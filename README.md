# 🌿 EcoPulse — AI-Powered Green Fintech & Carbon Intelligence Platform
> **EcoPulse** is an AI-powered Carbon Footprint & Financial Management Platform that enables users to track daily expenses, compute real-time carbon emissions, scan paper receipts using live OCR, compare transport commute options, set reduction targets, and plant virtual trees in a digital eco-forest.

The platform leverages **Google ML Kit OCR** for on-device receipt scanning, **FastAPI** for high-performance carbon classification, and **Supabase Cloud PostgreSQL** for real-time cloud data synchronization and multi-user authentication.

By combining Machine Learning, Retrieval-Augmented Rule Engines, Interactive Analytics, and Groq-powered AI assistance, **EcoPulse** transforms everyday financial logging into actionable environmental intelligence through a sleek mobile interface.

---

## 🚀 Key Features

### 📷 Live Camera & Receipt OCR Scanner
Scan paper receipts and invoices effortlessly using your phone camera or gallery:
- **On-Device Optical Recognition**: Powered by Google ML Kit OCR.
- **Dynamic NLP & Entity Extraction**: Automatically extracts Vendor Name, Total Amount (INR / USD), Category, and Carbon Footprint.
- **Smart Regex Parser**: Identifies line items, totals, currency symbols (`₹`, `Rs.`, `$`), and tax breakdowns.
- **Zero Placeholder Output**: Full real-time entity recognition with fallback protection.

### ☁️ Supabase Cloud Database & User Auth
- **PostgreSQL Cloud Sync**: Connected to live Supabase PostgreSQL via IPv4 connection poolers.
- **Multi-User Security**: `bcrypt` password hashing and secure token-based user authentication.
- **Isolated User Storage**: Scoped per-user profile photo storage (Camera, Gallery, or Remove Photo options).

### 🚗 Transport Carbon Comparator
Compare side-by-side emissions, financial cost, and XP rewards across 5 commute modes:
- **Continuous 0.5 km Slider Math**: Smooth distance selection from `0.5 km` to `50.0 km`.
- **Custom Decimal Input Modal (✏️)**: Allows typing any exact trip distance (e.g. `2.5 km`, `7.8 km`, `14.25 km`).
- **Modes Covered**: Walking/Cycling, Metro/Bus, Electric Vehicle (EV), Carpool, and Solo Petrol Car.

### 🌲 Digital Eco Forest & Tree Offset Engine
- **Eco Letter Grade**: Evaluates carbon footprint from Grade **A+** (Pristine Zero Footprint) to **D** (High Emission).
- **Tree Offset Math**: Calculates exact annual and monthly tree offset requirements (`21.7 kg CO₂ / tree / year`).
- **Virtual Tree Planting**: Gamified reward engine allowing users to pledge 100 XP points to plant virtual trees in their digital forest.

### 🎯 Target Goals & Weekly Quests
- **Custom Carbon & Spending Goals**: Set active targets by category or total emissions.
- **Interactive Goal Deletion**: Red trash bin button with confirmation modal to remove completed or outdated goals.
- **Weekly Eco Quests**: Interactive challenge system (`Meatless Monday`, `Zero-Car Commute`, `Energy Saver`) with XP rewards and streak tracking.

### 📊 Executive Carbon Audit CSV Export
- Generate downloadable CSV reports containing full transaction logs, categories, amounts, dates, and carbon footprints for personal or enterprise environmental compliance auditing.

### 💬 AI Eco Advisor Chatbot
- Context-aware green financial assistant answering natural language questions about reducing travel emissions, sustainable diets, and streak points.

---

## 🎯 Why Supabase Cloud & On-Device ML Kit?

Traditional expense trackers rely on manual data entry and local SQLite databases that do not sync across devices.

Smart Expense CO₂ Tracker Pro adopts cloud database synchronization and on-device machine learning:

| Feature | Legacy Expense Trackers | Smart Expense CO₂ Tracker Pro |
|---|---|---|
| **Data Storage** | Local SQLite Cache | ☁️ Live Supabase Cloud PostgreSQL |
| **Receipt Processing** | Manual Typing | 📷 Google ML Kit Live Camera OCR |
| **Carbon Calculation** | Static Rough Guesses | 🧠 Dynamic Multi-Factor Classifier |
| **Multi-Device Sync** | ❌ Unavailable | ✅ Real-Time Cloud Sync |
| **Profile Photos** | Default Icons | 👤 User-Isolated Camera & Gallery Picker |
| **Audit Compliance** | ❌ No Export | 📊 Executive CSV Audit Engine |

---

## 🏗️ System Architecture

```
                 User Mobile Device (Flutter App)
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
  📷 Google ML Kit OCR                 🔒 SharedPreferences
  (On-Device Text Parsing)              (User Session & Cache)
            │                                     │
            └──────────────────┬──────────────────┘
                               ▼
                    FastAPI Backend Server
               (https://eco-pulse-eta.vercel.app)
                               │
     ┌─────────────────────────┼─────────────────────────┐
     ▼                         ▼                         ▼
🧠 AI Emission           📊 Analytics & CSV         💬 Groq / Rule
  Classifier               Audit Engine               AI Chatbot
     │                         │                         │
     └─────────────────────────┼─────────────────────────┘
                               ▼
                  ☁️ Supabase Cloud Database
                    (PostgreSQL Engine)
```

---

## 🔄 Data & Receipt Processing Workflow

