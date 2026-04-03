extends Node2D
class_name Enemy

enum EnemyKind { SWARM, RANGED, CHARGER, BOSS }

var kind: int = EnemyKind.SWARM

var max_health: float = 40.0
var health: float = 40.0
var move_speed: float = 100.0
var attack_range: float = 24.0
var damage: float = 8.0
var attack_cooldown: float = 0.8
var body_radius: float = 10.0
var body_color: Color = Color(0.95, 0.4, 0.4)

var target_hero: Hero = null
var attack_timer: float = 0.0
var target_refresh_timer: float = 0.0
var charge_timer: float = 0.0
var charge_burst_timer: float = 0.0
var strafe_dir: float = 1.0

var wave_level: int = 1
var boss_aoe_timer: float = 0.0
var boss_summon_timer: float = 0.0
var boss_time_alive: float = 0.0

func configure(enemy_kind: int, spawn_position: Vector2, assigned_target: Hero, wave_strength: int = 1) -> void:
	kind = enemy_kind
	global_position = spawn_position
	target_hero = assigned_target
	wave_level = max(1, wave_strength)

	match kind:
		EnemyKind.SWARM:
			max_health = 38.0
			health = max_health
			move_speed = 112.0
			attack_range = 21.0
			damage = 8.0
			attack_cooldown = 0.9
			body_radius = 9.0
			body_color = Color(0.95, 0.32, 0.32)
		EnemyKind.RANGED:
			max_health = 58.0
			health = max_health
			move_speed = 84.0
			attack_range = 168.0
			damage = 11.0
			attack_cooldown = 1.25
			body_radius = 11.0
			body_color = Color(0.95, 0.72, 0.25)
		EnemyKind.CHARGER:
			max_health = 82.0
			health = max_health
			move_speed = 96.0
			attack_range = 27.0
			damage = 20.0
			attack_cooldown = 1.8
			body_radius = 13.0
			body_color = Color(0.66, 0.42, 0.98)
		EnemyKind.BOSS:
			max_health = 560.0 + float(max(0, wave_level - 5)) * 28.0
			health = max_health
			move_speed = 62.0
			attack_range = 260.0
			damage = 17.0 + float(max(0, wave_level - 5)) * 0.6
			attack_cooldown = 1.45
			body_radius = 28.0
			body_color = Color(0.9, 0.22, 0.3)
			boss_aoe_timer = randf_range(2.0, 3.1)
			boss_summon_timer = randf_range(3.4, 4.6)
			boss_time_alive = 0.0

	attack_timer = randf_range(0.0, attack_cooldown)
	target_refresh_timer = randf_range(1.0, 2.1)
	charge_timer = randf_range(1.6, 2.8)
	strafe_dir = -1.0 if randf() < 0.5 else 1.0
	queue_redraw()

func process_tick(delta: float, heroes: Array[Hero], arena_rect: Rect2, projectile_spawns: Array[Dictionary], summon_spawns: Array[Dictionary]) -> void:
	if health <= 0.0:
		return

	attack_timer = maxf(0.0, attack_timer - delta)
	target_refresh_timer -= delta
	if target_refresh_timer <= 0.0:
		_retarget(heroes)
		target_refresh_timer = randf_range(1.1, 2.6)

	if target_hero == null or target_hero.health <= 0.0:
		_retarget(heroes)
	if target_hero == null:
		return

	var to_target := target_hero.global_position - global_position
	var dist := to_target.length()
	var direction := to_target.normalized() if dist > 0.001 else Vector2.ZERO
	var velocity := Vector2.ZERO

	match kind:
		EnemyKind.SWARM:
			velocity = direction * move_speed
		EnemyKind.RANGED:
			var desired_dist := 155.0
			if dist < desired_dist * 0.75:
				velocity = -direction * move_speed
			elif dist > desired_dist * 1.2:
				velocity = direction * move_speed * 0.9
			else:
				var tangent := Vector2(-direction.y, direction.x)
				velocity = tangent * move_speed * strafe_dir * 0.65
		EnemyKind.CHARGER:
			charge_timer -= delta
			if charge_timer <= 0.0:
				charge_burst_timer = 0.42
				charge_timer = randf_range(2.2, 3.5)
			if charge_burst_timer > 0.0:
				charge_burst_timer = maxf(0.0, charge_burst_timer - delta)
				velocity = direction * move_speed * 2.35
			else:
				velocity = direction * move_speed
		EnemyKind.BOSS:
			var desired_dist := 146.0
			if dist > desired_dist * 1.1:
				velocity = direction * move_speed
			elif dist < desired_dist * 0.72:
				velocity = -direction * move_speed * 0.56
			else:
				var tangent := Vector2(-direction.y, direction.x).normalized()
				velocity = tangent * move_speed * strafe_dir * 0.42

	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)

	if kind == EnemyKind.BOSS:
		boss_time_alive += delta
		boss_aoe_timer = maxf(0.0, boss_aoe_timer - delta)
		boss_summon_timer = maxf(0.0, boss_summon_timer - delta)

		if boss_aoe_timer <= 0.0:
			_emit_boss_projectile_ring(projectile_spawns)
			var aoe_cooldown: float = maxf(1.8, 3.2 - boss_time_alive * 0.05)
			boss_aoe_timer = aoe_cooldown + randf_range(-0.2, 0.22)

		if boss_summon_timer <= 0.0:
			_queue_boss_summons(summon_spawns)
			var summon_cooldown: float = maxf(2.3, 5.0 - boss_time_alive * 0.08)
			boss_summon_timer = summon_cooldown + randf_range(-0.34, 0.28)

	if attack_timer <= 0.0 and dist <= attack_range and target_hero.health > 0.0:
		var dealt: float = damage
		if kind == EnemyKind.CHARGER and charge_burst_timer > 0.0:
			dealt *= 1.35
		if kind == EnemyKind.BOSS:
			_spawn_boss_projectile_volley(target_hero, projectile_spawns)
		elif kind == EnemyKind.RANGED:
			projectile_spawns.append({
				"team": "enemy",
				"position": global_position,
				"target_position": target_hero.global_position,
				"damage": dealt,
				"speed": 340.0,
				"radius": 5.0,
				"life": 2.0,
				"color": Color(1.0, 0.78, 0.32)
			})
		else:
			target_hero.apply_damage(dealt)
		attack_timer = attack_cooldown

