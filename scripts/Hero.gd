extends Node2D
class_name Hero
signal impact(position: Vector2, intensity: float)

enum HeroKind { KNIGHT, RANGER, ROGUE }
const HERO_ANIM_NAME := "idle"
const HERO_SHEET_FRAME_COUNT := 8
const KNIGHT_SPRITE_PATH := "res://assets/heroes/tank_idle.png"
const RANGER_SPRITE_PATH := "res://assets/heroes/ranger_idle.png"
const ROGUE_SPRITE_PATH := "res://assets/heroes/rogue_idle.png"
const HERO_SIZE_MULT := 1.5
const HERO_UNIFORM_BASE_SCALE := Vector2(0.98, 0.98)
const HERO_MOVE_SPEED_MULT := 0.94
const HERO_DAMAGE_MULT := 1.56

var kind: int = HeroKind.KNIGHT
var hero_name: String = "Knight"
var body_color: Color = Color(0.8, 0.85, 0.95)

var max_health: float = 100.0
var health: float = 100.0
var move_speed: float = 80.0
var attack_range: float = 70.0
var attack_damage: float = 12.0
var attack_cooldown: float = 0.8
var body_radius: float = 16.0
var preferred_distance: float = 130.0

var has_halo: bool = false
var is_player_controlled: bool = false
var attack_timer: float = 0.0
var pull_pulse_timer: float = 0.0
var support_pulse_timer: float = 0.0
var switch_flash_timer: float = 0.0
var visual_time: float = 0.0
var melee_swing_timer: float = 0.0
var melee_swing_duration: float = 0.16
var melee_swing_half_angle: float = 0.0
var melee_swing_reach: float = 0.0
var melee_swing_direction: Vector2 = Vector2.RIGHT
var melee_swing_color: Color = Color(1.0, 1.0, 1.0, 0.9)
var melee_swing_secondary_timer: float = 0.0
var melee_swing_secondary_half_angle: float = 0.0
var melee_swing_secondary_reach: float = 0.0
var melee_swing_secondary_direction: Vector2 = Vector2.LEFT
var melee_swing_secondary_color: Color = Color(0.8, 1.0, 0.9, 0.8)
var hero_sprite: AnimatedSprite2D = null
var facing_left: bool = false

var rogue_halo_damage_bonus_mult: float = 0.0
var rogue_halo_speed_bonus_mult: float = 0.0
var rogue_dual_strike_unlocked: bool = false
var tank_heavy_attack_unlocked: bool = false
var tank_heavy_charge_timer: float = 0.0
var tank_heavy_cooldown_timer: float = 0.0
var tank_heavy_target_point: Vector2 = Vector2.ZERO
var ranger_triple_arrows_unlocked: bool = false
var ranger_heal_visual_radius: float = 0.0
var ranger_heal_pulse_timer: float = 0.0
var ranger_heal_pulse_phase: float = 0.0
var team_power: float = 0.0

const ROGUE_ASSIST_TRIGGER_RATIO := 0.73
const ROGUE_ASSIST_THREAT_RADIUS := 225.0
const ROGUE_GUARD_PADDING := 40.0
const ROGUE_ANCHOR_TOLERANCE := 12.0
const ROGUE_TOO_CLOSE_MULT := 0.8
const ROGUE_GUARD_LOCK_DURATION := 0.65
const ROGUE_GUARD_SWAP_HEALTH_MARGIN := 0.08
const HERO_COHESION_DISTANCE := 172.0
const HERO_REJOIN_DISTANCE := 242.0
const HERO_DODGE_PADDING := 26.0
const RANGER_HEAL_PULSE_DURATION := 0.56
const PARTY_SOFT_RADIUS := 148.0
const PARTY_HARD_RADIUS := 212.0
const PARTY_COHESION_BLEND := 0.82
const HEALER_ANCHOR_SOFT_MIN := 120.0
const HEALER_ANCHOR_HARD_MIN := 180.0
const HEALER_ANCHOR_BLEND := 0.74
const WALL_SLIDE_MARGIN := 18.0
const FORMATION_RADIUS := 58.0
const FORMATION_SOFT_RADIUS := 18.0
const FORMATION_HARD_RADIUS := 60.0
const FORMATION_BLEND := 1.08
const HIT_FLASH_DURATION := 0.12
const LEADER_ROAM_RADIUS := 82.0
const LEADER_ATTACK_EXCURSION_RADIUS := 112.0
const LEADER_LEASH_RADIUS := 124.0
const LEADER_MAX_RADIUS := 162.0
const LEADER_FOLLOW_BLEND := 0.62
const LEADER_OUTWARD_DAMP := 0.82
const LEADER_COMBAT_CHASE_RADIUS := 148.0
const LEADER_COMBAT_FORMATION_RELAX := 0.58
const LEADER_COMBAT_OUTWARD_ALLOW := 0.72
const TANK_HEAVY_CHARGE_TIME := 0.26
const TANK_HEAVY_COOLDOWN := 3.8
const TANK_HEAVY_RADIUS_BONUS := 96.0
const TANK_HEAVY_DAMAGE_MULT := 2.35
const RANGER_TRIPLE_SPREAD := 0.2
const FACING_VELOCITY_DEADZONE := 12.0
const FACING_DIRECTION_DEADZONE := 0.16
const ATTACK_FACING_LOCK_TIME := 0.18

var rogue_guard_ally: Hero = null
var rogue_guard_lock_timer: float = 0.0
var rogue_velocity_smooth: Vector2 = Vector2.ZERO
var current_velocity: Vector2 = Vector2.ZERO
var knockback_velocity: Vector2 = Vector2.ZERO
var hit_flash_timer: float = 0.0
var pending_damage_source: Vector2 = Vector2.ZERO
var bob_phase: float = 0.0
var bob_amp: float = 0.0
var bob_freq: float = 0.0
var facing_lock_timer: float = 0.0

