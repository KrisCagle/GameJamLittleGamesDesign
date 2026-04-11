extends Node2D
class_name Enemy
signal impact(position: Vector2, intensity: float)

enum EnemyKind { SWARM, RANGED, ELITE, BOSS }
const SWARM_SPRITE_PATH := "res://assets/enemies/enemy_swarm_attack.webp"
const SWARM_ANIM_NAME := "attack"
const RANGED_WALK_SPRITE_PATH := "res://assets/enemies/enemy_ranged_walk.png"
const RANGED_ATTACK_SPRITE_PATH := "res://assets/enemies/enemy_ranged_attack.png"
const RANGED_ANIM_WALK := "walk"
const RANGED_ANIM_ATTACK := "attack"
const RANGED_FRAME_COUNT := 5
const RANGED_FLIP_THRESHOLD := 0.14
const ENEMY_SIZE_MULT := 1.34
const ENEMY_MOVE_SPEED_MULT := 0.88
const ENEMY_HIT_FLASH_DURATION := 0.11
const SHOW_ENEMY_HEALTH_BARS := false

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
var strafe_dir: float = 1.0

var wave_level: int = 1

var elite_window_timer: float = 0.0
var elite_window_duration: float = 0.0
var elite_window_active: bool = false

var boss_aoe_timer: float = 0.0
var boss_summon_timer: float = 0.0
var boss_volley_timer: float = 0.0
var boss_window_timer: float = 0.0
var boss_window_duration: float = 0.0
var boss_window_active: bool = false
var boss_time_alive: float = 0.0
var swarm_sprite: AnimatedSprite2D = null
var ranged_sprite: AnimatedSprite2D = null
var ranged_facing_left: bool = false
var hit_flash_timer: float = 0.0
var hit_flash_strength: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var pending_damage_source: Vector2 = Vector2.ZERO

func configure(enemy_kind: int, spawn_position: Vector2, assigned_target: Hero, wave_strength: int = 1) -> void:
	kind = enemy_kind
	global_position = spawn_position
	target_hero = assigned_target
	wave_level = max(1, wave_strength)

	match kind:
		EnemyKind.SWARM:
			max_health = 28.0 + float(wave_level) * 1.2
			health = max_health
			move_speed = 132.0 + float(wave_level) * 0.9
			attack_range = 22.0
			damage = 7.0 + float(wave_level) * 0.18
			attack_cooldown = 0.78
			body_radius = 8.0
			body_color = Color(0.96, 0.34, 0.34)
			_ensure_swarm_sprite()
			_hide_ranged_sprite()
		EnemyKind.RANGED:
			max_health = 56.0 + float(wave_level) * 1.6
			health = max_health
			move_speed = 88.0 + float(wave_level) * 0.55
			attack_range = 242.0
			damage = 9.5 + float(wave_level) * 0.3
			attack_cooldown = 0.84
			body_radius = 11.0
			body_color = Color(0.98, 0.72, 0.27)
			_hide_swarm_sprite()
			_ensure_ranged_sprite()
		EnemyKind.ELITE:
			max_health = 120.0 + float(wave_level) * 5.2
			health = max_health
			move_speed = 84.0 + float(wave_level) * 0.45
			attack_range = 30.0
			damage = 18.0 + float(wave_level) * 0.65
			attack_cooldown = 1.35
			body_radius = 14.0
			body_color = Color(0.71, 0.44, 1.0)
			elite_window_timer = randf_range(2.2, 3.6)
			elite_window_duration = 0.0
			elite_window_active = false
			_hide_swarm_sprite()
			_hide_ranged_sprite()
		EnemyKind.BOSS:
			max_health = 520.0 + float(max(0, wave_level - 5)) * 28.0
			health = max_health
			move_speed = 62.0
			attack_range = 260.0
			damage = 12.0 + float(max(0, wave_level - 5)) * 0.5
			attack_cooldown = 1.35
			body_radius = 30.0
			body_color = Color(0.9, 0.22, 0.3)
			boss_aoe_timer = randf_range(2.4, 3.3)
			boss_summon_timer = randf_range(5.0, 6.5)
			boss_volley_timer = randf_range(1.35, 1.9)
			boss_window_timer = randf_range(5.4, 7.0)
			boss_window_duration = 0.0
			boss_window_active = false
			boss_time_alive = 0.0
			_hide_swarm_sprite()
			_hide_ranged_sprite()

	attack_timer = randf_range(0.0, attack_cooldown)
	move_speed *= ENEMY_MOVE_SPEED_MULT
	body_radius *= ENEMY_SIZE_MULT
	ranged_facing_left = false
	hit_flash_timer = 0.0
	hit_flash_strength = 0.0
	knockback_velocity = Vector2.ZERO
	pending_damage_source = Vector2.ZERO
	target_refresh_timer = randf_range(1.0, 2.1)
	strafe_dir = -1.0 if randf() < 0.5 else 1.0
	queue_redraw()

