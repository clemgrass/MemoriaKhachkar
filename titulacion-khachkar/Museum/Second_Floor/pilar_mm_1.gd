@tool
extends MultiMeshInstance3D

## =========================================================
## POBLADOR AUTOMÁTICO DE PILARES
## =========================================================
## Crea 27 instancias separadas por 0.975 en X
##
## REQUISITOS:
## 1. Este script debe ir en PilarMM1
## 2. PilarMM1 debe tener un MultiMesh asignado
## 3. El MultiMesh debe tener el mesh del pilar
##
## FUNCIONA EN EL EDITOR
## =========================================================

@export var build_now := false

@export var pillar_count := 27
@export var spacing := 0.975

func _process(_delta):

	if not Engine.is_editor_hint():
		return

	if not build_now:
		return

	build_now = false
	build_pillars()


func build_pillars():

	if multimesh == null:
		push_error("PilarMM1 no tiene MultiMesh asignado")
		return

	multimesh.instance_count = pillar_count

	for i in range(pillar_count):

		var transform_3d = Transform3D()

		## Posición:
		## X aumenta
		## Y permanece igual
		## Z permanece igual

		transform_3d.origin = Vector3(
			spacing * i,
			0,
			0
		)

		multimesh.set_instance_transform(
			i,
			transform_3d
		)

	print("✅ Pilares generados: ", pillar_count)