func configure(hero_kind: int, spawn_position: Vector2) -> void:
	kind = hero_kind
	global_position = spawn_position

	match kind:
		HeroKind.KNIGHT:
			hero_name = "Tank"
			body_color = Color(0.3, 0.5, 0.95)
			max_health = 300.0
			move_speed = 86.0
			attack_range = 68.0
			attack_damage = 18.0
			attack_cooldown = 0.92
			body_radius = 22.0
			preferred_distance = 84.0
		HeroKind.RANGER:
			hero_name = "Ranger"
			body_color = Color(0.95, 0.45, 0.75)
			max_health = 100.0
			move_speed = 92.0
			attack_range = 252.0
			attack_damage = 10.0
			attack_cooldown = 0.84
			body_radius = 14.0
			preferred_distance = 194.0
		HeroKind.ROGUE:
			hero_name = "Rogue"
			body_color = Color(0.3, 0.95, 0.65)
			max_health = 105.0
			move_speed = 176.0
			attack_range = 78.0
			attack_damage = 9.0
			attack_cooldown = 0.34
			body_radius = 13.0
			preferred_distance = 94.0

	health = max_health
	move_speed *= HERO_MOVE_SPEED_MULT
	attack_damage *= HERO_DAMAGE_MULT
	body_radius *= HERO_SIZE_MULT
	attack_timer = randf_range(0.12, 0.5)
	pull_pulse_timer = randf_range(0.2, 0.7)
	support_pulse_timer = randf_range(0.3, 0.95)
	switch_flash_timer = 0.0
	melee_swing_timer = 0.0
	melee_swing_half_angle = 0.0
	melee_swing_reach = 0.0
	melee_swing_direction = Vector2.RIGHT
	melee_swing_secondary_timer = 0.0
	melee_swing_secondary_half_angle = 0.0
	melee_swing_secondary_reach = 0.0
	melee_swing_secondary_direction = Vector2.LEFT
	visual_time = randf() * 100.0
	rogue_halo_damage_bonus_mult = 0.0
	rogue_halo_speed_bonus_mult = 0.0
	rogue_dual_strike_unlocked = false
	tank_heavy_attack_unlocked = false
	tank_heavy_charge_timer = 0.0
	tank_heavy_cooldown_timer = 0.0
	tank_heavy_target_point = global_position + Vector2.RIGHT * 10.0
	ranger_triple_arrows_unlocked = false
	ranger_heal_visual_radius = 0.0
	ranger_heal_pulse_timer = 0.0
	ranger_heal_pulse_phase = randf() * TAU
	team_power = 0.0
	current_velocity = Vector2.ZERO
	knockback_velocity = Vector2.ZERO
	hit_flash_timer = 0.0
	pending_damage_source = Vector2.ZERO
	bob_phase = randf() * TAU
	match kind:
		HeroKind.KNIGHT:
			bob_amp = 1.15
			bob_freq = 3.1
		HeroKind.RANGER:
			bob_amp = 1.8
			bob_freq = 3.9
		HeroKind.ROGUE:
			bob_amp = 2.25
			bob_freq = 4.8
	facing_left = false
	facing_lock_timer = 0.0
	_ensure_hero_sprite()
	_sync_hero_sprite_visuals()
	queue_redraw()

func process_tick(delta: float, enemies: Array[Enemy], heroes: Array[Hero], arena_rect: Rect2, projectile_spawns: Array[Dictionary], player_move_input: Vector2) -> void:
	if health <= 0.0:
		return

	attack_timer = maxf(0.0, attack_timer - delta)
	facing_lock_timer = maxf(0.0, facing_lock_timer - delta)
	rogue_guard_lock_timer = maxf(0.0, rogue_guard_lock_timer - delta)
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 420.0 * delta)
	tank_heavy_cooldown_timer = maxf(0.0, tank_heavy_cooldown_timer - delta)
	if tank_heavy_charge_timer > 0.0:
		tank_heavy_charge_timer = maxf(0.0, tank_heavy_charge_timer - delta)
		if tank_heavy_charge_timer <= 0.0 and kind == HeroKind.KNIGHT and tank_heavy_attack_unlocked:
			_execute_tank_heavy_attack(enemies)

	var target: Enemy = _select_movement_target(enemies, heroes)
	if is_player_controlled:
		_move_player_controlled(delta, player_move_input, enemies, arena_rect)
	else:
		_move_by_role(delta, target, heroes, enemies, arena_rect)
	_try_attack(target, enemies, projectile_spawns)

func _select_movement_target(enemies: Array[Enemy], heroes: Array[Hero]) -> Enemy:
	match kind:
		HeroKind.KNIGHT:
			return _find_nearest_enemy(enemies)
		HeroKind.RANGER:
			return _find_nearest_enemy(enemies)
		HeroKind.ROGUE:
			var ally: Hero = _find_ally_needing_help(heroes, enemies)
			if ally != null:
				return _find_enemy_near_point(enemies, ally.global_position)
			return _find_nearest_enemy(enemies)
	return null

func _move_player_controlled(delta: float, player_move_input: Vector2, enemies: Array[Enemy], arena_rect: Rect2) -> void:
	var direction: Vector2 = player_move_input
	if direction.length() > 1.0:
		direction = direction.normalized()

	var speed_mult: float = 1.0
	if has_halo:
		match kind:
			HeroKind.KNIGHT:
				speed_mult = 1.1
			HeroKind.RANGER:
				speed_mult = 1.16
			HeroKind.ROGUE:
				speed_mult = 1.36 + rogue_halo_speed_bonus_mult
	elif kind == HeroKind.ROGUE:
		speed_mult = 0.9

	var velocity: Vector2 = direction * move_speed * speed_mult
	var dodge: Vector2 = _compute_enemy_avoidance(enemies)
	if dodge.length_squared() > 0.0001:
		velocity += dodge * move_speed * 0.35
	velocity += knockback_velocity
	if velocity.length() > move_speed * 1.45:
		velocity = velocity.normalized() * move_speed * 1.45
	_update_facing_from_velocity(velocity)
	velocity = _apply_wall_slide(velocity, arena_rect)
	current_velocity = velocity

	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)

