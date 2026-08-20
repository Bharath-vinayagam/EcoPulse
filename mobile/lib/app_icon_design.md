# Smart Expense CO₂ Tracker - App Icon Design

## Concept
A modern, eco-friendly icon combining:
- 💰 Money/Expense (Wallet)
- 🌱 Environment (Leaf)
- 📊 Tracking (Data)

## Design Description

### Primary Design (Recommended)
**Green Leaf with Currency Symbol**
- Background: Gradient from bright green (#00C853) to emerald (#00E676)
- Main Icon: White leaf outline with ₹/$ symbol integrated
- Style: Minimalist, modern, flat design
- Shape: Rounded square with slight shadow

### Visual Elements:
```
╔═══════════════════════════╗
║                           ║
║        🌿                 ║
║       /|\                 ║
║      / | \                ║
║     /  ₹  \               ║
║    /   |   \              ║
║   ───────────             ║
║                           ║
╚═══════════════════════════╝
```

Background: Green Gradient
Leaf: White with currency symbol in center
Style: Clean, professional, eco-conscious

## Color Palette
- Primary: #00C853 (Green)
- Secondary: #00E676 (Light Green)
- Accent: #FFFFFF (White)
- Shadow: rgba(0,0,0,0.15)

## Alternative Designs

### Option 2: CO₂ Molecule with Money
- CO₂ chemical formula
- Dollar/Rupee symbol integrated
- Green circular background

### Option 3: Plant Growing from Coin
- Minimalist plant sprout
- Emerging from a coin
- Symbolizes growth and savings

## Implementation Steps

1. Create SVG design in Figma/Illustrator
2. Export at multiple resolutions:
   - Android: 192x192 (xxxhdpi)
   - Android: 144x144 (xxhdpi)
   - Android: 96x96 (xhdpi)
   - Android: 72x72 (hdpi)
   - Android: 48x48 (mdpi)
   
3. Use flutter_launcher_icons package for automatic generation

## Quick Setup

Add to pubspec.yaml:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#00C853"
  adaptive_icon_foreground: "assets/icon/foreground.png"
```

Then run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Icon Philosophy
The icon represents:
- 🌱 Environmental consciousness
- 💰 Financial tracking
- 📈 Personal growth
- ♻️ Sustainability
- ✨ Modern technology

**Message:** "Track your money, save the planet"
