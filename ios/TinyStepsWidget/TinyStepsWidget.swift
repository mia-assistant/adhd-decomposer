import WidgetKit
import SwiftUI

// MARK: - Brand Colors

struct BrandColors {
    static let teal500 = Color(hex: "4ECDC4")
    static let teal600 = Color(hex: "3BB8B0")
    static let teal700 = Color(hex: "2A9D8F")
    static let coral500 = Color(hex: "FF6B6B")
    static let coral400 = Color(hex: "FF8585")
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "555555")
    static let textTertiary = Color(hex: "999999")
    static let surface = Color.white
    static let backgroundLight = Color(hex: "FAFAFA")
}

// MARK: - Entry

struct TaskEntry: TimelineEntry {
    let date: Date
    let taskName: String
    let currentStep: String
    let currentStepIndex: Int
    let totalSteps: Int
    let hasActiveTask: Bool
    
    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStepIndex + 1) / Double(totalSteps)
    }
    
    var motivationalText: String {
        guard hasActiveTask && totalSteps > 0 else { return "" }
        let remaining = totalSteps - (currentStepIndex + 1)
        switch progress {
        case 0..<0.25: return "You've got this! 💪"
        case 0.25..<0.5: return "Great momentum!"
        case 0.5..<0.75: return "Over halfway there!"
        case 0.75..<1.0:
            if remaining == 1 { return "Just 1 step left! 🎯" }
            return "Almost done! 🔥"
        default: return "Finishing up! ✨"
        }
    }
}

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            taskName: "Clean the kitchen",
            currentStep: "Gather cleaning supplies",
            currentStepIndex: 2,
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

// MARK: - Circular Progress Ring

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    BrandColors.teal500.opacity(0.2),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [BrandColors.teal500, BrandColors.coral500]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Step Dots

struct StepDots: View {
    let current: Int
    let total: Int
    let maxVisible: Int
    
    var body: some View {
        HStack(spacing: 3) {
            let visibleCount = min(total, maxVisible)
            ForEach(0..<visibleCount, id: \.self) { index in
                let actualIndex = total > maxVisible
                    ? mapIndex(index, visibleCount: visibleCount)
                    : index
                
                Circle()
                    .fill(actualIndex <= current ? BrandColors.teal500 : BrandColors.teal500.opacity(0.2))
                    .frame(width: actualIndex == current ? 6 : 4, height: actualIndex == current ? 6 : 4)
            }
            if total > maxVisible {
                Text("+\(total - maxVisible)")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(BrandColors.textTertiary)
            }
        }
    }
    
    private func mapIndex(_ index: Int, visibleCount: Int) -> Int {
        // Show dots centered around current step
        let halfVisible = visibleCount / 2
        let start = max(0, min(current - halfVisible, total - visibleCount))
        return start + index
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: TaskEntry
    
    var body: some View {
        if entry.hasActiveTask {
            activeSmallView
        } else {
            emptySmallView
        }
    }
    
    private var activeSmallView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: task name + progress ring
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.taskName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(BrandColors.textSecondary)
                        .lineLimit(1)
                    
                    if entry.totalSteps > 0 {
                        Text("Step \(entry.currentStepIndex + 1)/\(entry.totalSteps)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(BrandColors.textTertiary)
                    }
                }
                
                Spacer()
                
                if entry.totalSteps > 0 {
                    ZStack {
                        ProgressRing(progress: entry.progress, lineWidth: 3, size: 28)
                        
                        Text("\(Int(entry.progress * 100))%")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(BrandColors.teal700)
                    }
                }
            }
            
            Spacer(minLength: 6)
            
            // Current step — hero text
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [BrandColors.teal500, BrandColors.coral500]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
                
                Text(entry.currentStep)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(BrandColors.textPrimary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 6)
            
