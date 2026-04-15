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
const ENEMY_FINAL_BOSS := 4
const ENEMY_FLYER := 5
const ENEMY_THROWER := 6

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
const UPGRADE_HALO_SPECTER := 14
const UPGRADE_HALO_ECHO := 15
const UPGRADE_ROGUE_TWIN_FANGS_PLUS := 16
const UPGRADE_TANK_HEAVY_ATTACK_PLUS := 17
const UPGRADE_RANGER_TRIPLE_ARROWS_PLUS := 18

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
const START_CARD_TANK_CUSTOM_PATH := "res://assets/ui/select_cards/tank_selectscreen.png"
const START_CARD_RANGER_CUSTOM_PATH := "res://assets/ui/select_cards/ranger_selectscreen.png"
const UPGRADE_CARD_RANGER_REMEDY_PATH := "res://assets/ui/upgrade_cards/ranger_remedy.png"
const UPGRADE_CARD_HALO_CONDUCTION_PATH := "res://assets/ui/upgrade_cards/halo_conduction.png"
const UPGRADE_CARD_GOLDEN_SURGE_PATH := "res://assets/ui/upgrade_cards/golden_surge.png"
const UPGRADE_CARD_ROGUE_PRECISION_PATH := "res://assets/ui/upgrade_cards/rogue_precision.png"
const UPGRADE_CARD_TANK_MARCH_PATH := "res://assets/ui/upgrade_cards/tank_march.png"
const UPGRADE_CARD_HEAVY_ATTACK_PLUS_PATH := "res://assets/ui/upgrade_cards/heavy_attack_plus.png"
const UPGRADE_CARD_TRIPLE_ARROWS_PLUS_PATH := "res://assets/ui/upgrade_cards/triple_arrows_plus.png"
const UPGRADE_CARD_TRIPLE_ARROWS_PATH := "res://assets/ui/upgrade_cards/triple_arrows.png"
const UPGRADE_CARD_SPECTRAL_HALO_PATH := "res://assets/ui/upgrade_cards/spectral_halo.png"
const UPGRADE_CARD_PLUS_1_SPECTRAL_HALO_PATH := "res://assets/ui/upgrade_cards/plus_1_spectral_halo.png"
const UPGRADE_CARD_HEAVY_ATTACK_PATH := "res://assets/ui/upgrade_cards/heavy_attack.png"
const UPGRADE_CARD_TANK_BASTION_PATH := "res://assets/ui/upgrade_cards/tank_bastion.png"
const UPGRADE_CARD_SHADOW_ZIP_PATH := "res://assets/ui/upgrade_cards/shadow_zip.png"
const UPGRADE_CARD_SHADOW_ZIP_PLUS_PATH := "res://assets/ui/upgrade_cards/shadow_zip_plus.png"
const UPGRADE_CARD_HALO_RESERVOIR_PATH := "res://assets/ui/upgrade_cards/halo_reservoir.png"
const UPGRADE_CARD_ROGUE_OVERDRIVE_PATH := "res://assets/ui/upgrade_cards/rogue_overdrive.png"
const UPGRADE_CARD_ARCHER_FOCUS_PATH := "res://assets/ui/upgrade_cards/archer_focus.png"
const UPGRADE_CARD_TEAM_TRAINING_PATH := "res://assets/ui/upgrade_cards/team_training.png"
const START_SCREEN_TITLE_LOGO_PATH := "res://assets/ui/title_logo.png"
const START_MENU_TITLE_FONT_PATH := "res://assets/fonts/Starstruck.ttf"
const UI_HUD_FONT_PATH := "res://assets/fonts/DEATHCROW.ttf"
const UI_HUD_FONT_ALT_PATH := "res://assets/fonts/Mokgech-Regular.otf"
const UI_TEXT_COLOR := Color(0.9, 0.24, 0.28, 1.0)
const UI_OUTLINE_COLOR := Color(0.07, 0.0, 0.01, 0.96)
const UI_SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.9)
const FLOOR_MAIN_TEXTURE_PATH := "res://assets/floor/floor_main_tile.png"
const FLOOR_MIDDLE_TEXTURE_PATH := "res://assets/floor/floor_middle_tile.png"
const FLOOR_TEXTURE_TILE_WORLD_SIZE := 320.0
const FLOOR_TEXTURE_MAIN_ALPHA := 0.96
const FLOOR_TEXTURE_CENTER_ALPHA := 0.98
const FLOOR_TILE_SIZE := 104.0
const FLOOR_PATTERN_PAD := 220.0
const WALL_TOP_WINDOWS_TEXTURE_PATH := "res://assets/floor/walls_top_windows.png"
const WALL_LEFT_TEXTURE_PATH := "res://assets/floor/walls_left.png"
const WALL_RIGHT_TEXTURE_PATH := "res://assets/floor/walls_right.png"
const WALL_BOTTOM_TEXTURE_PATH := "res://assets/floor/walls_down.png"
const WINDOW_LIGHT_TEXTURE_PATH := "res://assets/floor/window_light.png"
const FLOOR_LIGHT_TEXTURE_PATH := "res://assets/floor/floor_light.png"
const WALL_TOP_BLOCK := 236.0
const WALL_SIDE_BLOCK := 24.0
const WALL_BOTTOM_BLOCK := 14.0
const PLAYFIELD_INNER_PAD := 8.0
const WALL_FRAME_THICKNESS := 34.0
const VIGNETTE_RINGS := 4
const HERO_CONTRAST_BASE_RADIUS := 34.0
const ATMOS_RAY_COUNT := 4
const ATMOS_RAY_EDGE_INSET := 140.0
const CAMERA_ZOOM_MENU := Vector2(1.0, 1.0)
const CAMERA_ZOOM_GAME := Vector2(1.22, 1.22)
const CAMERA_ZOOM_SMOOTH := 8.5
const WEB_LOW_SPEC_ENABLED := true
const WAVE_BASE_ENEMIES := 32
const WAVE_LINEAR_ENEMIES := 8
const WAVE_SCALING_ENEMIES := 2.4
const WAVE_GRADUAL_EXTRA_START := 3
const WAVE_GRADUAL_EXTRA_PER_WAVE := 2
const WAVE_GRADUAL_EXTRA_CAP := 32
const WAVE_BOSS_SUPPORT_BASE := 18
const WAVE_BOSS_SUPPORT_PER_WAVE := 4
const WAVE_SPAWN_INTERVAL_START := 0.43
const WAVE_SPAWN_INTERVAL_FLOOR := 0.16
const WAVE_SPAWN_INTERVAL_DECAY := 0.014
const WAVE_BURST_WAVE_START := 5
const WAVE_BURST_MIN := 2
const WAVE_BURST_MAX := 4
const WAVE_BURST_WAVE9_BONUS := 1
const WAVE_MINI_SURGE_WAVE_START := 6
const WAVE_MINI_SURGE_DURATION_BASE := 3.2
const WAVE_MINI_SURGE_DURATION_MAX := 5.2
const WAVE_MINI_SURGE_DURATION_WAVE_SCALE := 0.06
const WAVE_MINI_SURGE_COOLDOWN_BASE := 10.6
const WAVE_MINI_SURGE_COOLDOWN_MIN := 6.2
const WAVE_MINI_SURGE_COOLDOWN_WAVE_SCALE := 0.24
const WAVE_MINI_SURGE_INTERVAL_MULT := 0.56
const WAVE_MINI_SURGE_EXTRA_BATCH := 2
const WAVE_MINI_SURGE_RECOVERY_DURATION := 2.2
const WAVE_MINI_SURGE_HERO_ATK_SPEED_BONUS := 0.2
const WAVE_MINI_SURGE_HERO_DAMAGE_BONUS := 0.15
const CAMERA_SHAKE_DURATION := 0.16
const CAMERA_SHAKE_DECAY := 26.0
const CAMERA_SHAKE_MAX := 8.0
const TEAM_POWER_TIGHT_RADIUS := 102.0
const TEAM_POWER_SPREAD_RADIUS := 268.0
const TEAM_POWER_SMOOTH := 5.6
const TEAM_LINK_MAX_DISTANCE := 220.0
const TEAM_LINK_MAX_ALPHA := 0.26
const TEAM_CIRCLE_BASE_RADIUS := 116.0
const TEAM_CIRCLE_MAX_RADIUS := 178.0
const KILL_FLASH_DURATION := 0.24
const HEALTH_DROP_LIFETIME := 11.0
const HEALTH_DROP_DRAG := 190.0
const HEALTH_DROP_PULL_SPEED := 320.0
const HEALTH_DROP_ATTRACT_RADIUS := 124.0
const HEALTH_DROP_PICKUP_PAD := 6.0
const HEALTH_DROP_SHEET_PATH := "res://assets/pickups/heal_sheet7.png"
const HEALTH_DROP_SHEET_FRAME_COUNT := 7
const HEALTH_DROP_SHEET_FPS := 9.2
const HEALTH_DROP_SHEET_BASE_SCALE := 2.0
const PERFECT_POSITION_RING_RADIUS := 92.0
const PERFECT_POSITION_FEEDBACK_DURATION := 0.92
const PERFECT_POSITION_KILL_FLASH_MULT := 1.34
const PERFECT_POSITION_HIT_FEEDBACK_MULT := 1.3
const PERFECT_POSITION_HIT_SHAKE_BONUS := 0.22
const PERFECT_POSITION_IMPACT_FLASH_INTERVAL := 0.05
const PERFECT_POSITION_IMPACT_FLASH_INTENSITY := 1.08
const PERFECT_POSITION_SOUND_COOLDOWN := 2.8
const PERFECT_POSITION_ENTER_STABLE_TIME := 0.22
const PERFECT_POSITION_EXIT_GRACE_TIME := 0.14
const PERFECT_POSITION_SOUND_REARM_TIME := 0.8
const PERFECT_POSITION_SFX_PATH := "res://assets/audio/perfect_position_lock_in.wav"
const PERFECT_POSITION_SFX_VOLUME_DB := -19.0
const PERFECT_POSITION_BREAK_SFX_PATH := "res://assets/audio/perfect_position_break.wav"
const PERFECT_POSITION_BREAK_SFX_VOLUME_DB := -19.5
const PERFECT_POSITION_BREAK_SOUND_COOLDOWN := 2.8
const PERFECT_POSITION_BREAK_MIN_ACTIVE_TIME := 0.65
const SPECTRAL_HALO_SPEED := 356.0
const SPECTRAL_HALO_RADIUS := 18.0
const SPECTRAL_HALO_CONTACT_DAMAGE := 21.0
const SPECTRAL_HALO_HIT_COOLDOWN := 0.14
const SPECTRAL_HALO_HEAL_RADIUS_BONUS := 16.0
const SPECTRAL_HALO_HEAL_AMOUNT := 7.0
const SPECTRAL_HALO_HEAL_COOLDOWN := 0.45
const SPECTRAL_HALO_MAX_COUNT := 4
const ENABLE_SFX := false
const PERFECT_POSITION_SOUND_ENABLED := true
const SFX_MIX_RATE := 32000.0
const SFX_BUFFER_LENGTH := 0.16
const SFX_MIN_INTERVAL := 0.035
const BGM_MENU_PATH := "res://assets/audio/menu_triada_poderoza.mp3"
const BGM_GAME_PATH := "res://assets/audio/triada_poderoza.mp3"
const BGM_GAME_LOW_HEALTH_PATH := "res://assets/audio/triada_poderoza_low_health.mp3"
const BGM_MENU_VOLUME_DB := -26.0
const BGM_GAME_VOLUME_DB := -16.0
const BGM_LOOP_CROSSFADE_TIME := 0.72
const BGM_SILENT_DB := -46.0
const BGM_VOLUME_SMOOTH := 5.5
const BGM_LOW_HEALTH_ENTER_RATIO := 0.34
const BGM_LOW_HEALTH_EXIT_RATIO := 0.48
const BGM_LOW_LAYER_BLEND_SPEED := 4.2
const BGM_LOW_LAYER_SYNC_TOLERANCE := 0.22
const BGM_GAME_LOW_LAYER_VOLUME_DB := -15.0
const BGM_GAME_MAIN_DUCK_DB := 7.0
const BGM_MODE_MENU := 0
const BGM_MODE_GAME := 1
const BGM_MODE_GAME_LOW_HEALTH := 2
const UI_CLICK_SFX_PATH := "res://assets/audio/menu_click_1.wav"
const UI_CHARACTER_SELECT_SFX_PATH := "res://assets/audio/character_select_1.wav"
const UI_START_GAME_SFX_PATH := "res://assets/audio/start_game_3.wav"
const UI_FINAL_BOSS_APPEAR_SFX_PATH := "res://assets/audio/final_boss_appear.wav"
const UI_CLICK_SFX_VOLUME_DB := -12.0
const UI_CHARACTER_SELECT_SFX_VOLUME_DB := -12.5
const UI_START_GAME_SFX_VOLUME_DB := -12.5
const UI_FINAL_BOSS_APPEAR_SFX_VOLUME_DB := -13.5
const UI_CLICK_SFX_MAX_POLYPHONY := 6
const UI_SELECT_SFX_MAX_POLYPHONY := 4
const START_SCREEN_BUTTON_SIZE := Vector2(300.0, 72.0)
const GAME_OVER_BUTTON_SIZE := Vector2(360.0, 72.0)
const GAME_OVER_PANEL_SIZE := Vector2(560.0, 320.0)
const PAUSE_PANEL_SIZE := Vector2(560.0, 320.0)
const PAUSE_BUTTON_SIZE := Vector2(360.0, 68.0)
const TUTORIAL_PANEL_SIZE := Vector2(920.0, 560.0)
const TUTORIAL_BUTTON_SIZE := Vector2(420.0, 70.0)
const TUTORIAL_PANEL_MARGIN_X := 54.0
const TUTORIAL_PANEL_MARGIN_Y := 44.0
const BOSS_VICTORY_PANEL_SIZE := Vector2(760.0, 420.0)
const BOSS_VICTORY_BUTTON_SIZE := Vector2(300.0, 64.0)
const BOSS_VICTORY_PANEL_MARGIN_X := 72.0
const BOSS_VICTORY_PANEL_MARGIN_Y := 56.0
const OPTIONS_PANEL_SIZE := Vector2(560.0, 330.0)
const OPTIONS_BUTTON_SIZE := Vector2(300.0, 64.0)
const OPTIONS_CLOSE_BUTTON_SIZE := Vector2(220.0, 58.0)

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
var boss_spawn_kind: int = ENEMY_BOSS
var spawn_burst_remaining: int = 0
var wave_surge_active: bool = false
var wave_surge_timer: float = 0.0
var wave_surge_cooldown_timer: float = 0.0
var wave_surge_recovery_timer: float = 0.0
var waiting_for_next_wave: bool = false
var intermission_timer: float = 0.0

var game_over: bool = false
var start_screen_active: bool = true
var start_selection_active: bool = false
var tutorial_screen_active: bool = false
var pause_menu_active: bool = false
var options_menu_active: bool = false
var boss_victory_prompt_active: bool = false
var upgrade_phase_active: bool = false
var upgrade_choices: Array[int] = []
var upgrade_levels: Dictionary = {}
var last_upgrade_choices: Array[int] = []
var final_boss_prompt_pending: bool = false
var endless_cycle: int = 0

var ranger_halo_heal_amount: float = 14.0
var ranger_halo_heal_radius: float = 165.0
var knight_taunt_radius: float = 240.0
var knight_pull_radius: float = 220.0
var knight_guard_heal_per_sec: float = 4.0
var start_card_frames: Dictionary = {}
var start_card_tank_custom: Texture2D = null
var start_card_ranger_custom: Texture2D = null
var upgrade_card_ranger_remedy: Texture2D = null
var upgrade_card_halo_conduction: Texture2D = null
var upgrade_card_golden_surge: Texture2D = null
var upgrade_card_rogue_precision: Texture2D = null
var upgrade_card_tank_march: Texture2D = null
var upgrade_card_heavy_attack_plus: Texture2D = null
var upgrade_card_triple_arrows_plus: Texture2D = null
var upgrade_card_triple_arrows: Texture2D = null
var upgrade_card_spectral_halo: Texture2D = null
var upgrade_card_plus_1_spectral_halo: Texture2D = null
var upgrade_card_heavy_attack: Texture2D = null
var upgrade_card_tank_bastion: Texture2D = null
var upgrade_card_shadow_zip: Texture2D = null
var upgrade_card_shadow_zip_plus: Texture2D = null
var upgrade_card_halo_reservoir: Texture2D = null
var upgrade_card_rogue_overdrive: Texture2D = null
var upgrade_card_archer_focus: Texture2D = null
var upgrade_card_team_training: Texture2D = null
var start_screen_title_logo: Texture2D = null
var start_menu_title_font: Font = null
var hud_font: Font = null
var lighting_root: Node2D = null
var light_texture_soft: Texture2D = null
var light_texture_wide: Texture2D = null
var floor_main_texture: Texture2D = null
var floor_middle_texture: Texture2D = null
var wall_top_windows_texture: Texture2D = null
var wall_left_texture: Texture2D = null
var wall_right_texture: Texture2D = null
var wall_bottom_texture: Texture2D = null
var window_light_texture: Texture2D = null
var floor_light_texture: Texture2D = null
var stained_glass_window_texture: Texture2D = null
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
var health_drop_sheet: Texture2D = null
var health_drop_frame_size: Vector2 = Vector2.ZERO
var low_spec_mode: bool = false
var camera_shake_timer: float = 0.0
var camera_shake_strength: float = 0.0
var camera_shake_offset: Vector2 = Vector2.ZERO
var team_power: float = 0.0
var team_power_center: Vector2 = Vector2.ZERO
var team_power_radius: float = TEAM_CIRCLE_BASE_RADIUS
var kill_flashes: Array[Dictionary] = []
var health_drops: Array[Dictionary] = []
var perfect_position_active: bool = false
var perfect_position_feedback_timer: float = 0.0
var perfect_position_impact_flash_timer: float = 0.0
var perfect_position_sound_cooldown_timer: float = 0.0
var perfect_position_break_sound_cooldown_timer: float = 0.0
var perfect_position_inside_timer: float = 0.0
var perfect_position_outside_timer: float = 0.0
var perfect_position_active_hold_timer: float = 0.0
var perfect_position_sound_armed: bool = true
var perfect_position_break_sound_armed: bool = false
var spectral_halo_unlocked: bool = false
var spectral_halo_count: int = 0
var spectral_halo_positions: Array[Vector2] = []
var spectral_halo_velocities: Array[Vector2] = []
var spectral_halo_hit_timers: Array[float] = []
var spectral_halo_heal_timers: Array[float] = []
var bgm_players: Array[AudioStreamPlayer] = []
var bgm_menu_stream: AudioStream = null
var bgm_game_stream: AudioStream = null
var bgm_game_low_health_stream: AudioStream = null
var bgm_target_volume_db: float = BGM_MENU_VOLUME_DB
var bgm_active_player_index: int = 0
var bgm_active_mode: int = BGM_MODE_MENU
var bgm_low_health_active: bool = false
var bgm_low_layer_player: AudioStreamPlayer = null
var bgm_low_layer_mix: float = 0.0
var bgm_crossfade_active: bool = false
var bgm_crossfade_timer: float = 0.0
var bgm_crossfade_from_index: int = 0
var bgm_crossfade_to_index: int = 1
var sfx_player: AudioStreamPlayer = null
var sfx_playback: AudioStreamGeneratorPlayback = null
var sfx_cooldown_timer: float = 0.0
var ui_click_player: AudioStreamPlayer = null
var ui_character_select_player: AudioStreamPlayer = null
var ui_start_game_player: AudioStreamPlayer = null
var ui_final_boss_appear_player: AudioStreamPlayer = null
var ui_click_stream: AudioStream = null
var ui_character_select_stream: AudioStream = null
var ui_start_game_stream: AudioStream = null
var ui_final_boss_appear_stream: AudioStream = null
var perfect_position_stream: AudioStream = null
var perfect_position_player: AudioStreamPlayer = null
var perfect_position_break_stream: AudioStream = null
var perfect_position_break_player: AudioStreamPlayer = null
var music_volume_percent: float = 100.0
var sfx_volume_percent: float = 100.0
var options_drag_slider: int = -1

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
	upgrade_levels[UPGRADE_HALO_SPECTER] = 0
	upgrade_levels[UPGRADE_HALO_ECHO] = 0
	upgrade_levels[UPGRADE_ROGUE_TWIN_FANGS_PLUS] = 0
	upgrade_levels[UPGRADE_TANK_HEAVY_ATTACK_PLUS] = 0
	upgrade_levels[UPGRADE_RANGER_TRIPLE_ARROWS_PLUS] = 0

	_spawn_heroes()
	_load_start_card_textures()
	_load_upgrade_card_textures()
	start_screen_title_logo = _prepare_start_screen_title_logo(load(START_SCREEN_TITLE_LOGO_PATH) as Texture2D)
	start_menu_title_font = load(START_MENU_TITLE_FONT_PATH) as Font
	hud_font = load(UI_HUD_FONT_PATH) as Font
	if hud_font == null:
		hud_font = load(UI_HUD_FONT_ALT_PATH) as Font
	_configure_hud_style()
	floor_main_texture = load(FLOOR_MAIN_TEXTURE_PATH) as Texture2D
	floor_middle_texture = load(FLOOR_MIDDLE_TEXTURE_PATH) as Texture2D
	wall_top_windows_texture = load(WALL_TOP_WINDOWS_TEXTURE_PATH) as Texture2D
	wall_left_texture = load(WALL_LEFT_TEXTURE_PATH) as Texture2D
	wall_right_texture = load(WALL_RIGHT_TEXTURE_PATH) as Texture2D
	wall_bottom_texture = load(WALL_BOTTOM_TEXTURE_PATH) as Texture2D
	window_light_texture = load(WINDOW_LIGHT_TEXTURE_PATH) as Texture2D
	floor_light_texture = load(FLOOR_LIGHT_TEXTURE_PATH) as Texture2D
	stained_glass_window_texture = _prepare_vertical_flip_texture(floor_light_texture)
	health_drop_sheet = load(HEALTH_DROP_SHEET_PATH) as Texture2D
	if health_drop_sheet != null:
		var frame_count: int = max(1, HEALTH_DROP_SHEET_FRAME_COUNT)
		var frame_w: float = floor(float(health_drop_sheet.get_width()) / float(frame_count))
		if frame_w > 0.0:
			health_drop_frame_size = Vector2(frame_w, float(health_drop_sheet.get_height()))
	_setup_bgm()
	_start_bgm_menu()
	_setup_audio_sfx()
	_setup_ui_sfx()
	_apply_audio_mix_levels()
	low_spec_mode = WEB_LOW_SPEC_ENABLED and OS.has_feature("web")
	_setup_lighting_nodes()
	heroes_root.visible = false
	start_screen_active = true
	start_selection_active = false
	tutorial_screen_active = false
	pause_menu_active = false
	options_menu_active = false
	halo_index = -1
	halo_equipped = false
	halo_charge = HALO_CHARGE_MAX
	halo_recharge_delay_timer = 0.0
	halo_toggle_lock_timer = 0.0
	halo_switch_feedback_timer = 0.0
	spectral_halo_unlocked = false
	spectral_halo_count = 0
	spectral_halo_positions.clear()
	spectral_halo_velocities.clear()
	spectral_halo_hit_timers.clear()
	spectral_halo_heal_timers.clear()
	for _i in range(heroes.size()):
		spectral_halo_heal_timers.append(0.0)
	health_drops.clear()
	perfect_position_active = false
	perfect_position_feedback_timer = 0.0
	perfect_position_impact_flash_timer = 0.0
	perfect_position_sound_cooldown_timer = 0.0
	perfect_position_break_sound_cooldown_timer = 0.0
	perfect_position_inside_timer = 0.0
	perfect_position_outside_timer = 0.0
	perfect_position_active_hold_timer = 0.0
	perfect_position_sound_armed = true
	perfect_position_break_sound_armed = false
	_sync_halo_state()
	world_camera.position = arena_rect.get_center()
	world_camera.zoom = CAMERA_ZOOM_MENU
	world_camera.limit_left = int(arena_rect.position.x)
	world_camera.limit_top = int(arena_rect.position.y)
	world_camera.limit_right = int(arena_rect.end.x)
	world_camera.limit_bottom = int(arena_rect.end.y)
	set_process(true)
	queue_redraw()

