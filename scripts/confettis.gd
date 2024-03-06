class_name Confettis extends GPUParticles2D

static func spawn_at(p_position: Vector2, p_parent: Node) -> Confettis:
	var instance: Confettis = load("res://scenes/confettis.tscn").instantiate()
	p_parent.add_child(instance)
	instance.position += p_position
	instance.emitting = true
	return instance

func _on_finished():
	queue_free()
