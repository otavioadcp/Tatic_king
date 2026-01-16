extends Node2D

var current_hex: Vector2i = Vector2i(-1, -1)
var tile_map_ref: TileMapLayer = null

# Cache da forma para não pedir ao GlobalGrid todo frame
# Usamos 'lazy initialization' (inicializar apenas quando necessário)
@onready var hex_shape: PackedVector2Array = GlobalGrid.get_hexagon_collision_shape()

func update_cursor(hex_coord: Vector2i, tile_map: TileMapLayer):
	if current_hex != hex_coord: # Só redesenha se o hexágono mudar
		current_hex = hex_coord
		tile_map_ref = tile_map
		queue_redraw()
		
func _draw() -> void:
	# Ignora caso o mouse mova, mas permaneça no msm hex
	if current_hex == Vector2i(-1, -1) or tile_map_ref == null:
		return
		
	# 1. Pega a posição central
	var center_pos = tile_map_ref.map_to_local(current_hex)
	
	# 2.Pegamos o "centro" do "current_hex", e movemos o highlight pra ele.
	draw_set_transform(center_pos, 0.0, Vector2.ONE)
	
	# 3. Desenha na origem (0,0), pois o transform já moveu pro exato local
	draw_polyline(hex_shape, Color.YELLOW, 2.0, true)
	
	# Preenchimento transparente no hexagono
	var fill_color = Color(Color.YELLOW, 0.15) # 15% de opacidade
	draw_colored_polygon(hex_shape, fill_color)
