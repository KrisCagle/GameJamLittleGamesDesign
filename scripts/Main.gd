extends Node2D

const HeroScript = preload("res://scripts/Hero.gd")
const EnemyScript = preload("res://scripts/Enemy.gd")
const ProjectileScript = preload("res://scripts/Projectile.gd")

const HERO_KNIGHT := 0
const HERO_RANGER := 1
const HERO_ROGUE := 2

const ENEMY_SWARM := 0
const ENEMY_RANGED := 1
const ENEMY_CHARGER := 2
const ENEMY_BOSS := 3

const PROJECTILE_TEAM_HERO := 0

const UPGRADE_HALO_FLOW := 0
const UPGRADE_RANGER_REMEDY := 1
const UPGRADE_ROGUE_OVERDRIVE := 2
const UPGRADE_TANK_BASTION := 3
const UPGRADE_FIELD_PATCH := 4

const VIEW_SIZE := Vector2(1280, 720)
const ARENA_MARGIN := 44.0
const LAST_STAND_HEAT_MAX := 100.0
const LAST_STAND_HEAT_RATE := 36.0
const LAST_STAND_COOL_RATE := 28.0
const LAST_STAND_OVERLOAD_DURATION := 2.0
const LAST_STAND_FLICKER_CHECK_PERIOD := 0.12
const HALO_SWITCH_COOLDOWN := 0.22
const HALO_SWITCH_HEAT_MAX := 100.0
const HALO_SWITCH_HEAT_PER_SWAP := 34.0
const HALO_SWITCH_HEAT_COOL_RATE := 22.0
const HALO_SWITCH_OVERHEAT_LOCK := 1.2
const HALO_SWITCH_FEEDBACK_DURATION := 0.24

@onready var heroes_root: Node2D = $Heroes
@onready var enemies_root: Node2D = $Enemies
@onready var projectiles_root: Node2D = $Projectiles
@onready var wave_label: Label = $UI/WaveLabel
@onready var threat_label: Label = $UI/ThreatLabel
@onready var hero_status: Label = $UI/HeroStatus
@onready var hint_label: Label = $UI/HintLabel

var arena_rect := Rect2(Vector2(ARENA_MARGIN, ARENA_MARGIN), VIEW_SIZE - Vector2(ARENA_MARGIN * 2.0, ARENA_MARGIN * 2.0))

var heroes: Array[Hero] = []
var enemies: Array[Enemy] = []
var projectiles: Array = []
var projectile_spawns: Array[Dictionary] = []
var summon_spawns: Array[Dictionary] = []

var halo_index := 0

var wave := 0
var elapsed_time := 0.0
var upgrades_taken := 0

var spawn_remaining := 0
var spawn_timer := 0.0
var spawning := false
var boss_spawn_pending := false
var waiting_for_next_wave := false
var intermission_timer := 0.0

var game_over := false
var upgrade_phase_active := false
var upgrade_choices: Array[int] = []
var upgrade_levels: Dictionary = {}

var last_stand_active := false
var last_stand_manual_drop := false
var halo_heat := 0.0
var halo_overloaded := false
var halo_overload_timer := 0.0
var halo_flicker_off_timer := 0.0
var halo_flicker_check_timer := 0.0
var halo_switch_cooldown_timer := 0.0
var halo_switch_heat := 0.0
var halo_switch_overheat_timer := 0.0
var halo_switch_feedback_timer := 0.0
var halo_switch_feedback_from := Vector2.ZERO
var halo_switch_feedback_to := Vector2.ZERO

var halo_switch_cooldown_value := HALO_SWITCH_COOLDOWN
var halo_switch_heat_per_swap_value := HALO_SWITCH_HEAT_PER_SWAP

var ranger_halo_heal_amount := 14.0
var ranger_halo_heal_radius := 250.0
var knight_taunt_radius := 240.0
var knight_pull_radius := 220.0
var knight_guard_heal_per_sec := 4.0

