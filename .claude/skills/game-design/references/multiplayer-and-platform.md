# Multiplayer, Monetization, Testing, and Platform Design

## Table of Contents
- [Multiplayer Design](#multiplayer-design)
- [Monetization Ethics](#monetization-ethics)
- [Testing and Iteration](#testing-and-iteration)
- [Platform Considerations](#platform-considerations)

---

## Multiplayer Design

### Netcode

**Server-authoritative architecture** is the only acceptable approach for competitive multiplayer. The server is the source of truth; the client predicts and the server corrects.

**Key concepts:**
- **Client prediction:** The client simulates player actions locally for responsiveness. The server validates and corrects if needed.
- **Rollback netcode:** On receiving authoritative state, the client rolls back to the corrected state and replays inputs from that point. The gold standard for fighting games and fast-paced action. Guilty Gear Strive made rollback the expected standard.
- **Delay-based netcode:** Add input delay to synchronize players. Simpler but feels sluggish at higher latencies. Acceptable for turn-based games.
- **Tick rate:** How often the server updates game state. 64 tick minimum for competitive shooters (CS2 uses 64). 20-30 acceptable for slower games.
- **Interpolation and extrapolation:** Smooth out visual positions between server updates. Interpolation (rendering slightly in the past) is more reliable than extrapolation (predicting ahead).

**DO:**
- Display connection quality to the player (ping, packet loss indicator).
- Design for 100-200ms latency as the baseline experience. It must feel acceptable, not just functional.
- For fighting games, use rollback. Players will not accept delay-based in the modern era.

**DON'T:**
- Trust the client for anything gameplay-critical. Health, damage, position validation -- all server-side.
- Ignore packet loss. Design for degraded network conditions, not just ideal ones.

### Matchmaking

**DO:**
- Use skill-based matchmaking (SBMM) with a rating system (Elo, Glicko-2, or TrueSkill).
- Prioritize match quality over queue time for competitive modes. Players prefer waiting 60 seconds for a fair match over instant stomps.
- Place new players in a protected bracket for the first 5-10 matches until the system calibrates.
- Show the player an indication of their skill bracket (rank, tier, division).

**DON'T:**
- Match solely on connection quality. Fast but unfair matches frustrate more than slow fair ones.
- Use hidden SBMM in casual modes without transparency. The community will discover it, and secrecy breeds conspiracy theories.
- Force solo players against premade groups without adjusting ratings.

### Toxicity Management

Toxic behavior costs the industry an estimated $29 billion in annual revenue through player churn.

**DO:**
- Implement reporting with follow-up ("A player you reported has been actioned"). Riot Games found this increases reporting and community trust.
- Use positive reinforcement: honor systems, commendation rewards, "good teammate" badges. Riot's honor system reduced repeat offenses.
- Apply graduated punishments: warning, chat restriction, temporary ban, permanent ban. Timely nudges after first offense reduce reoffending below 10%.
- Provide robust mute/block tools that are easy to access (1-2 clicks from the scoreboard).

**DON'T:**
- Ignore toxicity as "just part of gaming." It directly causes player loss.
- Apply only punitive measures without positive alternatives. Punishment alone does not teach better behavior.

### Cooperative Design

**DO:**
- Design challenges that require cooperation, not just parallel play. Left 4 Dead's Special Infected require team coordination to counter.
- Use "AI Director" patterns: scale difficulty to player count and skill. Drop-in/drop-out should not break the experience.
- Communicate shared objectives clearly. Every player should know what the team needs to accomplish.
- Make revive/rescue mechanics forgiving. If a single player dying fails the team, the weakest player determines the ceiling, which is frustrating.

### Asymmetric Multiplayer

- **Information asymmetry (Among Us):** One side knows something the other does not. Design for both the informed and uninformed experience to be fun.
- **Role asymmetry (Dead by Daylight):** Different roles have fundamentally different gameplay. Both must be fun and neither should feel helpless.
- **Power asymmetry (L4D Versus):** One side is individually weaker but numerous. Balance team power budgets, not individual power.

---

## Monetization Ethics

### Fair Free-to-Play

**Gold standard references:** Path of Exile (cosmetic-only), Warframe (everything earnable, premium is convenience/cosmetic).

**DO:**
- Sell cosmetics, not power. Skins, emotes, visual effects that have zero gameplay impact.
- Allow all gameplay content to be earned through play. Premium currency should be a shortcut, not a gate.
- Be transparent about what money buys. No hidden costs, no bait-and-switch.
- Provide good value at the lowest price tier. A player spending $5 should feel respected.

**DON'T:**
- Sell gameplay advantages (pay-to-win). Star Wars Battlefront II (2017) is the definitive cautionary tale: loot boxes with gameplay advantages triggered regulatory action, EA's response became the most downvoted Reddit comment in history, and Disney intervened directly.
- Use manipulated pricing (odd currency amounts that always leave leftover premium currency).
- Exploit loss aversion or FOMO aggressively (limited-time offers with countdown timers, expiring content).

### Battle Passes

**DO:**
- Make the pass completable with reasonable play time (~1 hour/day should be enough).
- Show exactly what the pass contains and what the player will get.
- Include a free track with meaningful rewards alongside the premium track.
- Carry forward XP or provide catch-up mechanics for players who start late.

**DON'T:**
- Require excessive daily play to complete. This turns entertainment into obligation.
- Fill the pass with filler items. Every tier should feel like a reward, not padding.
- Make the premium track mandatory for gameplay content.

### Regional Pricing

- Over 60% of game revenue now comes from outside North America and Western Europe.
- Use Steam's recommended regional pricing as a baseline.
- Test purchasing power parity for your target markets.
- Overpricing in developing markets does not increase revenue -- it increases piracy.

---

## Testing and Iteration

### Playtesting Methodology

**The golden rules:**
1. Watch silently. Do not guide, hint, or explain. Where the player struggles is data.
2. Use the "Think Aloud" method: ask the player to verbalize their thought process while playing.
3. Test with players who match your target audience, not other developers.
4. Test early and often: paper prototypes, greybox levels, vertical slices. Do not wait for polish.
5. Record sessions (with consent). You will miss things in real-time observation.

**Frequency:**
- Weekly playtests during active development with 3-5 testers per session.
- Monthly larger sessions (10-20 testers) for broader feedback.
- Test every major milestone with fresh players who have never seen the game.

### Metrics That Matter

| Metric | What It Tells You | Red Flag |
|--------|-------------------|----------|
| D1 Retention | First impression quality | Below 40% |
| D7 Retention | Early game depth | Below 15% |
| Session length | Engagement per visit | Below 5 minutes consistently |
| Stickiness (DAU/MAU) | Return frequency | Below 20% |
| Funnel completion | Where players drop off | >50% drop at any single step |
| Heatmaps (death/quit locations) | Pain points in levels | Cluster of deaths/quits at one spot |
| Time to first reward | Onboarding speed | Over 5 minutes |

### A/B Testing

**When to A/B test:**
- UI layouts, tutorial flows, reward amounts, difficulty tuning.
- Objective, measurable outcomes (retention, conversion, completion rate).

**When NOT to A/B test:**
- Core creative vision. Art direction, narrative choices, and mechanical identity should not be decided by A/B metrics.
- Small sample sizes. Below ~1,000 users per variant, results are noise.

### Minimum Viable Product (MVP)

The MVP for a game is: **the smallest playable thing that proves the core mechanic is fun.**

- A platformer MVP is: one character, one level, tight controls, no menus.
- An RPG MVP is: one combat encounter with the core battle system.
- A puzzle game MVP is: 5-10 puzzles demonstrating the core rule.

If the MVP is not fun, more content will not fix it. Pivot or polish the core until it works.

### Kill Your Darlings

Use the MoSCoW method for feature prioritization:
- **Must have:** Core loop, essential UI, save/load.
- **Should have:** Polish, secondary systems, settings menus.
- **Could have:** Extra content, achievements, leaderboards.
- **Won't have (this release):** Everything else.

70%+ of indie developers cite scope as a primary failure factor. Cut early and often.

### Early Access

- Only 20% of Early Access games perform better at 1.0 launch than at EA launch.
- Median EA duration is 437 days. Plan for this.
- Set clear expectations: what is in, what is coming, what the timeline looks like.
- Treat EA players as partners, not beta testers. Communicate regularly.

---

## Platform Considerations

### Session Length Design by Platform

| Platform | Expected Session | Design For |
|----------|-----------------|------------|
| Mobile | 2-10 minutes | 3-5 minute complete loops. Auto-save constantly. Resume instantly. |
| PC | 30 min - 3 hours | 15-20 minute core loops. Regular save points. Alt-tab friendly. |
| Console | 1-4+ hours | 20-30 minute loops. Quick resume support. Couch-readable UI. |
| Handheld/Switch | 10-60 minutes | Dual-mode: quick loops + extended play. Sleep/suspend support. |

### Touch Controls

**DO:**
- Place interactive elements in thumb zones (bottom 40% of screen for portrait, bottom-left and bottom-right for landscape).
- Minimum touch target size: 44x44pt (Apple HIG), 48x48dp (Material Design).
- Use gestures that feel natural: tap to select, swipe to move, pinch to zoom. Do not invent novel gestures without teaching them.
- Provide visual feedback on every touch (ripple, highlight, slight scale).

**DON'T:**
- Place critical UI near screen edges (notch, system gesture areas).
- Require precise input (small buttons, narrow tap targets).
- Use virtual joysticks as the primary control method if a better alternative exists (tap-to-move, swipe-to-aim).

### Controller vs Keyboard+Mouse

| Feature | Controller | KB+M |
|---------|-----------|------|
| Aiming | Aim assist required | Precise, no assist needed |
| Navigation | D-pad lists, bumper tabs | Mouse click, scroll |
| Input count | ~16 buttons | 100+ keys + mouse |
| Comfort | Relaxed, lean back | Precise, lean forward |
| Haptics | Vibration + triggers | None (usually) |

**Aim assist for controllers:**
- Bullet magnetism (slight auto-correction toward targets).
- Reticle slowdown (reduced sensitivity when crosshair is near a target).
- Aim acceleration (slow at small stick deflection, fast at large).
- All must be tunable in settings. Provide sensitivity curves (linear, exponential).

**DO:**
- Support input-based matchmaking in competitive multiplayer (KB+M vs KB+M, controller vs controller).
- Design UI that works for both: navigable by D-pad and clickable by mouse.
- Allow simultaneous input (controller movement + mouse aim).

### Cross-Platform Play

- Cross-save is increasingly expected. Players want to continue on a different device.
- Use input-based matchmaking, not platform-based, for competitive fairness.
- Design UI that scales: what is readable on a 6-inch phone must also work on a 65-inch TV.
- Test on minimum-spec hardware for each platform, not just your development machine.

### Screen Sizes and Aspect Ratios

- Design for 16:9 as the primary target. Support 16:10, 21:9, and 32:9 ultrawide by expanding the viewport (show more, do not stretch).
- Use DPI-independent UI scaling. A button should be the same physical size on a 1080p 24" monitor and a 4K 27" monitor.
- Phone notches and punch-holes: use safe area insets. Never place interactive UI under a notch.
- Console on TV: keep all critical UI within the 90% title-safe area. Provide a UI margin/safe area slider.
- Text must be readable from the expected viewing distance: 10pt on a phone at arm's length, 26px+ at 1080p on a TV from 8 feet.
