class_name Weapon extends Node3D

# The Weapon class is a MeshInstance3D that represents a weapon in a 3D scene. It is used to manage the weapon's state and behavior.

# Properties
@export_category('Weapon Stats')
@export_range(0, 100, 0.1) var damage: float = 10
@export var weaponCritic: float = 1.1
@export var weaponKnockback: float = 1
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
var attackedEnemy: Node3D = null
var closestEnemy = null
var closestDistance: float = 1000
@onready var animationTree: AnimationTree = $"2H_Sword/AnimationTree"
@onready var hitZone: Area3D = $"2H_Sword/Area3D"
const baseAnimDuration = 1.6667

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

    var newBaseDuration = attackSpeed / baseAnimDuration
    animationTree.set("parameters/VerticalSwing/TimeScale/scale", newBaseDuration)
    animationTree.set("parameters/LeftDiagonalSwing/TimeScale/scale", newBaseDuration)
    animationTree.set("parameters/RightDiagonalSwing/TimeScale/scale", newBaseDuration)


func _process(_delta):
    # Check for enemies in detection zone
    var bodies = detectionZone.get_overlapping_bodies()
    # Check who is the closest enemy in range
    for body in bodies:
        if body != self and body.is_in_group("Enemies") and body.isDead == false:
          var distance = detectionZone.global_transform.origin.distance_to(body.global_transform.origin)
          if distance < closestDistance and !isAttacking:
              closestDistance = distance
              closestEnemy = body

    if closestEnemy != null:
        isIdling = false
        animationTree.set("parameters/conditions/isIdling", false)
        positionWeaponCloseToEnemy(closestEnemy)
    else:
        animationTree.set("parameters/conditions/isIdling", true)
        isIdling = true


func positionWeaponCloseToEnemy(enemy: Node3D):
    # Position the weapon close to the enemy
    var enemyGlobalTransform = enemy.global_transform
    var enemyPosition = enemyGlobalTransform.origin
    var direction = enemyPosition.direction_to(centerNodeRef.global_transform.origin).normalized()
    var attackPosition = enemyPosition + direction * (attackRange - 0.25)
    attackPosition.y = attackPosition.y + 0.5
    global_transform.origin = global_transform.origin.lerp(attackPosition, 0.1)

    # Rotate the weapon to face the enemy using direction
    global_transform.basis = Basis.looking_at(direction, Vector3(0, 1, 0)) * Basis(Vector3(0, 1, 0), -90 * PI / 180)

    # If distance to enemy is less than attackRange, attack the enemy
    if global_transform.origin.distance_to(enemyPosition) < attackRange + 0.2 and !isAttacking:
        attack(enemy)

func attack(enemy: Node3D):
    animationTree.set("parameters/conditions/isAttacking", true)
    attackedEnemy = enemy
    isAttacking = true
    get_tree().create_timer(attackSpeed).connect("timeout", on_attack_timeout)

func on_attack_timeout():
    animationTree.set("parameters/conditions/isAttacking", false)
    isAttacking = false
    attackedEnemy = null
    closestEnemy = null
    closestDistance = 1000

func _on_damage_detector_area_entered(area:bodyHitbox):
    # Assert that the area is in the enemy_hitbox group
    if area.is_in_group("enemy_hitbox"):
        area.hit(damage, weaponCritic, weaponKnockback)
