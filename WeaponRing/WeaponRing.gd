class_name WeaponRing extends Node3D
# preload all the weapons
var longSword = preload("res://Weapons/longSword/longSword.weapon.tscn")

@export var weaponList: Array[Weapon] = []

const weaponHeight = 1.7

func _ready():
  # add two longSwords to the weaponList
  addNewWeapon(longSword)
  # addNewWeapon(longSword, {"detectionRange": 7})

func _process(delta):
  #  make the weapon ring rotate
  rotate_y(delta * 0.3)

  # using the lenght of the weaponList to calculate the angle between each weapon and the center of the ring
  # filter the weapons that arent idling
  var idlingWeapons = weaponList.filter(func(weapon): return weapon.isIdling == true)
  for i in range(idlingWeapons.size()):
    var angle = i * 2 * PI / idlingWeapons.size()
    var x = cos(angle) * 2.5
    var z = sin(angle) * 2.5
    idlingWeapons[i].transform.origin = Vector3(x, weaponHeight, z)
    # make the weapon look at the center of the ring, declare var ring center as the center of this node
    var ringCenter = self.global_transform.origin
    ringCenter.y = weaponHeight + 1
    
    idlingWeapons[i].look_at(ringCenter, Vector3.UP)


func addNewWeapon(weapon: PackedScene, weaponParams: Dictionary = {}):
  var newWeapon = weapon.instantiate()
  newWeapon.centerNodeRef = self
  # use the weaponParams to set the weapon properties
  for key in weaponParams.keys():
    newWeapon[key] = weaponParams[key]
  weaponList.append(newWeapon)
  add_child(newWeapon)