func _move_by_role(delta: float, target: Enemy, heroes: Array[Hero], enemies: Array[Enemy], arena_rect: Rect2) -> void:
	var velocity := Vector2.ZERO

	match kind:
		HeroKind.KNIGHT:
			if target != null:
				velocity = (target.global_position - global_position).normalized() * move_speed
			if has_halo:
				velocity *= 1.12
		HeroKind.RANGER:
			if target != null:
				var to_target: Vector2 = target.global_position - global_position
				var dist: float = to_target.length()
				if dist < preferred_distance * 0.86:
					velocity = -to_target.normalized() * move_speed
				elif dist > preferred_distance * 1.2:
					velocity = to_target.normalized() * move_speed * 0.9
				else:
					var tangent: Vector2 = Vector2(-to_target.y, to_target.x).normalized()
					velocity = tangent * move_speed * 0.64
		HeroKind.ROGUE:
			var ally: Hero = _resolve_rogue_guard_ally(heroes, enemies)
			if ally != null:
				var desired_spacing: float = ally.body_radius + body_radius + ROGUE_GUARD_PADDING
				var anchor: Vector2 = ally.global_position
				if target != null:
					var ally_to_threat: Vector2 = target.global_position - ally.global_position
					if ally_to_threat.length() > 0.001:
						anchor = ally.global_position - ally_to_threat.normalized() * desired_spacing
				else:
					var ally_to_rogue: Vector2 = global_position - ally.global_position
					if ally_to_rogue.length() <= 0.001:
						ally_to_rogue = Vector2.RIGHT
					anchor = ally.global_position + ally_to_rogue.normalized() * desired_spacing

				var ally_to_rogue_now: Vector2 = global_position - ally.global_position
				var ally_dist_now: float = ally_to_rogue_now.length()
				if ally_dist_now < desired_spacing * ROGUE_TOO_CLOSE_MULT:
					var away: Vector2 = ally_to_rogue_now.normalized() if ally_dist_now > 0.001 else Vector2.RIGHT
					var tangent_escape: Vector2 = Vector2(-away.y, away.x).normalized()
					velocity = (away * 0.82 + tangent_escape * 0.58).normalized() * move_speed * 1.24
				else:
					var to_anchor: Vector2 = anchor - global_position
					var anchor_dist: float = to_anchor.length()
					if anchor_dist > ROGUE_ANCHOR_TOLERANCE:
						var speed_mult: float = 1.18
						if has_halo:
							speed_mult = 1.42 + rogue_halo_speed_bonus_mult
						velocity = to_anchor.normalized() * move_speed * speed_mult
					else:
						var orbit_axis: Vector2 = global_position - anchor
						if orbit_axis.length() <= 0.001:
							orbit_axis = Vector2.RIGHT
						var tangent: Vector2 = Vector2(-orbit_axis.y, orbit_axis.x).normalized()
						velocity = tangent * move_speed * 0.82
			elif target != null:
				rogue_guard_ally = null
				var chase_mult: float = 1.04 if not has_halo else 1.18 + rogue_halo_speed_bonus_mult
				velocity = (target.global_position - global_position).normalized() * move_speed * chase_mult

	if not has_halo:
		var halo_anchor: Hero = _find_halo_anchor(heroes)
		if halo_anchor != null and halo_anchor != self:
			var to_anchor: Vector2 = halo_anchor.global_position - global_position
			var dist_to_anchor: float = to_anchor.length()
			if dist_to_anchor > HERO_REJOIN_DISTANCE:
				velocity = to_anchor.normalized() * move_speed * 1.05
			elif dist_to_anchor > HERO_COHESION_DISTANCE:
				var cohesion_velocity: Vector2 = to_anchor.normalized() * move_speed * 0.86
				velocity = velocity.lerp(cohesion_velocity, 0.5)

	# Keep non-controlled heroes feeling like a party: chase threats, but snap back when too spread.
	velocity = _apply_party_cohesion(velocity, heroes)
	velocity = _apply_healer_anchor(velocity, heroes)
	velocity = _apply_controlled_leader_formation(velocity, heroes, target)

	var dodge: Vector2 = _compute_enemy_avoidance(enemies)
	if dodge.length_squared() > 0.0001:
		var dodge_mult := 0.75
		match kind:
			HeroKind.KNIGHT:
				dodge_mult = 0.4
			HeroKind.RANGER:
				dodge_mult = 1.2
			HeroKind.ROGUE:
				dodge_mult = 0.82
		velocity += dodge * move_speed * dodge_mult

	# Rogue guard AI can oscillate when ally-threat vectors change quickly.
	# Smooth its final steering a bit so movement stays fast but less jittery.
	if kind == HeroKind.ROGUE and not is_player_controlled:
		var smooth_t: float = clampf(delta * 12.0, 0.0, 1.0)
		rogue_velocity_smooth = rogue_velocity_smooth.lerp(velocity, smooth_t)
		velocity = rogue_velocity_smooth
	velocity += knockback_velocity

	if velocity.length() > move_speed * 1.45:
		velocity = velocity.normalized() * move_speed * 1.45
	_update_facing_from_velocity(velocity)
	velocity = _apply_wall_slide(velocity, arena_rect)
	current_velocity = velocity

	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)

