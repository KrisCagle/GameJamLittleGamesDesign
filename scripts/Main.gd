extends Node2D

const HeroScript = preload("res://scripts/Hero.gd")
const EnemyScript = preload("res://scripts/Enemy.gd")
const ProjectileScript = preload("res://scripts/Projectile.gd")

const HERO_KNIGHT := 0
const HERO_RANGER := 1
const HERO_ROGUE := 2

const ENEMY_SWARM := 0
const ENEMY_RANGED := 1
const ENEMY_ELITE := 2
const ENEMY_BOSS := 3

const PROJECTILE_TEAM_HERO := 0

const UPGRADE_HALO_FLOW := 0
const UPGRADE_RANGER_REMEDY := 1
const UPGRADE_ROGUE_OVERDRIVE := 2
const UPGRADE_TANK_BASTION := 3
const UPGRADE_FIELD_PATCH := 4
const UPGRADE_HALO_RESERVOIR := 5
const UPGRADE_RANGER_FOCUS := 6
const UPGRADE_TANK_MARCH := 7
const UPGRADE_ROGUE_PRECISION := 8
const UPGRADE_TEAM_TRAINING := 9
const UPGRADE_GOLDEN_SURGE := 10
const UPGRADE_ROGUE_TWIN_FANGS := 11
const UPGRADE_TANK_HEAVY_ATTACK := 12
const UPGRADE_RANGER_TRIPLE_ARROWS := 13

const WORLD_SIZE := Vector2(3200, 2200)
const ARENA_MARGIN := 44.0
const CAMERA_FOLLOW_SMOOTH := 7.5

const HALO_CHARGE_MAX := 130.0
const HALO_DRAIN_PER_SEC := 10.5
const HALO_RECHARGE_PER_SEC := 24.0
const HALO_RECHARGE_DELAY := 3.0
const HALO_MIN_CHARGE_TO_EQUIP := 16.0
const HALO_TOGGLE_LOCK := 0.22
const HALO_SWITCH_FEEDBACK_DURATION := 0.24
const HERO_CARD_FRAME_COUNT := 8
const HERO_CARD_TANK_SHEET := "res://assets/heroes/tank_idle.png"
const HERO_CARD_RANGER_SHEET := "res://assets/heroes/ranger_idle.png"
const HERO_CARD_ROGUE_SHEET := "res://assets/heroes/rogue_idle.png"
const START_MENU_TITLE_FONT_PATH := "res://assets/fonts/Starstruck.ttf"
const FLOOR_TEXTURE_PATH := "res://assets/floor/floor_tileset12.png"
const FLOOR_TEXTURE_CENTER_COVERAGE := 0.9
const FLOOR_TEXTURE_WEB_COVERAGE_MULT := 0.52
const FLOOR_TEXTURE_TILE_WORLD_SIZE := 420.0
const FLOOR_TILE_SIZE := 104.0
const FLOOR_PATTERN_PAD := 220.0
const WALL_FRAME_THICKNESS := 34.0
const VIGNETTE_RINGS := 4
const HERO_CONTRAST_BASE_RADIUS := 34.0
const ATMOS_RAY_COUNT := 4
const ATMOS_RAY_EDGE_INSET := 140.0
const CAMERA_ZOOM_MENU := Vector2(1.0, 1.0)
const CAMERA_ZOOM_GAME := Vector2(1.22, 1.22)
const CAMERA_ZOOM_SMOOTH := 8.5
const WEB_LOW_SPEC_ENABLED := true
const WAVE_BASE_ENEMIES := 30
const WAVE_LINEAR_ENEMIES := 7
const WAVE_SCALING_ENEMIES := 2.2
const WAVE_BOSS_SUPPORT_BASE := 18
const WAVE_BOSS_SUPPORT_PER_WAVE := 4
const WAVE_SPAWN_INTERVAL_START := 0.43
const WAVE_SPAWN_INTERVAL_FLOOR := 0.16
const WAVE_SPAWN_INTERVAL_DECAY := 0.014
const CAMERA_SHAKE_DURATION := 0.16
const CAMERA_SHAKE_DECAY := 26.0
const CAMERA_SHAKE_MAX := 8.0
const TEAM_POWER_TIGHT_RADIUS := 102.0
const TEAM_POWER_SPREAD_RADIUS := 268.0
const TEAM_POWER_SMOOTH := 5.6
const TEAM_POWER_REGEN_THRESHOLD := 0.56
const TEAM_POWER_REGEN_PER_SEC := 1.05
const TEAM_LINK_MAX_DISTANCE := 220.0
const TEAM_LINK_MAX_ALPHA := 0.26
const TEAM_CIRCLE_BASE_RADIUS := 116.0
const TEAM_CIRCLE_MAX_RADIUS := 178.0
const KILL_FLASH_DURATION := 0.24
const ENABLE_SFX := false
const SFX_MIX_RATE := 32000.0
const SFX_BUFFER_LENGTH := 0.16
const SFX_MIN_INTERVAL := 0.035

@onready var heroes_root: Node2D = $Heroes
@onready var enemies_root: Node2D = $Enemies
@onready var projectiles_root: Node2D = $Projectiles
@onready var world_camera: Camera2D = $WorldCamera
@onready var wave_label: Label = $UI/WaveLabel
@onready var threat_label: Label = $UI/ThreatLabel
@onready var hero_status: Label = $UI/HeroStatus
@onready var hint_label: Label = $UI/HintLabel

var arena_rect := Rect2(Vector2(ARENA_MARGIN, ARENA_MARGIN), WORLD_SIZE - Vector2(ARENA_MARGIN * 2.0, ARENA_MARGIN * 2.0))

var heroes: Array[Hero] = []
var enemies: Array[Enemy] = []
var projectiles: Array[Projectile] = []
var projectile_spawns: Array[Dictionary] = []
var summon_spawns: Array[Dictionary] = []

var halo_index: int = -1
var halo_equipped: bool = false
var halo_charge: float = HALO_CHARGE_MAX
var halo_recharge_delay_timer: float = 0.0
var halo_toggle_lock_timer: float = 0.0

var halo_switch_feedback_timer: float = 0.0
var halo_switch_feedback_from: Vector2 = Vector2.ZERO
var halo_switch_feedback_to: Vector2 = Vector2.ZERO

var halo_drain_rate_value: float = HALO_DRAIN_PER_SEC
var halo_recharge_rate_value: float = HALO_RECHARGE_PER_SEC
var halo_recharge_delay_value: float = HALO_RECHARGE_DELAY
var halo_min_activate_charge_value: float = HALO_MIN_CHARGE_TO_EQUIP
var halo_charge_cap: float = HALO_CHARGE_MAX

var wave: int = 0
var elapsed_time: float = 0.0
var upgrades_taken: int = 0

var spawn_remaining: int = 0
var spawn_timer: float = 0.0
var spawning: bool = false
var boss_spawn_pending: bool = false
var waiting_for_next_wave: bool = false
var intermission_timer: float = 0.0

var game_over: bool = false
var start_selection_active: bool = true
var upgrade_phase_active: bool = false
var upgrade_choices: Array[int] = []
var upgrade_levels: Dictionary = {}
var last_upgrade_choices: Array[int] = []

var ranger_halo_heal_amount: float = 14.0
var ranger_halo_heal_radius: float = 165.0
var knight_taunt_radius: float = 240.0
var knight_pull_radius: float = 220.0
var knight_guard_heal_per_sec: float = 4.0
var start_card_frames: Dictionary = {}
var start_menu_title_font: Font = null
var lighting_root: Node2D = null
var light_texture_soft: Texture2D = null
var light_texture_wide: Texture2D = null
var floor_texture: Texture2D = null
var top_glow_lights: Array[PointLight2D] = []
var top_beam_lights: Array[PointLight2D] = []
var hero_lights: Array[PointLight2D] = []
var menu_card_glow_lights: Array[PointLight2D] = []
var menu_card_beam_lights: Array[PointLight2D] = []
var menu_card_far_beam_lights: Array[PointLight2D] = []
var center_ceiling_glow: PointLight2D = null
var center_ceiling_beam: PointLight2D = null
var center_ceiling_core: PointLight2D = null
var center_ceiling_haze: PointLight2D = null
var low_spec_mode: bool = false
var camera_shake_timer: float = 0.0
var camera_shake_strength: float = 0.0
var camera_shake_offset: Vector2 = Vector2.ZERO
var team_power: float = 0.0
var team_power_center: Vector2 = Vector2.ZERO
var team_power_radius: float = TEAM_CIRCLE_BASE_RADIUS
var kill_flashes: Array[Dictionary] = []
var sfx_player: AudioStreamPlayer = null
var sfx_playback: AudioStreamGeneratorPlayback = null
var sfx_cooldown_timer: float = 0.0

func _ready() -> void:
	randomize()
	upgrade_levels[UPGRADE_HALO_FLOW] = 0
	upgrade_levels[UPGRADE_RANGER_REMEDY] = 0
	upgrade_levels[UPGRADE_ROGUE_OVERDRIVE] = 0
	upgrade_levels[UPGRADE_TANK_BASTION] = 0
	upgrade_levels[UPGRADE_FIELD_PATCH] = 0
	upgrade_levels[UPGRADE_HALO_RESERVOIR] = 0
	upgrade_levels[UPGRADE_RANGER_FOCUS] = 0
	upgrade_levels[UPGRADE_TANK_MARCH] = 0
	upgrade_levels[UPGRADE_ROGUE_PRECISION] = 0
	upgrade_levels[UPGRADE_TEAM_TRAINING] = 0
	upgrade_levels[UPGRADE_GOLDEN_SURGE] = 0
	upgrade_levels[UPGRADE_ROGUE_TWIN_FANGS] = 0
	upgrade_levels[UPGRADE_TANK_HEAVY_ATTACK] = 0
	upgrade_levels[UPGRADE_RANGER_TRIPLE_ARROWS] = 0

	_spawn_heroes()
	_load_start_card_textures()
	start_menu_title_font = load(START_MENU_TITLE_FONT_PATH) as Font
	floor_texture = load(FLOOR_TEXTURE_PATH) as Texture2D
	_setup_audio_sfx()
	low_spec_mode = WEB_LOW_SPEC_ENABLED and OS.has_feature("web")
	_setup_lighting_nodes()
	heroes_root.visible = false
	halo_index = -1
	halo_equipped = false
	halo_charge = HALO_CHARGE_MAX
	halo_recharge_delay_timer = 0.0
	halo_toggle_lock_timer = 0.0
	halo_switch_feedback_timer = 0.0
	_sync_halo_state()
	world_camera.position = arena_rect.get_center()
	world_camera.zoom = CAMERA_ZOOM_MENU
	world_camera.limit_left = int(arena_rect.position.x)
	world_camera.limit_top = int(arena_rect.position.y)
	world_camera.limit_right = int(arena_rect.end.x)
	world_camera.limit_bottom = int(arena_rect.end.y)
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	sfx_cooldown_timer = maxf(0.0, sfx_cooldown_timer - delta)

	if start_selection_active:
		_update_kill_flashes(delta)
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if game_over:
		_update_kill_flashes(delta)
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if upgrade_phase_active:
		_update_kill_flashes(delta)
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	elapsed_time += delta
	_update_spawning(delta)
	_update_halo_charge(delta)

	projectile_spawns.clear()
	summon_spawns.clear()
	var player_move_input: Vector2 = _get_player_move_input()
	for hero: Hero in heroes:
		hero.process_visual_tick(delta)
		hero.process_tick(delta, enemies, heroes, arena_rect, projectile_spawns, player_move_input)

	_apply_halo_synergies(delta)
	for enemy: Enemy in enemies:
		enemy.process_tick(delta, heroes, arena_rect, projectile_spawns, summon_spawns)

	_spawn_summoned_enemies_from_queue()
	_spawn_projectiles_from_queue()
	_update_projectiles(delta)
	_cleanup_dead_enemies()
	_validate_halo_target()
	_check_for_game_over()
	_progress_wave_timing(delta)
	_update_team_power(delta)
	_update_kill_flashes(delta)
	_update_dynamic_lighting(delta)
	_update_camera(delta)
	_update_ui()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if start_selection_active:
			match event.keycode:
				KEY_1:
					_choose_starting_hero(0)
				KEY_2:
					_choose_starting_hero(1)
				KEY_3:
					_choose_starting_hero(2)
			return

		if game_over and (event.keycode == KEY_ENTER or event.keycode == KEY_R):
			get_tree().reload_current_scene()
			return

		if upgrade_phase_active:
			return

		match event.keycode:
			KEY_1:
				_set_halo(0, false)
			KEY_2:
				_set_halo(1, false)
			KEY_3:
				_set_halo(2, false)
			KEY_SPACE:
				if halo_equipped:
					_drop_halo_manual()
				else:
					_attempt_halo_reactivate()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not game_over:
		if start_selection_active:
			_choose_starting_hero_from_point(event.position)
			return
		if upgrade_phase_active:
			_choose_upgrade_from_point(event.position)
			return
		var world_point: Vector2 = _screen_to_world(event.position)
		if event.double_click:
			if halo_equipped:
				_drop_halo_manual()
			else:
				_set_halo_from_point(world_point)
				_attempt_halo_reactivate()
			return
		_set_halo_from_point(world_point)

