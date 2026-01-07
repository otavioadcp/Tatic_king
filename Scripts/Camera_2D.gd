extends Camera2D

# Configurações de Movimento
@export var move_speed: float = 500.0
@export var edge_scroll_margin: float = 20.0
@export var drag_sensitivity: float = 1.0

# Zoom
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var is_dragging: bool = false

# Variável para guardar posição inicial customizada (opcional)
var start_pos_override: Vector2 = Vector2.INF

func _process(delta: float) -> void:
	# Só processa movimento automático se não estiver arrastando
	if not is_dragging:
		handle_edge_scroll(delta)
		handle_keyboard_movement(delta)

func setup_camera(map_pixel_rect: Rect2, margin: float = 200.0, custom_start: Vector2 = Vector2.INF) -> void:
	# 1. Configurar Limites (O Player não sai daqui)
	limit_left = int(map_pixel_rect.position.x - margin)
	limit_top = int(map_pixel_rect.position.y - margin)
	limit_right = int(map_pixel_rect.end.x + margin)
	limit_bottom = int(map_pixel_rect.end.y + margin)
	
	# 2. Definir Ponto Inicial
	if custom_start != Vector2.INF:
		# Se passarmos um ponto especifico, usa ele
		position = custom_start
	else:
		# Padrão: Centraliza no Mapa
		position = map_pixel_rect.get_center()

func _unhandled_input(event: InputEvent) -> void:
	# Zoom (Roda do Mouse)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed)
		
		# Início/Fim do Drag (Botão do Meio)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed # True se apertou, False se soltou

	# Movimento de Drag (Enquanto move o mouse)
	if event is InputEventMouseMotion and is_dragging:
		# Movemos a câmera o oposto do mouse (-relative)
		# Multiplicamos pelo zoom para que a velocidade pareça 1:1 com o chão
		position -= event.relative * drag_sensitivity / zoom.x

func handle_keyboard_movement(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): velocity.x += 1
	if Input.is_action_pressed("ui_left"): velocity.x -= 1
	if Input.is_action_pressed("ui_down"): velocity.y += 1
	if Input.is_action_pressed("ui_up"): velocity.y -= 1
	
	position += velocity * move_speed * delta / zoom.x

func handle_edge_scroll(delta: float) -> void:
	# Se a janela do jogo não estiver em foco, evitamos mover a câmera
	if not get_viewport().has_focus(): return

	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	var velocity = Vector2.ZERO

	# Verifica bordas
	if mouse_pos.x < edge_scroll_margin:
		velocity.x -= 1
	elif mouse_pos.x > screen_size.x - edge_scroll_margin:
		velocity.x += 1
	
	if mouse_pos.y < edge_scroll_margin:
		velocity.y -= 1
	elif mouse_pos.y > screen_size.y - edge_scroll_margin:
		velocity.y += 1
	
	if velocity.length() > 0:
		position += velocity * move_speed * delta / zoom.x

func zoom_camera(amount: float) -> void:
	var old_zoom = zoom.x
	var new_zoom = old_zoom + amount
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	
	if old_zoom == new_zoom:
		return
	
	# 1. Descobrir onde o mouse está na TELA (em pixels, a partir do centro)
	# Isso é infalível, não depende do mundo 2D
	var screen_center = get_viewport_rect().size / 2
	var mouse_screen_position = get_viewport().get_mouse_position()
	var mouse_offset_from_center = mouse_screen_position - screen_center
	
	# 2. Descobrir onde esse ponto é no MUNDO hoje
	# Mundo = Câmera + (OffsetTela / Zoom)
	# (Se tiver rotação, precisamos des-rotacionar o offset)
	var mouse_world_pos = position + (mouse_offset_from_center.rotated(rotation) / old_zoom)
	
	# 3. Aplicar o novo Zoom
	zoom = Vector2(new_zoom, new_zoom)
	
	# 4. Calcular onde a câmera DEVERIA estar para que aquele ponto do mundo
	# continue embaixo do mesmo pixel da tela
	# NovaPosCamera = PontoMundo - (OffsetTela / NovoZoom)
	var required_camera_pos = mouse_world_pos - (mouse_offset_from_center.rotated(rotation) / new_zoom)
	
	# 5. Aplicar a nova posição
	position = required_camera_pos
	
	# Opcional: Se quiser que o zoom force ultrapassar os limites levemente para não perder o foco
	# force_update_scroll()
