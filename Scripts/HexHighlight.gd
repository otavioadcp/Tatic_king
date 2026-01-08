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
		
	# 1. Pega o centro do hexágono no mundo
	var center_pos = tile_map_ref.map_to_local(current_hex)
	
	# 2. Define os pontos MANUAIS baseados no tamanho 56x64
	# Topo/Baixo = 32px do centro (Total 64 altura)
	# Lados = 28px do centro (Total 56 largura)
	# "Ombro" (onde começa a reta vertical) = 16px do centro
	
	var local_corners = PackedVector2Array([
		Vector2(0, -32),   # Topo Centro
		Vector2(28, -16),  # Topo Direito
		Vector2(28, 16),   # Baixo Direito
		Vector2(0, 32),    # Baixo Centro
		Vector2(-28, 16),  # Baixo Esquerdo
		Vector2(-28, -16), # Topo Esquerdo
		Vector2(0, -32)    # Repete o Topo para fechar o loop automaticamente
	])
	
	# 3. Aplica o deslocamento (posição no mundo)
	var final_points = PackedVector2Array()
	for p in local_corners:
		final_points.append(p + center_pos)
		
	# 4. Desenha
	# Usando draw_polyline com o último ponto igual ao primeiro, ele fecha o ciclo
	draw_polyline(final_points, Color.YELLOW, 2.0) # Diminuí a espessura para 2.0 pra ficar mais delicado
