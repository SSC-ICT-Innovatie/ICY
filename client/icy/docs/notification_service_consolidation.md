# Notification Service Consolidation Strategy

## Current Situation

The app currently has two separate notification services:

1. **SystemNotificationService** (`lib/services/notification_service.dart`) 
   - Handles device-level notifications using flutter_local_notifications
   - Manages permissions, scheduling, and showing actual notifications on the device

2. **NotificationService** (`lib/features/notifications/services/notification_service.dart`)
   - Handles in-app UI notifications and notification management
   - Manages notification dialogs, UI elements, and notification-specific navigation

## Consolidation Plan

### Short-term Solution
- Keep both services with clear naming and documentation
- Use appropriate service for each use case
- Add TODOs to indicate future consolidation

### Long-term Solution
- Create a unified `NotificationService` that handles both system and in-app notifications
- Implement as a facade pattern with specialized handlers for each type
- Structure:
  ```
  NotificationService
  ├── SystemNotificationHandler (device notifications)
  └── UINotificationHandler (in-app notifications)
  ```

### Implementation Steps
1. Create new consolidated service
2. Migrate functionality from both existing services
3. Update all references to use the new service
4. Remove old services once migration is complete

## Benefits of Consolidation
- Single source of truth for notification handling
- Simplified API for components using notifications
- Better coordination between in-app and system notifications
- Clearer separation of concerns with specialized handlers
