//
//  ComplicationController.swift
//  TinySteps Watch App Extension
//
//  Provides watch face complications for TinySteps.
//  Supports circular, rectangular, and corner styles.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "tinysteps-progress",
                displayName: "TinySteps Progress",
                supportedFamilies: [
                    .graphicCircular,
                    .graphicRectangular,
                    .graphicCorner,
                    .modularSmall
                ]
            )
        ]
        handler(descriptors)
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(
        for complication: CLKComplication,
        withHandler handler: @escaping (Date?) -> Void
    ) {
        // Update when task changes, not time-based
        handler(nil)
    }
    
    func getPrivacyBehavior(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void
    ) {
        // Show on lock screen - not sensitive data
        handler(.showOnLockScreen)
    }
    
    // MARK: - Current Entry
    
    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let taskData = loadCurrentTask()
        let template = createTemplate(for: complication.family, with: taskData)
        
        if let template = template {
            let entry = CLKComplicationTimelineEntry(
                date: Date(),
                complicationTemplate: template
            )
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    // MARK: - Template Creation
    
    private func createTemplate(
        for family: CLKComplicationFamily,
        with task: TaskComplicationData?
    ) -> CLKComplicationTemplate? {
        switch family {
        case .graphicCircular:
            return createGraphicCircular(task: task)
        case .graphicRectangular:
            return createGraphicRectangular(task: task)
        case .graphicCorner:
            return createGraphicCorner(task: task)
        case .modularSmall:
            return createModularSmall(task: task)
        default:
            return nil
        }
    }
    
    // MARK: - Graphic Circular
    
    private func createGraphicCircular(task: TaskComplicationData?) -> CLKComplicationTemplate {
        if let task = task, task.totalSteps > 0 {
            let fraction = Float(task.currentStep) / Float(task.totalSteps)
            
            return CLKComplicationTemplateGraphicCircularClosedGaugeText(
                gaugeProvider: CLKSimpleGaugeProvider(
                    style: .fill,
                    gaugeColor: .cyan,
                    fillFraction: fraction
                ),
                centerTextProvider: CLKSimpleTextProvider(
                    text: "\(task.currentStep)/\(task.totalSteps)"
                )
            )
        } else {
            // Empty state
            return CLKComplicationTemplateGraphicCircularStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "🎯"),
                line2TextProvider: CLKSimpleTextProvider(text: "Ready")
            )
        }
    }
    
    // MARK: - Graphic Rectangular
    
    private func createGraphicRectangular(task: TaskComplicationData?) -> CLKComplicationTemplate {
        if let task = task, task.totalSteps > 0 {
            let fraction = Float(task.currentStep) / Float(task.totalSteps)
            
            return CLKComplicationTemplateGraphicRectangularTextGauge(
                headerTextProvider: CLKSimpleTextProvider(text: task.taskTitle),
                body1TextProvider: CLKSimpleTextProvider(
                    text: "Step \(task.currentStep) of \(task.totalSteps)"
                ),
                gaugeProvider: CLKSimpleGaugeProvider(
                    style: .fill,
                    gaugeColor: .cyan,
                    fillFraction: fraction
                )
            )
        } else {
            return CLKComplicationTemplateGraphicRectangularStandardBody(
                headerTextProvider: CLKSimpleTextProvider(text: "🎯 TinySteps"),
                body1TextProvider: CLKSimpleTextProvider(text: "No active task"),
                body2TextProvider: nil
            )
        }
    }
    
    // MARK: - Graphic Corner
    
    private func createGraphicCorner(task: TaskComplicationData?) -> CLKComplicationTemplate {
        if let task = task, task.totalSteps > 0 {
            let fraction = Float(task.currentStep) / Float(task.totalSteps)
            
            return CLKComplicationTemplateGraphicCornerGaugeText(
                gaugeProvider: CLKSimpleGaugeProvider(
                    style: .fill,
                    gaugeColor: .cyan,
                    fillFraction: fraction
                ),
                outerTextProvider: CLKSimpleTextProvider(
                    text: "\(task.currentStep)/\(task.totalSteps)"
                )
            )
        } else {
            return CLKComplicationTemplateGraphicCornerTextImage(
                textProvider: CLKSimpleTextProvider(text: "Ready"),
                imageProvider: CLKFullColorImageProvider(
                    fullColorImage: UIImage(systemName: "checkmark.circle")!
                )
            )
        }
    }
    
    // MARK: - Modular Small
    
    private func createModularSmall(task: TaskComplicationData?) -> CLKComplicationTemplate {
        if let task = task, task.totalSteps > 0 {
            return CLKComplicationTemplateModularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "🎯"),
                line2TextProvider: CLKSimpleTextProvider(
                    text: "\(task.currentStep)/\(task.totalSteps)"
                )
            )
        } else {
            return CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: "🎯")
            )
        }
    }
    
    // MARK: - Data Loading
    
    private func loadCurrentTask() -> TaskComplicationData? {
        // Load from App Group shared UserDefaults
        guard let defaults = UserDefaults(suiteName: "group.com.yourcompany.tinysteps"),
              let data = defaults.data(forKey: "currentTask"),
              let task = try? JSONDecoder().decode(TaskComplicationData.self, from: data)
        else {
            return nil
        }
        
        return task
    }
}

// MARK: - Complication Data Model

struct TaskComplicationData: Codable {
    let taskTitle: String
    let currentStep: Int
    let totalSteps: Int
}

// MARK: - Complication Update Helper

extension ComplicationController {
    /// Call this when task data changes to update complications
    static func reloadComplications() {
        let server = CLKComplicationServer.sharedInstance()
        
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }
    
    /// Update complication data from WatchConnectivity
    static func updateFromSync(task: TaskSync) {
        let complicationData = TaskComplicationData(
            taskTitle: task.taskTitle,
            currentStep: task.currentStepIndex + 1,
            totalSteps: task.steps.count
        )
        
        guard let defaults = UserDefaults(suiteName: "group.com.yourcompany.tinysteps"),
              let encoded = try? JSONEncoder().encode(complicationData)
        else {
            return
        }
        
        defaults.set(encoded, forKey: "currentTask")
        reloadComplications()
    }
}