func _ready() -> void:
	randomize()
	upgrade_levels[UPGRADE_HALO_FLOW] = 0
	upgrade_levels[UPGRADE_RANGER_REMEDY] = 0
	upgrade_levels[UPGRADE_ROGUE_OVERDRIVE] = 0
	upgrade_levels[UPGRADE_TANK_BASTION] = 0
	upgrade_levels[UPGRADE_FIELD_PATCH] = 0

	_spawn_heroes()
	_set_halo(0)
	halo_switch_heat = 0.0
	halo_switch_cooldown_timer = 0.0
	halo_switch_overheat_timer = 0.0
	halo_switch_feedback_timer = 0.0
	_start_wave()
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	if game_over:
		_update_ui()
		return

	elapsed_time += delta
	_update_spawning(delta)
	_update_halo_switch_system(delta)
	_update_last_stand(delta)

	if upgrade_phase_active:
		_update_ui()
		queue_redraw()
		return

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
	_update_ui()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if game_over and (event.keycode == KEY_ENTER or event.keycode == KEY_R):
			get_tree().reload_current_scene()
			return

		if upgrade_phase_active:
			match event.keycode:
				KEY_Q, KEY_1:
					_choose_upgrade(0)
				KEY_W, KEY_2:
					_choose_upgrade(1)
				KEY_E, KEY_3:
					_choose_upgrade(2)
			return

		match event.keycode:
			KEY_1:
				_set_halo(0)
			KEY_2:
				_set_halo(1)
			KEY_3:
				_set_halo(2)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not game_over and not upgrade_phase_active:
		_set_halo_from_point(event.position)

func _spawn_heroes() -> void:
	heroes.clear()

	var knight: Hero = HeroScript.new()
	knight.configure(HERO_KNIGHT, Vector2(VIEW_SIZE.x * 0.5, VIEW_SIZE.y * 0.54))
	heroes_root.add_child(knight)
	heroes.append(knight)

	var ranger: Hero = HeroScript.new()
	ranger.configure(HERO_RANGER, Vector2(VIEW_SIZE.x * 0.33, VIEW_SIZE.y * 0.68))
	heroes_root.add_child(ranger)
	heroes.append(ranger)

	var rogue: Hero = HeroScript.new()
	rogue.configure(HERO_ROGUE, Vector2(VIEW_SIZE.x * 0.67, VIEW_SIZE.y * 0.68))
	heroes_root.add_child(rogue)
	heroes.append(rogue)

func _set_halo(index: int) -> void:
	if index < 0 or index >= heroes.size():
		return
	if heroes[index].health <= 0.0:
		return

	if index == halo_index and not last_stand_active:
		if halo_index >= 0 and halo_index < heroes.size() and heroes[halo_index].has_halo:
			return

	if last_stand_active and index == halo_index and not halo_overloaded:
		last_stand_manual_drop = not last_stand_manual_drop
		halo_switch_feedback_from = heroes[index].global_position
		halo_switch_feedback_to = heroes[index].global_position
		halo_switch_feedback_timer = HALO_SWITCH_FEEDBACK_DURATION * 0.7
		heroes[index].trigger_halo_switch_feedback()
		_sync_halo_state()
		return

	if _is_halo_switch_locked():
		return

	var previous_index := halo_index
	halo_index = index
	last_stand_manual_drop = false
	halo_switch_cooldown_timer = halo_switch_cooldown_value
	halo_switch_heat = minf(HALO_SWITCH_HEAT_MAX, halo_switch_heat + halo_switch_heat_per_swap_value)
	if halo_switch_heat >= HALO_SWITCH_HEAT_MAX:
		halo_switch_overheat_timer = HALO_SWITCH_OVERHEAT_LOCK
	_sync_halo_state()
	_on_halo_switched(previous_index, halo_index)

