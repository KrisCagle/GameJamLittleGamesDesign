# GameJamLittleGamesDesign
Invincibility game.
Godot 4 prototype for the jam theme invincibility.

Current Vertical Slice
3 auto-acting heroes: Knight, Mage, Rogue
One transferable Halo (invincibility) at a time
Instant switching with 1, 2, 3, or left-click on a hero
Halo switching now has tactical limits:
brief transfer cooldown
switch heat that can overheat and lock switching for a moment
Last Stand mode when only one hero lives:
Halo gains heat, flickers, and can overload
Tap the current hero key/click to vent the Halo and cool it (at risk)
Wave based enemy pressure with Swarm, Ranged, and Charger enemies
Escalating wave difficulty and mixed targeting pressure
Light synergy only:
Knight + Halo: periodic pull pulse and stronger frontline control
Mage + Halo: high burst damage
Rogue + Halo: higher mobility and faster clutch attacks
Roles are intentionally distinct:
Knight = slower, tankier, and stronger frontline control
Mage = fragile long-range burst
Rogue = fastest responder and cleanup
Goal
Survive as many waves as possible by switching invincibility early, not late.


What’s now in
Halo hero is now player-controlled (WASD/arrow keys), others stay AI-driven.
Core decision loop is centered on “who gets halo right now” under pressure.
Between waves, you now pick 1 of 3 upgrades (Q/W/E or 1/2/3) before next wave starts.
Roles are now clearly differentiated:
Tank: space control/protection, durable baseline.
Ranger: ranged support; halo enables healing pulses.
Rogue: aggressive finisher; much stronger/faster with halo, weaker without it.
Files changed
Hero.gd
Converted Mage role to Ranger.
Added is_player_controlled.
Added role-specific halo behavior and non-halo behavior.
Added healing/support hooks (heal, ranger support pulse).
Added rogue halo bonus fields for upgrade scaling.
Main.gd
Added direct-control input routing for current halo hero.
Added upgrade phase system and upgrade application logic.
Added new ranger/tank halo synergies.
Updated wave flow to include upgrade pick between waves.
Updated UI/hints to show control state and upgrade choices.
Notes
Existing projectile system and last-stand behavior were preserved and integrated.
