# 🎯 PLAN DE OPTIMIZACIÓN MAESTRO - MUSEO 3D EN GODOT 4.6 WEBGL

## 📊 DIAGNÓSTICO ACTUAL

```
Meshes:           6,804 MeshInstance3D
Materiales:       280 únicos
Texturas:         75 únicas (~192 MB VRAM)
Vértices:         911,488 totales
Draw calls est:   ~1,500-2,000 (CRÍTICO)
FPS target:       60 FPS (smooth)
Plataforma:       WebGL (navegador)
Hardware target:  Gráficos integrados (Dell XPS 2018)
```

## ⚠️ PROBLEMAS CRÍTICOS

| Problema | Impacto | Severidad |
|----------|---------|-----------|
| SIN Occlusion Culling | -50% FPS en web | 🔴 CRÍTICO |
| 6,804 meshes individuales | Draw calls al cielo | 🔴 CRÍTICO |
| 192 MB texturas en VRAM | Crash en bajo-end | 🔴 CRÍTICO |
| MultiMesh no usado | 924 árboles = 924 draw calls | 🔴 CRÍTICO |
| Sin LOD | Objeto lejano = mismo costo que cercano | 🟡 ALTO |
| 33 texturas usadas 1 vez | Desperdicio VRAM | 🟡 ALTO |

---

## 🚀 PLAN DE ACCIÓN (5 FASES)

### **FASE 1: OCCLUSION CULLING (Impacto: -40-60% draw calls)**

**Tiempo: 2-3 horas**
**Impacto: MÁXIMO**

#### Paso 1.1: Configurar Occlusion en Godot
```
Project > Project Settings > Rendering > Occlusion Culling
  - BVH Build Mode = Dynamic
  - Enable Occlusion Culling = true
```

#### Paso 1.2: Usar el script `01_occlusion_culling_setup.gd`
```gdscript
# Crea un nodo vacío en la raíz llamado "OcclusionManager"
# Adjunta el script 01_occlusion_culling_setup.gd
# Ejecuta la escena (F5)
# Se crearán automáticamente oclusores por sala
```

#### Paso 1.3: Verificar en consola
Deberías ver algo como:
```
✅ Oclusores generados: 5-7
```

#### Paso 1.4: Benchmarking
Antes vs después:
- **Antes:** ~1500-2000 draw calls
- **Después:** ~400-600 draw calls (mismo frame)

---

### **FASE 2: MULTIMESH PARA OBJETOS REPETIDOS (Impacto: -30-40% draw calls)**

**Tiempo: 1-2 horas**
**Impacto: ALTO**

#### Problemas que resuelve:
```
tree_3.tscn → 924 instancias = 924 draw calls
tree_2.tscn → 390 instancias = 390 draw calls
tree_1.tscn → 168 instancias = 168 draw calls
Rings.tscn → 718*4 instancias = 2,872 draw calls

TOTAL: 4,470 draw calls solo en 4 tipos de objeto
SOLUCIÓN: MultiMesh = 4 draw calls
AHORRO: 4,466 draw calls 🎉
```

#### Paso 2.1: Usar el script `02_multimesh_converter.gd`
```gdscript
# Crea un nodo vacío en la raíz llamado "MultiMeshConverter"
# Adjunta el script 02_multimesh_converter.gd
# Ejecuta la escena (F5)
# El script identificará automáticamente candidatos
```

#### Paso 2.2: Revisar cambios
```
Candidatos encontrados: 24 meshes con 20+ instancias
MultiMeshInstance3D creadas: ~12-15
```

#### Paso 2.3: Optimizaciones manuales
Para los Rings.tscn (4 meshes con 718 instancias cada uno):
1. Abre cada uno en la escena
2. Aplica el script manualmente si no se detectó
3. Verifica que las posiciones se copien correctamente

#### Paso 2.4: Benchmarking
```
Antes: ~1500-2000 draw calls
Después: ~300-400 draw calls
Mejora: +50-70% FPS estimado
```

---

### **FASE 3: LOD - LEVEL OF DETAIL (Impacto: -20-30% vértices)**

