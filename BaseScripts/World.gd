extends Node3D

@onready var playerRef: player = $Map_One/NavigationRegion3D/Knigth

func _physics_process(_delta):
  get_tree().call_group("Enemies", "updateTargetLocation", playerRef.global_transform.origin, playerRef.isDead)


func _on_player_game_over():	
  print("Game Over")