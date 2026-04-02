extends Node2D
class_name Hero

enum HeroKind { KNIGHT, MAGE, ROGUE }

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
var attack_timer: float = 0.0
var pull_pulse_timer: float = 0.0
var switch_flash_timer: float = 0.0

const ROGUE_ASSIST_TRIGGER_RATIO := 0.74
const ROGUE_ASSIST_THREAT_RADIUS := 220.0
const ROGUE_GUARD_PADDING := 42.0
const ROGUE_ANCHOR_TOLERANCE := 10.0
const ROGUE_TOO_CLOSE_MULT := 0.82

func configure(hero_kind: int, spawn_position: Vector2) -> void:
	kind = hero_kind
	global_position = spawn_position

	match kind:
		HeroKind.KNIGHT:
			hero_name = "Knight"
			body_color = Color(0.3, 0.5, 0.95)
			max_health = 260.0
			move_speed = 70.0
			attack_range = 64.0
			attack_damage = 21.0
			attack_cooldown = 0.85
			body_radius = 21.0
			preferred_distance = 80.0
		HeroKind.MAGE:
			hero_name = "Mage"
			body_color = Color(0.95, 0.45, 0.75)
			max_health = 85.0
			move_speed = 80.0
			attack_range = 250.0
			attack_damage = 22.0
			attack_cooldown = 0.62
			body_radius = 14.0
			preferred_distance = 185.0
		HeroKind.ROGUE:
			hero_name = "Rogue"
			body_color = Color(0.3, 0.95, 0.65)
			max_health = 110.0
			move_speed = 195.0
			attack_range = 76.0
			attack_damage = 10.0
			attack_cooldown = 0.3
			body_radius = 13.0
			preferred_distance = 90.0

	health = max_health
	attack_timer = randf_range(0.15, 0.55)
	pull_pulse_timer = randf_range(0.25, 0.75)
	switch_flash_timer = 0.0
	queue_redraw()

func process_tick(delta: float, enemies: Array[Enemy], heroes: Array[Hero], arena_rect: Rect2, projectile_spawns: Array[Dictionary]) -> void:
	if health <= 0.0:
		return

	attack_timer = maxf(0.0, attack_timer - delta)

	var target := _select_movement_target(enemies, heroes)
	_move_by_role(delta, target, heroes, enemies, arena_rect)
	_try_attack(target, enemies, heroes, projectile_spawns)

func _select_movement_target(enemies: Array[Enemy], heroes: Array[Hero]) -> Enemy:
	match kind:
		HeroKind.KNIGHT:
			return _find_nearest_enemy(enemies)
		HeroKind.MAGE:
			return _find_nearest_enemy(enemies)
		HeroKind.ROGUE:
			var ally := _find_ally_needing_help(heroes, enemies)
			if ally != null:
				return _find_enemy_near_point(enemies, ally.global_position)
			return _find_nearest_enemy(enemies)

	return null

func _move_by_role(delta: float, target: Enemy, heroes: Array[Hero], enemies: Array[Enemy], arena_rect: Rect2) -> void:
	var velocity := Vector2.ZERO

	match kind:
		HeroKind.KNIGHT:
			if target != null:
				velocity = (target.global_position - global_position).normalized() * move_speed
			if has_halo:
				velocity *= 1.12
		HeroKind.MAGE:
			if target != null:
				var to_target := target.global_position - global_position
				var dist := to_target.length()
				if dist < preferred_distance * 0.85:
					velocity = -to_target.normalized() * move_speed
				elif dist > preferred_distance * 1.2:
					velocity = to_target.normalized() * move_speed * 0.85
				else:
					var tangent := Vector2(-to_target.y, to_target.x).normalized()
					velocity = tangent * move_speed * 0.65
		HeroKind.ROGUE:
			var ally := _find_ally_needing_help(heroes, enemies)
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
					velocity = (away * 0.8 + tangent_escape * 0.6).normalized() * move_speed * 1.28
				else:
					var to_anchor: Vector2 = anchor - global_position
					var anchor_dist: float = to_anchor.length()
					if anchor_dist > ROGUE_ANCHOR_TOLERANCE:
						var speed_mult: float = 1.45 if has_halo else 1.08
						velocity = to_anchor.normalized() * move_speed * speed_mult
					else:
						var orbit_axis: Vector2 = global_position - anchor
						if orbit_axis.length() <= 0.001:
							orbit_axis = Vector2.RIGHT
						var tangent: Vector2 = Vector2(-orbit_axis.y, orbit_axis.x).normalized()
						velocity = tangent * move_speed * 0.82
			elif target != null:
				velocity = (target.global_position - global_position).normalized() * move_speed * 1.1

	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)

