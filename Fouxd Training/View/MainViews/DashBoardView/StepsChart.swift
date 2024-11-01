//
//  StepsChart.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 27.10.2024.
//

import SwiftUI
import Charts


struct DailySteps: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Double
}

struct StepsChart: View {
    let data: [(date: Date, steps: Double)]  // Updated to match HealthKitManager data structure
    @State private var selectedData: (date: Date, steps: Double)?
    @State private var plotWidth: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Weekly Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(LocalizedStringResource(stringLiteral: "\(totalSteps) steps"))
                        .font(.title3)
                        .bold()
                }
                Spacer()
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: progressToGoal)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                .frame(width: 40, height: 40)
            }
            
            // Chart
            Chart {
                ForEach(data, id: \.date) { daily in
                    AreaMark(
                        x: .value("Day", daily.date),
                        y: .value("Steps", daily.steps)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Day", daily.date),
                        y: .value("Steps", daily.steps)
                    )
                    .foregroundStyle(.blue)
                    .symbol(Circle())
                    
                    if let selected = selectedData,
                       selected.date == daily.date {
                        RuleMark(x: .value("Day", daily.date))
                            .foregroundStyle(.gray.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1))
                            .annotation(position: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Steps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(Int(daily.steps))")
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
    
    private var totalSteps: Int {
        data.reduce(0) { $0 + Int($1.steps) }
    }
    
    private var progressToGoal: Double {
        let dailyGoal = 10000.0 // Daily goal for steps
        let averageSteps = Double(totalSteps) / Double(data.count)
        return min(averageSteps / dailyGoal, 1.0)
    }
}
