@tool
# MapSystem.gd
extends Node2D

# Referência ao nó filho TileMapLayer
@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var highlight_layer: Node2D = $HighlightLayer # Referencia ao novo nó
@onready var debug_layer: Node2D = $DebugLayer 

# Importante: Pegue a referencia da câmera. 
# Se ela for filha do MapSystem, use $RTSCamera2D (ajuste o nome se precisar)
@onready var camera: Camera2D = $Camera2D

# Parâmetros do Mapa (Editáveis no Inspector)
@export var grid_width: int = 20
@export var grid_height: int = 15

# Novo parametro: Ponto de partida customizado (em coordenadas do Grid, ex: 5,5)
# Se deixar (-1, -1), ele centraliza automaticamente.
@export var start_coordinates: Vector2i = Vector2i(-1, -1)

# Controle de Interação
var hovered_hex: Vector2i = Vector2i(-1, -1) # Coordenada inválida inicial


func _ready() -> void:
	generate_grid()
	
	
func generate_grid() -> void:
	tile_map.clear()
	
	# Loop simples para preencher o TileMap
	# O TileMapLayer do Godot já lida com o posicionamento "offset" dos hexágonos
	for x in range(grid_width):
		for y in range(grid_height):
			var coord = Vector2i(x, y)
			# (0, 0) é o ID do atlas source, (0, 0) é a coordenada do tile no atlas
			# Ajuste esses IDs conforme o seu TileSet criado
			tile_map.set_cell(coord, 0, Vector2i(0, 0))
	
	# Inicializa a camada de debug com os dados do mapa atual
	debug_layer.setup(tile_map, grid_width, grid_height)
	
	# --- CONFIGURAÇÃO DA CÂMERA ---
	
	# 1. Calcular o retângulo total do mapa em Pixels
	# get_used_rect() retorna as células (ex: 0,0 até 20,15)
	var used_rect = tile_map.get_used_rect()
	
	# Convertemos o topo-esquerda e baixo-direita para pixels
	var top_left_px = tile_map.map_to_local(used_rect.position)
	var bottom_right_px = tile_map.map_to_local(used_rect.end)
	
	# Criamos um Rect2 com esses valores
	var map_pixel_rect = Rect2(top_left_px, bottom_right_px - top_left_px)
	
	# 2. Verificar se temos um override de posição inicial
	var start_pixel = Vector2.INF
	if start_coordinates != Vector2i(-1, -1):
		# Converte a coordenada do grid (ex: 5,5) para pixels
		start_pixel = tile_map.map_to_local(start_coordinates)
	
	# 3. Manda a câmera se ajustar
	# 500.0 é a margem extra de borda
	if camera.has_method("setup_camera"):
		# Margem de 2000 pixels (ou mais)
		# Isso permite que a câmera saia bastante do mapa para focar num canto
		camera.setup_camera(map_pixel_rect, 2000.0, start_pixel)	
		
	# Força um redesenho para mostrar as coordenadas
	queue_redraw()

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
