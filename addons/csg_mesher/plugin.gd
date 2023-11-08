@tool
extends EditorPlugin

# MIT License
#
# Copyright (c) 2023 Donn Ingle (donn.ingle@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

var inspector_plugin

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		add_custom_type(
			"CSGMesher", #type
			"CSGCombiner3D", #base
			preload("src/CSGMesher.gd"), #script
			preload("CSGMesher_icon.svg") #icon
		)
	
	# Add our custom Go button!
	inspector_plugin = preload("src/inspectorbutton/inspector_button_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("CSGMesher")
	remove_inspector_plugin(inspector_plugin)

func _get_plugin_name() -> String:
	return "CSG Mesher"
