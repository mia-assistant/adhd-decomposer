//
//  ContentView.swift
//  TinySteps Watch App
//
//  Main navigation view for the watch app.
//  Uses TabView for swipe navigation between Step and Timer views.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var viewModel = WatchViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StepView(viewModel: viewModel)
                .tag(0)
            
            TimerView(viewModel: viewModel)
                .tag(1)
        }
        .tabViewStyle(.page)
        .onAppear {
            viewModel.activateSession()
        }
    }
}

// MARK: - Watch View Model

@MainActor
class WatchViewModel: NSObject, ObservableObject {
    @Published var currentStep: String = "No active task"
    @Published var stepNumber: Int = 0
    @Published var totalSteps: Int = 0
    @Published var taskTitle: String = ""
    @Published var isConnected: Bool = false
    @Published var timerRemaining: Int = 0
    @Published var timerDuration: Int = 0
    
    private var session: WCSession?
    private var currentTaskId: String?
    private var currentStepId: String?
    
    // MARK: - Session Management
    
    func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }
    
    // MARK: - Actions
    
    func completeStep() {
        guard let taskId = currentTaskId, let stepId = currentStepId else { return }
        
        sendAction(StepAction(
            taskId: taskId,
            stepId: stepId,
            action: "complete",
            timestamp: Date()
        ))
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.success)
    }
    
    func skipStep() {
        guard let taskId = currentTaskId, let stepId = currentStepId else { return }
        
        sendAction(StepAction(
            taskId: taskId,
            stepId: stepId,
            action: "skip",
            timestamp: Date()
        ))
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.click)
    }
    
    private func sendAction(_ action: StepAction) {
        guard let session = session, session.isReachable else {
            // Queue for later sync
            queueAction(action)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(action)
            session.sendMessageData(data, replyHandler: nil) { error in
                print("Failed to send action: \(error)")
            }
        } catch {
            print("Failed to encode action: \(error)")
        }
    }
    
    private func queueAction(_ action: StepAction) {
        // Store in UserDefaults for later sync
        // Implementation: append to array in App Group shared container
    }
}

// MARK: - WCSessionDelegate

extension WatchViewModel: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith state: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            self.isConnected = state == .activated
        }
    }
    
    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        guard let data = userInfo["task"] as? Data else { return }
        
        do {
            let task = try JSONDecoder().decode(TaskSync.self, from: data)
            Task { @MainActor in
                self.updateFromSync(task)
            }
        } catch {
            print("Failed to decode task: \(error)")
        }
    }
    
    @MainActor
    private func updateFromSync(_ task: TaskSync) {
        self.currentTaskId = task.taskId
        self.taskTitle = task.taskTitle
        self.totalSteps = task.steps.count
        self.stepNumber = task.currentStepIndex + 1
        
        if task.currentStepIndex < task.steps.count {
            let step = task.steps[task.currentStepIndex]
            self.currentStep = step.text
            self.currentStepId = step.id
        }
        
        if let duration = task.timerDuration {
            self.timerDuration = duration
            self.timerRemaining = duration
        }
    }
}

// MARK: - Data Models

struct TaskSync: Codable {
    let taskId: String
    let taskTitle: String
    let steps: [StepSync]
    let currentStepIndex: Int
    let timerDuration: Int?
}

struct StepSync: Codable {
    let id: String
    let text: String
    let isCompleted: Bool
    let isSkipped: Bool
}

struct StepAction: Codable {
    let taskId: String
    let stepId: String
    let action: String
    let timestamp: Date
}

// MARK: - Preview

#Preview {
    ContentView()
}