func _spawn_heroes() -> void:
	heroes.clear()
	var c: Vector2 = arena_rect.get_center()

	var knight: Hero = HeroScript.new()
	knight.configure(HERO_KNIGHT, c + Vector2(0.0, -10.0))
	heroes_root.add_child(knight)
	heroes.append(knight)
	_connect_hero_signals(knight)

	var ranger: Hero = HeroScript.new()
	ranger.configure(HERO_RANGER, c + Vector2(-58.0, 44.0))
	heroes_root.add_child(ranger)
	heroes.append(ranger)
	_connect_hero_signals(ranger)

	var rogue: Hero = HeroScript.new()
	rogue.configure(HERO_ROGUE, c + Vector2(58.0, 44.0))
	heroes_root.add_child(rogue)
	heroes.append(rogue)
	_connect_hero_signals(rogue)

func _connect_hero_signals(hero: Hero) -> void:
	if hero == null:
		return
	var cb: Callable = Callable(self, "_on_hero_impact")
	if not hero.impact.is_connected(cb):
		hero.impact.connect(cb)

func _connect_enemy_signals(enemy: Enemy) -> void:
	if enemy == null:
		return
	var cb: Callable = Callable(self, "_on_enemy_impact")
	if not enemy.impact.is_connected(cb):
		enemy.impact.connect(cb)

func _set_halo(index: int, allow_reactivate: bool = true) -> void:
	if index < 0 or index >= heroes.size():
		return
	if heroes[index].health <= 0.0:
		return

	var previous_index: int = halo_index
	halo_index = index

	if not halo_equipped and allow_reactivate:
		_attempt_halo_reactivate(false)

	_sync_halo_state()
	if _can_project_halo() and (previous_index != halo_index or not heroes[halo_index].has_halo):
		_on_halo_switched(previous_index, halo_index)

func _load_start_card_textures() -> void:
	start_card_frames.clear()
	start_card_frames[HERO_KNIGHT] = _load_start_card_preview_frames(HERO_CARD_TANK_SHEET)
	start_card_frames[HERO_RANGER] = _load_start_card_preview_frames(HERO_CARD_RANGER_SHEET)
	start_card_frames[HERO_ROGUE] = _load_start_card_preview_frames(HERO_CARD_ROGUE_SHEET)

func _load_start_card_preview_frames(path: String) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	var sheet: Texture2D = load(path)
	if sheet == null:
		return result

	var frame_count: int = HERO_CARD_FRAME_COUNT
	if sheet.get_width() % HERO_CARD_FRAME_COUNT != 0:
		frame_count = max(1, int(round(float(sheet.get_width()) / maxf(float(sheet.get_height()), 1.0))))
	var frame_w: int = int(floor(float(sheet.get_width()) / float(max(1, frame_count))))
	var frame_h: int = sheet.get_height()
	if frame_w <= 0 or frame_h <= 0:
		result.append(sheet)
		return result

	var sheet_img: Image = sheet.get_image()
	if sheet_img == null or sheet_img.is_empty():
		result.append(sheet)
		return result

	for i in range(max(1, frame_count)):
		var frame_img: Image = Image.create(frame_w, frame_h, false, sheet_img.get_format())
		frame_img.blit_rect(sheet_img, Rect2i(i * frame_w, 0, frame_w, frame_h), Vector2i.ZERO)
		result.append(ImageTexture.create_from_image(frame_img))
	return result