func _set_halo_from_point(point: Vector2) -> void:
	var closest_index := -1
	var best_dist := INF

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
		spawn_remaining = 5 + (wave * 2) + int(floor(float(wave) / 2.0))
	spawn_timer = 0.22
	spawning = true
	waiting_for_next_wave = false
	upgrade_phase_active = false
	intermission_timer = 0.0
	_sync_halo_state()

func _update_spawning(delta: float) -> void:
	if not spawning:
		return

	spawn_timer -= delta
	var interval := maxf(0.78 - float(wave) * 0.045, 0.2)
	while spawn_timer <= 0.0 and (spawn_remaining > 0 or boss_spawn_pending):
		if boss_spawn_pending:
			_spawn_boss()
			boss_spawn_pending = false
			spawn_timer += interval * 1.5
		elif spawn_remaining > 0:
			_spawn_enemy()
			spawn_remaining -= 1
			spawn_timer += interval

	if spawn_remaining <= 0 and not boss_spawn_pending:
		spawning = false

func _update_halo_switch_system(delta: float) -> void:
	halo_switch_cooldown_timer = maxf(0.0, halo_switch_cooldown_timer - delta)
	halo_switch_feedback_timer = maxf(0.0, halo_switch_feedback_timer - delta)

	if halo_switch_overheat_timer > 0.0:
		halo_switch_overheat_timer = maxf(0.0, halo_switch_overheat_timer - delta)
		halo_switch_heat = maxf(0.0, halo_switch_heat - HALO_SWITCH_HEAT_COOL_RATE * 1.45 * delta)
	else:
		halo_switch_heat = maxf(0.0, halo_switch_heat - HALO_SWITCH_HEAT_COOL_RATE * delta)

func _is_halo_switch_locked() -> bool:
	return halo_switch_cooldown_timer > 0.0 or halo_switch_overheat_timer > 0.0

func _on_halo_switched(previous_index: int, new_index: int) -> void:
	if new_index < 0 or new_index >= heroes.size():
		return

	var from_pos := heroes[new_index].global_position
	if previous_index >= 0 and previous_index < heroes.size():
		from_pos = heroes[previous_index].global_position

	halo_switch_feedback_from = from_pos
	halo_switch_feedback_to = heroes[new_index].global_position
	halo_switch_feedback_timer = HALO_SWITCH_FEEDBACK_DURATION
	heroes[new_index].trigger_halo_switch_feedback()

func _update_last_stand(delta: float) -> void:
	var alive_count := _alive_hero_count()
	if alive_count == 1 and not game_over:
		if not last_stand_active:
			last_stand_active = true
			last_stand_manual_drop = false
			halo_heat = 18.0
			halo_overloaded = false
			halo_overload_timer = 0.0
			halo_flicker_off_timer = 0.0
			halo_flicker_check_timer = 0.0
	else:
		last_stand_active = false
		last_stand_manual_drop = false
		halo_heat = 0.0
		halo_overloaded = false
		halo_overload_timer = 0.0
		halo_flicker_off_timer = 0.0
		halo_flicker_check_timer = 0.0
		_sync_halo_state()
		return

	halo_flicker_off_timer = maxf(0.0, halo_flicker_off_timer - delta)
	if halo_overloaded:
		halo_overload_timer = maxf(0.0, halo_overload_timer - delta)
		halo_heat = maxf(0.0, halo_heat - LAST_STAND_COOL_RATE * 1.9 * delta)
		if halo_overload_timer <= 0.0 and halo_heat <= 35.0:
			halo_overloaded = false
	else:
		if _is_halo_projection_available():
			halo_heat = minf(LAST_STAND_HEAT_MAX, halo_heat + LAST_STAND_HEAT_RATE * delta)
		else:
			halo_heat = maxf(0.0, halo_heat - LAST_STAND_COOL_RATE * delta)

		halo_flicker_check_timer = maxf(0.0, halo_flicker_check_timer - delta)
		if halo_flicker_off_timer <= 0.0 and halo_flicker_check_timer <= 0.0 and halo_heat >= 42.0:
			halo_flicker_check_timer = LAST_STAND_FLICKER_CHECK_PERIOD
			var pressure: float = clampf((halo_heat - 42.0) / (LAST_STAND_HEAT_MAX - 42.0), 0.0, 1.0)
			var chance: float = 0.08 + pressure * 0.67
			if randf() < chance:
				halo_flicker_off_timer = randf_range(0.05, 0.12 + pressure * 0.18)

		if halo_heat >= LAST_STAND_HEAT_MAX:
			halo_overloaded = true
			halo_overload_timer = LAST_STAND_OVERLOAD_DURATION
			halo_flicker_off_timer = 0.0
			halo_flicker_check_timer = 0.0

	_sync_halo_state()

