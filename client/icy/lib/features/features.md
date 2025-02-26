# Features Folder Structure / Feature Map Structuur 🗂️

## Overview / Overzicht 👁️

Each feature in our app is organized in its own folder for better code management. Think of it like keeping different tools in separate drawers.

Elk onderdeel van onze app heeft zijn eigen map voor betere code organisatie. Denk eraan als verschillende gereedschappen in aparte lades.

## Structure / Structuur 🏗️

```
features/
├── feature_name/           # Example: authentication, profile, settings
│   ├── ui/                # 🖼️ Everything users see and interact with
│   ├── domain/           # 🧠 Business rules and data handling
│   └── state/           # 💾 How the app remembers things
```

## What Goes Where? / Wat Komt Waar? 🧩

### UI Folder / UI Map 🖼️
- **screens**: 📱 Full pages users see
- **widgets**: 🧰 Reusable UI pieces (buttons, cards)
- **views**: 👀 Different ways to show the same information

### Domain Folder / Domain Map 🧠
- **models**: 📋 Templates for our data (like user profile structure)
- **repositories**: 🔌 How we talk to databases and APIs
- Think of it as the brain of the feature

### State Folder / State Map 💾
- **bloc**: 🔄 Controls how data flows
- **events**: 👆 What users do (tap buttons, type text)
- **states**: 📊 Current situation of the app (loading, error, success)

## Tips for New Developers / Tips voor Nieuwe Ontwikkelaars 💡
1. Start with the UI folder when building new features
2. Keep related code together
3. When in doubt, ask if code belongs to UI, Domain, or State

## Quick Example / Snel Voorbeeld 📝
```dart
// In ui/screens/login_screen.dart
class LoginScreen extends StatelessWidget {...}

// In domain/models/user.dart
class User {...}

// In state/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {...}
```
