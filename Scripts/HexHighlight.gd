# MapCursor.gd
extends Node2D

var current_hex: Vector2i = Vector2i(-1, -1)
var tile_map_ref: TileMapLayer = null

func update_cursor(hex_coord: Vector2i, tile_map: TileMapLayer):
	current_hex = hex_coord
	tile_map_ref = tile_map
	queue_redraw() # Força o Godot a rodar o _draw() de novo

func _draw() -> void:
	if current_hex == Vector2i(-1, -1) or tile_map_ref == null:
		return
		
	# Pega o centro do hexágono baseado no TileMap
	var center_pos = tile_map_ref.map_to_local(current_hex)
	
	# Usa nossa matemática para achar os cantos
	var corners = HexMetrics.get_corners(Vector2.ZERO) # Pega cantos locais (relativo ao centro 0,0)
	
	# Ajusta a posição para onde o nó está
	# Como este nó (HighlightLayer) estará na posição 0,0 do mundo, 
	# precisamos desenhar o poligono deslocado para 'center_pos'
	var offset_corners = PackedVector2Array()
	for p in corners:
		offset_corners.append(p + center_pos)
		
	# Desenha
	draw_polyline(offset_corners, Color.YELLOW, 4.0)
	draw_line(offset_corners[-1], offset_corners[0], Color.YELLOW, 4.0)
