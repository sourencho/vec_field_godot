@tool
extends Node2D

@export var do_distribution := false: set = _set_do_distribution
@export var distribute_on_ready := false

@export var noise : FastNoiseLite

@onready var _mesh_instance = $icon
@onready var _multi_mesh_instance = $MultiMeshInstance2D

func _ready():
	if distribute_on_ready:
		randomize()
		_do_distribution()


func _do_distribution():
	var multi_mesh = _multi_mesh_instance.multimesh
	multi_mesh.mesh = _mesh_instance.mesh
	var screen_size = get_viewport_rect().size
	var mesh_size = Vector2(10,10)
	
	var width = 900.0
	var height = 900.0
	var margin = 50.0
	var count = float(multi_mesh.instance_count)
	var ps = get_blue_noise(width+margin,height+margin,count)
	var ps_circ = filter_circle(Vector2(width/2+margin, height/2+margin), width/2, ps)
	
	var n = 0
	for p in ps_circ:
		var v = Vector2(p.x, p.y)
		var t = Transform2D( 0.0, v)
		#var noise_val = noise.get_noise_2d(v.x, v.y)
		multi_mesh.set_instance_transform_2d(n, t)
		multi_mesh.set_instance_custom_data(
			n, 
			Color(v.x/width,v.y/height,randf(),randf())
		)
		n += 1


func _set_do_distribution(value):
	if value:
		_do_distribution()
		
		
func filter_circle(center, rad, ps):
	var out = []
	for p in ps:
		print(center.distance_to(Vector2(p.x, p.y)))
		if (center.distance_to(Vector2(p.x, p.y)) <= rad):
			out.append(p)
	return out

func get_blue_noise (width, height, n):
	var rng = RandomNumberGenerator.new()
	
	# SWEEP-AND-PRUNE BLUE-NOISE-SAMPLES
	# example code by @2DArray
	
	# a version with no comments:
	# https://pastebin.com/V87QZDUg
	
	# list of points
	var p=[]

	# how many points to spawn?
	var count=n
	
	for i in range(0,count):
		# x value gradually increases
		# as we spawn more points.
		# the newest point is always
		# the rightmost point!
		var x=i/count*height
		
		# test some y-positions for
		# this x-position.
		# we'll keep track of the
		# best candidate we've found
		var bestscore=0
		var besty=0
		for j in range(0,50):
		
			# y-candidate is random
			var y=rng.randf_range(0,width)
			
			# find closest neighbor.
			# initial closest-dist is
			# "mega-huge." in other
			# languages this might be
			# maxvalue, or infinity.
			var closestdist=32000
			
			# iterate points...
			# but do it in reverse!!
			for k in range(i-1,1,-1):
				var other=p[k]
				
				# this is the broadphase.
				# seems simple, but think
				# closely about this part!
				# by iterating in reverse,
				# the x position of each
				# neighbor gets lower and
				# lower. once we reach a
				# neighbor whose x value
				# is farther away than our
				# closest-neighbor-so-far,
				# we know that any later
				# tests (against points
				# with a lower index) will
				# be far enough away that
				# we can safely skip them.
				# if so:
				# ~~early-quit the loop!!~~
				if (other.x+closestdist<x):
					break
				
				# measure the distance
				# to this neighbor
				var dx=other.x-x
				var dy=other.y-y
				var dist=sqrt(dx*dx+dy*dy)
				
				# keep track of the closest
				# neighbor we've found for
				# this y-candidate
				if (dist<closestdist):
					closestdist=dist
			
			# neighbor-check complete!
			# a candidate's score is
			# their distance away from
			# their closest neighbor.
			if (closestdist>bestscore):
				# this is the best candidate
				# we've seen so far!
				bestscore=closestdist
				besty=y
		
		# all candidates have been
		# tested! "besty" is the
		# y-candidate which puts us
		# farthest away from any
		# other points.
		var d = {"x"=x,"y"=besty}
		p.append(d)

	return p
