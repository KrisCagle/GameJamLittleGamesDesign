extends Node2D

const HeroScript = preload("res://scripts/Hero.gd")
const EnemyScript = preload("res://scripts/Enemy.gd")
const ProjectileScript = preload("res://scripts/Projectile.gd")

const HERO_KNIGHT := 0
const HERO_MAGE := 1
const HERO_ROGUE := 2

const ENEMY_SWARM := 0
const ENEMY_RANGED := 1
const ENEMY_CHARGER := 2
const PROJECTILE_TEAM_HERO := 0
const PROJECTILE_TEAM_ENEMY := 1

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

var halo_index := 0

var wave := 0
var elapsed_time := 0.0

var spawn_remaining := 0
var spawn_timer := 0.0
var spawning := false
var waiting_for_next_wave := false
var intermission_timer := 0.0

var game_over := false
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

func _ready() -> void:
	randomize()
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
	projectile_spawns.clear()

	for hero: Hero in heroes:
		hero.process_visual_tick(delta)
		hero.process_tick(delta, enemies, heroes, arena_rect, projectile_spawns)
	_apply_halo_synergies(delta)
	for enemy: Enemy in enemies:
		enemy.process_tick(delta, heroes, arena_rect, projectile_spawns)
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
		match event.keycode:
			KEY_1:
				_set_halo(0)
			KEY_2:
				_set_halo(1)
			KEY_3:
				_set_halo(2)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not game_over:
		_set_halo_from_point(event.position)

func _spawn_heroes() -> void:
	heroes.clear()

	var knight: Hero = HeroScript.new()
	knight.configure(HERO_KNIGHT, Vector2(VIEW_SIZE.x * 0.5, VIEW_SIZE.y * 0.54))
	heroes_root.add_child(knight)
	heroes.append(knight)

	var mage: Hero = HeroScript.new()
	mage.configure(HERO_MAGE, Vector2(VIEW_SIZE.x * 0.33, VIEW_SIZE.y * 0.68))
	heroes_root.add_child(mage)
	heroes.append(mage)

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
	halo_switch_cooldown_timer = HALO_SWITCH_COOLDOWN
	halo_switch_heat = minf(HALO_SWITCH_HEAT_MAX, halo_switch_heat + HALO_SWITCH_HEAT_PER_SWAP)
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
	spawn_remaining = 5 + (wave * 2) + int(floor(float(wave) / 2.0))
	spawn_timer = 0.2
	spawning = true
	waiting_for_next_wave = false
	intermission_timer = 0.0

func _update_spawning(delta: float) -> void:
	if not spawning:
		return

	spawn_timer -= delta
	var interval := maxf(0.78 - float(wave) * 0.045, 0.2)

	while spawn_remaining > 0 and spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_remaining -= 1
		spawn_timer += interval

	if spawn_remaining <= 0:
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
			var pressure := clampf((halo_heat - 42.0) / (LAST_STAND_HEAT_MAX - 42.0), 0.0, 1.0)
			var chance := 0.08 + pressure * 0.67
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

func _apply_halo_synergies(delta: float) -> void:
	for hero: Hero in heroes:
		if hero.kind == HERO_KNIGHT and hero.has_halo:
			for enemy: Enemy in enemies:
				if enemy.health <= 0.0:
					continue
				if hero.global_position.distance_to(enemy.global_position) <= 240.0:
					enemy.target_hero = hero
		if not hero.consume_knight_pull_pulse(delta):
			continue
		for enemy: Enemy in enemies:
			if enemy.health <= 0.0:
				continue
			if hero.global_position.distance_to(enemy.global_position) <= 220.0:
				enemy.apply_pull_towards(hero.global_position, 48.0)

func _spawn_enemy() -> void:
	var enemy: Enemy = EnemyScript.new()
	var kind := _pick_enemy_kind()
	var target := _pick_spawn_target(kind)
	enemy.configure(kind, _random_spawn_point(), target)
	enemies_root.add_child(enemy)
	enemies.append(enemy)

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
			preferred_kind = HERO_MAGE
		ENEMY_CHARGER:
			preferred_kind = HERO_ROGUE

	var preferred := _find_alive_hero_by_kind(alive, preferred_kind)
	if preferred != null and randf() < 0.72:
		return preferred

	var best: Hero = alive[0]
	var best_score := INF

	for hero: Hero in alive:
		var load := 0
		for enemy: Enemy in enemies:
			if enemy.health > 0.0 and enemy.target_hero == hero:
				load += 1
		var score := float(load) + randf() * 0.45
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

func _progress_wave_timing(delta: float) -> void:
	if spawning or game_over:
		return

	if enemies.is_empty() and not waiting_for_next_wave:
		waiting_for_next_wave = true
		intermission_timer = 2.2

	if waiting_for_next_wave:
		intermission_timer -= delta
		if intermission_timer <= 0.0:
			_start_wave()

func _update_ui() -> void:
	wave_label.text = "Wave %d  |  Time %.1fs" % [wave, elapsed_time]

	var swarm_count := 0
	var ranged_count := 0
	var charger_count := 0
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

	threat_label.text = "Enemies %d  |  Swarm %d  Ranged %d  Charger %d  |  Shots %d" % [enemies.size(), swarm_count, ranged_count, charger_count, projectiles.size()]
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
		var halo_tag := ""
		if i == halo_index:
			if hero.has_halo:
				halo_tag = "(HALO)"
			elif last_stand_active and halo_overloaded:
				halo_tag = "(OVERLOAD)"
			elif last_stand_active and last_stand_manual_drop:
				halo_tag = "(VENTING)"
			elif last_stand_active and halo_flicker_off_timer > 0.0:
				halo_tag = "(FLICKER)"
		var hp_text := "DOWN" if hero.health <= 0.0 else "%d/%d" % [int(round(hero.health)), int(hero.max_health)]
		lines.append("[%d] %s  %s %s" % [i + 1, hero.hero_name, hp_text, halo_tag])
	hero_status.text = "\n".join(lines)

	if game_over:
		hint_label.text = "All heroes are down. Press R or Enter to restart."
	elif halo_switch_overheat_timer > 0.0 and not last_stand_active:
		hint_label.text = "Halo overheat lockout. Hold position while switch recovers."
	elif halo_switch_cooldown_timer > 0.0 and not last_stand_active:
		hint_label.text = "Halo transfer cooling down. Chain decisions slightly ahead of danger."
	elif last_stand_active and halo_overloaded:
		hint_label.text = "Last Stand: Halo overloaded. Survive %.1fs with no invincibility." % [halo_overload_timer]
	elif last_stand_active:
		hint_label.text = "Last Stand: Halo is unstable. Press current hero key/click to vent and cool heat."
	elif waiting_for_next_wave:
		hint_label.text = "Wave clear. Next wave in %.1f seconds." % [maxf(intermission_timer, 0.0)]
	else:
		hint_label.text = "Switch Halo instantly with 1/2/3 or click a hero. You cannot save everyone perfectly."

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
