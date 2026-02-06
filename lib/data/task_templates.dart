// Pre-made task decompositions for common ADHD struggle tasks.
// Users can pick from these instead of using AI decomposition.

class TaskTemplate {
  final String id;
  final String title;
  final String category;
  final List<TaskTemplateStep> steps;
  final int totalMinutes;
  final String? icon;
  final String? description;

  const TaskTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.steps,
    required this.totalMinutes,
    this.icon,
    this.description,
  });
}

class TaskTemplateStep {
  final String action;
  final int minutes;

  const TaskTemplateStep({
    required this.action,
    required this.minutes,
  });
}

/// All available task template categories
class TaskCategories {
  static const String home = 'home';
  static const String work = 'work';
  static const String selfcare = 'selfcare';
  static const String errands = 'errands';

  static const Map<String, String> labels = {
    home: 'Home',
    work: 'Work & Productivity',
    selfcare: 'Self-Care',
    errands: 'Errands',
  };

  static const Map<String, String> icons = {
    home: '🏠',
    work: '💼',
    selfcare: '🧘',
    errands: '🏃',
  };
}

/// All pre-made task templates organized by category
class TaskTemplates {
  // ============================================
  // HOME TASKS
  // ============================================

  static const cleanKitchen = TaskTemplate(
    id: 'clean_kitchen',
    title: 'Clean the Kitchen',
    category: TaskCategories.home,
    icon: '🍳',
    description: 'Get your kitchen sparkling in manageable chunks',
    totalMinutes: 35,
    steps: [
      TaskTemplateStep(action: 'Clear the sink – put dishes in dishwasher or stack to wash', minutes: 3),
      TaskTemplateStep(action: 'Wash any dishes that need hand-washing', minutes: 8),
      TaskTemplateStep(action: 'Wipe down countertops', minutes: 4),
      TaskTemplateStep(action: 'Clean stovetop', minutes: 5),
      TaskTemplateStep(action: 'Wipe cabinet fronts if needed', minutes: 3),
      TaskTemplateStep(action: 'Take out kitchen trash', minutes: 2),
      TaskTemplateStep(action: 'Sweep or vacuum the floor', minutes: 5),
      TaskTemplateStep(action: 'Mop the floor', minutes: 5),
    ],
  );

  static const doLaundry = TaskTemplate(
    id: 'do_laundry',
    title: 'Do Laundry (Full Cycle)',
    category: TaskCategories.home,
    icon: '👕',
    description: 'Wash, dry, fold, and put away – the complete journey',
    totalMinutes: 45,
    steps: [
      TaskTemplateStep(action: 'Gather dirty clothes and check pockets', minutes: 5),
      TaskTemplateStep(action: 'Sort by color/type if needed', minutes: 3),
      TaskTemplateStep(action: 'Load washing machine and start cycle', minutes: 3),
      TaskTemplateStep(action: '⏰ Set timer – do something else while washing!', minutes: 1),
      TaskTemplateStep(action: 'Move clothes to dryer or hanging area', minutes: 5),
      TaskTemplateStep(action: '⏰ Set timer – do something else while drying!', minutes: 1),
      TaskTemplateStep(action: 'Take clothes out while still warm', minutes: 2),
      TaskTemplateStep(action: 'Fold everything (play music or a podcast!)', minutes: 15),
      TaskTemplateStep(action: 'Put folded clothes away in drawers/closet', minutes: 10),
    ],
  );

  static const cleanBathroom = TaskTemplate(
    id: 'clean_bathroom',
    title: 'Clean the Bathroom',
    category: TaskCategories.home,
    icon: '🚿',
    description: 'A fresh bathroom in bite-sized steps',
    totalMinutes: 30,
    steps: [
      TaskTemplateStep(action: 'Spray toilet with cleaner and let it sit', minutes: 1),
      TaskTemplateStep(action: 'Clear countertop and put things away', minutes: 3),
      TaskTemplateStep(action: 'Wipe down mirror', minutes: 2),
      TaskTemplateStep(action: 'Clean sink and faucet', minutes: 3),
      TaskTemplateStep(action: 'Wipe countertop', minutes: 2),
      TaskTemplateStep(action: 'Scrub and wipe toilet (inside and outside)', minutes: 5),
      TaskTemplateStep(action: 'Spray and wipe shower/tub', minutes: 6),
      TaskTemplateStep(action: 'Empty trash', minutes: 1),
      TaskTemplateStep(action: 'Sweep floor', minutes: 3),
      TaskTemplateStep(action: 'Mop or wipe floor', minutes: 4),
    ],
  );

