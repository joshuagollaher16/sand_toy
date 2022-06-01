extends Node2D


@onready var children = get_parent().get_children()

var currently_hovering: bool = false

func on_mouse_entered():
	currently_hovering = true

func on_mouse_exited():
	currently_hovering = false

func _ready():
	
	for child in children:
		child.connect("mouse_entered", on_mouse_entered)
		child.connect("mouse_exited", on_mouse_exited)
	

	


