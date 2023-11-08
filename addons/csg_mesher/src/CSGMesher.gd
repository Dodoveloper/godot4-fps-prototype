@tool
extends CSGCombiner3D

## MIT License
## 
## Copyright (c) 2023 Donn Ingle (donn.ingle@gmail.com)
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.


## Add some superpowers to your CSG Shape Nodes. With CSGMesher, you can quickly 
## output the final static mesh (i.e. not the 'live' CSG mesh) as well as an 
## optional static body and collision shape. You can also quickly set a group on 
## the ouput nodes.
## There's an optional 'disable' group for the CSGMesher node itself. This can be 
## useful if you want to disable the node in your own code.

## Lessons learned:
## 1. If the CSGTools node is *not* visible, then nothing works.
##    Added an assert to try inform me of that sitch.


enum {NONE,COLLIDER,MESH,BOTH}
enum colliders { TRIMESH }


## What do you want to make?
@export_enum("None","Collision","Mesh","Full StaticBody3D") var make:int = 0:
	set(v):
		make=v
		if Engine.is_editor_hint(): notify_property_list_changed()


## Group to put the output into - can be useful in scatter-type nodes
@export var group:String


## Add to a group named "disable". You can then use that to hide or
## disable this entire CSGMesher node in your own code.
@export var add_disable_group:bool = false:
	set(b):
		add_disable_group = b
		if b:
			self.add_to_group("disable",true)
		else:
			self.remove_from_group("disable")


## "go_ahead" is intercepted and replaced with a button
@export var go_Mesherize : String


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		if not self.is_connected("visibility_changed", _vis_changed):
			self.visibility_changed.connect(_vis_changed)

		child_entered_tree.connect(_check_kids, CONNECT_REFERENCE_COUNTED)
		
		var stuff : Array = _get_all_csg_children()
		for c in stuff:
			if not c.is_connected("visibility_changed", _vis_changed):
				c.visibility_changed.connect(_vis_changed)
		_detect_hidden_children_and_warn()
		_set_group_on_all()

		# Also force my own group - as per the inspector ui
		add_disable_group = add_disable_group # weird!


func _set_group_on_all():
	# make sure produced children have the group (if any)
	if group:
		var stuff : Array = find_children("*", "StaticBody3D", true)
		for sbod in stuff:
				sbod.add_to_group(group, true)
		stuff = find_children("*", "MeshInstance3D", true)
		for m in stuff:
				m.add_to_group(group, true)


func _on_button_pressed(text:String):
	if Engine.is_editor_hint():
		if make != NONE:
			makestuff()


func _get_all_csg_children():
	return find_children("*", "CSGShape3D", true)


func _vis_changed():
	_detect_hidden_children_and_warn()


func _check_kids(_child):
	_detect_hidden_children_and_warn()
	if _child is CSGShape3D:
		#if not _child.is_connected(&"visibility_changed", _vis_changed):
		_child.visibility_changed.connect(_vis_changed, CONNECT_REFERENCE_COUNTED)


var _complain:bool = false
func _get_configuration_warnings() -> PackedStringArray:
	if _complain:
		return ["FYI: Some children are not visible. They won't be included in output."]
	return []


func _detect_hidden_children_and_warn()->bool:
	var a : Array = _get_all_csg_children()
	var _s : bool = false
	for child in a:
		_s = child.visible
		if not _s: break
	_complain = not _s
	update_configuration_warnings()
	return !_s


## Make the actual mesh, collider or both from the CSG
func makestuff():
	var sbod : StaticBody3D

	var output:Node3D
	# look for the output node and murder it
	output = get_node_or_null("Output")
	if output:
		output.free()

	# make a basic node to contain everything coming
	output = Node3D.new()
	output.name = "Output"
	add_child(output)
	output.set_owner(owner)

	# get the mesh from the CSG
	_update_shape() # wow, vital line!
	var a = get_meshes()
	var m3d : MeshInstance3D = MeshInstance3D.new()

	assert(a.size(), "The CSG get_meshes() command did not work. There is no mesh.")

	m3d.mesh = a[1]

	var shape : Shape3D
	var coll : CollisionShape3D

	if make == MESH or make == BOTH:
		output.add_child(m3d)
		m3d.set_owner(owner)
		m3d.name = "MeshInstance3D"

	if make == COLLIDER or make == BOTH:
		sbod = StaticBody3D.new()
		sbod.name = "StaticBody3D"

		output.add_child(sbod)
		sbod.set_owner(owner)

		shape = m3d.mesh.create_trimesh_shape()

		coll = CollisionShape3D.new()
		coll.shape = shape
		assert(coll, "Collision shape is empty")

		sbod.add_child(coll)
		coll.set_owner(owner)

	_set_group_on_all()
