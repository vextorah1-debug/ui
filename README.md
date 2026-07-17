# Handoff: Brainrot Collector Game UI System

## Overview
Complete UI system for a Roblox brainrot-collecting game. These HTML files are **design references** — prototypes showing the intended look and behavior. Your task is to **recreate these designs in Roblox Studio** as ScreenGuis using the Roblox MCP, matching colors, spacing, typography, and interactions as closely as possible.

## Fidelity
**High-fidelity.** All colors, spacing, typography, border radii, and interactions are final. Recreate pixel-perfectly using Roblox UI objects.

## Design Language
- **Dark theme** with card-based panels on a dark background
- **Roblox "chunky" button style**: gradient backgrounds, thick bottom borders (3-4px) that compress on click, rounded corners (8-14px)
- **Header bars** on every panel: 64px tall, gradient colored, with Lilita One font title + thick text stroke outline, stud texture overlay (optional repeating rounded-rect pattern at 6% opacity)
- **Close buttons**: red gradient pill (40x40), Lilita One "X"
- **Toast notifications**: slide in from top-right

## Screens / Panels

### 1. HUD (Always Visible)
- **Top-left**: Health bar (red #F2543E), Hunger bar (orange #F0B93A), Stamina bar (green #8CDC3E) — each with icon, label, numeric value
- **Top-center**: Level badge + XP bar (blue #4E9BEC), Cash display (green #B4F470), Gems display (cyan #5AD6A0)
- **Bottom-center**: Hotbar — 9 slots + equipped slot, dark cards (#1D2230), 1.5px border #2A3044, 10px radius
- **Bottom-right**: Minimap — 200x200 rounded square, dark border
- **Right side**: Vertical button strip for opening panels (Shop, Rebirth, Index, Quests, Events, Settings, Upgrades, Sell, Admin)
  - Each button: 52x52, gradient bg matching its theme color, 1.5px border, thick bottom border, rounded 11px, icon + label below

### 2. Shop Panel (1240px wide)
- **Header**: Green gradient (#66CE36 → #4CB322), title "SHOP"
- **Tabs**: Featured, Boosts, Brainrots, Gamepasses — each a chunky pill button
- **Featured tab**: 2-column grid (main + 330px sidebar). Main has featured cards with rarity borders, price tags. Sidebar has daily deals + best value bundles
- **Boosts tab**: Grid of boost items with duration, multiplier, price
- **Brainrots tab**: Collection grid showing brainrot creatures with rarity colors
- **Gamepasses tab**: Premium items grid with Robux pricing

### 3. Upgrades Panel (640px wide) ⭐ NEW
- **Header**: Gold gradient (#F0B93A → #DD9615), title "UPGRADES"
- **Balance display**: Shows current cash at top
- **Upgrade rows** (3 items):
  - **Carry Capacity** (green #8CDC3E) — "Hold more brainrots" — Lv.8 — $4,200
  - **Speed** (blue #4E9BEC) — "Movement speed boost" — Lv.3 — $1,800
  - **Luck** (purple #B564F2) — "Better rare spawn odds" — Lv.5 — $3,100
- Each row: icon well (42x42, tinted bg), name + description, progress bar showing level/50, green buy button with price
- Footer note: "Max level per upgrade: 50 · Prices scale each level"

### 4. Sell Panel (480px wide) ⭐ NEW
- **Header**: Green gradient (#66CE36 → #4CB322), title "SELL"
- **Sell Preview box**: Shows value breakdown
  - Equipped (1 brainrot): $2,400
  - Inventory (12 brainrots): $18,750
- **Three buttons**:
  - "Sell Equipped · $2,400" — green gradient
  - "Sell Inventory · $18,750" — gold gradient
  - "Never mind" — dark gray, closes panel

### 5. Rebirth Panel (1240px wide)
- **Header**: Purple gradient (#AE58F0 → #8B34D6), title "REBIRTH"
- Shows rebirth tier, multiplier bonus, milestone rewards
- Rebirth button with confirmation

### 6. Index / Collection (1240px wide)
- **Header**: Blue gradient (#4E9BEC → #2F7BD6), title "INDEX"
- Search bar + grid of all brainrot creatures
- Cards show: image placeholder, name, rarity color, owned count

### 7. Quests (640px wide)
- **Header**: Gold gradient (#F0B93A → #DD9615), title "QUESTS"
- Daily/Weekly tabs
- Quest rows: description, progress bar, reward chip, claim button

### 8. Settings (1240px wide)
- **Header**: Gray gradient, title "SETTINGS"
- Left sidebar tabs: General, Graphics, Audio, Controls, About
- Toggle rows, select dropdowns, sliders
- Reset tab / Save All / unsaved-changes modal

### 9. Events (1240px wide)
- **Header**: Orange gradient (#F2843E → #D96420), title "EVENTS"
- 3-column grid of event cards with status badges, countdown timers, reward chips
- Vote for next event, start event early (Robux)

### 10. Inventory (1240px wide)
- Grid of owned brainrots with filter bar (All/Common/Rare/etc) + search
- Equip/unequip on click

### 11. Trade (1240px wide)
- Split view: Your slots / Their slots
- Ready up system, accept trade

### 12. Additional Panels
- **Codes**: Input field + redeem button + redeemed list
- **Map Vote**: 3 map cards, vote buttons, countdown
- **Daily Rewards**: 7-day grid, claim button
- **Lucky Wheel**: Spin wheel with segments, spin button
- **Season Pass**: Tier track with free/premium lanes
- **Starter Pack**: Promotional popup
- **Purchase Confirmation**: Modal with item preview + confirm/cancel
- **Event Results**: Post-event summary with rewards

### 13. Mobile Layouts
- Reorganized HUD for portrait mobile
- Collapsed hotbar, repositioned stat bars
- See `Mobile Layouts.dc.html` for reference

## Design Tokens

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| Panel BG | #171B26 | Main panel backgrounds |
| Card BG | #1D2230 | Cards, sections inside panels |
| Dark BG | #0D1017 | Page/world background |
| Border | #2A3044 | Card and panel borders |
| Border Light | #333C55 | Secondary borders, dividers |
| Text Primary | #FFFFFF | Titles, important text |
| Text Secondary | #C6CDDD | Body text, descriptions |
| Text Muted | #9AA3B8 | Subtitles, hints |
| Text Dim | #5E6880 | Disabled, footnotes |
| Green Primary | #63B91F | Buy buttons, cash, success |
| Green Light | #7FD435 / #8CDC3E | Gradient tops, accents |
| Green Dark | #2E5E10 | Button borders, shadows |
| Cash Text | #B4F470 | Money/cash amounts |
| Blue Primary | #2F7BD6 | XP, info, Index |
| Blue Light | #4E9BEC | Gradient tops |
| Blue Dark | #16457E | Button borders |
| Purple Primary | #8B34D6 | Rebirth, Luck |
| Purple Light | #B564F2 | Gradient tops |
| Red Primary | #D5341F | Close buttons, danger |
| Red Light | #F2543E | Gradient tops |
| Red Dark | #6E140C | Button borders |
| Gold Primary | #DD9615 | Quests, premium, Upgrades |
| Gold Light | #F0B93A | Gradient tops |
| Gold Dark | #7A4E08 | Button borders |
| Orange Primary | #D96420 | Events |
| Orange Light | #F2843E | Gradient tops |
| Gem Cyan | #5AD6A0 | Gem currency |

### Typography
| Element | Font | Size | Weight | Extras |
|---------|------|------|--------|--------|
| Panel Title | Lilita One | 30px | 400 (inherent) | 2.5px stroke outline, letter-spacing 1.2px |
| Section Title | System | 19px | 900 | letter-spacing 1.2px |
| Body | System | 13-14px | 800 | — |
| Small/Label | System | 11.5-12px | 800-900 | letter-spacing 0.3-0.5px |
| Button Text | System | 13-15px | 900 | text-shadow 0 1.5px |

### Spacing
- Panel padding: 16-20px
- Card padding: 14-20px
- Gap between cards: 10-16px
- Border radius: Panels 14px, Cards 12px, Buttons 8-10px, Small chips 6-7px

### Button Pattern (Chunky Roblox Style)
```
Background: linear-gradient(180deg, lightColor, baseColor)
Border: 1.5px solid darkColor
Border-bottom-width: 4px (creates 3D depth)
Border-radius: 9-10px
Box-shadow: inset 0 1.5px 0 rgba(255,255,255,.3) (top highlight)
Text-shadow: 0 1.5px 0 darkColor
Hover: filter brightness(1.08-1.1)
Active: translateY(2px), border-bottom-width back to 1.5px (button "press")
```

### Icons
All icons are inline SVGs built from a helper function. The icon set includes: basket, refresh, book, scroll, gear, shield, star, bolt, blob, crown, monitor, speaker, gamepad, info, coin, bill, gem, crate, clover, search, spinner, xp, qmark, heart, person, bag, gift, trophy, lock, check, robux, swap, ticket, map. Each takes a color and size parameter. In Roblox, replace with ImageLabels using equivalent icon assets.

## Interactions & Behavior
- **Panel switching**: Only one panel open at a time. Clicking a HUD button toggles its panel (or closes if already open).
- **Tab switching**: Within panels (Shop, Settings, Quests), tabs swap visible content.
- **Button press**: translateY(2px) + flatten bottom border = "push down" effect. In Roblox use TweenService to animate Position + Size.
- **Hover**: brightness increase. In Roblox, use MouseEnter/MouseLeave to tween BackgroundColor3.
- **Toast notifications**: Appear top-right, auto-dismiss after ~4s. Slide in with animation.
- **Purchase confirmation**: Modal overlay (72% opacity black bg) with centered dialog.
- **Settings**: Draft/saved state pattern — edits are drafts until "Save All" is clicked. Unsaved changes modal on close.
- **Sell**: Shows value preview BEFORE confirming. Three options: sell equipped, sell inventory, or cancel.
- **Upgrades**: Each upgrade shows current level, progress bar (level/50), and scaling price. Buy button triggers level-up toast.

## State Management
- `panel`: string | null — which panel is open
- `shopTab`: 'featured' | 'boosts' | 'brainrots' | 'gamepasses'
- `settingsTab`: 'general' | 'graphics' | 'audio' | 'controls' | 'about'
- `questTab`: 'daily' | 'weekly'
- `purchase`: object | null — current purchase confirmation dialog
- `draft` / `saved`: settings state objects for dirty-checking
- `toasts`: array of active notifications
- `invFilter` / `invSearch`: inventory filtering
- `yourReady`: trade ready state
- `codeInput` / `redeemed`: code redemption

## Files
- `Game UI System v3.dc.html` — Main UI with all panels (desktop)
- `Mobile Layouts.dc.html` — Mobile-optimized HUD layout
- `Design System Sheet.dc.html` — Component reference sheet
- `GameUI.client.lua` — Earlier Luau script attempt (partial, use as reference only)

## Prompt for Claude Code

Copy and paste this into Claude Code along with the zip:

---

I have a complete game UI system designed in HTML. I need you to recreate it 1:1 in Roblox Studio using the Roblox MCP.

**Read the README.md first** for the full design spec, then reference the HTML files for exact layouts.

**Build these as Roblox ScreenGuis:**
1. Main HUD (always visible): health/hunger/stamina bars, level/XP, cash/gems, hotbar (9 slots + equipped), minimap, panel buttons
2. Shop (4 tabs: Featured, Boosts, Brainrots, Gamepasses)
3. Upgrades (Carry Capacity, Speed, Luck — each with level, progress bar, buy button)
4. Sell (value preview + Sell Equipped / Sell Inventory / Never mind)
5. Rebirth
6. Index/Collection
7. Quests (Daily/Weekly tabs)
8. Settings (General/Graphics/Audio/Controls/About tabs with toggles, sliders, selects)
9. Events (card grid with status/timers)
10. Inventory (filterable grid)
11. Trade (split view with ready-up)
12. Codes, Map Vote, Daily Rewards, Lucky Wheel, Season Pass
13. Purchase confirmation modal, Toast notifications

**Key Roblox implementation notes:**
- Use `UICorner` for border-radius, `UIListLayout`/`UIGridLayout` for flex/grid, `UIPadding` for padding, `UIStroke` for borders
- Chunky button effect: use `UIStroke` + offset Position tween on click (2px down, reduce visible "depth")
- Gradients: `UIGradient` with matching Color3 keypoints
- Font: Use GothamBold/GothamBlack as system font; for panel titles use a bold display font or TextLabel with rich text
- Icons: Use ImageLabels with icon asset IDs (I'll provide or you can use placeholder decals)
- Panel switching: one LocalScript managing Visible property on each panel Frame
- All colors are provided as hex in the README — convert to Color3.fromHex()

Match the dark theme (#171B26 backgrounds, #1D2230 cards, #2A3044 borders) and the chunky gradient button style throughout. Every panel should feel consistent.

---