func _retarget(heroes: Array[Hero]) -> void:
	var alive_heroes: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive_heroes.append(hero)

	if alive_heroes.is_empty():
		target_hero = null
		return

	if target_hero != null and target_hero.health > 0.0 and randf() < 0.42:
		return

	target_hero = alive_heroes[randi() % alive_heroes.size()]

func _emit_boss_projectile_ring(projectile_spawns: Array[Dictionary]) -> void:
	var phase: int = clampi(int(floor(boss_time_alive / 18.0)), 0, 5)
	var projectile_count: int = 16 + phase * 2
	var shot_speed: float = 250.0 + float(phase) * 24.0
	var ring_damage: float = 8.0 + float(phase) * 1.1

	for i in range(projectile_count):
		var angle: float = TAU * float(i) / float(projectile_count)
		var shot_dir: Vector2 = Vector2.RIGHT.rotated(angle)
		projectile_spawns.append({
			"team": "enemy",
			"position": global_position,
			"target_position": global_position + shot_dir * 220.0,
			"damage": ring_damage,
			"speed": shot_speed,
			"radius": 5.6,
			"life": 2.2,
			"color": Color(1.0, 0.44, 0.34)
		})

func _queue_boss_summons(summon_spawns: Array[Dictionary]) -> void:
	var phase: int = clampi(int(floor(boss_time_alive / 16.0)), 0, 4)
	var summon_count: int = 2 + phase

	for i in range(summon_count):
		var roll: float = randf()
		var charger_chance: float = minf(0.12 + float(phase) * 0.05, 0.34)
		var ranged_chance: float = minf(0.28 + float(phase) * 0.06, 0.5)
		var summon_kind: int = EnemyKind.SWARM
		if roll < charger_chance:
			summon_kind = EnemyKind.CHARGER
		elif roll < charger_chance + ranged_chance:
			summon_kind = EnemyKind.RANGED

		var dir: Vector2 = Vector2.RIGHT.rotated(randf() * TAU)
		var radius: float = randf_range(62.0, 126.0)
		summon_spawns.append({
			"kind": summon_kind,
			"position": global_position + dir * radius
		})

func _spawn_boss_projectile_volley(target: Hero, projectile_spawns: Array[Dictionary]) -> void:
	var base_dir: Vector2 = (target.global_position - global_position).normalized()
	if base_dir.length_squared() <= 0.0001:
		base_dir = Vector2.RIGHT

	var spread_angles: Array[float] = [-0.22, 0.0, 0.22]
	for angle in spread_angles:
		var shot_dir: Vector2 = base_dir.rotated(angle)
		projectile_spawns.append({
			"team": "enemy",
			"position": global_position,
			"target_position": global_position + shot_dir * 220.0,
			"damage": damage,
			"speed": 360.0,
			"radius": 7.0,
			"life": 2.2,
			"color": Color(1.0, 0.4, 0.32)
		})

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	queue_redraw()

func apply_pull_towards(point: Vector2, strength: float) -> void:
	if health <= 0.0:
		return
	if kind == EnemyKind.BOSS:
		return
	var to_point := point - global_position
	if to_point.length_squared() <= 0.0001:
		return
	global_position += to_point.normalized() * strength

func _draw() -> void:
	if health <= 0.0:
		return

	draw_circle(Vector2.ZERO, body_radius, body_color)
	if kind == EnemyKind.BOSS:
		draw_circle(Vector2.ZERO, body_radius + 6.0, Color(1.0, 0.25, 0.24, 0.2))

	var bar_width := 24.0
	if kind == EnemyKind.BOSS:
		bar_width = 48.0
	var bar_pos := Vector2(-bar_width * 0.5, -body_radius - 10.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 4.0)), Color(0.08, 0.08, 0.08, 0.8), true)
	var ratio := clampf(health / maxf(max_health, 0.01), 0.0, 1.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * ratio, 4.0)), Color(0.8, 0.95, 0.3), true)