func _make_hud_label_settings(font_size: int) -> LabelSettings:
	var settings: LabelSettings = LabelSettings.new()
	if hud_font != null:
		settings.font = hud_font
	settings.font_size = font_size
	settings.font_color = UI_TEXT_COLOR
	settings.outline_size = 2
	settings.outline_color = UI_OUTLINE_COLOR
	settings.shadow_size = 2
	settings.shadow_color = UI_SHADOW_COLOR
	settings.shadow_offset = Vector2(2.0, 2.0)
	return settings

func _configure_hud_style() -> void:
	wave_label.label_settings = _make_hud_label_settings(32)
	threat_label.label_settings = _make_hud_label_settings(30)
	hero_status.label_settings = _make_hud_label_settings(34)
	hint_label.label_settings = _make_hud_label_settings(22)

	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hero_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	threat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _process(delta: float) -> void:
	sfx_cooldown_timer = maxf(0.0, sfx_cooldown_timer - delta)
	perfect_position_impact_flash_timer = maxf(0.0, perfect_position_impact_flash_timer - delta)
	perfect_position_sound_cooldown_timer = maxf(0.0, perfect_position_sound_cooldown_timer - delta)
	perfect_position_break_sound_cooldown_timer = maxf(0.0, perfect_position_break_sound_cooldown_timer - delta)
	_update_gameplay_bgm_state()
	_update_bgm_loop(delta)

	if start_screen_active:
		_update_kill_flashes(delta)
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if tutorial_screen_active:
		_update_kill_flashes(delta)
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if start_selection_active:
		_update_kill_flashes(delta)
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if pause_menu_active:
		_update_dynamic_lighting(delta)
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if boss_victory_prompt_active:
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
	var play_rect: Rect2 = _playfield_rect()
	var surge_intensity: float = _wave_surge_intensity()
	var surge_attack_speed_bonus: float = WAVE_MINI_SURGE_HERO_ATK_SPEED_BONUS * surge_intensity
	var surge_damage_bonus: float = WAVE_MINI_SURGE_HERO_DAMAGE_BONUS * surge_intensity
	for hero: Hero in heroes:
		hero.set_wave_surge_boost(surge_attack_speed_bonus, surge_damage_bonus)
		hero.process_visual_tick(delta)
		hero.process_tick(delta, enemies, heroes, play_rect, projectile_spawns, player_move_input)

	_apply_halo_synergies(delta)
	for enemy: Enemy in enemies:
		enemy.process_tick(delta, heroes, play_rect, projectile_spawns, summon_spawns)
	_update_spectral_halo(delta)

	_spawn_summoned_enemies_from_queue()
	_spawn_projectiles_from_queue()
	_update_projectiles(delta)
	_cleanup_dead_enemies()
	_update_health_drops(delta)
	_validate_halo_target()
	_check_for_game_over()
	_progress_wave_timing(delta)
	_update_team_power(delta)
	_update_perfect_position_state(delta)
	_update_kill_flashes(delta)
	_update_dynamic_lighting(delta)
	_update_camera(delta)
	_update_ui()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if options_menu_active:
			if event.keycode == KEY_ESCAPE:
				_play_ui_click_sfx()
				_close_options_menu()
			return
		if event.keycode == KEY_ESCAPE:
			if pause_menu_active:
				_play_ui_click_sfx()
				_resume_from_pause()
				return
			if tutorial_screen_active:
				_play_ui_click_sfx()
				_open_start_screen()
				return
			if not start_screen_active and not start_selection_active and not tutorial_screen_active and not game_over and not upgrade_phase_active and not boss_victory_prompt_active:
				_play_ui_click_sfx()
				_open_pause_menu()
				return

		if start_screen_active and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE):
			_play_ui_start_game_sfx()
			_open_tutorial_screen()
			return

		if tutorial_screen_active and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_C):
			_play_ui_click_sfx()
			_open_starting_hero_menu()
			return

		if pause_menu_active:
			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				_play_ui_click_sfx()
				_resume_from_pause()
			elif event.keycode == KEY_H or event.keycode == KEY_M:
				_play_ui_click_sfx()
				_return_to_main_menu()
			return

		if boss_victory_prompt_active:
			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_C:
				_play_ui_click_sfx()
				_continue_after_main_boss()
			elif event.keycode == KEY_H or event.keycode == KEY_M or event.keycode == KEY_ESCAPE:
				_play_ui_click_sfx()
				_return_to_main_menu()
			return

		if start_selection_active:
			match event.keycode:
				KEY_1:
					_choose_starting_hero(0)
				KEY_2:
					_choose_starting_hero(1)
				KEY_3:
					_choose_starting_hero(2)
			return

		if game_over and (event.keycode == KEY_ENTER or event.keycode == KEY_R or event.keycode == KEY_SPACE):
			_play_ui_click_sfx()
			_return_to_main_menu()
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

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if options_menu_active:
			_handle_options_click(event.position)
			return
		if start_screen_active:
			if _start_screen_button_rect().has_point(event.position):
				_play_ui_start_game_sfx()
				_open_tutorial_screen()
				return
			if _start_screen_options_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_open_options_menu()
				return
			return
		if tutorial_screen_active:
			if _tutorial_continue_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_open_starting_hero_menu()
				return
			return
		if pause_menu_active:
			if _pause_resume_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_resume_from_pause()
				return
			if _pause_home_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_return_to_main_menu()
				return
			if _pause_options_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_open_options_menu()
				return
			return
		if boss_victory_prompt_active:
			if _boss_victory_continue_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_continue_after_main_boss()
				return
			if _boss_victory_home_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_return_to_main_menu()
				return
			return
		if game_over:
			if _game_over_button_rect().has_point(event.position):
				_play_ui_click_sfx()
				_return_to_main_menu()
			return
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

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		options_drag_slider = -1
		return

	if event is InputEventMouseMotion and options_menu_active and options_drag_slider >= 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if options_drag_slider == 0:
			_set_music_volume_percent(_slider_value_from_screen_point(event.position, _options_music_slider_rect_screen()))
		elif options_drag_slider == 1:
			_set_sfx_volume_percent(_slider_value_from_screen_point(event.position, _options_sfx_slider_rect_screen()))
		return

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
	start_card_tank_custom = load(START_CARD_TANK_CUSTOM_PATH) as Texture2D
	start_card_ranger_custom = load(START_CARD_RANGER_CUSTOM_PATH) as Texture2D

func _load_upgrade_card_textures() -> void:
	upgrade_card_ranger_remedy = load(UPGRADE_CARD_RANGER_REMEDY_PATH) as Texture2D
	upgrade_card_halo_conduction = load(UPGRADE_CARD_HALO_CONDUCTION_PATH) as Texture2D
	upgrade_card_golden_surge = load(UPGRADE_CARD_GOLDEN_SURGE_PATH) as Texture2D
	upgrade_card_rogue_precision = load(UPGRADE_CARD_ROGUE_PRECISION_PATH) as Texture2D
	upgrade_card_tank_march = load(UPGRADE_CARD_TANK_MARCH_PATH) as Texture2D
	upgrade_card_heavy_attack_plus = load(UPGRADE_CARD_HEAVY_ATTACK_PLUS_PATH) as Texture2D
	upgrade_card_triple_arrows_plus = load(UPGRADE_CARD_TRIPLE_ARROWS_PLUS_PATH) as Texture2D
	upgrade_card_triple_arrows = load(UPGRADE_CARD_TRIPLE_ARROWS_PATH) as Texture2D
	upgrade_card_spectral_halo = load(UPGRADE_CARD_SPECTRAL_HALO_PATH) as Texture2D
	upgrade_card_plus_1_spectral_halo = load(UPGRADE_CARD_PLUS_1_SPECTRAL_HALO_PATH) as Texture2D
	upgrade_card_heavy_attack = load(UPGRADE_CARD_HEAVY_ATTACK_PATH) as Texture2D
	upgrade_card_tank_bastion = load(UPGRADE_CARD_TANK_BASTION_PATH) as Texture2D
	upgrade_card_shadow_zip = load(UPGRADE_CARD_SHADOW_ZIP_PATH) as Texture2D
	upgrade_card_shadow_zip_plus = load(UPGRADE_CARD_SHADOW_ZIP_PLUS_PATH) as Texture2D
	upgrade_card_halo_reservoir = load(UPGRADE_CARD_HALO_RESERVOIR_PATH) as Texture2D
	upgrade_card_rogue_overdrive = load(UPGRADE_CARD_ROGUE_OVERDRIVE_PATH) as Texture2D
	upgrade_card_archer_focus = load(UPGRADE_CARD_ARCHER_FOCUS_PATH) as Texture2D
	upgrade_card_team_training = load(UPGRADE_CARD_TEAM_TRAINING_PATH) as Texture2D

func _custom_upgrade_card_texture(upgrade_id: int) -> Texture2D:
	match upgrade_id:
		UPGRADE_RANGER_REMEDY:
			return upgrade_card_ranger_remedy
		UPGRADE_HALO_FLOW:
			return upgrade_card_halo_conduction
		UPGRADE_GOLDEN_SURGE:
			return upgrade_card_golden_surge
		UPGRADE_ROGUE_PRECISION:
			return upgrade_card_rogue_precision
		UPGRADE_TANK_MARCH:
			return upgrade_card_tank_march
		UPGRADE_TANK_HEAVY_ATTACK_PLUS:
			return upgrade_card_heavy_attack_plus
		UPGRADE_RANGER_TRIPLE_ARROWS_PLUS:
			return upgrade_card_triple_arrows_plus
		UPGRADE_RANGER_TRIPLE_ARROWS:
			return upgrade_card_triple_arrows
		UPGRADE_HALO_SPECTER:
			return upgrade_card_spectral_halo
		UPGRADE_HALO_ECHO:
			return upgrade_card_plus_1_spectral_halo
		UPGRADE_TANK_HEAVY_ATTACK:
			return upgrade_card_heavy_attack
		UPGRADE_TANK_BASTION:
			return upgrade_card_tank_bastion
		UPGRADE_ROGUE_TWIN_FANGS:
			return upgrade_card_shadow_zip
		UPGRADE_ROGUE_TWIN_FANGS_PLUS:
			return upgrade_card_shadow_zip_plus
		UPGRADE_HALO_RESERVOIR:
			return upgrade_card_halo_reservoir
		UPGRADE_ROGUE_OVERDRIVE:
			return upgrade_card_rogue_overdrive
		UPGRADE_RANGER_FOCUS:
			return upgrade_card_archer_focus
		UPGRADE_TEAM_TRAINING:
			return upgrade_card_team_training
	return null

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

func _prepare_start_screen_title_logo(texture: Texture2D) -> Texture2D:
	if texture == null:
		return null
	var img: Image = texture.get_image()
	if img == null or img.is_empty():
		return texture

	img.convert(Image.FORMAT_RGBA8)
	var bg: Color = img.get_pixel(0, 0)
	var bg_r: float = bg.r
	var bg_g: float = bg.g
	var bg_b: float = bg.b
	var keyed_any: bool = false
	var inner_dist: float = 0.11
	var outer_dist: float = 0.2
	var width: int = img.get_width()
	var height: int = img.get_height()

	for y in range(height):
		for x in range(width):
			var c: Color = img.get_pixel(x, y)
			var dr: float = c.r - bg_r
			var dg: float = c.g - bg_g
			var db: float = c.b - bg_b
			var dist: float = sqrt(dr * dr + dg * dg + db * db)
			if dist <= inner_dist:
				img.set_pixel(x, y, Color(c.r, c.g, c.b, 0.0))
				keyed_any = true
			elif dist <= outer_dist:
				var t: float = (dist - inner_dist) / maxf(outer_dist - inner_dist, 0.0001)
				var a: float = clampf(c.a * t, 0.0, 1.0)
				if a < c.a:
					keyed_any = true
				img.set_pixel(x, y, Color(c.r, c.g, c.b, a))

	if not keyed_any:
		return texture
	return ImageTexture.create_from_image(img)

