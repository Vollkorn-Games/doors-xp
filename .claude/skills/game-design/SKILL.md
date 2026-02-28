---
name: game-design
description: Comprehensive game design principles and best practices skill. Covers UI/UX, game feel/juice/polish, core loops, player motivation, progression, difficulty, balancing, retention, narrative, level design, audio, visual clarity, accessibility, multiplayer, monetization, and platform considerations. Use when designing game systems, implementing gameplay features, creating UI/menus, adding game feel/juice, designing levels, planning progression systems, evaluating difficulty, improving player onboarding, making games accessible, or reviewing any game design decision. Triggers on any game design, gameplay implementation, or player experience task.
---

# Game Design Principles

## Design Thinking Phase

Before implementing any game system, answer these questions:

1. **What is the core fantasy?** What does the player want to feel? (powerful, clever, fast, creative, scared)
2. **What is the core loop?** Action -> Feedback -> Reward -> Decision -> Action. If you cannot state it in one sentence, simplify.
3. **Who is the player?** Casual/hardcore, session length expectations, platform, input method.
4. **What makes this distinct?** One unique mechanic executed well beats five generic ones.

## Universal Principles

1. **Player agency is sacred** - Every moment the player is not making a meaningful choice is a moment they could quit. Minimize cutscenes, automate tedium, maximize decisions.
2. **Juice everything** - Every player action needs feedback: visual, audio, haptic. No silent, static responses. The gap between "functional" and "feels amazing" is sound effects, screen shake, and particles.
3. **Teach through play** - If you wrote a text tutorial, delete it. Design a space where the mechanic teaches itself. Super Mario World 1-1 taught an entire generation without a single word.
4. **Difficulty should be fair, not easy** - Players accept death when they understand why they died. Celeste is brutally hard and universally loved because the controls are perfect and respawns are instant.
5. **Respect the player's time** - Every grind, unskippable animation, and forced wait is a trust withdrawal. Make progression feel earned, not time-gated.
6. **Accessible by default** - Remappable controls, subtitles, colorblind support, and scalable UI are not features -- they are baseline requirements. 15-20% of players have a disability.
7. **Ship the core, not the scope** - A polished 2-hour game beats a janky 20-hour one. Cut features ruthlessly. If the core loop is not fun by hour one, more content will not fix it.
8. **Playtest relentlessly** - Your intuition is wrong. Watch real players silently. Where they hesitate, struggle, or quit tells you more than any design document.

## Reference Files

Consult these based on the task at hand:

- **HUD design, menus, feedback systems, readability, onboarding, input design, accessibility** - See [references/ui-ux.md](references/ui-ux.md)
- **Screen shake, hit stop, animation, camera, particles, polish checklist, performance** - See [references/game-feel.md](references/game-feel.md)
- **Sound layering, adaptive music, mixing priorities, positional audio, silence as design** - See [references/audio.md](references/audio.md)
- **Core loops, player motivation, progression, rewards, difficulty, attention span, balancing, retention** - See [references/mechanics-and-loops.md](references/mechanics-and-loops.md)
- **Environmental storytelling, level design flow, guiding attention, combat arenas, verticality** - See [references/narrative-and-levels.md](references/narrative-and-levels.md)
- **Multiplayer netcode, matchmaking, monetization ethics, playtesting, platform differences** - See [references/multiplayer-and-platform.md](references/multiplayer-and-platform.md)

## Quick Decision Framework

When implementing a game feature, run through this checklist:

- Does this action have visual + audio feedback?
- Can a new player understand this without reading text?
- Does this respect the player's time?
- Is this accessible (remappable, readable, colorblind-safe)?
- Does this serve the core loop or distract from it?
- Have I seen a real player try this?

If any answer is "no," address it before moving on.
