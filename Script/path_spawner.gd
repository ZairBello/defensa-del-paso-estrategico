extends Node2D

@export var time_between_enemies: float = 1.0     # Tiempo entre enemigos
@export var time_between_waves: float = 2.0       # Tiempo entre oleadas
@export var total_waves: int = 3                  # Número total de oleadas
@onready var path: Path2D = $PathA

# Lista de grupos de enemigos (puede exportarse o definirse en _ready si es fija)
var enemy_groups: Array = []

var current_wave := 0
var current_group_index := 0
var enemies_spawned_in_group := 0
var spawning_wave := false

@onready var spawn_timer := Timer.new()
@onready var wave_timer := Timer.new()

func _ready():
	# Definís los grupos aquí (o podés hacerlos exportables también)
	enemy_groups = [
		{ "scene": preload("res://Scenes/Soldier A.tscn"), "amount": 10 },
		{ "scene": preload("res://Scenes/soldier_b.tscn"), "amount": 5 },
		{ "scene": preload("res://Scenes/soldier_c.tscn"),    "amount": 4 },
		{ "scene": preload("res://Scenes/soldier_e.tscn"),    "amount": 6 },
		{ "scene": preload("res://Scenes/soldier_f.tscn"),    "amount": 3 }
	]

	# Configurar timers
	spawn_timer.wait_time = time_between_enemies
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	wave_timer.wait_time = time_between_waves
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_start_wave)
	add_child(wave_timer)

	# Iniciar la primera oleada
	_start_wave()

func _start_wave():
	if current_wave >= total_waves:
		print("Todas las oleadas completadas.")
		return

	print("Iniciando oleada ", current_wave + 1)
	current_wave += 1
	current_group_index = 0
	enemies_spawned_in_group = 0
	spawning_wave = true
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if current_group_index >= enemy_groups.size():
		# Todos los grupos ya fueron spawneados
		spawn_timer.stop()
		spawning_wave = false

		if current_wave < total_waves:
			print("Oleada terminada. Esperando siguiente oleada.")
			wave_timer.start()
		else:
			print("Última oleada completada.")
		return

	_spawn_enemy()

func _spawn_enemy():
	var group = enemy_groups[current_group_index]
	var enemy_scene: PackedScene = group["scene"]
	var amount: int = group["amount"]

	if enemies_spawned_in_group < amount:
		var enemy = enemy_scene.instantiate()

		var path_follow := PathFollow2D.new()
		path_follow.progress = 0
		path_follow.add_child(enemy)
		path.add_child(path_follow)

		enemies_spawned_in_group += 1
		print("Enemigo del grupo ", current_group_index, " generado.")
	else:
		current_group_index += 1
		enemies_spawned_in_group = 0
