extends Node
## Script de análisis completo de la escena 3D
## Coloca este script en un nodo vacío y ejecuta la escena para obtener un reporte

class_name SceneAnalyzer

var mesh_count = 0
var material_count = 0
var texture_count = 0
var total_vertices = 0
var total_triangles = 0
var material_dict = {}  # Para contar materiales únicos
var texture_dict = {}   # Para contar texturas únicas
var mesh_dict = {}      # Para contar instancias del mismo mesh
var static_bodies = 0
var rigid_bodies = 0
var omni_lights = 0
var directional_lights = 0
var viewport_area = 0

var results_file = "res://scene_analysis_results.txt"

func _ready():
	print("\n" + "=".repeat(60))
	print("🔍 INICIANDO ANÁLISIS DE ESCENA 3D")
	print("=".repeat(60) + "\n")
	
	# Analizar la raíz de la escena
	analyze_node(get_tree().root)
	
	# Generar reporte
	generate_report()

func analyze_node(node: Node) -> void:
	# Analizar nodo actual
	if node is MeshInstance3D:
		analyze_mesh_instance(node)
	
	if node is StaticBody3D:
		static_bodies += 1
	
	if node is RigidBody3D:
		rigid_bodies += 1
	
	if node is OmniLight3D:
		omni_lights += 1
	
	if node is DirectionalLight3D:
		directional_lights += 1
	
	# Recursivamente analizar hijos
	for child in node.get_children():
		analyze_node(child)

func analyze_mesh_instance(mesh_instance: MeshInstance3D) -> void:
	mesh_count += 1
	
	var mesh = mesh_instance.mesh
	if mesh == null:
		return
	
	# Contar instancias del mismo mesh
	var mesh_name = str(mesh.resource_path)
	if mesh_name == "":
		mesh_name = "internal_mesh_" + str(mesh.get_instance_id())
	
	if mesh_name not in mesh_dict:
		mesh_dict[mesh_name] = {"count": 0, "vertices": 0, "triangles": 0}
	
	mesh_dict[mesh_name]["count"] += 1
	
	# Contar vértices y triángulos
	var surface_count = mesh.get_surface_count()
	for surface_idx in range(surface_count):
		var arrays = mesh.surface_get_arrays(surface_idx)
		var vertices = arrays[ArrayMesh.ARRAY_VERTEX]
		if vertices:
			mesh_dict[mesh_name]["vertices"] += vertices.size()
			total_vertices += vertices.size()
	
	# Contar materiales únicos
	for i in range(surface_count):
		var material = mesh_instance.get_active_material(i)
		if material == null:
			material = mesh_instance.material_override
		
		if material != null:
			var mat_name = str(material.resource_path)
			if mat_name == "":
				mat_name = "internal_mat_" + str(material.get_instance_id())
			
			if mat_name not in material_dict:
				material_dict[mat_name] = {"count": 0, "textures": []}
				# Extraer texturas del material
				extract_textures_from_material(material, mat_name)
			
			material_dict[mat_name]["count"] += 1

func extract_textures_from_material(material: Material, mat_name: String) -> void:
	if material is StandardMaterial3D:
		var std_mat = material as StandardMaterial3D
		
		# Albedo
		if std_mat.albedo_texture:
			register_texture(std_mat.albedo_texture, mat_name, "albedo")
		
		# Normal
		if std_mat.normal_texture:
			register_texture(std_mat.normal_texture, mat_name, "normal")
		
		# Roughness
		if std_mat.roughness_texture:
			register_texture(std_mat.roughness_texture, mat_name, "roughness")
		
		# Metallic
		if std_mat.metallic_texture:
			register_texture(std_mat.metallic_texture, mat_name, "metallic")
		
		# AO
		if std_mat.ao_texture:
			register_texture(std_mat.ao_texture, mat_name, "ao")

func register_texture(texture: Texture2D, mat_name: String, tex_type: String) -> void:
	var tex_name = str(texture.resource_path)
	if tex_name == "":
		tex_name = "internal_tex_" + str(texture.get_instance_id())
	
	if tex_name not in texture_dict:
		texture_dict[tex_name] = {
			"size": texture.get_size(),
			"materials": [],
			"type": tex_type
		}
		texture_count += 1
	
	if mat_name not in texture_dict[tex_name]["materials"]:
		texture_dict[tex_name]["materials"].append(mat_name)