func process_tick(delta: float, heroes: Array[Hero], arena_rect: Rect2, projectile_spawns: Array[Dictionary], summon_spawns: Array[Dictionary]) -> void:
	if health <= 0.0:
		return

	attack_timer = maxf(0.0, attack_timer - delta)
	hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
	_update_sprite_flash()
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 360.0 * delta)
	target_refresh_timer -= delta
	if target_refresh_timer <= 0.0:
		_retarget(heroes)
		target_refresh_timer = randf_range(1.1, 2.4)

	if target_hero == null or target_hero.health <= 0.0:
		_retarget(heroes)
	if target_hero == null:
		return

	if kind == EnemyKind.ELITE:
		_update_elite_window(delta)
	if kind == EnemyKind.BOSS:
		_update_boss_window(delta)

	var to_target: Vector2 = target_hero.global_position - global_position
	var dist: float = to_target.length()
	var direction: Vector2 = to_target.normalized() if dist > 0.001 else Vector2.ZERO
	if kind == EnemyKind.SWARM and swarm_sprite != null and absf(direction.x) > 0.01:
		swarm_sprite.flip_h = direction.x < 0.0
	if kind == EnemyKind.RANGED and ranged_sprite != null:
		if direction.x > RANGED_FLIP_THRESHOLD:
			ranged_facing_left = false
		elif direction.x < -RANGED_FLIP_THRESHOLD:
			ranged_facing_left = true
		ranged_sprite.flip_h = ranged_facing_left
	var velocity: Vector2 = Vector2.ZERO

	match kind:
		EnemyKind.SWARM:
			velocity = direction * move_speed
		EnemyKind.RANGED:
			var desired_dist: float = 168.0
			if dist < desired_dist * 0.74:
				velocity = -direction * move_speed
			elif dist > desired_dist * 1.2:
				velocity = direction * move_speed * 0.9
			else:
				var tangent: Vector2 = Vector2(-direction.y, direction.x)
				velocity = tangent * move_speed * strafe_dir * 0.68
		EnemyKind.ELITE:
			if elite_window_active:
				velocity = -direction * move_speed * 0.38
			else:
				velocity = direction * move_speed
		EnemyKind.BOSS:
			var desired_dist: float = 150.0
			if dist > desired_dist * 1.08:
				velocity = direction * move_speed
			elif dist < desired_dist * 0.75:
				velocity = -direction * move_speed * 0.6
			else:
				var tangent_boss: Vector2 = Vector2(-direction.y, direction.x).normalized()
				velocity = tangent_boss * move_speed * strafe_dir * 0.44
			if boss_window_active:
				velocity *= 0.62

	velocity += knockback_velocity
	global_position += velocity * delta
	global_position.x = clampf(global_position.x, arena_rect.position.x + body_radius, arena_rect.end.x - body_radius)
	global_position.y = clampf(global_position.y, arena_rect.position.y + body_radius, arena_rect.end.y - body_radius)
	if kind == EnemyKind.RANGED and ranged_sprite != null:
		_update_ranged_animation_state(velocity)

	if kind == EnemyKind.BOSS:
		boss_time_alive += delta
		boss_aoe_timer = maxf(0.0, boss_aoe_timer - delta)
		boss_summon_timer = maxf(0.0, boss_summon_timer - delta)
		boss_volley_timer = maxf(0.0, boss_volley_timer - delta)

		if boss_aoe_timer <= 0.0:
			_emit_boss_projectile_ring(projectile_spawns)
			var aoe_cooldown: float = maxf(2.1, 3.35 - boss_time_alive * 0.03)
			boss_aoe_timer = aoe_cooldown + randf_range(-0.22, 0.22)

		if boss_summon_timer <= 0.0:
			_queue_boss_summons(summon_spawns)
			var summon_cooldown: float = maxf(2.4, 4.8 - boss_time_alive * 0.06)
			boss_summon_timer = summon_cooldown + randf_range(-0.3, 0.25)

		if boss_volley_timer <= 0.0:
			_spawn_boss_projectile_volley(target_hero, projectile_spawns)
			var volley_cooldown: float = 1.3 if not boss_window_active else 1.85
			boss_volley_timer = volley_cooldown + randf_range(-0.15, 0.12)

	if attack_timer <= 0.0 and dist <= attack_range and target_hero.health > 0.0:
		if kind == EnemyKind.RANGED:
			projectile_spawns.append({
				"team": "enemy",
				"style": "enemy_ranged",
				"position": global_position,
				"target_position": target_hero.global_position,
				"damage": damage,
				"speed": 260.0,
				"radius": 6.2,
				"life": 2.4,
				"color": Color(1.0, 0.76, 0.34)
			})
			_play_ranged_attack_anim()
		elif kind == EnemyKind.SWARM or kind == EnemyKind.ELITE:
			var dealt: float = damage
			if kind == EnemyKind.ELITE and elite_window_active:
				dealt *= 0.75
			target_hero.set_damage_source(global_position)
			target_hero.apply_damage(dealt)
		attack_timer = attack_cooldown