func _try_attack(target: Enemy, enemies: Array[Enemy], projectile_spawns: Array[Dictionary]) -> void:
	if attack_timer > 0.0:
		return

	var active_target: Enemy = target
	if active_target == null or active_target.health <= 0.0:
		active_target = _find_nearest_enemy(enemies)
	if active_target == null:
		return

	var distance: float = global_position.distance_to(active_target.global_position)
	var attack_face_dir: Vector2 = (active_target.global_position - global_position).normalized()
	_set_facing_from_direction(attack_face_dir, ATTACK_FACING_LOCK_TIME)
	if kind == HeroKind.RANGER:
		var ranged_limit: float = attack_range + 96.0 + team_power * 68.0
		if distance > ranged_limit:
			var ranged_fallback: Enemy = _find_nearest_enemy(enemies, ranged_limit)
			if ranged_fallback == null:
				ranged_fallback = _find_nearest_enemy(enemies, attack_range + 420.0)
				if ranged_fallback == null:
					return
			active_target = ranged_fallback
			distance = global_position.distance_to(active_target.global_position)
			attack_face_dir = (active_target.global_position - global_position).normalized()
			_set_facing_from_direction(attack_face_dir, ATTACK_FACING_LOCK_TIME)
	else:
		var melee_limit: float = attack_range + body_radius + 4.0
		if distance > melee_limit:
			var melee_fallback: Enemy = _find_nearest_enemy(enemies, melee_limit)
			if melee_fallback == null:
				return
			active_target = melee_fallback
			distance = global_position.distance_to(active_target.global_position)
			attack_face_dir = (active_target.global_position - global_position).normalized()
			_set_facing_from_direction(attack_face_dir, ATTACK_FACING_LOCK_TIME)

	var damage_mult: float = 1.0
	if has_halo:
		match kind:
			HeroKind.KNIGHT:
				damage_mult = 1.24
			HeroKind.RANGER:
				damage_mult = 1.08
			HeroKind.ROGUE:
				damage_mult = 1.92 + rogue_halo_damage_bonus_mult
	elif kind == HeroKind.ROGUE:
		damage_mult = 0.84

	var dealt_damage: float = attack_damage * damage_mult
	if has_halo:
		dealt_damage *= lerpf(1.0, 1.22, team_power)
	if kind == HeroKind.RANGER:
		var shot_speed: float = (540.0 if has_halo else 438.0) + team_power * (58.0 if has_halo else 24.0)
		if ranger_triple_arrows_unlocked:
			var base_dir: Vector2 = (active_target.global_position - global_position).normalized()
			if base_dir.length_squared() <= 0.0001:
				base_dir = Vector2.RIGHT
			for shot_angle in [-RANGER_TRIPLE_SPREAD, 0.0, RANGER_TRIPLE_SPREAD]:
				var dir: Vector2 = base_dir.rotated(float(shot_angle))
				var is_center: bool = is_zero_approx(float(shot_angle))
				var homing_rate: float = 6.0 if has_halo else 4.2
				if not is_center:
					homing_rate = 5.1 if has_halo else 3.7
				projectile_spawns.append({
					"team": "hero",
					"position": global_position,
					"target_position": global_position + dir * 320.0,
					"damage": dealt_damage * 0.7,
					"speed": shot_speed,
					"radius": 5.0,
					"life": 2.0,
					"color": Color(0.98, 0.46, 0.92),
					"homing_target": active_target,
					"homing_turn_rate": homing_rate
				})
		else:
			projectile_spawns.append({
				"team": "hero",
				"position": global_position,
				"target_position": active_target.global_position,
				"damage": dealt_damage,
				"speed": shot_speed,
				"radius": 5.0,
				"life": 2.0,
				"color": Color(0.98, 0.46, 0.92),
				"homing_target": active_target,
				"homing_turn_rate": 6.0 if has_halo else 4.2
			})
		var ranged_cooldown_mult: float = 0.86 if has_halo else 1.0
		var ranged_power: float = team_power if has_halo else team_power * 0.45
		ranged_cooldown_mult *= lerpf(1.0, 0.78, ranged_power)
		attack_timer = attack_cooldown * ranged_cooldown_mult
		return

	var attack_dir: Vector2 = (active_target.global_position - global_position).normalized()
	if attack_dir.length_squared() <= 0.0001:
		attack_dir = Vector2.RIGHT
	_set_facing_from_direction(attack_dir, ATTACK_FACING_LOCK_TIME)

	if kind == HeroKind.KNIGHT and tank_heavy_attack_unlocked and tank_heavy_charge_timer <= 0.0 and tank_heavy_cooldown_timer <= 0.0:
		tank_heavy_charge_timer = TANK_HEAVY_CHARGE_TIME
		tank_heavy_target_point = active_target.global_position
		attack_timer = maxf(attack_cooldown * 0.36, TANK_HEAVY_CHARGE_TIME)
		return

	var melee_reach: float = attack_range + body_radius + 4.0
	var melee_half_angle: float = deg_to_rad(46.0)
	var swing_color: Color = Color(1.0, 0.95, 0.7, 0.9)
	match kind:
		HeroKind.KNIGHT:
			melee_reach += 12.0
			melee_half_angle = deg_to_rad(58.0)
			swing_color = Color(0.56, 0.78, 1.0, 0.95)
		HeroKind.ROGUE:
			melee_reach += 16.0
			melee_half_angle = deg_to_rad(42.0)
			swing_color = Color(0.6, 1.0, 0.76, 0.95)

	var hit_count: int = _apply_melee_cone_damage(enemies, attack_dir, melee_reach, melee_half_angle, dealt_damage)
	_start_melee_swing(attack_dir, melee_reach, melee_half_angle, swing_color)
	if kind == HeroKind.ROGUE and rogue_dual_strike_unlocked:
		var offhand_dir: Vector2 = -attack_dir
		var offhand_damage: float = dealt_damage * 0.8
		var offhand_half_angle: float = melee_half_angle * 0.9
		var offhand_reach: float = melee_reach * 0.95
		hit_count += _apply_melee_cone_damage(enemies, offhand_dir, offhand_reach, offhand_half_angle, offhand_damage)
		_start_secondary_melee_swing(offhand_dir, offhand_reach, offhand_half_angle, Color(0.74, 1.0, 0.84, 0.9))
	if hit_count > 0 and kind == HeroKind.KNIGHT and has_halo:
		for enemy: Enemy in enemies:
			if enemy.health <= 0.0:
				continue
			if global_position.distance_to(enemy.global_position) <= melee_reach:
				enemy.apply_pull_towards(global_position, 20.0)

	var cooldown_mult := 1.0
	if has_halo and kind == HeroKind.ROGUE:
		cooldown_mult = 0.56
	var melee_power: float = team_power if has_halo else team_power * 0.35
	cooldown_mult *= lerpf(1.0, 0.86, melee_power)
	attack_timer = attack_cooldown * cooldown_mult

func _apply_melee_cone_damage(enemies: Array[Enemy], attack_dir: Vector2, reach: float, half_angle: float, damage: float) -> int:
	var dir: Vector2 = attack_dir.normalized()
	var cos_half_angle: float = cos(half_angle)
	var hit_count: int = 0

	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var to_enemy: Vector2 = enemy.global_position - global_position
		var dist: float = to_enemy.length()
		if dist <= 0.001:
			continue
		if dist > reach + enemy.body_radius:
			continue
		var forward_dot: float = dir.dot(to_enemy / dist)
		if forward_dot < cos_half_angle:
			continue
		enemy.set_damage_source(global_position)
		enemy.take_damage(damage)
		hit_count += 1

	return hit_count

func _execute_tank_heavy_attack(enemies: Array[Enemy]) -> void:
	if health <= 0.0:
		return
	var to_target: Vector2 = tank_heavy_target_point - global_position
	var attack_dir: Vector2 = to_target.normalized() if to_target.length_squared() > 0.0001 else Vector2.RIGHT
	_set_facing_from_direction(attack_dir, ATTACK_FACING_LOCK_TIME)
	var heavy_reach: float = attack_range + body_radius + TANK_HEAVY_RADIUS_BONUS
	var heavy_damage: float = attack_damage * TANK_HEAVY_DAMAGE_MULT
	var hit_count: int = 0
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var dist: float = enemy.global_position.distance_to(global_position)
		if dist > heavy_reach + enemy.body_radius:
			continue
		enemy.set_damage_source(global_position)
		enemy.take_damage(heavy_damage)
		hit_count += 1
	_start_melee_swing(attack_dir, heavy_reach, deg_to_rad(172.0), Color(0.74, 0.92, 1.0, 0.96))
	if hit_count > 0:
		for enemy: Enemy in enemies:
			if enemy.health <= 0.0:
				continue
			if enemy.global_position.distance_to(global_position) <= heavy_reach:
				enemy.apply_pull_towards(global_position, 26.0)
	tank_heavy_cooldown_timer = TANK_HEAVY_COOLDOWN
	queue_redraw()

func _start_melee_swing(dir: Vector2, reach: float, half_angle: float, color: Color) -> void:
	melee_swing_timer = melee_swing_duration
	melee_swing_direction = dir.normalized()
	melee_swing_reach = reach
	melee_swing_half_angle = half_angle
	melee_swing_color = color
	queue_redraw()

func _start_secondary_melee_swing(dir: Vector2, reach: float, half_angle: float, color: Color) -> void:
	melee_swing_secondary_timer = melee_swing_duration * 0.92
	melee_swing_secondary_direction = dir.normalized()
	melee_swing_secondary_reach = reach
	melee_swing_secondary_half_angle = half_angle
	melee_swing_secondary_color = color
	queue_redraw()

func _find_nearest_enemy(enemies: Array[Enemy], max_distance: float = -1.0) -> Enemy:
	var best_dist := INF
	var nearest: Enemy = null
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var dist: float = global_position.distance_to(enemy.global_position)
		if max_distance > 0.0 and dist > max_distance:
			continue
		if dist < best_dist:
			best_dist = dist
			nearest = enemy
	return nearest

func _find_enemy_near_point(enemies: Array[Enemy], point: Vector2) -> Enemy:
	var best_dist := INF
	var nearest: Enemy = null
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var dist: float = point.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			nearest = enemy
	return nearest

