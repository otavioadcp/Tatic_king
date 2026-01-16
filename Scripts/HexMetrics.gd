class_name HexMetrics

# Fonte: https://www.redblobgames.com/grids/hexagons/
# Orientação: Pointy-Topped (Topo Pontudo)

# Tamanho do hexágono (do centro até um canto - "Size" no RedBlob)
const SIZE := 64.0

# Fórmula para mapa "Pointy-Topped":
# Width = sqrt(3) * size
# Height = 2 * size

# Usamos esses valores para desenhar ou calcular limites
const WIDTH := SIZE * 1.7320508 # Aprox 110.85
const HEIGHT := SIZE * 2.0      # 128.0

# Dicionário de vizinhos para sistema de coordenadas Axiais (q, r)
# No Godot, com 'Offset Coordinates' (Odd-r ou Even-r), a vizinhança muda
# Mas manteremos a lógica vetorial simples do Godot Tilemap por enquanto
const NEIGHBORS = [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1)
]

# Calcula os cantos para desenhar linhas de debug
# Para Pointy-Topped, o primeiro canto é a 30 graus (ou 0.5 radianos pi)
static func get_corners(center: Vector2) -> PackedVector2Array:
	var corners = PackedVector2Array()
	for i in range(6):
		# No RedBlob, Pointy-topped angles são 30°, 90°, 150°...
		# 30 graus + (60 * i)
		var angle_deg = 30 + (60 * i)
		var angle_rad = deg_to_rad(angle_deg)
		var point = Vector2(
			center.x + SIZE * cos(angle_rad),
			center.y + SIZE * sin(angle_rad)
		)
		corners.append(point)
	return corners
