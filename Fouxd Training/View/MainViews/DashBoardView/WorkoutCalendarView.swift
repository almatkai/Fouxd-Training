//
//  WorkoutCalendarView.swift
//  Fouxd Training
//
//  Created by Naukanova Nuraiym on 27.10.2024.
//

import SwiftUI

struct WorkoutCalendarView: View {
    let workoutHistories: [WorkoutHistory]
    let calendar = Calendar.current
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            Text("Workout Completion")
                .font(.headline)
                .padding(.bottom)
            
            CalendarView(
                selectedDate: $selectedDate,
                workoutHistories: workoutHistories
            )
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.cGradientPurple1), Color(.cGradientPurple2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(22)
//        .shadow(radius: 2)
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    let workoutHistories: [WorkoutHistory]
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // Month and year header
            HStack {
                Text(selectedDate.formatted(.dateTime.month().year()))
                    .font(.title3)
                    .bold()
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding(.bottom)
            
            // Weekday headers
            HStack {
                ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            workouts: workoutsForDate(date)
                        )
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
    
    private func previousMonth() {
        withAnimation {
            selectedDate = calendar.date(
                byAdding: .month,
                value: -1,
                to: selectedDate
            ) ?? selectedDate
        }
    }
    
    private func nextMonth() {
        withAnimation {
            selectedDate = calendar.date(
                byAdding: .month,
                value: 1,
                to: selectedDate
            ) ?? selectedDate
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        
        let days = calendar.generateDates(
            inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
        
        return days.map { date in
            calendar.isDate(date, equalTo: monthInterval.start, toGranularity: .month) ? date : nil
        }
    }
    
    private func workoutsForDate(_ date: Date) -> [WorkoutHistory] {
        workoutHistories.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

struct DayCell: View {
    let date: Date
    let workouts: [WorkoutHistory]
    
    private var isFutureDate: Bool {
        date > Date()
    }
    
    private var completionPercentage: Double {
        if workouts.isEmpty { return 0 }
        let totalCompleted = workouts.reduce(0.0) { $0 + Double($1.exercisesCompleted) }
        let totalExercises = workouts[0].totalExercises

        if totalExercises > 0 {
            let percentage = totalCompleted / Double(totalExercises)
            return min(percentage * 100, 100)
        } else {
            return 0
        }
    }
    
    private var color: Color {
        if completionPercentage >= 66.66 { return .green }
        if completionPercentage >= 33.33 { return .yellow }
        return .red
    }
    
    var body: some View {
        ZStack {
            if !isFutureDate && completionPercentage != 0 {
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 28, height: 28)
            }
            
            if !isFutureDate {
                if completionPercentage >= 99.9999 {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                } else if completionPercentage > 0.001 {
                    Text("\(Int(completionPercentage))%")
                        .font(.system(size: 10))
                        .foregroundColor(color)
                } else {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption2)
                .foregroundColor(.secondary)
                .position(x: 2, y: 2)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .offset(x: 6, y: 6)
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
    
    // Additional helper functions that might be useful
    func startOfMonth(for date: Date) -> Date? {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)
    }
    
    func endOfMonth(for date: Date) -> Date? {
        guard let startOfNextMonth = self.date(
            byAdding: DateComponents(month: 1),
            to: startOfMonth(for: date) ?? date
        ) else { return nil }
        
        return self.date(byAdding: DateComponents(second: -1), to: startOfNextMonth)
    }
    
    func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        return compare(date1, to: date2, toGranularity: .day) == .orderedSame
    }
    
    func isDateInToday(_ date: Date) -> Bool {
        return isDate(date, inSameDayAs: Date())
    }
}