```
[ User Snaps Receipt / Input Expense ]
                 │
                 ▼
[ Google ML Kit OCR Text Extraction ]
                 │
                 ▼
[ Regex & NLP Entity Extractor (Vendor + Amount) ]
                 │
                 ▼
[ Multi-Factor Emission Classifier (Category + CO₂ kg) ]
                 │
                 ▼
[ Supabase PostgreSQL Storage & User Streak Update ]
                 │
                 ▼
[ Real-Time Dashboard, Eco Forest & Leaderboard Refresh ]
```

---

## 🛠️ Tech Stack

| Component | Technology | Description |
|---|---|---|
| **Mobile Frontend** | Flutter 3.x, Dart | Cross-platform UI for Android & iOS |
| **Backend API** | FastAPI, Python 3.10 | High-performance async REST API |
| **Database** | Supabase PostgreSQL | Live cloud database with IPv4 pooler support |
| **On-Device OCR** | Google ML Kit | Real-time optical character recognition |
| **Security** | Passlib, Bcrypt | Password hashing & session security |
| **Visual Analytics** | FL Chart, AnimateDo | Interactive charts & micro-animations |
| **Data Export** | StreamingResponse CSV | Executive carbon audit export engine |
| **Testing** | Custom QA Test Runner | 24-point automated test suite |

---

## 📂 Project Structure

```
smart-expense-co2/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── auth.py              # User authentication router (Register/Login)
│   │   ├── classifier.py        # AI Carbon Emission & Category Classifier
│   │   ├── database.py          # SQLAlchemy & Supabase PostgreSQL connection
│   │   ├── emissions.json       # Emission factor reference dataset
│   │   ├── main.py              # FastAPI main application & 24 API routes
│   │   ├── models.py            # SQLAlchemy database models
│   │   └── schemas.py           # Pydantic data validation schemas
│   ├── .env.example             # Sample environment variable config
│   ├── Dockerfile               # Backend Docker container config
│   ├── migrate_to_supabase.py   # SQLite to Supabase migration script
│   ├── requirements.txt         # Python dependencies
│   └── test_qa_suite.py         # 24-point QA automated test runner
│
├── mobile/
│   ├── android/                 # Native Android build manifests
│   ├── assets/                  # App branding & icons
│   ├── lib/
│   │   ├── models/              # Dart data models (Expense, Summary)
│   │   ├── screens/
│   │   │   ├── analytics_screen.dart        # Monthly charts & forecast
│   │   │   ├── goals_screen.dart            # Active targets & deletion
│   │   │   ├── home_screen.dart             # Dashboard & Eco Forest modal
│   │   │   ├── login_screen.dart            # Authentication UI
│   │   │   ├── main_navigation.dart         # Bottom nav bar & FAB
│   │   │   ├── profile_screen.dart          # Scoped avatar & settings
│   │   │   ├── scan_screen.dart             # Live Camera OCR & manual log
│   │   │   └── transport_compare_screen.dart# Commute carbon comparator
│   │   ├── services/
│   │   │   └── api_service.dart # HTTP client with automatic IP fallback
│   │   ├── utils/
│   │   │   └── app_theme.dart   # Design tokens & color gradients
│   │   └── main.dart            # App entry point & theme listener
│   └── pubspec.yaml             # Flutter dependencies
│
├── .gitignore                   # Workspace git exclusion rules
└── README.md                    # Project documentation
```

---

## ⚙️ Installation & Setup Guide

### 1️⃣ Clone Repository
```bash
git clone https://github.com/YOUR_USERNAME/smart-expense-co2.git
cd smart-expense-co2
```

### 2️⃣ Configure Backend Environment
```bash
cd backend
python -m venv venv

# On Windows:
venv\Scripts\activate
# On macOS / Linux:
source venv/bin/activate

pip install -r requirements.txt
```

Create `.env` file inside `backend/`:
```env
DATABASE_URL=postgresql://postgres.your_ref:your_password@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres
```

### 3️⃣ Launch Backend Server
```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```
Open API Docs: `http://127.0.0.1:8000/docs`

### 4️⃣ Run QA Automated Test Suite
```bash
python test_qa_suite.py
```

### 5️⃣ Launch Mobile App
```bash
cd ../mobile
flutter pub get

# Enable ADB reverse port for physical Android device
adb reverse tcp:8000 tcp:8000

flutter run
```

---

## 💡 Example Use Cases

- **Snap Receipt via Live Camera**: Take a picture of a supermarket or fuel receipt and watch ML Kit auto-fill the vendor and total amount.
- **Compare Commute Footprint**: Calculate whether taking the Metro vs driving solo saves `12.5 kg CO₂` for your 15 km daily commute.
- **Pledge Virtual Trees**: Accumulate 100 XP points by logging low-emission expenses and plant digital trees to improve your Eco Grade.
- **Export Executive CSV Audit**: Download full transaction histories for carbon tax compliance or personal sustainability reports.

---

## 🎯 Future Enhancements

- 🌐 Multi-Currency Conversion (USD, EUR, INR, GBP).
- 📲 Push Notifications for Carbon Budget Threshold Alerts.
- 🤝 Social Community Leaderboards & Group Carbon Offsets.
- 🧾 PDF Invoice Scanner Integration.

---

## 👩‍💻 Author

**Bharath Vinayagam**  
*B.Tech Computer Science and Engineering*  
*VIT Chennai*

---

⭐ **If you found this project useful, consider giving it a star on GitHub!**
