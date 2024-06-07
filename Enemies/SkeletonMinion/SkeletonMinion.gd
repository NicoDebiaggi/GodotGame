extends CharacterBody3D

# Properties
@export_category("SkeletonMinion")
@export var damage: float = 1.0
@export var attackSpeed: float = 1.0
@export var attackRange: float = 1.0
@export var speed: float = 1.0
@export var health: float = 30.0

# Variables
@onready var animationTree: AnimationTree = $skeletonMinion_mesh/AnimationTree
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
const navAgentOffset = .3
var just_hit: bool = false
var isDead = false
var isAttacking = false
var targetIsDead = false

func _ready():
  navAgent.target_position = self.global_transform.origin
  navAgent.target_desired_distance = attackRange + navAgentOffset

func _physics_process(delta):
  if health < 1 || isDead:
    kill()
    return

  var currentLocation = self.global_transform.origin
  await get_tree().process_frame
  var nextLocation = navAgent.get_next_path_position()
  var lookAtVector = (navAgent.target_position - currentLocation).normalized()
  self.look_at((currentLocation + lookAtVector), Vector3.UP)
  var newVelocity = (nextLocation - currentLocation).normalized() * speed * 10 * delta
  navAgent.set_velocity(newVelocity)

func kill():
  isDead = true
  const deathY = 0.15
  animationTree.set("parameters/conditions/death", true)
  # move the body below the ground with an animation
  global_position.y = lerp(global_position.y, deathY, 0.025)
  if global_position.y <= deathY + 0.05:
    queue_free()

func updateTargetLocation(targetLocation: Vector3, isTargetDead: bool):
  if isTargetDead:
    targetIsDead = true
    return
  else:
    targetLocation.y = self.global_transform.origin.y
    navAgent.target_position = targetLocation

func _on_navigation_agent_3d_target_reached():
  if isDead or targetIsDead:
    isAttacking = false
    animationTree.set("parameters/conditions/attacking", false)
    return
  isAttacking = true
  animationTree.set("parameters/conditions/attacking", true)
  pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3):
  if isDead or targetIsDead:
    isAttacking = false
    animationTree.set("parameters/conditions/attacking", false)
    return

  var currentLocation = self.global_transform.origin
  var distanceToTarget = navAgent.target_position.distance_to(currentLocation) - navAgentOffset
  if distanceToTarget > attackRange:
    isAttacking = false
    animationTree.set("parameters/conditions/attacking", false)
    velocity = velocity.move_toward(safe_velocity, .25)
  else:
    velocity = Vector3.ZERO

  move_and_slide()

func _on_just_hit_timeout():
  just_hit = false

func _on_area_3d_body_part_hit(damage_received:Variant, isCritic:Variant, critic_multiplier:Variant, knockback:Variant):
  if (isDead or just_hit):
    return
  else :
    get_node("just_hit").start()
    just_hit = true
    var finalDamage = damage_received
    if isCritic:
      finalDamage *= critic_multiplier
    health -= finalDamage

    # Knockback
    var knockbackDirection: Vector3 = (global_position - navAgent.target_position).normalized()
    knockbackDirection.y = 0
    knockbackDirection *= knockback * 2
    velocity = knockbackDirection

func _on_damage_detector_area_entered(area: Area3D):
    # Assert that the area is in the player_hitbox group
    if area.is_in_group("player_hitbox"):
      area.hit(damage, 1, 1)