func _is_halo_projection_available() -> bool:
	if halo_index < 0 or halo_index >= heroes.size():
		return false
	var selected: Hero = heroes[halo_index]
	if selected.health <= 0.0:
		return false
	if not last_stand_active:
		return true
	if last_stand_manual_drop:
		return false
	if halo_overloaded:
		return false
	if halo_flicker_off_timer > 0.0:
		return false
	return true

func _sync_halo_state() -> void:
	var can_project := _is_halo_projection_available()
	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		var active := can_project and i == halo_index and hero.health > 0.0
		hero.set_halo(active)
		hero.set_player_controlled(active and not upgrade_phase_active and not game_over)

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
			_apply_ranger_halo_support(hero)

func _apply_ranger_halo_support(ranger: Hero) -> void:
	var best_target: Hero = null
	var lowest_ratio := INF

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
	var kind := _pick_enemy_kind()
	var target := _pick_spawn_target(kind)
	enemy.configure(kind, _random_spawn_point(), target, wave)
	enemies_root.add_child(enemy)
	enemies.append(enemy)

func _spawn_boss() -> void:
	var enemy: Enemy = EnemyScript.new()
	var target := _pick_spawn_target(ENEMY_BOSS)
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
	var charger_chance := minf(0.08 + float(wave) * 0.02, 0.28)
	var ranged_chance := minf(0.2 + float(wave) * 0.03, 0.45)
	var roll := randf()
	if roll < charger_chance:
		return ENEMY_CHARGER
	if roll < charger_chance + ranged_chance:
		return ENEMY_RANGED
	return ENEMY_SWARM

func _pick_spawn_target(enemy_kind: int) -> Hero:
	var alive: Array[Hero] = []
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive.append(hero)

	if alive.is_empty():
		return null

	var preferred_kind := HERO_KNIGHT
	match enemy_kind:
		ENEMY_SWARM:
			preferred_kind = HERO_KNIGHT
		ENEMY_RANGED:
			preferred_kind = HERO_RANGER
		ENEMY_CHARGER:
			preferred_kind = HERO_ROGUE
		ENEMY_BOSS:
			preferred_kind = HERO_KNIGHT

	var preferred: Hero = _find_alive_hero_by_kind(alive, preferred_kind)
	if preferred != null and randf() < 0.72:
		return preferred

	var best: Hero = alive[0]
	var best_score := INF
	for hero: Hero in alive:
		var load := 0
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
	var edge := randi() % 4
	var x := randf_range(arena_rect.position.x, arena_rect.end.x)
	var y := randf_range(arena_rect.position.y, arena_rect.end.y)
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
		var projectile = ProjectileScript.new()
		projectile.configure_from_data(data)
		projectiles_root.add_child(projectile)
		projectiles.append(projectile)
	projectile_spawns.clear()

func _update_projectiles(delta: float) -> void:
	if projectiles.is_empty():
		return

	var extended_arena := arena_rect.grow(48.0)
	for i in range(projectiles.size() - 1, -1, -1):
		var projectile = projectiles[i]
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
			var previous_index := halo_index
			halo_index = i
			last_stand_manual_drop = false
			_sync_halo_state()
			if previous_index != halo_index:
				_on_halo_switched(previous_index, halo_index)
			return

	halo_index = -1
	_sync_halo_state()