func _draw_texture_fit(texture: Texture2D, rect: Rect2, modulate: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	var draw_rect_fit: Rect2 = _get_texture_fit_rect(texture, rect)
	if draw_rect_fit.size.x <= 0.0 or draw_rect_fit.size.y <= 0.0:
		return
	draw_texture_rect(texture, draw_rect_fit, false, modulate)

func _get_texture_fit_rect(texture: Texture2D, rect: Rect2) -> Rect2:
	if texture == null:
		return Rect2(rect.position, Vector2.ZERO)
	var tex_size: Vector2 = texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return Rect2(rect.position, Vector2.ZERO)
	var scale: float = minf(rect.size.x / tex_size.x, rect.size.y / tex_size.y)
	var draw_size: Vector2 = tex_size * scale
	return Rect2(rect.position + (rect.size - draw_size) * 0.5, draw_size)

func _draw_capsule_outline(rect: Rect2, color: Color, width: float = 1.6) -> void:
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var radius: float = minf(rect.size.x * 0.5, rect.size.y * 0.5)
	if radius <= 0.0:
		return
	var cx: float = rect.get_center().x
	var top_cy: float = rect.position.y + radius
	var bottom_cy: float = rect.end.y - radius
	draw_arc(Vector2(cx, top_cy), radius, PI, TAU, 28, color, width)
	draw_arc(Vector2(cx, bottom_cy), radius, 0.0, PI, 28, color, width)
	var left_x: float = cx - radius
	var right_x: float = cx + radius
	draw_line(Vector2(left_x, top_cy), Vector2(left_x, bottom_cy), color, width)
	draw_line(Vector2(right_x, top_cy), Vector2(right_x, bottom_cy), color, width)

func _prepare_vertical_flip_texture(texture: Texture2D) -> Texture2D:
	if texture == null:
		return null
	var img: Image = texture.get_image()
	if img == null or img.is_empty():
		return texture
	img.flip_y()
	return ImageTexture.create_from_image(img)

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
	var in_start_menu: bool = start_selection_active or start_screen_active or tutorial_screen_active
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

		if start_selection_active or start_screen_active or tutorial_screen_active or pause_menu_active or hero.health <= 0.0:
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
	var cycle_wave: int = _current_cycle_wave()
	boss_spawn_pending = cycle_wave >= 5 and (cycle_wave % 5 == 0)
	boss_spawn_kind = ENEMY_FINAL_BOSS if (cycle_wave >= 10 and cycle_wave % 10 == 0) else ENEMY_BOSS
	if boss_spawn_kind == ENEMY_FINAL_BOSS:
		final_boss_prompt_pending = true
	if boss_spawn_pending:
		# Boss waves open as a clean boss-only phase; adds ramp from boss summons over time.
		spawn_remaining = 0
		spawn_burst_remaining = 0
		wave_surge_active = false
		wave_surge_timer = 0.0
		wave_surge_cooldown_timer = 0.0
		wave_surge_recovery_timer = 0.0
	else:
		var difficulty_wave: int = _difficulty_wave_value()
		var cycle_bonus: int = endless_cycle * 8
		var gradual_steps: int = max(0, cycle_wave - WAVE_GRADUAL_EXTRA_START + 1)
		var gradual_bonus: int = mini(WAVE_GRADUAL_EXTRA_CAP + endless_cycle * 6, gradual_steps * WAVE_GRADUAL_EXTRA_PER_WAVE)
		spawn_remaining = WAVE_BASE_ENEMIES + cycle_wave * WAVE_LINEAR_ENEMIES + int(floor(float(difficulty_wave) * WAVE_SCALING_ENEMIES)) + cycle_bonus + gradual_bonus
		spawn_burst_remaining = _roll_spawn_burst_count(cycle_wave)
		wave_surge_active = false
		wave_surge_timer = 0.0
		wave_surge_recovery_timer = 0.0
		wave_surge_cooldown_timer = _roll_next_surge_cooldown(cycle_wave)
	spawn_timer = 0.18
	spawning = true
	waiting_for_next_wave = false
	boss_victory_prompt_active = false
	upgrade_phase_active = false
	intermission_timer = 0.0
	_set_world_visible_for_upgrade(true)
	_sync_halo_state()

func _update_spawning(delta: float) -> void:
	if not spawning:
		return

	_update_wave_surge(delta)
	spawn_timer -= delta
	var difficulty_wave: int = _difficulty_wave_value()
	var interval: float = maxf(WAVE_SPAWN_INTERVAL_START - float(difficulty_wave) * WAVE_SPAWN_INTERVAL_DECAY, WAVE_SPAWN_INTERVAL_FLOOR)
	if wave_surge_active:
		interval *= WAVE_MINI_SURGE_INTERVAL_MULT
	elif wave_surge_recovery_timer > 0.0:
		interval *= 1.24
	while spawn_timer <= 0.0 and (spawn_remaining > 0 or boss_spawn_pending):
		if boss_spawn_pending:
			_spawn_boss()
			boss_spawn_pending = false
			spawn_timer += interval * 1.75
		elif spawn_remaining > 0:
			var batch_count: int = _next_spawn_batch_size()
			for _i in range(batch_count):
				if spawn_remaining <= 0:
					break
				_spawn_enemy()
				spawn_remaining -= 1
			spawn_timer += interval * randf_range(0.86, 1.18)

	if spawn_remaining <= 0 and not boss_spawn_pending:
		spawning = false
		wave_surge_active = false
		wave_surge_timer = 0.0
		wave_surge_cooldown_timer = 0.0
		wave_surge_recovery_timer = 0.0

func _roll_spawn_burst_count(cycle_wave: int) -> int:
	if cycle_wave < WAVE_BURST_WAVE_START:
		return 0
	var max_bonus: int = WAVE_BURST_WAVE9_BONUS if cycle_wave >= 9 else 0
	return randi_range(WAVE_BURST_MIN, WAVE_BURST_MAX + max_bonus)

func _roll_next_surge_cooldown(cycle_wave: int) -> float:
	if cycle_wave < WAVE_MINI_SURGE_WAVE_START:
		return 9999.0
	var scaled: float = WAVE_MINI_SURGE_COOLDOWN_BASE - float(cycle_wave - WAVE_MINI_SURGE_WAVE_START) * WAVE_MINI_SURGE_COOLDOWN_WAVE_SCALE
	var base: float = maxf(WAVE_MINI_SURGE_COOLDOWN_MIN, scaled)
	return base + randf_range(-0.9, 1.2)

func _wave_has_boss_pressure() -> bool:
	if boss_spawn_pending:
		return true
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		if enemy.kind == ENEMY_BOSS or enemy.kind == ENEMY_FINAL_BOSS:
			return true
	return false

func _update_wave_surge(delta: float) -> void:
	if _current_cycle_wave() < WAVE_MINI_SURGE_WAVE_START:
		wave_surge_active = false
		wave_surge_timer = 0.0
		wave_surge_cooldown_timer = 0.0
		wave_surge_recovery_timer = 0.0
		return

	if _wave_has_boss_pressure():
		wave_surge_active = false
		wave_surge_timer = 0.0
		wave_surge_recovery_timer = 0.0
		return

	if wave_surge_active:
		wave_surge_timer = maxf(0.0, wave_surge_timer - delta)
		if wave_surge_timer <= 0.0:
			wave_surge_active = false
			wave_surge_recovery_timer = WAVE_MINI_SURGE_RECOVERY_DURATION + randf_range(-0.3, 0.3)
			wave_surge_cooldown_timer = _roll_next_surge_cooldown(_current_cycle_wave())
		return

	if wave_surge_recovery_timer > 0.0:
		wave_surge_recovery_timer = maxf(0.0, wave_surge_recovery_timer - delta)
		return

	wave_surge_cooldown_timer -= delta
	if wave_surge_cooldown_timer > 0.0 or spawn_remaining <= 0:
		return

	wave_surge_active = true
	var cycle_wave: int = _current_cycle_wave()
	var duration: float = minf(
		WAVE_MINI_SURGE_DURATION_MAX,
		WAVE_MINI_SURGE_DURATION_BASE + float(max(0, cycle_wave - WAVE_MINI_SURGE_WAVE_START)) * WAVE_MINI_SURGE_DURATION_WAVE_SCALE
	)
	wave_surge_timer = duration + randf_range(-0.35, 0.48)
	spawn_burst_remaining += WAVE_MINI_SURGE_EXTRA_BATCH + (1 if cycle_wave >= 10 else 0)
	_add_camera_shake(0.32)

func _next_spawn_batch_size() -> int:
	var cycle_wave: int = _current_cycle_wave()
	var batch: int = 1
	if cycle_wave >= WAVE_BURST_WAVE_START and spawn_burst_remaining > 0:
		batch += 1
		if cycle_wave >= 8 and randf() < 0.42:
			batch += 1
		spawn_burst_remaining -= 1
		if spawn_burst_remaining <= 0:
			spawn_burst_remaining = _roll_spawn_burst_count(cycle_wave)
	if wave_surge_active:
		batch += WAVE_MINI_SURGE_EXTRA_BATCH
		if cycle_wave >= 10:
			batch += 1
	elif wave_surge_recovery_timer > 0.0:
		batch = maxi(1, batch - 1)
	return batch

func _wave_surge_intensity() -> float:
	if wave_surge_active:
		return 1.0
	if wave_surge_recovery_timer > 0.0:
		return clampf(wave_surge_recovery_timer / maxf(WAVE_MINI_SURGE_RECOVERY_DURATION, 0.01), 0.0, 1.0) * 0.3
	return 0.0

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
		var control_active: bool = i == halo_index and hero.health > 0.0 and not upgrade_phase_active and not game_over and not boss_victory_prompt_active
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
	enemy.configure(kind, _random_spawn_point(), target, _difficulty_wave_value())
	_connect_enemy_signals(enemy)
	enemies_root.add_child(enemy)
	enemies.append(enemy)

func _spawn_boss() -> void:
	var enemy: Enemy = EnemyScript.new()
	var kind: int = boss_spawn_kind
	var target: Hero = _pick_spawn_target(kind)
	enemy.configure(kind, _boss_spawn_point(), target, _difficulty_wave_value())
	_connect_enemy_signals(enemy)
	enemies_root.add_child(enemy)
	enemies.append(enemy)
	if kind == ENEMY_FINAL_BOSS:
		_play_ui_final_boss_appear_sfx()

func _spawn_summoned_enemies_from_queue() -> void:
	if summon_spawns.is_empty():
		return

	for data: Dictionary in summon_spawns:
		var kind: int = int(data.get("kind", ENEMY_SWARM))
		if kind == ENEMY_BOSS or kind == ENEMY_FINAL_BOSS:
			kind = ENEMY_SWARM
		var spawn_pos: Vector2 = data.get("position", _random_spawn_point())
		spawn_pos = _clamp_point_to_arena(spawn_pos)
		var target: Hero = _pick_spawn_target(kind)
		var enemy: Enemy = EnemyScript.new()
		enemy.configure(kind, spawn_pos, target, _difficulty_wave_value())
		_connect_enemy_signals(enemy)
		enemies_root.add_child(enemy)
		enemies.append(enemy)

	summon_spawns.clear()

func _count_active_enemies_by_kind(kind: int) -> int:
	var count: int = 0
	for enemy: Enemy in enemies:
		if enemy.health > 0.0 and int(enemy.kind) == kind:
			count += 1
	return count

func _pick_enemy_kind() -> int:
	var d_wave: int = _difficulty_wave_value()
	var cycle_wave: int = _current_cycle_wave()
	var elite_count: int = _count_active_enemies_by_kind(ENEMY_ELITE)
	var ranged_count: int = _count_active_enemies_by_kind(ENEMY_RANGED)
	var flyer_count: int = _count_active_enemies_by_kind(ENEMY_FLYER)
	var thrower_count: int = _count_active_enemies_by_kind(ENEMY_THROWER)

	var elite_cap: int = 3 if cycle_wave < 8 else 4
	var flyer_cap: int = 0
	if cycle_wave >= 4:
		flyer_cap = 3
	if cycle_wave >= 8:
		flyer_cap = 5
	var thrower_cap: int = 0
	if cycle_wave >= 3:
		thrower_cap = 2
	if cycle_wave >= 8:
		thrower_cap = 4
	var projectile_enemy_cap: int = 3 if cycle_wave < 6 else (5 if cycle_wave < 10 else 7)
	var projectile_enemy_count: int = ranged_count + thrower_count

	var weight_swarm: float = 1.0 + float(max(0, cycle_wave - 6)) * 0.03
	var weight_elite: float = minf(0.035 + float(d_wave) * 0.006, 0.12)
	var weight_ranged: float = minf(0.06 + float(d_wave) * 0.0032, 0.115)
	var weight_flyer: float = 0.0
	var weight_thrower: float = 0.0
	if cycle_wave >= 4:
		weight_flyer = minf(0.05 + float(cycle_wave - 4) * 0.004, 0.11)
	if cycle_wave >= 3:
		weight_thrower = minf(0.045 + float(cycle_wave - 3) * 0.0038, 0.105)

	if elite_count >= elite_cap:
		weight_elite = 0.0
	if flyer_count >= flyer_cap:
		weight_flyer = 0.0
	if thrower_count >= thrower_cap or projectile_enemy_count >= projectile_enemy_cap:
		weight_thrower = 0.0
	if ranged_count >= projectile_enemy_cap or projectile_enemy_count >= projectile_enemy_cap:
		weight_ranged = 0.0

	var total_weight: float = weight_swarm + weight_elite + weight_ranged + weight_flyer + weight_thrower
	if total_weight <= 0.001:
		return ENEMY_SWARM

	var roll: float = randf() * total_weight
	if roll < weight_swarm:
		return ENEMY_SWARM
	roll -= weight_swarm
	if roll < weight_elite:
		return ENEMY_ELITE
	roll -= weight_elite
	if roll < weight_ranged:
		return ENEMY_RANGED
	roll -= weight_ranged
	if roll < weight_flyer:
		return ENEMY_FLYER
	roll -= weight_flyer
	if roll < weight_thrower:
		return ENEMY_THROWER
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
		ENEMY_FLYER:
			preferred_kind = HERO_ROGUE
		ENEMY_RANGED:
			preferred_kind = HERO_RANGER
		ENEMY_THROWER:
			preferred_kind = HERO_RANGER
		ENEMY_ELITE:
			preferred_kind = HERO_ROGUE
		ENEMY_BOSS:
			preferred_kind = HERO_KNIGHT
		ENEMY_FINAL_BOSS:
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

func _playfield_rect() -> Rect2:
	var min_x: float = arena_rect.position.x + WALL_SIDE_BLOCK + PLAYFIELD_INNER_PAD
	var max_x: float = arena_rect.end.x - WALL_SIDE_BLOCK - PLAYFIELD_INNER_PAD
	var min_y: float = arena_rect.position.y + WALL_TOP_BLOCK + PLAYFIELD_INNER_PAD
	var max_y: float = arena_rect.end.y - WALL_BOTTOM_BLOCK - PLAYFIELD_INNER_PAD
	if max_x <= min_x or max_y <= min_y:
		return arena_rect
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _random_spawn_point() -> Vector2:
	var play_rect: Rect2 = _playfield_rect()
	var edge: int = randi() % 4
	var x: float = randf_range(play_rect.position.x, play_rect.end.x)
	var y: float = randf_range(play_rect.position.y, play_rect.end.y)
	match edge:
		0:
			return Vector2(x, play_rect.position.y + 6.0)
		1:
			return Vector2(x, play_rect.end.y - 6.0)
		2:
			return Vector2(play_rect.position.x + 6.0, y)
		_:
			return Vector2(play_rect.end.x - 6.0, y)

func _boss_spawn_point() -> Vector2:
	return _playfield_rect().get_center()

func _clamp_point_to_arena(point: Vector2) -> Vector2:
	var play_rect: Rect2 = _playfield_rect()
	var x: float = clampf(point.x, play_rect.position.x + 12.0, play_rect.end.x - 12.0)
	var y: float = clampf(point.y, play_rect.position.y + 12.0, play_rect.end.y - 12.0)
	return Vector2(x, y)

func _cleanup_dead_enemies() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if enemies[i].health <= 0.0:
			var dead_enemy: Enemy = enemies[i]
			var kill_mult: float = PERFECT_POSITION_KILL_FLASH_MULT if perfect_position_active else 1.0
			_spawn_kill_flash(dead_enemy.global_position, dead_enemy.body_radius, kill_mult)
			_add_camera_shake(0.2 + team_power * 0.45 + (PERFECT_POSITION_HIT_SHAKE_BONUS if perfect_position_active else 0.0))
			_maybe_spawn_health_drop(dead_enemy)
			enemies[i].queue_free()
			enemies.remove_at(i)

func _spawn_kill_flash(position: Vector2, body_radius: float, intensity: float = 1.0) -> void:
	var clamped_intensity: float = clampf(intensity, 0.7, 2.2)
	var duration: float = KILL_FLASH_DURATION * lerpf(0.9, 1.35, clampf(clamped_intensity - 1.0, 0.0, 1.0))
	var flash: Dictionary = {
		"position": position,
		"time": duration,
		"max_time": duration,
		"radius": maxf(16.0, body_radius * 2.5) * clamped_intensity
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

func _update_perfect_position_state(delta: float) -> void:
	perfect_position_feedback_timer = maxf(0.0, perfect_position_feedback_timer - delta)
	var alive: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive.append(hero)

	var all_inside_inner_ring: bool = not alive.is_empty()
	var inner_radius_sq: float = PERFECT_POSITION_RING_RADIUS * PERFECT_POSITION_RING_RADIUS
	for hero: Hero in alive:
		if hero.global_position.distance_squared_to(team_power_center) > inner_radius_sq:
			all_inside_inner_ring = false
			break

	if all_inside_inner_ring:
		perfect_position_inside_timer += delta
		perfect_position_outside_timer = 0.0
		if perfect_position_active:
			perfect_position_active_hold_timer += delta
	else:
		perfect_position_outside_timer += delta
		perfect_position_inside_timer = 0.0
		if perfect_position_outside_timer >= PERFECT_POSITION_SOUND_REARM_TIME:
			perfect_position_sound_armed = true

	var entering: bool = false
	if perfect_position_active:
		if not all_inside_inner_ring and perfect_position_outside_timer >= PERFECT_POSITION_EXIT_GRACE_TIME:
			perfect_position_active = false
			var can_play_break: bool = perfect_position_break_sound_armed \
				and perfect_position_break_sound_cooldown_timer <= 0.0 \
				and perfect_position_active_hold_timer >= PERFECT_POSITION_BREAK_MIN_ACTIVE_TIME
			if can_play_break:
				_play_perfect_position_break_sfx()
				perfect_position_break_sound_cooldown_timer = PERFECT_POSITION_BREAK_SOUND_COOLDOWN
				perfect_position_break_sound_armed = false
			perfect_position_active_hold_timer = 0.0
	else:
		if all_inside_inner_ring and perfect_position_inside_timer >= PERFECT_POSITION_ENTER_STABLE_TIME:
			perfect_position_active = true
			entering = true
			perfect_position_active_hold_timer = 0.0

	if not perfect_position_active:
		perfect_position_feedback_timer = 0.0
		perfect_position_active_hold_timer = 0.0
		return

	if entering:
		perfect_position_feedback_timer = PERFECT_POSITION_FEEDBACK_DURATION
		_spawn_kill_flash(team_power_center, 26.0, 1.35)
		_add_camera_shake(0.48)
		if perfect_position_sound_armed and perfect_position_sound_cooldown_timer <= 0.0:
			_play_perfect_position_sfx()
			perfect_position_sound_cooldown_timer = PERFECT_POSITION_SOUND_COOLDOWN
			perfect_position_sound_armed = false
		perfect_position_break_sound_armed = true

func _spawn_projectiles_from_queue() -> void:
	if projectile_spawns.is_empty():
		return
	for data: Dictionary in projectile_spawns:
		var projectile: Projectile = ProjectileScript.new()
		projectile.configure_from_data(data)
		projectiles_root.add_child(projectile)
		projectiles.append(projectile)
	projectile_spawns.clear()

func _add_spectral_halo_slot(spawn_position: Vector2 = Vector2.ZERO) -> void:
	if spectral_halo_positions.size() >= SPECTRAL_HALO_MAX_COUNT:
		return
	var spawn_pos: Vector2 = spawn_position
	if spawn_pos == Vector2.ZERO:
		spawn_pos = _camera_target_position()
	spectral_halo_positions.append(_clamp_point_to_arena(spawn_pos))
	spectral_halo_velocities.append(Vector2.RIGHT.rotated(randf() * TAU) * SPECTRAL_HALO_SPEED)
	spectral_halo_hit_timers.append(0.08)

func _ensure_spectral_halo_slots() -> void:
	if not spectral_halo_unlocked:
		spectral_halo_positions.clear()
		spectral_halo_velocities.clear()
		spectral_halo_hit_timers.clear()
		spectral_halo_count = 0
		return

	spectral_halo_count = clampi(spectral_halo_count, 1, SPECTRAL_HALO_MAX_COUNT)
	while spectral_halo_positions.size() < spectral_halo_count:
		_add_spectral_halo_slot()
	while spectral_halo_velocities.size() < spectral_halo_count:
		spectral_halo_velocities.append(Vector2.RIGHT.rotated(randf() * TAU) * SPECTRAL_HALO_SPEED)
	while spectral_halo_hit_timers.size() < spectral_halo_count:
		spectral_halo_hit_timers.append(0.08)
	while spectral_halo_positions.size() > spectral_halo_count:
		spectral_halo_positions.remove_at(spectral_halo_positions.size() - 1)
	while spectral_halo_velocities.size() > spectral_halo_count:
		spectral_halo_velocities.remove_at(spectral_halo_velocities.size() - 1)
	while spectral_halo_hit_timers.size() > spectral_halo_count:
		spectral_halo_hit_timers.remove_at(spectral_halo_hit_timers.size() - 1)

func _spectral_halo_bounds() -> Rect2:
	var margin: float = SPECTRAL_HALO_RADIUS + 6.0
	var view_rect: Rect2 = _viewport_rect_world().grow(-margin)
	var clamp_rect: Rect2 = _playfield_rect().grow(-margin)
	var intersection: Rect2 = clamp_rect.intersection(view_rect)
	if intersection.size.x > 48.0 and intersection.size.y > 48.0:
		return intersection
	return clamp_rect

func _update_spectral_halo(delta: float) -> void:
	if not spectral_halo_unlocked:
		return
	if spectral_halo_count <= 0:
		spectral_halo_count = 1
	_ensure_spectral_halo_slots()

	if spectral_halo_heal_timers.size() != heroes.size():
		spectral_halo_heal_timers.clear()
		for _i in range(heroes.size()):
			spectral_halo_heal_timers.append(0.0)

	var bounds: Rect2 = _spectral_halo_bounds()
	for h in range(spectral_halo_count):
		var velocity: Vector2 = spectral_halo_velocities[h]
		if velocity.length_squared() <= 0.0001:
			velocity = Vector2.RIGHT.rotated(randf() * TAU) * SPECTRAL_HALO_SPEED

		var pos: Vector2 = spectral_halo_positions[h] + velocity * delta
		var bounced: bool = false
		if pos.x < bounds.position.x:
			pos.x = bounds.position.x
			velocity.x = absf(velocity.x)
			bounced = true
		elif pos.x > bounds.end.x:
			pos.x = bounds.end.x
			velocity.x = -absf(velocity.x)
			bounced = true
		if pos.y < bounds.position.y:
			pos.y = bounds.position.y
			velocity.y = absf(velocity.y)
			bounced = true
		elif pos.y > bounds.end.y:
			pos.y = bounds.end.y
			velocity.y = -absf(velocity.y)
			bounced = true
		if bounced:
			var bounce_jitter: float = randf_range(-0.16, 0.16)
			velocity = velocity.rotated(bounce_jitter)
			if velocity.length_squared() <= 0.0001:
				velocity = Vector2.RIGHT.rotated(randf() * TAU)
			velocity = velocity.normalized() * SPECTRAL_HALO_SPEED

		spectral_halo_positions[h] = pos
		spectral_halo_velocities[h] = velocity
		spectral_halo_hit_timers[h] = maxf(0.0, spectral_halo_hit_timers[h] - delta)

	for i in range(heroes.size()):
		spectral_halo_heal_timers[i] = maxf(0.0, spectral_halo_heal_timers[i] - delta)

	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		if hero.health <= 0.0:
			continue
		if spectral_halo_heal_timers[i] > 0.0:
			continue
		var heal_dist: float = SPECTRAL_HALO_RADIUS + hero.body_radius + SPECTRAL_HALO_HEAL_RADIUS_BONUS
		var healed: bool = false
		for h in range(spectral_halo_count):
			if spectral_halo_positions[h].distance_squared_to(hero.global_position) <= heal_dist * heal_dist:
				healed = true
				break
		if not healed:
			continue
		var heal_amount: float = SPECTRAL_HALO_HEAL_AMOUNT + team_power * 3.0
		hero.heal(heal_amount)
		hero.trigger_halo_switch_feedback()
		_spawn_kill_flash(hero.global_position, hero.body_radius * 0.8, 0.78)
		spectral_halo_heal_timers[i] = SPECTRAL_HALO_HEAL_COOLDOWN

	for h in range(spectral_halo_count):
		if spectral_halo_hit_timers[h] > 0.0:
			continue
			var halo_pos: Vector2 = spectral_halo_positions[h]
			var halo_velocity: Vector2 = Vector2.ZERO
			if h >= 0 and h < spectral_halo_velocities.size():
				halo_velocity = spectral_halo_velocities[h]
			for enemy: Enemy in enemies:
				if enemy.health <= 0.0:
					continue
				var contact_dist: float = SPECTRAL_HALO_RADIUS + enemy.body_radius
				if halo_pos.distance_squared_to(enemy.global_position) > contact_dist * contact_dist:
					continue
				enemy.set_damage_source(halo_pos)
				enemy.set_damage_direction(halo_velocity)
				var contact_damage: float = SPECTRAL_HALO_CONTACT_DAMAGE * (1.0 + team_power * 0.75)
				enemy.take_damage(contact_damage)
				spectral_halo_hit_timers[h] = SPECTRAL_HALO_HIT_COOLDOWN
				_add_camera_shake(0.14)
				break

func _update_projectiles(delta: float) -> void:
	if projectiles.is_empty():
		return

	var extended_arena: Rect2 = _playfield_rect().grow(48.0)
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
						enemy.set_damage_direction(projectile.velocity)
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
		pause_menu_active = false
		boss_victory_prompt_active = false
		halo_equipped = false
		_stop_bgm()
		heroes_root.visible = false
		enemies_root.visible = false
		projectiles_root.visible = false
		_sync_halo_state()

func _progress_wave_timing(delta: float) -> void:
	if spawning or game_over:
		return

	if enemies.is_empty() and not waiting_for_next_wave:
		if final_boss_prompt_pending and boss_spawn_kind == ENEMY_FINAL_BOSS:
			_open_boss_victory_prompt()
			return
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

func _open_boss_victory_prompt() -> void:
	final_boss_prompt_pending = false
	waiting_for_next_wave = false
	upgrade_phase_active = false
	boss_victory_prompt_active = true
	intermission_timer = 0.0
	halo_equipped = false
	_set_world_visible_for_upgrade(false)
	_sync_halo_state()

func _continue_after_main_boss() -> void:
	boss_victory_prompt_active = false
	final_boss_prompt_pending = false
	endless_cycle += 1
	waiting_for_next_wave = false
	upgrade_phase_active = false
	intermission_timer = 0.0
	spawning = false
	health_drops.clear()
	_revive_all_heroes_for_continue()
	_set_world_visible_for_upgrade(true)
	_sync_halo_state()
	_start_wave()

func _revive_all_heroes_for_continue() -> void:
	var anchor: Vector2 = _camera_target_position()
	if heroes.is_empty():
		return
	var revive_offsets: Array[Vector2] = [
		Vector2(0.0, -14.0),
		Vector2(-56.0, 42.0),
		Vector2(56.0, 42.0)
	]
	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		var was_dead: bool = hero.health <= 0.0
		hero.health = hero.max_health
		if was_dead:
			hero.global_position = _clamp_point_to_arena(anchor + revive_offsets[i % revive_offsets.size()])
		hero.current_velocity = Vector2.ZERO
		hero.knockback_velocity = Vector2.ZERO
		hero.pending_damage_source = Vector2.ZERO
		hero.queue_redraw()

func _maybe_spawn_health_drop(dead_enemy: Enemy) -> void:
	if dead_enemy == null:
		return
	var kind: int = int(dead_enemy.kind)
	var drop_chance: float = 0.0
	var heal_amount: float = 0.0
	var drop_radius: float = 0.0
	match kind:
		ENEMY_SWARM:
			drop_chance = 0.09
			heal_amount = 10.0
			drop_radius = 6.0
		ENEMY_FLYER:
			drop_chance = 0.1
			heal_amount = 11.0
			drop_radius = 6.2
		ENEMY_RANGED:
			drop_chance = 0.13
			heal_amount = 12.0
			drop_radius = 6.4
		ENEMY_THROWER:
			drop_chance = 0.14
			heal_amount = 13.0
			drop_radius = 6.6
		ENEMY_ELITE:
			drop_chance = 0.24
			heal_amount = 18.0
			drop_radius = 7.2
		ENEMY_BOSS:
			drop_chance = 1.0
			heal_amount = 28.0
			drop_radius = 8.8
		ENEMY_FINAL_BOSS:
			drop_chance = 1.0
			heal_amount = 42.0
			drop_radius = 10.0
		_:
			return

	if randf() > drop_chance:
		return
	_spawn_health_drop(dead_enemy.global_position, heal_amount, drop_radius)
	if kind == ENEMY_BOSS and randf() < 0.45:
		_spawn_health_drop(dead_enemy.global_position + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0)), heal_amount * 0.65, 7.4)

