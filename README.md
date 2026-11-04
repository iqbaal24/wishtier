# 🎯 WishTier

**A Smart Tier-Based Wishlist Application Built with Flutter**

WishTier is a mobile wishlist application that helps users organize, prioritize, and manage their desired purchases using a tier-based priority system. Instead of keeping all wishlist items in one long list, WishTier categorizes them into four priority levels, helping users make smarter purchasing decisions.

Built with Flutter, WishTier aims to provide a simple, intuitive, and efficient experience on Android and iOS.

---

## 📱 About the Project

Many people have multiple things they want to buy but limited budgets. Traditional wishlist applications often provide only a simple list without helping users determine which items should be prioritized.

WishTier solves this problem through a tier-based wishlist management system.

Users can categorize their wishlist items based on importance, track estimated costs, and monitor purchased items in one place.

### 🎯 Project Goals

- Organize wishlist items based on purchase priority.
- Help users make smarter purchasing decisions.
- Track estimated expenses for each priority tier.
- Provide a simple and intuitive wishlist management experience.
- Support offline access with local data storage.

---

## ✨ Key Features

### 1. Tier-Based Wishlist

Organize wishlist items into four priority levels:

| Tier | Priority | Description |
|:---:|---|---|
| S | Highest | Must Have – Very important and urgent |
| A | High | Important – Should be purchased soon |
| B | Medium | Nice to Have – Useful but not urgent |
| C | Low | Maybe Later – Can be postponed |

### 2. Wishlist Management (CRUD)

Manage wishlist items with the following information:

- Item name
- Estimated price
- Priority tier
- Notes or description
- Product URL
- Optional product image

### 3. Drag and Drop

Easily rearrange wishlist priorities by moving items between different tiers.

### 4. Purchase Tracking

- Mark wishlist items as purchased.
- Automatically move purchased items to purchase history.
- Keep active wishlist items separate from purchased items.

### 5. Expense Summary

Monitor estimated purchasing costs through:

- Total estimated cost per tier.
- Total cost of all active wishlist items.
- Better visibility into purchasing priorities.

### 6. Search and Filter

Find wishlist items quickly using:

- Item name search.
- Tier filtering.
- Purchase status filtering.

### 7. Offline Support

All wishlist data is stored locally on the device, allowing users to manage their wishlist without an internet connection.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile development |
| Dart | Programming language |
| SQLite / sqflite | Local database storage |
| Riverpod / Provider | State management |
| Material Design | User interface |
| ReorderableListView | Drag and drop functionality |

*The final libraries and dependencies may be adjusted during development.*

---

## 📂 Project Structure

```text
wishtier-v2/
├── android/
├── ios/
├── linux/
├── assets/
│   ├── images/
│   └── icons/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── data/
│   │   ├── database/
│   │   ├── models/
│   │   └── repositories/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── services/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 🚀 Getting Started

Follow these steps to run WishTier locally.

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android Emulator or a physical Android device

Check your Flutter installation:

```bash
flutter doctor
```

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/iqbaal24/wishtier-v2.git
```

**2. Navigate to the project directory**

```bash
cd wishtier-v2
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Check connected devices**

```bash
flutter devices
```

**5. Run the application**

```bash
flutter run
```

---

## 📸 Screenshots

Application screenshots will be added as the UI development progresses.

<!-- Add application screenshots here -->

---

## 🗺️ Development Roadmap

- [x] Product Requirements Document (PRD)
- [ ] UI/UX Design and Prototyping
- [ ] Project Architecture Setup
- [ ] Wishlist CRUD Operations
- [ ] Tier-Based Wishlist Display
- [ ] Drag and Drop Functionality
- [ ] Purchase Status Tracking
- [ ] Purchase History
- [ ] Expense Summary
- [ ] Search and Filtering
- [ ] Local Database Integration
- [ ] Testing and Bug Fixes
- [ ] Initial Release

---

## 🔮 Future Improvements

Features planned for future versions:

- User authentication and cloud synchronization.
- Purchase deadline and target date.
- Push notifications and reminders.
- Wishlist sharing with friends and family.
- Product price tracking.
- Dark mode customization.

---

## 🎯 Target Audience

WishTier is designed for:

- University students.
- Young professionals.
- People with limited purchasing budgets.
- Anyone who wants to organize and prioritize their shopping plans.

---

## 🤝 Contributing

Contributions, suggestions, and feedback are welcome.

If you have an idea to improve WishTier, feel free to fork this repository and submit a pull request.

---

## 👨‍💻 Author

**Mohammad Iqbal**

Informatics Engineering Student | Backend Developer Enthusiast

- GitHub: [@iqbaal24](https://github.com/iqbaal24)

---

## 📄 License

This project is developed for educational and personal development purposes.

---

<p align="center">
  Made with ❤️ using Flutter
</p>