func _update_ranged_animation_state(velocity: Vector2) -> void:
	if ranged_sprite == null:
		return
	if ranged_sprite.animation == RANGED_ANIM_ATTACK:
		if not ranged_sprite.is_playing():
			ranged_sprite.play(RANGED_ANIM_WALK)
		return
	if ranged_sprite.animation != RANGED_ANIM_WALK:
		ranged_sprite.play(RANGED_ANIM_WALK)
	elif not ranged_sprite.is_playing():
		ranged_sprite.play(RANGED_ANIM_WALK)

func _play_ranged_attack_anim() -> void:
	if ranged_sprite == null:
		return
	ranged_sprite.play(RANGED_ANIM_ATTACK)

func _update_sprite_flash() -> void:
	var flash_t: float = 0.0
	if ENEMY_HIT_FLASH_DURATION > 0.0:
		flash_t = clampf(hit_flash_timer / ENEMY_HIT_FLASH_DURATION, 0.0, 1.0)
	var flash_strength: float = flash_t * clampf(0.35 + hit_flash_strength * 0.6, 0.0, 1.0)
	var flash_mod: Color = Color(1.0 + flash_strength * 0.55, 1.0 + flash_strength * 0.36, 1.0 + flash_strength * 0.24, 1.0)
	if swarm_sprite != null:
		swarm_sprite.modulate = flash_mod
	if ranged_sprite != null:
		ranged_sprite.modulate = flash_mod

func _update_elite_window(delta: float) -> void:
	if kind != EnemyKind.ELITE:
		return

	if elite_window_active:
		elite_window_duration = maxf(0.0, elite_window_duration - delta)
		if elite_window_duration <= 0.0:
			elite_window_active = false
			elite_window_timer = randf_range(2.8, 4.2)
	else:
		elite_window_timer = maxf(0.0, elite_window_timer - delta)
		if elite_window_timer <= 0.0:
			elite_window_active = true
			elite_window_duration = randf_range(1.05, 1.6)
	queue_redraw()

