extends Node3D

@onready var spawn_point = %SpawnPoint
@onready var damage_number_template = preload("res://DamageNumber/damage_number.tscn")


@export var spread_value: int = 1
@export var height_value: int = 2
@export var duration: float = 1
@export var sizeRatio: float = 1
@export_color_no_alpha var initial_color = Color(1, 1, 1, 1)
@export_color_no_alpha var final_color = Color(0.6, 0.6, 0.6, 1)

var damage_number_pool: Array[DamageNumber] = []
var rmb_held = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.

func _process(_delta: float) -> void:
	if rmb_held:
		spawn_damage_number(randf_range(0, 10))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		spawn_damage_number(randf_range(0, 1000))

	if event.is_action_pressed("Right Click"):
		rmb_held = true

	if event.is_action_released("Right Click"):
		rmb_held = false


func spawn_damage_number(value: float):
	var damage_number = get_damage_number()
	var val = str(round(value))
	var pos = spawn_point.position
	add_child(damage_number, true)
	damage_number.set_values_and_animate(val, pos, height_value, spread_value, initial_color, final_color, duration, sizeRatio)

func get_damage_number() -> DamageNumber:
	# get a damage number from the pool
	if damage_number_pool.size() > 0:
		return damage_number_pool.pop_front()

	# create a new damage number if the pool is empty
	else:
		var new_damage_number = damage_number_template.instantiate()
		new_damage_number.tree_exiting.connect(
			func(): damage_number_pool.append(new_damage_number))
		return new_damage_number
