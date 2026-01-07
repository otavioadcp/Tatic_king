@tool
extends Node2D

var tile_map_ref: TileMapLayer
var grid_w: int
var grid_h: int
var _initialized: bool = false

func setup(tm: TileMapLayer, w: int, h: int) -> void:
	tile_map_ref = tm
	grid_w = w
	grid_h = h
	_initialized = true
	queue_redraw() # Pede para desenhar assim que tiver os dados

func _draw() -> void:
	if not _initialized: return
	
	var font = ThemeDB.fallback_font
	var font_size = 16
	var color = Color.BLACK # Ou Color.WHITE se seu mapa for escuro
	
	for x in range(grid_w):
		for y in range(grid_h):
			var cell_coord = Vector2i(x, y)
			var cell_pos = tile_map_ref.map_to_local(cell_coord)
			
			# Ajuste o Vector2(-15, 5) se o texto não ficar perfeitamente no centro
			draw_string(font, cell_pos + Vector2(-12, 6), str(x) + "," + str(y), HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)