func _find_ally_needing_help(heroes: Array[Hero], enemies: Array[Enemy]) -> Hero:
	var result: Hero = null
	var lowest_ratio: float = INF
	for hero: Hero in heroes:
		if hero == self:
			continue
		if hero.health <= 0.0:
			continue
		var ratio: float = hero.health / maxf(hero.max_health, 0.01)
		if ratio < lowest_ratio:
			lowest_ratio = ratio
			result = hero

	if result == null:
		return null
	if lowest_ratio > ROGUE_ASSIST_TRIGGER_RATIO:
		return null
	var nearest_threat_dist: float = _nearest_enemy_distance_to_point(enemies, result.global_position)
	if nearest_threat_dist > ROGUE_ASSIST_THREAT_RADIUS:
		return null
	return result

func _resolve_rogue_guard_ally(heroes: Array[Hero], enemies: Array[Enemy]) -> Hero:
	if kind != HeroKind.ROGUE:
		return null

	if rogue_guard_ally != null and (not is_instance_valid(rogue_guard_ally) or rogue_guard_ally.health <= 0.0):
		rogue_guard_ally = null
		rogue_guard_lock_timer = 0.0

	var candidate: Hero = _find_ally_needing_help(heroes, enemies)
	if rogue_guard_ally == null:
		if candidate != null:
			rogue_guard_ally = candidate
			rogue_guard_lock_timer = ROGUE_GUARD_LOCK_DURATION
		return rogue_guard_ally

	if candidate == null:
		if rogue_guard_lock_timer <= 0.0:
			rogue_guard_ally = null
		return rogue_guard_ally

	if candidate != rogue_guard_ally:
		var current_ratio: float = rogue_guard_ally.health_ratio()
		var candidate_ratio: float = candidate.health_ratio()
		var should_swap: bool = candidate_ratio < (current_ratio - ROGUE_GUARD_SWAP_HEALTH_MARGIN)
		if should_swap and rogue_guard_lock_timer <= 0.0:
			rogue_guard_ally = candidate
			rogue_guard_lock_timer = ROGUE_GUARD_LOCK_DURATION
	else:
		rogue_guard_lock_timer = ROGUE_GUARD_LOCK_DURATION

	return rogue_guard_ally

func _nearest_enemy_distance_to_point(enemies: Array[Enemy], point: Vector2) -> float:
	var nearest_dist: float = INF
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var dist: float = point.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
	return nearest_dist

func _find_halo_anchor(heroes: Array[Hero]) -> Hero:
	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		if hero.has_halo:
			return hero
	return null

func _find_controlled_leader(heroes: Array[Hero]) -> Hero:
	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		if hero.is_player_controlled:
			return hero
	return null

func _apply_controlled_leader_formation(base_velocity: Vector2, heroes: Array[Hero], target: Enemy) -> Vector2:
	if is_player_controlled or health <= 0.0:
		return base_velocity

	var leader: Hero = _find_controlled_leader(heroes)
	if leader == null or leader == self:
		return base_velocity

	var follower_count: int = 0
	var my_slot: int = -1
	for hero: Hero in heroes:
		if hero.health <= 0.0 or hero == leader:
			continue
		if hero == self:
			my_slot = follower_count
		follower_count += 1

	if my_slot < 0 or follower_count <= 0:
		return base_velocity

	var slot_step: float = TAU / float(follower_count + 1)
	var slot_angle: float = -PI * 0.5 + slot_step * float(my_slot + 1)
	var desired: Vector2 = leader.global_position + Vector2.RIGHT.rotated(slot_angle) * FORMATION_RADIUS
	var to_slot: Vector2 = desired - global_position
	var dist: float = to_slot.length()
	var to_leader: Vector2 = leader.global_position - global_position
	var dist_leader: float = to_leader.length()
	var leader_vel: Vector2 = leader.current_velocity
	var leader_speed_ratio: float = clampf(leader_vel.length() / maxf(leader.move_speed * 1.05, 0.01), 0.0, 1.0)
	var combat_pressure: float = 0.0
	if target != null and target.health > 0.0:
		var target_dist: float = global_position.distance_to(target.global_position)
		var engage_dist: float = attack_range + 68.0 if kind != HeroKind.RANGER else attack_range + 112.0
		if target_dist <= engage_dist:
			combat_pressure = 1.0
		elif target_dist <= engage_dist + 72.0:
			combat_pressure = 0.55
		if dist_leader > LEADER_COMBAT_CHASE_RADIUS:
			var chase_t: float = clampf((dist_leader - LEADER_COMBAT_CHASE_RADIUS) / maxf(LEADER_MAX_RADIUS - LEADER_COMBAT_CHASE_RADIUS, 0.01), 0.0, 1.0)
			combat_pressure *= (1.0 - chase_t * 0.92)
	var formation_pull_mult: float = 1.0 - combat_pressure * LEADER_COMBAT_FORMATION_RELAX
	var constrained_velocity: Vector2 = base_velocity
	if dist_leader > 0.001:
		var radial_dir: Vector2 = (global_position - leader.global_position).normalized()
		var outward_speed: float = maxf(constrained_velocity.dot(radial_dir), 0.0)
		if outward_speed > 0.0 and dist_leader >= LEADER_ATTACK_EXCURSION_RADIUS:
			var damp_t: float = clampf((dist_leader - LEADER_ATTACK_EXCURSION_RADIUS) / maxf(LEADER_MAX_RADIUS - LEADER_ATTACK_EXCURSION_RADIUS, 0.01), 0.22, 1.0)
			var damp_strength: float = LEADER_OUTWARD_DAMP * damp_t * (1.0 - combat_pressure * LEADER_COMBAT_OUTWARD_ALLOW)
			constrained_velocity -= radial_dir * outward_speed * damp_strength
		if outward_speed > 0.0 and dist_leader >= LEADER_LEASH_RADIUS:
			constrained_velocity -= radial_dir * outward_speed * (1.0 - combat_pressure * 0.45)

	if combat_pressure >= 0.8 and dist_leader <= LEADER_ATTACK_EXCURSION_RADIUS:
		if leader_speed_ratio > 0.05:
			return constrained_velocity.lerp(leader_vel, LEADER_FOLLOW_BLEND * 0.42)
		return constrained_velocity

	# Inside roam radius: keep combat behavior, just mild slot attraction.
	if dist_leader <= LEADER_ROAM_RADIUS:
		if dist <= FORMATION_SOFT_RADIUS or dist <= 0.001:
			if leader_speed_ratio <= 0.05:
				return constrained_velocity
			return constrained_velocity.lerp(leader_vel, LEADER_FOLLOW_BLEND * 0.7)
		var t_soft: float = clampf((dist - FORMATION_SOFT_RADIUS) / maxf(FORMATION_HARD_RADIUS - FORMATION_SOFT_RADIUS, 0.01), 0.0, 1.0)
		var slot_velocity_soft: Vector2 = to_slot.normalized() * move_speed * (0.7 + t_soft * 0.33)
		var follow_velocity: Vector2 = leader_vel * (0.44 + leader_speed_ratio * 0.44)
		var blended_soft: Vector2 = constrained_velocity.lerp(slot_velocity_soft, (0.42 + t_soft * 0.34) * formation_pull_mult)
		if leader_speed_ratio > 0.05:
			blended_soft = blended_soft.lerp(follow_velocity, LEADER_FOLLOW_BLEND * (0.58 + t_soft * 0.42))
		return blended_soft

	# Between roam and leash: allow aggression, but bias back toward formation.
	if dist_leader <= LEADER_LEASH_RADIUS:
		var t_mid: float = (dist_leader - LEADER_ROAM_RADIUS) / maxf(LEADER_LEASH_RADIUS - LEADER_ROAM_RADIUS, 0.01)
		var slot_velocity_mid: Vector2 = to_slot.normalized() * move_speed * 1.14 if dist > 0.001 else Vector2.ZERO
		var blended_mid: Vector2 = constrained_velocity.lerp(slot_velocity_mid, clampf((0.66 + t_mid * 0.26) * formation_pull_mult, 0.0, 0.96))
		if leader_speed_ratio > 0.05:
			blended_mid = blended_mid.lerp(leader_vel, LEADER_FOLLOW_BLEND * (0.6 + t_mid * 0.36 + leader_speed_ratio * 0.18))
		return blended_mid

	# Hard leash: pull back strongly so party stays together.
	if dist_leader >= LEADER_MAX_RADIUS:
		var hard_return: Vector2 = to_leader.normalized() * move_speed * 1.52
		if dist > 0.001:
			hard_return = hard_return.lerp(to_slot.normalized() * move_speed * 1.24, 0.36)
		return hard_return + leader_vel * 0.56

	var t_hard: float = (dist_leader - LEADER_LEASH_RADIUS) / maxf(LEADER_MAX_RADIUS - LEADER_LEASH_RADIUS, 0.01)
	var pull_velocity: Vector2 = to_leader.normalized() * move_speed * (1.2 + t_hard * 0.44)
	if dist > 0.001:
		pull_velocity = pull_velocity.lerp(to_slot.normalized() * move_speed * 1.1, 0.28)
	var blended_hard: Vector2 = constrained_velocity.lerp(pull_velocity, clampf(0.86 + t_hard * 0.14, 0.0, 0.99))
	if leader_speed_ratio > 0.05:
		blended_hard = blended_hard.lerp(leader_vel, LEADER_FOLLOW_BLEND * (0.66 + leader_speed_ratio * 0.22))
	return blended_hard