func _spawn_health_drop(position: Vector2, heal_amount: float, drop_radius: float) -> void:
	if heal_amount <= 0.0:
		return
	var burst_velocity: Vector2 = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(22.0, 78.0)
	var drop: Dictionary = {
		"position": _clamp_point_to_arena(position),
		"velocity": burst_velocity,
		"heal": heal_amount,
		"radius": maxf(5.0, drop_radius),
		"life": HEALTH_DROP_LIFETIME,
		"pulse": randf() * TAU
	}
	health_drops.append(drop)

func _update_health_drops(delta: float) -> void:
	if health_drops.is_empty():
		return
	var attract_radius_sq: float = HEALTH_DROP_ATTRACT_RADIUS * HEALTH_DROP_ATTRACT_RADIUS
	for i in range(health_drops.size() - 1, -1, -1):
		var drop: Dictionary = health_drops[i]
		var pos_variant: Variant = drop.get("position", Vector2.ZERO)
		var vel_variant: Variant = drop.get("velocity", Vector2.ZERO)
		var pos: Vector2 = pos_variant if pos_variant is Vector2 else Vector2.ZERO
		var vel: Vector2 = vel_variant if vel_variant is Vector2 else Vector2.ZERO
		var heal_amount: float = float(drop.get("heal", 0.0))
		var radius: float = float(drop.get("radius", 6.0))
		var life: float = float(drop.get("life", HEALTH_DROP_LIFETIME)) - delta
		if life <= 0.0:
			health_drops.remove_at(i)
			continue

		var nearest_hero: Hero = null
		var nearest_dist_sq: float = INF
		for hero: Hero in heroes:
			if hero.health <= 0.0:
				continue
			if hero.health >= hero.max_health - 0.5:
				continue
			var dist_sq: float = pos.distance_squared_to(hero.global_position)
			if dist_sq < nearest_dist_sq and dist_sq <= attract_radius_sq:
				nearest_dist_sq = dist_sq
				nearest_hero = hero
		if nearest_hero != null:
			var to_hero: Vector2 = nearest_hero.global_position - pos
			if to_hero.length_squared() > 0.0001:
				vel += to_hero.normalized() * HEALTH_DROP_PULL_SPEED * delta
				vel = vel.limit_length(HEALTH_DROP_PULL_SPEED)

		pos += vel * delta
		vel = vel.move_toward(Vector2.ZERO, HEALTH_DROP_DRAG * delta)
		pos = _clamp_point_to_arena(pos)

		var picked_up: bool = false
		for hero: Hero in heroes:
			if hero.health <= 0.0:
				continue
			var pickup_dist: float = hero.body_radius + radius + HEALTH_DROP_PICKUP_PAD
			if pos.distance_squared_to(hero.global_position) > pickup_dist * pickup_dist:
				continue
			hero.heal(heal_amount)
			hero.trigger_halo_switch_feedback()
			_spawn_kill_flash(pos, radius * 1.6, 0.72)
			picked_up = true
			break
		if picked_up:
			health_drops.remove_at(i)
			continue

		drop["position"] = pos
		drop["velocity"] = vel
		drop["life"] = life
		health_drops[i] = drop

func _set_world_visible_for_upgrade(visible: bool) -> void:
	heroes_root.visible = visible and not start_selection_active and not start_screen_active and not tutorial_screen_active and not boss_victory_prompt_active
	enemies_root.visible = visible
	projectiles_root.visible = visible

func _has_alive_hero_kind(kind: int) -> bool:
	for hero: Hero in heroes:
		if hero.health > 0.0 and hero.kind == kind:
			return true
	return false

func _collect_attack_unlock_priority(tank_alive: bool, ranger_alive: bool, rogue_alive: bool) -> Array[int]:
	var priority: Array[int] = []
	if int(upgrade_levels.get(UPGRADE_HALO_SPECTER, 0)) <= 0:
		priority.append(UPGRADE_HALO_SPECTER)
	elif spectral_halo_count < SPECTRAL_HALO_MAX_COUNT and int(upgrade_levels.get(UPGRADE_HALO_ECHO, 0)) <= 0:
		priority.append(UPGRADE_HALO_ECHO)
	var hero_attack_unlocks: Array[int] = []
	if tank_alive and int(upgrade_levels.get(UPGRADE_TANK_HEAVY_ATTACK, 0)) <= 0:
		hero_attack_unlocks.append(UPGRADE_TANK_HEAVY_ATTACK)
	elif tank_alive and int(upgrade_levels.get(UPGRADE_TANK_HEAVY_ATTACK_PLUS, 0)) <= 0:
		hero_attack_unlocks.append(UPGRADE_TANK_HEAVY_ATTACK_PLUS)
	if ranger_alive and int(upgrade_levels.get(UPGRADE_RANGER_TRIPLE_ARROWS, 0)) <= 0:
		hero_attack_unlocks.append(UPGRADE_RANGER_TRIPLE_ARROWS)
	elif ranger_alive and int(upgrade_levels.get(UPGRADE_RANGER_TRIPLE_ARROWS_PLUS, 0)) <= 0:
		hero_attack_unlocks.append(UPGRADE_RANGER_TRIPLE_ARROWS_PLUS)
	if rogue_alive and int(upgrade_levels.get(UPGRADE_ROGUE_TWIN_FANGS, 0)) <= 0:
		hero_attack_unlocks.append(UPGRADE_ROGUE_TWIN_FANGS)
		# Slight extra weight so Shadow Zip shows up at parity with other class unlocks.
		hero_attack_unlocks.append(UPGRADE_ROGUE_TWIN_FANGS)
	elif rogue_alive and int(upgrade_levels.get(UPGRADE_ROGUE_TWIN_FANGS_PLUS, 0)) <= 0:
		hero_attack_unlocks.append(UPGRADE_ROGUE_TWIN_FANGS_PLUS)
		hero_attack_unlocks.append(UPGRADE_ROGUE_TWIN_FANGS_PLUS)
	hero_attack_unlocks.shuffle()
	for upgrade_id in hero_attack_unlocks:
		priority.append(upgrade_id)
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
	if int(upgrade_levels.get(UPGRADE_HALO_SPECTER, 0)) <= 0:
		pool.append(UPGRADE_HALO_SPECTER)
	elif spectral_halo_count < SPECTRAL_HALO_MAX_COUNT:
		pool.append(UPGRADE_HALO_ECHO)

	if tank_alive:
		pool.append(UPGRADE_TANK_BASTION)
		pool.append(UPGRADE_TANK_MARCH)
		if int(upgrade_levels.get(UPGRADE_TANK_HEAVY_ATTACK, 0)) <= 0:
			pool.append(UPGRADE_TANK_HEAVY_ATTACK)
		else:
			pool.append(UPGRADE_TANK_HEAVY_ATTACK_PLUS)

	if ranger_alive:
		pool.append(UPGRADE_RANGER_REMEDY)
		pool.append(UPGRADE_RANGER_FOCUS)
		if int(upgrade_levels.get(UPGRADE_RANGER_TRIPLE_ARROWS, 0)) <= 0:
			pool.append(UPGRADE_RANGER_TRIPLE_ARROWS)
		else:
			pool.append(UPGRADE_RANGER_TRIPLE_ARROWS_PLUS)

	if rogue_alive:
		pool.append(UPGRADE_ROGUE_OVERDRIVE)
		pool.append(UPGRADE_ROGUE_PRECISION)
		if int(upgrade_levels.get(UPGRADE_ROGUE_TWIN_FANGS, 0)) <= 0:
			pool.append(UPGRADE_ROGUE_TWIN_FANGS)
		else:
			pool.append(UPGRADE_ROGUE_TWIN_FANGS_PLUS)

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

	var cycle_wave: int = _current_cycle_wave()
	if cycle_wave > 0 and cycle_wave % 5 == 0:
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

func _start_screen_button_rect() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	return Rect2(
		Vector2((view_size.x - START_SCREEN_BUTTON_SIZE.x) * 0.5, view_size.y * 0.58),
		START_SCREEN_BUTTON_SIZE
	)

func _start_screen_options_button_rect() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	return Rect2(
		Vector2((view_size.x - OPTIONS_BUTTON_SIZE.x) * 0.5, view_size.y * 0.68),
		OPTIONS_BUTTON_SIZE
	)

func _tutorial_panel_rect_screen() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var max_w: float = minf(view_size.x - 24.0, maxf(460.0, view_size.x - TUTORIAL_PANEL_MARGIN_X * 2.0))
	var max_h: float = minf(view_size.y - 24.0, maxf(360.0, view_size.y - TUTORIAL_PANEL_MARGIN_Y * 2.0))
	var panel_size: Vector2 = Vector2(
		minf(TUTORIAL_PANEL_SIZE.x, max_w),
		minf(TUTORIAL_PANEL_SIZE.y, max_h)
	)
	var panel_pos: Vector2 = (view_size - panel_size) * 0.5
	return Rect2(panel_pos, panel_size)

func _tutorial_continue_button_rect() -> Rect2:
	var panel: Rect2 = _tutorial_panel_rect_screen()
	var btn_w: float = minf(TUTORIAL_BUTTON_SIZE.x, panel.size.x - 80.0)
	var btn_h: float = TUTORIAL_BUTTON_SIZE.y
	return Rect2(
		Vector2(panel.position.x + (panel.size.x - btn_w) * 0.5, panel.end.y - btn_h - 28.0),
		Vector2(btn_w, btn_h)
	)

func _game_over_button_rect() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var panel: Rect2 = Rect2((view_size - GAME_OVER_PANEL_SIZE) * 0.5, GAME_OVER_PANEL_SIZE)
	return Rect2(
		Vector2((view_size.x - GAME_OVER_BUTTON_SIZE.x) * 0.5, panel.position.y + 214.0),
		GAME_OVER_BUTTON_SIZE
	)

func _boss_victory_continue_button_rect() -> Rect2:
	var panel: Rect2 = _boss_victory_panel_rect_screen()
	var gap: float = 26.0
	var usable_w: float = panel.size.x - 96.0
	var btn_w: float = maxf(120.0, minf(BOSS_VICTORY_BUTTON_SIZE.x, (usable_w - gap) * 0.5))
	var btn_h: float = BOSS_VICTORY_BUTTON_SIZE.y
	var y: float = panel.end.y - btn_h - 38.0
	var x: float = panel.position.x + (panel.size.x - (btn_w * 2.0 + gap)) * 0.5
	return Rect2(
		Vector2(x, y),
		Vector2(btn_w, btn_h)
	)

func _boss_victory_home_button_rect() -> Rect2:
	var continue_rect: Rect2 = _boss_victory_continue_button_rect()
	var gap: float = 26.0
	return Rect2(
		Vector2(continue_rect.end.x + gap, continue_rect.position.y),
		continue_rect.size
	)

func _boss_victory_panel_rect_screen() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var max_w: float = minf(view_size.x - 24.0, maxf(420.0, view_size.x - BOSS_VICTORY_PANEL_MARGIN_X * 2.0))
	var max_h: float = minf(view_size.y - 24.0, maxf(300.0, view_size.y - BOSS_VICTORY_PANEL_MARGIN_Y * 2.0))
	var panel_size: Vector2 = Vector2(
		minf(BOSS_VICTORY_PANEL_SIZE.x, max_w),
		minf(BOSS_VICTORY_PANEL_SIZE.y, max_h)
	)
	var panel_pos: Vector2 = (view_size - panel_size) * 0.5
	return Rect2(panel_pos, panel_size)

func _pause_resume_button_rect() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var panel: Rect2 = Rect2((view_size - PAUSE_PANEL_SIZE) * 0.5, PAUSE_PANEL_SIZE)
	return Rect2(
		Vector2((view_size.x - PAUSE_BUTTON_SIZE.x) * 0.5, panel.position.y + 132.0),
		PAUSE_BUTTON_SIZE
	)

func _pause_home_button_rect() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var panel: Rect2 = Rect2((view_size - PAUSE_PANEL_SIZE) * 0.5, PAUSE_PANEL_SIZE)
	return Rect2(
		Vector2((view_size.x - PAUSE_BUTTON_SIZE.x) * 0.5, panel.position.y + 214.0),
		PAUSE_BUTTON_SIZE
	)

func _pause_options_button_rect() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	var panel: Rect2 = Rect2((view_size - PAUSE_PANEL_SIZE) * 0.5, PAUSE_PANEL_SIZE)
	var size: Vector2 = Vector2(220.0, 50.0)
	var x: float = panel.position.x + (panel.size.x - size.x) * 0.5
	var y: float = panel.position.y + 92.0
	return Rect2(
		Vector2(x, y),
		size
	)

func _options_panel_rect_screen() -> Rect2:
	var view_size: Vector2 = _viewport_size()
	return Rect2((view_size - OPTIONS_PANEL_SIZE) * 0.5, OPTIONS_PANEL_SIZE)

func _options_music_slider_rect_screen() -> Rect2:
	var panel: Rect2 = _options_panel_rect_screen()
	return Rect2(
		Vector2(panel.position.x + 72.0, panel.position.y + 128.0),
		Vector2(panel.size.x - 144.0, 20.0)
	)

func _options_sfx_slider_rect_screen() -> Rect2:
	var panel: Rect2 = _options_panel_rect_screen()
	return Rect2(
		Vector2(panel.position.x + 72.0, panel.position.y + 206.0),
		Vector2(panel.size.x - 144.0, 20.0)
	)

func _options_close_button_rect_screen() -> Rect2:
	var panel: Rect2 = _options_panel_rect_screen()
	return Rect2(
		Vector2(panel.position.x + (panel.size.x - OPTIONS_CLOSE_BUTTON_SIZE.x) * 0.5, panel.end.y - 78.0),
		OPTIONS_CLOSE_BUTTON_SIZE
	)

func _open_starting_hero_menu() -> void:
	start_screen_active = false
	tutorial_screen_active = false
	start_selection_active = true
	pause_menu_active = false
	options_menu_active = false
	options_drag_slider = -1
	boss_victory_prompt_active = false
	game_over = false
	_start_bgm_menu()
	_set_world_visible_for_upgrade(false)
	_sync_halo_state()

func _open_start_screen() -> void:
	start_screen_active = true
	tutorial_screen_active = false
	start_selection_active = false
	pause_menu_active = false
	options_menu_active = false
	options_drag_slider = -1
	boss_victory_prompt_active = false
	game_over = false
	_start_bgm_menu()
	_set_world_visible_for_upgrade(false)
	_sync_halo_state()

func _open_tutorial_screen() -> void:
	start_screen_active = false
	tutorial_screen_active = true
	start_selection_active = false
	pause_menu_active = false
	options_menu_active = false
	options_drag_slider = -1
	boss_victory_prompt_active = false
	game_over = false
	_start_bgm_menu()
	_set_world_visible_for_upgrade(false)
	_sync_halo_state()

func _open_pause_menu() -> void:
	pause_menu_active = true
	options_menu_active = false
	options_drag_slider = -1
	heroes_root.visible = false
	enemies_root.visible = false
	projectiles_root.visible = false
	_set_bgm_paused_mix(true)

func _resume_from_pause() -> void:
	pause_menu_active = false
	options_menu_active = false
	options_drag_slider = -1
	heroes_root.visible = true
	enemies_root.visible = true
	projectiles_root.visible = true
	_set_bgm_paused_mix(false)

func _open_options_menu() -> void:
	options_menu_active = true
	options_drag_slider = -1

func _close_options_menu() -> void:
	options_menu_active = false
	options_drag_slider = -1

func _set_music_volume_percent(value: float) -> void:
	music_volume_percent = clampf(value, 0.0, 100.0)
	_apply_audio_mix_levels()

func _set_sfx_volume_percent(value: float) -> void:
	sfx_volume_percent = clampf(value, 0.0, 100.0)
	_apply_audio_mix_levels()

func _slider_value_from_screen_point(screen_point: Vector2, slider_rect: Rect2) -> float:
	if slider_rect.size.x <= 0.0001:
		return 0.0
	var t: float = clampf((screen_point.x - slider_rect.position.x) / slider_rect.size.x, 0.0, 1.0)
	return t * 100.0

func _handle_options_click(screen_point: Vector2) -> bool:
	var close_rect: Rect2 = _options_close_button_rect_screen()
	var music_rect: Rect2 = _options_music_slider_rect_screen()
	var sfx_rect: Rect2 = _options_sfx_slider_rect_screen()
	if close_rect.has_point(screen_point):
		_play_ui_click_sfx()
		_close_options_menu()
		return true
	if music_rect.grow(8.0).has_point(screen_point):
		_set_music_volume_percent(_slider_value_from_screen_point(screen_point, music_rect))
		options_drag_slider = 0
		return true
	if sfx_rect.grow(8.0).has_point(screen_point):
		_set_sfx_volume_percent(_slider_value_from_screen_point(screen_point, sfx_rect))
		options_drag_slider = 1
		return true
	# If click is outside panel, close menu.
	if not _options_panel_rect_screen().has_point(screen_point):
		_close_options_menu()
		return true
	return true

func _return_to_main_menu() -> void:
	_stop_bgm()
	get_tree().reload_current_scene()

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

	_play_ui_character_select_sfx()
	start_selection_active = false
	pause_menu_active = false
	boss_victory_prompt_active = false
	heroes_root.visible = true
	halo_equipped = false
	halo_charge = halo_charge_cap
	halo_recharge_delay_timer = 0.0
	halo_toggle_lock_timer = 0.0
	_set_halo(index, false)
	_start_bgm_game()
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
	if start_selection_active or start_screen_active or tutorial_screen_active:
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
	var target_zoom: Vector2 = CAMERA_ZOOM_MENU if (start_selection_active or start_screen_active or tutorial_screen_active) else CAMERA_ZOOM_GAME
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

func _setup_bgm() -> void:
	bgm_players.clear()
	bgm_menu_stream = _load_bgm_stream(BGM_MENU_PATH)
	bgm_game_stream = _load_bgm_stream(BGM_GAME_PATH)
	bgm_game_low_health_stream = _load_bgm_stream(BGM_GAME_LOW_HEALTH_PATH)
	if bgm_game_stream == null:
		bgm_game_stream = bgm_menu_stream
	if bgm_game_low_health_stream == null:
		bgm_game_low_health_stream = bgm_game_stream
	if bgm_menu_stream == null:
		bgm_menu_stream = bgm_game_stream
	if bgm_menu_stream == null:
		push_warning("No BGM stream could be loaded.")
		return

	for i in range(2):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "BGMPlayer%d" % [i]
		player.bus = "Master"
		player.stream = bgm_menu_stream
		player.volume_db = (BGM_MENU_VOLUME_DB + _music_mix_db()) if i == 0 else (BGM_SILENT_DB + _music_mix_db())
		add_child(player)
		bgm_players.append(player)

	bgm_low_layer_player = null
	if bgm_game_low_health_stream != null:
		bgm_low_layer_player = AudioStreamPlayer.new()
		bgm_low_layer_player.name = "BGMLowHealthLayerPlayer"
		bgm_low_layer_player.bus = "Master"
		bgm_low_layer_player.stream = bgm_game_low_health_stream
		bgm_low_layer_player.volume_db = BGM_SILENT_DB + _music_mix_db()
		add_child(bgm_low_layer_player)

	bgm_target_volume_db = BGM_MENU_VOLUME_DB
	bgm_active_mode = BGM_MODE_MENU
	bgm_low_health_active = false
	bgm_low_layer_mix = 0.0
	bgm_active_player_index = 0
	bgm_crossfade_active = false
	bgm_crossfade_timer = 0.0
	bgm_crossfade_from_index = 0
	bgm_crossfade_to_index = 1
	var starter: AudioStreamPlayer = _bgm_player_at(bgm_active_player_index)
	if starter != null:
		starter.play()

