extends Node2D
 
@export var path = preload("res://Scenes/stage 1.tscn")

func _on_timer_timeout() -> void:
	var tempoPath = path.instantiate()
	add_child(tempoPath)
