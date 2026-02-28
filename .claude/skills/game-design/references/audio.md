# Game Audio Design

## Table of Contents
- [Sound Effect Design](#sound-effect-design)
- [Audio Mixing Priorities](#audio-mixing-priorities)
- [Adaptive Music Systems](#adaptive-music-systems)
- [Positional Audio](#positional-audio)
- [Silence as Design](#silence-as-design)

---

## Sound Effect Design

### Layering

Every significant sound effect should be built from 2-4 layers:

| Layer | Purpose | Example (Sword Hit) |
|-------|---------|-------------------|
| Impact | Core hit feel | Sharp metallic clang |
| Body | Weight and substance | Low thud or crunch |
| Sweetener | Character and tone | High ring or sizzle |
| Tail | Spatial context | Brief reverb or echo |

A single-layer sound feels flat. Two layers feel functional. Three-four layers feel professional.

### Variation Techniques

Repetition is the enemy of immersion. For any sound that plays frequently:

- **Pitch jitter:** Randomize pitch +/- 5-10% on each play. Prevents robotic repetition.
- **Sample pooling:** Record 3-5 variations of the same sound. Randomly select on each play. Never play the same variation twice consecutively.
- **Volume jitter:** +/- 1-3 dB per play for natural variation.
- **Combine all three** for high-frequency sounds like footsteps, gunfire, and UI interactions.

### Sound Design by Action Type

| Action | Key Quality | Reference |
|--------|------------|-----------|
| Menu hover/select | Crisp, minimal, consistent | Any Nintendo game |
| Item pickup | Satisfying, brief, positive | Zelda item jingle |
| Attack/hit | Punchy, layered, scaled to damage | Hades weapon strikes |
| Jump/land | Contextual to surface, weight-appropriate | Celeste |
| Death/fail | Distinct, not punishing, brief | Hollow Knight shade death |
| Achievement/unlock | Celebratory, musical, memorable | Xbox achievement sound |
| Low health warning | Urgent but not annoying, pulsing | Zelda low-heart beep (carefully -- too aggressive is annoying) |
| Environmental | Ambient, looping, seamless, low in mix | Rain, wind, fire crackle |

**DO:**
- Give every meaningful player action a sound. Silence feels broken.
- Make distinct sounds for distinct events. If pickup and damage sound similar, the player loses information.
- Create an iconic sound for your most important feedback moment (Overwatch's headshot "dink", Mario's coin).

**DON'T:**
- Use placeholder sounds in playtests -- they create wrong associations that persist.
- Play reward sounds for routine actions. If every pickup gets a fanfare, the fanfare loses meaning.
- Let any single sound play more than ~4 times per second without heavy variation.

---

## Audio Mixing Priorities

### Priority Tiers (Highest to Lowest)

| Priority | Category | Relative Volume |
|----------|----------|----------------|
| 1 | Player action feedback (attacks, jumps) | 100% |
| 2 | Critical alerts (low health, incoming danger) | 90-95% |
| 3 | Dialogue and narration | 85-90% |
| 4 | Enemy and NPC actions | 70-80% |
| 5 | Ambient environment | 40-60% |
| 6 | Music | 30-50% (ducked during dialogue) |

### Ducking

When a higher-priority sound plays, temporarily reduce lower-priority channels:

- **Dialogue plays:** Duck music to 30-40%, ambient to 50-60%. Restore over 0.5-1.0s after dialogue ends.
- **Explosion/major event:** Duck everything except the explosion for 0.1-0.3s, then restore.
- **Menu open:** Duck gameplay audio to 30-50%, or mute entirely depending on tone.

### Volume Slider Best Practices

- Provide separate sliders: Master, Music, SFX, Dialogue, Voice Chat.
- Use logarithmic scaling, not linear. Human hearing is logarithmic -- a linear slider makes the bottom 30% nearly inaudible and the top 30% barely different.
- Default Master to 80%, not 100%. Leaves headroom for the player's system volume.
- Allow sliders to go to 0 (true mute). Never set minimum at 1%.

---

## Adaptive Music Systems

### Vertical Layering (Intensity-based)

Stack instrument layers that fade in/out based on game state:

```
State: Exploration (calm)
  Layer 1: Ambient pad (always playing)
  
State: Tension (enemy nearby)
  Layer 1: Ambient pad
  Layer 2: Rhythmic percussion
  
State: Combat (engaged)
  Layer 1: Ambient pad
  Layer 2: Rhythmic percussion
  Layer 3: Melodic lead
  Layer 4: Bass line
  
State: Boss (high stakes)
  All layers + additional choir/brass intensity layer
```

All layers are recorded in the same key, tempo, and time signature. They are synchronized and play simultaneously, with individual volume/mute control per layer.

### Horizontal Resequencing (Section-based)

Compose music in interchangeable sections that can be rearranged based on gameplay:

```
Intro (4 bars) -> Loop A (8 bars) -> [gameplay continues] -> Loop A or Loop B
                                      [combat starts] -> Combat Intro (2 bars) -> Combat Loop
                                      [combat ends] -> Outro (4 bars) -> Exploration Loop
```

Transitions happen at musical boundaries (bar lines, phrase endings) to avoid jarring cuts.

### Transition Rules

- **Never hard-cut music** unless it is intentionally dramatic (sudden silence on a jump scare).
- Crossfade over 1-4 beats (tempo-synced) for smooth transitions.
- Use a "stinger" (short musical phrase) to bridge significantly different sections.
- If the player's state changes rapidly (in and out of combat), add a cooldown (3-5 seconds) before transitioning music to avoid whiplash.

### Practical Advice for Small Teams

If a full adaptive system is too complex:
- At minimum, have separate exploration and combat tracks with crossfade transitions.
- Use a single looping track with a filter (low-pass during calm, full spectrum during intensity) as a lightweight alternative.
- Compose in a key and tempo that allows clean loops. Test the loop point meticulously -- a bad loop seam is worse than no music.

---

## Positional Audio

### 2D Games

- Pan sounds left/right based on the source's horizontal position relative to the camera/listener.
- Attenuate by distance: sounds further from the player are quieter. Use inverse distance or linear falloff.
- Off-screen sounds should still be audible (attenuated) to provide spatial awareness. An enemy approaching from the right should be heard before it is seen.

### 3D Games

- Use the engine's built-in spatial audio system (Godot AudioStreamPlayer3D, Unity AudioSource 3D, Unreal Sound Attenuation).
- Set appropriate min/max distance per sound type:
  - Footsteps: 1-10m
  - Gunfire: 5-50m
  - Explosions: 10-100m
  - Ambient sources: 2-20m
- Use HRTF (Head-Related Transfer Function) if the engine supports it for headphone users. Provides vertical positioning.
- Occlude sounds behind walls and obstacles. Even simple volume reduction + low-pass filter for occluded sounds adds immersion.

---

## Silence as Design

Silence is one of the most powerful audio tools. Constant sound creates fatigue and removes contrast.

**When to use silence:**
- **Before a jump scare or reveal:** Cut all sound for 0.5-2 seconds before the shock. The contrast makes the shock far more intense. Dead Space does this masterfully.
- **After a boss defeat or major story beat:** Let the weight of the moment breathe. Fade all sound for 2-5 seconds before the victory music.
- **In safe spaces:** If the game is intense, provide moments of near-silence (ambient only, no music, no threats) so the player can decompress. Hollow Knight's bench resting areas.
- **During narrative weight:** When a character dies or a critical choice is made, pulling the music creates emotional gravity.

**DON'T:**
- Have music playing 100% of the time. Music without silence loses its emotional power.
- Fill every quiet moment with ambient noise. Some spaces should feel genuinely still.
- Use silence accidentally. Every moment of silence should be intentional. Unintentional silence (a missing sound) feels like a bug.
