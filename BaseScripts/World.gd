extends Node3D

@onready var player: Node3D = $Knigth

func _physics_process(_delta):
  get_tree().call_group("Enemies", "updateTargetLocation", player.global_transform.origin)