func _check_for_game_over() -> void:
	var alive_count := 0
	for hero: Hero in heroes:
		if hero.health > 0.0:
			alive_count += 1
	if alive_count <= 0:
		game_over = true
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

	var result: Array[int] = []
	while result.size() < 3 and not pool.is_empty():
		var idx: int = randi() % pool.size()
		result.append(pool[idx])
		pool.remove_at(idx)
	return result

func _choose_upgrade(slot: int) -> void:
	if not upgrade_phase_active:
		return
	if slot < 0 or slot >= upgrade_choices.size():
		return

	var upgrade_id: int = upgrade_choices[slot]
	_apply_upgrade(upgrade_id)
	upgrade_phase_active = false
	upgrade_choices.clear()
	intermission_timer = 1.2
	_sync_halo_state()

func _apply_upgrade(upgrade_id: int) -> void:
	match upgrade_id:
		UPGRADE_HALO_FLOW:
			halo_switch_cooldown_value = maxf(0.08, halo_switch_cooldown_value * 0.84)
			halo_switch_heat_per_swap_value = maxf(14.0, halo_switch_heat_per_swap_value * 0.9)
		UPGRADE_RANGER_REMEDY:
			ranger_halo_heal_amount += 6.0
			ranger_halo_heal_radius += 18.0
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
	return "Unknown"

func _upgrade_description(upgrade_id: int) -> String:
	match upgrade_id:
		UPGRADE_HALO_FLOW:
			return "Faster halo switching and less overheat per transfer."
		UPGRADE_RANGER_REMEDY:
			return "Ranger halo pulse heals more and reaches farther."
		UPGRADE_ROGUE_OVERDRIVE:
			return "Rogue gets stronger and faster while haloed."
		UPGRADE_TANK_BASTION:
			return "Tank taunt/pull radius up, better nearby ally sustain."
		UPGRADE_FIELD_PATCH:
			return "Immediate team heal and max HP increase."
	return ""

