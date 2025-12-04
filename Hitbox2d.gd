@icon("res://addons/Toxic-Library/toxic_hit_hurt_boxes/Hitbox.svg")

extends Area2D
class_name Hitbox2d

## Deals damage to Hurtbox2ds

##################################
# VARIABLES
##################################

# ENUMS

enum reset_type_enum {Exit, Cooldown, Oneshot}

# EXPORTS

@export var active: bool = true ##Wether or not the hitbox deals any damage
@export_range(0,25,1) var faction : int = 0 ##Can not deal damage to HurtBox2ds with the same faction number. Set to 0 to damage any type.
@export var healing: bool = false ##Converts all damage into healing
@export_group("Damage")
@export var damage: float = 1 ##The amount of damage dealt
@export var reset_type: reset_type_enum = reset_type_enum.Exit ##Exit: Reactivates after exiting the Hurtbox.  Cooldown: Reactivates after a set cooldown time.  Oneshot: Is not reactivated
# NOTE: Exit may have a glitch when colliding with multiple hurtboxes
@export var cooldown_time: float = 1 ##The amount of time, in seconds, until the hitbox reactivates. Only applies if "Cooldown" is the reset type.

# VARIBALES
var current_hurtbox: Hurtbox2d
var in_hurtbox: bool = false

###############################
# METHODS
###############################

func damage_cooldown(damaged_node: Hurtbox2d) -> void:
	active = false
	match reset_type:
		reset_type_enum.Cooldown:
			await get_tree().create_timer(cooldown_time).timeout
			active = true
		reset_type_enum.Exit:
			if damaged_node in get_overlapping_areas():
				current_hurtbox = damaged_node
				in_hurtbox = true
		reset_type_enum.Oneshot:
			pass

################################
# BODY
################################

func _process(delta: float) -> void:
	if reset_type == reset_type_enum.Exit && in_hurtbox:
		if current_hurtbox in get_overlapping_areas():
			pass
		else:
			active = true
			in_hurtbox = false
	
