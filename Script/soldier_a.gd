extends CharacterBody2D

@export var speed = 100
@export var health = 10 

func _process(_delta): 
	get_parent().set_progress(get_parent().get_progress() + speed * _delta)
	if get_parent().get_progress_ratio() == 1:
		queue_free()

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
