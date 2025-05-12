extends Panel

@onready var tower_scene = preload("res://Scenes/AnotherTower.tscn")
var dragging_tower: Node2D = null

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Crear la torre y posicionarla donde el jugador hace clic (en el mundo 2D)
			dragging_tower = tower_scene.instantiate()
			get_tree().get_root().add_child(dragging_tower)
			dragging_tower.process_mode = Node.PROCESS_MODE_DISABLED
			dragging_tower.global_position = get_viewport().get_camera_2d().get_global_mouse_position()

		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and dragging_tower:
			var towers_container = get_tree().get_root().get_node("Main/Towers")
			var area = dragging_tower.get_node_or_null("Area")
			if area:
				area.hide()
			dragging_tower.process_mode = Node.PROCESS_MODE_INHERIT
			dragging_tower.reparent(towers_container)
			dragging_tower = null

	elif event is InputEventMouseMotion and dragging_tower:
		dragging_tower.global_position = get_viewport().get_camera_2d().get_global_mouse_position()