  static const declutterDesk = TaskTemplate(
    id: 'declutter_desk',
    title: 'Declutter Desk/Workspace',
    category: TaskCategories.home,
    icon: '🖥️',
    description: 'Transform your workspace chaos into calm',
    totalMinutes: 25,
    steps: [
      TaskTemplateStep(action: 'Take everything off the desk surface', minutes: 3),
      TaskTemplateStep(action: 'Throw away obvious trash and recycling', minutes: 2),
      TaskTemplateStep(action: 'Wipe down the desk surface', minutes: 2),
      TaskTemplateStep(action: 'Sort papers into keep, file, or toss piles', minutes: 5),
      TaskTemplateStep(action: 'File or put away the "keep" papers', minutes: 5),
      TaskTemplateStep(action: 'Organize supplies – pens, cables, etc.', minutes: 4),
      TaskTemplateStep(action: 'Put back only what you actually use daily', minutes: 3),
      TaskTemplateStep(action: 'Find a home for items that don\'t belong on desk', minutes: 1),
    ],
  );

  static const takeOutTrash = TaskTemplate(
    id: 'take_out_trash',
    title: 'Take Out Trash & Recycling',
    category: TaskCategories.home,
    icon: '🗑️',
    description: 'Quick win – the easiest adulting task',
    totalMinutes: 10,
    steps: [
      TaskTemplateStep(action: 'Get new trash bags ready', minutes: 1),
      TaskTemplateStep(action: 'Tie up kitchen trash bag', minutes: 1),
      TaskTemplateStep(action: 'Check other rooms for small trash bins', minutes: 2),
      TaskTemplateStep(action: 'Gather recycling', minutes: 2),
      TaskTemplateStep(action: 'Walk everything to the bin/curb', minutes: 3),
      TaskTemplateStep(action: 'Put new bags in all trash cans', minutes: 1),
    ],
  );

  // ============================================
  // WORK/PRODUCTIVITY TASKS
  // ============================================

  static const processInbox = TaskTemplate(
    id: 'process_inbox',
    title: 'Process Email Inbox',
    category: TaskCategories.work,
    icon: '📧',
    description: 'Inbox zero is possible – one email at a time',
    totalMinutes: 30,
    steps: [
      TaskTemplateStep(action: 'Open email and sort by date (oldest first)', minutes: 1),
      TaskTemplateStep(action: 'Delete/archive obvious junk and newsletters', minutes: 5),
      TaskTemplateStep(action: 'Reply to quick emails (under 2 min each)', minutes: 10),
      TaskTemplateStep(action: 'Star/flag emails needing longer responses', minutes: 3),
      TaskTemplateStep(action: 'Add tasks to to-do list from action emails', minutes: 5),
      TaskTemplateStep(action: 'Archive everything that\'s been handled', minutes: 3),
      TaskTemplateStep(action: 'Unsubscribe from 2-3 unwanted lists', minutes: 3),
    ],
  );

  static const startDifficultTask = TaskTemplate(
    id: 'start_difficult_task',
    title: 'Start a Difficult Work Task',
    category: TaskCategories.work,
    icon: '🎯',
    description: 'The hardest part is starting – break through the wall',
    totalMinutes: 35,
    steps: [
      TaskTemplateStep(action: 'Write down exactly what the task is in one sentence', minutes: 2),
      TaskTemplateStep(action: 'Set a 25-minute timer (Pomodoro!)', minutes: 1),
      TaskTemplateStep(action: 'Close distracting tabs and put phone away', minutes: 2),
      TaskTemplateStep(action: 'Open the file/tool you need to work in', minutes: 1),
      TaskTemplateStep(action: 'Do the easiest possible first step', minutes: 5),
      TaskTemplateStep(action: 'Work for the remaining timer (just keep going!)', minutes: 19),
      TaskTemplateStep(action: 'Take a 5-minute break – you earned it!', minutes: 5),
    ],
  );