**Tiempo: 1-2 horas**
**Impacto: MEDIO-ALTO**

#### Paso 3.1: Activar LOD en Project Settings
```
Project > Project Settings > Rendering > Meshes
  - Generate LODs = true
  - LOD Sphere Simplify = 0.7 (agresivo para web)
```

#### Paso 3.2: Script de LOD automático (opcional)
```gdscript
# Adjunta el script 03_lod_system.gd a un nodo en la escena
# El script buscará automáticamente meshes con >2000 vértices
# Creará variantes LOD simplificadas
```

#### Paso 3.3: Configurar distancias LOD
Para cada mesh importante, establece:
```
Original: 0-30 unidades
LOD1: 30-100 unidades
(LOD2 solo si vértices extremadamente altos)
```

#### Paso 3.4: Verificar resultados
- Selecciona un objeto lejano
- Acércate lentamente
- Deberías ver cambios sutiles en detalle (no obvios)

---

### **FASE 4: OPTIMIZACIÓN DE TEXTURAS (Impacto: -50 MB VRAM)**

**Tiempo: 2-4 horas**
**Impacto: CRÍTICO para bajo-end**

#### Problema:
```
Khachkar0_uv_map (2).jpg: 4096x1293 = 20.20 MB
Otros Khachkar x6: 12 MB cada uno = 72 MB
Total texturas no-esenciales: ~90 MB (sin beneficio visual en web)
```

#### Paso 4.1: Usar `04_texture_optimization_guide.gd` para ver qué hacer
```gdscript
# Este script detalla exactamente qué optimizar
# Imprime recetas específicas por textura
```

#### Paso 4.2: Cambiar importación de texturas (MANUAL)
Para cada textura en la carpeta de imports:

**Khachkar0_uv_map (2).jpg:**
1. Click derecho → Properties
2. Pestaña "Reimport"
3. Cambios:
   - Texture Type = 2D Texture
   - Compress Mode = VRAM Compressed
   - VRAM Compression = VRAM Compression S3TC/DXT
   - Size Limit = 2048 (reduce 4096→2048 automáticamente)
   - Mipmaps = Enabled
4. "Reimport" button

**Todas las Khachkar (1536x2048):**
1. Idem anterior pero:
   - Size Limit = 1024 (reduce a 1K)
   - Quality = 0.85 (JPG compression)
   - Mipmaps = Enabled

**Ground003_4K (2048x2048):**
1. Si es decoración/background:
   - Size Limit = 1024
   
2. Si es piso principal:
   - Mantener 2K pero con mipmaps + compression

#### Paso 4.3: Crear atlas para texturas pequeñas
Tarea: Consolidar las 33 texturas "usadas 1 sola vez" en un atlas

Opción 1 (Fácil): Usar TexturePacker
- Descarga TexturePacker (tiene trial gratuito)
- Selecciona todas las pequeñas texturas (<1K)
- Export como Godot
- Reimporta en proyecto

Opción 2 (Gratis): Mezclar manualmente en Blender
- Abre Blender
- Textura > UV Editor > UV > Pack Islands
- Export como PNG

#### Paso 4.4: VRAM Compression global
```
Project > Project Settings > Rendering > Textures > VRAM Compression
  - Import ETC2/S3TC = true
  - Default Filter = Linear with Mipmaps
  - Anisotropy = 2.0
```

#### Paso 4.5: Benchmarking VRAM
Antes:
```
Editor > Profiler > Frametime
VRAM Usage: ~192 MB
```

Después (esperado):
```
VRAM Usage: ~80-100 MB (-55%)
```

---

### **FASE 5: CONFIGURACIÓN WEBGL (Impacto: +20-30% FPS)**

**Tiempo: 30 minutos**
**Impacto: CRÍTICO para web**

#### Paso 5.1: Cambiar renderer a "Mobile"
```
Project > Project Settings > Rendering > Textures
  - Renderer = "Mobile" (NO Forward+)
```