func _find_active_ranger_healer(heroes: Array[Hero]) -> Hero:
	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		if hero.kind == HeroKind.RANGER and hero.has_halo:
			return hero
	return null

func _apply_party_cohesion(base_velocity: Vector2, heroes: Array[Hero]) -> Vector2:
	var alive_count: int = 0
	var center: Vector2 = Vector2.ZERO
	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		alive_count += 1
		center += hero.global_position

	if alive_count <= 1:
		return base_velocity

	center /= float(alive_count)
	var to_center: Vector2 = center - global_position
	var dist_to_center: float = to_center.length()
	if dist_to_center <= PARTY_SOFT_RADIUS or dist_to_center <= 0.001:
		return base_velocity

	var regroup_dir: Vector2 = to_center.normalized()
	if dist_to_center >= PARTY_HARD_RADIUS:
		return regroup_dir * move_speed * 1.15

	var t: float = (dist_to_center - PARTY_SOFT_RADIUS) / maxf(PARTY_HARD_RADIUS - PARTY_SOFT_RADIUS, 0.01)
	var regroup_velocity: Vector2 = regroup_dir * move_speed * (0.72 + t * 0.3)
	return base_velocity.lerp(regroup_velocity, clampf(PARTY_COHESION_BLEND * t + 0.18, 0.0, 0.9))

func _apply_healer_anchor(base_velocity: Vector2, heroes: Array[Hero]) -> Vector2:
	if has_halo:
		return base_velocity

	var healer: Hero = _find_active_ranger_healer(heroes)
	if healer == null or healer == self:
		return base_velocity

	var to_healer: Vector2 = healer.global_position - global_position
	var dist: float = to_healer.length()
	if dist <= 0.001:
		return base_velocity

	var heal_radius: float = maxf(float(healer.ranger_heal_visual_radius), 0.0)
	var soft_radius: float = maxf(HEALER_ANCHOR_SOFT_MIN, heal_radius * 0.64)
	var hard_radius: float = maxf(HEALER_ANCHOR_HARD_MIN, heal_radius * 0.9)
	if dist <= soft_radius:
		return base_velocity

	var dir: Vector2 = to_healer.normalized()
	if dist >= hard_radius:
		return dir * move_speed * 1.1

	var t: float = (dist - soft_radius) / maxf(hard_radius - soft_radius, 0.01)
	var regroup_velocity: Vector2 = dir * move_speed * (0.74 + t * 0.26)
	return base_velocity.lerp(regroup_velocity, clampf(HEALER_ANCHOR_BLEND * t + 0.15, 0.0, 0.92))

func _compute_enemy_avoidance(enemies: Array[Enemy]) -> Vector2:
	var steering := Vector2.ZERO
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var away: Vector2 = global_position - enemy.global_position
		var dist: float = away.length()
		var avoid_radius: float = body_radius + enemy.body_radius + HERO_DODGE_PADDING
		if dist <= 0.001 or dist > avoid_radius:
			continue
		var weight: float = (avoid_radius - dist) / avoid_radius
		steering += away.normalized() * weight

	if steering.length() > 1.0:
		steering = steering.normalized()
	return steering

func _apply_wall_slide(base_velocity: Vector2, arena_rect: Rect2) -> Vector2:
	var velocity: Vector2 = base_velocity
	var min_x: float = arena_rect.position.x + body_radius
	var max_x: float = arena_rect.end.x - body_radius
	var min_y: float = arena_rect.position.y + body_radius
	var max_y: float = arena_rect.end.y - body_radius

	if global_position.x <= min_x + WALL_SLIDE_MARGIN and velocity.x < 0.0:
		velocity.x = 0.0
	elif global_position.x >= max_x - WALL_SLIDE_MARGIN and velocity.x > 0.0:
		velocity.x = 0.0

	if global_position.y <= min_y + WALL_SLIDE_MARGIN and velocity.y < 0.0:
		velocity.y = 0.0
	elif global_position.y >= max_y - WALL_SLIDE_MARGIN and velocity.y > 0.0:
		velocity.y = 0.0

	return velocity

func _hero_sprite_path_for_kind(hero_kind: int) -> String:
	match hero_kind:
		HeroKind.KNIGHT:
			return KNIGHT_SPRITE_PATH
		HeroKind.RANGER:
			return RANGER_SPRITE_PATH
		HeroKind.ROGUE:
			return ROGUE_SPRITE_PATH
	return ""