func _create_soft_light_texture(size: int, exponent: float) -> Texture2D:
	var tex_size: int = max(16, size)
	var img: Image = Image.create(tex_size, tex_size, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(float(tex_size - 1) * 0.5, float(tex_size - 1) * 0.5)
	var max_r: float = float(tex_size) * 0.5
	for y in range(tex_size):
		for x in range(tex_size):
			var d: float = Vector2(float(x), float(y)).distance_to(center) / max_r
			var a: float = 0.0
			if d < 1.0:
				a = pow(1.0 - d, exponent)
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	return ImageTexture.create_from_image(img)

func _setup_lighting_nodes() -> void:
	if lighting_root != null and is_instance_valid(lighting_root):
		lighting_root.queue_free()

	top_glow_lights.clear()
	top_beam_lights.clear()
	hero_lights.clear()
	menu_card_glow_lights.clear()
	menu_card_beam_lights.clear()
	menu_card_far_beam_lights.clear()
	center_ceiling_glow = null
	center_ceiling_beam = null
	center_ceiling_core = null
	center_ceiling_haze = null

	if low_spec_mode:
		lighting_root = null
		light_texture_soft = null
		light_texture_wide = null
		return

	lighting_root = Node2D.new()
	lighting_root.name = "Lighting"
	add_child(lighting_root)

	light_texture_soft = _create_soft_light_texture(192, 2.05)
	light_texture_wide = _create_soft_light_texture(192, 1.35)

	for i in range(ATMOS_RAY_COUNT):
		var anchor: Vector2 = _top_light_anchor_position(i)

		var glow: PointLight2D = PointLight2D.new()
		glow.texture = light_texture_soft
		glow.position = anchor + Vector2(0.0, 10.0)
		glow.color = Color(0.72, 0.86, 1.0, 1.0)
		glow.energy = 0.66
		glow.texture_scale = 1.12
		lighting_root.add_child(glow)
		top_glow_lights.append(glow)

		var beam: PointLight2D = PointLight2D.new()
		beam.texture = light_texture_wide
		beam.position = anchor + Vector2(0.0, 320.0)
		beam.scale = Vector2(0.72, 3.75)
		beam.color = Color(0.66, 0.82, 1.0, 1.0)
		beam.energy = 0.44
		beam.texture_scale = 2.0
		lighting_root.add_child(beam)
		top_beam_lights.append(beam)

	# Center "ceiling" light to give the nave a stronger focal atmosphere.
	var center_anchor: Vector2 = Vector2(arena_rect.get_center().x, arena_rect.position.y + 26.0)
	center_ceiling_glow = PointLight2D.new()
	center_ceiling_glow.texture = light_texture_soft
	center_ceiling_glow.position = center_anchor
	center_ceiling_glow.color = Color(0.86, 0.9, 1.0, 1.0)
	center_ceiling_glow.energy = 1.08
	center_ceiling_glow.texture_scale = 1.62
	lighting_root.add_child(center_ceiling_glow)

	center_ceiling_beam = PointLight2D.new()
	center_ceiling_beam.texture = light_texture_wide
	center_ceiling_beam.position = center_anchor + Vector2(0.0, 360.0)
	center_ceiling_beam.scale = Vector2(0.92, 4.85)
	center_ceiling_beam.color = Color(0.78, 0.88, 1.0, 1.0)
	center_ceiling_beam.energy = 0.68
	center_ceiling_beam.texture_scale = 2.48
	lighting_root.add_child(center_ceiling_beam)

	for i in range(3):
		var menu_color: Color = Color(0.34, 0.72, 1.0, 1.0)
		match i:
			1:
				menu_color = Color(0.94, 0.48, 0.82, 1.0)
			2:
				menu_color = Color(0.4, 0.95, 0.72, 1.0)

		var menu_glow: PointLight2D = PointLight2D.new()
		menu_glow.texture = light_texture_soft
		menu_glow.color = menu_color.lightened(0.05)
		menu_glow.texture_scale = 0.98
		menu_glow.energy = 0.0
		menu_glow.z_index = -3
		lighting_root.add_child(menu_glow)
		menu_card_glow_lights.append(menu_glow)

		var menu_beam: PointLight2D = PointLight2D.new()
		menu_beam.texture = light_texture_wide
		menu_beam.color = menu_color
		menu_beam.scale = Vector2(0.78, 5.9)
		menu_beam.texture_scale = 2.35
		menu_beam.energy = 0.0
		menu_beam.z_index = -3
		lighting_root.add_child(menu_beam)
		menu_card_beam_lights.append(menu_beam)

		var menu_far_beam: PointLight2D = PointLight2D.new()
		menu_far_beam.texture = light_texture_wide
		menu_far_beam.color = menu_color.lightened(0.24)
		menu_far_beam.scale = Vector2(1.22, 10.0)
		menu_far_beam.texture_scale = 2.8
		menu_far_beam.energy = 0.0
		menu_far_beam.z_index = -4
		lighting_root.add_child(menu_far_beam)
		menu_card_far_beam_lights.append(menu_far_beam)

	for _i in range(heroes.size()):
		var hl: PointLight2D = PointLight2D.new()
		hl.texture = light_texture_soft
		hl.color = Color(0.62, 0.82, 1.0, 1.0)
		hl.texture_scale = 1.0
		hl.energy = 0.0
		hl.enabled = true
		lighting_root.add_child(hl)
		hero_lights.append(hl)

func _update_dynamic_lighting(_delta: float) -> void:
	if lighting_root == null or not is_instance_valid(lighting_root):
		return

	var t: float = float(Time.get_ticks_msec()) * 0.001
	var in_start_menu: bool = start_selection_active
	for i in range(min(top_glow_lights.size(), ATMOS_RAY_COUNT)):
		var anchor: Vector2 = _top_light_anchor_position(i)
		var pulse: float = 0.92 + 0.1 * sin(t * 1.3 + float(i) * 0.7)
		var glow: PointLight2D = top_glow_lights[i]
		glow.position = anchor + Vector2(0.0, 10.0)
		glow.energy = 0.0 if in_start_menu else 0.64 * pulse

	for i in range(min(top_beam_lights.size(), ATMOS_RAY_COUNT)):
		var anchor: Vector2 = _top_light_anchor_position(i)
		var sway: float = sin(t * 0.62 + float(i) * 0.82) * 6.0
		var beam: PointLight2D = top_beam_lights[i]
		beam.position = anchor + Vector2(sway, 320.0)
		beam.energy = 0.0 if in_start_menu else 0.42 + 0.05 * sin(t * 1.1 + float(i))

	if center_ceiling_glow != null:
		center_ceiling_glow.position = Vector2(arena_rect.get_center().x, arena_rect.position.y + 26.0)
		center_ceiling_glow.energy = 0.0 if in_start_menu else 1.02 + 0.14 * sin(t * 0.88)
	if center_ceiling_beam != null:
		var center_sway: float = sin(t * 0.54) * 4.5
		center_ceiling_beam.position = Vector2(arena_rect.get_center().x + center_sway, arena_rect.position.y + 386.0)
		center_ceiling_beam.energy = 0.0 if in_start_menu else 0.66 + 0.08 * sin(t * 0.7 + 0.6)
	if center_ceiling_core != null:
		var core_sway: float = sin(t * 0.48 + 0.9) * 3.0
		center_ceiling_core.position = Vector2(arena_rect.get_center().x + core_sway, arena_rect.position.y + 398.0)
		center_ceiling_core.energy = 0.0 if in_start_menu else 0.78 + 0.1 * sin(t * 0.95 + 1.1)
	if center_ceiling_haze != null:
		center_ceiling_haze.position = Vector2(arena_rect.get_center().x, arena_rect.position.y + 292.0)
		center_ceiling_haze.energy = 0.0 if in_start_menu else 0.39 + 0.06 * sin(t * 0.6 + 0.3)

	for i in range(min(menu_card_glow_lights.size(), 3)):
		var card_rect_screen: Rect2 = _starting_hero_slot_rect(i)
		var slot_world: Rect2 = _screen_rect_to_world(card_rect_screen)
		var slot_center_x: float = slot_world.get_center().x
		var window_anchor_world: Vector2 = _screen_to_world(card_rect_screen.position + Vector2(card_rect_screen.size.x * 0.5, -96.0))
		var beam_floor_start_y: float = slot_world.end.y + 28.0
		var menu_glow: PointLight2D = menu_card_glow_lights[i]
		var menu_beam: PointLight2D = menu_card_beam_lights[i]
		var menu_far_beam: PointLight2D = menu_card_far_beam_lights[i] if i < menu_card_far_beam_lights.size() else null
		var phase: float = float(i) * 0.9
		var speed_scale: float = 1.0 + float(i) * 0.07
		var breathe_main: float = 0.24 * sin(t * 0.62 * speed_scale + phase)
		var breathe_secondary: float = 0.12 * sin(t * 1.28 * (0.96 + float(i) * 0.05) + phase * 0.72 + 0.8)
		var breathe_micro: float = 0.03 * sin(t * 2.85 * (1.0 + float(i) * 0.03) + phase * 1.1)
		var rand_wobble: float = 0.034 * sin(
			t * (1.46 + float(i) * 0.19) +
			phase * 1.87 +
			0.72 * sin(t * (0.39 + float(i) * 0.03) + float(i) * 2.4)
		)
		var candle_flicker: float = clampf(0.96 + breathe_main + breathe_secondary + breathe_micro + rand_wobble, 0.72, 1.28)

		menu_glow.position = window_anchor_world + Vector2(0.0, 22.0)
		menu_beam.position = Vector2(slot_center_x, beam_floor_start_y + 252.0)
		if menu_far_beam != null:
			menu_far_beam.position = Vector2(slot_center_x, beam_floor_start_y + 790.0)
		if in_start_menu:
			menu_glow.energy = 0.1 * candle_flicker
			menu_beam.energy = 1.3 * candle_flicker
			if menu_far_beam != null:
				menu_far_beam.energy = 1.22 * candle_flicker
		else:
			menu_glow.energy = 0.0
			menu_beam.energy = 0.0
			if menu_far_beam != null:
				menu_far_beam.energy = 0.0

	for i in range(min(hero_lights.size(), heroes.size())):
		var hero: Hero = heroes[i]
		var hl: PointLight2D = hero_lights[i]
		hl.position = hero.global_position + Vector2(0.0, -2.0)

		if start_selection_active or hero.health <= 0.0:
			hl.energy = 0.0
			continue

		if hero.has_halo:
			hl.color = Color(1.0, 0.92, 0.6, 1.0)
			hl.texture_scale = 1.26
			hl.energy = 0.68
		elif hero.is_player_controlled:
			hl.color = Color(0.68, 0.88, 1.0, 1.0)
			hl.texture_scale = 1.04
			hl.energy = 0.34
		else:
			hl.color = Color(0.56, 0.76, 1.0, 1.0)
			hl.texture_scale = 0.86
			hl.energy = 0.16

func _drop_halo_manual() -> void:
	if not halo_equipped:
		return
	if halo_toggle_lock_timer > 0.0:
		return

	halo_equipped = false
	halo_toggle_lock_timer = HALO_TOGGLE_LOCK
	halo_recharge_delay_timer = halo_recharge_delay_value
	_sync_halo_state()

func _attempt_halo_reactivate(with_feedback: bool = true) -> void:
	if halo_equipped:
		return
	if halo_toggle_lock_timer > 0.0:
		return
	if halo_recharge_delay_timer > 0.0:
		return
	if halo_charge < halo_min_activate_charge_value:
		return

	if halo_index < 0 or halo_index >= heroes.size() or heroes[halo_index].health <= 0.0:
		_validate_halo_target()
		if halo_index < 0 or halo_index >= heroes.size() or heroes[halo_index].health <= 0.0:
			return

	halo_equipped = true
	halo_toggle_lock_timer = HALO_TOGGLE_LOCK
	_sync_halo_state()
	if with_feedback:
		_on_halo_switched(halo_index, halo_index)

func _set_halo_from_point(point: Vector2) -> void:
	var closest_index: int = -1
	var best_dist: float = INF

	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		if hero.health <= 0.0:
			continue
		var dist: float = hero.global_position.distance_squared_to(point)
		if dist < best_dist:
			best_dist = dist
			closest_index = i

	if closest_index >= 0:
		_set_halo(closest_index, false)

func _start_wave() -> void:
	wave += 1
	boss_spawn_pending = wave >= 5 and (wave % 5 == 0)
	if boss_spawn_pending:
		spawn_remaining = WAVE_BOSS_SUPPORT_BASE + wave * WAVE_BOSS_SUPPORT_PER_WAVE
	else:
		spawn_remaining = WAVE_BASE_ENEMIES + wave * WAVE_LINEAR_ENEMIES + int(floor(float(wave) * WAVE_SCALING_ENEMIES))
	spawn_timer = 0.18
	spawning = true
	waiting_for_next_wave = false
	upgrade_phase_active = false
	intermission_timer = 0.0
	_set_world_visible_for_upgrade(true)
	_sync_halo_state()

func _update_spawning(delta: float) -> void:
	if not spawning:
		return

	spawn_timer -= delta
	var interval: float = maxf(WAVE_SPAWN_INTERVAL_START - float(wave) * WAVE_SPAWN_INTERVAL_DECAY, WAVE_SPAWN_INTERVAL_FLOOR)
	while spawn_timer <= 0.0 and (spawn_remaining > 0 or boss_spawn_pending):
		if boss_spawn_pending:
			_spawn_boss()
			boss_spawn_pending = false
			spawn_timer += interval * 1.75
		elif spawn_remaining > 0:
			_spawn_enemy()
			spawn_remaining -= 1
			spawn_timer += interval

	if spawn_remaining <= 0 and not boss_spawn_pending:
		spawning = false

func _update_halo_charge(delta: float) -> void:
	halo_toggle_lock_timer = maxf(0.0, halo_toggle_lock_timer - delta)
	halo_switch_feedback_timer = maxf(0.0, halo_switch_feedback_timer - delta)

	if _can_project_halo():
		halo_charge = maxf(0.0, halo_charge - halo_drain_rate_value * delta)
		if halo_charge <= 0.0:
			halo_equipped = false
			halo_toggle_lock_timer = HALO_TOGGLE_LOCK
			halo_recharge_delay_timer = halo_recharge_delay_value + 0.35
	else:
		halo_recharge_delay_timer = maxf(0.0, halo_recharge_delay_timer - delta)
		if halo_recharge_delay_timer <= 0.0:
			halo_charge = minf(halo_charge_cap, halo_charge + halo_recharge_rate_value * delta)

	_sync_halo_state()

func _can_project_halo() -> bool:
	if not halo_equipped:
		return false
	if halo_charge <= 0.0:
		return false
	if halo_index < 0 or halo_index >= heroes.size():
		return false
	var selected: Hero = heroes[halo_index]
	if selected.health <= 0.0:
		return false
	return true

func _on_halo_switched(previous_index: int, new_index: int) -> void:
	if new_index < 0 or new_index >= heroes.size():
		return

	var from_pos: Vector2 = heroes[new_index].global_position
	if previous_index >= 0 and previous_index < heroes.size():
		from_pos = heroes[previous_index].global_position

	halo_switch_feedback_from = from_pos
	halo_switch_feedback_to = heroes[new_index].global_position
	halo_switch_feedback_timer = HALO_SWITCH_FEEDBACK_DURATION
	heroes[new_index].trigger_halo_switch_feedback()
	_add_camera_shake(0.42)
	_play_switch_sfx()

func _sync_halo_state() -> void:
	var can_project: bool = _can_project_halo()
	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		var active: bool = can_project and i == halo_index and hero.health > 0.0
		var control_active: bool = i == halo_index and hero.health > 0.0 and not upgrade_phase_active and not game_over
		hero.set_halo(active)
		hero.set_player_controlled(control_active)
		if hero.kind == HERO_RANGER:
			hero.ranger_heal_visual_radius = ranger_halo_heal_radius if active else 0.0

func _apply_halo_synergies(delta: float) -> void:
	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue

		if hero.kind == HERO_KNIGHT and hero.has_halo:
			for enemy: Enemy in enemies:
				if enemy.health <= 0.0:
					continue
				if hero.global_position.distance_to(enemy.global_position) <= knight_taunt_radius:
					enemy.target_hero = hero
			for ally: Hero in heroes:
				if ally == hero or ally.health <= 0.0:
					continue
				if hero.global_position.distance_to(ally.global_position) <= 155.0:
					ally.heal(knight_guard_heal_per_sec * delta)

		if hero.consume_knight_pull_pulse(delta):
			for enemy: Enemy in enemies:
				if enemy.health <= 0.0:
					continue
				if hero.global_position.distance_to(enemy.global_position) <= knight_pull_radius:
					enemy.apply_pull_towards(hero.global_position, 48.0)

		if hero.kind == HERO_RANGER and hero.consume_ranger_support_pulse(delta):
			hero.trigger_ranger_heal_pulse()
			_apply_ranger_halo_support(hero)

func _apply_ranger_halo_support(ranger: Hero) -> void:
	var best_target: Hero = null
	var lowest_ratio: float = INF

	for ally: Hero in heroes:
		if ally.health <= 0.0:
			continue
		if ranger.global_position.distance_to(ally.global_position) > ranger_halo_heal_radius:
			continue
		var ratio: float = ally.health_ratio()
		if ratio < lowest_ratio:
			lowest_ratio = ratio
			best_target = ally

	if best_target == null:
		return

	best_target.heal(ranger_halo_heal_amount)
	for ally: Hero in heroes:
		if ally == best_target or ally.health <= 0.0:
			continue
		if best_target.global_position.distance_to(ally.global_position) <= 110.0:
			ally.heal(ranger_halo_heal_amount * 0.3)

func _spawn_enemy() -> void:
	var enemy: Enemy = EnemyScript.new()
	var kind: int = _pick_enemy_kind()
	var target: Hero = _pick_spawn_target(kind)
	enemy.configure(kind, _random_spawn_point(), target, wave)
	_connect_enemy_signals(enemy)
	enemies_root.add_child(enemy)
	enemies.append(enemy)

func _spawn_boss() -> void:
	var enemy: Enemy = EnemyScript.new()
	var target: Hero = _pick_spawn_target(ENEMY_BOSS)
	enemy.configure(ENEMY_BOSS, _boss_spawn_point(), target, wave)
	_connect_enemy_signals(enemy)
	enemies_root.add_child(enemy)
	enemies.append(enemy)

func _spawn_summoned_enemies_from_queue() -> void:
	if summon_spawns.is_empty():
		return

	for data: Dictionary in summon_spawns:
		var kind: int = int(data.get("kind", ENEMY_SWARM))
		if kind == ENEMY_BOSS:
			kind = ENEMY_SWARM
		var spawn_pos: Vector2 = data.get("position", _random_spawn_point())
		spawn_pos = _clamp_point_to_arena(spawn_pos)
		var target: Hero = _pick_spawn_target(kind)
		var enemy: Enemy = EnemyScript.new()
		enemy.configure(kind, spawn_pos, target, wave)
		_connect_enemy_signals(enemy)
		enemies_root.add_child(enemy)
		enemies.append(enemy)

	summon_spawns.clear()

func _pick_enemy_kind() -> int:
	var elite_chance: float = minf(0.06 + float(wave) * 0.012, 0.22)
	var ranged_chance: float = minf(0.22 + float(wave) * 0.02, 0.42)
	var roll: float = randf()
	if roll < elite_chance:
		return ENEMY_ELITE
	if roll < elite_chance + ranged_chance:
		return ENEMY_RANGED
	return ENEMY_SWARM

func _pick_spawn_target(enemy_kind: int) -> Hero:
	var alive: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive.append(hero)

	if alive.is_empty():
		return null

	var preferred_kind: int = HERO_KNIGHT
	match enemy_kind:
		ENEMY_SWARM:
			preferred_kind = HERO_KNIGHT
		ENEMY_RANGED:
			preferred_kind = HERO_RANGER
		ENEMY_ELITE:
			preferred_kind = HERO_ROGUE
		ENEMY_BOSS:
			preferred_kind = HERO_KNIGHT

	var preferred: Hero = _find_alive_hero_by_kind(alive, preferred_kind)
	if preferred != null and randf() < 0.74:
		return preferred

	var best: Hero = alive[0]
	var best_score: float = INF
	for hero: Hero in alive:
		var load: int = 0
		for enemy: Enemy in enemies:
			if enemy.health > 0.0 and enemy.target_hero == hero:
				load += 1
		var score: float = float(load) + randf() * 0.45
		if score < best_score:
			best = hero
			best_score = score
	return best

func _find_alive_hero_by_kind(alive: Array[Hero], kind: int) -> Hero:
	for hero: Hero in alive:
		if hero.kind == kind:
			return hero
	return null

func _random_spawn_point() -> Vector2:
	var edge: int = randi() % 4
	var x: float = randf_range(arena_rect.position.x, arena_rect.end.x)
	var y: float = randf_range(arena_rect.position.y, arena_rect.end.y)
	match edge:
		0:
			return Vector2(x, arena_rect.position.y + 6.0)
		1:
			return Vector2(x, arena_rect.end.y - 6.0)
		2:
			return Vector2(arena_rect.position.x + 6.0, y)
		_:
			return Vector2(arena_rect.end.x - 6.0, y)

func _boss_spawn_point() -> Vector2:
	return Vector2(arena_rect.position.x + arena_rect.size.x * 0.5, arena_rect.position.y + 18.0)

func _clamp_point_to_arena(point: Vector2) -> Vector2:
	var x: float = clampf(point.x, arena_rect.position.x + 12.0, arena_rect.end.x - 12.0)
	var y: float = clampf(point.y, arena_rect.position.y + 12.0, arena_rect.end.y - 12.0)
	return Vector2(x, y)

func _cleanup_dead_enemies() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if enemies[i].health <= 0.0:
			var dead_enemy: Enemy = enemies[i]
			_spawn_kill_flash(dead_enemy.global_position, dead_enemy.body_radius)
			_add_camera_shake(0.2 + team_power * 0.45)
			enemies[i].queue_free()
			enemies.remove_at(i)

func _spawn_kill_flash(position: Vector2, body_radius: float) -> void:
	var flash: Dictionary = {
		"position": position,
		"time": KILL_FLASH_DURATION,
		"max_time": KILL_FLASH_DURATION,
		"radius": maxf(16.0, body_radius * 2.5)
	}
	kill_flashes.append(flash)

func _update_kill_flashes(delta: float) -> void:
	for i in range(kill_flashes.size() - 1, -1, -1):
		var flash: Dictionary = kill_flashes[i]
		var time_left: float = float(flash.get("time", 0.0)) - delta
		if time_left <= 0.0:
			kill_flashes.remove_at(i)
			continue
		flash["time"] = time_left
		kill_flashes[i] = flash

func _update_team_power(delta: float) -> void:
	var alive: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive.append(hero)

	if alive.is_empty():
		team_power = 0.0
		team_power_center = arena_rect.get_center()
		team_power_radius = TEAM_CIRCLE_BASE_RADIUS
		return

	var anchor: Vector2 = _camera_target_position()
	if halo_index >= 0 and halo_index < heroes.size():
		var lead: Hero = heroes[halo_index]
		if lead.health > 0.0:
			anchor = lead.global_position
	team_power_center = anchor

	var avg_dist: float = 0.0
	for hero: Hero in alive:
		avg_dist += hero.global_position.distance_to(anchor)
	avg_dist /= float(alive.size())

	var spread_t: float = (avg_dist - TEAM_POWER_TIGHT_RADIUS) / maxf(TEAM_POWER_SPREAD_RADIUS - TEAM_POWER_TIGHT_RADIUS, 0.01)
	var target_power: float = clampf(1.0 - spread_t, 0.0, 1.0)
	team_power = lerpf(team_power, target_power, clampf(delta * TEAM_POWER_SMOOTH, 0.0, 1.0))
	team_power_radius = lerpf(TEAM_CIRCLE_MAX_RADIUS, TEAM_CIRCLE_BASE_RADIUS, team_power)

	for hero: Hero in heroes:
		hero.set_team_power(team_power)

	if team_power > TEAM_POWER_REGEN_THRESHOLD:
		var regen_t: float = (team_power - TEAM_POWER_REGEN_THRESHOLD) / maxf(1.0 - TEAM_POWER_REGEN_THRESHOLD, 0.01)
		var regen_value: float = TEAM_POWER_REGEN_PER_SEC * regen_t * delta
		for hero: Hero in alive:
			hero.heal(regen_value)

func _spawn_projectiles_from_queue() -> void:
	if projectile_spawns.is_empty():
		return
	for data: Dictionary in projectile_spawns:
		var projectile: Projectile = ProjectileScript.new()
		projectile.configure_from_data(data)
		projectiles_root.add_child(projectile)
		projectiles.append(projectile)
	projectile_spawns.clear()

func _update_projectiles(delta: float) -> void:
	if projectiles.is_empty():
		return

	var extended_arena: Rect2 = arena_rect.grow(48.0)
	for i in range(projectiles.size() - 1, -1, -1):
		var projectile: Projectile = projectiles[i]
		var alive: bool = bool(projectile.process_tick(delta, extended_arena))
		var hit: bool = false

		if alive:
			var projectile_pos: Vector2 = projectile.global_position
			var projectile_radius: float = float(projectile.radius)
			var projectile_damage: float = float(projectile.damage)
			var projectile_team: int = int(projectile.team)

			if projectile_team == PROJECTILE_TEAM_HERO:
				for enemy: Enemy in enemies:
					if enemy.health <= 0.0:
						continue
					var impact_dist: float = projectile_radius + enemy.body_radius
					if projectile_pos.distance_squared_to(enemy.global_position) <= impact_dist * impact_dist:
						enemy.set_damage_source(projectile_pos)
						enemy.take_damage(projectile_damage)
						hit = true
						break
			else:
				for hero: Hero in heroes:
					if hero.health <= 0.0:
						continue
					var impact_dist: float = projectile_radius + hero.body_radius
					if projectile_pos.distance_squared_to(hero.global_position) <= impact_dist * impact_dist:
						hero.set_damage_source(projectile_pos)
						hero.apply_damage(projectile_damage)
						hit = true
						break

		if hit or not alive:
			projectile.queue_free()
			projectiles.remove_at(i)

func _validate_halo_target() -> void:
	if halo_index >= 0 and halo_index < heroes.size() and heroes[halo_index].health > 0.0:
		_sync_halo_state()
		return

	for i in range(heroes.size()):
		if heroes[i].health > 0.0:
			halo_index = i
			_sync_halo_state()
			return

	halo_index = -1
	halo_equipped = false
	_sync_halo_state()

func _check_for_game_over() -> void:
	var alive_count: int = 0
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive_count += 1
	if alive_count <= 0:
		game_over = true
		halo_equipped = false
		_sync_halo_state()

func _progress_wave_timing(delta: float) -> void:
	if spawning or game_over:
		return

	if enemies.is_empty() and not waiting_for_next_wave:
		waiting_for_next_wave = true
		_begin_upgrade_phase()

	if waiting_for_next_wave:
		if upgrade_phase_active:
			return
		intermission_timer -= delta
		if intermission_timer <= 0.0:
			_start_wave()

func _begin_upgrade_phase() -> void:
	upgrade_choices = _roll_upgrade_choices()
	if upgrade_choices.is_empty():
		upgrade_phase_active = false
		intermission_timer = 1.0
		_set_world_visible_for_upgrade(true)
		return

	upgrade_phase_active = true
	intermission_timer = 999.0
	_set_world_visible_for_upgrade(false)
	_sync_halo_state()

func _set_world_visible_for_upgrade(visible: bool) -> void:
	heroes_root.visible = visible and not start_selection_active
	enemies_root.visible = visible
	projectiles_root.visible = visible

func _has_alive_hero_kind(kind: int) -> bool:
	for hero: Hero in heroes:
		if hero.health > 0.0 and hero.kind == kind:
			return true
	return false

func _collect_attack_unlock_priority(tank_alive: bool, ranger_alive: bool, rogue_alive: bool) -> Array[int]:
	var priority: Array[int] = []
	if tank_alive and int(upgrade_levels.get(UPGRADE_TANK_HEAVY_ATTACK, 0)) <= 0:
		priority.append(UPGRADE_TANK_HEAVY_ATTACK)
	if ranger_alive and int(upgrade_levels.get(UPGRADE_RANGER_TRIPLE_ARROWS, 0)) <= 0:
		priority.append(UPGRADE_RANGER_TRIPLE_ARROWS)
	if rogue_alive and int(upgrade_levels.get(UPGRADE_ROGUE_TWIN_FANGS, 0)) <= 0:
		priority.append(UPGRADE_ROGUE_TWIN_FANGS)
	return priority

func _roll_upgrade_choices() -> Array[int]:
	var tank_alive: bool = _has_alive_hero_kind(HERO_KNIGHT)
	var ranger_alive: bool = _has_alive_hero_kind(HERO_RANGER)
	var rogue_alive: bool = _has_alive_hero_kind(HERO_ROGUE)

	var pool: Array[int] = []
	# Core halo/pacing cards are always relevant.
	pool.append(UPGRADE_HALO_FLOW)
	pool.append(UPGRADE_FIELD_PATCH)
	pool.append(UPGRADE_HALO_RESERVOIR)
	pool.append(UPGRADE_TEAM_TRAINING)

	if tank_alive:
		pool.append(UPGRADE_TANK_BASTION)
		pool.append(UPGRADE_TANK_MARCH)
		if int(upgrade_levels.get(UPGRADE_TANK_HEAVY_ATTACK, 0)) <= 0:
			pool.append(UPGRADE_TANK_HEAVY_ATTACK)

	if ranger_alive:
		pool.append(UPGRADE_RANGER_REMEDY)
		pool.append(UPGRADE_RANGER_FOCUS)
		if int(upgrade_levels.get(UPGRADE_RANGER_TRIPLE_ARROWS, 0)) <= 0:
			pool.append(UPGRADE_RANGER_TRIPLE_ARROWS)

	if rogue_alive:
		pool.append(UPGRADE_ROGUE_OVERDRIVE)
		pool.append(UPGRADE_ROGUE_PRECISION)
		if int(upgrade_levels.get(UPGRADE_ROGUE_TWIN_FANGS, 0)) <= 0:
			pool.append(UPGRADE_ROGUE_TWIN_FANGS)

	if pool.is_empty():
		return []

	var result: Array[int] = []
	var priority_unlocks: Array[int] = _collect_attack_unlock_priority(tank_alive, ranger_alive, rogue_alive)
	for upgrade_id in priority_unlocks:
		if result.size() >= 3:
			break
		if pool.has(upgrade_id):
			result.append(upgrade_id)
			pool.erase(upgrade_id)

	var preferred: Array[int] = []
	for upgrade_id in pool:
		if not last_upgrade_choices.has(upgrade_id):
			preferred.append(upgrade_id)

	while result.size() < 3 and not preferred.is_empty():
		var pidx: int = randi() % preferred.size()
		var pick: int = preferred[pidx]
		result.append(pick)
		preferred.remove_at(pidx)
		pool.erase(pick)

	while result.size() < 3 and not pool.is_empty():
		var idx: int = randi() % pool.size()
		result.append(pool[idx])
		pool.remove_at(idx)

	if wave > 0 and wave % 5 == 0:
		if not result.has(UPGRADE_GOLDEN_SURGE):
			if result.size() >= 3:
				result[randi() % result.size()] = UPGRADE_GOLDEN_SURGE
			else:
				result.append(UPGRADE_GOLDEN_SURGE)

	last_upgrade_choices = result.duplicate()
	return result

func _starting_hero_slot_rect(slot: int) -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var width: float = 336.0
	var height: float = 220.0
	var gap: float = 24.0
	var total_width: float = width * 3.0 + gap * 2.0
	var start_x: float = (view_size.x - total_width) * 0.5
	var y: float = view_size.y * 0.32
	return Rect2(Vector2(start_x + float(slot) * (width + gap), y), Vector2(width, height))

func _choose_starting_hero_from_point(screen_point: Vector2) -> void:
	if not start_selection_active:
		return
	for i in range(heroes.size()):
		if _starting_hero_slot_rect(i).has_point(screen_point):
			_choose_starting_hero(i)
			return

func _choose_starting_hero(index: int) -> void:
	if not start_selection_active:
		return
	if index < 0 or index >= heroes.size():
		return
	if heroes[index].health <= 0.0:
		return

	start_selection_active = false
	heroes_root.visible = true
	halo_equipped = false
	halo_charge = halo_charge_cap
	halo_recharge_delay_timer = 0.0
	halo_toggle_lock_timer = 0.0
	_set_halo(index, false)
	_start_wave()

func _upgrade_slot_rect(slot: int) -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var width: float = 318.0
	var height: float = 138.0
	var gap: float = 16.0
	var total_width: float = width * 3.0 + gap * 2.0
	var start_x: float = (view_size.x - total_width) * 0.5
	var y: float = (view_size.y - height) * 0.5
	return Rect2(Vector2(start_x + float(slot) * (width + gap), y), Vector2(width, height))

func _camera_target_position() -> Vector2:
	if start_selection_active:
		return arena_rect.get_center()

	if halo_index >= 0 and halo_index < heroes.size() and heroes[halo_index].health > 0.0:
		return heroes[halo_index].global_position

	var alive_positions: Array[Vector2] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive_positions.append(hero.global_position)
	if alive_positions.is_empty():
		return arena_rect.get_center()

	var center := Vector2.ZERO
	for p in alive_positions:
		center += p
	return center / float(alive_positions.size())

func _update_camera(delta: float) -> void:
	var target: Vector2 = _camera_target_position()
	var follow_t: float = clampf(CAMERA_FOLLOW_SMOOTH * delta, 0.0, 1.0)
	world_camera.position = world_camera.position.lerp(target, follow_t)
	var target_zoom: Vector2 = CAMERA_ZOOM_MENU if start_selection_active else CAMERA_ZOOM_GAME
	var zoom_t: float = clampf(CAMERA_ZOOM_SMOOTH * delta, 0.0, 1.0)
	world_camera.zoom = world_camera.zoom.lerp(target_zoom, zoom_t)
	_update_camera_shake(delta)

func _update_camera_shake(delta: float) -> void:
	if camera_shake_timer > 0.0:
		camera_shake_timer = maxf(0.0, camera_shake_timer - delta)
		var t: float = camera_shake_timer / CAMERA_SHAKE_DURATION
		var random_offset: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		var target_offset: Vector2 = random_offset * camera_shake_strength * clampf(t, 0.0, 1.0)
		camera_shake_offset = camera_shake_offset.lerp(target_offset, clampf(delta * 28.0, 0.0, 1.0))
		camera_shake_strength = maxf(0.0, camera_shake_strength - CAMERA_SHAKE_DECAY * delta)
	else:
		camera_shake_offset = camera_shake_offset.lerp(Vector2.ZERO, clampf(delta * 18.0, 0.0, 1.0))
	world_camera.offset = camera_shake_offset

func _add_camera_shake(amount: float) -> void:
	camera_shake_strength = minf(CAMERA_SHAKE_MAX, camera_shake_strength + amount)
	camera_shake_timer = maxf(camera_shake_timer, CAMERA_SHAKE_DURATION)

func _setup_audio_sfx() -> void:
	if not ENABLE_SFX:
		return
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = SFX_MIX_RATE
	generator.buffer_length = SFX_BUFFER_LENGTH
	sfx_player.stream = generator
	sfx_player.volume_db = -12.0
	sfx_player.play()
	sfx_playback = sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _play_hit_sfx(enemy_hit: bool, intensity: float) -> void:
	if not ENABLE_SFX:
		return
	if sfx_playback == null:
		return
	if sfx_cooldown_timer > 0.0:
		return
	sfx_cooldown_timer = SFX_MIN_INTERVAL
	var freq: float = 252.0 if enemy_hit else 176.0
	freq *= 1.0 + randf_range(-0.08, 0.08)
	var dur: float = 0.046 + clampf(intensity, 0.0, 1.0) * 0.028
	var amp: float = (0.26 if enemy_hit else 0.22) * (0.55 + clampf(intensity, 0.0, 1.0) * 0.45)
	_push_sfx_tone(freq, dur, amp)

func _play_switch_sfx() -> void:
	if not ENABLE_SFX:
		return
	if sfx_playback == null:
		return
	_push_sfx_tone(420.0, 0.055, 0.17)

func _push_sfx_tone(freq: float, duration: float, amp: float) -> void:
	if not ENABLE_SFX:
		return
	if sfx_playback == null and sfx_player != null:
		sfx_playback = sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if sfx_playback == null:
		return
	var frame_count: int = int(maxf(1.0, SFX_MIX_RATE * duration))
	if not sfx_playback.can_push_buffer(frame_count):
		return
	var phase: float = 0.0
	var phase_h: float = 0.0
	var phase_inc: float = TAU * freq / SFX_MIX_RATE
	var phase_inc_h: float = TAU * freq * 2.0 / SFX_MIX_RATE
	for i in range(frame_count):
		var t: float = float(i) / float(frame_count)
		var env: float = (1.0 - t)
		env *= env
		var sample: float = sin(phase) * amp * env + sin(phase_h) * amp * 0.22 * env
		sfx_playback.push_frame(Vector2(sample, sample))
		phase += phase_inc
		phase_h += phase_inc_h

func _on_enemy_impact(_position: Vector2, intensity: float) -> void:
	if start_selection_active:
		return
	_add_camera_shake(0.55 + intensity * 0.75)
	_play_hit_sfx(true, intensity)

func _on_hero_impact(_position: Vector2, intensity: float) -> void:
	if start_selection_active:
		return
	_add_camera_shake(0.75 + intensity * 0.95)
	_play_hit_sfx(false, intensity)

func _view_origin() -> Vector2:
	return _screen_to_world(Vector2.ZERO)

func _viewport_rect_world() -> Rect2:
	var size: Vector2 = _viewport_size()
	return Rect2(_view_origin(), size)

func _screen_to_world(screen_point: Vector2) -> Vector2:
	var inv_canvas: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	return inv_canvas * screen_point

func _screen_rect_to_world(screen_rect: Rect2) -> Rect2:
	var p0: Vector2 = _screen_to_world(screen_rect.position)
	var p1: Vector2 = _screen_to_world(screen_rect.position + screen_rect.size)
	return Rect2(p0, p1 - p0).abs()

func _viewport_size() -> Vector2:
	return get_viewport_rect().size

func _wrap_text_lines(text: String, max_chars_per_line: int, max_lines: int) -> Array[String]:
	var words: PackedStringArray = text.split(" ", false)
	var lines: Array[String] = []
	var current: String = ""
	var truncated: bool = false

	for word in words:
		var candidate: String = word if current.is_empty() else current + " " + word
		if candidate.length() > max_chars_per_line and not current.is_empty():
			lines.append(current)
			current = word
			if lines.size() >= max_lines:
				truncated = true
				break
		else:
			current = candidate

	if lines.size() < max_lines and not current.is_empty():
		lines.append(current)
	elif not current.is_empty():
		truncated = true

	if truncated and not lines.is_empty():
		var last_idx: int = lines.size() - 1
		var last_line: String = lines[last_idx].strip_edges()
		if not last_line.ends_with("..."):
			lines[last_idx] = last_line + "..."

	return lines

func _choose_upgrade_from_point(point: Vector2) -> void:
	if not upgrade_phase_active:
		return
	for i in range(upgrade_choices.size()):
		if _upgrade_slot_rect(i).has_point(point):
			_choose_upgrade(i)
			return

func _choose_upgrade(slot: int) -> void:
	if not upgrade_phase_active:
		return
	if slot < 0 or slot >= upgrade_choices.size():
		return

	var upgrade_id: int = upgrade_choices[slot]
	_apply_upgrade(upgrade_id)
	upgrade_phase_active = false
	upgrade_choices.clear()
	intermission_timer = 1.4
	_set_world_visible_for_upgrade(true)
	_sync_halo_state()

func _apply_upgrade(upgrade_id: int) -> void:
	match upgrade_id:
		UPGRADE_HALO_FLOW:
			halo_drain_rate_value = maxf(8.0, halo_drain_rate_value * 0.9)
			halo_recharge_rate_value = minf(42.0, halo_recharge_rate_value * 1.12)
			halo_recharge_delay_value = maxf(1.1, halo_recharge_delay_value - 0.12)
			halo_min_activate_charge_value = maxf(8.0, halo_min_activate_charge_value - 1.4)
		UPGRADE_RANGER_REMEDY:
			ranger_halo_heal_amount += 6.0
			ranger_halo_heal_radius += 32.0
		UPGRADE_ROGUE_OVERDRIVE:
			for hero: Hero in heroes:
				if hero.kind == HERO_ROGUE:
					hero.rogue_halo_damage_bonus_mult += 0.2
					hero.rogue_halo_speed_bonus_mult += 0.06
		UPGRADE_TANK_BASTION:
			knight_taunt_radius += 34.0
			knight_pull_radius += 24.0
			knight_guard_heal_per_sec += 2.0
		UPGRADE_FIELD_PATCH:
			for hero: Hero in heroes:
				if hero.health > 0.0:
					hero.heal(42.0)
					hero.add_max_health(6.0)
		UPGRADE_HALO_RESERVOIR:
			halo_charge_cap += 18.0
			halo_charge = minf(halo_charge_cap, halo_charge + 12.0)
		UPGRADE_RANGER_FOCUS:
			for hero: Hero in heroes:
				if hero.kind == HERO_RANGER:
					hero.attack_damage += 1.1
					hero.attack_cooldown = maxf(0.52, hero.attack_cooldown * 0.93)
		UPGRADE_TANK_MARCH:
			for hero: Hero in heroes:
				if hero.kind == HERO_KNIGHT:
					hero.move_speed += 4.0
					hero.add_max_health(14.0)
		UPGRADE_ROGUE_PRECISION:
			for hero: Hero in heroes:
				if hero.kind == HERO_ROGUE:
					hero.attack_damage += 1.0
					hero.attack_cooldown = maxf(0.2, hero.attack_cooldown * 0.92)
		UPGRADE_TEAM_TRAINING:
			for hero: Hero in heroes:
				hero.move_speed += 2.2
				hero.attack_damage += 0.6
		UPGRADE_GOLDEN_SURGE:
			halo_drain_rate_value = maxf(6.5, halo_drain_rate_value * 0.84)
			halo_recharge_rate_value = minf(52.0, halo_recharge_rate_value * 1.18)
			halo_charge_cap += 24.0
			halo_charge = minf(halo_charge_cap, halo_charge + 20.0)
			for hero: Hero in heroes:
				if hero.health <= 0.0:
					continue
				hero.heal(32.0)
				hero.move_speed += 3.0
				hero.attack_damage += 1.25
		UPGRADE_ROGUE_TWIN_FANGS:
			for hero: Hero in heroes:
				if hero.kind == HERO_ROGUE:
					hero.rogue_dual_strike_unlocked = true
					hero.attack_cooldown = maxf(0.18, hero.attack_cooldown * 0.95)
		UPGRADE_TANK_HEAVY_ATTACK:
			for hero: Hero in heroes:
				if hero.kind == HERO_KNIGHT:
					hero.tank_heavy_attack_unlocked = true
					hero.attack_damage += 1.4
		UPGRADE_RANGER_TRIPLE_ARROWS:
			for hero: Hero in heroes:
				if hero.kind == HERO_RANGER:
					hero.ranger_triple_arrows_unlocked = true
					hero.attack_cooldown = maxf(0.54, hero.attack_cooldown * 0.96)

	upgrade_levels[upgrade_id] = int(upgrade_levels.get(upgrade_id, 0)) + 1
	upgrades_taken += 1

func _upgrade_name(upgrade_id: int) -> String:
	match upgrade_id:
		UPGRADE_HALO_FLOW:
			return "Halo Conduction"
		UPGRADE_RANGER_REMEDY:
			return "Ranger Remedy"
		UPGRADE_ROGUE_OVERDRIVE:
			return "Rogue Overdrive"
		UPGRADE_TANK_BASTION:
			return "Tank Bastion"
		UPGRADE_FIELD_PATCH:
			return "Field Patch"
		UPGRADE_HALO_RESERVOIR:
			return "Halo Reservoir"
		UPGRADE_RANGER_FOCUS:
			return "Ranger Focus"
		UPGRADE_TANK_MARCH:
			return "Tank March"
		UPGRADE_ROGUE_PRECISION:
			return "Rogue Precision"
		UPGRADE_TEAM_TRAINING:
			return "Team Training"
		UPGRADE_GOLDEN_SURGE:
			return "Golden Surge"
		UPGRADE_ROGUE_TWIN_FANGS:
			return "Twin Fangs"
		UPGRADE_TANK_HEAVY_ATTACK:
			return "Heavy Attack"
		UPGRADE_RANGER_TRIPLE_ARROWS:
			return "Triple Arrows"
	return "Unknown"

func _upgrade_description(upgrade_id: int) -> String:
	match upgrade_id:
		UPGRADE_HALO_FLOW:
			return "Longer halo uptime, faster recharge, lower re-equip threshold."
		UPGRADE_RANGER_REMEDY:
			return "Ranger halo pulse heals more and reaches farther."
		UPGRADE_ROGUE_OVERDRIVE:
			return "Rogue gets stronger and faster while haloed."
		UPGRADE_TANK_BASTION:
			return "Tank taunt/pull radius up, better nearby ally sustain."
		UPGRADE_FIELD_PATCH:
			return "Immediate team heal and max HP increase."
		UPGRADE_HALO_RESERVOIR:
			return "Increase halo charge capacity and gain a charge burst now."
		UPGRADE_RANGER_FOCUS:
			return "Ranger attacks faster and hits harder."
		UPGRADE_TANK_MARCH:
			return "Tank gains movement speed and max HP."
		UPGRADE_ROGUE_PRECISION:
			return "Rogue attacks faster and with stronger strikes."
		UPGRADE_TEAM_TRAINING:
			return "All heroes gain a small speed and damage bump."
		UPGRADE_GOLDEN_SURGE:
			return "Boss reward: major all-around power spike this run."
		UPGRADE_ROGUE_TWIN_FANGS:
			return "Unlock Rogue dual strike: attacks in front and behind each swing."
		UPGRADE_TANK_HEAVY_ATTACK:
			return "Unlock Tank charged slam: huge area strike that punishes swarms."
		UPGRADE_RANGER_TRIPLE_ARROWS:
			return "Unlock Ranger triple-shot: fires 3 arrows at once."
	return ""

func _update_ui() -> void:
	var view_size: Vector2 = _viewport_size()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hint_label.size = Vector2(maxf(320.0, view_size.x - 20.0), hint_label.size.y)
	hint_label.position = Vector2(10.0, view_size.y - 36.0)

	if start_selection_active:
		wave_label.text = ""
		threat_label.text = ""
		hero_status.text = ""
		hint_label.text = ""
		return

	wave_label.text = "Wave %d  |  Time %.1fs  |  Upgrades %d" % [wave, elapsed_time, upgrades_taken]

	var swarm_count: int = 0
	var ranged_count: int = 0
	var elite_count: int = 0
	var boss_count: int = 0
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		match enemy.kind:
			ENEMY_SWARM:
				swarm_count += 1
			ENEMY_RANGED:
				ranged_count += 1
			ENEMY_ELITE:
				elite_count += 1
			ENEMY_BOSS:
				boss_count += 1

	threat_label.text = "Enemies %d  |  Swarm %d  Ranged %d  Elite %d  Boss %d  |  Shots %d" % [enemies.size(), swarm_count, ranged_count, elite_count, boss_count, projectiles.size()]
	var halo_pct: float = clampf((halo_charge / maxf(halo_charge_cap, 0.01)) * 100.0, 0.0, 999.0)
	threat_label.text += "  |  Halo %.0f%%" % [halo_pct]
	threat_label.text += "  |  Power %d%%" % int(round(team_power * 100.0))
	if halo_equipped:
		threat_label.text += " ACTIVE"
	else:
		if halo_recharge_delay_timer > 0.0:
			threat_label.text += " DROPPED (Recharge in %.1fs)" % [halo_recharge_delay_timer]
		else:
			threat_label.text += " RECHARGING"

	var lines: Array[String] = []
	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		var tags: Array[String] = []
		if i == halo_index:
			if hero.has_halo:
				tags.append("HALO")
			elif not halo_equipped:
				tags.append("OFF")
		if hero.is_player_controlled:
			tags.append("CTRL")
		var hp_text: String = "DOWN" if hero.health <= 0.0 else "%d/%d" % [int(round(hero.health)), int(round(hero.max_health))]
		var tag_text: String = ""
		if not tags.is_empty():
			tag_text = "(%s)" % ["/".join(tags)]
		lines.append("[%d] %s  %s %s" % [i + 1, hero.hero_name, hp_text, tag_text])

	if upgrade_phase_active:
		lines.append("")
		lines.append("Choose One Upgrade (Mouse Click Only)")

	hero_status.text = "\n".join(lines)

	if game_over:
		hint_label.text = "All heroes are down. Press R or Enter to restart."
	elif upgrade_phase_active:
		hint_label.text = "Upgrade pause: click one of the three cards to continue."
	elif not halo_equipped:
		if halo_recharge_delay_timer > 0.0:
			hint_label.text = "Halo dropped. Recharge starts in %.1fs." % [halo_recharge_delay_timer]
		elif halo_charge < halo_min_activate_charge_value:
			hint_label.text = "Halo recharging... need %.0f%% to re-equip (SPACE)." % [halo_min_activate_charge_value]
		elif halo_index < 0:
			hint_label.text = "Pick a hero with 1/2/3 or click. Then press SPACE or double-click to activate Halo."
		else:
			hint_label.text = "Controlling selected hero without Halo. Press SPACE or double-click to activate."
	elif waiting_for_next_wave:
		hint_label.text = "Wave clear. Next wave in %.1f seconds." % [maxf(intermission_timer, 0.0)]
	else:
		hint_label.text = "WASD/Arrows move halo hero. Switch with 1/2/3 or click. SPACE or double-click drops halo."

func _get_player_move_input() -> Vector2:
	var x: float = 0.0
	var y: float = 0.0

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		y += 1.0

	var input_vec: Vector2 = Vector2(x, y)
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	return input_vec

func _draw_world_backdrop(view_rect: Rect2) -> void:
	draw_rect(arena_rect.grow(2600.0), Color(0.02, 0.03, 0.06), true)
	draw_rect(arena_rect, Color(0.05, 0.08, 0.13), true)
	_draw_floor_pattern(view_rect)
	if low_spec_mode:
		draw_rect(arena_rect, Color(0.03, 0.05, 0.08, 0.26), true)
	_draw_boundary_walls()
	_draw_atmospheric_lighting(view_rect)

func _draw_start_menu_backdrop(view_rect: Rect2) -> void:
	draw_rect(view_rect, Color(0.015, 0.03, 0.065, 1.0), true)

	# Vertical tone bands for a dedicated menu look (separate from the arena floor).
	var band_count: int = 16
	for i in range(band_count):
		var t0: float = float(i) / float(band_count)
		var t1: float = float(i + 1) / float(band_count)
		var y0: float = lerpf(view_rect.position.y, view_rect.end.y, t0)
		var y1: float = lerpf(view_rect.position.y, view_rect.end.y, t1)
		var band_rect: Rect2 = Rect2(Vector2(view_rect.position.x, y0), Vector2(view_rect.size.x, y1 - y0))
		var top_col: Color = Color(0.02, 0.07, 0.13, 0.6)
		var bot_col: Color = Color(0.01, 0.02, 0.05, 0.74)
		draw_rect(band_rect, top_col.lerp(bot_col, t0), true)

	# Three square stained-glass windows aligned behind the three hero cards.
	var glass_colors: Array[Color] = [
		Color(0.24, 0.7, 0.98, 0.5),
		Color(0.94, 0.46, 0.78, 0.48),
		Color(0.39, 0.88, 0.74, 0.48),
		Color(0.94, 0.74, 0.32, 0.46)
	]
	for i in range(3):
		var slot_world: Rect2 = _screen_rect_to_world(_starting_hero_slot_rect(i))
		var window_w: float = slot_world.size.x * 0.34
		var window_h: float = slot_world.size.y * 1.02
		var window_x: float = slot_world.position.x + (slot_world.size.x - window_w) * 0.5
		var window_y: float = slot_world.position.y - window_h * 0.84
		var frame_color: Color = Color(0.16, 0.21, 0.31, 0.82)
		var lead_color: Color = Color(0.82, 0.9, 1.0, 0.3)

		var outer_rect: Rect2 = Rect2(Vector2(window_x, window_y), Vector2(window_w, window_h))
		draw_rect(outer_rect, frame_color, true)
		var inner_rect: Rect2 = outer_rect.grow(-7.0)
		draw_rect(inner_rect, Color(0.09, 0.14, 0.2, 0.62), true)

		var cols: int = 3
		var rows: int = 2
		var pane_gap: float = 2.0
		var pane_w: float = (inner_rect.size.x - pane_gap * float(cols - 1)) / float(cols)
		var pane_h: float = (inner_rect.size.y - pane_gap * float(rows - 1)) / float(rows)
		for row in range(rows):
			for col in range(cols):
				var px: float = inner_rect.position.x + float(col) * (pane_w + pane_gap)
				var py: float = inner_rect.position.y + float(row) * (pane_h + pane_gap)
				var pane: Rect2 = Rect2(Vector2(px, py), Vector2(pane_w, pane_h))
				var c_idx: int = (i + row + col) % glass_colors.size()
				draw_rect(pane, glass_colors[c_idx], true)
				draw_rect(pane.grow(-1.2), Color(0.9, 0.95, 1.0, 0.08), true)

		for col in range(1, cols):
			var lx: float = inner_rect.position.x + float(col) * (pane_w + pane_gap) - pane_gap * 0.5
			draw_line(Vector2(lx, inner_rect.position.y), Vector2(lx, inner_rect.end.y), lead_color, 1.4)
		for row in range(1, rows):
			var ly: float = inner_rect.position.y + float(row) * (pane_h + pane_gap) - pane_gap * 0.5
			draw_line(Vector2(inner_rect.position.x, ly), Vector2(inner_rect.end.x, ly), lead_color, 1.4)

	# Subtle rectangular stage wash behind cards.
	var stage_rect: Rect2 = Rect2(
		Vector2(view_rect.position.x + view_rect.size.x * 0.1, view_rect.position.y + view_rect.size.y * 0.26),
		Vector2(view_rect.size.x * 0.8, view_rect.size.y * 0.44)
	)
	draw_rect(stage_rect, Color(0.12, 0.24, 0.38, 0.07), true)
	draw_rect(stage_rect.grow(-36.0), Color(0.1, 0.21, 0.34, 0.04), true)

	# Subtle framing ornaments.
	draw_rect(view_rect.grow(-24.0), Color(0.78, 0.88, 1.0, 0.1), false, 2.0)
	draw_rect(view_rect.grow(-44.0), Color(0.56, 0.74, 1.0, 0.07), false, 1.6)

func _draw_readability_pass() -> void:
	if low_spec_mode:
		return

	# Slightly dim the busy floor so character silhouettes stand out more.
	draw_rect(arena_rect, Color(0.0, 0.0, 0.0, 0.12), true)

	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		var nearest_light: Vector2 = _nearest_top_light_anchor(hero.global_position)
		var away_from_light: Vector2 = (hero.global_position - nearest_light).normalized()
		if away_from_light.length_squared() <= 0.0001:
			away_from_light = Vector2(0.0, 1.0)
		var shadow_dir: Vector2 = away_from_light.lerp(Vector2(0.0, 1.0), 0.36).normalized()
		if shadow_dir.length_squared() <= 0.0001:
			shadow_dir = Vector2(0.0, 1.0)
		var shadow_center: Vector2 = hero.global_position + shadow_dir * (hero.body_radius * 0.44) + Vector2(0.0, hero.body_radius * 0.3)
		var shadow_length: float = maxf(HERO_CONTRAST_BASE_RADIUS * 0.82, hero.body_radius * 1.66)
		var shadow_width: float = maxf(HERO_CONTRAST_BASE_RADIUS * 0.4, hero.body_radius * 0.76)
		if hero.is_player_controlled:
			shadow_length *= 0.86
			shadow_width *= 0.86
		var light_proximity: float = clampf(1.0 - hero.global_position.distance_to(nearest_light) / 920.0, 0.0, 1.0)
		var shadow_alpha_main: float = lerpf(0.22, 0.11, light_proximity)
		var shadow_alpha_soft: float = shadow_alpha_main * 0.66
		var shadow_tint: Color = Color(0.04, 0.06, 0.09, 1.0).lerp(Color(0.16, 0.22, 0.3, 1.0), light_proximity * 0.58)
		_draw_soft_shadow(shadow_center, shadow_dir, shadow_length, shadow_width, shadow_tint, shadow_alpha_main)
		_draw_soft_shadow(shadow_center + shadow_dir * 2.0, shadow_dir, shadow_length * 0.68, shadow_width * 0.7, shadow_tint, shadow_alpha_soft)

		# Tiny light catch on the side facing the nearest beam so light/shadow feel connected.
		var light_catch_center: Vector2 = hero.global_position - away_from_light * (hero.body_radius * 0.42) + Vector2(0.0, hero.body_radius * 0.18)
		_draw_oriented_soft_ellipse(light_catch_center, shadow_dir, shadow_width * 0.4, shadow_width * 0.22, Color(0.6, 0.78, 1.0, 0.1), 20)

		if hero.is_player_controlled:
			draw_arc(shadow_center, shadow_width * 1.18, 0.0, TAU, 44, Color(0.72, 0.93, 1.0, 0.2), 2.0)
		elif hero.has_halo:
			draw_arc(shadow_center, shadow_width * 1.13, 0.0, TAU, 44, Color(1.0, 0.93, 0.58, 0.18), 1.9)

func _draw_soft_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color, points: int) -> void:
	_draw_oriented_soft_ellipse(center, Vector2.RIGHT, radius_x, radius_y, color, points)

