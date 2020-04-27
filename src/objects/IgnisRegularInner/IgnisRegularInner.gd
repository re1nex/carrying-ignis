extends Light2D

const deltaScale = 0.0025
const energyDec = 0.025
const energyMin = 0.1
const default_health = GlobalVars.Ignis_state.LIFE_MAX
const health_to_index = {
	GlobalVars.Ignis_state.OFF: 0,
	GlobalVars.Ignis_state.LIFE_1: 1,
	GlobalVars.Ignis_state.LIFE_2: 2,
	GlobalVars.Ignis_state.LIFE_3: 3,
	GlobalVars.Ignis_state.LIFE_MAX: 4,
}
const index_to_health = [
	GlobalVars.Ignis_state.OFF,
	GlobalVars.Ignis_state.LIFE_1,
	GlobalVars.Ignis_state.LIFE_2,
	GlobalVars.Ignis_state.LIFE_3,
	GlobalVars.Ignis_state.LIFE_MAX,
]
const energy_levels = [0, 0.75, 0.85, 0.95, 1.00] # default for inner
const scale_levels = [0, 0.75, 0.85, 0.95, 1.00] # default for inner

var minScale
var energyMax
var switchingOff
var switchedOff
var health = default_health
var true_scale # when the health is max (start values)
var true_energy
var true_area2D_scale
var true_vis_enabler_scale
var scale_list # can be changed in IgnisRegularLevel
var energy_list # call set_health_params() to change

var priority = 1

var reflected = 1

var enemy_visible = true

enum Ignis_layer{
	STAGE,
	MENU
}

# Called when the node enters the scene tree for the first time.
func _ready():
	scale_list = scale_levels # default parameters
	energy_list = energy_levels # default parameters
	true_area2D_scale = $Area2D.scale
	true_vis_enabler_scale = $VisibilityEnabler2D.scale
	minScale = texture_scale - 0.01
	true_scale = texture_scale
	energyMax = 1.2
	true_energy = energyMax
	switchingOff = false
	switchedOff = true
	finish_disabling()
	set_state()
	set_process(false)
	set_visibility_flags(true)
	pass # Replace with function body

# Called in ignisRegularLevel and ...Outer to increase radiuses
func init_radius(mul):
	texture_scale *= mul
	$Area2D.scale *= mul
	minScale = texture_scale - 0.01
	$VisibilityEnabler2D.scale *= mul
	true_scale = minScale
	true_area2D_scale = $Area2D.scale
	true_vis_enabler_scale = $VisibilityEnabler2D.scale


func set_light_layer(layer):
	if layer == Ignis_layer.STAGE:
		shadow_item_cull_mask = 1 << 0
		$Flame.light_mask = 1 << 0
		range_item_cull_mask = 1 << 1
	elif layer == Ignis_layer.MENU:
		shadow_item_cull_mask = 1 << 1
		$Flame.light_mask = 1 << 1
		range_item_cull_mask = 1 << 1


func set_enemy_visible(vis):
	enemy_visible = vis
	if enemy_visible == false:
		$Area2D/CollisionShape2D.disabled = true


func _process(delta):
	texture_scale = minScale + float(randf() / (minScale + deltaScale))
	if switchingOff and not switchedOff:
		# switching off is in process
		energy -= energyDec
		checkEnergy()
	if not switchingOff and switchedOff:
		# light needs to be switched on
		finish_enabling()


func checkEnergy():
	if energy <= energyMin:
		finish_disabling()
		set_process(false)
		set_visibility_flags(false)
		switchedOff = true


func disable():
	switchingOff = true


func finish_disabling():
	if enemy_visible == true:
		$Area2D/CollisionShape2D.disabled = true
	$Flame.emitting = false
	$Smoke.emitting = false
	enabled = false
	energy = 0
	switchedOff = true


func enable():
	if health != GlobalVars.Ignis_state.OFF:
		switchingOff = false
		energy = energyMax
		set_process(true)
		set_visibility_flags(true)


func finish_enabling():
	switchedOff = false
	$Flame.emitting = true
	$Smoke.emitting = true
	if enemy_visible == true:
		$Area2D/CollisionShape2D.disabled = false
	enabled = true
	energy = energyMax


func mirror():
	reflected *= -1
	pass


func rotate_ignis(degree):
	pass


func set_visibility_flags(val):
	$VisibilityEnabler2D.process_parent = val
	$VisibilityEnabler2D.pause_particles = val


func set_state():
	var ind = health_to_index[health]
	if ind == 0:
		_handle_state_off()
	else:
		_set_state_params(scale_list[ind], energy_list[ind])


func _handle_state_off():
	disable()


func _set_state_params(scale_part, energy_part):
	minScale = true_scale * scale_part - 0.01
	energyMax = true_energy * energy_part
	$Area2D.scale = true_area2D_scale * scale_part
	$VisibilityEnabler2D.scale = true_vis_enabler_scale * scale_part


func hit():
	var ind = health_to_index[health]
	if ind > 0:
		ind -= 1
	health = index_to_health[ind]
	set_state()

# source state is GlobalVars.Ignis_state enum
func reload(source_state):
	health = source_state


func set_health_params(new_scales, new_energies):
	scale_list = new_scales
	energy_list = new_energies
	set_state()
