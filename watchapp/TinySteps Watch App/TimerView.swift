//
//  TimerView.swift
//  TinySteps Watch App
//
//  Focus timer with circular progress and haptic feedback.
//  Supports pause/resume and configurable intervals.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var viewModel: WatchViewModel
    @State private var isRunning = false
    @State private var timer: Timer?
    
    private var progress: Double {
        guard viewModel.timerDuration > 0 else { return 0 }
        return 1 - (Double(viewModel.timerRemaining) / Double(viewModel.timerDuration))
    }
    
    private var timeString: String {
        let minutes = viewModel.timerRemaining / 60
        let seconds = viewModel.timerRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Task title
            if !viewModel.taskTitle.isEmpty {
                Text(viewModel.taskTitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Circular progress timer
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        Color.gray.opacity(0.3),
                        lineWidth: 8
                    )
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        timerColor,
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                // Time display
                VStack(spacing: 2) {
                    Text(timeString)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                    
                    if isRunning {
                        Image(systemName: "pause.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 100, height: 100)
            .onTapGesture {
                toggleTimer()
            }
            
            // Control button
            Button(action: toggleTimer) {
                Label(
                    isRunning ? "Pause" : "Start",
                    systemImage: isRunning ? "pause.fill" : "play.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isRunning ? .orange : .cyan)
            
            // Duration presets (when not running)
            if !isRunning && viewModel.timerRemaining == 0 {
                durationPresets
            }
        }
        .padding(.horizontal, 8)
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Duration Presets
    
    private var durationPresets: some View {
        HStack(spacing: 8) {
            ForEach([5, 10, 15], id: \.self) { minutes in
                Button("\(minutes)m") {
                    setDuration(minutes: minutes)
                }
                .font(.caption2)
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - Timer Color
    
    private var timerColor: Color {
        if viewModel.timerRemaining <= 60 {
            return .red
        } else if viewModel.timerRemaining <= 300 {
            return .orange
        } else {
            return .cyan
        }
    }
    
    // MARK: - Timer Controls
    
    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        guard viewModel.timerRemaining > 0 else {
            // Default to 5 minutes if no duration set
            setDuration(minutes: 5)
            return
        }
        
        isRunning = true
        WKInterfaceDevice.current().play(.start)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                tick()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        WKInterfaceDevice.current().play(.stop)
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        guard viewModel.timerRemaining > 0 else {
            timerComplete()
            return
        }
        
        viewModel.timerRemaining -= 1
        
        // Haptic pulse every 5 minutes
        if viewModel.timerRemaining > 0 && viewModel.timerRemaining % 300 == 0 {
            WKInterfaceDevice.current().play(.notification)
        }
        
        // Warning at 1 minute
        if viewModel.timerRemaining == 60 {
            WKInterfaceDevice.current().play(.retry)
        }
    }
    
    private func timerComplete() {
        stopTimer()
        
        // Double haptic for completion
        WKInterfaceDevice.current().play(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    private func setDuration(minutes: Int) {
        let seconds = minutes * 60
        viewModel.timerDuration = seconds
        viewModel.timerRemaining = seconds
    }
}

// MARK: - Preview

#Preview("Running") {
    let viewModel = WatchViewModel()
    viewModel.taskTitle = "Clean Kitchen"
    viewModel.timerDuration = 300
    viewModel.timerRemaining = 187
    return TimerView(viewModel: viewModel)
}

#Preview("Stopped") {
    let viewModel = WatchViewModel()
    viewModel.taskTitle = "Focus Time"
    viewModel.timerDuration = 0
    viewModel.timerRemaining = 0
    return TimerView(viewModel: viewModel)
}