func _update_boss_window(delta: float) -> void:
	if kind != EnemyKind.BOSS:
		return

	if boss_window_active:
		boss_window_duration = maxf(0.0, boss_window_duration - delta)
		if boss_window_duration <= 0.0:
			boss_window_active = false
			boss_window_timer = randf_range(6.4, 8.2)
	else:
		boss_window_timer = maxf(0.0, boss_window_timer - delta)
		if boss_window_timer <= 0.0:
			boss_window_active = true
			boss_window_duration = randf_range(2.1, 2.9)
	queue_redraw()

func _retarget(heroes: Array[Hero]) -> void:
	var alive_heroes: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive_heroes.append(hero)

	if alive_heroes.is_empty():
		target_hero = null
		return

	if target_hero != null and target_hero.health > 0.0 and randf() < 0.4:
		return

	var preferred_kind: int = 0
	match kind:
		EnemyKind.SWARM:
			preferred_kind = 0
		EnemyKind.RANGED:
			preferred_kind = 1
		EnemyKind.ELITE:
			preferred_kind = 2
		EnemyKind.BOSS:
			preferred_kind = 0

	for hero: Hero in alive_heroes:
		if hero.kind == preferred_kind and randf() < 0.7:
			target_hero = hero
			return

	target_hero = alive_heroes[randi() % alive_heroes.size()]

func _ensure_swarm_sprite() -> void:
	if swarm_sprite != null:
		swarm_sprite.visible = true
		if not swarm_sprite.is_playing():
			swarm_sprite.play(SWARM_ANIM_NAME)
		return

	var texture: Texture2D = load(SWARM_SPRITE_PATH)
	if texture == null:
		return

	var frame_count: int = maxi(1, int(floor(float(texture.get_width()) / maxf(float(texture.get_height()), 1.0))))
	frame_count = clampi(frame_count, 1, 12)
	var frame_width: int = int(floor(float(texture.get_width()) / float(frame_count)))
	if frame_width <= 0:
		return

	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation(SWARM_ANIM_NAME)
	frames.set_animation_loop(SWARM_ANIM_NAME, true)
	frames.set_animation_speed(SWARM_ANIM_NAME, 7.4)

	for i in range(frame_count):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_width, 0, frame_width, texture.get_height())
		atlas.filter_clip = true
		frames.add_frame(SWARM_ANIM_NAME, atlas)

	swarm_sprite = AnimatedSprite2D.new()
	swarm_sprite.name = "SwarmSprite"
	swarm_sprite.sprite_frames = frames
	swarm_sprite.animation = SWARM_ANIM_NAME
	swarm_sprite.centered = true
	swarm_sprite.z_index = 3
	swarm_sprite.scale = Vector2(1.15, 1.15) * ENEMY_SIZE_MULT
	add_child(swarm_sprite)
	swarm_sprite.play(SWARM_ANIM_NAME)

func _hide_swarm_sprite() -> void:
	if swarm_sprite != null:
		swarm_sprite.visible = false