  static const writeReport = TaskTemplate(
    id: 'write_report',
    title: 'Write a Report/Document',
    category: TaskCategories.work,
    icon: '📝',
    description: 'From blank page to finished document',
    totalMinutes: 60,
    steps: [
      TaskTemplateStep(action: 'Brain dump – write down all points to include', minutes: 5),
      TaskTemplateStep(action: 'Create basic outline with section headers', minutes: 5),
      TaskTemplateStep(action: 'Write the easiest section first (any section!)', minutes: 15),
      TaskTemplateStep(action: 'Write the introduction', minutes: 10),
      TaskTemplateStep(action: 'Fill in remaining sections', minutes: 15),
      TaskTemplateStep(action: 'Write the conclusion', minutes: 5),
      TaskTemplateStep(action: 'Quick proofread for obvious errors', minutes: 5),
    ],
  );

  static const prepareForMeeting = TaskTemplate(
    id: 'prepare_for_meeting',
    title: 'Prepare for a Meeting',
    category: TaskCategories.work,
    icon: '📅',
    description: 'Walk in confident and prepared',
    totalMinutes: 20,
    steps: [
      TaskTemplateStep(action: 'Review meeting invite – check time, attendees, agenda', minutes: 2),
      TaskTemplateStep(action: 'Review any shared documents or previous notes', minutes: 5),
      TaskTemplateStep(action: 'Write down 2-3 questions you want to ask', minutes: 3),
      TaskTemplateStep(action: 'Note your key points or updates to share', minutes: 4),
      TaskTemplateStep(action: 'Prepare any materials you need to present', minutes: 4),
      TaskTemplateStep(action: 'Get water/coffee and settle in 2 min early', minutes: 2),
    ],
  );

  static const makePhoneCall = TaskTemplate(
    id: 'make_phone_call',
    title: 'Make a Phone Call You\'ve Been Avoiding',
    category: TaskCategories.work,
    icon: '📞',
    description: 'Phone anxiety is real – let\'s conquer it together',
    totalMinutes: 15,
    steps: [
      TaskTemplateStep(action: 'Write down who you\'re calling and why', minutes: 1),
      TaskTemplateStep(action: 'Write out your opening sentence', minutes: 2),
      TaskTemplateStep(action: 'List 2-3 key points you need to cover', minutes: 2),
      TaskTemplateStep(action: 'Have pen and paper ready for notes', minutes: 1),
      TaskTemplateStep(action: 'Take three deep breaths', minutes: 1),
      TaskTemplateStep(action: 'Dial the number NOW (don\'t overthink!)', minutes: 1),
      TaskTemplateStep(action: 'Have the conversation', minutes: 5),
      TaskTemplateStep(action: 'Write down any follow-up actions', minutes: 2),
    ],
  );

  // ============================================
  // SELF-CARE TASKS
  // ============================================

  static const morningRoutine = TaskTemplate(
    id: 'morning_routine',
    title: 'Morning Routine',
    category: TaskCategories.selfcare,
    icon: '🌅',
    description: 'Start your day right with a structured routine',
    totalMinutes: 45,
    steps: [
      TaskTemplateStep(action: 'Get out of bed when alarm goes off (no snooze!)', minutes: 1),
      TaskTemplateStep(action: 'Drink a glass of water', minutes: 1),
      TaskTemplateStep(action: 'Use the bathroom', minutes: 5),
      TaskTemplateStep(action: 'Wash face and brush teeth', minutes: 5),
      TaskTemplateStep(action: 'Get dressed (clothes out the night before helps!)', minutes: 5),
      TaskTemplateStep(action: 'Make and eat breakfast', minutes: 15),
      TaskTemplateStep(action: 'Take any medications', minutes: 1),
      TaskTemplateStep(action: 'Quick check of today\'s schedule', minutes: 3),
      TaskTemplateStep(action: 'Grab everything you need and head out/start work', minutes: 5),
      TaskTemplateStep(action: 'Give yourself a mental high-five – you did it!', minutes: 1),
    ],
  );

