class_name MainMenu extends Control

func _on_play_button_button_up():
  SceneManager.swap_scenes(
    "res://Levels/LevelOne/level_one.level.tscn",
    get_tree().root,
    self,
    "fade_to_black"
  )