func _ensure_ranged_sprite() -> void:
	if ranged_sprite != null:
		ranged_sprite.visible = true
		if not ranged_sprite.is_playing():
			ranged_sprite.play(RANGED_ANIM_WALK)
		return

	var walk_texture: Texture2D = load(RANGED_WALK_SPRITE_PATH)
	var attack_texture: Texture2D = load(RANGED_ATTACK_SPRITE_PATH)
	if walk_texture == null or attack_texture == null:
		return

	var walk_frame_width: int = int(floor(float(walk_texture.get_width()) / float(RANGED_FRAME_COUNT)))
	var walk_frame_height: int = walk_texture.get_height()
	var attack_frame_width: int = int(floor(float(attack_texture.get_width()) / float(RANGED_FRAME_COUNT)))
	var attack_frame_height: int = attack_texture.get_height()
	if walk_frame_width <= 0 or walk_frame_height <= 0 or attack_frame_width <= 0 or attack_frame_height <= 0:
		return

	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation(RANGED_ANIM_WALK)
	frames.set_animation_loop(RANGED_ANIM_WALK, true)
	frames.set_animation_speed(RANGED_ANIM_WALK, 6.6)
	for i in range(RANGED_FRAME_COUNT):
		var atlas_walk: AtlasTexture = AtlasTexture.new()
		atlas_walk.atlas = walk_texture
		atlas_walk.region = Rect2(i * walk_frame_width, 0, walk_frame_width, walk_frame_height)
		atlas_walk.filter_clip = true
		frames.add_frame(RANGED_ANIM_WALK, atlas_walk)

	frames.add_animation(RANGED_ANIM_ATTACK)
	frames.set_animation_loop(RANGED_ANIM_ATTACK, false)
	frames.set_animation_speed(RANGED_ANIM_ATTACK, 7.6)
	for i in range(RANGED_FRAME_COUNT):
		var atlas_attack: AtlasTexture = AtlasTexture.new()
		atlas_attack.atlas = attack_texture
		atlas_attack.region = Rect2(i * attack_frame_width, 0, attack_frame_width, attack_frame_height)
		atlas_attack.filter_clip = true
		frames.add_frame(RANGED_ANIM_ATTACK, atlas_attack)

	ranged_sprite = AnimatedSprite2D.new()
	ranged_sprite.name = "RangedSprite"
	ranged_sprite.sprite_frames = frames
	ranged_sprite.animation = RANGED_ANIM_WALK
	ranged_sprite.centered = true
	ranged_sprite.z_index = 3
	ranged_sprite.scale = Vector2(1.24, 1.24) * ENEMY_SIZE_MULT
	add_child(ranged_sprite)
	ranged_sprite.play(RANGED_ANIM_WALK)

func _hide_ranged_sprite() -> void:
	if ranged_sprite != null:
		ranged_sprite.visible = false

func _emit_boss_projectile_ring(projectile_spawns: Array[Dictionary]) -> void:
	var phase: int = clampi(int(floor(boss_time_alive / 18.0)), 0, 5)
	var projectile_count: int = 14 + phase * 2
	var shot_speed: float = 224.0 + float(phase) * 18.0
	var ring_damage: float = 6.8 + float(phase) * 0.9

	for i in range(projectile_count):
		var angle: float = TAU * float(i) / float(projectile_count)
		var shot_dir: Vector2 = Vector2.RIGHT.rotated(angle)
		projectile_spawns.append({
			"team": "enemy",
			"position": global_position,
			"target_position": global_position + shot_dir * 240.0,
			"damage": ring_damage,
			"speed": shot_speed * 0.88,
			"radius": 5.6,
			"life": 2.2,
			"color": Color(1.0, 0.44, 0.34)
		})

func _queue_boss_summons(summon_spawns: Array[Dictionary]) -> void:
	var phase: int = clampi(int(floor(boss_time_alive / 15.0)), 0, 5)
	var summon_count: int = 0
	if boss_time_alive >= 8.0:
		summon_count = 1 + phase
	if boss_time_alive >= 24.0:
		summon_count += 1
	if summon_count <= 0:
		return

	for i in range(summon_count):
		var roll: float = randf()
		var elite_chance: float = minf(0.06 + float(phase) * 0.04, 0.24)
		var ranged_chance: float = minf(0.32 + float(phase) * 0.04, 0.54)
		var summon_kind: int = EnemyKind.SWARM
		if roll < elite_chance:
			summon_kind = EnemyKind.ELITE
		elif roll < elite_chance + ranged_chance:
			summon_kind = EnemyKind.RANGED

		var dir: Vector2 = Vector2.RIGHT.rotated(randf() * TAU)
		var radius: float = randf_range(62.0, 126.0)
		summon_spawns.append({
			"kind": summon_kind,
			"position": global_position + dir * radius
		})