func generate_report() -> void:
	var report = ""
	report += "\n" + "=".repeat(70) + "\n"
	report += "📊 REPORTE DE ANÁLISIS DE ESCENA 3D\n"
	report += "=".repeat(70) + "\n\n"
	
	# RESUMEN GENERAL
	report += "📈 RESUMEN GENERAL:\n"
	report += "-".repeat(70) + "\n"
	report += "Total MeshInstance3D: %d\n" % mesh_count
	report += "Materiales únicos: %d\n" % material_dict.size()
	report += "Texturas únicas: %d\n" % texture_count
	report += "Total vértices: %d\n" % total_vertices
	report += "StaticBody3D: %d\n" % static_bodies
	report += "RigidBody3D: %d\n" % rigid_bodies
	report += "Luces OmniLight3D: %d\n" % omni_lights
	report += "Luces DirectionalLight3D: %d\n" % directional_lights
	report += "\n"
	
	# ANÁLISIS DE MESHES REPETIDOS
	report += "🔄 TOP 10 MESHES MÁS INSTANCIADOS:\n"
	report += "-".repeat(70) + "\n"
	
	var mesh_list = []
	for mesh_name in mesh_dict.keys():
		mesh_list.append({
			"name": mesh_name,
			"count": mesh_dict[mesh_name]["count"],
			"vertices": mesh_dict[mesh_name]["vertices"]
		})
	
	mesh_list.sort_custom(func(a, b): return a["count"] > b["count"])
	
	for i in range(min(10, mesh_list.size())):
		var m = mesh_list[i]
		var optimization_note = ""
		if m["count"] > 20:
			optimization_note = " ⚠️ CANDIDATO PARA MULTIMESH"
		elif m["count"] > 5:
			optimization_note = " ⚡ Considera MultiMesh"
		
		report += "%d. %s x%d (vértices: %d)%s\n" % [
			i+1,
			m["name"].split("/")[-1] if "/" in m["name"] else m["name"],
			m["count"],
			m["vertices"],
			optimization_note
		]
	
	report += "\n"
	
	# ANÁLISIS DE TEXTURAS
	report += "🖼️ INFORMACIÓN DE TEXTURAS:\n"
	report += "-".repeat(70) + "\n"
	
	var texture_list = []
	for tex_name in texture_dict.keys():
		var tex_data = texture_dict[tex_name]
		var size = tex_data["size"]
		var memory_mb = (size.x * size.y * 4) / (1024.0 * 1024.0)  # Aproximado RGBA
		
		texture_list.append({
			"name": tex_name,
			"size": size,
			"memory_mb": memory_mb,
			"material_count": tex_data["materials"].size()
		})
	
	texture_list.sort_custom(func(a, b): return a["memory_mb"] > b["memory_mb"])
	
	var total_texture_memory = 0.0
	report += "Top 15 texturas por consumo de VRAM:\n"
	for i in range(min(15, texture_list.size())):
		var t = texture_list[i]
		total_texture_memory += t["memory_mb"]
		var reuse_note = ""
		if t["material_count"] == 1:
			reuse_note = " ⚠️ Usada en 1 sola imagen"
		
		report += "  %d. %s (%dx%d) = ~%.2f MB%s\n" % [
			i+1,
			t["name"].split("/")[-1] if "/" in t["name"] else t["name"],
			int(t["size"].x),
			int(t["size"].y),
			t["memory_mb"],
			reuse_note
		]
	
	report += "\nMemoria total (texturas): ~%.2f MB\n" % total_texture_memory
	report += "\n"
	
	# ANÁLISIS DE MATERIALES
	report += "🎨 INFORMACIÓN DE MATERIALES:\n"
	report += "-".repeat(70) + "\n"
	report += "Materiales únicos: %d\n" % material_dict.size()
	
	var material_list = []
	for mat_name in material_dict.keys():
		material_list.append({
			"name": mat_name,
			"count": material_dict[mat_name]["count"]
		})
	
	material_list.sort_custom(func(a, b): return a["count"] > b["count"])
	
	report += "\nTop materiales por uso:\n"
	for i in range(min(10, material_list.size())):
		var m = material_list[i]
		report += "  %d. %s x%d instancias\n" % [
			i+1,
			m["name"].split("/")[-1] if "/" in m["name"] else m["name"],
			m["count"]
		]
	
	report += "\n"
	
	# RECOMENDACIONES
	report += "💡 RECOMENDACIONES DE OPTIMIZACIÓN:\n"
	report += "-".repeat(70) + "\n"
	
	# Recomendación 1: MultiMesh
	var multimesh_candidates = mesh_list.filter(func(m): return m["count"] > 20)
	if multimesh_candidates.size() > 0:
		report += "✅ MultiMesh: Tienes %d meshes que aparecen 20+ veces\n" % multimesh_candidates.size()
		report += "   Convertir a MultiMesh podría reducir draw calls significativamente\n\n"
	
	# Recomendación 2: Atlasing
	var single_use_textures = texture_list.filter(func(t): return t["material_count"] == 1)
	if single_use_textures.size() > 10:
		report += "✅ Atlas de Texturas: Tienes %d texturas usadas solo 1 vez\n" % single_use_textures.size()
		report += "   Crear atlas de texturas podría reducir cambios de textura\n\n"
	
	# Recomendación 3: LOD
	if mesh_count > 500:
		report += "✅ LOD (Level of Detail): Con %d meshes, implementar LOD es crucial\n" % mesh_count
		report += "   Para WebGL, especialmente importante reducir vértices en distancia\n\n"
	
	# Recomendación 4: Occlusion Culling
	report += "✅ Occlusion Culling: Con varias salas visibles simultáneamente,\n"
	report += "   implementar occlusion culling es CRÍTICO para WebGL\n\n"
	
	# Recomendación 5: Static Bodies
	if static_bodies < (mesh_count * 0.5):
		report += "⚠️ Física: Solo %.1f%% de meshes tienen StaticBody3D\n" % (static_bodies / float(mesh_count) * 100.0)
		report += "   Para objetos puramente decorativos, evita physics bodies\n\n"
	
	report += "=".repeat(70) + "\n"
	
	# Imprimir en consola
	print(report)
	
	# Guardar a archivo
	var file = FileAccess.open(results_file, FileAccess.WRITE)
	if file:
		file.store_string(report)
		print("\n✅ Reporte guardado en: %s\n" % results_file)
	
	print("🎯 PRÓXIMOS PASOS:")
	print("1. Abre el reporte guardado para ver detalles completos")
	print("2. Prioriza MultiMesh para meshes que se repiten 20+ veces")
	print("3. Crea atlas de texturas para reducir cambios de material")
	print("4. Implementa LOD para meshes complejos")
	print("5. Configura Occlusion Culling por sala")
	print("=".repeat(70) + "\n")