func _draw_oriented_soft_ellipse(center: Vector2, axis_dir: Vector2, radius_long: float, radius_short: float, color: Color, points: int) -> void:
	var dir: Vector2 = axis_dir.normalized()
	if dir.length_squared() <= 0.0001:
		dir = Vector2.RIGHT
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	var poly := PackedVector2Array()
	var count: int = max(12, points)
	for i in range(count):
		var t: float = TAU * float(i) / float(count)
		var p: Vector2 = center + dir * (cos(t) * radius_long) + perp * (sin(t) * radius_short)
		poly.append(p)
	draw_colored_polygon(poly, color)

func _draw_soft_shadow(center: Vector2, direction: Vector2, length: float, width: float, tint: Color, alpha: float) -> void:
	var dir: Vector2 = direction.normalized()
	if dir.length_squared() <= 0.0001:
		dir = Vector2(0.0, 1.0)
	for i in range(3):
		var t: float = float(i) / 2.0
		var layer_center: Vector2 = center + dir * (length * 0.08 * t)
		var layer_len: float = length * (1.0 - t * 0.28)
		var layer_wid: float = width * (1.0 - t * 0.44)
		var layer_alpha: float = alpha * (1.0 - t * 0.62)
		_draw_oriented_soft_ellipse(layer_center, dir, layer_len, layer_wid, Color(tint.r, tint.g, tint.b, layer_alpha), 20)

