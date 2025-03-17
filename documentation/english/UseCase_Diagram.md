# ICY Application Use Case Diagram

## Primary Actors

1. **Regular User**: Regular employees using the ICY app
2. **Team Leader**: Department heads, can see team performance
3. **Administrator**: Can manage all system aspects

## Use Cases

### Authentication & User Management
- Login to application
- Register new account
- Reset password
- Update user profile
- View and edit personal details
- Select department during signup
- Verify email address

### Survey Functionality
- View available surveys
- Complete daily surveys
- Save survey progress
- Submit survey responses
- View survey history

### Achievements & Rewards
- View earned badges and achievements
- Track achievement progress
- View active challenges
- Complete challenges for rewards
- Earn XP and level up

### Marketplace
- Browse marketplace items
- View item categories
- Purchase rewards with earned coins
- View purchase history
- Redeem purchased items

### Team Collaboration
- View team members
- View team statistics
- Track team ranking
- View leaderboards
- Track department progress

### Notifications
- Receive notifications
- View notification history
- Mark notifications as read
- Respond to action notifications

### Administration
- Manage users
- Create and manage surveys
- Configure badges and challenges
- Manage marketplace items
- View system analytics
- Manage departments

## Department Management
- List all departments
- Add new departments
- Edit departments
- Deactivate departments
- Associate users with departments

## Use Case Relationships

- Regular User: Can perform all basic app functions
- Team Leader: Has Regular User permissions plus team management functions
- Administrator: Has all permissions and system management capabilities

## UML Use Case Diagram

```mermaid
flowchart TD
    User["Regular User"]
    TeamLead["Team Leader"]
    Admin["Administrator"]
    
    %% Authentication Use Cases
    Auth[Authentication]
    Login[Login]
    Register[Register]
    ResetPwd[Reset Password]
    Profile[Manage Profile]
    Verify[Verify Email]
    SelectDept[Select Department]
    
    %% Survey Use Cases
    Surveys[Surveys]
    ViewSurveys[View Surveys]
    CompleteSurveys[Complete Surveys]
    ViewHistory[View History]
    
    %% Achievement Use Cases
    Achieve[Achievements]
    ViewBadges[View Badges]
    Challenges[Complete Challenges]
    TrackProgress[Track Progress]
    
    %% Marketplace Use Cases
    Market[Marketplace]
    BrowseItems[Browse Items]
    Purchase[Purchase Items]
    Redeem[Redeem Rewards]
    
    %% Team Use Cases
    Team[Team Management]
    ViewTeam[View Team]
    TeamStats[Team Statistics]
    Leaderboard[Leaderboard]
    
    %% Notification Use Cases
    Notify[Notifications]
    ReceiveNotify[Receive Notifications]
    ManageNotify[Manage Notifications]
    
    %% Admin Use Cases
    AdminFunc[Administration]
    ManageUsers[Manage Users]
    ManageSurveys[Manage Surveys]
    ManageBadges[Manage Badges]
    ManageDepts[Manage Departments]
    SystemAnalytics[System Analytics]
    
    %% Department Management Use Cases
    DeptMgmt[Department Management]
    ListDepts[List Departments]
    AddDept[Add Department]
    EditDept[Edit Department]
    DeactivateDept[Deactivate Department]
    
    %% Relationships
    User --> Auth
    User --> Surveys
    User --> Achieve
    User --> Market
    User --> Team
    User --> Notify
    
    TeamLead --> User
    TeamLead --> Team
    
    Admin --> TeamLead
    Admin --> AdminFunc
    Admin --> DeptMgmt
    
    %% Detailed relationships
    Auth --> Login
    Auth --> Register
    Auth --> ResetPwd
    Auth --> Profile
    Auth --> Verify
    Auth --> SelectDept
    
    Surveys --> ViewSurveys
    Surveys --> CompleteSurveys
    Surveys --> ViewHistory
    
    Achieve --> ViewBadges
    Achieve --> Challenges
    Achieve --> TrackProgress
    
    Market --> BrowseItems
    Market --> Purchase
    Market --> Redeem
    
    Team --> ViewTeam
    Team --> TeamStats
    Team --> Leaderboard
    
    Notify --> ReceiveNotify
    Notify --> ManageNotify
    
    AdminFunc --> ManageUsers
    AdminFunc --> ManageSurveys
    AdminFunc --> ManageBadges
    AdminFunc --> ManageDepts
    AdminFunc --> SystemAnalytics
    
    DeptMgmt --> ListDepts
    DeptMgmt --> AddDept
    DeptMgmt --> EditDept
    DeptMgmt --> DeactivateDept


