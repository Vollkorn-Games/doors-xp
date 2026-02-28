# Narrative Design and Level Design

## Table of Contents
- [Narrative Design](#narrative-design)
- [World Building](#world-building)
- [Level Design](#level-design)

---

## Narrative Design

### Environmental Storytelling

The most powerful game narratives are discovered, not told. Environmental storytelling encodes story into the world itself.

**DO:**
- Tell stories through placement and composition. A skeleton slumped against a wall, reaching toward a locked door, tells a story without words. BioShock's Rapture tells its collapse through crumbling architecture, scattered propaganda, and audio diaries.
- Use the "show, don't tell" principle ruthlessly. Journey communicates its entire narrative through visual language: murals, environmental scale, and the mountain always visible in the distance.
- Layer narrative for different engagement levels: surface story (what's happening now) for casual players, deep lore (item descriptions, environmental details) for invested players. Dark Souls excels at this -- you can complete the game understanding almost nothing, or spend hundreds of hours piecing together lore.
- Let the player discover narrative at their own pace. Never force lore on a player who just wants to play.

**DON'T:**
- Dump exposition through dialogue. If a character explains what the player can see, the environmental storytelling has failed.
- Force the player to stop moving to receive story. Walking-and-talking, environmental discovery, and gameplay-integrated narrative respect the player's time.
- Create ludonarrative dissonance: narrative and gameplay contradicting each other. Nathan Drake is characterized as a likeable everyman while the player kills 700 people. Uncharted 4 even made an achievement called "Ludonarrative Dissonance" for killing 1,000 enemies, acknowledging the problem.

### Ludonarrative Harmony

The gold standard: gameplay mechanics reinforce and express the narrative theme.

- **Celeste:** The core mechanic (difficult precision platforming with generous assists) mirrors the narrative theme (struggling with anxiety while accepting help).
- **Hades:** The roguelike structure (dying and returning) is the story itself (Zagreus literally cannot escape death).
- **Papers, Please:** The core loop (stamp passports under time pressure) creates the moral dilemmas the narrative explores.
- **Outer Wilds:** The time loop mechanic is both the gameplay structure and the narrative mystery.

Design mechanics that express your theme. If your game is about loss, make the player lose something mechanically meaningful, not just narratively.

### Branching Narratives

**DO:**
- Make choices meaningful with visible, delayed consequences. The Witcher 3's Bloody Baron questline: early decisions affect outcomes hours later, and there is no "good" ending -- every outcome has trade-offs.
- Let the player express character through choices, not just pick between good/evil. Disco Elysium's dialogue system lets the player be a hundred shades of weird, not just saint or monster.
- Telegraph that a choice matters without revealing what will happen. A musical sting, a pause, a character looking at the player -- signal weight without spoiling outcome.

**DON'T:**
- Present false choices where all options lead to the same outcome. Players learn to distrust choice systems that do not deliver.
- Use binary good/evil morality. Real decisions are between competing goods or competing evils.
- Show dialogue option text that misrepresents what the character will say. Fallout 4's truncated dialogue options ("Sarcastic" leading to an unexpected response) is the most cited failure.

### Dialogue Systems

- Show the full player response (or a faithful summary) before selection. No surprises.
- Allow players to skip dialogue they have seen before (especially in roguelikes or replayed sections).
- Provide dialogue logs so players can review what was said.
- Voice-acted dialogue should match subtitle text exactly. Mismatches break trust.

### Emergent Narratives

Some of the most memorable game stories are player-created:

- **Dwarf Fortress / RimWorld:** Procedural events + complex systems = unique stories every playthrough.
- **XCOM:** Permadeath + character naming = players create attachment and narrative from emergent events.

**DO:**
- Design systems with enough complexity and randomness to generate surprising outcomes.
- Give players tools to name, customize, and personalize entities they interact with.
- Let failure states be interesting, not just "game over." A colony collapse in RimWorld is a story.

---

## World Building

### Consistent Internal Logic

**DO:**
- Establish rules and follow them. Breath of the Wild: anything wooden burns, anything metallic conducts electricity, anything round rolls downhill. The player learns the world's physics and trusts them.
- Make the world's economy and ecology visible. Red Dead Redemption 2: towns have visible industry, trade routes, and social structure. NPCs have schedules and routines.
- If the player can interact with a system, it should behave predictably. Inconsistency ("this door opens but that identical door doesn't") breaks immersion.

**DON'T:**
- Break your own rules for convenience. If fire burns wood, it must always burn wood. Exceptions require clear in-world justification.
- Include set-dressing that implies interactivity but is not interactive. A prominent lever that does nothing is worse than no lever at all.

### Lore Delivery

Layer lore through multiple optional channels:

1. **Environmental (passive):** Architecture, graffiti, wear patterns, vegetation.
2. **Collectible (active):** Audio logs, journal entries, item descriptions. The player seeks these out.
3. **NPC dialogue (interactive):** Characters share knowledge when asked. Do not force.
4. **Mechanical (experiential):** The player learns world rules by interacting with them. Metroid Prime's scan visor lets players choose their lore depth.

No single channel should carry the entire narrative weight. Players who skip collectibles should still understand the core story. Players who seek everything should be rewarded with depth.

### Sense of Place

**DO:**
- Make each area feel distinct through a combination of visual palette, audio, enemy types, and mechanics. Hollow Knight: every biome has unique color, music, enemy behavior, and environmental hazards.
- Use sound and music to establish mood before the player sees anything. The audio of an area should communicate its character within seconds.
- Create "memorable moments" tied to specific locations. A vista, a discovery, an encounter that the player remembers and associates with that place.

**DON'T:**
- Copy-paste environments. If two areas feel the same, one of them should not exist.
- Rely solely on visual variety. An area that looks different but plays identically to the last is variety theater, not genuine diversity.

---

## Level Design

### Flow and Pacing

Levels should follow a tension/release rhythm:

```
Challenge -> Challenge -> PEAK -> Relief -> Reward -> Challenge -> ...
```

- **Challenge sections:** Active gameplay (combat, puzzles, platforming).
- **Peak moments:** The hardest encounter or most dramatic beat in a sequence.
- **Relief sections:** Safe spaces for exploration, story, resource management.
- **Reward moments:** Loot, upgrades, narrative reveals, vistas.

No section should persist too long. 2-3 challenge encounters, then a beat of relief. Resident Evil's mansion paces horror with safe rooms and item management.

### Guiding Player Attention

Players naturally look toward:

1. **Light:** Bright areas draw the eye over dark areas. Use lighting to lead the player forward.
2. **Contrast:** A single colored element against a monochrome background. Mirror's Edge uses red objects against white/grey cityscapes.
3. **Motion:** Moving objects attract attention. Flags, swaying plants, particle effects at important locations.
4. **Lines:** Architecture, pathways, and environmental geometry that converge on a point. Leading lines toward the objective.
5. **Sound:** Audio sources pull attention. A distant sound can guide the player toward an unseen objective.
6. **The "Weenie" (Disney concept):** A large, visible landmark that acts as a constant reference point and navigation target. Breath of the Wild's towers and Elden Ring's Erdtree serve this purpose.

**DO:**
- Use multiple guidance channels simultaneously (light + path + sound). Redundancy prevents players from getting lost.
- Make the critical path the most visually interesting path. Players follow novelty.
- Reward exploration of non-critical paths with collectibles, lore, or shortcuts so curiosity is reinforced.

**DON'T:**
- Use explicit UI markers (floating arrows, minimap waypoints) as a substitute for good level design. Use them as a supplement, not a crutch.
- Create dead ends without rewards. If a player goes the "wrong way," they should find something.
- Make the correct path ambiguous in action sequences. During high-tension moments, the path forward should be unmistakable.

### Gating and Progression

**Lock-and-key design:** The player encounters a barrier, acquires an ability/key elsewhere, then returns to pass the barrier.

- **Metroidvania gating (Hollow Knight, Metroid):** New abilities open previously inaccessible areas. The player remembers blocked paths and returns with anticipation.
- **Dark Souls shortcut model:** Progress opens shortcuts back to safe areas. Creates a network that rewards exploration and provides "aha!" moments of connection.
- **Zelda key-item model:** Each dungeon introduces a key item that enables new interactions within that dungeon and the overworld.

**DO:**
- Make it clear when a barrier requires a future ability vs. is currently solvable. Hollow Knight uses distinct visual language for different gate types.
- Reward backtracking. If you make the player return to an old area, ensure there is something new there.

**DON'T:**
- Gate progress behind obscure or unintuitive requirements. If the player cannot reasonably deduce what they need, the gate is a wall.
- Require excessive backtracking without fast travel. If backtracking takes more than 2-3 minutes with no new content, provide a shortcut.

### Combat Arena Design

**DO:**
- Shape arenas to create gameplay variety. Pillars for cover, height for tactical advantage, chokepoints for control, open areas for dodging. Doom Eternal's arenas are carefully sculpted to support its mobility-focused combat.
- Place enemies to create interesting tactical problems. Mix ranged and melee enemies, vary threat levels, create spatial pressure.
- Provide readable boundaries. The player should know the fight space without running into invisible walls.
- Use arena shape to telegraph boss phases. A circular arena suggests a mobile boss. A corridor suggests a charge attack.

### Verticality

Vertical level design adds depth (literal and figurative):

- **Overlapping paths** that the player traverses at different times create "aha!" moments (Dark Souls 1's interconnected world).
- **Height reveals:** Reaching a high point and seeing previously explored areas from above creates a sense of mastery. Breath of the Wild's Great Plateau reveal.
- **Risk/reward layers:** High ground is advantageous but exposed. Low ground is hidden but vulnerable.
