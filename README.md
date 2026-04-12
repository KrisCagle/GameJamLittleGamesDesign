# GameJamLittleGamesDesign

Game jam prototype built in **Godot 4** for the theme: **Invincibility**.

The player does not directly control heroes.  
Instead, you control a single transferable **Halo** (invincibility) and make fast triage decisions under pressure.

## Pillars

1. **Switching Invincibility**
   - Only one hero can have the Halo at a time.
   - Switching is instant (`1`, `2`, `3`, or click a hero).

2. **Pressure System**
   - Multiple enemies threaten different heroes at once.
   - Waves escalate in density and speed.
   - You cannot save everyone perfectly in later waves.

3. **Light Synergy (No Combo Overload)**
   - Knight benefits as a control frontliner.
   - Mage benefits with burst damage.
   - Rogue benefits with mobility and clutch cleanup.

## Current Gameplay Loop

1. Enemies spawn and spread threat across heroes.
2. Player switches Halo to prevent critical deaths.
3. Heroes auto-act by role while player manages risk.
4. Wave pressure escalates.
5. Survive, then repeat on the next harder wave.

## Last Stand Mode

When only one hero remains, the Halo becomes unstable:

- Halo builds **heat** while active.
- At higher heat it can **flicker**.
- At max heat it **overloads** (temporary no-invincibility window).
- Player can manually **vent** by toggling Halo off/on (same hero key or click).

This keeps the endgame tense instead of becoming unwinnable or endless.

## Controls

- `1` = Send Halo to Knight
- `2` = Send Halo to Mage
- `3` = Send Halo to Rogue
- `Left Click` = Send Halo to nearest clicked hero
- `R` or `Enter` = Restart after wipe

## Hero Roles

- **Knight**: tanky, short-range, frontline pressure and pull utility when Haloed.
- **Mage**: fragile, ranged, high burst while Haloed.
- **Rogue**: fast responder, helps stabilize dangerous situations and clutch picks.

## Enemy Types

- **Swarm**: constant close-range pressure.
- **Ranged**: spacing pressure, punishes bad positioning.
- **Charger**: burst threat windows.

## Run Locally

1. Open this folder in Godot 4.
2. Run the project (main scene is `scenes/Main.tscn`).

## Project Structure

- `project.godot` - Godot project config
- `scenes/Main.tscn` - Main arena scene
- `scripts/Main.gd` - Core loop, waves, halo switching, last stand
- `scripts/Hero.gd` - Hero behaviors and role logic
- `scripts/Enemy.gd` - Enemy AI and attack behavior

## Jam Notes

- This is a gameplay-first prototype with simple placeholder visuals.
- Balance values are intentionally easy to tune in scripts during playtests.