func _hero_sprite_scale_for_kind(hero_kind: int) -> Vector2:
	return HERO_UNIFORM_BASE_SCALE * HERO_SIZE_MULT

func _ensure_hero_sprite() -> void:
	if hero_sprite != null:
		if not hero_sprite.is_playing():
			hero_sprite.play(HERO_ANIM_NAME)
		return

	var texture: Texture2D = load(_hero_sprite_path_for_kind(kind))
	if texture == null:
		return

	var tex_w: int = texture.get_width()
	var tex_h: int = texture.get_height()
	if tex_w <= 0 or tex_h <= 0:
		return

	var frame_count: int = HERO_SHEET_FRAME_COUNT
	if tex_w % HERO_SHEET_FRAME_COUNT != 0:
		frame_count = maxi(1, int(round(float(tex_w) / maxf(float(tex_h), 1.0))))
	frame_count = clampi(frame_count, 1, 16)
	var frame_width: int = int(floor(float(tex_w) / float(frame_count)))
	if frame_width <= 0:
		return

	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation(HERO_ANIM_NAME)
	frames.set_animation_loop(HERO_ANIM_NAME, true)
	frames.set_animation_speed(HERO_ANIM_NAME, 8.0)
	for i in range(frame_count):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_width, 0, frame_width, tex_h)
		atlas.filter_clip = true
		frames.add_frame(HERO_ANIM_NAME, atlas)

	hero_sprite = AnimatedSprite2D.new()
	hero_sprite.name = "HeroSprite"
	hero_sprite.centered = true
	hero_sprite.z_index = 0
	hero_sprite.show_behind_parent = true
	hero_sprite.sprite_frames = frames
	hero_sprite.animation = HERO_ANIM_NAME
	hero_sprite.scale = _hero_sprite_scale_for_kind(kind)
	add_child(hero_sprite)
	hero_sprite.play(HERO_ANIM_NAME)

func _update_facing_from_velocity(velocity: Vector2) -> void:
	if absf(velocity.x) < FACING_VELOCITY_DEADZONE:
		return
	_set_facing_from_direction(velocity, 0.0)

func _set_facing_from_direction(direction: Vector2, lock_time: float = 0.0) -> void:
	if direction.length_squared() <= 0.0001:
		return
	if absf(direction.x) < FACING_DIRECTION_DEADZONE:
		return
	var want_left: bool = direction.x < 0.0
	if facing_lock_timer > 0.0 and want_left != facing_left:
		return
	facing_left = want_left
	if lock_time > 0.0:
		facing_lock_timer = maxf(facing_lock_timer, lock_time)
	_sync_hero_sprite_visuals()

func _sync_hero_sprite_visuals() -> void:
	if hero_sprite == null:
		return
	hero_sprite.flip_h = facing_left
	hero_sprite.position = Vector2(0.0, _current_bob_offset())
	if health <= 0.0:
		hero_sprite.modulate = Color(0.34, 0.34, 0.34, 0.95)
	else:
		hero_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _current_bob_offset() -> float:
	if health <= 0.0:
		return 0.0
	var halo_boost: float = 1.18 if has_halo else 1.0
	var move_boost: float = 1.12 if is_player_controlled else 1.0
	return sin(visual_time * bob_freq + bob_phase) * bob_amp * halo_boost * move_boost

func set_damage_source(source_position: Vector2) -> void:
	pending_damage_source = source_position

func apply_damage(amount: float) -> void:
	if health <= 0.0:
		return
	if has_halo:
		return

	var incoming: float = amount
	if kind == HeroKind.ROGUE:
		incoming *= 1.18
	elif kind == HeroKind.KNIGHT:
		incoming *= 0.88
	health = maxf(0.0, health - incoming)
	hit_flash_timer = HIT_FLASH_DURATION
	var source_position: Vector2 = pending_damage_source
	pending_damage_source = Vector2.ZERO
	if source_position != Vector2.ZERO:
		var away: Vector2 = global_position - source_position
		if away.length_squared() > 0.0001:
			var knockback_strength: float = 54.0
			match kind:
				HeroKind.KNIGHT:
					knockback_strength = 34.0
				HeroKind.RANGER:
					knockback_strength = 50.0
				HeroKind.ROGUE:
					knockback_strength = 58.0
			knockback_velocity += away.normalized() * knockback_strength
	emit_signal("impact", global_position, 0.58)
	_sync_hero_sprite_visuals()
	queue_redraw()

func heal(amount: float) -> void:
	if health <= 0.0:
		return
	health = minf(max_health, health + maxf(amount, 0.0))
	_sync_hero_sprite_visuals()
	queue_redraw()

func add_max_health(amount: float) -> void:
	if amount <= 0.0:
		return
	max_health += amount
	health += amount
	queue_redraw()

func set_halo(active: bool) -> void:
	if has_halo == active:
		return
	has_halo = active
	queue_redraw()

func set_team_power(power: float) -> void:
	team_power = clampf(power, 0.0, 1.0)

func set_player_controlled(active: bool) -> void:
	if is_player_controlled == active:
		return
	is_player_controlled = active
	if active and kind == HeroKind.ROGUE:
		rogue_velocity_smooth = Vector2.ZERO
	queue_redraw()

func trigger_halo_switch_feedback() -> void:
	switch_flash_timer = 0.24
	queue_redraw()

func process_visual_tick(delta: float) -> void:
	visual_time += delta
	_sync_hero_sprite_visuals()
	var need_redraw := false
	if hit_flash_timer > 0.0:
		hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
		need_redraw = true
	if switch_flash_timer > 0.0:
		switch_flash_timer = maxf(0.0, switch_flash_timer - delta)
		need_redraw = true
	if ranger_heal_pulse_timer > 0.0:
		ranger_heal_pulse_timer = maxf(0.0, ranger_heal_pulse_timer - delta)
		need_redraw = true
	if melee_swing_timer > 0.0:
		melee_swing_timer = maxf(0.0, melee_swing_timer - delta)
		need_redraw = true
	if melee_swing_secondary_timer > 0.0:
		melee_swing_secondary_timer = maxf(0.0, melee_swing_secondary_timer - delta)
		need_redraw = true
	if tank_heavy_charge_timer > 0.0:
		need_redraw = true
	if need_redraw:
		queue_redraw()

func trigger_ranger_heal_pulse() -> void:
	if kind != HeroKind.RANGER:
		return
	ranger_heal_pulse_timer = RANGER_HEAL_PULSE_DURATION
	ranger_heal_pulse_phase = randf() * TAU
	queue_redraw()

func health_ratio() -> float:
	if max_health <= 0.0:
		return 0.0
	return health / max_health

