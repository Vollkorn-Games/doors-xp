# Game UI/UX Design

## Table of Contents
- [HUD Design](#hud-design)
- [Menu Design](#menu-design)
- [Feedback Systems](#feedback-systems)
- [Readability](#readability)
- [Onboarding and Tutorials](#onboarding-and-tutorials)
- [Input Design](#input-design)
- [Accessibility](#accessibility)

---

## HUD Design

### Information Hierarchy

Show only what the player needs right now. Critical data (health, ammo, threats) at screen edges; secondary info (minimap, quests) less prominent or contextual.

**DO:**
- Use adaptive/contextual HUDs. Elden Ring hides HUD outside combat, reveals health/stamina when enemies appear.
- Let players customize HUD density (Full/Compact/Minimal/Off). The Witcher 3 allows toggling individual elements.
- Reinforce critical states through multiple channels: low health = red screen vignette + audio warning + character animation, not just a shrinking bar.
- Keep persistent HUD elements under 15-20% of screen space.

**DON'T:**
- Display everything at once. Cluttered HUDs overwhelm and bury critical information.
- Put critical info only in one location with no redundancy.
- Obscure gameplay with UI. The center of the screen is where gameplay happens.

### Diegetic vs Non-Diegetic UI

| Type | Description | Example |
|------|-------------|---------|
| **Diegetic** | Exists in game world, characters see it | Dead Space spine health bar |
| **Non-Diegetic** | Overlay only player sees | Traditional health bars |
| **Spatial** | In game world but characters cannot see it | Enemy health bars above heads |
| **Meta** | Affects rendered image, not a discrete element | Screen going red when damaged |

- Use diegetic UI when immersion is a core design pillar (horror, survival).
- Use non-diegetic UI for competitive or fast-paced games where instant readability matters.
- Combine approaches freely. Metro Exodus: diegetic wrist compass + non-diegetic crosshair.

---

## Menu Design

### Navigation Patterns

**DO:**
- Design console-first, then adapt. Gamepad navigation (D-pad lists, bumper tabs) translates well to keyboard and mouse.
- Use tabbed categories with L1/R1 switching between settings groups (Gameplay, Audio, Video, Controls, Accessibility). This is a universal convention.
- Provide a "back" action on every screen. B/Circle always goes back.
- Allow settings changes from the pause menu. Never require quitting to main menu for volume or sensitivity.

**DON'T:**
- Bury frequently-used settings. Audio volume, subtitles, and sensitivity within 1-2 clicks of settings root.
- Require restart for non-essential settings changes. If unavoidable, warn before confirming.

### Settings Menu Checklist (Minimum)

**Audio:** Master, Music, SFX, Dialogue volume sliders. Voice Chat volume for multiplayer.

**Video/Display:** Resolution, Display Mode (Fullscreen/Windowed/Borderless), Brightness, VSync, Frame Rate Cap, FOV slider (first-person games).

**Controls:** Sensitivity (X and Y separate), Invert Y toggle, full key/button remapping, dead zone adjustment, vibration toggle + intensity.

**Accessibility:** Subtitles (on/off, size, background opacity, speaker colors), colorblind mode (Protanopia/Deuteranopia/Tritanopia with strength slider), text size scaling, screen shake intensity/toggle, high contrast mode, motion sickness options (camera bob, motion blur).

**Gameplay:** Difficulty selection (changeable mid-game), auto-save frequency, tutorial/hint toggles.

---

## Feedback Systems

### Visual Feedback

**DO:**
- Use hit markers to confirm damage. Overwatch's crosshair tick on hit (different for headshots/kills) provides instant unambiguous confirmation. Players must never wonder "did that hit?"
- Scale feedback to significance. Light attack = small flash. Critical hit = large damage numbers + bigger flash + screen shake. Borderlands uses font size, color, and exclamation marks.
- Implement hit stop (frame freeze) for impactful attacks. Monster Hunter and Hades freeze 2-4 frames on heavy hits. Duration scales with significance.
- Use particles purposefully. Dust on landing, sparks on parry, debris on hit. Hollow Knight's slash effects are exemplary.

**DON'T:**
- Let damage numbers obscure gameplay. Offer threshold filtering and toggle-off options.
- Apply uniform screen shake to everything. If everything shakes, nothing feels impactful. Reserve strong shake for significant events.

### Audio Feedback

**DO:**
- Give every meaningful action a distinct sound. Jumping, landing, attacking, picking up items, menu hover -- silence feels broken.
- Layer by significance. Menu hover = soft tick. Purchase = satisfying cha-ching. Critical hit = meaty crunch with rising pitch.
- Use pitch variation (plus/minus 5-15%) on frequent sounds (footsteps, gunfire) to prevent repetitive fatigue.
- Create distinct audio for critical state changes. Low health needs a warning sound.

**DON'T:**
- Let UI sounds overpower gameplay audio.
- Play reward sounds for routine actions. Save fanfares for real achievements.

### Haptic Feedback

- Use DualSense as the gold standard reference for what's possible (location-specific, intensity variation, texture simulation).
- Implement adaptive trigger resistance for bows, guns, brakes where applicable.
- Always make haptics optional with an intensity slider (0-100%) and full disable toggle.
- Haptics must reinforce visual and audio feedback, never replace them.

---

## Readability

### Font Size Guidelines

| Platform | Minimum | Recommended | Scaling Range |
|----------|---------|-------------|---------------|
| Console (TV at 8ft) | 26px at 1080p | 28-32px at 1080p | Up to 200% |
| PC (Monitor at 2ft) | 16px at 1080p | 18-20px at 1080p | Up to 200% |
| Mobile (Handheld) | 11pt (~15px) | 14-16pt | Pinch/slider |
| Subtitles | 46px at 1080p | 46-56px | S/M/L/XL |

**DO:**
- Use mixed-case text. Mixed case is 13% faster to read than all-caps.
- Include at least one sans-serif font option if your game uses stylistic fonts.
- Allow text scaling up to 200% without loss of content (Microsoft XAG requirement).
- Test readability at worst-case viewing distance for your target platform.

**DON'T:**
- Use thin or light font weights for gameplay-critical text.
- Use font sizes below 26px at 1080p for console.
- Rely on all-caps for emphasis. Use bold, size, or color instead.

### Contrast and Color

- Target minimum 4.5:1 contrast ratio for body text (WCAG AA). 3:1 for large text (18pt+).
- Place text on solid or semi-opaque background panels over dynamic scenes. White text on a snowy landscape is unreadable.
- Offer a high-contrast mode. God of War Ragnarok assigns bright color filters to enemies, allies, interactables, and hazards.

### Colorblind Design

8% of men have color vision deficiency. This is not niche.

**DO:**
- Never use color as the sole differentiator. Pair with shape, pattern, icon, or text label.
- Offer per-type presets (Protanopia, Deuteranopia, Tritanopia) with strength slider.
- Change specific UI element colors rather than applying a whole-screen filter. Battlefield 4 approach over global filters.

**DON'T:**
- Rely on red vs green for friend vs foe. Use blue vs orange, or add shape differentiation.

---

## Onboarding and Tutorials

### Teaching Through Play

**DO:**
- Study Super Mario Bros World 1-1. First Goomba teaches jumping without a word. First pit has a safe bottom. Coins create positive reinforcement that leads to discovering the Mushroom.
- Use Portal's approach for complex mechanics: each test chamber isolates one concept, then combines with previous concepts.
- Design "teaching spaces" where failure is cheap. Celeste's early screens have short falls and nearby respawns.
- Use environmental signposting: arrows, lighting, color-coded surfaces, NPC gaze direction, camera framing. Breath of the Wild lights a distant tower and puts it on a hill.

**DON'T:**
- Front-load tutorials before gameplay. If your tutorial takes >60 seconds before meaningful agency, it is too long.
- Use unskippable text dumps for control explanations. Let the player perform each action immediately after being told.
- Teach mechanics the player will not use for another hour. Teach when relevant.

### Progressive Disclosure

- Introduce one mechanic at a time, let players practice, then introduce the next.
- Gate advanced systems behind natural progression. Don't show the skill tree at level 1.
- Show control prompts at the moment of relevance, fade after 3-5 seconds, do not repeat if the player has demonstrated understanding.
- Implement a "stuck" detector: if a player spends >60-90 seconds without progress, offer an optional hint (dismissable, not modal).

---

## Input Design

### Core Principles

**DO:**
- Respect platform conventions. Xbox: A=confirm, B=back. PlayStation: Cross=confirm, Circle=back. Support full key/button remapping.
- Buffer inputs for 3-5 frames (50-83ms). If a player presses jump 3 frames before landing, the jump executes on the first valid frame.
- Implement coyote time: 3-6 frame (50-100ms) grace period after leaving a ledge where jumping is still valid. Celeste uses 5 frames. This is non-negotiable for any game with platforming.
- Dynamically swap button prompts when input method changes. Show Xbox glyphs for Xbox controllers, PlayStation for DualSense. Add a 200-300ms delay before switching to prevent flicker.
- Provide dead zone sliders. Default 15-20% to handle stick drift on aging controllers. Use radial dead zones, not axial.
- Support simultaneous input methods (controller for movement + mouse for aiming).

**DON'T:**
- Hardcode any bindings. Every input must be remappable, including pause.
- Use "hold to confirm" for frequent actions. Reserve for rare high-consequence actions (drop item, quit).
- Make coyote time too generous (>150ms) in precision platformers -- it becomes noticeable and floaty.
- Skip forgiveness mechanics because the game is "supposed to be hard." Celeste is brutally hard and uses every forgiveness system listed above.

---

## Accessibility

This is not optional. 15-20% of the global population has some form of disability. The Last of Us Part II shipped with 60+ accessibility options. God of War Ragnarok shipped with 70+.

### Non-Negotiable Minimum (Ship with these)

1. Subtitles on by default with a background, at 46px+ on console
2. Remappable controls -- every input, no exceptions
3. Separate volume sliders for Master, Music, SFX, Dialogue
4. Colorblind mode with symbol/shape redundancy (not just a filter)
5. Text size scaling up to 200%
6. Difficulty changeable mid-game
7. Screen shake toggle/slider
8. Input buffering and coyote time for platforming
9. Dynamic input prompts matching active controller
10. Pause anywhere (single-player)

### Subtitles and Captions

- Enable by default or prompt on first launch.
- Offer customization: size (S/M/L/XL), background opacity (0-100%), speaker identification (colors or names).
- Limit to 2 lines max, 40 chars per line, paced at 160-180 WPM.
- Distinguish subtitles (dialogue) from closed captions (sound effects: "[glass shattering]", "[ominous music]").

### Difficulty Options

- Allow difficulty change at any time during gameplay. Never lock players in.
- Offer granular components, not just a single slider. The Last of Us Part II: independent Player Damage, Enemy Aggression, Ally Effectiveness, Stealth Detection, Resource Scarcity.
- Celeste Assist Mode model: game speed (50-100%), extra dashes, invincibility -- all independent toggles. Achievements remain available. No shaming.

**DON'T:**
- Shame players for easier settings. No skull icons, no "are you sure?" on Easy, no disabled achievements.
- Make "Normal" the only well-tuned difficulty.

### Additional Accessibility

- **Motion sickness:** Toggle camera bobbing, disable motion blur, reduce/disable screen shake, provide static reference point.
- **Photosensitivity:** Reduce/disable screen flash effects.
- **Cognitive:** Auto-save frequently, provide quest reminders, allow game speed reduction, use consistent iconography.
- **One-handed:** Provide one-handed control presets. Minimize simultaneous button requirements or offer press-to-toggle alternatives.
- **Screen reader:** Implement menu narration. Label all interactive UI elements. Ask on first launch if the player wants screen reader support.
