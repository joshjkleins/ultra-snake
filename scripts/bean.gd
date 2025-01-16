extends Node2D

func _on_area_2d_area_entered(_area):
	destroyBean()

func destroyBean():
	var main = get_parent().get_parent()
	main.beanPickedUp(position)
	queue_free()
