class_name Weapon extends Node3D

# The Weapon class is a MeshInstance3D that represents a weapon in a 3D scene. It is used to manage the weapon's state and behavior.

# Properties
@export_category('Weapon Stats')
@export_range(0, 100, 0.1) var damage: float = 10
@export_range(0, 15, 0.1) var detectionRange: float = 5
@export_range(0, 15, 0.1) var attackRange: float = 1
@export_range(0, 100, 0.1) var attackSpeed: float = 1
@export_range(1, 4, 1) var weaponLevel: int = 1
@export_enum("Melee", "Ranged") var weaponType: int = 0
@export var weaponName: String
@export var weaponRigidBody: RigidBody3D = null

# variables
var centerNodeRef: Node3D = null
var isIdling: bool = true
var isAttacking: bool = false
var isReloading: bool = false

# Generate a detection zone for enemies, should be a cilinder shape positiones on centerNodeRef with a radius of detectionRange
var detectionZone: Area3D = Area3D.new()
var detectionZoneShape: CollisionShape3D = CollisionShape3D.new()

# Methods
func _ready():
    # Called when the node is added to the scene for the first time.
    var cylinderShape = CylinderShape3D.new()
    cylinderShape.radius = detectionRange
    cylinderShape.height = 2
    detectionZoneShape.shape = cylinderShape
    detectionZone.add_child(detectionZoneShape)
    detectionZone.set_collision_layer_value(1, false)
    detectionZone.set_collision_mask_value(1, false)
    detectionZone.set_collision_layer_value(2, true)
    detectionZone.set_collision_mask_value(2, true)
    centerNodeRef.add_child.call_deferred(detectionZone)
    detectionZone.position = Vector3(0, 2, 0)

func _process(_delta):
    # Check for enemies in detection zone
    var bodies = detectionZone.get_overlapping_bodies()
    # Check who is the closest enemy in range
    var closestEnemy = null
    var closestDistance: float = 1000
    for body in bodies:
      print(body)
      if body != self and body.is_in_group("Enemies"):
        var distance = detectionZone.global_transform.origin.distance_to(body.global_transform.origin)
        if distance < closestDistance:
          print("Enemy detected at " + str(distance) + " meters")
          closestDistance = distance
          closestEnemy = body

    if closestEnemy != null:
      positionWeaponCloseToEnemy(closestEnemy)
    else:
      isIdling = true
    
func positionWeaponCloseToEnemy(enemy: Node3D):
    # Position the weapon close to the enemy
    var enemyGlobalTransform = enemy.global_transform
    var enemyPosition = enemyGlobalTransform.origin
    # var enemyRotation = enemyGlobalTransform.basis.get_euler()

    global_transform.origin = enemyPosition
    global_transform.basis = enemyGlobalTransform.basis
    global_transform.basis = global_transform.basis.rotated(Vector3(0, 1, 0), PI)
    global_transform.origin += global_transform.basis.z * attackRange

    # make the above transformations but with a lerp function to make it smooth
    # global_transform.origin = global_transform.origin.lerp(enemyPosition, 1)
    # global_transform.basis = global_transform.basis.slerp(enemyGlobalTransform.basis, 1)

func attack():
    # Called when the weapon attacks.
    print("Attacking with " + weaponName + " for " + str(damage) + " damage")
