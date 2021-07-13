tool
extends Node2D

export var do_distribution := false setget _set_do_distribution


onready var _mesh_instance = $icon
onready var _multi_mesh_instance = $MultiMeshInstance2D


#func _ready():
#	_do_distribution()


func _do_distribution():
	var multi_mesh = _multi_mesh_instance.multimesh
	multi_mesh.mesh = _mesh_instance.mesh
	var screen_size = get_viewport_rect().size
	for i in multi_mesh.instance_count:
		var v = Vector2( randf() * screen_size.x, randf() * screen_size.y )
		var t = Transform2D( 0.0, v)
		multi_mesh.set_instance_transform_2d(i, t)


func _set_do_distribution(value):
	if value:
		_do_distribution()
