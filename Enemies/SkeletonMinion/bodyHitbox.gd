class_name bodyHitbox extends Area3D

signal body_part_hit(damage_received, isCritic, critic_multiplier, knockback)

func hit(damage, critic_multiplier, knockback):
    var isCritical = self.is_in_group("critical")
    emit_signal("body_part_hit", damage, isCritical, critic_multiplier, knockback)