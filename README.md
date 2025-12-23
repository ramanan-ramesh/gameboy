# gameboy

Introducing "gameboy" – the app that makes you feel like a genius one day and question your life choices the next! 😅 Whether you're cracking Wordsy codes, flexing your vocabulary in BeeWise, or showing off random trivia knowledge, gameboy keeps your neurons firing and your ego in check. Perfect for those who think they're smart… until they misspell "yacht."

## A Flutter-Powered Playground for Word Wizards

Looking for a game that puts your brain to work while showcasing the magic of Flutter? Meet WordPlay, the ultimate collection of daily word challenges that adapts beautifully to screens of all shapes and sizes.

- **AlphaBound**: Ever wondered what word fits perfectly between apple and zebra in a sorted dictionary? No? Well, now's your chance to find out in this addictive guessing game.
- **Wordsy**: The timeless classic reimagined in Flutter. Guess the word of the day — one letter at a time, with suspense and strategy.
- **BeeWise**: Armed with just seven letters, unleash your inner wordsmith and craft as many words as you can. Your score? It's not just a number; it's your bragging right!
- **LexBox**: Connect words chain-style using all 12 letters arranged in a box. Each word must start with the last letter of the previous word!

From adaptive layouts to delightful animations, WordPlay isn't just fun — it's a tribute to Flutter's power and versatility. Dive in, flex those neurons, and let the letters fly!

---

## 🏗️ Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ GameLayout  │  │ StatsSheet  │  │TutorialSheet │  │  Widgets     │  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                │                │                  │          │
│         └────────────────┴────────────────┴──────────────────┘          │
│                                   │                                     │
│                         BlocListener / BlocBuilder                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            BLOC LAYER                                   │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │           GameBloc<TEvent, TState, TStats, TEngine>                │ │
│  │  ┌────────────────────────────────────────────────────────────┐    │ │
│  │  │ • Receives UI events (SubmitWord, EraseWord, etc.)         │    │ │
│  │  │ • Orchestrates GameEngine and StatsRepo calls              │    │ │
│  │  │ • Emits states for UI to react to                          │    │ │
│  │  │ • Handles game lifecycle (loading, playing, won/lost)      │    │ │
│  │  └────────────────────────────────────────────────────────────┘    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│   AlphaBoundBloc    WordsyBloc    BeeWiseBloc    LexBoxBloc            │
└─────────────────────────────────────────────────────────────────────────┘
                          │                  │
            ┌─────────────┘                  └─────────────┐
            ▼                                              ▼
