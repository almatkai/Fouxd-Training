//
//  ActivityChart.swift
//  Fouxd Training
//
//  Created by Almat Kairatov on 27.10.2024.
//

import SwiftUI
import Charts


struct DailyActivity: Identifiable {
    let id = UUID()
    let date: Date
    let activeEnergy: Double
}

struct ActivityChart: View {
    let data: [(date: Date, calories: Double)]
    @State private var selectedData: (date: Date, calories: Double)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                
                Spacer()
                // Activity ring
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.2), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: progressToGoal)
                        .stroke(
                            AngularGradient(
                                colors: [.orange, .red],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 40, height: 40)
            }
            
            // Chart
            Chart {
                ForEach(data, id: \.date) { daily in
                    BarMark(
                        x: .value("Day", daily.date),
                        y: .value("Calories", daily.calories)  // Updated to use calories
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.orange, .red],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(8)
                    
                    if let selected = selectedData,
                       selected.date == daily.date {
                        RuleMark(x: .value("Day", daily.date))
                            .foregroundStyle(.gray.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                            .annotation(position: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(LocalizedStringKey(stringLiteral: "Active Energy"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Int(daily.calories)) kcal")  // Updated to use calories
                                        .font(.caption)
                                        .bold()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemBackground))
                                        .shadow(radius: 2)
                                )
                            }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday())
                }
            }
            .chartPlotStyle { plot in
                plot.frame(height: 180)
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let currentX = value.location.x - geometry.frame(in: .local).origin.x
                                    guard currentX >= 0, currentX <= geometry.size.width else {
                                        selectedData = nil
                                        return
                                    }
                                    
                                    let date = proxy.value(atX: currentX, as: Date.self)
                                    selectedData = data.first { Calendar.current.isDate($0.date, inSameDayAs: date!) }
                                }
                                .onEnded { _ in
                                    selectedData = nil
                                }
                        )
                }
            }
        }
    }
    
    private var totalCalories: Int {
        data.reduce(0) { $0 + Int($1.calories) }
    }
    
    private var progressToGoal: Double {
        let dailyGoal = 600.0
        let averageCalories = Double(totalCalories) / Double(data.count)
        return min(averageCalories / dailyGoal, 1.0)
    }
}