func _try_attack(target: Enemy, enemies: Array[Enemy], heroes: Array[Hero], projectile_spawns: Array[Dictionary]) -> void:
	if target == null:
		return
	if attack_timer > 0.0:
		return

	var distance := global_position.distance_to(target.global_position)
	if kind == HeroKind.MAGE:
		if distance > attack_range + 20.0:
			return
	else:
		if distance > attack_range:
			return

	var damage_mult := 1.0
	if has_halo:
		match kind:
			HeroKind.KNIGHT:
				damage_mult = 1.15
			HeroKind.MAGE:
				damage_mult = 1.7
			HeroKind.ROGUE:
				damage_mult = 1.25

	var dealt_damage: float = attack_damage * damage_mult
	if kind == HeroKind.MAGE:
		var shot_speed: float = 560.0 if has_halo else 460.0
		projectile_spawns.append({
			"team": "hero",
			"position": global_position,
			"target_position": target.global_position,
			"damage": dealt_damage,
			"speed": shot_speed,
			"radius": 5.5,
			"life": 1.8,
			"color": Color(0.98, 0.46, 0.92)
		})
		attack_timer = attack_cooldown
		return

	target.take_damage(dealt_damage)

	# Synergy hooks kept intentionally simple.
	if kind == HeroKind.KNIGHT and has_halo:
		target.apply_pull_towards(global_position, 34.0)
	if kind == HeroKind.ROGUE and has_halo:
		global_position = global_position.move_toward(target.global_position, 42.0)

	var cooldown_mult := 0.7 if (has_halo and kind == HeroKind.ROGUE) else 1.0
	attack_timer = attack_cooldown * cooldown_mult

func _find_nearest_enemy(enemies: Array[Enemy], max_distance: float = -1.0) -> Enemy:
	var best_dist := INF
	var nearest: Enemy = null

	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var dist := global_position.distance_to(enemy.global_position)
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
		var dist := point.distance_to(enemy.global_position)
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

func _nearest_enemy_distance_to_point(enemies: Array[Enemy], point: Vector2) -> float:
	var nearest_dist: float = INF
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		var dist: float = point.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
	return nearest_dist

func _find_most_threatened_ally(heroes: Array[Hero]) -> Hero:
	var result: Hero = null
	var lowest_ratio := INF

	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		var ratio := hero.health / maxf(hero.max_health, 0.01)
		if ratio < lowest_ratio:
			lowest_ratio = ratio
			result = hero

	return result

func apply_damage(amount: float) -> void:
	if health <= 0.0:
		return
	if has_halo:
		return

	health = maxf(0.0, health - amount)
	queue_redraw()

func set_halo(active: bool) -> void:
	if has_halo == active:
		return
	has_halo = active
	queue_redraw()

func trigger_halo_switch_feedback() -> void:
	switch_flash_timer = 0.24
	queue_redraw()

func process_visual_tick(delta: float) -> void:
	if switch_flash_timer <= 0.0:
		return
	switch_flash_timer = maxf(0.0, switch_flash_timer - delta)
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

	pull_pulse_timer = 0.95
	return true

func _draw() -> void:
	var color := body_color
	if health <= 0.0:
		color = Color(0.2, 0.2, 0.2, 0.95)

	draw_circle(Vector2.ZERO, body_radius, color)

	if has_halo and health > 0.0:
		draw_arc(Vector2.ZERO, body_radius + 8.0, 0.0, TAU, 36, Color(1.0, 0.95, 0.45), 4.0)
		draw_circle(Vector2.ZERO, body_radius + 3.0, Color(1.0, 0.95, 0.45, 0.2))

	if switch_flash_timer > 0.0 and health > 0.0:
		var t := switch_flash_timer / 0.24
		var pulse_radius := body_radius + 8.0 + (1.0 - t) * 22.0
		var pulse_color := Color(1.0, 0.96, 0.62, 0.45 * t)
		draw_arc(Vector2.ZERO, pulse_radius, 0.0, TAU, 36, pulse_color, 6.0 * t)

	var bar_width := 38.0
	var bar_height := 5.0
	var bar_pos := Vector2(-bar_width * 0.5, -body_radius - 14.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.08, 0.08, 0.08, 0.85), true)

	if health > 0.0:
		var ratio := clampf(health_ratio(), 0.0, 1.0)
		var fill := Vector2(bar_width * ratio, bar_height)
		var fill_color := Color(1.0 - ratio, 0.3 + ratio * 0.6, 0.25)
		draw_rect(Rect2(bar_pos, fill), fill_color, true)