func _spawn_boss_projectile_volley(target: Hero, projectile_spawns: Array[Dictionary]) -> void:
	if target == null:
		return
	var base_dir: Vector2 = (target.global_position - global_position).normalized()
	if base_dir.length_squared() <= 0.0001:
		base_dir = Vector2.RIGHT

	var spread_angles: Array[float] = [-0.2, 0.0, 0.2]
	for angle in spread_angles:
		var shot_dir: Vector2 = base_dir.rotated(angle)
		projectile_spawns.append({
			"team": "enemy",
			"position": global_position,
			"target_position": global_position + shot_dir * 240.0,
			"damage": damage * 0.9,
			"speed": 304.0,
			"radius": 6.2,
			"life": 2.2,
			"color": Color(1.0, 0.4, 0.32)
		})

func set_damage_source(source_position: Vector2) -> void:
	pending_damage_source = source_position

func take_damage(amount: float) -> void:
	var incoming: float = amount
	if kind == EnemyKind.ELITE and elite_window_active:
		incoming *= 1.65
	if kind == EnemyKind.BOSS and boss_window_active:
		incoming *= 1.58
	health = maxf(0.0, health - incoming)
	hit_flash_timer = ENEMY_HIT_FLASH_DURATION
	hit_flash_strength = clampf(incoming / maxf(max_health * 0.16, 0.01), 0.0, 1.2)
	var source_position: Vector2 = pending_damage_source
	pending_damage_source = Vector2.ZERO
	if source_position != Vector2.ZERO and kind != EnemyKind.BOSS:
		var away: Vector2 = global_position - source_position
		if away.length_squared() > 0.0001:
			var knockback_strength: float = 40.0
			match kind:
				EnemyKind.SWARM:
					knockback_strength = 46.0
				EnemyKind.RANGED:
					knockback_strength = 38.0
				EnemyKind.ELITE:
					knockback_strength = 24.0
			knockback_velocity += away.normalized() * knockback_strength
	var impact_intensity: float = 0.44
	if kind == EnemyKind.ELITE:
		impact_intensity = 0.62
	elif kind == EnemyKind.BOSS:
		impact_intensity = 0.8
	emit_signal("impact", global_position, impact_intensity)
	queue_redraw()

func apply_pull_towards(point: Vector2, strength: float) -> void:
	if health <= 0.0:
		return
	if kind == EnemyKind.BOSS:
		return
	var to_point: Vector2 = point - global_position
	if to_point.length_squared() <= 0.0001:
		return
	global_position += to_point.normalized() * strength

func _draw() -> void:
	if health <= 0.0:
		return

	var draw_color: Color = body_color
	if kind == EnemyKind.ELITE and elite_window_active:
		draw_color = Color(1.0, 0.9, 0.45)
	if kind == EnemyKind.BOSS and boss_window_active:
		draw_color = Color(1.0, 0.74, 0.52)
	if hit_flash_timer > 0.0:
		var flash_t: float = hit_flash_timer / ENEMY_HIT_FLASH_DURATION
		var flash_gain: float = clampf(0.42 + hit_flash_strength * 0.45, 0.0, 0.95)
		draw_color = draw_color.lerp(Color(1.0, 0.96, 0.9), flash_gain * flash_t)

	var draw_sprite_body: bool = true
	if kind == EnemyKind.SWARM and swarm_sprite != null and swarm_sprite.visible:
		draw_sprite_body = false
	if kind == EnemyKind.RANGED and ranged_sprite != null and ranged_sprite.visible:
		draw_sprite_body = false
	if draw_sprite_body:
		draw_circle(Vector2.ZERO, body_radius, draw_color)

	if SHOW_ENEMY_HEALTH_BARS:
		var bar_width: float = 24.0
		if kind == EnemyKind.BOSS:
			bar_width = 52.0
		var bar_pos: Vector2 = Vector2(-bar_width * 0.5, -body_radius - 10.0)
		draw_rect(Rect2(bar_pos, Vector2(bar_width, 4.0)), Color(0.08, 0.08, 0.08, 0.8), true)
		var ratio: float = clampf(health / maxf(max_health, 0.01), 0.0, 1.0)
		draw_rect(Rect2(bar_pos, Vector2(bar_width * ratio, 4.0)), Color(0.8, 0.95, 0.3), true)
