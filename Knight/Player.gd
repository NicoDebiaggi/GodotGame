class_name player extends CharacterBody3D

@export var SPEED = 8
@export var SPEED_ACCELERATION = 5
@export var SPEED_FRICTION = 7
@export var DASH_VELOCITY = 80
@export var DASH_TIMEOUT = 0.5
@export var ROTATION_WEIGHT = 10
@export var DASH_TRAIL_LENGTH = 0.1
@export var MAX_HEALTH = 100

@onready var knightRef = $Knight_mesh
@onready var knightAnimationTree: AnimationTree = knightRef.get_node("AnimationTree")
@onready var knightAnimationPlayer: AnimationPlayer = knightRef.get_node("AnimationPlayer")
@onready var dashParticles = $Trail3D
@onready var damageNumSpawner:DamageNumberSpawner = %damage_number_spawner

signal game_over # Signal to be emitted when the player dies.

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var canDash: bool = true
var just_hit: bool = false
var isDead: bool = false
var health: int = MAX_HEALTH

func _physics_process(delta):
	if isDead:
		return
	if health < 1 || isDead:
		kill()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("move_left", "move_rigth", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle dash. it should accelerate the player to DASH_VELOCITY in the direction of the movement. set a timeout to prevent spamming.
	if Input.is_action_just_pressed("move_dash") && canDash:
		velocity = -direction * DASH_VELOCITY
		canDash = false
		# see if we move this node out of the player script into the scene
		await get_tree().create_timer(DASH_TIMEOUT).timeout
		canDash = true

	# Emit the dash particles if the player is dashing.
	if velocity.length() > SPEED:
		dashParticles.segments = lerp(dashParticles.segments, 15, 0.1)
		dashParticles.distance = lerp(dashParticles.distance, DASH_TRAIL_LENGTH, 0.1)
	else:
		dashParticles.segments = lerp(dashParticles.segments, 0, 0.5)
		dashParticles.distance = lerp(dashParticles.distance, 0.0, 0.5)

	if direction.length() > 0:
		# Rotate the character to the direction of movement.
		var desired_rotation_y = atan2( - direction.x, -direction.z)
		knightRef.rotation.y = lerp_angle(knightRef.rotation.y, desired_rotation_y, ROTATION_WEIGHT * delta)

	# Get the input direction and handle the movement/deceleration.
	if (Input.is_action_pressed("move_left") || Input.is_action_pressed("move_rigth") || Input.is_action_pressed("move_up") || Input.is_action_pressed("move_down")) && velocity.length() < SPEED:
		if direction:
			velocity.x = lerp(velocity.x, -direction.x * SPEED, SPEED_ACCELERATION * delta)
			velocity.z = lerp(velocity.z, -direction.z * SPEED, SPEED_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = lerp(velocity.x, 0.0, SPEED_FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, SPEED_FRICTION * delta)
		direction = transform.basis.z

	# Set the run animation
	var runBlendValue: float = ((velocity.length() / SPEED) * 2) - 1
	var currentRunFastBlendValue: float = knightAnimationTree.get("parameters/Alive/run_fast_transition/blend_amount")
	var runFastBlendValue: float = 0.0

	if runBlendValue > 1:
		runFastBlendValue = lerp(currentRunFastBlendValue, 1.0, 1.0)
	else:
		runFastBlendValue = lerp(currentRunFastBlendValue, 0.0, 0.01)

	knightAnimationTree.set("parameters/Alive/run_transition/blend_amount", clamp(runBlendValue, -1, 1))
	knightAnimationTree.set("parameters/Alive/run_fast_transition/blend_amount", clamp(runFastBlendValue, 0, 1))
	
	move_and_slide()

func kill():
	isDead = true
	knightAnimationTree.set("parameters/conditions/isDead", true)
	await get_tree().create_timer(1.0).timeout
	emit_signal("game_over")
	# game over screen or something

func _on_just_hit_timeout():
	just_hit = false

func _on_area_3d_body_part_hit(damage_received, isCritic, critic_multiplier, _knockback):
	if (isDead or just_hit):
		return
	else:
		knightAnimationPlayer.play("Knight/hit")
		get_node("just_hit").start()
		just_hit = true
		var finalDamage = damage_received
		if isCritic:
			finalDamage *= critic_multiplier
		damageNumSpawner.spawn_damage_number(finalDamage)
		health -= finalDamage
