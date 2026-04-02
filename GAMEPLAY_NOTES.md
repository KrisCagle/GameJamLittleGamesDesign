# GameJamLittleGamesDesign Notes

Godot 4 prototype for the jam theme **invincibility**.

## Current Vertical Slice

- 3 auto-acting heroes: Knight, Mage, Rogue
- One transferable Halo (invincibility) at a time
- Instant switching with `1`, `2`, `3`, or left-click on a hero
- Last Stand mode when only one hero lives:
  - Halo gains heat, flickers, and can overload
  - Tap the current hero key/click to vent the Halo and cool it (at risk)
- Wave-based enemy pressure with Swarm, Ranged, and Charger enemies
- Escalating wave difficulty and mixed targeting pressure
- Light synergy only:
  - Knight + Halo: periodic pull pulse and stronger front-line control
  - Mage + Halo: high burst damage
  - Rogue + Halo: higher mobility and faster clutch attacks

## Goal

Survive as many waves as possible by switching invincibility early, not late.