            // Footer: motivational text
            Text(entry.motivationalText)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(BrandColors.coral500)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.surface)
    }
    
    private var emptySmallView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(BrandColors.teal500)
            
            Text("Ready to start?")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(BrandColors.textPrimary)
            
            Text("Tap to break down\na task")
                .font(.system(size: 10))
                .foregroundColor(BrandColors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.surface)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: TaskEntry
    
    var body: some View {
        if entry.hasActiveTask {
            activeMediumView
        } else {
            emptyMediumView
        }
    }
    
    private var activeMediumView: some View {
        HStack(spacing: 14) {
            // Left side: progress ring
            VStack {
                ZStack {
                    ProgressRing(progress: entry.progress, lineWidth: 4.5, size: 56)
                    
                    VStack(spacing: 0) {
                        Text("\(entry.currentStepIndex + 1)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(BrandColors.teal700)
                        Text("of \(entry.totalSteps)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(BrandColors.textTertiary)
                    }
                }
                
                Spacer()
            }
            .frame(width: 56)
            
            // Right side: text content
            VStack(alignment: .leading, spacing: 4) {
                // Task name
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(BrandColors.teal500)
                    
                    Text(entry.taskName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(BrandColors.textSecondary)
                        .lineLimit(1)
                }
                
                // Current step — hero
                Text(entry.currentStep)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(BrandColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 4)
                
                // Progress bar + motivational text
                VStack(alignment: .leading, spacing: 4) {
                    // Step dots
                    if entry.totalSteps > 0 {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Track
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(BrandColors.teal500.opacity(0.15))
                                    .frame(height: 4)
                                
                                // Fill
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [BrandColors.teal500, BrandColors.coral400]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(4, geo.size.width * CGFloat(entry.progress)), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    
                    HStack {
                        Text(entry.motivationalText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(BrandColors.coral500)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(BrandColors.teal500.opacity(0.5))
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.surface)
    }
    
    private var emptyMediumView: some View {
        HStack(spacing: 16) {
            // Decorative icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                BrandColors.teal500.opacity(0.1),
                                BrandColors.coral500.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundColor(BrandColors.teal500)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ready when you are")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(BrandColors.textPrimary)
                
                Text("Tap to break any task into tiny, manageable steps")
                    .font(.system(size: 12))
                    .foregroundColor(BrandColors.textTertiary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.surface)
    }
}

// MARK: - Lock Screen Widget (iOS 16+)

@available(iOSApplicationExtension 16.0, *)
struct AccessoryRectangularView: View {
    let entry: TaskEntry
    
    var body: some View {
        if entry.hasActiveTask {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.system(size: 8))
                    Text(entry.taskName)
                        .font(.system(size: 10, weight: .semibold))
                        .lineLimit(1)
                }
                .opacity(0.7)
                
                Text(entry.currentStep)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(2)
                
                if entry.totalSteps > 0 {
                    // Mini progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 1)
                                .opacity(0.2)
                                .frame(height: 2)
                            RoundedRectangle(cornerRadius: 1)
                                .frame(width: max(2, geo.size.width * CGFloat(entry.progress)), height: 2)
                        }
                    }
                    .frame(height: 2)
                }
            }
        } else {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                VStack(alignment: .leading) {
                    Text("Tiny Steps")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Tap to start a task")
                        .font(.system(size: 10))
                        .opacity(0.7)
                }
            }
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct AccessoryCircularView: View {
    let entry: TaskEntry
    
    var body: some View {
        if entry.hasActiveTask && entry.totalSteps > 0 {
            ZStack {
                AccessoryWidgetBackground()
                
                VStack(spacing: 0) {
                    Text("\(entry.currentStepIndex + 1)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("/\(entry.totalSteps)")
                        .font(.system(size: 9, weight: .medium))
                        .opacity(0.7)
                }
            }
            .widgetLabel {
                ProgressView(value: entry.progress)
                    .tint(.teal)
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
            }
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct AccessoryInlineView: View {
    let entry: TaskEntry
    
    var body: some View {
        if entry.hasActiveTask && entry.totalSteps > 0 {
            Label(
                "Step \(entry.currentStepIndex + 1)/\(entry.totalSteps): \(entry.currentStep)",
                systemImage: "target"
            )
        } else {
            Label("Tiny Steps — Tap to start", systemImage: "sparkles")
        }
    }
}

// MARK: - Main Entry View (Router)

struct TinyStepsWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            default:
                if #available(iOSApplicationExtension 16.0, *) {
                    lockScreenView
                } else {
                    SmallWidgetView(entry: entry)
                }
            }
        }
    }
    
    @available(iOSApplicationExtension 16.0, *)
    @ViewBuilder
    private var lockScreenView: some View {
        switch family {
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Color Extension

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

// MARK: - Widget Configuration

@main
struct TinyStepsWidget: Widget {
    let kind: String = "TinyStepsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                TinyStepsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TinyStepsWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Current Task")
        .description("Shows your current step and progress")
        .supportedFamilies(supportedFamilies)
    }
    
    private var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall, .systemMedium]
        if #available(iOSApplicationExtension 16.0, *) {
            families.append(contentsOf: [
                .accessoryRectangular,
                .accessoryCircular,
                .accessoryInline
            ])
        }
        return families
    }
}

// MARK: - Lock Screen Entry View

@available(iOSApplicationExtension 16.0, *)
struct LockScreenEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            EmptyView()
        }
    }
}

// MARK: - Previews

struct TinyStepsWidget_Previews: PreviewProvider {
    static var previews: some View {
        // Small — Active task
        SmallWidgetView(entry: TaskEntry(
            date: Date(),
            taskName: "Clean the kitchen",
            currentStep: "Wipe down countertops with cloth",
            currentStepIndex: 5,
            totalSteps: 9,
            hasActiveTask: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Small — Active")
        
        // Small — Empty
        SmallWidgetView(entry: TaskEntry(
            date: Date(),
            taskName: "No active task",
            currentStep: "Tap to start a task",
            currentStepIndex: 0,
            totalSteps: 0,
            hasActiveTask: false
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Small — Empty")
        
        // Medium — Active task
        MediumWidgetView(entry: TaskEntry(
            date: Date(),
            taskName: "Clean the kitchen",
            currentStep: "Wipe down countertops with cloth",
            currentStepIndex: 5,
            totalSteps: 9,
            hasActiveTask: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .previewDisplayName("Medium — Active")
        
        // Medium — Empty
        MediumWidgetView(entry: TaskEntry(
            date: Date(),
            taskName: "No active task",
            currentStep: "Tap to start a task",
            currentStepIndex: 0,
            totalSteps: 0,
            hasActiveTask: false
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .previewDisplayName("Medium — Empty")
        
        // Medium — Almost done
        MediumWidgetView(entry: TaskEntry(
            date: Date(),
            taskName: "Morning routine",
            currentStep: "Put on shoes",
            currentStepIndex: 6,
            totalSteps: 7,
            hasActiveTask: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .previewDisplayName("Medium — Almost Done")
    }
}
