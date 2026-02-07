# Cloud Sync Design Specification

*Tiny Steps - Optional Account & Cloud Sync*

## Overview

Cloud sync allows users to optionally create an account and sync their data across devices. This is a **premium feature** included in the subscription.

## Requirements

### Must Have
- Completely optional (app works 100% offline)
- No data collected without explicit opt-in
- End-to-end encryption for user data
- Sync across iOS and Android
- Conflict resolution for simultaneous edits

### Should Have
- Anonymous account option (no email required)
- Data export (JSON/CSV)
- Account deletion (GDPR compliance)

### Nice to Have
- Share routines with other users
- Family sharing
- Web dashboard

## Data Model

### Syncable Data
```dart
class SyncableData {
  // Tasks
  List<Task> tasks;
  List<Task> completedTasks;  // Last 30 days
  
  // Routines
  List<Routine> routines;
  
  // Stats
  StatsSnapshot stats;
  
  // Achievements
  List<Achievement> unlockedAchievements;
  
  // Settings (optional sync)
  UserPreferences preferences;
  
  // Profile
  PlayerProfile profile;  // Level, XP, unlocks
  
  // Metadata
  DateTime lastSyncedAt;
  String deviceId;
  int schemaVersion;
}
```

### Not Synced (Device-specific)
- Notification preferences
- Calendar permissions
- API keys
- Cache data

## Backend Options

### Option A: Firebase (Recommended for MVP)
- Firestore for data storage
- Firebase Auth for accounts
- Cloud Functions for complex operations
- Pros: Quick to implement, scales well
- Cons: Vendor lock-in, costs at scale

### Option B: Supabase
- PostgreSQL database
- Built-in auth
- Open source
- Pros: Self-hostable, SQL familiar
- Cons: More setup required

### Option C: Custom Backend
- Node.js/Go API
- PostgreSQL + Redis
- Pros: Full control
- Cons: Most development time

**Recommendation:** Start with Firebase for speed to market. Migrate later if needed.

## Authentication Flow

```
User taps "Enable Cloud Sync"
         ↓
    Create Account
    ┌─────────────┐
    │ - Email     │
    │ - Apple ID  │
    │ - Google    │
    │ - Anonymous │
    └─────────────┘
         ↓
    Initial Sync
    (Upload local data)
         ↓
    Sync Complete
    (Show success)
```

### Anonymous Accounts
- Generate random identifier
- Can upgrade to email later
- Data preserved on upgrade
- Warning: Unrecoverable if device lost

## Sync Strategy

### Approach: Merge with Timestamps

Each record has:
- `id`: UUID
- `createdAt`: Timestamp
- `updatedAt`: Timestamp  
- `deletedAt`: Timestamp (soft delete)
- `deviceId`: Source device

### Conflict Resolution
1. Compare `updatedAt` timestamps
2. Most recent update wins
3. If same second, prefer server version
4. Deleted items stay deleted (tombstone)

### Sync Frequency
- On app launch (if online)
- After each task completion
- Every 5 minutes in background
- Manual pull-to-refresh

## Data Flow

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Device A  │      │   Server    │      │   Device B  │
└─────────────┘      └─────────────┘      └─────────────┘
       │                    │                    │
       │ ──── Push ────────>│                    │
       │                    │<──── Pull ─────────│
       │                    │                    │
       │<─── Pull ──────────│                    │
       │                    │ ──── Push ────────>│
```

## Security

### Encryption
- TLS 1.3 for transport
- AES-256 for data at rest
- Client-side encryption for sensitive fields (optional)

### Privacy
- Minimal data collection
- No analytics without consent
- Data residency options (EU/US)
- 30-day deletion after account closure

### Authentication Security
- MFA support (optional)
- Session tokens with refresh
- Device management (revoke access)

## UI Components

### Settings > Cloud Sync
```
┌─────────────────────────────┐
│  ☁️ Cloud Sync              │
│                             │
│  Status: Synced             │
│  Last sync: 2 minutes ago   │
│                             │
│  [Sync Now]                 │
│                             │
│  ───────────────────────    │
│                             │
│  Account: user@email.com    │
│  [Manage Account]           │
│  [Sign Out]                 │
│                             │
│  ───────────────────────    │
│                             │
│  [Export Data]              │
│  [Delete Account]           │
└─────────────────────────────┘
```

### Sync Status Indicator
- Small cloud icon in app bar
- ✓ Synced (green)
- ↻ Syncing (animated)
- ⚠ Pending (yellow)
- ✗ Offline (gray)

## Error Handling

| Error | User Message | Action |
|-------|--------------|--------|
| Network offline | "Working offline. Will sync when connected." | Queue changes |
| Auth expired | "Please sign in again" | Re-auth flow |
| Conflict | Silent merge | Log for debugging |
| Server error | "Sync temporarily unavailable" | Retry with backoff |
| Quota exceeded | "Storage limit reached" | Prompt upgrade |

## Migration Path

### From Local-Only to Synced
1. User enables sync
2. Create account
3. Upload all local data
4. Server assigns IDs
5. Future changes sync

### From Synced to Local-Only
1. Download all data
2. Sign out
3. Data remains local
4. Sync disabled

## Implementation Phases

### Phase 1: Foundation
- [ ] Firebase project setup
- [ ] Auth service (email, Apple, Google)
- [ ] Basic data model
- [ ] Settings UI for enable/disable

### Phase 2: Core Sync
- [ ] Task sync
- [ ] Routine sync
- [ ] Stats sync
- [ ] Conflict resolution

### Phase 3: Polish
- [ ] Background sync
- [ ] Offline queue
- [ ] Sync status UI
- [ ] Error handling

### Phase 4: Advanced
- [ ] Data export
- [ ] Account deletion
- [ ] Multi-device management
- [ ] Sharing features

## Cost Estimation (Firebase)

| Users | Reads/month | Writes/month | Storage | Est. Cost |
|-------|-------------|--------------|---------|-----------|
| 1K | 500K | 100K | 1GB | $0 (free tier) |
| 10K | 5M | 1M | 10GB | ~$25/mo |
| 50K | 25M | 5M | 50GB | ~$150/mo |
| 100K | 50M | 10M | 100GB | ~$350/mo |

## Files to Create

```
lib/data/services/
├── sync_service.dart        # Main sync orchestration
├── auth_service.dart        # Authentication
├── cloud_storage_service.dart  # Firestore operations
└── offline_queue.dart       # Pending changes queue

lib/data/models/
├── sync_record.dart         # Base syncable model
└── sync_status.dart         # Sync state

lib/presentation/screens/
└── cloud_sync_screen.dart   # Settings/management UI
```

## Decision Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Backend | Firebase | Fast MVP, scales, good Flutter support |
| Auth | Multiple providers | User choice, Apple required for App Store |
| Sync strategy | Timestamp merge | Simple, handles most cases |
| Encryption | Transport + at-rest | Balance of security and performance |
| Anonymous accounts | Yes | Lower barrier to try sync |

---

*This is a design spec. Implementation requires Firebase setup and significant development time. Estimate: 2-3 weeks for basic sync.*