#### Paso 5.2: Desactivar efectos costosos
```
Project > Project Settings > Rendering > Screen Space
  - Screen Space Reflection = false
  - SSAO Enabled = false
  - SSIL Enabled = false

Rendering > Lights and Shadows
  - Directional Shadow Size = 512 (no 4096)
  - Soft Shadow Filter Quality = 0 (hard shadows)
  - Use Physical Units = false
```

#### Paso 5.3: Anti-aliasing para WebGL
```
Rendering > Anti Aliasing
  - MSAA 3D = Disabled (muy costoso en web)
  - TAA Enabled = false
  - Use Debanding = false
```

#### Paso 5.4: Shaders optimizados
Reemplaza shaders complejos con el shader de `05_webgl_optimization.gd`:

```gdscript
# Para objetos lejanos, usa shader unlit:
var unlit_shader = WebGLOptimizer.create_webgl_unlit_shader()
var material = ShaderMaterial.new()
material.shader = unlit_shader
```

#### Paso 5.5: Configurar exportación HTML5
```
Project > Export > [Create "Web" preset]

Settings:
  - Custom HTML Shell = (use the template from 05_webgl_optimization.gd)
  - Export Type = Regular
  - Vram Compression > For Desktop = ETC2/S3TC
  - Files > Progressive Web App = true
  - HTML > Progressive Web App = true
```

#### Paso 5.6: Crear archivo HTML optimizado
Copia el template de `05_webgl_optimization.gd` → `custom_web_shell.html`
```
Esto proporciona:
- Progress bar de carga
- Fallback si WebGL no disponible
- Optimizaciones de resolución adaptativa
```

---

## 📈 BENCHMARKING - ANTES vs DESPUÉS

### Métrica: Draw Calls

```
ANTES:
  tree_3: 924 calls
  tree_2: 390 calls
  tree_1: 168 calls
  Rings: 2,872 calls
  Otros meshes: 3,450 calls
  ─────────────────
  TOTAL: ~7,804 draw calls

DESPUÉS (todas las fases):
  tree_3 (MultiMesh): 1 call
  tree_2 (MultiMesh): 1 call
  tree_1 (MultiMesh): 1 call
  Rings (MultiMesh): 4 calls
  Otros (LOD + Culling): ~150 calls
  Occlusion-culled: ~0 (fuera de vista)
  ─────────────────
  TOTAL: ~157 draw calls en viewport típico

MEJORA: -80% draw calls 🎉
IMPACTO FPS: 20-30 → 45-60 FPS (estimado)
```

### Métrica: VRAM

```
ANTES:
  Texturas: 192 MB
  Meshes (vértices): ~140 MB
  Materiales: ~40 MB
  ─────────────────
  TOTAL: ~372 MB

DESPUÉS (todas las fases):
  Texturas (comprimidas): 80-100 MB
  Meshes (LOD+culling): ~40 MB visible
  Materiales (merged): ~15 MB
  ─────────────────
  TOTAL: ~135-155 MB (-60%)
```

### Métrica: FPS en WebGL

```
Target: Dell XPS 13 (2018) con GPU integrada

ANTES:
  Viewport vacío: ~40 FPS
  Museo completo: ~15-20 FPS ❌

DESPUÉS:
  Viewport completo: ~50-60 FPS ✅
  
Mejora: +200% FPS
```

---

## 🔄 ORDEN DE EJECUCIÓN RECOMENDADO

### Día 1: Occlusion + MultiMesh
1. Occlusion Culling (01_occlusion_culling_setup.gd) - **1 hora**
2. MultiMesh Converter (02_multimesh_converter.gd) - **1 hora**
3. Benchmarking - **30 min**
4. Ajustar según resultados - **1 hora**

**Esperado al final:** +40% FPS, -40% draw calls

### Día 2: LOD + Texturas
1. LOD system (03_lod_system.gd) - **1 hora**
2. Texture optimization (04_texture_optimization_guide.gd) - **2-3 horas**
3. Crear atlas de texturas - **1 hora**
4. Benchmarking VRAM - **30 min**

**Esperado al final:** +20% FPS adicional, -50% VRAM

