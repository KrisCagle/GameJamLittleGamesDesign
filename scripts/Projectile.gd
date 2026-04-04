extends Node2D
class_name Projectile

enum Team { HERO, ENEMY }

var team: int = Team.HERO
var velocity: Vector2 = Vector2.ZERO
var damage: float = 1.0
var radius: float = 5.0
var ttl: float = 2.0
var body_color: Color = Color(1.0, 1.0, 1.0)

var homing_target: Node2D = null
var homing_turn_rate: float = 0.0

func configure_from_data(data: Dictionary) -> void:
	var spawn_position: Vector2 = data.get("position", Vector2.ZERO)
	var target_position: Vector2 = data.get("target_position", spawn_position + Vector2.RIGHT)
	var speed: float = data.get("speed", 380.0)
	damage = data.get("damage", 8.0)
	radius = data.get("radius", 5.0)
	ttl = data.get("life", 2.0)
	body_color = data.get("color", Color(1.0, 1.0, 1.0))

	var team_name: String = str(data.get("team", "hero"))
	team = Team.ENEMY if team_name == "enemy" else Team.HERO

	homing_target = null
	homing_turn_rate = float(data.get("homing_turn_rate", 0.0))
	var target_candidate: Variant = data.get("homing_target", null)
	if target_candidate is Node2D:
		homing_target = target_candidate

	global_position = spawn_position
	var direction: Vector2 = target_position - spawn_position
	if direction.length_squared() <= 0.0001:
		direction = Vector2.RIGHT
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	queue_redraw()

func process_tick(delta: float, extended_arena: Rect2) -> bool:
	if homing_target != null and is_instance_valid(homing_target) and homing_turn_rate > 0.0:
		var desired_dir: Vector2 = (homing_target.global_position - global_position).normalized()
		if desired_dir.length_squared() > 0.0001:
			var current_dir: Vector2 = velocity.normalized()
			var turn_lerp: float = clampf(homing_turn_rate * delta, 0.0, 1.0)
			var new_dir: Vector2 = current_dir.slerp(desired_dir, turn_lerp).normalized()
			velocity = new_dir * velocity.length()

	global_position += velocity * delta
	rotation = velocity.angle()
	ttl = maxf(0.0, ttl - delta)
	if ttl <= 0.0:
		return false
	if not extended_arena.has_point(global_position):
		return false
	queue_redraw()
	return true

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, body_color)
	draw_circle(Vector2.ZERO, radius + 2.0, Color(body_color.r, body_color.g, body_color.b, 0.22))