┌───────────────────────────────────┐    ┌───────────────────────────────────┐
│          GAME ENGINE              │    │           STATS REPO              │
│ ─────────────────────────────────│    │ ─────────────────────────────────│
│ 📋 RESPONSIBILITIES:             │    │ 📋 RESPONSIBILITIES:              │
│ • Pure game logic                │    │ • Persistence (Firebase)          │
│ • Rule validation                │    │ • Analytics recording             │
│ • Win/loss detection             │    │ • Session management              │
│ • State machine                  │    │ • Streak calculation              │
│                                  │    │                                   │
│ ❌ NOT RESPONSIBLE FOR:          │    │ ❌ NOT RESPONSIBLE FOR:           │
│ • Persistence                    │    │ • Game logic                      │
│ • Network calls                  │    │ • Win/loss detection              │
│ • Analytics                      │    │ • Rule validation                 │
└───────────────────────────────────┘    └───────────────────────────────────┘
```

---

### Layered Architecture Detail

```
┌──────────────────────────────────────────────────────────────────┐
│                         lib/                                     │
├──────────────────────────────────────────────────────────────────┤
│  presentation/                                                   │
│  ├── app/                    # Shared app-wide UI components     │
│  │   ├── pages/                                                  │
│  │   │   ├── game_content_page/  # Generic game container        │
│  │   │   ├── games_list_view/    # Game selection screen         │
│  │   │   └── master_page/        # App shell with navigation     │
│  │   └── widgets/                # Reusable widgets              │
│  ├── alphaBound/             # AlphaBound-specific UI            │
│  ├── beeWise/                # BeeWise-specific UI               │
│  ├── lexBox/                 # LexBox-specific UI                │
│  └── wordsy/                 # Wordsy-specific UI                │
├──────────────────────────────────────────────────────────────────┤
│  blocs/                                                          │
│  ├── game/                   # Base GameBloc abstraction         │
│  │   ├── bloc.dart           # Generic game bloc base class      │
│  │   ├── events.dart         # Common events (RequestStats, etc) │
│  │   ├── states.dart         # Common states (GameLoaded, etc)   │
│  │   └── game_data.dart      # Game configuration container      │
│  ├── alphaBound/             # AlphaBound bloc implementation    │
│  ├── beeWise/                # BeeWise bloc implementation       │
│  ├── lexBox/                 # LexBox bloc implementation        │
│  └── wordsy/                 # Wordsy bloc implementation        │
├──────────────────────────────────────────────────────────────────┤
│  data/                                                           │
│  ├── app/                    # Shared data abstractions          │
│  │   ├── models/                                                 │
│  │   │   ├── game_engine.dart    # Base GameEngine interface     │
│  │   │   └── stats.dart          # Base Statistics interface     │
│  │   └── extensions.dart                                         │
│  ├── alphaBound/                                                 │
│  │   ├── models/             # Interfaces & data models          │
│  │   └── implementation/     # Concrete implementations          │
│  ├── beeWise/                                                    │
│  ├── lexBox/                                                     │
│  └── wordsy/                                                     │
└──────────────────────────────────────────────────────────────────┘
```

---

### Game Lifecycle Flow

```
    ┌──────────────────────────────────────────────────────────────┐
    │                    GAME STARTUP FLOW                         │
    └──────────────────────────────────────────────────────────────┘
    
    User selects game
           │
           ▼
    ┌──────────────┐
    │ GameBloc     │───▶ emit(GameLoading)
    │ created      │
    └──────┬───────┘
           │
           ▼
    ┌──────────────────┐
    │ statisticsCreator│───▶ Load user data from Firebase
    └──────┬───────────┘
           │
           ▼
    ┌──────────────────┐
    │ stats.reCalculate│───▶ Check if new day, reset streaks if needed
    └──────┬───────────┘
           │
           ▼
    ┌──────────────────┐
    │ gameEngineCreator│───▶ Initialize engine with persisted state
    └──────┬───────────┘
           │
           ▼
    ┌──────────────────────┐
    │ emit(GameLoaded)     │───▶ UI shows game content
    └──────┬───────────────┘
           │
           ▼
    ┌──────────────────────────┐
    │ getGameStateOnStartup()  │───▶ Check if already won/lost today
    └──────┬───────────────────┘
           │
           ▼
    ┌──────────────────────────┐
    │ emit(WinOnStartup) ?     │───▶ Show celebration if applicable
    └──────────────────────────┘
```

---

### User Action Flow (LexBox Example)

```
    ┌──────────────────────────────────────────────────────────────┐
    │                   SUBMIT WORD FLOW                           │
    └──────────────────────────────────────────────────────────────┘

    User types word and presses Enter
           │
           ▼
    ┌────────────────────────┐
    │  Bloc receives         │
    │  SubmitWord event      │
    └──────────┬─────────────┘
               │
               ▼
    ┌────────────────────────┐       ┌─────────────────────┐
    │ gameEngine             │──────▶│ Validate word       │
    │ .trySubmitWord(word)   │       │ • In dictionary?    │
    └──────────┬─────────────┘       │ • Valid chain?      │
               │                     │ • Uses box letters? │
               │                     └─────────────────────┘
               ▼
    ┌─────────────────────────────┐
    │ Word Valid?                 │
    └──────────┬──────────────────┘
               │
       ┌───────┴───────┐
       │               │
      YES              NO
       │               │
       ▼               ▼
    ┌────────────┐  ┌─────────────────┐
    │ stats      │  │ emit(           │
    │ .recordWord│  │  InvalidWord)   │
    └─────┬──────┘  └─────────────────┘
          │
          ▼
    ┌─────────────────────────────┐
    │ Did this word cause a WIN?  │
    │ (gameEngine.isWon == true   │
    │  && wasWonBefore == false)  │
    └──────────┬──────────────────┘
               │
       ┌───────┴───────┐
       │               │
      YES              NO
       │               │
       ▼               ▼
    ┌────────────┐  ┌─────────────────┐
    │ stats      │  │ emit(           │
    │ .registerWin│ │  WordAccepted)  │
    └─────┬──────┘  └─────────────────┘
          │
          ▼
    ┌─────────────────┐
    │ emit(           │
    │  GameWon)       │
    └─────────────────┘
