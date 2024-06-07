extends Control

func _ready():
  self.hide()

func _on_player_game_over():
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  
  self.show()
  get_tree().paused = true

func _on_play_button_button_up():
  get_tree().paused = false
  self.hide()
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  SceneManager.swap_scenes(
    "res://Levels/LevelOne/level_one.level.tscn",
    get_tree().root,
    get_parent(),
    "fade_to_black"
  )

func _on_exit_button_button_up():
  get_tree().paused = false
  SceneManager.swap_scenes(
    "res://Menus/Screens/MainMenu/MainMenu.screen.tscn",
    get_tree().root,
    get_parent(),
    "wipe_to_right"
  )