func _top_light_anchor_position(index: int) -> Vector2:
	var t: float = (float(index) + 0.5) / float(max(1, ATMOS_RAY_COUNT))
	var sx: float = lerpf(arena_rect.position.x + ATMOS_RAY_EDGE_INSET, arena_rect.end.x - ATMOS_RAY_EDGE_INSET, t)
	return Vector2(sx, arena_rect.position.y + 24.0)

func _nearest_top_light_anchor(point: Vector2) -> Vector2:
	var nearest: Vector2 = _top_light_anchor_position(0)
	var nearest_dist_sq: float = point.distance_squared_to(nearest)
	for i in range(1, ATMOS_RAY_COUNT):
		var candidate: Vector2 = _top_light_anchor_position(i)
		var d: float = point.distance_squared_to(candidate)
		if d < nearest_dist_sq:
			nearest_dist_sq = d
			nearest = candidate
	return nearest

func _draw_floor_pattern(view_rect: Rect2) -> void:
	var visible: Rect2 = arena_rect.intersection(view_rect.grow(FLOOR_PATTERN_PAD))
	if visible.size.x <= 0.0 or visible.size.y <= 0.0:
		return

	if floor_texture != null:
		var tex_w: float = float(floor_texture.get_width())
		var tex_h: float = float(floor_texture.get_height())
		if tex_w > 0.0 and tex_h > 0.0:
			# Fill the arena with repeated floor tiles so walking always reveals more floor.
			draw_rect(arena_rect, Color(0.06, 0.1, 0.14, 0.95), true)
			var tile_size: float = FLOOR_TEXTURE_TILE_WORLD_SIZE
			var start_x: float = floor((visible.position.x - arena_rect.position.x) / tile_size) * tile_size + arena_rect.position.x
			var start_y: float = floor((visible.position.y - arena_rect.position.y) / tile_size) * tile_size + arena_rect.position.y
			var end_x: float = minf(visible.end.x + tile_size, arena_rect.end.x + tile_size)
			var end_y: float = minf(visible.end.y + tile_size, arena_rect.end.y + tile_size)
			var src_rect_full: Rect2 = Rect2(Vector2.ZERO, Vector2(tex_w, tex_h))
			for y in range(int(start_y), int(end_y), int(tile_size)):
				for x in range(int(start_x), int(end_x), int(tile_size)):
					var tile_rect: Rect2 = Rect2(Vector2(float(x), float(y)), Vector2(tile_size, tile_size))
					draw_texture_rect_region(floor_texture, tile_rect, src_rect_full, Color(0.56, 0.66, 0.8, 0.42), false, true)

			# Keep a stronger center medallion accent.
			var coverage: float = FLOOR_TEXTURE_CENTER_COVERAGE
			if OS.has_feature("web"):
				coverage *= FLOOR_TEXTURE_WEB_COVERAGE_MULT
			var max_h: float = arena_rect.size.y * coverage
			var draw_h: float = max_h
			var draw_w: float = draw_h * (tex_w / maxf(tex_h, 0.001))
			var max_w: float = arena_rect.size.x * 0.94
			if draw_w > max_w:
				draw_w = max_w
				draw_h = draw_w * (tex_h / maxf(tex_w, 0.001))
			var draw_rect_tex: Rect2 = Rect2(
				arena_rect.get_center() - Vector2(draw_w * 0.5, draw_h * 0.5),
				Vector2(draw_w, draw_h)
			)
			draw_texture_rect_region(floor_texture, draw_rect_tex, src_rect_full, Color(0.8, 0.9, 1.0, 0.84), false, true)
			draw_rect(arena_rect, Color(0.02, 0.04, 0.07, 0.14), true)
			return

	_draw_floor_pattern_fallback(visible)