```

---

### Single Responsibility Principle (SRP) Compliance

```
┌─────────────────────────────────────────────────────────────────┐
│                    RESPONSIBILITY MATRIX                        │
├─────────────────────────────────────────────────────────────────┤
│ Responsibility              │ GameEngine │ StatsRepo │  Bloc   │
├─────────────────────────────┼────────────┼───────────┼─────────┤
│ Word validation             │     ✅     │    ❌     │   ❌    │
│ Win/loss detection          │     ✅     │    ❌     │   ❌    │
│ Game rules enforcement      │     ✅     │    ❌     │   ❌    │
│ State transitions           │     ✅     │    ❌     │   ❌    │
├─────────────────────────────┼────────────┼───────────┼─────────┤
│ Firebase persistence        │     ❌     │    ✅     │   ❌    │
│ Streak calculation          │     ❌     │    ✅     │   ❌    │
│ Win/loss recording          │     ❌     │    ✅     │   ❌    │
│ Analytics tracking          │     ❌     │    ✅     │   ❌    │
│ Session management          │     ❌     │    ✅     │   ❌    │
├─────────────────────────────┼────────────┼───────────┼─────────┤
│ UI event handling           │     ❌     │    ❌     │   ✅    │
│ State emission              │     ❌     │    ❌     │   ✅    │
│ Orchestration               │     ❌     │    ❌     │   ✅    │
│ Lifecycle management        │     ❌     │    ❌     │   ✅    │
└─────────────────────────────┴────────────┴───────────┴─────────┘
```

---

### Game Comparison

| Feature | AlphaBound | Wordsy | BeeWise | LexBox |
|---------|------------|--------|---------|--------|
| Daily Challenge | ✅ | ✅ | ✅ | ✅ |
| Win Condition | Guess word | Guess word | Score-based | Use all letters |
| Loss Condition | Max guesses | Max guesses | None | None |
| Erase Support | ❌ | ❌ | ❌ | ✅ |
| Streak Tracking | ✅ | ✅ | ❌ | ✅ |
| Win Count | ✅ | ✅ | ❌ | ✅ |

---

### Adding a New Game

To add a new game, follow this pattern:

1. **Create data models** in `lib/data/<game_name>/models/`
   - `game_engine.dart` - Interface extending `GameEngine`
   - `stats.dart` - Interface extending `Statistics`

2. **Implement data layer** in `lib/data/<game_name>/implementation/`
   - `game_engine.dart` - Concrete game logic
   - `stats.dart` - Firebase persistence

3. **Create bloc** in `lib/blocs/<game_name>/`
   - `bloc.dart` - Extend `GameBloc<TEvent, TState, TStats, TEngine>`
   - `events.dart` - Game-specific events
   - `states.dart` - Game-specific states

4. **Build UI** in `lib/presentation/<game_name>/`
   - Implement `GameLayout` interface
   - Create game-specific widgets

5. **Register game** in `GameData` configuration

---

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Interface segregation** | Separate read-only (`Statistics`) from write (`StatsModifier`) |
| **Generic base bloc** | Type-safe while allowing game-specific behavior |
| **Engine ≠ Stats** | Clear separation enables testing and single responsibility |
| **Factory constructors** | Async initialization with `create()` pattern |
| **Win detection in Engine** | Stats doesn't know game rules, just records events |