  static const eveningRoutine = TaskTemplate(
    id: 'evening_routine',
    title: 'Evening Routine (Wind Down)',
    category: TaskCategories.selfcare,
    icon: '🌙',
    description: 'Set yourself up for better sleep',
    totalMinutes: 40,
    steps: [
      TaskTemplateStep(action: 'Set tomorrow\'s clothes out', minutes: 3),
      TaskTemplateStep(action: 'Quick 5-minute tidy of main living space', minutes: 5),
      TaskTemplateStep(action: 'Set phone to charge and enable Do Not Disturb', minutes: 1),
      TaskTemplateStep(action: 'Brush teeth and do skincare', minutes: 8),
      TaskTemplateStep(action: 'Take any evening medications', minutes: 1),
      TaskTemplateStep(action: 'Do something relaxing (read, stretch, journal)', minutes: 15),
      TaskTemplateStep(action: 'Get into bed', minutes: 2),
      TaskTemplateStep(action: 'Deep breaths and gratitude for one good thing today', minutes: 3),
      TaskTemplateStep(action: 'Lights out – you\'ve got this!', minutes: 2),
    ],
  );

  static const showerAndGetReady = TaskTemplate(
    id: 'shower_and_get_ready',
    title: 'Shower and Get Ready',
    category: TaskCategories.selfcare,
    icon: '🚿',
    description: 'The shower is calling – answer it!',
    totalMinutes: 30,
    steps: [
      TaskTemplateStep(action: 'Get towel and clothes ready', minutes: 2),
      TaskTemplateStep(action: 'Turn on water to warm up', minutes: 1),
      TaskTemplateStep(action: 'Get in the shower', minutes: 1),
      TaskTemplateStep(action: 'Wash hair', minutes: 3),
      TaskTemplateStep(action: 'Wash body', minutes: 3),
      TaskTemplateStep(action: 'Rinse and enjoy the warm water briefly', minutes: 2),
      TaskTemplateStep(action: 'Get out and dry off', minutes: 3),
      TaskTemplateStep(action: 'Deodorant and any lotions', minutes: 2),
      TaskTemplateStep(action: 'Get dressed', minutes: 5),
      TaskTemplateStep(action: 'Style hair if needed', minutes: 5),
      TaskTemplateStep(action: 'Hang up towel – done!', minutes: 1),
    ],
  );

  static const exerciseWorkout = TaskTemplate(
    id: 'exercise_workout',
    title: 'Exercise Workout',
    category: TaskCategories.selfcare,
    icon: '💪',
    description: 'Movement is medicine – even a short workout counts!',
    totalMinutes: 35,
    steps: [
      TaskTemplateStep(action: 'Put on workout clothes', minutes: 3),
      TaskTemplateStep(action: 'Fill water bottle', minutes: 1),
      TaskTemplateStep(action: 'Start with light warm-up (marching, arm circles)', minutes: 3),
      TaskTemplateStep(action: 'Dynamic stretches', minutes: 3),
      TaskTemplateStep(action: 'Main workout (your choice of activity!)', minutes: 20),
      TaskTemplateStep(action: 'Cool down and stretch', minutes: 5),
    ],
  );

  static const mealPrep = TaskTemplate(
    id: 'meal_prep',
    title: 'Meal Prep',
    category: TaskCategories.selfcare,
    icon: '🥗',
    description: 'Future you will thank present you!',
    totalMinutes: 60,
    steps: [
      TaskTemplateStep(action: 'Decide on 2-3 simple meals to prep', minutes: 3),
      TaskTemplateStep(action: 'Check what ingredients you have', minutes: 3),
      TaskTemplateStep(action: 'Get out all containers you\'ll need', minutes: 2),
      TaskTemplateStep(action: 'Wash and chop all vegetables', minutes: 15),
      TaskTemplateStep(action: 'Cook any proteins (chicken, beans, etc.)', minutes: 20),
      TaskTemplateStep(action: 'Cook any grains (rice, pasta, etc.)', minutes: 2),
      TaskTemplateStep(action: 'Portion everything into containers', minutes: 10),
      TaskTemplateStep(action: 'Label containers with contents and date', minutes: 2),
      TaskTemplateStep(action: 'Clean up kitchen', minutes: 3),
    ],
  );

  // ============================================
  // ERRANDS
  // ============================================

