extends Node2D

var posRD = Vector2()
var posLU = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	posRD = $BoxLevelTesting.posRD
	posLU = $BoxLevelTesting.posLU
	$Player.prepare_camera(posLU, posRD)
	$IgnisRegularOuter.connect("ignis_regular_taken", $Player, "_on_IgnisRegularOuter_ignis_regular_taken")