func _draw_floor_pattern_fallback(visible: Rect2) -> void:
	var tile: float = FLOOR_TILE_SIZE
	var half: float = tile * 0.5
	var start_x: float = floor(visible.position.x / tile) * tile
	var start_y: float = floor(visible.position.y / tile) * tile
	var end_x: float = visible.end.x + tile
	var end_y: float = visible.end.y + tile
	var center: Vector2 = arena_rect.get_center()

	for y in range(int(start_y), int(end_y), int(tile)):
		for x in range(int(start_x), int(end_x), int(tile)):
			var c: Vector2 = Vector2(float(x) + half, float(y) + half)
			var parity: int = (int(floor(float(x) / tile)) + int(floor(float(y) / tile))) % 2
			var dist_ratio: float = clampf(c.distance_to(center) / 1280.0, 0.0, 1.0)
			var cold: Color = Color(0.08, 0.18, 0.27, 0.9)
			var warm: Color = Color(0.15, 0.11, 0.08, 0.9)
			var base_color: Color = cold if parity == 0 else warm
			base_color = base_color.lerp(Color(0.03, 0.04, 0.06, 0.9), dist_ratio * 0.42)

			var diamond := PackedVector2Array([
				c + Vector2(0.0, -half),
				c + Vector2(half, 0.0),
				c + Vector2(0.0, half),
				c + Vector2(-half, 0.0)
			])
			draw_colored_polygon(diamond, base_color)

			var outline := PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]])
			var line_alpha: float = 0.12 if parity == 0 else 0.07
			if ((int(floor(float(x) / tile)) + int(floor(float(y) / tile))) % 3) == 0:
				draw_polyline(outline, Color(0.77, 0.67, 0.42, line_alpha), 1.1)