  static const groceryShopping = TaskTemplate(
    id: 'grocery_shopping',
    title: 'Go Grocery Shopping',
    category: TaskCategories.errands,
    icon: '🛒',
    description: 'In and out efficiently – you can do this!',
    totalMinutes: 50,
    steps: [
      TaskTemplateStep(action: 'Check what you already have at home', minutes: 3),
      TaskTemplateStep(action: 'Write shopping list by store section', minutes: 5),
      TaskTemplateStep(action: 'Grab reusable bags', minutes: 1),
      TaskTemplateStep(action: 'Drive/walk to store', minutes: 10),
      TaskTemplateStep(action: 'Get a cart and work through list systematically', minutes: 20),
      TaskTemplateStep(action: 'Checkout', minutes: 5),
      TaskTemplateStep(action: 'Load groceries and head home', minutes: 6),
    ],
  );

  static const returnItem = TaskTemplate(
    id: 'return_item',
    title: 'Return an Item to Store',
    category: TaskCategories.errands,
    icon: '📦',
    description: 'Stop procrastinating – get that refund!',
    totalMinutes: 30,
    steps: [
      TaskTemplateStep(action: 'Find the item to return', minutes: 2),
      TaskTemplateStep(action: 'Find receipt (check email for digital receipt)', minutes: 3),
      TaskTemplateStep(action: 'Put item in bag with receipt', minutes: 1),
      TaskTemplateStep(action: 'Look up store return policy if unsure', minutes: 2),
      TaskTemplateStep(action: 'Drive to store', minutes: 10),
      TaskTemplateStep(action: 'Go to customer service desk and do the return', minutes: 10),
      TaskTemplateStep(action: 'Celebrate – that\'s money back in your pocket!', minutes: 2),
    ],
  );

  static const scheduleDoctorAppointment = TaskTemplate(
    id: 'schedule_doctor_appointment',
    title: 'Schedule a Doctor Appointment',
    category: TaskCategories.errands,
    icon: '🏥',
    description: 'Your health matters – make the call!',
    totalMinutes: 15,
    steps: [
      TaskTemplateStep(action: 'Find doctor\'s phone number (check insurance card or google)', minutes: 2),
      TaskTemplateStep(action: 'Have insurance card ready', minutes: 1),
      TaskTemplateStep(action: 'Check your calendar for available times', minutes: 2),
      TaskTemplateStep(action: 'Call the office (you can do it!)', minutes: 5),
      TaskTemplateStep(action: 'Pick a date and time that works', minutes: 2),
      TaskTemplateStep(action: 'Add appointment to your calendar immediately', minutes: 2),
      TaskTemplateStep(action: 'Set a reminder for 1 day before', minutes: 1),
    ],
  );

  static const payBills = TaskTemplate(
    id: 'pay_bills',
    title: 'Pay Bills',
    category: TaskCategories.errands,
    icon: '💰',
    description: 'Adulting achievement unlocked!',
    totalMinutes: 25,
    steps: [
      TaskTemplateStep(action: 'Gather all bills (paper and check email)', minutes: 3),
      TaskTemplateStep(action: 'List each bill with due date and amount', minutes: 5),
      TaskTemplateStep(action: 'Check bank account balance', minutes: 2),
      TaskTemplateStep(action: 'Pay bills in order of due date', minutes: 12),
      TaskTemplateStep(action: 'File or discard paid bill statements', minutes: 2),
      TaskTemplateStep(action: 'Set up autopay for recurring bills if possible', minutes: 1),
    ],
  );

  // ============================================
  // ALL TEMPLATES
  // ============================================

  static const List<TaskTemplate> all = [
    // Home
    cleanKitchen,
    doLaundry,
    cleanBathroom,
    declutterDesk,
    takeOutTrash,
    // Work
    processInbox,
    startDifficultTask,
    writeReport,
    prepareForMeeting,
    makePhoneCall,
    // Self-care
    morningRoutine,
    eveningRoutine,
    showerAndGetReady,
    exerciseWorkout,
    mealPrep,
    // Errands
    groceryShopping,
    returnItem,
    scheduleDoctorAppointment,
    payBills,
  ];

  /// Get all templates for a specific category
  static List<TaskTemplate> byCategory(String category) {
    return all.where((t) => t.category == category).toList();
  }

  /// Get all unique categories
  static List<String> get categories {
    return [
      TaskCategories.home,
      TaskCategories.work,
      TaskCategories.selfcare,
      TaskCategories.errands,
    ];
  }
}
