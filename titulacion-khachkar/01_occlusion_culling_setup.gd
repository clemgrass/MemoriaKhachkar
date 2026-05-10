extends Node
## OCCLUSION CULLING SETUP PARA GODOT 4.6
## Este script genera automáticamente oclusores para tu museo
## INSTRUCCIONES:
## 1. Crea un nodo vacío en la raíz de tu escena llamado "OcclusionManager"
## 2. Adjunta este script a ese nodo
## 3. Ejecuta la escena con F5
## 4. El script creará una carpeta "OcclusionMeshes" con los oclusores

class_name OcclusionManager

@export var auto_generate_occluders = true
@export var occluder_simplification = 1  # 0-1, menor = más simple
@export var debug_mode = true

var occluders_created = 0

func _ready():
	if auto_generate_occluders:
		print("\n" + "=".repeat(60))
		print("🔍 GENERANDO OCLUSORES AUTOMÁTICAMENTE")
		print("=".repeat(60))
		
		generate_room_occluders()
		print("\n✅ Oclusores generados: %d" % occluders_created)
		print("=".repeat(60) + "\n")

func generate_room_occluders() -> void:
	"""Genera oclusores basados en las salas detectadas"""
	var rooms = find_rooms()
	
	if rooms.is_empty():
		print("⚠️ No se encontraron salas definidas. Usando estrategia genérica...")
		generate_generic_occluders()
		return
	
	for room in rooms:
		create_room_occluder(room)

func find_rooms() -> Array:
	"""Intenta encontrar nodos que representen salas"""
	var rooms = []
	
	# Buscar nodos con nombres que sugieran salas
	var keywords = ["room1", "room2", "room3", "room4", "room5"]
	
	for child in get_parent().get_children():
		var name_lower = child.name.to_lower()
		for keyword in keywords:
			if keyword in name_lower:
				print(name_lower)
				rooms.append(child)
				break
	
	return rooms

func create_room_occluder(room_node: Node) -> void:
	"""Crea un oclusor para una sala específica"""
	if room_node is not Node3D:
		return
	
	# Obtener bounds de la sala
	var aabb = get_node_aabb(room_node)
	if aabb.size == Vector3.ZERO:
		return
	
	# Crear OccluderInstance3D
	var occluder = OccluderInstance3D.new()
	occluder.name = "%s_Occluder" % room_node.name
	occluder.global_position = aabb.get_center()
	
	# Crear ArrayOccluder3D con forma cúbica simplificada
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = aabb.size

	var arrays = cube_mesh.surface_get_arrays(0)

	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var indices = arrays[Mesh.ARRAY_INDEX]

	var array_occluder = ArrayOccluder3D.new()
	array_occluder.set_arrays(vertices, indices)

	occluder.occluder = array_occluder
	
	# Añadir a la escena
	room_node.add_child(occluder)
	
	if debug_mode:
		print("  ✓ Oclusor creado para: %s" % room_node.name)
	
	occluders_created += 1

func get_node_aabb(node: Node) -> AABB:
	"""Obtiene el AABB de todos los meshes dentro de un nodo"""
	var combined_aabb = AABB()
	var has_meshes = false
	
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			combined_aabb = mesh.get_aabb()
			combined_aabb.position += node.global_position
			has_meshes = true
	
	for child in node.get_children():
		var child_aabb = get_node_aabb(child)
		if child_aabb.size != Vector3.ZERO:
			if has_meshes:
				combined_aabb = combined_aabb.merge(child_aabb)
			else:
				combined_aabb = child_aabb
			has_meshes = true
	
	return combined_aabb if has_meshes else AABB()

func generate_generic_occluders() -> void:
	"""Genera oclusores genéricos cuando no hay salas definidas"""
	print("Generando oclusores genéricos basados en estructura...")
	
	var root = get_tree().root.get_child(0)
	
	# Procesar todos los nodos principales
	for child in root.get_children():
		if child is Node3D and child.name != "Player" and child.name != "Camera":
			var aabb = get_node_aabb(child)
			if aabb.size.length() > 10:  # Solo si es suficientemente grande
				create_room_occluder(child)

# ============================================================================
# CONFIGURACIÓN DE PROYECTO (Ejecuta esto UNA SOLA VEZ)
# ============================================================================

static func setup_project_for_occlusion():
	"""
	Configura el proyecto para usar Occlusion Culling.
	Llama esto una sola vez al iniciar.
	"""
	
	print("\n📋 CONFIGURANDO PROYECTO PARA OCCLUSION CULLING...")
	
	
	print("\n⚠️ CONFIGURACIÓN MANUAL REQUERIDA EN project.settings:")
	print("1. Abre Project > Project Settings > Rendering > Occlusion Culling")
	print("2. Set 'BVH Build Mode' = 'Dynamic' (para actualizaciones en tiempo real)")
	print("3. Habilita 'Use Occlusion Culling' en cada OccluderInstance3D")
	print("\nO usa este código en _ready():")
	print("""
	# Activar occlusion culling globalmente
	RenderingServer.set_debug_draw_mode(RenderingServer.DEBUG_DRAW_NONE)
	
	# Para una cámara específica:
	# get_viewport().get_camera_3d().cull_mask = (1 << 0)  # Layer 1
	""")
