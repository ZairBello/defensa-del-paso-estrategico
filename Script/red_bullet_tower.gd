extends StaticBody2D

# --- CONFIGURACIÓN ---
var BulletScene = preload("res://Scenes/red_bullet.tscn")
var bulletDamage := 5
var rotationSpeed := 5.0  # Velocidad de rotación de la torreta
var shootCooldown := 1.0  # Tiempo entre disparos
var shootDelay := 0.1     # Retardo tras girar antes de disparar

# --- ESTADO INTERNO ---
var canShoot := true
var currentTarget: Node2D = null
var pendingTarget: Node2D = null


func _ready():
	_init_shoot_timer()
	_init_delay_timer()


func _process(delta):
	_rotate_towards_target(delta)


# --- INICIALIZACIÓN DE TIMERS ---
func _init_shoot_timer():
	var timer = Timer.new()
	timer.name = "ShootTimer"
	timer.wait_time = shootCooldown
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_shoot_timer_timeout"))
	add_child(timer)

func _init_delay_timer():
	var timer = Timer.new()
	timer.name = "DelayTimer"
	timer.wait_time = shootDelay
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_delay_timer_timeout"))
	add_child(timer)


# --- ROTACIÓN SUAVIZADA HACIA EL OBJETIVO ---
func _rotate_towards_target(delta):
	if is_instance_valid(currentTarget):
		var angle_to_target = (currentTarget.global_position - global_position).angle()
		rotation = lerp_angle(rotation, angle_to_target, delta * rotationSpeed)


# --- DETECCIÓN DE SOLDADOS EN RANGO ---
func _on_tower_body_entered(body):
	if "Soldier A" in body.name and canShoot:
		var targets = _get_valid_soldier_targets()
		var strongest = _get_strongest_target(targets)

		if strongest:
			currentTarget = strongest
			canShoot = false
			pendingTarget = strongest
			$ShootTimer.start()
			$DelayTimer.start()


func _get_valid_soldier_targets():
	var overlapping = get_node("Tower").get_overlapping_bodies()
	return overlapping.filter(func(target): return "Soldier" in target.name)


func _get_strongest_target(targets):
	var best = null
	for t in targets:
		var progress = t.get_parent().get_progress()
		if best == null or progress > best.get_parent().get_progress():
			best = t
	return best


# --- DISPARO DEL PROYECTIL ---
func _on_delay_timer_timeout():
	if pendingTarget and is_instance_valid(pendingTarget):
		var bullet = BulletScene.instantiate()
		bullet.global_position = $TowerDefenseTile250/Ain.global_position
		bullet.bulletDamage = bulletDamage
		bullet.set_target(pendingTarget)
		get_node("BulletContainer").call_deferred("add_child", bullet)
	pendingTarget = null


# --- CONTROL DE COOLDOWN ---
func _on_shoot_timer_timeout():
	canShoot = true


# --- ACTUALIZACIÓN DE OBJETIVOS AL SALIR ---
func _on_tower_body_exited(_body):
	# Recolecta posibles nuevos objetivos
	currentTarget = null
