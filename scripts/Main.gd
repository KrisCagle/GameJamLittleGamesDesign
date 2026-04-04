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

const VIEW_SIZE := Vector2(1280, 720)
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

var halo_index: int = 0
var halo_equipped: bool = true
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
var upgrade_phase_active: bool = false
var upgrade_choices: Array[int] = []
var upgrade_levels: Dictionary = {}
var last_upgrade_choices: Array[int] = []

var ranger_halo_heal_amount: float = 14.0
var ranger_halo_heal_radius: float = 165.0
var knight_taunt_radius: float = 240.0
var knight_pull_radius: float = 220.0
var knight_guard_heal_per_sec: float = 4.0

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

	_spawn_heroes()
	halo_equipped = true
	halo_charge = HALO_CHARGE_MAX
	halo_recharge_delay_timer = 0.0
	halo_toggle_lock_timer = 0.0
	_set_halo(0)
	halo_switch_feedback_timer = 0.0
	world_camera.position = arena_rect.get_center()
	world_camera.limit_left = int(arena_rect.position.x)
	world_camera.limit_top = int(arena_rect.position.y)
	world_camera.limit_right = int(arena_rect.end.x)
	world_camera.limit_bottom = int(arena_rect.end.y)
	_start_wave()
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	if game_over:
		_update_camera(delta)
		_update_ui()
		queue_redraw()
		return

	if upgrade_phase_active:
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
	_update_camera(delta)
	_update_ui()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if game_over and (event.keycode == KEY_ENTER or event.keycode == KEY_R):
			get_tree().reload_current_scene()
			return

		if upgrade_phase_active:
			return

		match event.keycode:
			KEY_1:
				_set_halo(0)
			KEY_2:
				_set_halo(1)
			KEY_3:
				_set_halo(2)
			KEY_SPACE:
				if halo_equipped:
					_drop_halo_manual()
				else:
					_attempt_halo_reactivate()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not game_over:
		if upgrade_phase_active:
			_choose_upgrade_from_point(event.position)
			return
		_set_halo_from_point(_screen_to_world(event.position))

func _spawn_heroes() -> void:
	heroes.clear()
	var c: Vector2 = arena_rect.get_center()

	var knight: Hero = HeroScript.new()
	knight.configure(HERO_KNIGHT, c + Vector2(0.0, -28.0))
	heroes_root.add_child(knight)
	heroes.append(knight)

	var ranger: Hero = HeroScript.new()
	ranger.configure(HERO_RANGER, c + Vector2(-84.0, 62.0))
	heroes_root.add_child(ranger)
	heroes.append(ranger)

	var rogue: Hero = HeroScript.new()
	rogue.configure(HERO_ROGUE, c + Vector2(84.0, 62.0))
	heroes_root.add_child(rogue)
	heroes.append(rogue)

func _set_halo(index: int) -> void:
	if index < 0 or index >= heroes.size():
		return
	if heroes[index].health <= 0.0:
		return

	var previous_index: int = halo_index
	halo_index = index

	if not halo_equipped:
		_attempt_halo_reactivate(false)

	_sync_halo_state()
	if previous_index != halo_index or not heroes[halo_index].has_halo:
		_on_halo_switched(previous_index, halo_index)

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
		_set_halo(closest_index)

func _start_wave() -> void:
	wave += 1
	boss_spawn_pending = wave >= 5 and (wave % 5 == 0)
	if boss_spawn_pending:
		spawn_remaining = 0
	else:
		spawn_remaining = 16 + wave * 4 + int(floor(float(wave) * 1.4))
	spawn_timer = 0.25
	spawning = true
	waiting_for_next_wave = false
	upgrade_phase_active = false
	intermission_timer = 0.0
	_sync_halo_state()

func _update_spawning(delta: float) -> void:
	if not spawning:
		return

	spawn_timer -= delta
	var interval: float = maxf(0.55 - float(wave) * 0.015, 0.22)
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
	enemies_root.add_child(enemy)
	enemies.append(enemy)

func _spawn_boss() -> void:
	var enemy: Enemy = EnemyScript.new()
	var target: Hero = _pick_spawn_target(ENEMY_BOSS)
	enemy.configure(ENEMY_BOSS, _boss_spawn_point(), target, wave)
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
			enemies[i].queue_free()
			enemies.remove_at(i)

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
						enemy.take_damage(projectile_damage)
						hit = true
						break
			else:
				for hero: Hero in heroes:
					if hero.health <= 0.0:
						continue
					var impact_dist: float = projectile_radius + hero.body_radius
					if projectile_pos.distance_squared_to(hero.global_position) <= impact_dist * impact_dist:
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
		return

	upgrade_phase_active = true
	intermission_timer = 999.0
	_sync_halo_state()

func _roll_upgrade_choices() -> Array[int]:
	var pool: Array[int] = []
	pool.append(UPGRADE_HALO_FLOW)
	pool.append(UPGRADE_RANGER_REMEDY)
	pool.append(UPGRADE_ROGUE_OVERDRIVE)
	pool.append(UPGRADE_TANK_BASTION)
	pool.append(UPGRADE_FIELD_PATCH)
	pool.append(UPGRADE_HALO_RESERVOIR)
	pool.append(UPGRADE_RANGER_FOCUS)
	pool.append(UPGRADE_TANK_MARCH)
	pool.append(UPGRADE_ROGUE_PRECISION)
	pool.append(UPGRADE_TEAM_TRAINING)

	var result: Array[int] = []
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

func _upgrade_slot_rect(slot: int) -> Rect2:
	var width: float = 318.0
	var height: float = 124.0
	var gap: float = 16.0
	var total_width: float = width * 3.0 + gap * 2.0
	var start_x: float = (VIEW_SIZE.x - total_width) * 0.5
	var y: float = VIEW_SIZE.y * 0.57
	return Rect2(Vector2(start_x + float(slot) * (width + gap), y), Vector2(width, height))

