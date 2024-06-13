class_name DamageNumber
extends Node3D

@onready var label:Label3D = %Label3D
@onready var label_container:Node3D = %LabelContainer

	
func set_values_and_animate(value:String, start_pos:Vector3, height:float, spread:float, start_color: Color, end_color:Color, anim_duration:float, sizeRatio:float) -> void:
	label.text = value
	label.scale = Vector3(sizeRatio,sizeRatio,sizeRatio)

	var end_pos = Vector3(randf_range(-spread,spread),height,randf_range(-spread,spread)) + start_pos
	var tween = get_tree().create_tween()

	# label anim
	tween.tween_property(label,"modulate", start_color, anim_duration/3).from(label.modulate)
	tween.parallel().tween_property(label,"outline_modulate", Color(0,0,0,1), anim_duration/3).from(label.outline_modulate)
	tween.parallel().tween_property(label, "scale", label.scale, anim_duration/3).from(label.scale * 0.5)

	tween.tween_property(label,"modulate", end_color, anim_duration/3).from(start_color)
	tween.parallel().tween_property(label, "scale", label.scale * 0.5, (anim_duration/3) * 2).from(label.scale)

	tween.tween_property(label,"modulate", Color(0,0,0,0), anim_duration/3).from(end_color)
	tween.parallel().tween_property(label,"outline_modulate", Color(0,0,0,0), anim_duration/3).from(Color(0,0,0,1))

	tween.play()


	# movement anim
	var tweenMovement = get_tree().create_tween()
	tweenMovement.tween_property(label_container,"position",end_pos,anim_duration).from(start_pos)


func remove() -> void:
	if is_inside_tree():
		get_parent().remove_child(self)
