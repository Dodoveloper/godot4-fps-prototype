extends MarginContainer

var object: Object

func _init(obj: Object, text:String):
	object = obj
	#alignment = MarginContainer.ALIGNMENT_CENTER
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var button := Button.new()
	add_child(button)
	self.set("theme_override_constants/margin_left",2)
	self.set("theme_override_constants/margin_top",2)
	self.set("theme_override_constants/margin_right",2)
	self.set("theme_override_constants/margin_bottom",2)
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.flat = false
	button.text = text
	button.button_down.connect(object._on_button_pressed.bind(text))
	