### Día 3: WebGL + Exportación
1. WebGL settings (05_webgl_optimization.gd) - **30 min**
2. Shaders optimizados - **30 min**
3. Exportación y testing - **2 horas**
4. Optimizaciones finales - **1 hora**

**Esperado al final:** +60% FPS en WebGL, lista para producción

---

## ✅ CHECKLIST FINAL

### Antes de exportar a producción:

- [ ] Occlusion Culling configurado y testeado
- [ ] MultiMesh implementado para objetos repetidos
- [ ] LOD activo para meshes complejos
- [ ] Texturas comprimidas y optimizadas
- [ ] VRAM <150 MB
- [ ] Draw calls <300 en viewport típico
- [ ] FPS estable 50-60 en target hardware
- [ ] Renderer = Mobile (no Forward+)
- [ ] MSAA deshabilitado
- [ ] Soft shadows OFF
- [ ] HTML5 export configurado
- [ ] Progressive Web App habilitado
- [ ] Testeado en navegadores (Chrome, Firefox, Safari)
- [ ] Testeado en Dell XPS 2018 (o equivalente)

---

## 🎯 RESULTADOS ESPERADOS

| Métrica | Antes | Después | Mejora |
|---------|-------|---------|--------|
| **FPS (WebGL)** | 15-20 | 50-60 | **+200%** ⭐ |
| **Draw Calls** | ~1,500-2,000 | ~150-300 | **-85%** ⭐ |
| **VRAM** | 192 MB | 80-100 MB | **-50%** |
| **Carga inicial** | ~30s | ~5-10s | **-70%** |
| **Funciona en Papa** | ❌ NO | ✅ SÍ | **✅ CRITICAL** |

---

## 🆘 TROUBLESHOOTING

### Problema: MultiMesh no se ve
**Solución:**
1. Verifica que el material se haya copiado correctamente
2. Revisa cull_mask del MultiMeshInstance3D
3. Comprueba que el original mesh_instance esté oculto

### Problema: LOD muy agresivo (se ve mal)
**Solución:**
1. Aumenta `lod_distance_ratios` en 03_lod_system.gd
2. Reduce `simplification_threshold` para menos agresión
3. Desactiva LOD para objetos en primer plano

### Problema: Occlusion Culling culls cosas que no debería
**Solución:**
1. Los oclusores pueden ser demasiado pequeños
2. Aumenta el size de oclusores en 01_occlusion_culling_setup.gd
3. O coloca oclusores manualmente en puertas/entradas

### Problema: Texturas se ven pixeladas
**Solución:**
1. La compresión fue muy agresiva
2. Aumenta `Size Limit` en importación (2048 en lugar de 1024)
3. O reduce `Quality` de JPG a 0.90-0.95

### Problema: WebGL crashea en bajo-end
**Solución:**
1. Reduce Size Limit a 512px para texturas no-críticas
2. Desactiva LOD completamente
3. Aumenta distancia de Occlusion Culling
4. Usa shader unlit para todos los objetos lejanos

---

## 📚 RECURSOS ADICIONALES

- **Documentación Godot 4.6 LOD:** https://docs.godotengine.org/en/4.6/tutorials/3d/using_3d_characters/creating_3d_characters.html#lod
- **WebGL Best Practices:** https://docs.godotengine.org/en/4.6/getting_started/introduction/first_3d_game/05_using_3d_models.html
- **Occlusion Culling Guide:** https://docs.godotengine.org/en/4.6/tutorials/3d/occlusion_culling.html
- **MultiMesh Tutorial:** https://docs.godotengine.org/en/4.6/tutorials/3d/using_3d_models/meshes/mesh_optimization/using_multimesh.html

---

## 🎉 ¡LISTO!

Sigue este plan paso a paso y tu museo pasará de un juego injugable a **60 FPS suave en WebGL** 🚀

**Tiempo total estimado:** 8-10 horas
**Resultado:** Juego playable en cualquier navegador, incluso en hardware bajo-end

¡Mucho éxito con la optimización! 💪