func _update_ui() -> void:
	wave_label.text = "Wave %d  |  Time %.1fs  |  Upgrades %d" % [wave, elapsed_time, upgrades_taken]

	var swarm_count := 0
	var ranged_count := 0
	var charger_count := 0
	var boss_count := 0
	for enemy: Enemy in enemies:
		if enemy.health <= 0.0:
			continue
		match enemy.kind:
			ENEMY_SWARM:
				swarm_count += 1
			ENEMY_RANGED:
				ranged_count += 1
			ENEMY_CHARGER:
				charger_count += 1
			ENEMY_BOSS:
				boss_count += 1

	threat_label.text = "Enemies %d  |  Swarm %d  Ranged %d  Charger %d  Boss %d  |  Shots %d" % [enemies.size(), swarm_count, ranged_count, charger_count, boss_count, projectiles.size()]
	threat_label.text += "  |  Switch Heat %.0f%%" % [halo_switch_heat]
	if halo_switch_overheat_timer > 0.0:
		threat_label.text += "  |  OVERHEAT %.1fs" % [halo_switch_overheat_timer]
	elif halo_switch_cooldown_timer > 0.0:
		threat_label.text += "  |  Cooldown %.2fs" % [halo_switch_cooldown_timer]
	if last_stand_active:
		var stand_state := "OVERLOAD" if halo_overloaded else "UNSTABLE"
		threat_label.text += "  |  Last Stand %s %.0f%%" % [stand_state, halo_heat]

	var lines: Array[String] = []
	for i in range(heroes.size()):
		var hero: Hero = heroes[i]
		var tags: Array[String] = []
		if i == halo_index:
			if hero.has_halo:
				tags.append("HALO")
			elif last_stand_active and halo_overloaded:
				tags.append("OVERLOAD")
			elif last_stand_active and last_stand_manual_drop:
				tags.append("VENTING")
			elif last_stand_active and halo_flicker_off_timer > 0.0:
				tags.append("FLICKER")
		if hero.is_player_controlled:
			tags.append("CTRL")
		var hp_text := "DOWN" if hero.health <= 0.0 else "%d/%d" % [int(round(hero.health)), int(round(hero.max_health))]
		var tag_text := ""
		if not tags.is_empty():
			tag_text = "(%s)" % ["/".join(tags)]
		lines.append("[%d] %s  %s %s" % [i + 1, hero.hero_name, hp_text, tag_text])

	if upgrade_phase_active:
		lines.append("")
		lines.append("Choose One Upgrade:")
		for i in range(upgrade_choices.size()):
			var upgrade_id: int = upgrade_choices[i]
			lines.append("[%d] %s - %s" % [i + 1, _upgrade_name(upgrade_id), _upgrade_description(upgrade_id)])
		lines.append("Keys: Q/W/E or 1/2/3")

	hero_status.text = "\n".join(lines)

	if game_over:
		hint_label.text = "All heroes are down. Press R or Enter to restart."
	elif upgrade_phase_active:
		hint_label.text = "Between waves: pick an upgrade to shape your next halo decision."
	elif halo_switch_overheat_timer > 0.0 and not last_stand_active:
		hint_label.text = "Halo overheat lockout. Hold position while switch recovers."
	elif halo_switch_cooldown_timer > 0.0 and not last_stand_active:
		hint_label.text = "Halo transfer cooling down. Plan one step ahead."
	elif last_stand_active and halo_overloaded:
		hint_label.text = "Last Stand: Halo overloaded. Survive %.1fs with no invincibility." % [halo_overload_timer]
	elif last_stand_active:
		hint_label.text = "Last Stand: Halo unstable. Press current hero key/click to vent heat."
	elif waiting_for_next_wave:
		hint_label.text = "Wave clear. Next wave in %.1f seconds." % [maxf(intermission_timer, 0.0)]
	else:
		hint_label.text = "WASD/Arrows move HALO hero. Switch with 1/2/3 or click. Choose who handles the current crisis."

func _get_player_move_input() -> Vector2:
	var x := 0.0
	var y := 0.0

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		y += 1.0

	var input_vec := Vector2(x, y)
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	return input_vec

func _alive_hero_count() -> int:
	var count := 0
	for hero: Hero in heroes:
		if hero.health > 0.0:
			count += 1
	return count

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.05, 0.07, 0.1), true)
	draw_rect(arena_rect, Color(0.09, 0.13, 0.18), true)
	draw_rect(arena_rect, Color(0.42, 0.86, 1.0, 0.9), false, 3.0)

	var right := arena_rect.position.x + arena_rect.size.x
	var bottom := arena_rect.position.y + arena_rect.size.y
	for x in range(int(arena_rect.position.x) + 64, int(right), 64):
		draw_line(Vector2(x, arena_rect.position.y), Vector2(x, bottom), Color(1, 1, 1, 0.04), 1.0)
	for y in range(int(arena_rect.position.y) + 64, int(bottom), 64):
		draw_line(Vector2(arena_rect.position.x, y), Vector2(right, y), Color(1, 1, 1, 0.04), 1.0)

	if halo_switch_feedback_timer > 0.0:
		var t := halo_switch_feedback_timer / HALO_SWITCH_FEEDBACK_DURATION
		var pulse_color := Color(1.0, 0.96, 0.58, 0.8 * t)
		draw_line(halo_switch_feedback_from, halo_switch_feedback_to, pulse_color, 6.0 * t)
		draw_circle(halo_switch_feedback_to, 12.0 + (1.0 - t) * 16.0, Color(1.0, 0.96, 0.58, 0.25 * t))

	if upgrade_phase_active:
		draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color(0.02, 0.04, 0.08, 0.28), true)