func _draw_boundary_walls() -> void:
	var top_y: float = arena_rect.position.y
	var bottom_y: float = arena_rect.end.y
	var left_x: float = arena_rect.position.x
	var right_x: float = arena_rect.end.x
	var wall_w: float = 54.0
	var top_wall: Rect2 = Rect2(Vector2(left_x, top_y), Vector2(arena_rect.size.x, wall_w))
	var bottom_wall: Rect2 = Rect2(Vector2(left_x, bottom_y - wall_w), Vector2(arena_rect.size.x, wall_w))
	var left_wall: Rect2 = Rect2(Vector2(left_x, top_y), Vector2(wall_w, arena_rect.size.y))
	var right_wall: Rect2 = Rect2(Vector2(right_x - wall_w, top_y), Vector2(wall_w, arena_rect.size.y))

	# Solid in-arena walls so boundaries are always obvious.
	draw_rect(top_wall, Color(0.08, 0.11, 0.16, 0.92), true)
	draw_rect(bottom_wall, Color(0.08, 0.11, 0.16, 0.92), true)
	draw_rect(left_wall, Color(0.08, 0.11, 0.16, 0.92), true)
	draw_rect(right_wall, Color(0.08, 0.11, 0.16, 0.92), true)

	# Decorative trims.
	draw_line(Vector2(left_x, top_y + wall_w), Vector2(right_x, top_y + wall_w), Color(0.72, 0.86, 1.0, 0.52), 2.4)
	draw_line(Vector2(left_x, bottom_y - wall_w), Vector2(right_x, bottom_y - wall_w), Color(0.72, 0.86, 1.0, 0.52), 2.4)
	draw_line(Vector2(left_x + wall_w, top_y), Vector2(left_x + wall_w, bottom_y), Color(0.72, 0.86, 1.0, 0.46), 2.2)
	draw_line(Vector2(right_x - wall_w, top_y), Vector2(right_x - wall_w, bottom_y), Color(0.72, 0.86, 1.0, 0.46), 2.2)
	draw_rect(arena_rect, Color(0.62, 0.82, 1.0, 0.52), false, 2.2)

	# Repeaters on side walls for structure.
	for y in range(int(top_y) + 90, int(bottom_y) - 90, 180):
		draw_rect(Rect2(Vector2(left_x + 8.0, float(y) - 20.0), Vector2(14.0, 40.0)), Color(0.36, 0.44, 0.56, 0.7), true)
		draw_rect(Rect2(Vector2(right_x - 22.0, float(y) - 20.0), Vector2(14.0, 40.0)), Color(0.36, 0.44, 0.56, 0.7), true)

	# Aligned "windows"/fixtures that match the atmospheric light ray anchors.
	for i in range(ATMOS_RAY_COUNT):
		var t: float = (float(i) + 0.5) / float(ATMOS_RAY_COUNT)
		var sx: float = lerpf(arena_rect.position.x + ATMOS_RAY_EDGE_INSET, arena_rect.end.x - ATMOS_RAY_EDGE_INSET, t)
		draw_rect(Rect2(Vector2(sx - 24.0, top_y + 8.0), Vector2(48.0, 24.0)), Color(0.5, 0.63, 0.82, 0.66), true)
		draw_rect(Rect2(Vector2(sx - 17.0, top_y + 14.0), Vector2(34.0, 10.0)), Color(0.74, 0.88, 1.0, 0.78), true)
		draw_rect(Rect2(Vector2(sx - 20.0, bottom_y - wall_w + 10.0), Vector2(40.0, 14.0)), Color(0.36, 0.44, 0.56, 0.65), true)

func _draw_central_floor_emblem() -> void:
	var c: Vector2 = arena_rect.get_center()
	draw_circle(c, 170.0, Color(0.11, 0.17, 0.25, 0.42))
	draw_arc(c, 170.0, 0.0, TAU, 80, Color(0.8, 0.72, 0.48, 0.6), 3.0)
	draw_arc(c, 118.0, 0.0, TAU, 72, Color(0.4, 0.66, 0.95, 0.52), 2.0)
	draw_arc(c, 76.0, 0.0, TAU, 64, Color(0.82, 0.79, 0.66, 0.48), 2.0)
	for i in range(12):
		var angle: float = TAU * float(i) / 12.0
		var dir: Vector2 = Vector2.RIGHT.rotated(angle)
		draw_line(c + dir * 84.0, c + dir * 160.0, Color(0.74, 0.63, 0.36, 0.36), 1.6)