func _camera_target_position() -> Vector2:
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

func _view_origin() -> Vector2:
	return world_camera.position - VIEW_SIZE * 0.5

func _viewport_rect_world() -> Rect2:
	return Rect2(_view_origin(), VIEW_SIZE)

func _screen_to_world(screen_point: Vector2) -> Vector2:
	return _view_origin() + screen_point

func _screen_rect_to_world(screen_rect: Rect2) -> Rect2:
	return Rect2(_screen_to_world(screen_rect.position), screen_rect.size)

func _wrap_text_lines(text: String, max_chars_per_line: int, max_lines: int) -> Array[String]:
	var words: PackedStringArray = text.split(" ", false)
	var lines: Array[String] = []
	var current: String = ""

	for word in words:
		var candidate: String = word if current.is_empty() else current + " " + word
		if candidate.length() > max_chars_per_line and not current.is_empty():
			lines.append(current)
			current = word
			if lines.size() >= max_lines:
				break
		else:
			current = candidate

	if lines.size() < max_lines and not current.is_empty():
		lines.append(current)

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
	return ""

func _update_ui() -> void:
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
		else:
			hint_label.text = "Halo ready. Press SPACE or click a hero to re-equip."
	elif waiting_for_next_wave:
		hint_label.text = "Wave clear. Next wave in %.1f seconds." % [maxf(intermission_timer, 0.0)]
	else:
		hint_label.text = "WASD/Arrows move halo hero. Switch with 1/2/3 or click. SPACE drops halo to recharge."

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

func _draw() -> void:
	var view_rect: Rect2 = _viewport_rect_world()
	draw_rect(arena_rect.grow(2600.0), Color(0.05, 0.07, 0.1), true)
	draw_rect(arena_rect, Color(0.09, 0.13, 0.18), true)
	draw_rect(arena_rect, Color(0.42, 0.86, 1.0, 0.9), false, 3.0)

	var right: float = arena_rect.position.x + arena_rect.size.x
	var bottom: float = arena_rect.position.y + arena_rect.size.y
	for x in range(int(arena_rect.position.x) + 64, int(right), 64):
		draw_line(Vector2(x, arena_rect.position.y), Vector2(x, bottom), Color(1, 1, 1, 0.04), 1.0)
	for y in range(int(arena_rect.position.y) + 64, int(bottom), 64):
		draw_line(Vector2(arena_rect.position.x, y), Vector2(right, y), Color(1, 1, 1, 0.04), 1.0)

	if halo_switch_feedback_timer > 0.0:
		var t: float = halo_switch_feedback_timer / HALO_SWITCH_FEEDBACK_DURATION
		var pulse_color: Color = Color(1.0, 0.96, 0.58, 0.8 * t)
		draw_line(halo_switch_feedback_from, halo_switch_feedback_to, pulse_color, 6.0 * t)
		draw_circle(halo_switch_feedback_to, 12.0 + (1.0 - t) * 16.0, Color(1.0, 0.96, 0.58, 0.25 * t))

	var bar_rect_screen: Rect2 = Rect2(Vector2(VIEW_SIZE.x * 0.5 - 160.0, 14.0), Vector2(320.0, 14.0))
	var bar_rect: Rect2 = _screen_rect_to_world(bar_rect_screen)
	draw_rect(bar_rect, Color(0.04, 0.06, 0.08, 0.9), true)
	var fill_ratio: float = clampf(halo_charge / maxf(halo_charge_cap, 0.01), 0.0, 1.0)
	var fill_color: Color = Color(0.98, 0.9, 0.35) if halo_equipped else Color(0.55, 0.86, 1.0)
	draw_rect(Rect2(bar_rect.position, Vector2(bar_rect.size.x * fill_ratio, bar_rect.size.y)), fill_color, true)
	draw_rect(bar_rect, Color(0.95, 0.98, 1.0, 0.7), false, 1.5)

	if upgrade_phase_active:
		draw_rect(view_rect, Color(0.02, 0.04, 0.08, 0.34), true)
		var hover_screen: Vector2 = get_viewport().get_mouse_position()
		var card_font: Font = hero_status.get_theme_font("font")
		if card_font == null:
			card_font = ThemeDB.fallback_font
		for i in range(upgrade_choices.size()):
			var upgrade_id: int = upgrade_choices[i]
			var title: String = "%d. %s" % [i + 1, _upgrade_name(upgrade_id)]
			var desc_lines: Array[String] = _wrap_text_lines(_upgrade_description(upgrade_id), 34, 3)
			var rect_screen: Rect2 = _upgrade_slot_rect(i)
			var is_hover: bool = rect_screen.has_point(hover_screen)
			var rect: Rect2 = _screen_rect_to_world(rect_screen)
			var base_color: Color = Color(0.12, 0.18, 0.26, 0.85)
			var text_color: Color = Color(0.9, 0.95, 1.0, 0.95)
			if is_hover:
				base_color = Color(0.2, 0.28, 0.38, 0.92)
				text_color = Color(1.0, 1.0, 1.0, 1.0)
			draw_rect(rect, base_color, true)
			draw_rect(rect, Color(0.9, 0.95, 1.0, 0.72), false, 2.0)
			draw_string(card_font, rect.position + Vector2(14.0, 30.0), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 20, text_color)
			var y: float = 56.0
			for line: String in desc_lines:
				draw_string(card_font, rect.position + Vector2(14.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24.0, 16, Color(text_color.r, text_color.g, text_color.b, 0.9))
				y += 19.0