func _bgm_player_at(index: int) -> AudioStreamPlayer:
	if index < 0 or index >= bgm_players.size():
		return null
	return bgm_players[index]

func _load_bgm_stream(path: String) -> AudioStream:
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		push_warning("BGM file not found at %s" % [path])
		return null
	# Disable built-in looping and do an explicit crossfade loop to avoid hard cut restarts.
	var mp3_stream: AudioStreamMP3 = stream as AudioStreamMP3
	if mp3_stream != null:
		mp3_stream.loop = false
	var ogg_stream: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
	if ogg_stream != null:
		ogg_stream.loop = false
	return stream

func _active_bgm_stream_for_mode(mode: int) -> AudioStream:
	if mode == BGM_MODE_GAME_LOW_HEALTH:
		return bgm_game_stream
	if mode == BGM_MODE_GAME:
		return bgm_game_stream
	return bgm_menu_stream

func _switch_bgm_mode(mode: int, restart_from_start: bool) -> void:
	if bgm_players.is_empty():
		return
	var desired_stream: AudioStream = _active_bgm_stream_for_mode(mode)
	if desired_stream == null:
		return
	var stream_changed: bool = false
	for player: AudioStreamPlayer in bgm_players:
		if player == null:
			continue
		if player.stream != desired_stream:
			player.stream = desired_stream
			stream_changed = true
	bgm_active_mode = mode
	if stream_changed or restart_from_start:
		_restart_bgm_now()
		return
	var active_player: AudioStreamPlayer = _bgm_player_at(bgm_active_player_index)
	if active_player != null and not active_player.playing:
		active_player.volume_db = bgm_target_volume_db + _music_mix_db()
		active_player.play()

func _start_bgm_menu() -> void:
	if bgm_players.is_empty():
		return
	bgm_target_volume_db = BGM_MENU_VOLUME_DB
	bgm_low_health_active = false
	bgm_low_layer_mix = 0.0
	if bgm_low_layer_player != null:
		if bgm_low_layer_player.playing:
			bgm_low_layer_player.stop()
		bgm_low_layer_player.volume_db = BGM_SILENT_DB + _music_mix_db()
	_switch_bgm_mode(BGM_MODE_MENU, false)

func _start_bgm_game() -> void:
	if bgm_players.is_empty():
		return
	bgm_low_health_active = false
	bgm_low_layer_mix = 0.0
	if bgm_low_layer_player != null:
		bgm_low_layer_player.volume_db = BGM_SILENT_DB + _music_mix_db()
	bgm_target_volume_db = BGM_GAME_VOLUME_DB
	# Restart from the beginning when a run starts and ensure game track is active.
	_switch_bgm_mode(BGM_MODE_GAME, true)

func _set_bgm_paused_mix(paused: bool) -> void:
	if bgm_players.is_empty():
		return
	if paused:
		# Keep current track, just duck to menu-level volume while paused.
		bgm_target_volume_db = BGM_MENU_VOLUME_DB
		return
	var in_game_mode: bool = bgm_active_mode == BGM_MODE_GAME or bgm_active_mode == BGM_MODE_GAME_LOW_HEALTH
	bgm_target_volume_db = BGM_GAME_VOLUME_DB if in_game_mode else BGM_MENU_VOLUME_DB

func _restart_bgm_now() -> void:
	if bgm_players.is_empty():
		return
	bgm_crossfade_active = false
	bgm_crossfade_timer = 0.0
	bgm_crossfade_from_index = 0
	bgm_crossfade_to_index = 1
	bgm_active_player_index = 0
	for i in range(bgm_players.size()):
		var player: AudioStreamPlayer = _bgm_player_at(i)
		if player == null:
			continue
		if player.playing:
			player.stop()
		player.volume_db = (bgm_target_volume_db + _music_mix_db()) if i == bgm_active_player_index else (BGM_SILENT_DB + _music_mix_db())
	var active_player: AudioStreamPlayer = _bgm_player_at(bgm_active_player_index)
	if active_player != null:
		active_player.play()
	if bgm_low_layer_player != null:
		if bgm_low_layer_player.playing:
			bgm_low_layer_player.stop()
		bgm_low_layer_player.volume_db = BGM_SILENT_DB + _music_mix_db()

func _stop_bgm() -> void:
	bgm_crossfade_active = false
	bgm_crossfade_timer = 0.0
	bgm_low_health_active = false
	bgm_low_layer_mix = 0.0
	for player: AudioStreamPlayer in bgm_players:
		if player != null and player.playing:
			player.stop()
	if bgm_low_layer_player != null and bgm_low_layer_player.playing:
		bgm_low_layer_player.stop()

func _is_gameplay_music_state() -> bool:
	return not start_screen_active \
		and not tutorial_screen_active \
		and not start_selection_active \
		and not pause_menu_active \
		and not boss_victory_prompt_active \
		and not game_over \
		and not upgrade_phase_active

func _average_alive_hero_health_ratio() -> float:
	var ratio_sum: float = 0.0
	var alive_count: int = 0
	for hero: Hero in heroes:
		if hero.health <= 0.0:
			continue
		ratio_sum += hero.health_ratio()
		alive_count += 1
	if alive_count <= 0:
		return -1.0
	return ratio_sum / float(alive_count)

func _update_gameplay_bgm_state() -> void:
	if bgm_players.is_empty():
		return
	if not _is_gameplay_music_state():
		bgm_low_health_active = false
		return
	var avg_ratio: float = _average_alive_hero_health_ratio()
	if avg_ratio < 0.0:
		bgm_low_health_active = false
		return
	var should_use_low_track: bool = avg_ratio <= BGM_LOW_HEALTH_ENTER_RATIO
	if bgm_low_health_active and avg_ratio < BGM_LOW_HEALTH_EXIT_RATIO:
		should_use_low_track = true
	bgm_low_health_active = should_use_low_track

func _switch_game_bgm_variant(low_health: bool) -> void:
	if bgm_players.size() < 2:
		return
	var desired_stream: AudioStream = bgm_game_low_health_stream if low_health else bgm_game_stream
	if desired_stream == null:
		return
	var desired_mode: int = BGM_MODE_GAME_LOW_HEALTH if low_health else BGM_MODE_GAME
	var active_player: AudioStreamPlayer = _bgm_player_at(bgm_active_player_index)
	if active_player != null and active_player.stream == desired_stream and bgm_active_mode == desired_mode:
		return
	var next_index: int = 1 - bgm_active_player_index
	var next_player: AudioStreamPlayer = _bgm_player_at(next_index)
	if next_player == null:
		return
	next_player.stream = desired_stream
	if next_player.playing:
		next_player.stop()
	next_player.volume_db = BGM_SILENT_DB
	next_player.play()
	bgm_crossfade_active = true
	bgm_crossfade_timer = 0.0
	bgm_crossfade_from_index = bgm_active_player_index
	bgm_crossfade_to_index = next_index
	bgm_active_mode = desired_mode

func _update_bgm_loop(delta: float) -> void:
	if bgm_players.size() < 2:
		return
	var active_player: AudioStreamPlayer = _bgm_player_at(bgm_active_player_index)
	if active_player == null or active_player.stream == null:
		return
	var music_db: float = _music_mix_db()
	var gameplay_mode: bool = _is_gameplay_music_state() and (bgm_active_mode == BGM_MODE_GAME or bgm_active_mode == BGM_MODE_GAME_LOW_HEALTH)
	var low_target_mix: float = 1.0 if (gameplay_mode and bgm_low_health_active) else 0.0
	var low_mix_t: float = clampf(delta * BGM_LOW_LAYER_BLEND_SPEED, 0.0, 1.0)
	bgm_low_layer_mix = lerpf(bgm_low_layer_mix, low_target_mix, low_mix_t)
	if absf(bgm_low_layer_mix - low_target_mix) <= 0.0015:
		bgm_low_layer_mix = low_target_mix
	var main_duck_db: float = BGM_GAME_MAIN_DUCK_DB * bgm_low_layer_mix if gameplay_mode else 0.0
	var target_db: float = bgm_target_volume_db + music_db - main_duck_db
	var silent_db: float = BGM_SILENT_DB + music_db
	if not active_player.playing:
		active_player.volume_db = target_db
		active_player.play()
	else:
		var stream_len: float = active_player.stream.get_length()
		if stream_len <= BGM_LOOP_CROSSFADE_TIME + 0.08:
			active_player.volume_db = lerpf(active_player.volume_db, target_db, clampf(delta * BGM_VOLUME_SMOOTH, 0.0, 1.0))
		else:
			if not bgm_crossfade_active:
				var time_left: float = stream_len - active_player.get_playback_position()
				if time_left <= BGM_LOOP_CROSSFADE_TIME:
					var next_index: int = 1 - bgm_active_player_index
					var next_player: AudioStreamPlayer = _bgm_player_at(next_index)
					if next_player != null and next_player.stream != null:
						if next_player.playing:
							next_player.stop()
						next_player.volume_db = silent_db
						next_player.play()
						bgm_crossfade_active = true
						bgm_crossfade_timer = 0.0
						bgm_crossfade_from_index = bgm_active_player_index
						bgm_crossfade_to_index = next_index

			if bgm_crossfade_active:
				bgm_crossfade_timer += delta
				var t: float = clampf(bgm_crossfade_timer / BGM_LOOP_CROSSFADE_TIME, 0.0, 1.0)
				var from_player: AudioStreamPlayer = _bgm_player_at(bgm_crossfade_from_index)
				var to_player: AudioStreamPlayer = _bgm_player_at(bgm_crossfade_to_index)
				if from_player == null or to_player == null:
					bgm_crossfade_active = false
				else:
					from_player.volume_db = lerpf(target_db, silent_db, t)
					to_player.volume_db = lerpf(silent_db, target_db, t)
					if t >= 1.0:
						if from_player.playing:
							from_player.stop()
						from_player.volume_db = silent_db
						bgm_active_player_index = bgm_crossfade_to_index
						bgm_crossfade_active = false
						bgm_crossfade_timer = 0.0
			else:
				active_player.volume_db = lerpf(active_player.volume_db, target_db, clampf(delta * BGM_VOLUME_SMOOTH, 0.0, 1.0))

	# Keep low-health layer running in sync with gameplay music and blend its volume by health state.
	if bgm_low_layer_player == null:
		return
	var low_target_db: float = silent_db
	if gameplay_mode and bgm_game_low_health_stream != null:
		if bgm_low_layer_player.stream != bgm_game_low_health_stream:
			bgm_low_layer_player.stream = bgm_game_low_health_stream
		var ref_player: AudioStreamPlayer = active_player
		if bgm_crossfade_active:
			var to_player_ref: AudioStreamPlayer = _bgm_player_at(bgm_crossfade_to_index)
			if to_player_ref != null and ref_player != null and to_player_ref.volume_db > ref_player.volume_db:
				ref_player = to_player_ref
		var desired_pos: float = ref_player.get_playback_position() if ref_player != null else 0.0
		if not bgm_low_layer_player.playing:
			bgm_low_layer_player.play(desired_pos)
		else:
			var drift: float = absf(desired_pos - bgm_low_layer_player.get_playback_position())
			var low_len: float = bgm_low_layer_player.stream.get_length() if bgm_low_layer_player.stream != null else 0.0
			if low_len > 0.01:
				drift = minf(drift, absf(low_len - drift))
			if drift > BGM_LOW_LAYER_SYNC_TOLERANCE:
				bgm_low_layer_player.play(desired_pos)
		low_target_db = lerpf(BGM_SILENT_DB, BGM_GAME_LOW_LAYER_VOLUME_DB, bgm_low_layer_mix) + music_db
	else:
		if bgm_low_layer_player.playing and bgm_low_layer_mix <= 0.002:
			bgm_low_layer_player.stop()
	bgm_low_layer_player.volume_db = lerpf(
		bgm_low_layer_player.volume_db,
		low_target_db,
		clampf(delta * BGM_VOLUME_SMOOTH, 0.0, 1.0)
	)

func _setup_audio_sfx() -> void:
	if not ENABLE_SFX and not PERFECT_POSITION_SOUND_ENABLED:
		return
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = SFX_MIX_RATE
	generator.buffer_length = SFX_BUFFER_LENGTH
	sfx_player.stream = generator
	sfx_player.volume_db = -6.0
	sfx_player.play()
	sfx_playback = sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback

	if PERFECT_POSITION_SOUND_ENABLED:
		perfect_position_stream = load(PERFECT_POSITION_SFX_PATH) as AudioStream
		if perfect_position_stream != null:
			perfect_position_player = AudioStreamPlayer.new()
			perfect_position_player.name = "PerfectPositionSFXPlayer"
			perfect_position_player.volume_db = PERFECT_POSITION_SFX_VOLUME_DB
			perfect_position_player.bus = "Master"
			perfect_position_player.stream = perfect_position_stream
			add_child(perfect_position_player)
		perfect_position_break_stream = load(PERFECT_POSITION_BREAK_SFX_PATH) as AudioStream
		if perfect_position_break_stream != null:
			perfect_position_break_player = AudioStreamPlayer.new()
			perfect_position_break_player.name = "PerfectPositionBreakSFXPlayer"
			perfect_position_break_player.volume_db = PERFECT_POSITION_BREAK_SFX_VOLUME_DB
			perfect_position_break_player.bus = "Master"
			perfect_position_break_player.stream = perfect_position_break_stream
			add_child(perfect_position_break_player)

func _setup_ui_sfx() -> void:
	ui_click_stream = load(UI_CLICK_SFX_PATH) as AudioStream
	ui_character_select_stream = load(UI_CHARACTER_SELECT_SFX_PATH) as AudioStream
	ui_start_game_stream = load(UI_START_GAME_SFX_PATH) as AudioStream
	ui_final_boss_appear_stream = load(UI_FINAL_BOSS_APPEAR_SFX_PATH) as AudioStream

	ui_click_player = AudioStreamPlayer.new()
	ui_click_player.name = "UIClickSFXPlayer"
	ui_click_player.volume_db = UI_CLICK_SFX_VOLUME_DB
	ui_click_player.bus = "Master"
	ui_click_player.max_polyphony = UI_CLICK_SFX_MAX_POLYPHONY
	ui_click_player.stream = ui_click_stream
	add_child(ui_click_player)

	ui_character_select_player = AudioStreamPlayer.new()
	ui_character_select_player.name = "UICharacterSelectSFXPlayer"
	ui_character_select_player.volume_db = UI_CHARACTER_SELECT_SFX_VOLUME_DB
	ui_character_select_player.bus = "Master"
	ui_character_select_player.max_polyphony = UI_SELECT_SFX_MAX_POLYPHONY
	ui_character_select_player.stream = ui_character_select_stream
	add_child(ui_character_select_player)

	ui_start_game_player = AudioStreamPlayer.new()
	ui_start_game_player.name = "UIStartGameSFXPlayer"
	ui_start_game_player.volume_db = UI_START_GAME_SFX_VOLUME_DB
	ui_start_game_player.bus = "Master"
	ui_start_game_player.max_polyphony = UI_SELECT_SFX_MAX_POLYPHONY
	ui_start_game_player.stream = ui_start_game_stream
	add_child(ui_start_game_player)

	ui_final_boss_appear_player = AudioStreamPlayer.new()
	ui_final_boss_appear_player.name = "UIFinalBossAppearSFXPlayer"
	ui_final_boss_appear_player.volume_db = UI_FINAL_BOSS_APPEAR_SFX_VOLUME_DB
	ui_final_boss_appear_player.bus = "Master"
	ui_final_boss_appear_player.stream = ui_final_boss_appear_stream
	add_child(ui_final_boss_appear_player)

func _volume_percent_to_db_offset(percent: float) -> float:
	var p: float = clampf(percent, 0.0, 100.0)
	if p <= 0.0001:
		return -80.0
	return linear_to_db(p / 100.0)

func _music_mix_db() -> float:
	return _volume_percent_to_db_offset(music_volume_percent)

func _sfx_mix_db() -> float:
	return _volume_percent_to_db_offset(sfx_volume_percent)

func _apply_audio_mix_levels() -> void:
	var sfx_db: float = _sfx_mix_db()
	var music_db: float = _music_mix_db()
	if sfx_player != null:
		sfx_player.volume_db = -6.0 + sfx_db
	if ui_click_player != null:
		ui_click_player.volume_db = UI_CLICK_SFX_VOLUME_DB + sfx_db
	if ui_character_select_player != null:
		ui_character_select_player.volume_db = UI_CHARACTER_SELECT_SFX_VOLUME_DB + sfx_db
	if ui_start_game_player != null:
		ui_start_game_player.volume_db = UI_START_GAME_SFX_VOLUME_DB + sfx_db
	if ui_final_boss_appear_player != null:
		ui_final_boss_appear_player.volume_db = UI_FINAL_BOSS_APPEAR_SFX_VOLUME_DB + sfx_db
	if perfect_position_player != null:
		perfect_position_player.volume_db = PERFECT_POSITION_SFX_VOLUME_DB + sfx_db
	if perfect_position_break_player != null:
		perfect_position_break_player.volume_db = PERFECT_POSITION_BREAK_SFX_VOLUME_DB + sfx_db
	if bgm_low_layer_player != null:
		var low_target_db: float = lerpf(BGM_SILENT_DB, BGM_GAME_LOW_LAYER_VOLUME_DB, bgm_low_layer_mix) + music_db
		bgm_low_layer_player.volume_db = low_target_db

func _play_ui_click_sfx() -> void:
	if ui_click_player == null or ui_click_stream == null:
		return
	ui_click_player.pitch_scale = randf_range(0.98, 1.02)
	ui_click_player.play()

func _play_ui_character_select_sfx() -> void:
	if ui_character_select_player == null or ui_character_select_stream == null:
		return
	ui_character_select_player.pitch_scale = 1.0
	ui_character_select_player.play()

func _play_ui_start_game_sfx() -> void:
	if ui_start_game_player == null or ui_start_game_stream == null:
		return
	ui_start_game_player.pitch_scale = 1.0
	ui_start_game_player.play()

func _play_ui_final_boss_appear_sfx() -> void:
	if ui_final_boss_appear_player == null or ui_final_boss_appear_stream == null:
		return
	ui_final_boss_appear_player.pitch_scale = 1.0
	ui_final_boss_appear_player.play()

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

func _play_perfect_position_sfx() -> void:
	if not PERFECT_POSITION_SOUND_ENABLED:
		return
	if perfect_position_player != null and perfect_position_stream != null:
		perfect_position_player.pitch_scale = randf_range(0.985, 1.015)
		perfect_position_player.play()
		return
	if sfx_player != null and not sfx_player.playing:
		sfx_player.play()
		sfx_playback = sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if sfx_playback == null:
		return
	_push_sfx_tone(368.0, 0.11, 0.24, true)
	_push_sfx_tone(548.0, 0.085, 0.16, true)

func _play_perfect_position_break_sfx() -> void:
	if not PERFECT_POSITION_SOUND_ENABLED:
		return
	if perfect_position_break_player != null and perfect_position_break_stream != null:
		perfect_position_break_player.pitch_scale = randf_range(0.985, 1.015)
		perfect_position_break_player.play()
		return

func _push_sfx_tone(freq: float, duration: float, amp: float, allow_when_sfx_disabled: bool = false) -> void:
	if not ENABLE_SFX and not allow_when_sfx_disabled:
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

func _on_enemy_impact(position: Vector2, intensity: float) -> void:
	if start_selection_active or start_screen_active or tutorial_screen_active:
		return
	var feedback_mult: float = PERFECT_POSITION_HIT_FEEDBACK_MULT if perfect_position_active else 1.0
	_add_camera_shake((0.55 + intensity * 0.75) * feedback_mult)
	_play_hit_sfx(true, intensity * feedback_mult)
	if perfect_position_active and perfect_position_impact_flash_timer <= 0.0:
		_spawn_kill_flash(position, 8.0 + intensity * 6.0, PERFECT_POSITION_IMPACT_FLASH_INTENSITY)
		perfect_position_impact_flash_timer = PERFECT_POSITION_IMPACT_FLASH_INTERVAL

func _on_hero_impact(_position: Vector2, intensity: float) -> void:
	if start_selection_active or start_screen_active or tutorial_screen_active:
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

func _fit_font_size_for_text(font: Font, text: String, max_width: float, preferred_size: int, min_size: int = 12) -> int:
	if font == null:
		return preferred_size
	var size: int = preferred_size
	var width_limit: float = maxf(max_width, 8.0)
	while size > min_size:
		var measured: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size)
		if measured.x <= width_limit:
			break
		size -= 1
	return maxi(size, min_size)

