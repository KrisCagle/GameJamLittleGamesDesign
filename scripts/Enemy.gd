extends Node2D
class_name Enemy

enum EnemyKind { SWARM, RANGED, CHARGER }

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

func configure(enemy_kind: int, spawn_position: Vector2, assigned_target: Hero) -> void:
	kind = enemy_kind
	global_position = spawn_position
	target_hero = assigned_target

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

	attack_timer = randf_range(0.0, attack_cooldown)
	target_refresh_timer = randf_range(1.0, 2.1)
	charge_timer = randf_range(1.6, 2.8)
	strafe_dir = -1.0 if randf() < 0.5 else 1.0
	queue_redraw()

func process_tick(delta: float, heroes: Array[Hero], arena_rect: Rect2) -> void:
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

	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)

	if attack_timer <= 0.0 and dist <= attack_range and target_hero.health > 0.0:
		var dealt := damage
		if kind == EnemyKind.CHARGER and charge_burst_timer > 0.0:
			dealt *= 1.35
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

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	queue_redraw()

func apply_pull_towards(point: Vector2, strength: float) -> void:
	if health <= 0.0:
		return
	var to_point := point - global_position
	if to_point.length_squared() <= 0.0001:
		return
	global_position += to_point.normalized() * strength

func _draw() -> void:
	if health <= 0.0:
		return

	draw_circle(Vector2.ZERO, body_radius, body_color)

	var bar_width := 24.0
	var bar_pos := Vector2(-bar_width * 0.5, -body_radius - 10.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 4.0)), Color(0.08, 0.08, 0.08, 0.8), true)
	var ratio := clampf(health / maxf(max_health, 0.01), 0.0, 1.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * ratio, 4.0)), Color(0.8, 0.95, 0.3), true)