func _draw_atmospheric_lighting(view_rect: Rect2) -> void:
	# Real lighting now comes from Light2D nodes. Keep this layer very subtle.
	draw_rect(arena_rect, Color(0.02, 0.04, 0.08, 0.05), true)

	for i in range(VIGNETTE_RINGS):
		var inset: float = float(i) * 24.0
		var ring: Rect2 = view_rect.grow(-inset)
		if ring.size.x <= 0.0 or ring.size.y <= 0.0:
			continue
		var alpha: float = 0.055 * (1.0 - float(i) / float(VIGNETTE_RINGS))
		draw_rect(ring, Color(0.0, 0.0, 0.0, alpha), false, 26.0)

func _draw() -> void:
	var view_rect: Rect2 = _viewport_rect_world()

	if start_selection_active:
		_draw_start_menu_backdrop(view_rect)
		draw_rect(view_rect, Color(0.01, 0.03, 0.07, 0.03), true)
		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font

		var title_font: Font = start_menu_title_font if start_menu_title_font != null else card_font
		var title_size: int = 62 if start_menu_title_font != null else 40
		var first_card_screen: Rect2 = _starting_hero_slot_rect(0)
		var title_y: float = _screen_to_world(Vector2(0.0, first_card_screen.position.y - 62.0)).y
		var title_x: float = view_rect.position.x
		var title_text: String = "Choose Your Starting Hero"

		# Layered shadow + highlight passes to give the title depth and texture.
		draw_string(
			title_font,
			Vector2(title_x + 3.0, title_y + 5.0),
			title_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			view_rect.size.x,
			title_size,
			Color(0.0, 0.0, 0.0, 0.72)
		)
		draw_string(
			title_font,
			Vector2(title_x + 1.0, title_y + 2.0),
			title_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			view_rect.size.x,
			title_size,
			Color(0.2, 0.15, 0.08, 0.42)
		)
		draw_string(
			title_font,
			Vector2(title_x, title_y),
			title_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			view_rect.size.x,
			title_size,
			Color(0.95, 0.83, 0.58, 0.98)
		)
		draw_string(
			title_font,
			Vector2(title_x + 1.0, title_y - 1.0),
			title_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			view_rect.size.x,
			title_size,
			Color(1.0, 0.95, 0.78, 0.34)
		)
		draw_string(
			title_font,
			Vector2(title_x - 1.0, title_y + 1.0),
			title_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			view_rect.size.x,
			title_size,
			Color(0.52, 0.34, 0.16, 0.2)
		)

		var hero_colors: Array[Color] = [
			Color(0.36, 0.56, 0.98),
			Color(0.95, 0.45, 0.75),
			Color(0.3, 0.95, 0.65)
		]
		var hero_titles: Array[String] = [
			"1. Tank",
			"2. Ranger",
			"3. Rogue"
		]
		for i in range(heroes.size()):
			var rect_screen: Rect2 = _starting_hero_slot_rect(i)
			var is_hover: bool = rect_screen.has_point(hover_screen)
			var rect: Rect2 = _screen_rect_to_world(rect_screen)
			var base_color: Color = Color(0.09, 0.14, 0.22, 0.96)
			if is_hover:
				base_color = Color(0.15, 0.22, 0.32, 0.98)
			draw_rect(rect, base_color, true)
			draw_rect(rect.grow(-3.0), Color(0.0, 0.0, 0.0, 0.12), true)
			draw_rect(rect, Color(0.9, 0.95, 1.0, 0.78), false, 2.2)
			var icon_size: Vector2 = Vector2(92.0, 92.0)
			var icon_rect: Rect2 = Rect2(
				rect.position + Vector2((rect.size.x - icon_size.x) * 0.5, 12.0),
				icon_size
			)
			var frame_list_variant: Variant = start_card_frames.get(i, [])
			var frame_list: Array = frame_list_variant as Array
			if not frame_list.is_empty():
				var tick: int = int(floor(Time.get_ticks_msec() / 110.0))
				var frame_idx: int = posmod(tick, frame_list.size())
				var hero_tex: Texture2D = frame_list[frame_idx] as Texture2D
				if hero_tex != null:
					draw_texture_rect(hero_tex, icon_rect, false, Color(1.0, 1.0, 1.0, 1.0))
				else:
					draw_circle(icon_rect.position + icon_rect.size * 0.5, 20.0, hero_colors[i])
			else:
				draw_circle(icon_rect.position + icon_rect.size * 0.5, 20.0, hero_colors[i])
			draw_string(card_font, rect.position + Vector2(0.0, 122.0), hero_titles[i], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color(1.0, 1.0, 1.0, 0.98))
			var detail_lines: Array[String] = []
			match i:
				0:
					detail_lines = [
						"Role: Space control / front line",
						"Attack: Wide melee swipe",
						"Halo Skill: Taunt + ally guard healing"
					]
				1:
					detail_lines = [
						"Role: Sustain / pressure support",
						"Attack: Ranged homing shot",
						"Halo Skill: Healing pulse aura"
					]
				_:
					detail_lines = [
						"Role: Burst finisher / clutch",
						"Attack: Fast melee arcs",
						"Halo Skill: Speed + damage spike"
					]
			var y_line: float = 152.0
			for line: String in detail_lines:
				draw_string(card_font, rect.position + Vector2(14.0, y_line), line, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 22.0, 18, Color(0.9, 0.95, 1.0, 0.92))
				y_line += 30.0
		return

	_draw_world_backdrop(view_rect)
	_draw_team_power_overlay()
	_draw_readability_pass()

	if halo_switch_feedback_timer > 0.0:
		var t: float = halo_switch_feedback_timer / HALO_SWITCH_FEEDBACK_DURATION
		var pulse_color: Color = Color(1.0, 0.96, 0.58, 0.8 * t)
		draw_line(halo_switch_feedback_from, halo_switch_feedback_to, pulse_color, 6.0 * t)
		draw_circle(halo_switch_feedback_to, 12.0 + (1.0 - t) * 16.0, Color(1.0, 0.96, 0.58, 0.25 * t))

	var view_size: Vector2 = _viewport_size()
	var bar_rect_screen: Rect2 = Rect2(Vector2(view_size.x * 0.5 - 160.0, 14.0), Vector2(320.0, 14.0))
	var bar_rect: Rect2 = _screen_rect_to_world(bar_rect_screen)
	draw_rect(bar_rect, Color(0.04, 0.06, 0.08, 0.9), true)
	var fill_ratio: float = clampf(halo_charge / maxf(halo_charge_cap, 0.01), 0.0, 1.0)
	var fill_color: Color = Color(0.98, 0.9, 0.35) if halo_equipped else Color(0.55, 0.86, 1.0)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * fill_ratio, bar_rect.size.y)), fill_color, true)
	draw_rect(bar_rect, Color(0.95, 0.98, 1.0, 0.7), false, 1.5)

	if upgrade_phase_active:
		# Stronger modal separation so gameplay action doesn't reduce card readability.
		draw_rect(view_rect, Color(0.01, 0.02, 0.04, 0.56), true)
		var first_slot_screen: Rect2 = _upgrade_slot_rect(0)
		var last_slot_screen: Rect2 = _upgrade_slot_rect(maxi(0, upgrade_choices.size() - 1))
		var modal_panel_screen: Rect2 = first_slot_screen.merge(last_slot_screen).grow_individual(34.0, 42.0, 34.0, 58.0)
		var modal_panel: Rect2 = _screen_rect_to_world(modal_panel_screen)
		draw_rect(modal_panel, Color(0.04, 0.08, 0.14, 0.66), true)
		draw_rect(modal_panel.grow(-6.0), Color(0.02, 0.04, 0.08, 0.36), true)
		draw_rect(modal_panel, Color(0.86, 0.93, 1.0, 0.28), false, 2.0)
		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		for i in range(upgrade_choices.size()):
			var upgrade_id: int = upgrade_choices[i]
			var title: String = "%d. %s" % [i + 1, _upgrade_name(upgrade_id)]
			var desc_lines: Array[String] = _wrap_text_lines(_upgrade_description(upgrade_id), 32, 3)
			var rect_screen: Rect2 = _upgrade_slot_rect(i)
			var is_hover: bool = rect_screen.has_point(hover_screen)
			var rect: Rect2 = _screen_rect_to_world(rect_screen)
			var base_color: Color = Color(0.12, 0.18, 0.26, 0.94)
			var text_color: Color = Color(0.9, 0.95, 1.0, 0.95)
			if is_hover:
				base_color = Color(0.2, 0.28, 0.38, 0.98)
				text_color = Color(1.0, 1.0, 1.0, 1.0)
			draw_rect(rect, base_color, true)
			draw_rect(rect, Color(0.9, 0.95, 1.0, 0.72), false, 2.0)
			draw_string(card_font, rect.position + Vector2(14.0, 30.0), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 19, text_color)
			var y: float = 56.0
			for line: String in desc_lines:
				draw_string(card_font, rect.position + Vector2(14.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 15, Color(text_color.r, text_color.g, text_color.b, 0.92))
				y += 18.0

func _draw_team_power_overlay() -> void:
	if start_selection_active or upgrade_phase_active or heroes.is_empty():
		return

	_draw_team_links()
	_draw_power_circle()
	_draw_kill_flashes()

func _draw_team_links() -> void:
	var alive: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive.append(hero)
	if alive.size() <= 1:
		return

	for i in range(alive.size()):
		for j in range(i + 1, alive.size()):
			var a: Vector2 = alive[i].global_position
			var b: Vector2 = alive[j].global_position
			var dist: float = a.distance_to(b)
			if dist > TEAM_LINK_MAX_DISTANCE:
				continue
			var closeness: float = 1.0 - dist / TEAM_LINK_MAX_DISTANCE
			var alpha: float = TEAM_LINK_MAX_ALPHA * closeness * team_power
			var width: float = 1.0 + 2.4 * closeness * team_power
			draw_line(a, b, Color(0.68, 0.95, 1.0, alpha), width, true)
			draw_circle(a.lerp(b, 0.5), 1.2 + 1.1 * closeness, Color(0.9, 0.98, 1.0, alpha * 0.9))

func _draw_power_circle() -> void:
	if team_power_center == Vector2.ZERO:
		return
	var pulse: float = 1.0 + sin(float(Time.get_ticks_msec()) * 0.0032) * (0.03 + team_power * 0.08)
	var r: float = team_power_radius * pulse
	var line_alpha: float = 0.12 + team_power * 0.72
	var outer_line_alpha: float = clampf(line_alpha * 0.58, 0.0, 1.0)
	var fill_alpha: float = 0.02 + team_power * 0.1
	var width: float = 1.8 + team_power * 5.0

	draw_circle(team_power_center, r, Color(0.78, 0.95, 1.0, fill_alpha))
	draw_arc(team_power_center, r, 0.0, TAU, 56, Color(0.92, 0.98, 1.0, outer_line_alpha), width)
	draw_arc(team_power_center, r * 0.72, 0.0, TAU, 48, Color(0.52, 0.86, 1.0, 0.07 + team_power * 0.26), 1.2 + team_power * 2.1)

	var spark_count: int = 10
	for i in range(spark_count):
		var phase: float = TAU * float(i) / float(spark_count)
		var wobble: float = sin(float(Time.get_ticks_msec()) * 0.005 + float(i) * 1.2)
		var sr: float = r + wobble * (3.0 + team_power * 6.0)
		var angle: float = phase + float(Time.get_ticks_msec()) * 0.00055 * (1.0 + team_power)
		var p: Vector2 = team_power_center + Vector2.RIGHT.rotated(angle) * sr
		draw_circle(p, 1.2 + team_power * 1.3, Color(0.94, 0.98, 1.0, 0.06 + team_power * 0.24))

func _draw_kill_flashes() -> void:
	for flash: Dictionary in kill_flashes:
		var time_left: float = float(flash.get("time", 0.0))
		var max_time: float = maxf(float(flash.get("max_time", KILL_FLASH_DURATION)), 0.01)
		var t: float = clampf(time_left / max_time, 0.0, 1.0)
		var p_variant: Variant = flash.get("position", Vector2.ZERO)
		var pos: Vector2 = Vector2.ZERO
		if p_variant is Vector2:
			pos = p_variant
		var radius: float = float(flash.get("radius", 24.0))
		var draw_radius: float = radius * (0.62 + (1.0 - t) * 1.2)
		draw_circle(pos, draw_radius, Color(1.0, 0.93, 0.72, 0.2 * t))
		draw_arc(pos, draw_radius + 5.0, 0.0, TAU, 30, Color(1.0, 0.88, 0.6, 0.58 * t), 2.0 + 2.6 * t)