func _centered_text_baseline(rect: Rect2, font: Font, font_size: int) -> float:
	if font == null:
		return rect.position.y + rect.size.y * 0.5
	var ascent: float = font.get_ascent(font_size)
	var descent: float = font.get_descent(font_size)
	return rect.position.y + (rect.size.y + ascent - descent) * 0.5

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

	_play_ui_click_sfx()
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
					hero.rogue_zip_unlocked = true
					hero.rogue_zip_skill_cooldown_reduction += 0.25
					hero.attack_damage += 1.2
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
		UPGRADE_HALO_SPECTER:
			spectral_halo_unlocked = true
			spectral_halo_count = maxi(1, spectral_halo_count)
			_ensure_spectral_halo_slots()
			if not spectral_halo_positions.is_empty():
				spectral_halo_positions[0] = _clamp_point_to_arena(_camera_target_position())
				spectral_halo_hit_timers[0] = 0.08
		UPGRADE_HALO_ECHO:
			if spectral_halo_unlocked:
				spectral_halo_count = mini(SPECTRAL_HALO_MAX_COUNT, spectral_halo_count + 1)
				_add_spectral_halo_slot(_camera_target_position() + Vector2(randf_range(-44.0, 44.0), randf_range(-44.0, 44.0)))
				_ensure_spectral_halo_slots()
		UPGRADE_ROGUE_TWIN_FANGS_PLUS:
			for hero: Hero in heroes:
				if hero.kind == HERO_ROGUE and hero.rogue_zip_unlocked:
					hero.rogue_zip_bonus_hops += 1
					hero.rogue_zip_damage_bonus_mult += 0.16
					hero.rogue_zip_skill_cooldown_reduction += 0.45
					hero.attack_damage += 0.8
					hero.attack_cooldown = maxf(0.16, hero.attack_cooldown * 0.95)
		UPGRADE_TANK_HEAVY_ATTACK_PLUS:
			for hero: Hero in heroes:
				if hero.kind == HERO_KNIGHT and hero.tank_heavy_attack_unlocked:
					hero.attack_damage += 1.8
					hero.attack_cooldown = maxf(0.52, hero.attack_cooldown * 0.95)
					hero.add_max_health(12.0)
		UPGRADE_RANGER_TRIPLE_ARROWS_PLUS:
			for hero: Hero in heroes:
				if hero.kind == HERO_RANGER and hero.ranger_triple_arrows_unlocked:
					hero.attack_damage += 1.25
					hero.attack_cooldown = maxf(0.48, hero.attack_cooldown * 0.92)

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
			return "Shadow Zip"
		UPGRADE_TANK_HEAVY_ATTACK:
			return "Heavy Attack"
		UPGRADE_RANGER_TRIPLE_ARROWS:
			return "Triple Arrows"
		UPGRADE_HALO_SPECTER:
			return "Spectral Halo"
		UPGRADE_HALO_ECHO:
			return "+1 Halo"
		UPGRADE_ROGUE_TWIN_FANGS_PLUS:
			return "Shadow Zip+"
		UPGRADE_TANK_HEAVY_ATTACK_PLUS:
			return "Heavy Attack+"
		UPGRADE_RANGER_TRIPLE_ARROWS_PLUS:
			return "Triple Arrows+"
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
			return "Unlock Rogue Shadow Zip: chain dash hits, return to formation, then wait for cooldown."
		UPGRADE_TANK_HEAVY_ATTACK:
			return "Unlock Tank charged slam: huge area strike that punishes swarms."
		UPGRADE_RANGER_TRIPLE_ARROWS:
			return "Unlock Ranger triple-shot: fires 3 arrows at once."
		UPGRADE_HALO_SPECTER:
			return "Summon a spectral halo that bounces around and hits enemies on contact."
		UPGRADE_HALO_ECHO:
			return "Add another bouncing halo (up to %d total)." % [SPECTRAL_HALO_MAX_COUNT]
		UPGRADE_ROGUE_TWIN_FANGS_PLUS:
			return "Shadow Zip upgrade: +1 chain hit, more zip damage, and shorter zip cooldown."
		UPGRADE_TANK_HEAVY_ATTACK_PLUS:
			return "Heavy Attack upgrade: stronger slams, faster cadence, bonus tank HP."
		UPGRADE_RANGER_TRIPLE_ARROWS_PLUS:
			return "Triple Arrows upgrade: stronger volleys and faster ranger attacks."
	return ""

func _is_boss_reward_upgrade(upgrade_id: int) -> bool:
	return upgrade_id == UPGRADE_GOLDEN_SURGE

func _update_ui() -> void:
	var view_size: Vector2 = _viewport_size()
	threat_label.position = Vector2(16.0, 12.0)
	threat_label.size = Vector2(520.0, 42.0)
	hint_label.position = Vector2(16.0, 48.0)
	hint_label.size = Vector2(760.0, 34.0)
	hero_status.position = Vector2(view_size.x * 0.5 - 180.0, 14.0)
	hero_status.size = Vector2(360.0, 44.0)
	wave_label.position = Vector2(view_size.x - 260.0, view_size.y - 56.0)
	wave_label.size = Vector2(240.0, 42.0)

	if start_selection_active or start_screen_active or tutorial_screen_active or game_over or boss_victory_prompt_active:
		wave_label.text = ""
		threat_label.text = ""
		hero_status.text = ""
		hint_label.text = ""
		return

	if pause_menu_active:
		wave_label.text = ""
		threat_label.text = ""
		hero_status.text = ""
		hint_label.text = ""
		return

	hero_status.text = "TIME  %.1fs" % [elapsed_time]
	wave_label.text = "WAVE %d" % [wave]

	var halo_pct: float = clampf((halo_charge / maxf(halo_charge_cap, 0.01)) * 100.0, 0.0, 999.0)
	threat_label.text = "Halo  %.0f%%" % [halo_pct]
	if halo_equipped:
		threat_label.text += "  ACTIVE"

	var status_line: String = ""
	if halo_equipped:
		status_line = ""
	else:
		if halo_recharge_delay_timer > 0.0:
			status_line = "Recharging."
		elif halo_charge < halo_min_activate_charge_value:
			status_line = "Recharging. Need %.0f%% to reactivate." % [halo_min_activate_charge_value]
		elif halo_index < 0:
			status_line = "Ready. Choose a hero, then activate Halo."
		else:
			status_line = "Ready."
	if game_over:
		status_line = ""
	elif upgrade_phase_active:
		status_line = "Choose one upgrade to continue."
	elif waiting_for_next_wave:
		status_line = "Wave clear. Next wave in %.1fs." % [maxf(intermission_timer, 0.0)]
	elif wave_surge_active:
		status_line = "Enemy surge! Hold formation and push through."
	elif wave_surge_recovery_timer > 0.0:
		status_line = "Regroup window."
	hint_label.text = status_line

func _current_cycle_wave() -> int:
	return wave

func _difficulty_wave_value() -> int:
	return wave + endless_cycle * 6

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
	draw_rect(view_rect, Color(0.01, 0.022, 0.05, 1.0), true)

	# Vertical tone bands for a dedicated menu look (separate from the arena floor).
	var band_count: int = 16
	for i in range(band_count):
		var t0: float = float(i) / float(band_count)
		var t1: float = float(i + 1) / float(band_count)
		var y0: float = lerpf(view_rect.position.y, view_rect.end.y, t0)
		var y1: float = lerpf(view_rect.position.y, view_rect.end.y, t1)
		var band_rect: Rect2 = Rect2(Vector2(view_rect.position.x, y0), Vector2(view_rect.size.x, y1 - y0))
		var top_col: Color = Color(0.015, 0.055, 0.1, 0.64)
		var bot_col: Color = Color(0.008, 0.016, 0.04, 0.78)
		draw_rect(band_rect, top_col.lerp(bot_col, t0), true)

	# Menu backdrop: only top wall + floor (edge to edge), no side/bottom wall strips.
	var menu_top_h: float = minf(WALL_TOP_BLOCK, view_rect.size.y * 0.3)
	draw_rect(Rect2(view_rect.position, Vector2(view_rect.size.x, menu_top_h)), Color(0.46, 0.46, 0.54, 0.84), true)

	var menu_window_segments: Array[Vector2] = []
	if wall_top_windows_texture != null and wall_top_windows_texture.get_width() > 0 and wall_top_windows_texture.get_height() > 0:
		var src_w: float = float(wall_top_windows_texture.get_width())
		var src_h: float = float(wall_top_windows_texture.get_height())
		for i in range(3):
			var slot_world: Rect2 = _screen_rect_to_world(_starting_hero_slot_rect(i))
			var win_h: float = menu_top_h * 0.95
			var win_w: float = maxf(70.0, win_h * (src_w / maxf(src_h, 0.0001)))
			var win_x: float = slot_world.get_center().x - win_w * 0.5
			var win_rect: Rect2 = Rect2(Vector2(win_x, view_rect.position.y + 4.0), Vector2(win_w, win_h))
			draw_texture_rect(wall_top_windows_texture, win_rect, false, Color(1.0, 1.0, 1.0, 0.98))
			menu_window_segments.append(Vector2(win_rect.get_center().x, win_rect.size.x))

	for seg in menu_window_segments:
		var sx: float = seg.x
		var seg_w: float = seg.y
		var shaft_top: float = view_rect.position.y + menu_top_h - 16.0
		var shaft_far_w: float = clampf(seg_w * 0.42, 46.0, 90.0)
		var shaft_core_w: float = shaft_far_w * 0.72
		if window_light_texture != null:
			var shaft_rect_far: Rect2 = Rect2(Vector2(sx - shaft_far_w * 0.5, shaft_top), Vector2(shaft_far_w, 340.0))
			draw_texture_rect(window_light_texture, shaft_rect_far, false, Color(1.0, 1.0, 1.0, 0.31))
			var shaft_rect_core: Rect2 = Rect2(Vector2(sx - shaft_core_w * 0.5, shaft_top + 10.0), Vector2(shaft_core_w, 304.0))
			draw_texture_rect(window_light_texture, shaft_rect_core, false, Color(1.0, 1.0, 1.0, 0.37))
		if floor_light_texture != null:
			var floor_w: float = clampf(seg_w * 0.74, 102.0, 160.0)
			var floor_rect: Rect2 = Rect2(Vector2(sx - floor_w * 0.5, shaft_top + 164.0), Vector2(floor_w, 286.0))
			draw_texture_rect(floor_light_texture, floor_rect, false, Color(1.0, 1.0, 1.0, 0.37))

	# Subtle rectangular stage wash behind cards.
	var stage_rect: Rect2 = Rect2(
		Vector2(view_rect.position.x + view_rect.size.x * 0.1, view_rect.position.y + view_rect.size.y * 0.26),
		Vector2(view_rect.size.x * 0.8, view_rect.size.y * 0.44)
	)
	draw_rect(stage_rect, Color(0.08, 0.18, 0.29, 0.06), true)
	draw_rect(stage_rect.grow(-36.0), Color(0.06, 0.15, 0.25, 0.035), true)
	draw_rect(view_rect, Color(0.0, 0.0, 0.0, 0.06), true)

	# No border frame here so top wall/floor read edge-to-edge.

