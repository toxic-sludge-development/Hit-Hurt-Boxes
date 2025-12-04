@icon("res://addons/Toxic-Library/toxic_hit_hurt_boxes/Hurtbox.svg")

extends Area2D
class_name Hurtbox2d

## Manages health and takes damage

##################################
# VARIABLES
##################################

# EXPORTS
@export_range(0,25,1) var faction : int = 0 ##Can not take damage from HittBox2ds with the same faction number. Set to 0 to take damage from any type.
@export_group("Damage")

@export var invincible: bool = false ##Immune to damage
@export var auto_damage: bool = true ##Takes damage automatically when colliding with a Hitbox2d

@export_subgroup("Armor")
@export var divide_by: float = 1 ##Divide incoming damage by this
@export var subtract_from: float = 0 ##Subtract this from incoming damage

@export_group("Healing")

@export var can_heal: bool = true ##Wether or not this node can be healed
@export var auto_heal: bool = true ##Heals automatically when colliding with a healing Hitbox2d

@export_subgroup("Bonus")
@export var multiply_by: float = 1 ##Multiply healing by this
@export var add_to: float = 0 ##Add this to incoming healing

@export_group("Health")

@export var max_health: float = 100 ##Maximum amount if health
@export var min_health: float = 0 ##Minimum amount health can't decrease under
@export var current_health: float = -INF ##The amount of health set at the beginning (Leave empty for Max)
@export var death_point: float = 0 ##The point under which the death signal is emitted


# VARS
var health: float = 0: set = _set_health

####################################
# SIGNALS
####################################
signal died
signal damaged
signal healed
signal over_max_health
signal under_min_health
####################################
# METHODS
####################################

func damage(damage_num: float) -> void:
	emit_signal("damaged")
	if can_heal:
		var dealt_damage = damage_num / divide_by - subtract_from
		health -= dealt_damage

func heal(heal_num: float) -> void:
	emit_signal("healed")
	if can_heal:
		var dealt_healing = heal_num * multiply_by + add_to
		health += dealt_healing

func health_check() -> void:
	if health > max_health:
		emit_signal("over_max_health")
		health = max_health
	if health < min_health:
		health = min_health
		emit_signal("under_min_health")
	if health <= death_point:
		emit_signal("died")

func _set_health(new_value: float) -> void:
	health = new_value
	health_check()

####################################
# BODY
####################################

func _ready() -> void:
	if current_health != -INF:
		health = current_health
	else:
		health = max_health
	

func _physics_process(_delta: float) -> void:
	if !get_overlapping_areas().is_empty():
		var overlapping_areas = get_overlapping_areas()
		for area in overlapping_areas:
			if area is Hitbox2d && area.active && (faction != area.faction or (area.faction == 0 or faction == 0)) && !invincible:
				if area.healing && auto_heal:
					heal(area.damage)
				elif auto_damage:
					damage(area.damage)
				area.damage_cooldown(self)