func consume_knight_pull_pulse(delta: float) -> bool:
	if kind != HeroKind.KNIGHT:
		return false
	if not has_halo or health <= 0.0:
		return false

	pull_pulse_timer = maxf(0.0, pull_pulse_timer - delta)
	if pull_pulse_timer > 0.0:
		return false
	pull_pulse_timer = 0.9
	return true

func consume_ranger_support_pulse(delta: float) -> bool:
	if kind != HeroKind.RANGER:
		return false
	if not has_halo or health <= 0.0:
		return false

	support_pulse_timer = maxf(0.0, support_pulse_timer - delta)
	if support_pulse_timer > 0.0:
		return false
	support_pulse_timer = 1.02
	return true

func _draw() -> void:
	var color := body_color
	if health <= 0.0:
		color = Color(0.2, 0.2, 0.2, 0.95)
	var draw_body: bool = hero_sprite == null
	var bob_y: float = _current_bob_offset()
	if draw_body:
		draw_circle(Vector2(0.0, bob_y), body_radius, color)

	if hit_flash_timer > 0.0:
		var flash_t: float = hit_flash_timer / HIT_FLASH_DURATION
		draw_circle(Vector2(0.0, bob_y), body_radius + 5.0, Color(1.0, 1.0, 1.0, 0.28 * flash_t))

	if has_halo and health > 0.0:
		var halo_pulse: float = 1.0 + sin(visual_time * 2.9 + float(kind)) * (0.03 + team_power * 0.06)
		var halo_radius: float = body_radius + 8.0 + team_power * 5.0 * halo_pulse
		var halo_width: float = 4.0 + team_power * 2.2
		draw_arc(Vector2(0.0, bob_y), halo_radius, 0.0, TAU, 36, Color(1.0, 0.95, 0.45), halo_width)
		draw_circle(Vector2(0.0, bob_y), body_radius + 3.0 + team_power * 2.4, Color(1.0, 0.95, 0.45, 0.2 + team_power * 0.08))

	if team_power > 0.04 and health > 0.0:
		var cohesion_radius: float = body_radius + 9.0 + team_power * 6.0
		var cohesion_alpha: float = 0.05 + team_power * 0.2
		draw_arc(Vector2(0.0, bob_y), cohesion_radius, 0.0, TAU, 30, Color(0.72, 0.96, 1.0, cohesion_alpha), 1.1 + team_power * 1.9)

	if kind == HeroKind.RANGER and ranger_heal_visual_radius > 0.0 and ranger_heal_pulse_timer > 0.0:
		var t: float = 1.0 - (ranger_heal_pulse_timer / RANGER_HEAL_PULSE_DURATION)
		var pulse_radius: float = maxf(8.0, ranger_heal_visual_radius * t)
		var alpha: float = clampf(1.0 - t, 0.0, 1.0)
		var particles: int = 24
		for i in range(particles):
			var angle: float = ranger_heal_pulse_phase + TAU * float(i) / float(particles)
			var jitter: float = sin(visual_time * 7.2 + float(i) * 1.37) * 3.2
			var p: Vector2 = Vector2(0.0, bob_y) + Vector2.RIGHT.rotated(angle) * (pulse_radius + jitter)
			var r: float = 1.2 + (1.0 - t) * 0.9
			draw_circle(p, r, Color(1.0, 0.88, 1.0, 0.82 * alpha))
		draw_arc(Vector2(0.0, bob_y), pulse_radius, 0.0, TAU, 56, Color(0.92, 0.66, 1.0, 0.34 * alpha), 2.0)

	if melee_swing_timer > 0.0 and kind != HeroKind.RANGER:
		var swing_t: float = 1.0 - (melee_swing_timer / maxf(melee_swing_duration, 0.001))
		var center_angle: float = melee_swing_direction.angle()
		var start_angle: float = center_angle - melee_swing_half_angle
		var end_angle: float = center_angle + melee_swing_half_angle
		var radius: float = body_radius + (melee_swing_reach - body_radius) * (0.36 + swing_t * 0.28)
		var alpha_swing: float = clampf(1.0 - swing_t, 0.0, 1.0)
		draw_arc(Vector2(0.0, bob_y), radius, start_angle, end_angle, 24, Color(melee_swing_color.r, melee_swing_color.g, melee_swing_color.b, 0.95 * alpha_swing), 3.0)
	if melee_swing_secondary_timer > 0.0 and kind == HeroKind.ROGUE:
		var swing_t2: float = 1.0 - (melee_swing_secondary_timer / maxf(melee_swing_duration * 0.92, 0.001))
		var center_angle2: float = melee_swing_secondary_direction.angle()
		var start_angle2: float = center_angle2 - melee_swing_secondary_half_angle
		var end_angle2: float = center_angle2 + melee_swing_secondary_half_angle
		var radius2: float = body_radius + (melee_swing_secondary_reach - body_radius) * (0.34 + swing_t2 * 0.24)
		var alpha_swing2: float = clampf(1.0 - swing_t2, 0.0, 1.0)
		draw_arc(Vector2(0.0, bob_y), radius2, start_angle2, end_angle2, 24, Color(melee_swing_secondary_color.r, melee_swing_secondary_color.g, melee_swing_secondary_color.b, 0.84 * alpha_swing2), 2.5)

	if is_player_controlled and health > 0.0:
		draw_arc(Vector2(0.0, bob_y), body_radius + 14.0, 0.0, TAU, 24, Color(0.8, 0.96, 1.0, 0.75), 2.5)

	if switch_flash_timer > 0.0 and health > 0.0:
		var t: float = switch_flash_timer / 0.24
		var pulse_radius: float = body_radius + 8.0 + (1.0 - t) * 22.0
		var pulse_color: Color = Color(1.0, 0.96, 0.62, 0.45 * t)
		draw_arc(Vector2(0.0, bob_y), pulse_radius, 0.0, TAU, 36, pulse_color, 6.0 * t)

	if kind == HeroKind.KNIGHT and tank_heavy_attack_unlocked and tank_heavy_charge_timer > 0.0 and health > 0.0:
		var charge_t: float = tank_heavy_charge_timer / TANK_HEAVY_CHARGE_TIME
		var charge_radius: float = body_radius + 20.0 + (1.0 - charge_t) * 18.0
		draw_arc(Vector2(0.0, bob_y), charge_radius, 0.0, TAU, 40, Color(0.72, 0.9, 1.0, 0.5 * (1.0 - charge_t)), 3.0)

	var bar_width := 38.0
	var bar_height := 5.0
	var bar_pos := Vector2(-bar_width * 0.5, -body_radius - 14.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.08, 0.08, 0.08, 0.85), true)

	if health > 0.0:
		var ratio: float = clampf(health_ratio(), 0.0, 1.0)
		var fill := Vector2(bar_width * ratio, bar_height)
		var fill_color: Color = Color(1.0 - ratio, 0.3 + ratio * 0.6, 0.25)
		draw_rect(Rect2(bar_pos, fill), fill_color, true)
