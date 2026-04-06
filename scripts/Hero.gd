extends Node2D
class_name Hero

enum HeroKind { KNIGHT, RANGER, ROGUE }
const HERO_ANIM_NAME := "idle"
const HERO_SHEET_FRAME_COUNT := 8
const KNIGHT_SPRITE_PATH := "res://assets/heroes/tank_idle.png"
const RANGER_SPRITE_PATH := "res://assets/heroes/ranger_idle.png"
const ROGUE_SPRITE_PATH := "res://assets/heroes/rogue_idle.png"
const HERO_SIZE_MULT := 1.4
const HERO_UNIFORM_BASE_SCALE := Vector2(0.98, 0.98)
const HERO_MOVE_SPEED_MULT := 1.04
const HERO_DAMAGE_MULT := 1.42

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
var hero_sprite: AnimatedSprite2D = null
var facing_left: bool = false

var rogue_halo_damage_bonus_mult: float = 0.0
var rogue_halo_speed_bonus_mult: float = 0.0
var ranger_heal_visual_radius: float = 0.0
var ranger_heal_pulse_timer: float = 0.0
var ranger_heal_pulse_phase: float = 0.0

const ROGUE_ASSIST_TRIGGER_RATIO := 0.73
const ROGUE_ASSIST_THREAT_RADIUS := 225.0
const ROGUE_GUARD_PADDING := 40.0
const ROGUE_ANCHOR_TOLERANCE := 12.0
const ROGUE_TOO_CLOSE_MULT := 0.8
const ROGUE_GUARD_LOCK_DURATION := 0.65
const ROGUE_GUARD_SWAP_HEALTH_MARGIN := 0.08
const HERO_COHESION_DISTANCE := 195.0
const HERO_REJOIN_DISTANCE := 275.0
const HERO_DODGE_PADDING := 26.0
const RANGER_HEAL_PULSE_DURATION := 0.56
const PARTY_SOFT_RADIUS := 165.0
const PARTY_HARD_RADIUS := 245.0
const PARTY_COHESION_BLEND := 0.68
const HEALER_ANCHOR_SOFT_MIN := 120.0
const HEALER_ANCHOR_HARD_MIN := 180.0
const HEALER_ANCHOR_BLEND := 0.74
const WALL_SLIDE_MARGIN := 18.0

var rogue_guard_ally: Hero = null
var rogue_guard_lock_timer: float = 0.0
var rogue_velocity_smooth: Vector2 = Vector2.ZERO

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
	visual_time = randf() * 100.0
	rogue_halo_damage_bonus_mult = 0.0
	rogue_halo_speed_bonus_mult = 0.0
	ranger_heal_visual_radius = 0.0
	ranger_heal_pulse_timer = 0.0
	ranger_heal_pulse_phase = randf() * TAU
	facing_left = false
	_ensure_hero_sprite()
	_sync_hero_sprite_visuals()
	queue_redraw()

func process_tick(delta: float, enemies: Array[Enemy], heroes: Array[Hero], arena_rect: Rect2, projectile_spawns: Array[Dictionary], player_move_input: Vector2) -> void:
	if health <= 0.0:
		return

	attack_timer = maxf(0.0, attack_timer - delta)
	rogue_guard_lock_timer = maxf(0.0, rogue_guard_lock_timer - delta)

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
	if velocity.length() > move_speed * 1.45:
		velocity = velocity.normalized() * move_speed * 1.45
	_update_facing_from_velocity(velocity)
	velocity = _apply_wall_slide(velocity, arena_rect)

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

	if velocity.length() > move_speed * 1.45:
		velocity = velocity.normalized() * move_speed * 1.45
	_update_facing_from_velocity(velocity)
	velocity = _apply_wall_slide(velocity, arena_rect)

	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)

func _try_attack(target: Enemy, enemies: Array[Enemy], projectile_spawns: Array[Dictionary]) -> void:
	if target == null:
		return
	if attack_timer > 0.0:
		return

	var distance: float = global_position.distance_to(target.global_position)
	if kind == HeroKind.RANGER:
		if distance > attack_range + 26.0:
			return
	else:
		if distance > attack_range + body_radius + 4.0:
			return

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
	if kind == HeroKind.RANGER:
		var shot_speed: float = 540.0 if has_halo else 438.0
		projectile_spawns.append({
			"team": "hero",
			"position": global_position,
			"target_position": target.global_position,
			"damage": dealt_damage,
			"speed": shot_speed,
			"radius": 5.0,
			"life": 2.0,
			"color": Color(0.98, 0.46, 0.92),
			"homing_target": target,
			"homing_turn_rate": 6.0 if has_halo else 4.2
		})
		attack_timer = attack_cooldown * (0.86 if has_halo else 1.0)
		return

	var attack_dir: Vector2 = (target.global_position - global_position).normalized()
	if attack_dir.length_squared() <= 0.0001:
		attack_dir = Vector2.RIGHT
	_update_facing_from_velocity(attack_dir)

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
	if hit_count > 0 and kind == HeroKind.KNIGHT and has_halo:
		for enemy: Enemy in enemies:
			if enemy.health <= 0.0:
				continue
			if global_position.distance_to(enemy.global_position) <= melee_reach:
				enemy.apply_pull_towards(global_position, 20.0)

	var cooldown_mult := 1.0
	if has_halo and kind == HeroKind.ROGUE:
		cooldown_mult = 0.56
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
		enemy.take_damage(damage)
		hit_count += 1

	return hit_count

