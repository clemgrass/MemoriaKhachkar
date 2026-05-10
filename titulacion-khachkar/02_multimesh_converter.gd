extends Node
## MULTIMESH CONVERTER - Convierte meshes repetidos a MultiMesh
## Impacto: Reduce draw calls de O(n) a O(1) por tipo de mesh
##
## USO:
## 1. Crea un nodo vacío en la raíz llamado "MultiMeshConverter"
## 2. Adjunta este script
## 3. Ejecuta la escena (F5)
## 4. Se crearán automaticamente MultiMeshInstance3D para meshes que se repiten 20+ veces

class_name MultiMeshConverter

@export var min_instances_for_conversion = 20  # Convertir solo si hay 20+ instancias
@export var debug_output = true
@export var auto_convert_on_ready = true

var mesh_groups = {}
var multimesh_instances_created = 0

func _ready():
	if auto_convert_on_ready:
		print("\n" + "="*70)
		print("🔄 INICIANDO CONVERSIÓN A MULTIMESH")
		print("="*70)
		
		await get_tree().process_frame  # Esperar a que cargue la escena
		
		scan_and_group_meshes()
		convert_to_multimesh()
		
		print("\n✅ MULTIMESH CONVERSION COMPLETADA")
		print("   MultiMeshInstance3D creadas: %d" % multimesh_instances_created)
		print("   Impacto estimado: -30% a -50% draw calls")
		print("="*70 + "\n")

func scan_and_group_meshes() -> void:
	"""Escanea la escena y agrupa MeshInstance3D idénticas"""
	print("\n📍 Escaneando meshes...")
	
	var root = get_tree().root.get_child(0)
	scan_node_recursive(root)
	
	print("   Total de meshes encontrados: %d" % sum_meshes())
	print("   Grupos de meshes idénticas: %d" % mesh_groups.size())
	
	# Mostrar candidatos para conversión
	var conversion_candidates = mesh_groups.keys().filter(
		func(key): return mesh_groups[key].size() >= min_instances_for_conversion
	)
	
	print("   Candidatos para MultiMesh (20+ instancias): %d" % conversion_candidates.size())
	
	for mesh_path in conversion_candidates:
		var count = mesh_groups[mesh_path].size()
		print("      • %s → %d instancias" % [mesh_path.get_file(), count])

func scan_node_recursive(node: Node) -> void:
	"""Busca recursivamente todos los MeshInstance3D"""
	if node is MeshInstance3D and node.mesh != null:
		var mesh_id = get_mesh_identifier(node)
		
		if mesh_id not in mesh_groups:
			mesh_groups[mesh_id] = []
		
		mesh_groups[mesh_id].append(node)
	
	for child in node.get_children():
		scan_node_recursive(child)

func get_mesh_identifier(mesh_instance: MeshInstance3D) -> String:
	"""Obtiene un identificador único para un mesh"""
	var mesh = mesh_instance.mesh
	
	# Usar la ruta del recurso o un ID interno
	var mesh_path = mesh.resource_path
	if mesh_path == "":
		mesh_path = "internal_%s" % str(mesh.get_instance_id())
	
	return mesh_path

func convert_to_multimesh() -> void:
	"""Convierte grupos de meshes idénticas a MultiMesh"""
	print("\n⚙️ Convirtiendo a MultiMesh...")
	
	for mesh_id in mesh_groups.keys():
		var instances = mesh_groups[mesh_id]
		
		# Solo convertir si hay suficientes instancias
		if instances.size() < min_instances_for_conversion:
			continue
		
		# Crear MultiMesh
		var multimesh_instance = create_multimesh_instance(instances)
		if multimesh_instance:
			multimesh_instances_created += 1
			
			if debug_output:
				var first_instance = instances[0]
				print("   ✓ Convertido: %s x%d → MultiMesh" % [
					first_instance.mesh.resource_name,
					instances.size()
				])

func create_multimesh_instance(instances: Array) -> MultiMeshInstance3D:
	"""Crea una MultiMeshInstance3D a partir de instancias individuales"""
	if instances.is_empty():
		return null
	
	var first_instance = instances[0] as MeshInstance3D
	var mesh = first_instance.mesh
	
	if mesh == null:
		return null
	
	# Crear MultiMesh
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instances.size()
	multimesh.mesh = mesh
	
	# Llenar las transformaciones
	for i in range(instances.size()):
		var instance = instances[i] as MeshInstance3D
		var transform = instance.global_transform
		multimesh.set_instance_transform(i, transform)
	
	# Copiar material del primer mesh
	var material = first_instance.get_active_material(0)
	
	# Crear MultiMeshInstance3D
	var multimesh_instance = MultiMeshInstance3D.new()
	multimesh_instance.multimesh = multimesh
	multimesh_instance.name = "%s_MultiMesh" % first_instance.mesh.resource_name
	
	if material:
		multimesh_instance.material_override = material
	
	# Añadir a la escena (en el mismo parent del primer mesh)
	var parent = first_instance.get_parent()
	parent.add_child(multimesh_instance)
	multimesh_instance.owner = get_tree().edited_scene_root
	
	# Ocultar meshes originales
	for instance in instances:
		instance.visible = false
		instance.process_mode = Node.PROCESS_MODE_DISABLED
	
	return multimesh_instance

func sum_meshes() -> int:
	var total = 0
	for group in mesh_groups.values():
		total += group.size()
	return total

# ============================================================================
# OPTIMIZACIONES ADICIONALES PARA MULTIMESH
# ============================================================================

static func optimize_multimesh_performance():
	"""
	Optimizaciones adicionales para MultiMesh en WebGL
	"""
	print("\n💡 RECOMENDACIONES PARA MULTIMESH EN WEBGL:")
	print("""
	1. INSTANCIAS VISIBLES: 
	   - MultiMesh funciona mejor con 10-500 instancias por MultiMeshInstance3D
	   - Si tienes >500, considera dividir en múltiples MultiMesh
	
	2. OCCLUSION CULLING:
	   - MultiMeshInstance3D respeta occlusion culling
	   - Pero todos los nodos en la MultiMesh se cull juntos
	   - Considera usar occlusion culling en puntos de entrada de salas
	
	3. INSTANCING:
	   - Si necesitas actualizar posiciones dinámicamente:
	   - Usa compute shaders o update_multimesh() cada frame
	   - Para estático (árboles, decoración): sin overhead
	
	4. PERFORMANCE EN WEBGL:
	   - MultiMesh = +20-40% FPS vs MeshInstance3D individual
	   - Especialmente importante en WebGL donde draw calls son limitados
	
	5. DEBUG:
	   - Si algo se ve mal: revisa cull_mask y materials
	   - MultiMesh hereda material del MultiMeshInstance3D
	""")

