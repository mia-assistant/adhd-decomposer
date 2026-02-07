//
//  StepView.swift
//  TinySteps Watch App
//
//  Main step display view - shows current step with Done/Skip actions.
//  Designed for glanceability with large touch targets.
//

import SwiftUI

struct StepView: View {
    @ObservedObject var viewModel: WatchViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress indicator
            if viewModel.totalSteps > 0 {
                HStack {
                    Text("Step \(viewModel.stepNumber)/\(viewModel.totalSteps)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Mini progress
                    ProgressView(value: Double(viewModel.stepNumber), total: Double(viewModel.totalSteps))
                        .progressViewStyle(.linear)
                        .frame(width: 40)
                        .tint(.cyan)
                }
                .padding(.horizontal, 4)
            }
            
            // Step text
            ScrollView {
                Text(viewModel.currentStep)
                    .font(.system(size: isExpanded ? 16 : 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(isExpanded ? nil : 3)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: isExpanded ? .infinity : 60)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
            
            Spacer()
            
            // Action buttons
            if !isExpanded {
                actionButtons
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Done button
            Button(action: {
                viewModel.completeStep()
            }) {
                VStack(spacing: 2) {
                    Image(systemName: "checkmark")
                        .font(.title3)
                    Text("Done")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            // Skip button
            Button(action: {
                viewModel.skipStep()
            }) {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.right")
                        .font(.title3)
                    Text("Skip")
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .tint(.gray)
        }
    }
}

// MARK: - Empty State

struct EmptyStepView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Text("All done!")
                .font(.headline)
            
            Text("Open your phone to start a new task")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("With Step") {
    let viewModel = WatchViewModel()
    viewModel.currentStep = "Open the email and read the first paragraph carefully"
    viewModel.stepNumber = 3
    viewModel.totalSteps = 8
    return StepView(viewModel: viewModel)
}

#Preview("Long Step") {
    let viewModel = WatchViewModel()
    viewModel.currentStep = "This is a very long step that should demonstrate how the text wraps and truncates when it exceeds three lines on the watch display"
    viewModel.stepNumber = 1
    viewModel.totalSteps = 5
    return StepView(viewModel: viewModel)
}