func _draw_options_overlay(view_rect: Rect2, title_font: Font, body_font: Font) -> void:
	draw_rect(view_rect, Color(0.0, 0.0, 0.0, 0.52), true)
	var panel_screen: Rect2 = _options_panel_rect_screen()
	var panel: Rect2 = _screen_rect_to_world(panel_screen)
	draw_rect(panel, Color(0.03, 0.06, 0.1, 0.88), true)
	draw_rect(panel.grow(-6.0), Color(0.01, 0.03, 0.06, 0.64), true)
	draw_rect(panel, Color(0.9, 0.95, 1.0, 0.42), false, 2.2)

	var title: String = "OPTIONS"
	var title_size: int = _fit_font_size_for_text(title_font, title, panel.size.x - 40.0, 46, 24)
	var title_y: float = panel.position.y + 58.0
	draw_string(title_font, Vector2(panel.position.x + 3.0, title_y + 4.0), title, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size, Color(0.0, 0.0, 0.0, 0.76))
	draw_string(title_font, Vector2(panel.position.x, title_y), title, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size, Color(0.95, 0.85, 0.62, 0.98))

	var music_slider_screen: Rect2 = _options_music_slider_rect_screen()
	var sfx_slider_screen: Rect2 = _options_sfx_slider_rect_screen()
	var music_slider: Rect2 = _screen_rect_to_world(music_slider_screen)
	var sfx_slider: Rect2 = _screen_rect_to_world(sfx_slider_screen)
	var label_size: int = 20
	var value_size: int = 18

	draw_string(body_font, Vector2(panel.position.x + 68.0, music_slider.position.y - 14.0), "Main Volume", HORIZONTAL_ALIGNMENT_LEFT, 240.0, label_size, Color(0.92, 0.96, 1.0, 0.97))
	draw_string(body_font, Vector2(panel.position.x + panel.size.x - 132.0, music_slider.position.y - 14.0), "%d%%" % [int(round(music_volume_percent))], HORIZONTAL_ALIGNMENT_RIGHT, 80.0, value_size, Color(0.82, 0.94, 1.0, 0.94))
	draw_string(body_font, Vector2(panel.position.x + 68.0, sfx_slider.position.y - 14.0), "SFX Volume", HORIZONTAL_ALIGNMENT_LEFT, 240.0, label_size, Color(0.92, 0.96, 1.0, 0.97))
	draw_string(body_font, Vector2(panel.position.x + panel.size.x - 132.0, sfx_slider.position.y - 14.0), "%d%%" % [int(round(sfx_volume_percent))], HORIZONTAL_ALIGNMENT_RIGHT, 80.0, value_size, Color(0.82, 0.94, 1.0, 0.94))

	for data in [
		{"rect": music_slider, "value": music_volume_percent},
		{"rect": sfx_slider, "value": sfx_volume_percent}
	]:
		var slider_rect: Rect2 = data["rect"]
		var value: float = float(data["value"])
		draw_rect(slider_rect, Color(0.09, 0.13, 0.2, 0.96), true)
		draw_rect(slider_rect, Color(0.9, 0.95, 1.0, 0.5), false, 1.6)
		var fill_w: float = slider_rect.size.x * clampf(value / 100.0, 0.0, 1.0)
		draw_rect(Rect2(slider_rect.position, Vector2(fill_w, slider_rect.size.y)), Color(0.38, 0.74, 1.0, 0.9), true)
		var knob_x: float = slider_rect.position.x + fill_w
		var knob_center: Vector2 = Vector2(knob_x, slider_rect.get_center().y)
		draw_circle(knob_center, 10.0, Color(0.96, 0.99, 1.0, 0.96))
		draw_circle(knob_center, 5.8, Color(0.44, 0.78, 1.0, 0.95))

	var close_screen: Rect2 = _options_close_button_rect_screen()
	var close_rect: Rect2 = _screen_rect_to_world(close_screen)
	var hover_screen: Vector2 = get_viewport().get_mouse_position()
	var close_hover: bool = close_screen.has_point(hover_screen)
	draw_rect(close_rect, Color(0.15, 0.22, 0.33, 0.96) if not close_hover else Color(0.23, 0.31, 0.45, 0.98), true)
	draw_rect(close_rect, Color(0.9, 0.95, 1.0, 0.82), false, 2.0)
	var close_label: String = "CLOSE"
	var close_size: int = _fit_font_size_for_text(body_font, close_label, close_rect.size.x - 16.0, 24, 15)
	var close_base_y: float = _centered_text_baseline(close_rect, body_font, close_size)
	draw_string(body_font, Vector2(close_rect.position.x + 2.0, close_base_y + 2.0), close_label, HORIZONTAL_ALIGNMENT_CENTER, close_rect.size.x, close_size, Color(0.0, 0.0, 0.0, 0.62))
	draw_string(body_font, Vector2(close_rect.position.x, close_base_y), close_label, HORIZONTAL_ALIGNMENT_CENTER, close_rect.size.x, close_size, Color(0.96, 0.99, 1.0, 0.98))

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

	if floor_main_texture != null:
		var main_w: float = float(floor_main_texture.get_width())
		var main_h: float = float(floor_main_texture.get_height())
		if main_w > 0.0 and main_h > 0.0:
			draw_rect(arena_rect, Color(0.05, 0.08, 0.12, 0.95), true)
			var tile_size: Vector2 = Vector2(main_w, main_h)
			if tile_size.x <= 0.0 or tile_size.y <= 0.0:
				tile_size = Vector2(FLOOR_TEXTURE_TILE_WORLD_SIZE, FLOOR_TEXTURE_TILE_WORLD_SIZE)

			# Anchor repeat grid at arena center to keep pattern alignment stable.
			var grid_anchor: Vector2 = arena_rect.get_center()
			var start_x: float = floor((visible.position.x - grid_anchor.x) / tile_size.x) * tile_size.x + grid_anchor.x
			var start_y: float = floor((visible.position.y - grid_anchor.y) / tile_size.y) * tile_size.y + grid_anchor.y
			var end_x: float = minf(visible.end.x + tile_size.x, arena_rect.end.x + tile_size.x)
			var end_y: float = minf(visible.end.y + tile_size.y, arena_rect.end.y + tile_size.y)

			var y: float = start_y
			while y < end_y:
				var x: float = start_x
				while x < end_x:
					var tile_rect: Rect2 = Rect2(Vector2(x, y), tile_size)
					draw_texture_rect(floor_main_texture, tile_rect, false, Color(1.0, 1.0, 1.0, FLOOR_TEXTURE_MAIN_ALPHA))
					x += tile_size.x
				y += tile_size.y

			if floor_middle_texture != null:
				var center_w: float = float(floor_middle_texture.get_width())
				var center_h: float = float(floor_middle_texture.get_height())
				if center_w > 0.0 and center_h > 0.0:
					var center_size: Vector2 = Vector2(center_w, center_h)
					var center_rect: Rect2 = Rect2(arena_rect.get_center() - center_size * 0.5, center_size)
					draw_texture_rect(floor_middle_texture, center_rect, false, Color(1.0, 1.0, 1.0, FLOOR_TEXTURE_CENTER_ALPHA))

			draw_rect(arena_rect, Color(0.02, 0.04, 0.07, 0.11), true)
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
	var top_wall_h: float = WALL_TOP_BLOCK
	var side_wall_w: float = WALL_SIDE_BLOCK
	var bottom_wall_h: float = WALL_BOTTOM_BLOCK
	var top_wall: Rect2 = Rect2(Vector2(left_x, top_y), Vector2(arena_rect.size.x, top_wall_h))
	var bottom_wall: Rect2 = Rect2(Vector2(left_x, bottom_y - bottom_wall_h), Vector2(arena_rect.size.x, bottom_wall_h))
	var left_wall: Rect2 = Rect2(Vector2(left_x, top_y), Vector2(side_wall_w, arena_rect.size.y))
	var right_wall: Rect2 = Rect2(Vector2(right_x - side_wall_w, top_y), Vector2(side_wall_w, arena_rect.size.y))

	# Base wall fill so bounds are always visible.
	draw_rect(top_wall, Color(0.62, 0.6, 0.66, 0.98), true)
	draw_rect(bottom_wall, Color(0.44, 0.39, 0.46, 0.96), true)
	draw_rect(left_wall, Color(0.44, 0.39, 0.46, 0.96), true)
	draw_rect(right_wall, Color(0.44, 0.39, 0.46, 0.96), true)

	# Top wall windows: repeat the supplied top-window tile across the wall.
	# Store center + segment width for per-window light/reflection stacks.
	var window_segments: Array[Vector2] = []
	if wall_top_windows_texture != null and wall_top_windows_texture.get_width() > 0 and wall_top_windows_texture.get_height() > 0:
		var src_w: float = float(wall_top_windows_texture.get_width())
		var src_h: float = float(wall_top_windows_texture.get_height())
		var ideal_seg_w: float = maxf(72.0, src_w * (top_wall_h / src_h))
		var seg_count: int = maxi(1, int(round(arena_rect.size.x / ideal_seg_w)))
		var seg_w: float = arena_rect.size.x / float(seg_count)
		for i in range(seg_count):
			var x_seg: float = left_x + seg_w * float(i)
			var seg_rect: Rect2 = Rect2(Vector2(x_seg, top_y), Vector2(seg_w, top_wall_h))
			draw_texture_rect(wall_top_windows_texture, seg_rect, false, Color(1.0, 1.0, 1.0, 0.98))
			window_segments.append(Vector2(x_seg + seg_w * 0.5, seg_w))
	else:
		var fallback_count: int = maxi(3, ATMOS_RAY_COUNT)
		var fallback_w: float = arena_rect.size.x / float(fallback_count)
		for i in range(fallback_count):
			var sx: float = left_x + fallback_w * (float(i) + 0.5)
			window_segments.append(Vector2(sx, fallback_w))

	# Side vertical walls.
	var side_start_y: float = top_y + top_wall_h
	var side_end_y: float = bottom_y - bottom_wall_h
	if wall_left_texture != null:
		var seg_h: float = maxf(44.0, float(wall_left_texture.get_height()))
		var y_left: float = side_start_y
		while y_left < side_end_y:
			var h_left: float = minf(seg_h, side_end_y - y_left)
			draw_texture_rect(wall_left_texture, Rect2(Vector2(left_x, y_left), Vector2(side_wall_w, h_left)), false, Color(1.0, 1.0, 1.0, 0.9))
			y_left += h_left
	if wall_right_texture != null:
		var seg_h_r: float = maxf(44.0, float(wall_right_texture.get_height()))
		var y_right: float = side_start_y
		while y_right < side_end_y:
			var h_right: float = minf(seg_h_r, side_end_y - y_right)
			draw_texture_rect(wall_right_texture, Rect2(Vector2(right_x - side_wall_w, y_right), Vector2(side_wall_w, h_right)), false, Color(1.0, 1.0, 1.0, 0.9))
			y_right += h_right

	# Bottom wall strip.
	if wall_bottom_texture != null:
		var bottom_seg_w: float = maxf(64.0, float(wall_bottom_texture.get_width()))
		var x_bottom: float = left_x
		while x_bottom < right_x:
			var w_bottom: float = minf(bottom_seg_w, right_x - x_bottom)
			draw_texture_rect(wall_bottom_texture, Rect2(Vector2(x_bottom, bottom_y - bottom_wall_h), Vector2(w_bottom, bottom_wall_h)), false, Color(1.0, 1.0, 1.0, 0.9))
			x_bottom += w_bottom

	# One reflection stack per repeated window segment.
	for seg in window_segments:
		var sx: float = seg.x
		var seg_w: float = seg.y
		var shaft_top: float = top_y + top_wall_h - 18.0
		var shaft_far_w: float = clampf(seg_w * 0.44, 46.0, 90.0)
		var shaft_core_w: float = shaft_far_w * 0.72
		var shaft_far_h: float = 360.0
		var shaft_core_h: float = 320.0
		if window_light_texture != null:
			var shaft_rect_far: Rect2 = Rect2(Vector2(sx - shaft_far_w * 0.5, shaft_top), Vector2(shaft_far_w, shaft_far_h))
			draw_texture_rect(window_light_texture, shaft_rect_far, false, Color(1.0, 1.0, 1.0, 0.31))
			var shaft_rect_core: Rect2 = Rect2(Vector2(sx - shaft_core_w * 0.5, shaft_top + 12.0), Vector2(shaft_core_w, shaft_core_h))
			draw_texture_rect(window_light_texture, shaft_rect_core, false, Color(1.0, 1.0, 1.0, 0.38))
		if floor_light_texture != null:
			var floor_w: float = clampf(seg_w * 0.68, 90.0, 146.0)
			var floor_h: float = 252.0
			var floor_glow_rect: Rect2 = Rect2(Vector2(sx - floor_w * 0.5, shaft_top + 172.0), Vector2(floor_w, floor_h))
			draw_texture_rect(floor_light_texture, floor_glow_rect, false, Color(1.0, 1.0, 1.0, 0.37))

	# Framing trims.
	draw_line(Vector2(left_x, top_y + top_wall_h), Vector2(right_x, top_y + top_wall_h), Color(0.82, 0.9, 1.0, 0.48), 2.0)
	draw_line(Vector2(left_x + side_wall_w, top_y), Vector2(left_x + side_wall_w, bottom_y), Color(0.76, 0.86, 1.0, 0.34), 1.8)
	draw_line(Vector2(right_x - side_wall_w, top_y), Vector2(right_x - side_wall_w, bottom_y), Color(0.76, 0.86, 1.0, 0.34), 1.8)
	draw_rect(arena_rect, Color(0.62, 0.82, 1.0, 0.42), false, 2.0)

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

	if start_screen_active:
		_draw_start_menu_backdrop(view_rect)
		draw_rect(view_rect, Color(0.01, 0.03, 0.07, 0.08), true)
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		if start_screen_title_logo != null:
			var logo_size: Vector2 = Vector2(float(start_screen_title_logo.get_width()), float(start_screen_title_logo.get_height()))
			if logo_size.x > 0.0 and logo_size.y > 0.0:
				var max_w: float = view_rect.size.x * 0.72
				var max_h: float = view_rect.size.y * 0.26
				var fit_scale: float = minf(max_w / logo_size.x, max_h / logo_size.y)
				fit_scale = clampf(fit_scale, 0.25, 3.0)
				var draw_size: Vector2 = logo_size * fit_scale
				var logo_rect: Rect2 = Rect2(
					Vector2(view_rect.get_center().x - draw_size.x * 0.5, view_rect.position.y + view_rect.size.y * 0.18),
					draw_size
				)
				var shadow_rect_far: Rect2 = logo_rect
				shadow_rect_far.position += Vector2(8.0, 10.0)
				draw_texture_rect(start_screen_title_logo, shadow_rect_far, false, Color(0.0, 0.0, 0.0, 0.22))
				var shadow_rect_near: Rect2 = logo_rect
				shadow_rect_near.position += Vector2(4.0, 5.0)
				draw_texture_rect(start_screen_title_logo, shadow_rect_near, false, Color(0.0, 0.0, 0.0, 0.34))
				draw_texture_rect(start_screen_title_logo, logo_rect, false, Color(1.0, 1.0, 1.0, 1.0))
			else:
				var title_font: Font = start_menu_title_font if start_menu_title_font != null else card_font
				var title_size: int = 74 if start_menu_title_font != null else 46
				var title_text: String = "Halo Keepers"
				var title_y: float = view_rect.position.y + view_rect.size.y * 0.31
				draw_string(title_font, Vector2(view_rect.position.x + 6.0, title_y + 8.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.0, 0.0, 0.0, 0.62))
				draw_string(title_font, Vector2(view_rect.position.x + 3.0, title_y + 5.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.0, 0.0, 0.0, 0.78))
				draw_string(title_font, Vector2(view_rect.position.x + 1.0, title_y + 2.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.0, 0.0, 0.0, 0.52))
				draw_string(title_font, Vector2(view_rect.position.x, title_y), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.95, 0.83, 0.58, 0.98))
		else:
			var title_font: Font = start_menu_title_font if start_menu_title_font != null else card_font
			var title_size: int = 74 if start_menu_title_font != null else 46
			var title_text: String = "Halo Keepers"
			var title_y: float = view_rect.position.y + view_rect.size.y * 0.31
			# Layered shadow passes to separate title from the busy backdrop.
			draw_string(title_font, Vector2(view_rect.position.x + 6.0, title_y + 8.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.0, 0.0, 0.0, 0.62))
			draw_string(title_font, Vector2(view_rect.position.x + 3.0, title_y + 5.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.0, 0.0, 0.0, 0.78))
			draw_string(title_font, Vector2(view_rect.position.x + 1.0, title_y + 2.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.0, 0.0, 0.0, 0.52))
			draw_string(title_font, Vector2(view_rect.position.x, title_y), title_text, HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, title_size, Color(0.95, 0.83, 0.58, 0.98))

		var button_rect_screen: Rect2 = _start_screen_button_rect()
		var options_button_screen: Rect2 = _start_screen_options_button_rect()
		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var is_hover: bool = button_rect_screen.has_point(hover_screen)
		var button_rect: Rect2 = _screen_rect_to_world(button_rect_screen)
		draw_rect(button_rect, Color(0.14, 0.2, 0.31, 0.96) if not is_hover else Color(0.2, 0.28, 0.4, 0.98), true)
		draw_rect(button_rect, Color(0.92, 0.97, 1.0, 0.86), false, 2.2)
		var start_label: String = "START GAME"
		var start_size: int = _fit_font_size_for_text(card_font, start_label, button_rect.size.x - 26.0, 32, 18)
		var start_base_y: float = _centered_text_baseline(button_rect, card_font, start_size)
		draw_string(card_font, Vector2(button_rect.position.x + 2.0, start_base_y + 2.0), start_label, HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, start_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(card_font, Vector2(button_rect.position.x, start_base_y), start_label, HORIZONTAL_ALIGNMENT_CENTER, button_rect.size.x, start_size, Color(0.98, 0.99, 1.0, 0.98))
		draw_string(card_font, Vector2(view_rect.position.x, button_rect.end.y + 34.0), "Press ENTER or click Start", HORIZONTAL_ALIGNMENT_CENTER, view_rect.size.x, 20, Color(0.84, 0.92, 1.0, 0.8))

		var options_hover: bool = options_button_screen.has_point(hover_screen)
		var options_button: Rect2 = _screen_rect_to_world(options_button_screen)
		draw_rect(options_button, Color(0.13, 0.19, 0.29, 0.94) if not options_hover else Color(0.2, 0.27, 0.38, 0.97), true)
		draw_rect(options_button, Color(0.9, 0.95, 1.0, 0.78), false, 2.0)
		var options_label: String = "OPTIONS"
		var options_size: int = _fit_font_size_for_text(card_font, options_label, options_button.size.x - 22.0, 28, 16)
		var options_base_y: float = _centered_text_baseline(options_button, card_font, options_size)
		draw_string(card_font, Vector2(options_button.position.x + 2.0, options_base_y + 2.0), options_label, HORIZONTAL_ALIGNMENT_CENTER, options_button.size.x, options_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(card_font, Vector2(options_button.position.x, options_base_y), options_label, HORIZONTAL_ALIGNMENT_CENTER, options_button.size.x, options_size, Color(0.96, 0.99, 1.0, 0.98))

		if options_menu_active:
			var opt_title_font: Font = start_menu_title_font if start_menu_title_font != null else card_font
			_draw_options_overlay(view_rect, opt_title_font, card_font)
		return

	if tutorial_screen_active:
		_draw_start_menu_backdrop(view_rect)
		draw_rect(view_rect, Color(0.01, 0.03, 0.07, 0.14), true)
		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		var button_font: Font = hud_font if hud_font != null else card_font
		var title_font: Font = start_menu_title_font if start_menu_title_font != null else button_font

		var panel_screen: Rect2 = _tutorial_panel_rect_screen()
		var panel: Rect2 = _screen_rect_to_world(panel_screen)
		draw_rect(panel, Color(0.03, 0.06, 0.1, 0.86), true)
		draw_rect(panel.grow(-6.0), Color(0.01, 0.03, 0.06, 0.62), true)
		draw_rect(panel, Color(0.9, 0.95, 1.0, 0.42), false, 2.2)

		var title_text: String = "How To Play"
		var title_size: int = _fit_font_size_for_text(title_font, title_text, panel.size.x - 80.0, 58, 30)
		var title_y: float = panel.position.y + 62.0
		draw_string(title_font, Vector2(panel.position.x + 3.0, title_y + 4.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size, Color(0.0, 0.0, 0.0, 0.78))
		draw_string(title_font, Vector2(panel.position.x, title_y), title_text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size, Color(0.95, 0.85, 0.62, 0.98))

		var content_left: float = panel.position.x + 52.0
		var content_width: float = panel.size.x - 104.0
		var content_y: float = panel.position.y + 116.0
		var heading_size: int = 24
		var line_size: int = 18
		var section_gap: float = 10.0
		var line_gap: float = 22.0

		var section_headers: Array[String] = [
			"CONTROLS",
			"HALO SYSTEM",
			"POSITIONING ADVANTAGE",
			"YOUR GOAL"
		]
		var section_lines: Array = [
			[
				"WASD / Arrows: Move selected hero",
				"1 / 2 / 3 or Click Hero: Select who you move",
				"SPACE or Double-Click Hero: Toggle Halo on selected hero",
				"ESC: Pause"
			],
			[
				"Only one hero can hold the Halo at a time.",
				"Halo hero becomes invincible and your main playmaker."
			],
			[
				"Keep all heroes close in the inner formation ring.",
				"Tight formation triggers stronger team payoff.",
				"Tank stabilizes, Ranger sustains, Rogue finishes."
			],
			[
				"Survive waves, choose upgrades, and beat bosses."
			]
		]

		for idx in range(section_headers.size()):
			var header: String = section_headers[idx]
			draw_string(button_font, Vector2(content_left + 2.0, content_y + 2.0), header, HORIZONTAL_ALIGNMENT_LEFT, content_width, heading_size, Color(0.0, 0.0, 0.0, 0.7))
			draw_string(button_font, Vector2(content_left, content_y), header, HORIZONTAL_ALIGNMENT_LEFT, content_width, heading_size, Color(0.94, 0.96, 1.0, 0.98))
			content_y += 26.0
			var lines: Array = section_lines[idx]
			for line: String in lines:
				draw_string(card_font, Vector2(content_left + 2.0, content_y + 1.0), line, HORIZONTAL_ALIGNMENT_LEFT, content_width, line_size, Color(0.0, 0.0, 0.0, 0.64))
				draw_string(card_font, Vector2(content_left, content_y), line, HORIZONTAL_ALIGNMENT_LEFT, content_width, line_size, Color(0.88, 0.94, 1.0, 0.94))
				content_y += line_gap
			content_y += section_gap

		var continue_screen: Rect2 = _tutorial_continue_button_rect()
		var continue_rect: Rect2 = _screen_rect_to_world(continue_screen)
		var continue_hover: bool = continue_screen.has_point(hover_screen)
		draw_rect(continue_rect, Color(0.16, 0.24, 0.36, 0.96) if not continue_hover else Color(0.24, 0.34, 0.48, 0.99), true)
		draw_rect(continue_rect, Color(0.9, 0.95, 1.0, 0.84), false, 2.2)
		var continue_label: String = "CONTINUE TO HERO SELECT"
		var continue_size: int = _fit_font_size_for_text(button_font, continue_label, continue_rect.size.x - 22.0, 24, 13)
		var continue_base_y: float = _centered_text_baseline(continue_rect, button_font, continue_size)
		draw_string(button_font, Vector2(continue_rect.position.x + 2.0, continue_base_y + 2.0), continue_label, HORIZONTAL_ALIGNMENT_CENTER, continue_rect.size.x, continue_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(continue_rect.position.x, continue_base_y), continue_label, HORIZONTAL_ALIGNMENT_CENTER, continue_rect.size.x, continue_size, Color(0.96, 0.99, 1.0, 0.98))

		return

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

			var custom_card: Texture2D = null
			if i == HERO_KNIGHT:
				custom_card = start_card_tank_custom
			elif i == HERO_RANGER:
				custom_card = start_card_ranger_custom

			if custom_card != null:
				var custom_rect: Rect2 = rect.grow(-4.0)
				draw_rect(custom_rect, Color(0.0, 0.0, 0.0, 0.22), true)
				_draw_texture_fit(custom_card, custom_rect, Color(1.0, 1.0, 1.0, 0.98))
				if is_hover:
					draw_rect(custom_rect, Color(1.0, 1.0, 1.0, 0.09), true)
				draw_rect(rect, Color(0.96, 0.98, 1.0, 0.9), false, 2.4)
				continue

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
	_draw_spectral_halo()
	_draw_team_power_overlay()
	_draw_readability_pass()

	if halo_switch_feedback_timer > 0.0:
		var t: float = halo_switch_feedback_timer / HALO_SWITCH_FEEDBACK_DURATION
		var pulse_color: Color = Color(1.0, 0.96, 0.58, 0.8 * t)
		draw_line(halo_switch_feedback_from, halo_switch_feedback_to, pulse_color, 6.0 * t)
		draw_circle(halo_switch_feedback_to, 12.0 + (1.0 - t) * 16.0, Color(1.0, 0.96, 0.58, 0.25 * t))

	var view_size: Vector2 = _viewport_size()
	var bar_rect_screen: Rect2 = Rect2(Vector2(view_size.x * 0.5 - 160.0, 58.0), Vector2(320.0, 14.0))
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
			var border_color: Color = Color(0.9, 0.95, 1.0, 0.72)
			if _is_boss_reward_upgrade(upgrade_id):
				base_color = Color(0.28, 0.21, 0.07, 0.96)
				text_color = Color(1.0, 0.94, 0.72, 0.98)
				border_color = Color(1.0, 0.86, 0.42, 0.92)
			if is_hover:
				if _is_boss_reward_upgrade(upgrade_id):
					base_color = Color(0.35, 0.27, 0.09, 0.99)
					text_color = Color(1.0, 0.98, 0.9, 1.0)
					border_color = Color(1.0, 0.93, 0.62, 0.98)
				else:
					base_color = Color(0.2, 0.28, 0.38, 0.98)
					text_color = Color(1.0, 1.0, 1.0, 1.0)
			var custom_card: Texture2D = _custom_upgrade_card_texture(upgrade_id)
			if custom_card != null:
				var art_rect: Rect2 = rect.grow(-1.0)
				draw_rect(rect, Color(0.08, 0.1, 0.16, 0.98), true)
				draw_texture_rect(custom_card, art_rect, false, Color(1.0, 1.0, 1.0, 1.0))
				if is_hover:
					draw_rect(art_rect, Color(1.0, 1.0, 1.0, 0.08), true)
				draw_rect(rect, Color(0.95, 0.98, 1.0, 0.84), false, 2.0)
				continue
			draw_rect(rect, base_color, true)
			draw_rect(rect, border_color, false, 2.0)
			draw_string(card_font, rect.position + Vector2(14.0, 30.0), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 19, text_color)
			var y: float = 56.0
			for line: String in desc_lines:
				draw_string(card_font, rect.position + Vector2(14.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 15, Color(text_color.r, text_color.g, text_color.b, 0.92))
				y += 18.0
			if _is_boss_reward_upgrade(upgrade_id):
				draw_string(card_font, rect.position + Vector2(14.0, rect.size.y - 10.0), "BOSS REWARD", HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 13, Color(1.0, 0.88, 0.5, 0.95))

	if boss_victory_prompt_active:
		draw_rect(view_rect, Color(0.0, 0.0, 0.0, 0.66), true)
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		var button_font: Font = hud_font if hud_font != null else card_font
		var title_font: Font = start_menu_title_font if start_menu_title_font != null else button_font
		var body_font: Font = button_font
		var panel_screen: Rect2 = _boss_victory_panel_rect_screen()
		var panel: Rect2 = _screen_rect_to_world(panel_screen)
		draw_rect(panel, Color(0.03, 0.06, 0.1, 0.8), true)
		draw_rect(panel.grow(-6.0), Color(0.01, 0.03, 0.06, 0.58), true)
		draw_rect(panel, Color(0.9, 0.95, 1.0, 0.38), false, 2.2)

		var title_line_1: String = "MAIN BOSS"
		var title_line_2: String = "DEFEATED"
		var title_w: float = panel.size.x - 64.0
		var title_size_1: int = _fit_font_size_for_text(title_font, title_line_1, title_w, 58, 26)
		var title_size_2: int = _fit_font_size_for_text(title_font, title_line_2, title_w, 56, 24)
		var title_y: float = panel.position.y + 64.0
		draw_string(title_font, Vector2(panel.position.x + 3.0, title_y + 4.0), title_line_1, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size_1, Color(0.0, 0.0, 0.0, 0.78))
		draw_string(title_font, Vector2(panel.position.x, title_y), title_line_1, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size_1, Color(0.95, 0.85, 0.62, 0.98))
		title_y += 46.0
		draw_string(title_font, Vector2(panel.position.x + 3.0, title_y + 4.0), title_line_2, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size_2, Color(0.0, 0.0, 0.0, 0.78))
		draw_string(title_font, Vector2(panel.position.x, title_y), title_line_2, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, title_size_2, Color(0.95, 0.85, 0.62, 0.98))

		var continue_screen: Rect2 = _boss_victory_continue_button_rect()
		var continue_rect: Rect2 = _screen_rect_to_world(continue_screen)
		var home_screen: Rect2 = _boss_victory_home_button_rect()
		var home_rect: Rect2 = _screen_rect_to_world(home_screen)

		var body_top: float = panel.position.y + 160.0
		var body_bottom: float = continue_rect.position.y - 18.0
		var body_max_w: float = panel.size.x - 88.0
		var body_header: String = "CONTINUE YOUR RUN?"
		var info_text: String = "You keep all skills and upgrades. Fallen heroes are revived on continue. Waves continue from 11 onward, and enemy challenge keeps scaling up each wave."
		var info_lines: Array[String] = _wrap_text_lines(info_text, 46, 5)
		var header_size: int = _fit_font_size_for_text(body_font, body_header, body_max_w, 26, 16)
		var info_size: int = 17
		for line: String in info_lines:
			info_size = mini(info_size, _fit_font_size_for_text(body_font, line, body_max_w, 17, 12))
		var total_height: float = 34.0 + float(info_lines.size()) * 24.0
		var available_height: float = maxf(88.0, body_bottom - body_top)
		var line_y: float = body_top + maxf(0.0, (available_height - total_height) * 0.5)

		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		draw_string(body_font, Vector2(panel.position.x + 46.0, line_y + 1.0), body_header, HORIZONTAL_ALIGNMENT_LEFT, body_max_w, header_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(body_font, Vector2(panel.position.x + 44.0, line_y), body_header, HORIZONTAL_ALIGNMENT_LEFT, body_max_w, header_size, Color(0.9, 0.96, 1.0, 0.98))
		line_y += 34.0
		for line: String in info_lines:
			draw_string(body_font, Vector2(panel.position.x + 46.0, line_y + 1.0), line, HORIZONTAL_ALIGNMENT_LEFT, body_max_w, info_size, Color(0.0, 0.0, 0.0, 0.62))
			draw_string(body_font, Vector2(panel.position.x + 44.0, line_y), line, HORIZONTAL_ALIGNMENT_LEFT, body_max_w, info_size, Color(0.9, 0.96, 1.0, 0.96))
			line_y += 24.0

		var continue_hover: bool = continue_screen.has_point(hover_screen)
		draw_rect(continue_rect, Color(0.16, 0.24, 0.36, 0.96) if not continue_hover else Color(0.24, 0.34, 0.48, 0.99), true)
		draw_rect(continue_rect, Color(0.9, 0.95, 1.0, 0.84), false, 2.2)
		var continue_label: String = "CONTINUE RUN"
		var continue_size: int = _fit_font_size_for_text(button_font, continue_label, continue_rect.size.x - 22.0, 22, 13)
		var continue_base_y: float = _centered_text_baseline(continue_rect, button_font, continue_size)
		draw_string(button_font, Vector2(continue_rect.position.x + 2.0, continue_base_y + 2.0), continue_label, HORIZONTAL_ALIGNMENT_CENTER, continue_rect.size.x, continue_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(continue_rect.position.x, continue_base_y), continue_label, HORIZONTAL_ALIGNMENT_CENTER, continue_rect.size.x, continue_size, Color(0.96, 0.99, 1.0, 0.98))

		var home_hover: bool = home_screen.has_point(hover_screen)
		draw_rect(home_rect, Color(0.15, 0.21, 0.3, 0.96) if not home_hover else Color(0.23, 0.3, 0.4, 0.98), true)
		draw_rect(home_rect, Color(0.9, 0.95, 1.0, 0.82), false, 2.2)
		var home_label: String = "RETURN TO HOME"
		var home_size: int = _fit_font_size_for_text(button_font, home_label, home_rect.size.x - 22.0, 20, 13)
		var home_base_y: float = _centered_text_baseline(home_rect, button_font, home_size)
		draw_string(button_font, Vector2(home_rect.position.x + 2.0, home_base_y + 2.0), home_label, HORIZONTAL_ALIGNMENT_CENTER, home_rect.size.x, home_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(home_rect.position.x, home_base_y), home_label, HORIZONTAL_ALIGNMENT_CENTER, home_rect.size.x, home_size, Color(0.96, 0.99, 1.0, 0.98))
		return

	if game_over:
		draw_rect(view_rect, Color(0.0, 0.0, 0.0, 0.62), true)
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		var title_font: Font = start_menu_title_font if start_menu_title_font != null else card_font
		var button_font: Font = hud_font if hud_font != null else card_font
		var panel_screen: Rect2 = Rect2((_viewport_size() - GAME_OVER_PANEL_SIZE) * 0.5, GAME_OVER_PANEL_SIZE)
		var panel: Rect2 = _screen_rect_to_world(panel_screen)
		draw_rect(panel, Color(0.03, 0.05, 0.09, 0.78), true)
		draw_rect(panel.grow(-6.0), Color(0.01, 0.02, 0.05, 0.52), true)
		draw_rect(panel, Color(0.9, 0.95, 1.0, 0.32), false, 2.2)
		var title_y: float = panel.position.y + 74.0
		draw_string(title_font, Vector2(panel.position.x + 4.0, title_y + 5.0), "GAME OVER", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 66, Color(0.0, 0.0, 0.0, 0.78))
		draw_string(title_font, Vector2(panel.position.x, title_y), "GAME OVER", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 66, Color(0.94, 0.44, 0.42, 0.98))
		var summary_text: String = "You reached Wave %d in %.1fs" % [wave, elapsed_time]
		var summary_size: int = _fit_font_size_for_text(card_font, summary_text, panel.size.x - 26.0, 23, 14)
		var summary_rect: Rect2 = Rect2(panel.position + Vector2(0.0, 106.0), Vector2(panel.size.x, 34.0))
		var summary_base_y: float = _centered_text_baseline(summary_rect, card_font, summary_size)
		draw_string(card_font, Vector2(panel.position.x, summary_base_y), summary_text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, summary_size, Color(0.92, 0.96, 1.0, 0.94))

		var menu_button_screen: Rect2 = _game_over_button_rect()
		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var is_hover: bool = menu_button_screen.has_point(hover_screen)
		var menu_button: Rect2 = _screen_rect_to_world(menu_button_screen)
		draw_rect(menu_button, Color(0.15, 0.2, 0.3, 0.96) if not is_hover else Color(0.22, 0.29, 0.4, 0.98), true)
		draw_rect(menu_button, Color(0.9, 0.95, 1.0, 0.82), false, 2.2)
		var gameover_label: String = "RETURN TO HOME"
		var gameover_size: int = _fit_font_size_for_text(button_font, gameover_label, menu_button.size.x - 24.0, 22, 14)
		var gameover_base_y: float = _centered_text_baseline(menu_button, button_font, gameover_size)
		draw_string(button_font, Vector2(menu_button.position.x + 2.0, gameover_base_y + 2.0), gameover_label, HORIZONTAL_ALIGNMENT_CENTER, menu_button.size.x, gameover_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(menu_button.position.x, gameover_base_y), gameover_label, HORIZONTAL_ALIGNMENT_CENTER, menu_button.size.x, gameover_size, Color(0.96, 0.99, 1.0, 0.98))
		return

	if pause_menu_active:
		draw_rect(view_rect, Color(0.0, 0.0, 0.0, 0.58), true)
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		var title_font: Font = start_menu_title_font if start_menu_title_font != null else card_font
		var button_font: Font = hud_font if hud_font != null else card_font
		var panel_screen: Rect2 = Rect2((_viewport_size() - PAUSE_PANEL_SIZE) * 0.5, PAUSE_PANEL_SIZE)
		var panel: Rect2 = _screen_rect_to_world(panel_screen)
		draw_rect(panel, Color(0.03, 0.06, 0.1, 0.76), true)
		draw_rect(panel.grow(-6.0), Color(0.01, 0.03, 0.06, 0.5), true)
		draw_rect(panel, Color(0.9, 0.95, 1.0, 0.32), false, 2.2)

		var title_y: float = panel.position.y + 68.0
		draw_string(title_font, Vector2(panel.position.x + 4.0, title_y + 5.0), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 62, Color(0.0, 0.0, 0.0, 0.78))
		draw_string(title_font, Vector2(panel.position.x, title_y), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 62, Color(0.96, 0.86, 0.62, 0.98))

		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var resume_screen: Rect2 = _pause_resume_button_rect()
		var resume_hover: bool = resume_screen.has_point(hover_screen)
		var resume_rect: Rect2 = _screen_rect_to_world(resume_screen)
		draw_rect(resume_rect, Color(0.15, 0.22, 0.34, 0.96) if not resume_hover else Color(0.22, 0.31, 0.45, 0.98), true)
		draw_rect(resume_rect, Color(0.9, 0.95, 1.0, 0.82), false, 2.2)
		var resume_label: String = "RESUME"
		var resume_size: int = _fit_font_size_for_text(button_font, resume_label, resume_rect.size.x - 24.0, 25, 14)
		var resume_base_y: float = _centered_text_baseline(resume_rect, button_font, resume_size)
		draw_string(button_font, Vector2(resume_rect.position.x + 2.0, resume_base_y + 2.0), resume_label, HORIZONTAL_ALIGNMENT_CENTER, resume_rect.size.x, resume_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(resume_rect.position.x, resume_base_y), resume_label, HORIZONTAL_ALIGNMENT_CENTER, resume_rect.size.x, resume_size, Color(0.96, 0.99, 1.0, 0.98))

		var home_screen: Rect2 = _pause_home_button_rect()
		var home_hover: bool = home_screen.has_point(hover_screen)
		var home_rect: Rect2 = _screen_rect_to_world(home_screen)
		draw_rect(home_rect, Color(0.15, 0.21, 0.3, 0.96) if not home_hover else Color(0.23, 0.3, 0.4, 0.98), true)
		draw_rect(home_rect, Color(0.9, 0.95, 1.0, 0.82), false, 2.2)
		var home_label: String = "RETURN TO HOME"
		var home_size: int = _fit_font_size_for_text(button_font, home_label, home_rect.size.x - 24.0, 22, 14)
		var home_base_y: float = _centered_text_baseline(home_rect, button_font, home_size)
		draw_string(button_font, Vector2(home_rect.position.x + 2.0, home_base_y + 2.0), home_label, HORIZONTAL_ALIGNMENT_CENTER, home_rect.size.x, home_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(home_rect.position.x, home_base_y), home_label, HORIZONTAL_ALIGNMENT_CENTER, home_rect.size.x, home_size, Color(0.96, 0.99, 1.0, 0.98))

		var options_screen: Rect2 = _pause_options_button_rect()
		var options_hover: bool = options_screen.has_point(hover_screen)
		var options_rect: Rect2 = _screen_rect_to_world(options_screen)
		draw_rect(options_rect, Color(0.14, 0.2, 0.3, 0.94) if not options_hover else Color(0.22, 0.29, 0.41, 0.98), true)
		draw_rect(options_rect, Color(0.9, 0.95, 1.0, 0.8), false, 2.0)
		var options_label: String = "OPTIONS"
		var options_size: int = _fit_font_size_for_text(button_font, options_label, options_rect.size.x - 20.0, 22, 14)
		var options_base_y: float = _centered_text_baseline(options_rect, button_font, options_size)
		draw_string(button_font, Vector2(options_rect.position.x + 2.0, options_base_y + 2.0), options_label, HORIZONTAL_ALIGNMENT_CENTER, options_rect.size.x, options_size, Color(0.0, 0.0, 0.0, 0.62))
		draw_string(button_font, Vector2(options_rect.position.x, options_base_y), options_label, HORIZONTAL_ALIGNMENT_CENTER, options_rect.size.x, options_size, Color(0.96, 0.99, 1.0, 0.98))
		var helper_text: String = "Press ESC to resume"
		var helper_size: int = _fit_font_size_for_text(card_font, helper_text, panel.size.x - 20.0, 18, 13)
		var helper_y: float = minf(view_rect.end.y - 16.0, home_rect.end.y + 30.0)
		draw_string(card_font, Vector2(panel.position.x, helper_y), helper_text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, helper_size, Color(0.84, 0.92, 1.0, 0.86))
		if options_menu_active:
			var opt_title_font: Font = start_menu_title_font if start_menu_title_font != null else button_font
			_draw_options_overlay(view_rect, opt_title_font, card_font)
		return

func _draw_team_power_overlay() -> void:
	if start_selection_active or start_screen_active or tutorial_screen_active or pause_menu_active or upgrade_phase_active or game_over or heroes.is_empty():
		return

	_draw_team_links()
	_draw_power_circle()
	_draw_health_drops()
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
			var perfect_link_mult: float = 1.3 if perfect_position_active else 1.0
			var alpha: float = TEAM_LINK_MAX_ALPHA * closeness * team_power * perfect_link_mult
			var width: float = 1.0 + 2.4 * closeness * team_power * perfect_link_mult
			draw_line(a, b, Color(0.68, 0.95, 1.0, alpha), width, true)
			draw_circle(a.lerp(b, 0.5), 1.2 + 1.1 * closeness * perfect_link_mult, Color(0.9, 0.98, 1.0, alpha * 0.9))

	if perfect_position_active:
		var glow_pulse: float = 0.7 + 0.3 * sin(float(Time.get_ticks_msec()) * 0.006)
		for hero: Hero in alive:
			var glow_radius: float = hero.body_radius + 12.0 + glow_pulse * 4.0
			draw_circle(hero.global_position, glow_radius, Color(0.74, 0.95, 1.0, 0.045 + glow_pulse * 0.025))
			draw_arc(hero.global_position, glow_radius + 2.5, 0.0, TAU, 36, Color(0.95, 0.99, 1.0, 0.2 + glow_pulse * 0.12), 1.2)

func _draw_power_circle() -> void:
	if team_power_center == Vector2.ZERO:
		return
	var now: float = float(Time.get_ticks_msec())
	# Gentle pulse so it feels alive without drawing too much attention.
	var breathe: float = 1.0 + sin(now * 0.0014) * (0.012 + team_power * 0.018)
	var r: float = team_power_radius * breathe
	var line_alpha: float = 0.045 + team_power * 0.17
	var outer_line_alpha: float = clampf(line_alpha * 0.78, 0.0, 0.26)
	var fill_alpha: float = 0.008 + team_power * 0.025
	var width: float = 1.0 + team_power * 1.9
	if perfect_position_active:
		var perfect_breathe: float = 1.0 + sin(now * 0.0019) * (0.014 + team_power * 0.02)
		r *= perfect_breathe
		width *= 1.15
		fill_alpha = minf(0.08, fill_alpha + 0.018)
		outer_line_alpha = minf(0.34, outer_line_alpha + 0.08)
	if perfect_position_feedback_timer > 0.0:
		var cue_t: float = perfect_position_feedback_timer / PERFECT_POSITION_FEEDBACK_DURATION
		draw_arc(team_power_center, r + (1.0 - cue_t) * 18.0, 0.0, TAU, 52, Color(1.0, 0.96, 0.72, 0.18 * cue_t), 1.8 * cue_t + 0.6)
		draw_circle(team_power_center, r * 0.52 + (1.0 - cue_t) * 10.0, Color(1.0, 0.94, 0.66, 0.045 * cue_t))

	draw_circle(team_power_center, r, Color(0.78, 0.95, 1.0, fill_alpha))
	# Use a dotted outer trace to avoid arc seam artifacts entirely.
	var outer_trace_points: int = 40
	for i in range(outer_trace_points):
		var a: float = TAU * float(i) / float(outer_trace_points)
		var p_trace: Vector2 = team_power_center + Vector2.RIGHT.rotated(a) * r
		draw_circle(p_trace, 0.65 + team_power * 0.45, Color(0.92, 0.98, 1.0, outer_line_alpha * 0.9))

	var spin_angle: float = now * 0.0004 * (0.9 + team_power * 0.6)
	# Spin cue with soft moving beacons instead of line sweeps (avoids seam/cap artifacts).
	var beacon_a: Vector2 = team_power_center + Vector2.RIGHT.rotated(spin_angle) * r
	var beacon_b: Vector2 = team_power_center + Vector2.RIGHT.rotated(spin_angle + PI * 0.92) * r
	draw_circle(beacon_a, 2.0 + team_power * 0.9, Color(0.96, 0.99, 1.0, outer_line_alpha * 1.3))
	draw_circle(beacon_a, 3.6 + team_power * 1.2, Color(0.9, 0.97, 1.0, outer_line_alpha * 0.26))
	draw_circle(beacon_b, 1.6 + team_power * 0.75, Color(0.88, 0.95, 1.0, outer_line_alpha * 1.0))
	draw_circle(beacon_b, 3.0 + team_power * 1.0, Color(0.84, 0.93, 1.0, outer_line_alpha * 0.2))
	var inner_alpha: float = 0.055 + team_power * 0.14
	var inner_width: float = 0.95 + team_power * 1.15
	if perfect_position_active:
		inner_alpha = minf(0.32, inner_alpha + 0.095)
		inner_width += 0.6
	draw_arc(team_power_center, PERFECT_POSITION_RING_RADIUS, 0.0, TAU, 52, Color(0.72, 0.92, 1.0, inner_alpha), inner_width)

	var spark_count_outer: int = 12
	for i in range(spark_count_outer):
		var phase: float = TAU * float(i) / float(spark_count_outer)
		var wobble: float = sin(now * 0.0016 + float(i) * 1.2)
		var sr: float = r + wobble * (0.8 + team_power * 1.7)
		var angle: float = phase + now * 0.00085 * (1.0 + team_power)
		var p: Vector2 = team_power_center + Vector2.RIGHT.rotated(angle) * sr
		draw_circle(p, 1.1 + team_power * 1.1, Color(0.94, 0.98, 1.0, 0.14 + team_power * 0.16))

	var spark_count_inner: int = 10
	for i in range(spark_count_inner):
		var phase_inner: float = TAU * float(i) / float(spark_count_inner)
		var wobble_inner: float = sin(now * 0.0014 + float(i) * 1.48)
		var inner_r: float = PERFECT_POSITION_RING_RADIUS + wobble_inner * (0.7 + team_power * 1.8)
		var angle_inner: float = phase_inner - now * 0.00062 * (0.9 + team_power * 0.8)
		var p_inner: Vector2 = team_power_center + Vector2.RIGHT.rotated(angle_inner) * inner_r
		draw_circle(p_inner, 1.0 + team_power * 0.95, Color(0.84, 0.95, 1.0, 0.16 + team_power * 0.14))

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
		var spike_count: int = 8
		var spin: float = float(Time.get_ticks_msec()) * 0.0018
		for i in range(spike_count):
			var angle: float = spin + TAU * float(i) / float(spike_count)
			var dir: Vector2 = Vector2.RIGHT.rotated(angle)
			var inner_len: float = draw_radius * 0.2
			var outer_len: float = draw_radius * (0.66 + (1.0 - t) * 0.42)
			var p0: Vector2 = pos + dir * inner_len
			var p1: Vector2 = pos + dir * outer_len
			draw_line(p0, p1, Color(1.0, 0.9, 0.64, 0.82 * t), 2.0 + 1.8 * t, true)
		draw_line(pos + Vector2(-draw_radius * 0.22, 0.0), pos + Vector2(draw_radius * 0.22, 0.0), Color(1.0, 0.95, 0.78, 0.88 * t), 2.2, true)
		draw_line(pos + Vector2(0.0, -draw_radius * 0.22), pos + Vector2(0.0, draw_radius * 0.22), Color(1.0, 0.95, 0.78, 0.88 * t), 2.2, true)

func _draw_health_drops() -> void:
	if health_drops.is_empty():
		return
	var now_sec: float = float(Time.get_ticks_msec()) * 0.001
	var use_sheet: bool = health_drop_sheet != null and health_drop_frame_size.x > 0.0 and health_drop_frame_size.y > 0.0
	for drop: Dictionary in health_drops:
		var pos_variant: Variant = drop.get("position", Vector2.ZERO)
		var pos: Vector2 = pos_variant if pos_variant is Vector2 else Vector2.ZERO
		var radius: float = float(drop.get("radius", 6.0))
		var life: float = float(drop.get("life", HEALTH_DROP_LIFETIME))
		var pulse_phase: float = float(drop.get("pulse", 0.0))
		var life_t: float = clampf(life / HEALTH_DROP_LIFETIME, 0.0, 1.0)
		var pulse: float = 1.0 + sin(now_sec * 3.8 + pulse_phase) * 0.12
		var r: float = radius * pulse
		var halo_alpha: float = 0.12 + 0.1 * life_t
		draw_circle(pos, r + 4.4, Color(0.54, 1.0, 0.56, halo_alpha))
		if use_sheet:
			var frame_count: int = max(1, HEALTH_DROP_SHEET_FRAME_COUNT)
			var frame_idx: int = int(floor(now_sec * HEALTH_DROP_SHEET_FPS + pulse_phase * 0.8)) % frame_count
			var src_x: float = float(frame_idx) * health_drop_frame_size.x
			var src_rect: Rect2 = Rect2(src_x, 0.0, health_drop_frame_size.x, health_drop_frame_size.y)
			var sprite_scale: float = HEALTH_DROP_SHEET_BASE_SCALE + radius * 0.038
			sprite_scale *= 0.95 + pulse * 0.11
			var draw_size: Vector2 = health_drop_frame_size * sprite_scale
			var draw_rect: Rect2 = Rect2(pos - draw_size * 0.5, draw_size)
			draw_texture_rect_region(health_drop_sheet, draw_rect, src_rect, Color(1.0, 1.0, 1.0, 0.8 + life_t * 0.2), false)
		else:
			var core_alpha: float = 0.34 + 0.3 * life_t
			draw_circle(pos, r + 1.8, Color(0.72, 1.0, 0.76, core_alpha * 0.7))
			draw_circle(pos, r, Color(0.89, 1.0, 0.9, core_alpha))
			var cross_half: float = r * 0.44
			var cross_thickness: float = 1.2 + r * 0.08
			draw_line(pos + Vector2(-cross_half, 0.0), pos + Vector2(cross_half, 0.0), Color(0.2, 0.7, 0.24, 0.92), cross_thickness, true)
			draw_line(pos + Vector2(0.0, -cross_half), pos + Vector2(0.0, cross_half), Color(0.2, 0.7, 0.24, 0.92), cross_thickness, true)

func _draw_spectral_halo() -> void:
	if not spectral_halo_unlocked:
		return
	if start_selection_active or start_screen_active or tutorial_screen_active or pause_menu_active or game_over:
		return
	if spectral_halo_count <= 0:
		return
	_ensure_spectral_halo_slots()
	var now: float = float(Time.get_ticks_msec())
	for h in range(spectral_halo_count):
		var halo_pos: Vector2 = spectral_halo_positions[h]
		var phase: float = float(h) * 1.37
		var pulse: float = 1.0 + sin(now * 0.007 + phase) * 0.11
		var r: float = SPECTRAL_HALO_RADIUS * pulse
		draw_circle(halo_pos, r + 5.0, Color(1.0, 0.94, 0.62, 0.14))
		draw_circle(halo_pos, r, Color(1.0, 0.93, 0.52, 0.24))
		draw_arc(halo_pos, r + 1.0, 0.0, TAU, 42, Color(1.0, 0.98, 0.72, 0.78), 2.2)
