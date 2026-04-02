extends Node2D
class_name Projectile

enum Team { HERO, ENEMY }

var team: int = Team.HERO
var velocity: Vector2 = Vector2.ZERO
var damage: float = 1.0
var radius: float = 5.0
var ttl: float = 2.0
var body_color: Color = Color(1.0, 1.0, 1.0)

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

	global_position = spawn_position
	var direction: Vector2 = target_position - spawn_position
	if direction.length_squared() <= 0.0001:
		direction = Vector2.RIGHT
	velocity = direction.normalized() * speed
	rotation = velocity.angle()
	queue_redraw()

func process_tick(delta: float, extended_arena: Rect2) -> bool:
	global_position += velocity * delta
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
