class_name GlobalGrid extends Node

const TILE_HEIGHT: float = 64.0
const TILE_WIDTH: float = 56.0


# Abordagem profissional: Uma função que retorna a forma pronta
static func get_hexagon_collision_shape() -> PackedVector2Array:
	# 56x64 = É o tamanho que os tiles foram desenhanos para ser um hexagono "perfeito"
	
	# 1. Define os pontos MANUAIS baseados no tamanho 56x64
	# Topo/Baixo = 32px do centro (Total 64 altura)
	# Lados = 28px do centro (Total 56 largura)
	# "Ombro" (onde começa a reta vertical) = 16px do centro
	
	
	var w2 = TILE_WIDTH / 2.0
	var h2 = TILE_HEIGHT / 2.0
	var h4 = TILE_HEIGHT / 4.0
	
	# Construímos o array usando lógica geométrica clara
	return PackedVector2Array([
		Vector2(0, -h2),   # Topo Centro
		Vector2(w2, -h4),  # Topo Direito
		Vector2(w2, h4),   # Baixo Direito
		Vector2(0, h2),    # Baixo Centro
		Vector2(-w2, h4),  # Baixo Esquerdo
		Vector2(-w2, -h4), # Topo Esquerdo
		Vector2(0, -h2)    # Fechamento
	])
