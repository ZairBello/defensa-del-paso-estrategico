extends CharacterBody2D

@export var bulletDamage: int = 5
@export var pathName: String = ""

var speed := 600
var target: Node = null


func _ready():
	set_process(true)


func _physics_process(_delta):
	if target == null or not is_instance_valid(target):
		queue_free()
		return

	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	look_at(target.global_position)



func set_target(target_node: Node):
	target = target_node


func _on_area_2d_body_entered(body):
	if "Soldier" in body.name:
		if body.has_method("take_damage"):
			body.take_damage(bulletDamage)
		else:
			body.health -= bulletDamage
			if body.health <= 0:
				body.queue_free()
		queue_free()
