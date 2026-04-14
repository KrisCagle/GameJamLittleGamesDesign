extends Node2D
class_name Projectile

enum Team { HERO, ENEMY }
const ENEMY_RANGED_PROJECTILE_SHEET_PATH := "res://assets/enemies/enemy_ranged_projectile_attack.png"
const ENEMY_RANGED_PROJECTILE_ANIM := "attack"
const ENEMY_RANGED_PROJECTILE_FRAME_COUNT := 5
const HERO_ARROW_SHEET_PATH := "res://assets/projectiles/arrow_sheet5.png"
const HERO_ARROW_ANIM := "fly"
const HERO_ARROW_FRAME_COUNT := 5

var team: int = Team.HERO
var velocity: Vector2 = Vector2.ZERO
var damage: float = 1.0
var radius: float = 5.0
var ttl: float = 2.0
var body_color: Color = Color(1.0, 1.0, 1.0)
var style: String = ""

var homing_target: Node2D = null
var homing_turn_rate: float = 0.0
var projectile_sprite: AnimatedSprite2D = null

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
	style = str(data.get("style", ""))

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
	_setup_projectile_visual()
	if projectile_sprite == null:
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
	if projectile_sprite == null:
		queue_redraw()
	return true

func _draw() -> void:
	if projectile_sprite != null:
		return
	draw_circle(Vector2.ZERO, radius, body_color)
	draw_circle(Vector2.ZERO, radius + 2.0, Color(body_color.r, body_color.g, body_color.b, 0.22))

func _setup_projectile_visual() -> void:
	if style == "enemy_ranged" and team == Team.ENEMY:
		var enemy_texture: Texture2D = load(ENEMY_RANGED_PROJECTILE_SHEET_PATH)
		if enemy_texture == null:
			return
		_setup_sheet_projectile_sprite(enemy_texture, ENEMY_RANGED_PROJECTILE_ANIM, ENEMY_RANGED_PROJECTILE_FRAME_COUNT, 10.5, Vector2(1.95, 1.95), Color(1.0, 0.96, 0.94, 1.0))
		return
	if style == "enemy_thrower" and team == Team.ENEMY:
		var thrower_texture: Texture2D = load(ENEMY_RANGED_PROJECTILE_SHEET_PATH)
		if thrower_texture == null:
			return
		_setup_sheet_projectile_sprite(thrower_texture, ENEMY_RANGED_PROJECTILE_ANIM, ENEMY_RANGED_PROJECTILE_FRAME_COUNT, 9.1, Vector2(2.2, 2.2), Color(1.0, 0.86, 0.82, 1.0))
		return
	if style == "hero_arrow" and team == Team.HERO:
		var hero_texture: Texture2D = load(HERO_ARROW_SHEET_PATH)
		if hero_texture == null:
			return
		_setup_sheet_projectile_sprite(hero_texture, HERO_ARROW_ANIM, HERO_ARROW_FRAME_COUNT, 14.0, Vector2(2.05, 2.05), Color(1.0, 0.98, 0.95, 1.0))
		return

func _setup_sheet_projectile_sprite(texture: Texture2D, anim_name: String, fallback_frame_count: int, anim_speed: float, sprite_scale: Vector2, tint: Color) -> void:
	if texture == null:
		return
	var frame_h: int = texture.get_height()
	var frame_count: int = fallback_frame_count
	if frame_count <= 0 or texture.get_width() % frame_count != 0:
		frame_count = maxi(1, int(round(float(texture.get_width()) / maxf(float(texture.get_height()), 1.0))))
	var frame_w: int = int(floor(float(texture.get_width()) / float(frame_count)))
	if frame_w <= 0 or frame_h <= 0:
		return

	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, true)
	frames.set_animation_speed(anim_name, anim_speed)
	for i in range(frame_count):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
		atlas.filter_clip = true
		frames.add_frame(anim_name, atlas)

	projectile_sprite = AnimatedSprite2D.new()
	projectile_sprite.name = "ProjectileSprite"
	projectile_sprite.centered = true
	projectile_sprite.z_index = 6
	projectile_sprite.sprite_frames = frames
	projectile_sprite.animation = anim_name
	projectile_sprite.scale = sprite_scale
	projectile_sprite.modulate = tint
	add_child(projectile_sprite)
	projectile_sprite.play(anim_name)
