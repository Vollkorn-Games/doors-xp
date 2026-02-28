# Game Feel, Polish, and Visual Design

## Table of Contents
- [Juice Philosophy](#juice-philosophy)
- [Screen Shake](#screen-shake)
- [Hit Stop and Impact](#hit-stop-and-impact)
- [Animation Principles for Games](#animation-principles-for-games)
- [Camera Design](#camera-design)
- [Particle Systems and VFX](#particle-systems-and-vfx)
- [Visual Clarity](#visual-clarity)
- [Polish Checklist](#polish-checklist)
- [Performance and Optimization](#performance-and-optimization)

---

## Juice Philosophy

"Juice" is excessive positive feedback for minimal player input. The gap between a "functional" game and one that "feels amazing" is almost entirely juice. Vlambeer's Nuclear Throne and Jan Willem Nijman's GDC talks are the definitive references.

**The Juice Stack for any impact event:**
1. Screen shake (directional, decaying)
2. Hit stop / freeze frame (2-6 frames)
3. Particle burst (sparks, debris, dust)
4. Sound effect (layered, pitch-varied)
5. Flash / color change on hit target (1-2 frames white flash)
6. Camera zoom pulse (subtle, 2-5%)
7. Knockback / recoil animation

Layering 5-7 of these multiplies perceived impact. Any single one alone feels thin.

**Critical rule:** Juice must reinforce the game's tone. A cozy farming game needs soft, satisfying plops and sparkles. A horror game needs wet crunches and screen distortion. Match juice to fantasy.

---

## Screen Shake

### Implementation

Use a trauma-based system:
```
offset = trauma^exponent * max_offset * noise(time)
```

- `trauma`: 0.0 to 1.0, decays over time
- `exponent`: 2-3 (makes small trauma subtle, large trauma dramatic)
- `max_offset`: maximum pixel displacement
- `noise`: Perlin or OpenSimplex (never random -- random looks jittery, noise looks organic)

### Parameters by Impact Level

| Impact | Trauma | Duration | Max Offset |
|--------|--------|----------|------------|
| Light (footstep, small hit) | 0.1-0.2 | 0.1-0.15s | 2-4px |
| Medium (explosion, heavy hit) | 0.3-0.5 | 0.2-0.3s | 6-10px |
| Heavy (boss slam, death) | 0.6-0.8 | 0.3-0.5s | 12-20px |

**DO:**
- Make shake directional -- push the camera in the direction of the impact source.
- Apply exponential decay so shake dissipates naturally.
- Always provide a screen shake intensity slider (0-100%) in accessibility settings.

**DON'T:**
- Use random displacement. Use Perlin noise.
- Apply screen shake to everything. If every action shakes, nothing feels impactful.
- Exceed 0.5s duration for most effects. Long shakes cause nausea.

---

## Hit Stop and Impact

Hit stop (freeze frames) is 2-6 frames where gameplay pauses on a significant hit to sell weight and impact.

### Frame Guidelines

| Impact | Freeze Duration | When to Use |
|--------|----------------|-------------|
| Light | 1-2 frames | Quick jabs, minor collisions |
| Medium | 3-4 frames | Sword slashes, charged attacks |
| Heavy | 5-8 frames | Finishing blows, parries, boss hits |

**Complementary techniques:**
- **Impact flash:** Target flashes white for 1-2 frames on hit.
- **Squash and stretch:** Compress the target sprite on impact frame, then stretch on recoil. 10-20% deformation is usually enough.
- **Knockback:** Push the target away from the hit direction. Scale distance with damage.
- **Slow-motion:** 0.1-0.3 second time-scale reduction (50-75%) for cinematic moments (final kill, parry). Use very sparingly.

**DO:**
- Scale hit stop duration with hit significance.
- Combine hit stop + flash + particles + sound for maximum impact.
- Reference: Monster Hunter (heavy weapon impacts), Hades (dash-strike), Hollow Knight (nail strikes).

**DON'T:**
- Apply hit stop to projectiles or rapid-fire weapons (it interrupts flow).
- Freeze longer than 8 frames outside of special cinematic moments.

---

## Animation Principles for Games

The 12 Disney principles apply, but games add critical constraints:

### Key Game-Specific Rules

1. **Anticipation must be short for player actions (1-3 frames) but generous for enemy telegraphs (10-30+ frames).** Player actions must feel responsive. Enemy attacks must be readable.
2. **Follow-through can be interrupted.** If a player inputs a new action during follow-through, cancel into the new action. Responsive > realistic.
3. **Ease in/out on everything.** Linear motion looks robotic. Apply acceleration curves to movement, UI transitions, camera motion.
4. **Squash and stretch is subtle in games.** 5-15% deformation for characters. More for cartoony styles, less for realistic.

### Animation Canceling

Two philosophies:
- **Animation Priority (Dark Souls):** Commit to attacks. Recovery frames are punishable. Creates deliberate, weighty combat.
- **Cancellable Offense (Devil May Cry):** Cancel animations into new actions freely. Creates fluid, expressive combat.

Choose based on your game's identity. Animation priority = deliberate/tactical. Cancellable = fast/expressive. Do not mix inconsistently -- players learn the system's rules and expect consistency.

### Input Buffering in Animation

Buffer the next input during the current animation's recovery frames (last 3-10 frames). This way, a player pressing attack slightly before the current attack ends will seamlessly chain into the next attack. Without buffering, players feel like the game is "eating" their inputs.

---

## Camera Design

### Camera Types

| Type | Best For | Key Parameters |
|------|----------|----------------|
| Fixed | Horror, puzzle, narrative | Frame composition, transition triggers |
| Follow/Lerp | Platformer, top-down | Dead zone size, damping (3-10 for responsive) |
| Orbit | 3D action, exploration | Distance, pitch limits, collision |
| Look-ahead | Fast platformers | Velocity-based offset, prediction distance |

### Follow Camera Best Practices

- **Dead zone:** A rectangular region around the player where the camera does not move. Player must exit this zone to move the camera. Prevents jitter during small movements. Size: 10-20% of viewport for platformers.
- **Damping/smoothing:** Lerp toward target. Higher values (5-10) = snappy. Lower values (1-3) = cinematic float. Match to game speed.
- **Look-ahead:** Offset camera in the direction the player is moving or facing. Gives more screen space ahead. Essential for fast-paced platformers.
- **Boundaries:** Clamp camera to level bounds so it never shows empty space beyond the level.

### Cinematic Camera Moments

- **Zoom pulse:** Brief 2-5% zoom on significant events (boss entrance, item discovery). Lerp in fast, out slow.
- **Slow-motion + zoom:** For kill cams or critical moments. 50% time scale + 10% zoom for 0.5-1.0 seconds.
- **Camera lead:** During boss entrances or reveals, briefly take camera control to frame the reveal, then smoothly return to gameplay camera.

---

## Particle Systems and VFX

### Impact Effects (4 components)

1. **Flash:** Bright sprite at impact point, 1-2 frames, fades immediately.
2. **Burst:** 5-15 small particles exploding outward from impact. Randomize direction within a cone.
3. **Debris:** 2-5 larger fragments with physics (gravity, bounce). Material-appropriate: sparks for metal, splinters for wood, dust for stone.
4. **Ring/shockwave:** Expanding circle from impact. Good for ground pounds, explosions. Scale = significance.

### Trail Effects

- **Motion trails:** Stretched sprites or line renderers following moving objects. Good for swords, projectiles, dashes.
- **Ghosting:** Semi-transparent copies of the character at previous positions. Good for dash abilities (Celeste, Hollow Knight).
- **Persistent trails:** Particle emitters attached to moving objects (fire trails, sparkle paths).

### Ambient Particles

- Keep 10-30 on screen at any time for atmosphere (dust motes, rain, floating embers).
- Set opacity to 10-30% -- ambient particles should not compete with gameplay particles.
- Use slow, randomized movement. Fast-moving ambient particles create visual noise.

### Performance Rules

- **Overdraw is the #1 particle performance killer.** Large transparent particles overlapping = GPU bottleneck. Keep particle sizes small and counts reasonable.
- **Budget per game type:** Mobile: 50-100 active particles. PC/Console: 200-500. AAA: 1000+.
- **Object pool particles.** Never instantiate/destroy per emission. Reuse from a pool.
- **LOD particles:** Reduce count and disable ambient particles at distance.

### When Less Is More

Add maximum juice for a feature, then remove elements one at a time. If removing an element does not noticeably reduce impact, leave it removed. Most juice effects survive with 60-70% of initial components.

---

## Visual Clarity

### Visual Hierarchy (Priority Order)

1. Player character / currently selected unit
2. Active threats / enemies in attack animation
3. Interactive objects / pickups
4. Allied units / NPCs
5. Environmental hazards (static)
6. Decorative foreground elements
7. Background

Every layer should be visually distinguishable from adjacent layers through contrast, saturation, detail level, or parallax.

### Silhouette Readability

If you desaturate and blur your game to a silhouette, every important gameplay element should still be identifiable by shape alone. Team Fortress 2 is the gold standard: every class is instantly recognizable by silhouette.

### Foreground/Background Separation

- Desaturate and reduce detail on non-interactive background layers.
- Use parallax to create depth separation.
- Keep gameplay elements at full saturation and sharpness.
- Add a subtle dark or light edge/outline to gameplay elements if background is visually busy.

### Enemy Attack Telegraphing

Use multiple channels simultaneously:

1. **Animation wind-up:** Exaggerated anticipation pose (10-30 frames depending on attack weight).
2. **Color/flash warning:** Red glow, pulsing outline, or highlighted attack zone.
3. **Audio cue:** Distinct sound before the attack lands.
4. **Ground indicator:** For area attacks, show the danger zone on the ground before the attack fills it.
5. **Timing rhythm:** Establish consistent telegraph-to-hit timing so players can learn the pattern.

Light attacks: 10-15 frame telegraph. Medium: 15-25 frames. Heavy/boss: 25-45+ frames.

### Visual Noise Management

- Limit simultaneous VFX sources. In dense combat, reduce ambient particles and secondary effects.
- Use screen-space limits: if a particle effect would exceed 30% of the visible screen, cap it.
- Ensure the player character is always the most readable element. Never lose the player in effects.

---

## Polish Checklist

### What Separates Amateur from Professional

| Area | Amateur | Professional |
|------|---------|-------------|
| Actions | Silent, static | Sound + particles + shake |
| Menus | Instant transitions | Eased transitions, hover states, sounds |
| Movement | Linear, snaps | Acceleration curves, momentum |
| Hits | Health bar changes | Flash + shake + stop + particles + sound |
| Cameras | Rigid follow | Smooth lerp, look-ahead, boundaries |
| UI | Raw text, no hierarchy | Clear hierarchy, consistent spacing, icons |
| Death/Fail | Instant reset | Death animation, brief pause, then reset |
| Pickups | Disappear on touch | Magnetize toward player, collect sound, +1 pop |
| Loading | Blank screen | Loading indicator, tip text, or mini-game |
| Audio | Placeholder or silent | Layered, pitch-varied, mixed by priority |

### The 80/20 of Polish (Estimated Impact)

1. Sound effects on all actions (25% of perceived polish)
2. Input responsiveness: buffering + coyote time + tight controls (20%)
3. UI transitions and feedback sounds (15%)
4. Screen shake + hit stop on combat/impacts (15%)
5. Particle effects on actions (10%)
6. Camera smoothing and boundaries (10%)
7. Animation easing and squash/stretch (5%)

Sound and input responsiveness alone account for ~45% of perceived polish.

---

## Performance and Optimization

### Frame Rate Targets

| Platform | Minimum | Target | Notes |
|----------|---------|--------|-------|
| PC | 30fps | 60fps | 120/144fps for competitive |
| Console | 30fps | 60fps | Performance/Quality modes |
| Mobile | 30fps | 60fps | Battery-conscious option for 30fps |
| VR | 72fps | 90fps | Below 72fps causes nausea |

### Frame Budget at 60fps (16.67ms total)

- Gameplay logic: <4ms
- Physics: <2ms
- Rendering: <8ms
- Audio: <1ms
- Headroom: ~1.5ms

### Input Lag Pipeline

Typical total: 40-100ms
- Input polling: 1-4ms
- Game logic processing: 1-16ms (depends on when in frame)
- Render pipeline: 16-33ms (1-2 frames)
- Display processing: 5-20ms

**Minimize by:** Polling input as late as possible in the frame, reducing render queue depth, supporting high refresh rates.

### Key Optimization Techniques

- **Object pooling:** Pre-allocate bullets, particles, enemies. Never instantiate/destroy in gameplay loops.
- **Async loading:** Load next area in background while player is in a corridor/elevator/cutscene. Never show a loading screen if avoidable.
- **LOD:** Reduce mesh detail, texture resolution, shader complexity, animation update rate, and particle count at distance.
- **Culling:** Don't render or update what's not on screen. Frustum culling for 3D, viewport bounds for 2D.
- **Spatial partitioning:** Quadtrees (2D) or octrees (3D) for collision and neighbor queries. Never check all-vs-all.

### Optimization Workflow

1. Profile first. Never optimize by guessing.
2. Identify the actual bottleneck (CPU, GPU, memory, I/O).
3. Fix the largest bottleneck.
4. Re-profile to confirm improvement.
5. Repeat until target frame rate is stable.
6. Test on minimum-spec hardware.