func _start_melee_swing(dir: Vector2, reach: float, half_angle: float, color: Color) -> void:
	melee_swing_timer = melee_swing_duration
	melee_swing_direction = dir.normalized()
	melee_swing_reach = reach
	melee_swing_half_angle = half_angle
	melee_swing_color = color
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
	frames.set_animation_speed(HERO_ANIM_NAME, 10.0)
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
	if velocity.x > 0.01:
		facing_left = false
	elif velocity.x < -0.01:
		facing_left = true
	_sync_hero_sprite_visuals()

func _sync_hero_sprite_visuals() -> void:
	if hero_sprite == null:
		return
	hero_sprite.flip_h = facing_left
	if health <= 0.0:
		hero_sprite.modulate = Color(0.34, 0.34, 0.34, 0.95)
	else:
		hero_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

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
	if switch_flash_timer > 0.0:
		switch_flash_timer = maxf(0.0, switch_flash_timer - delta)
		need_redraw = true
	if ranger_heal_pulse_timer > 0.0:
		ranger_heal_pulse_timer = maxf(0.0, ranger_heal_pulse_timer - delta)
		need_redraw = true
	if melee_swing_timer > 0.0:
		melee_swing_timer = maxf(0.0, melee_swing_timer - delta)
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
	if draw_body:
		draw_circle(Vector2.ZERO, body_radius, color)

	if has_halo and health > 0.0:
		draw_arc(Vector2.ZERO, body_radius + 8.0, 0.0, TAU, 36, Color(1.0, 0.95, 0.45), 4.0)
		draw_circle(Vector2.ZERO, body_radius + 3.0, Color(1.0, 0.95, 0.45, 0.2))

	if kind == HeroKind.RANGER and ranger_heal_visual_radius > 0.0 and ranger_heal_pulse_timer > 0.0:
		var t: float = 1.0 - (ranger_heal_pulse_timer / RANGER_HEAL_PULSE_DURATION)
		var pulse_radius: float = maxf(8.0, ranger_heal_visual_radius * t)
		var alpha: float = clampf(1.0 - t, 0.0, 1.0)
		var particles: int = 24
		for i in range(particles):
			var angle: float = ranger_heal_pulse_phase + TAU * float(i) / float(particles)
			var jitter: float = sin(visual_time * 7.2 + float(i) * 1.37) * 3.2
			var p: Vector2 = Vector2.RIGHT.rotated(angle) * (pulse_radius + jitter)
			var r: float = 1.2 + (1.0 - t) * 0.9
			draw_circle(p, r, Color(1.0, 0.88, 1.0, 0.82 * alpha))
		draw_arc(Vector2.ZERO, pulse_radius, 0.0, TAU, 56, Color(0.92, 0.66, 1.0, 0.34 * alpha), 2.0)

	if melee_swing_timer > 0.0 and kind != HeroKind.RANGER:
		var swing_t: float = 1.0 - (melee_swing_timer / maxf(melee_swing_duration, 0.001))
		var center_angle: float = melee_swing_direction.angle()
		var start_angle: float = center_angle - melee_swing_half_angle
		var end_angle: float = center_angle + melee_swing_half_angle
		var radius: float = body_radius + (melee_swing_reach - body_radius) * (0.36 + swing_t * 0.28)
		var alpha_swing: float = clampf(1.0 - swing_t, 0.0, 1.0)
		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 24, Color(melee_swing_color.r, melee_swing_color.g, melee_swing_color.b, 0.95 * alpha_swing), 3.0)

	if is_player_controlled and health > 0.0:
		draw_arc(Vector2.ZERO, body_radius + 14.0, 0.0, TAU, 24, Color(0.8, 0.96, 1.0, 0.75), 2.5)

	if switch_flash_timer > 0.0 and health > 0.0:
		var t: float = switch_flash_timer / 0.24
		var pulse_radius: float = body_radius + 8.0 + (1.0 - t) * 22.0
		var pulse_color: Color = Color(1.0, 0.96, 0.62, 0.45 * t)
		draw_arc(Vector2.ZERO, pulse_radius, 0.0, TAU, 36, pulse_color, 6.0 * t)

	var bar_width := 38.0
	var bar_height := 5.0
	var bar_pos := Vector2(-bar_width * 0.5, -body_radius - 14.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.08, 0.08, 0.08, 0.85), true)

	if health > 0.0:
		var ratio: float = clampf(health_ratio(), 0.0, 1.0)
		var fill := Vector2(bar_width * ratio, bar_height)
		var fill_color: Color = Color(1.0 - ratio, 0.3 + ratio * 0.6, 0.25)
		draw_rect(Rect2(bar_pos, fill), fill_color, true)
