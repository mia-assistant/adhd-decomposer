import WidgetKit
import SwiftUI

struct TaskEntry: TimelineEntry {
    let date: Date
    let taskName: String
    let currentStep: String
    let currentStepIndex: Int
    let totalSteps: Int
    let hasActiveTask: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            taskName: "Clean the kitchen",
            currentStep: "Gather cleaning supplies",
            currentStepIndex: 1,
            totalSteps: 5,
            hasActiveTask: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> ()) {
        let entry = getEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getEntry() -> TaskEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.miadevelops.adhd_decomposer")
        
        let taskName = userDefaults?.string(forKey: "task_name") ?? "No active task"
        let currentStep = userDefaults?.string(forKey: "current_step") ?? "Tap to start a task"
        let currentStepIndex = userDefaults?.integer(forKey: "current_step_index") ?? 0
        let totalSteps = userDefaults?.integer(forKey: "total_steps") ?? 0
        let hasActiveTask = userDefaults?.bool(forKey: "has_active_task") ?? false
        
        return TaskEntry(
            date: Date(),
            taskName: taskName,
            currentStep: currentStep,
            currentStepIndex: currentStepIndex,
            totalSteps: totalSteps,
            hasActiveTask: hasActiveTask
        )
    }
}

struct TinyStepsWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task name
            Text(entry.taskName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Current step
            Text(entry.currentStep)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(family == .systemSmall ? 2 : 3)
            
            Spacer()
            
            // Progress
            if entry.hasActiveTask && entry.totalSteps > 0 {
                HStack {
                    Text("Step \(entry.currentStepIndex + 1) of \(entry.totalSteps)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Image(systemName: "play.fill")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4ECDC4"), Color(hex: "3AA89F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

@main
struct TinyStepsWidget: Widget {
    let kind: String = "TinyStepsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TinyStepsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Current Task")
        .description("Shows your current step and progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TinyStepsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TinyStepsWidgetEntryView(entry: TaskEntry(
            date: Date(),
            taskName: "Clean the kitchen",
            currentStep: "Gather cleaning supplies from under the sink",
            currentStepIndex: 1,
            totalSteps: 5,
            hasActiveTask: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
