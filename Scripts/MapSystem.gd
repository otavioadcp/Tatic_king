@tool
extends Node2D

# Referência ao nó filho TileMapLayer
@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var highlight_layer: Node2D = $HighlightLayer # Layer que faz o highlight do mouse
@onready var debug_layer: Node2D = $DebugLayer #Layer que renderiza as coordenadas de cada hexagono (para debug)

# Pega a referencia da camera, via editor.
@export var camera: Camera2D

# Parâmetros do Mapa (Editáveis no Inspector)
@export var grid_width: int = 70
@export var grid_height: int = 70

# Ponto de partida da camera customizado (em coordenadas do Grid, ex: 5,5)
# Se deixar (-1, -1), ele centraliza automaticamente.
@export var start_coordinates: Vector2i = Vector2i(-1, -1)

# Controle de Interação
var hovered_hex: Vector2i = Vector2i(-1, -1) # Coordenada inválida inicial


# MAPA DE ATLAS. vetores Vector2i(x, y) indicam os tiles que existem no tileset
# Como fiz cada tile em uma coluna, só o primeiro valor (x) está sendo alterado.
const TERRAIN_ATLAS = {
	"GRASS": Vector2i(1, 0),  
	"WATER":      Vector2i(2, 0),
	"FOREST":     Vector2i(3, 0),
	"MOUNTAIN":   Vector2i(4, 0),
	"SAND":       Vector2i(5, 0),
}


# Parametros para gerar mapas.
@export_group("Map Generation")
@export var noise_seed: int = 123
@export var frequency: float = 0.05 # Tente 0.05 a 0.15 para mapas melhores

func _ready() -> void:
	generate_grid()
	
	
func generate_grid() -> void:
	tile_map.clear()
	
	# Gerador de Altitude (Mar vs Terra vs Montanha)
	var alt_noise = FastNoiseLite.new()
	alt_noise.seed = noise_seed
	alt_noise.frequency = frequency
	alt_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	alt_noise.fractal_octaves = 4 # Adiciona detalhes nas bordas
	
	# Gerador de Umidade (Deserto vs Floresta)
	var moisture_noise = FastNoiseLite.new()
	moisture_noise.seed = noise_seed * 10 # Seed diferente
	moisture_noise.frequency = frequency
	moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	for x in range(grid_width):
		for y in range(grid_height):
			var coord = Vector2i(x, y)
			
			# Pegamos os valores (-1.0 a 1.0)
			var elevation = alt_noise.get_noise_2d(x, y)
			var moisture = moisture_noise.get_noise_2d(x, y)
			
			# Decide qual tile usar
			var final_atlas_coord = get_biome_tile(elevation, moisture)
			
			# Pinta o tile (Source ID 0, Atlas Coord calculada)
			tile_map.set_cell(coord, 2, final_atlas_coord)

	# Setup dos sistemas auxiliares
	debug_layer.setup(tile_map, grid_width, grid_height)
	
	# Setup da camera (reutilizando a lógica que fizemos antes)
	var used_rect = tile_map.get_used_rect()
	var map_px_rect = Rect2(tile_map.map_to_local(used_rect.position), tile_map.map_to_local(used_rect.end) - tile_map.map_to_local(used_rect.position))
	if camera.has_method("setup_camera"):
		camera.setup_camera(map_px_rect, 2000.0)

# A Regra de Negócio dos Terrenos
func get_biome_tile(h: float, m: float) -> Vector2i:
	# h = height (altitude), m = moisture (umidade)
	
	# 1. ÁGUA (Altitude muito baixa)
	if h < 0.05:  return TERRAIN_ATLAS["WATER"]
	
	# 2. PRAIA (Transição Terra/Água)
	if h < 0.12: return TERRAIN_ATLAS["SAND"]
	
	# 3. MONTANHA (Altitude muito alta)
	if h > 0.45:
		return TERRAIN_ATLAS["MOUNTAIN"]
	
	# 4. TERRA PLANA (O meio termo)
	# Aqui a umidade define o que é
	if m < -0.3: return TERRAIN_ATLAS["SAND"]   # Deserto
	if m > 0.2:  return TERRAIN_ATLAS["FOREST"] # Floresta
	
	return TERRAIN_ATLAS["GRASS"] # Planície Padrão

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var local_pos = tile_map.get_local_mouse_position()
		var map_coord = tile_map.local_to_map(local_pos)
		
		# Só atualiza se mudou de hexágono E se for válido
		if map_coord != hovered_hex:
			hovered_hex = map_coord
			
			if is_valid_hex(hovered_hex):
				# MANDA O FILHO DESENHAR
				highlight_layer.update_cursor(hovered_hex, tile_map)
			else:
				# Esconde se sair do mapa
				highlight_layer.update_cursor(Vector2i(-1, -1), tile_map)
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Recalculamos a posição no momento do clique para garantir precisão
		# (Ou poderiamos usar o hovered_hex, mas recalcular é mais seguro contra bugs de frame)
		var local_pos = tile_map.get_local_mouse_position()
		var clicked_coord = tile_map.local_to_map(local_pos)
		
		if is_valid_hex(clicked_coord):
			print("Hexágono Clicado: ", clicked_coord)
			# Futuramente aqui entrará: selecionar_unidade(clicked_coord)

# Verifica se a coordenada está dentro dos limites gerados
func is_valid_hex(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < grid_width and coord.y >= 0 and coord.y < grid_height
