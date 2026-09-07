extends Control

const TOPIC_NOTIFICACIONES := "TU_TEMA_PRIVADO"
const INTERVALO_LOGRO := 10
const INTERVALO_NOTIFICACION := 50
const URL_FIREBASE := "https://TU_PROYECTO-default-rtdb.firebaseio.com/contador_global.json"
const URL_AVISTAMIENTOS := "https://TU_PROYECTO-default-rtdb.firebaseio.com/avistamientos.json"
const URL_NOTIFICACIONES := "https://script.google.com/macros/s/TU_IMPLEMENTACION/exec"
const ATLAS_SALCHICHAS := preload("res://assets/salchichas_rareza_atlas.png")
const FUENTE_SALCHICHA := preload("res://Botones/Fredoka-Medium.ttf")
const SONIDOS_RAREZA := {
	"Comun": preload("res://assets/audio/rareza_comun.wav"),
	"Raro": preload("res://assets/audio/rareza_rara.mp3"),
	"Epico": preload("res://assets/audio/rareza_epica.mp3"),
	"Legendario": preload("res://Rare-Achievement-Minecraft-Sound-Effect-_HD_.wav")
}
const COLORES_RAREZA := {
	"Comun": Color("55a9ff"),
	"Raro": Color("63e58c"),
	"Epico": Color("c175ff"),
	"Legendario": Color("ffd45a")
}
const SALCHICHAS := [
	{"nombre": "Rojo", "rareza": "Comun", "celda": Vector2i(0, 0)},
	{"nombre": "Negro", "rareza": "Comun", "celda": Vector2i(1, 0)},
	{"nombre": "Chocolate", "rareza": "Comun", "celda": Vector2i(2, 0)},
	{"nombre": "Negro Fuego", "rareza": "Raro", "celda": Vector2i(3, 0)},
	{"nombre": "Chocolate Fuego", "rareza": "Raro", "celda": Vector2i(0, 1)},
	{"nombre": "Jabali", "rareza": "Raro", "celda": Vector2i(1, 1)},
	{"nombre": "Azul Fuego", "rareza": "Epico", "celda": Vector2i(2, 1)},
	{"nombre": "Dapple", "rareza": "Epico", "celda": Vector2i(3, 1)},
	{"nombre": "Piebald", "rareza": "Epico", "celda": Vector2i(0, 2)},
	{"nombre": "Double Dapple", "rareza": "Legendario", "celda": Vector2i(1, 2)},
	{"nombre": "Goldenchicha", "rareza": "Legendario", "celda": Vector2i(2, 2)}
]
const DURACION_ATRAPA := 20
const RAREZAS_MEMORIA := ["Comun", "Raro", "Epico", "Legendario"]

@onready var musica_fondo: AudioStreamPlayer = $AudioStreamPlayer
@onready var sonido_suma: AudioStreamPlayer = $SonidoSuma
@onready var sonido_resta: AudioStreamPlayer = $SonidoResta
@onready var sonido_fiesta: AudioStreamPlayer2D = $SonidoFiesta
@onready var sonido_rareza: AudioStreamPlayer = $SonidoRareza
@onready var confeti: CPUParticles2D = $Confeti
@onready var fondo: TextureRect = $Fondo
@onready var etiqueta_numero: Label = $Label
@onready var boton_sumar: Button = $Button
@onready var boton_restar: Button = $ButtonResta
@onready var panel_admin: VBoxContainer = $PanelAdmin
@onready var caja_titulo: LineEdit = $PanelAdmin/CajaTitulo
@onready var caja_mensaje: LineEdit = $PanelAdmin/CajaMensaje
@onready var boton_enviar: Button = $PanelAdmin/BotonEnviar
@onready var estado_envio: Label = $PanelAdmin/EstadoEnvio
@onready var notificacion_en_app: PanelContainer = $NotificacionEnApp
@onready var titulo_notificacion: Label = $NotificacionEnApp/Margen/Contenido/Titulo
@onready var cuerpo_notificacion: Label = $NotificacionEnApp/Margen/Contenido/Cuerpo
@onready var http_notificacion: HTTPRequest = $HTTPNotificacion
@onready var http_hito: HTTPRequest = $HTTPHito
@onready var panel_avistamiento: PanelContainer = $PanelAvistamiento
@onready var grilla_colores: GridContainer = $PanelAvistamiento/Margen/Contenido/GrillaColores
@onready var etiqueta_rareza: Label = $PanelAvistamiento/Margen/Contenido/RarezaSeleccionada
@onready var campo_localidad: LineEdit = $PanelAvistamiento/Margen/Contenido/CampoLocalidad
@onready var boton_confirmar_avistamiento: Button = $PanelAvistamiento/Margen/Contenido/Acciones/Confirmar
@onready var boton_cancelar_avistamiento: Button = $PanelAvistamiento/Margen/Contenido/Acciones/Cancelar
@onready var estado_avistamiento: Label = $PanelAvistamiento/Margen/Contenido/Estado
@onready var http_avistamiento: HTTPRequest = $HTTPAvistamiento
@onready var arcade_secreto: PanelContainer = $ArcadeSecreto
@onready var menu_arcade: VBoxContainer = $ArcadeSecreto/Margen/Contenido/MenuArcade
@onready var juego_atrapa: VBoxContainer = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa
@onready var tiempo_atrapa: Label = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa/HUD/Tiempo
@onready var puntaje_atrapa: Label = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa/HUD/Puntaje
@onready var area_atrapa: PanelContainer = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa/AreaAtrapa
@onready var campo_atrapa: Control = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa/AreaAtrapa/Campo
@onready var objetivo_atrapa: Button = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa/AreaAtrapa/Campo/Objetivo
@onready var resultado_atrapa: Label = $ArcadeSecreto/Margen/Contenido/JuegoAtrapa/Resultado
@onready var juego_memoria: VBoxContainer = $ArcadeSecreto/Margen/Contenido/JuegoMemoria
@onready var nivel_memoria: Label = $ArcadeSecreto/Margen/Contenido/JuegoMemoria/Nivel
@onready var instruccion_memoria: Label = $ArcadeSecreto/Margen/Contenido/JuegoMemoria/Instruccion
@onready var resultado_memoria: Label = $ArcadeSecreto/Margen/Contenido/JuegoMemoria/Resultado
@onready var botones_memoria: Array[Button] = [
	$ArcadeSecreto/Margen/Contenido/JuegoMemoria/Grilla/Comun,
	$ArcadeSecreto/Margen/Contenido/JuegoMemoria/Grilla/Raro,
	$ArcadeSecreto/Margen/Contenido/JuegoMemoria/Grilla/Epico,
	$ArcadeSecreto/Margen/Contenido/JuegoMemoria/Grilla/Legendario
]

var contador := 0
var ultimo_hito_celebrado := 0
var ruta_guardado := "user://progreso.dat"
var ruta_preferencias := "user://preferencias.cfg"
var toques_admin := 0
var enviando_notificacion := false
var titulo_envio_pendiente := ""
var mensaje_envio_pendiente := ""
var envio_confirmado_por_fcm := false
var guardando_avistamiento := false
var color_seleccionado := -1
var botones_color: Array[Button] = []
var toques_arcade := 0
var puntaje_juego := 0
var tiempo_juego := 0
var secuencia_memoria: Array[int] = []
var posicion_memoria := 0
var memoria_aceptando := false
var sesion_memoria := 0
var ultimo_toque_arcade_msec := 0

var http_subir := HTTPRequest.new()
var http_bajar := HTTPRequest.new()
var timer_sync := Timer.new()
var timer_reset_toques := Timer.new()
var timer_secreto := Timer.new()
var timer_juego := Timer.new()
var rng := RandomNumberGenerator.new()
var firebase_core
var firebase_messaging
var tween_numero: Tween
var tween_notificacion: Tween
var tween_panel_avistamiento: Tween
var tween_ambiente: Tween
var tween_rareza: Tween


func _ready() -> void:
	cargar_progreso()
	ultimo_hito_celebrado = _hito_actual(contador)
	_actualizar_etiqueta()
	_configurar_interfaz()
	_configurar_avistamientos()
	_configurar_sincronizacion()
	_configurar_arcade()
	_inicializar_firebase()
	_iniciar_animacion_ambiente()
	print("Sistemas basicos en linea. Escuchando la nube...")


func _configurar_interfaz() -> void:
	boton_sumar.pivot_offset = boton_sumar.size * 0.5
	boton_restar.pivot_offset = boton_restar.size * 0.5
	etiqueta_numero.pivot_offset = etiqueta_numero.size * 0.5

	if not boton_sumar.pressed.is_connected(_on_boton_sumar_pressed):
		boton_sumar.pressed.connect(_on_boton_sumar_pressed)
	if not boton_restar.pressed.is_connected(_on_boton_restar_pressed):
		boton_restar.pressed.connect(_on_boton_restar_pressed)
	if not http_notificacion.request_completed.is_connected(_on_notificacion_completada):
		http_notificacion.request_completed.connect(_on_notificacion_completada)
	if not http_hito.request_completed.is_connected(_on_hito_notificacion_completada):
		http_hito.request_completed.connect(_on_hito_notificacion_completada)
	if not boton_confirmar_avistamiento.pressed.is_connected(_on_confirmar_avistamiento):
		boton_confirmar_avistamiento.pressed.connect(_on_confirmar_avistamiento)
	if not boton_cancelar_avistamiento.pressed.is_connected(_on_cancelar_avistamiento):
		boton_cancelar_avistamiento.pressed.connect(_on_cancelar_avistamiento)
	if not http_avistamiento.request_completed.is_connected(_on_avistamiento_guardado):
		http_avistamiento.request_completed.connect(_on_avistamiento_guardado)
	if not musica_fondo.finished.is_connected(_reiniciar_musica):
		musica_fondo.finished.connect(_reiniciar_musica)
	if not musica_fondo.playing:
		musica_fondo.play()

#Porfa, cambiar musica antes que caiga una denuncia por copyright
#Nintendo, no me bajes nada, es un poryecto personal

func _configurar_avistamientos() -> void:
	for indice in SALCHICHAS.size():
		var datos: Dictionary = SALCHICHAS[indice]
		var boton := Button.new()
		var rareza := str(datos["rareza"])
		var color_rareza: Color = COLORES_RAREZA[rareza]
		boton.name = "Color%d" % indice
		boton.text = "%s\n%s" % [datos["nombre"], rareza.to_upper()]
		boton.tooltip_text = "%s · Rareza %s" % [datos["nombre"], rareza]
		boton.custom_minimum_size = Vector2(0, 168)
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.expand_icon = true
		boton.add_theme_constant_override("icon_max_width", 238)
		boton.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.add_theme_font_override("font", FUENTE_SALCHICHA)
		boton.add_theme_font_size_override("font_size", 24 if rareza != "Legendario" else 22)
		boton.add_theme_color_override("font_color", color_rareza)
		boton.add_theme_color_override("font_hover_color", color_rareza.lightened(0.12))
		boton.add_theme_color_override("font_pressed_color", Color.WHITE)
		boton.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.01, 1.0))
		boton.add_theme_constant_override("outline_size", 5 if rareza == "Epico" else (8 if rareza == "Legendario" else 3))
		boton.add_theme_constant_override("h_separation", 8)
		var celda: Vector2i = datos["celda"]
		var icono := AtlasTexture.new()
		icono.atlas = ATLAS_SALCHICHAS
		icono.region = Rect2(celda.x * 384, celda.y * 341, 384, 341)
		icono.filter_clip = true
		boton.icon = icono
		_aplicar_estilo_boton_color(boton, rareza, false)
		boton.pressed.connect(_seleccionar_color.bind(indice))
		grilla_colores.add_child(boton)
		botones_color.append(boton)
	_limpiar_seleccion_color()
	var preferencias := ConfigFile.new()
	if preferencias.load(ruta_preferencias) == OK:
		campo_localidad.text = str(preferencias.get_value("avistamiento", "ultima_localidad", ""))


func _crear_estilo_color(rareza: String, seleccionado: bool, aclarado := false) -> StyleBoxFlat:
	var color: Color = COLORES_RAREZA[rareza]
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.055, 0.035, 0.03, 0.96) if not aclarado else Color(0.13, 0.08, 0.06, 0.98)
	var borde := 7 if seleccionado else 3
	estilo.border_width_left = borde
	estilo.border_width_top = borde
	estilo.border_width_right = borde
	estilo.border_width_bottom = borde
	estilo.border_color = color
	estilo.corner_radius_top_left = 24
	estilo.corner_radius_top_right = 24
	estilo.corner_radius_bottom_left = 24
	estilo.corner_radius_bottom_right = 24
	estilo.shadow_color = Color(color.r, color.g, color.b, 0.48 if seleccionado else 0.16)
	estilo.shadow_size = 16 if seleccionado else 6
	estilo.content_margin_left = 12
	estilo.content_margin_right = 12
	return estilo


func _aplicar_estilo_boton_color(boton: Button, rareza: String, seleccionado: bool) -> void:
	boton.add_theme_stylebox_override("normal", _crear_estilo_color(rareza, seleccionado))
	boton.add_theme_stylebox_override("hover", _crear_estilo_color(rareza, seleccionado, true))
	boton.add_theme_stylebox_override("pressed", _crear_estilo_color(rareza, true, true))
	boton.add_theme_stylebox_override("focus", _crear_estilo_color(rareza, seleccionado))


func _limpiar_seleccion_color() -> void:
	color_seleccionado = -1
	if tween_rareza and tween_rareza.is_valid():
		tween_rareza.kill()
	for indice in botones_color.size():
		var boton := botones_color[indice]
		boton.scale = Vector2.ONE
		boton.rotation = 0.0
		boton.modulate = Color.WHITE
		_aplicar_estilo_boton_color(boton, str(SALCHICHAS[indice]["rareza"]), false)
	etiqueta_rareza.text = "Elegí el pelaje que vieron"
	etiqueta_rareza.add_theme_color_override("font_color", Color(1, 1, 1, 0.82))
	etiqueta_rareza.add_theme_constant_override("outline_size", 2)


func _seleccionar_color(indice: int) -> void:
	if indice < 0 or indice >= SALCHICHAS.size():
		return
	if tween_rareza and tween_rareza.is_valid():
		tween_rareza.kill()
	for boton in botones_color:
		boton.scale = Vector2.ONE
		boton.rotation = 0.0
		boton.modulate = Color.WHITE
	for otro_indice in botones_color.size():
		_aplicar_estilo_boton_color(botones_color[otro_indice], str(SALCHICHAS[otro_indice]["rareza"]), otro_indice == indice)

	color_seleccionado = indice
	var datos: Dictionary = SALCHICHAS[indice]
	var rareza := str(datos["rareza"])
	var color: Color = COLORES_RAREZA[rareza]
	var boton := botones_color[indice]
	boton.pivot_offset = boton.size * 0.5
	etiqueta_rareza.text = "%s · %s" % [datos["nombre"], rareza.to_upper()]
	etiqueta_rareza.add_theme_color_override("font_color", color)
	etiqueta_rareza.add_theme_color_override("font_outline_color", color.darkened(0.75))
	etiqueta_rareza.add_theme_constant_override("outline_size", 8 if rareza == "Legendario" else (5 if rareza == "Epico" else 3))

	sonido_rareza.stream = SONIDOS_RAREZA[rareza]
	sonido_rareza.pitch_scale = {"Comun": 1.05, "Raro": 1.12, "Epico": 1.0, "Legendario": 0.92}[rareza]
	sonido_rareza.play()

#Aqui pongo los mejores perros salchichas, hay que ser cuidadosos
	if rareza == "Legendario":
		tween_rareza = create_tween().set_loops()
		tween_rareza.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_rareza.tween_property(boton, "scale", Vector2(1.045, 1.045), 0.48)
		tween_rareza.parallel().tween_property(boton, "modulate", Color(1.22, 1.12, 0.72, 1), 0.48)
		tween_rareza.tween_property(boton, "scale", Vector2.ONE, 0.48)
		tween_rareza.parallel().tween_property(boton, "modulate", Color.WHITE, 0.48)
	elif rareza == "Epico":
		tween_rareza = create_tween()
		tween_rareza.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween_rareza.tween_property(boton, "scale", Vector2(1.06, 1.06), 0.16)
		tween_rareza.parallel().tween_property(boton, "rotation", deg_to_rad(-2.0), 0.1)
		tween_rareza.tween_property(boton, "rotation", deg_to_rad(2.0), 0.1)
		tween_rareza.tween_property(boton, "rotation", 0.0, 0.1)
		tween_rareza.parallel().tween_property(boton, "scale", Vector2.ONE, 0.24)
	else:
		tween_rareza = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween_rareza.tween_property(boton, "scale", Vector2(1.045, 1.045), 0.12)
		tween_rareza.tween_property(boton, "scale", Vector2.ONE, 0.2)


func _reiniciar_musica() -> void:
	musica_fondo.play()


func _configurar_sincronizacion() -> void:
	add_child(http_subir)
	add_child(http_bajar)
	add_child(timer_sync)
	add_child(timer_reset_toques)

	http_subir.request_completed.connect(_on_subida_completada)
	http_bajar.request_completed.connect(_on_datos_nube_recibidos)

	timer_sync.wait_time = 2.0
	timer_sync.timeout.connect(_preguntar_a_la_nube)
	timer_sync.start()

	timer_reset_toques.wait_time = 2.0
	timer_reset_toques.one_shot = true
	timer_reset_toques.timeout.connect(_reiniciar_toques_admin)


func _configurar_arcade() -> void:
	rng.randomize()
	add_child(timer_secreto)
	add_child(timer_juego)
	timer_secreto.wait_time = 3.0
	timer_secreto.one_shot = true
	timer_secreto.timeout.connect(_reiniciar_toques_arcade)
	timer_juego.wait_time = 1.0
	timer_juego.timeout.connect(_tic_atrapa)

	fondo.mouse_filter = Control.MOUSE_FILTER_PASS
	fondo.gui_input.connect(_on_fondo_gui_input)
	$ArcadeSecreto/Margen/Contenido/Header/CerrarArcade.pressed.connect(_cerrar_arcade)
	$ArcadeSecreto/Margen/Contenido/MenuArcade/BotonAtrapa.pressed.connect(_iniciar_atrapa)
	$ArcadeSecreto/Margen/Contenido/MenuArcade/BotonMemoria.pressed.connect(_iniciar_memoria)
	$ArcadeSecreto/Margen/Contenido/JuegoAtrapa/Volver.pressed.connect(_mostrar_menu_arcade)
	$ArcadeSecreto/Margen/Contenido/JuegoMemoria/Acciones/Volver.pressed.connect(_mostrar_menu_arcade)
	$ArcadeSecreto/Margen/Contenido/JuegoMemoria/Acciones/Reiniciar.pressed.connect(_iniciar_memoria)
	objetivo_atrapa.pressed.connect(_atrapar_salchicha)

	var icono_objetivo := AtlasTexture.new()
	icono_objetivo.atlas = ATLAS_SALCHICHAS
	icono_objetivo.region = Rect2(2 * 384, 2 * 341, 384, 341)
	icono_objetivo.filter_clip = true
	objetivo_atrapa.icon = icono_objetivo
	objetivo_atrapa.expand_icon = true
	objetivo_atrapa.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	objetivo_atrapa.add_theme_constant_override("icon_max_width", 145)
	objetivo_atrapa.add_theme_color_override("font_color", COLORES_RAREZA["Legendario"])
	objetivo_atrapa.add_theme_font_override("font", FUENTE_SALCHICHA)
	_aplicar_estilo_boton_color(objetivo_atrapa, "Legendario", true)

	for indice in botones_memoria.size():
		var rareza := str(RAREZAS_MEMORIA[indice])
		var boton := botones_memoria[indice]
		boton.add_theme_color_override("font_color", COLORES_RAREZA[rareza])
		boton.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.05, 1))
		boton.add_theme_constant_override("outline_size", 8 if rareza == "Legendario" else 5)
		_aplicar_estilo_boton_color(boton, rareza, false)
		boton.pressed.connect(_pulsar_memoria.bind(indice))
	_mostrar_menu_arcade()


func _on_fondo_gui_input(event: InputEvent) -> void:
	var es_toque: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	es_toque = es_toque or (event is InputEventScreenTouch and event.pressed)
	if not es_toque:
		return
	var ahora := Time.get_ticks_msec()
	if ahora - ultimo_toque_arcade_msec < 120:
		return
	ultimo_toque_arcade_msec = ahora
	toques_arcade += 1
	timer_secreto.start()
	if toques_arcade == 3:
		_mostrar_notificacion_en_app("¿Escuchaste eso?", "Hay un secreto escondido entre las huellitas...", 2.0)
	if toques_arcade >= 5:
		toques_arcade = 0
		timer_secreto.stop()
		_abrir_arcade()


func _reiniciar_toques_arcade() -> void:
	toques_arcade = 0


func _abrir_arcade() -> void:
	panel_admin.visible = false
	panel_avistamiento.visible = false
	_mostrar_menu_arcade()
	arcade_secreto.visible = true
	arcade_secreto.pivot_offset = arcade_secreto.size * 0.5
	arcade_secreto.scale = Vector2(0.88, 0.88)
	arcade_secreto.modulate = Color(1, 1, 1, 0)
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(arcade_secreto, "scale", Vector2.ONE, 0.32)
	tween.tween_property(arcade_secreto, "modulate:a", 1.0, 0.22)
	sonido_rareza.stream = SONIDOS_RAREZA["Epico"]
	sonido_rareza.pitch_scale = 1.0
	sonido_rareza.play()


func _cerrar_arcade() -> void:
	timer_juego.stop()
	sesion_memoria += 1
	memoria_aceptando = false
	arcade_secreto.visible = false


func _mostrar_menu_arcade() -> void:
	timer_juego.stop()
	sesion_memoria += 1
	memoria_aceptando = false
	menu_arcade.visible = true
	juego_atrapa.visible = false
	juego_memoria.visible = false


func _iniciar_atrapa() -> void:
	menu_arcade.visible = false
	juego_memoria.visible = false
	juego_atrapa.visible = true
	puntaje_juego = 0
	tiempo_juego = DURACION_ATRAPA
	resultado_atrapa.text = "¡Tocá todos los Goldenchichas que puedas!"
	objetivo_atrapa.visible = true
	_actualizar_hud_atrapa()
	timer_juego.start()
	call_deferred("_mover_objetivo_atrapa")


func _actualizar_hud_atrapa() -> void:
	tiempo_atrapa.text = "Tiempo: %d" % tiempo_juego
	puntaje_atrapa.text = "Atrapados: %d" % puntaje_juego


func _mover_objetivo_atrapa() -> void:
	if not juego_atrapa.visible or not objetivo_atrapa.visible:
		return
	var limite_x := maxf(0.0, campo_atrapa.size.x - objetivo_atrapa.size.x - 18.0)
	var limite_y := maxf(0.0, campo_atrapa.size.y - objetivo_atrapa.size.y - 18.0)
	objetivo_atrapa.position = Vector2(
		rng.randf_range(12.0, maxf(12.0, limite_x)),
		rng.randf_range(12.0, maxf(12.0, limite_y))
	)
	objetivo_atrapa.rotation = rng.randf_range(-0.055, 0.055)


func _atrapar_salchicha() -> void:
	if tiempo_juego <= 0 or timer_juego.is_stopped():
		return
	puntaje_juego += 1
	_actualizar_hud_atrapa()
	sonido_rareza.stream = SONIDOS_RAREZA["Comun" if puntaje_juego % 5 != 0 else "Raro"]
	sonido_rareza.pitch_scale = minf(1.35, 1.0 + puntaje_juego * 0.015)
	sonido_rareza.play()
	_animar_boton(objetivo_atrapa)
	_mover_objetivo_atrapa()


func _tic_atrapa() -> void:
	tiempo_juego -= 1
	_actualizar_hud_atrapa()
	if tiempo_juego <= 0:
		_finalizar_atrapa()


func _finalizar_atrapa() -> void:
	timer_juego.stop()
	objetivo_atrapa.visible = false
	var mensaje := "¡%d Goldenchichas atrapados!" % puntaje_juego
	if puntaje_juego >= 20:
		mensaje += " Reflejos legendarios."
	elif puntaje_juego >= 10:
		mensaje += " ¡Muy buen olfato!"
	else:
		mensaje += " Los salchichas son veloces."
	resultado_atrapa.text = mensaje
	sonido_rareza.stream = SONIDOS_RAREZA["Legendario" if puntaje_juego >= 20 else "Epico"]
	sonido_rareza.pitch_scale = 1.0
	sonido_rareza.play()


func _iniciar_memoria() -> void:
	timer_juego.stop()
	menu_arcade.visible = false
	juego_atrapa.visible = false
	juego_memoria.visible = true
	sesion_memoria += 1
	secuencia_memoria.clear()
	posicion_memoria = 0
	memoria_aceptando = false
	resultado_memoria.text = ""
	_nueva_ronda_memoria(sesion_memoria)


func _nueva_ronda_memoria(id_sesion: int) -> void:
	if id_sesion != sesion_memoria or not juego_memoria.visible:
		return
	secuencia_memoria.append(rng.randi_range(0, RAREZAS_MEMORIA.size() - 1))
	posicion_memoria = 0
	memoria_aceptando = false
	nivel_memoria.text = "Nivel %d" % secuencia_memoria.size()
	instruccion_memoria.text = "Mirá la secuencia..."
	resultado_memoria.text = ""
	await get_tree().create_timer(0.55).timeout
	if id_sesion != sesion_memoria:
		return
	for indice in secuencia_memoria:
		await _destellar_memoria(indice, 0.38, id_sesion)
		await get_tree().create_timer(0.16).timeout
		if id_sesion != sesion_memoria:
			return
	memoria_aceptando = true
	instruccion_memoria.text = "¡Ahora repetila!"


func _destellar_memoria(indice: int, duracion: float, id_sesion: int) -> void:
	if id_sesion != sesion_memoria:
		return
	var boton := botones_memoria[indice]
	var rareza := str(RAREZAS_MEMORIA[indice])
	boton.pivot_offset = boton.size * 0.5
	_aplicar_estilo_boton_color(boton, rareza, true)
	boton.scale = Vector2(1.045, 1.045)
	sonido_rareza.stream = SONIDOS_RAREZA[rareza]
	sonido_rareza.pitch_scale = 1.0
	sonido_rareza.play()
	await get_tree().create_timer(duracion).timeout
	if id_sesion != sesion_memoria:
		return
	boton.scale = Vector2.ONE
	_aplicar_estilo_boton_color(boton, rareza, false)


func _pulsar_memoria(indice: int) -> void:
	if not memoria_aceptando or posicion_memoria >= secuencia_memoria.size():
		return
	var id_sesion := sesion_memoria
	_destellar_memoria(indice, 0.2, id_sesion)
	if indice != secuencia_memoria[posicion_memoria]:
		memoria_aceptando = false
		instruccion_memoria.text = "¡Ups! Esa no era."
		resultado_memoria.text = "Llegaron hasta el nivel %d. ¿Otra vez?" % secuencia_memoria.size()
		sonido_resta.play()
		return
	posicion_memoria += 1
	if posicion_memoria >= secuencia_memoria.size():
		memoria_aceptando = false
		resultado_memoria.text = "¡Secuencia perfecta!"
		_continuar_memoria(id_sesion)


func _continuar_memoria(id_sesion: int) -> void:
	await get_tree().create_timer(0.7).timeout
	if id_sesion == sesion_memoria:
		_nueva_ronda_memoria(id_sesion)


# Firebase Core debe arrancar antes que Messaging. En PC estos singletons no existen.
func _inicializar_firebase() -> void:
	if not Engine.has_singleton("GodotxFirebaseCore"):
		print("Firebase nativo no detectado. Esto es normal al ejecutar en PC.")
		return

	firebase_core = Engine.get_singleton("GodotxFirebaseCore")
	_conectar_senal_si_existe(firebase_core, "core_initialized", _al_inicializar_core)
	_conectar_senal_si_existe(firebase_core, "core_error", _al_error_core)
	firebase_core.initialize()
	print("Encendiendo Firebase Core...")


func _al_inicializar_core(exito: bool) -> void:
	if not exito:
		push_error("Firebase Core no pudo inicializarse.")
		return
	if not Engine.has_singleton("GodotxFirebaseMessaging"):
		push_error("Firebase Messaging no esta incluido en esta compilacion Android.")
		return

	print("Firebase Core: ONLINE")
	firebase_messaging = Engine.get_singleton("GodotxFirebaseMessaging")
	_conectar_senal_si_existe(firebase_messaging, "messaging_permission_granted", _al_otorgar_permiso)
	_conectar_senal_si_existe(firebase_messaging, "messaging_permission_denied", _al_denegar_permiso)
	_conectar_senal_si_existe(firebase_messaging, "messaging_message_received", _al_recibir_mensaje)
	_conectar_senal_si_existe(firebase_messaging, "messaging_token_received", _al_recibir_token)
	_conectar_senal_si_existe(firebase_messaging, "messaging_error", _al_error_messaging)

	firebase_messaging.initialize()
	# Es seguro pedirlo en cada inicio: Android solo muestra el dialogo la primera vez.
	firebase_messaging.request_permission()


func _al_otorgar_permiso() -> void:
	print("Permiso de notificaciones concedido.")
	if firebase_messaging == null:
		return
	firebase_messaging.subscribe_to_topic(TOPIC_NOTIFICACIONES)
	firebase_messaging.get_token()
	print("Suscripcion solicitada al tema: ", TOPIC_NOTIFICACIONES)


func _al_denegar_permiso() -> void:
	push_warning("Las notificaciones estan desactivadas en los ajustes del telefono.")


func _al_error_core(mensaje: String) -> void:
	push_error("Error de Firebase Core: " + mensaje)


func _al_error_messaging(mensaje: String) -> void:
	push_error("Error de Firebase Messaging: " + mensaje)


# Con la app abierta FCM no crea una bandeja del sistema: mostramos un aviso animado propio.
func _al_recibir_mensaje(titulo: String, cuerpo: String) -> void:
	print("Mensaje recibido: ", titulo, " - ", cuerpo)
	_mostrar_notificacion_en_app(titulo, cuerpo)
	_mostrar_notificacion_del_sistema(titulo, cuerpo)
	if titulo == titulo_envio_pendiente and cuerpo == mensaje_envio_pendiente:
		envio_confirmado_por_fcm = true
		enviando_notificacion = false
		boton_enviar.disabled = false
		estado_envio.text = "¡Notificacion enviada y recibida!"
		caja_mensaje.clear()
	Input.vibrate_handheld(350)


func _mostrar_notificacion_del_sistema(titulo: String, cuerpo: String) -> void:
	if OS.get_name() != "Android" or not Engine.has_singleton("JavaClassWrapper"):
		return
	var java_class_wrapper = Engine.get_singleton("JavaClassWrapper")
	var godot_app = java_class_wrapper.wrap("com.godot.game.GodotApp")
	if godot_app:
		godot_app.showSalchichaNotification(titulo, cuerpo)


func _al_recibir_token(token: String) -> void:
	# Solo se registra una parte para poder diagnosticar sin exponer el token completo.
	var resumen := token.left(10) + "..." if token.length() > 10 else token
	print("Token FCM recibido: ", resumen)


func _conectar_senal_si_existe(objeto: Object, nombre: StringName, callback: Callable) -> void:
	if objeto.has_signal(nombre) and not objeto.is_connected(nombre, callback):
		objeto.connect(nombre, callback)


func _subir_a_la_nube() -> void:
	var datos := JSON.stringify({"total": contador})
	var headers := PackedStringArray(["Content-Type: application/json"])
	var error := http_subir.request(URL_FIREBASE, headers, HTTPClient.METHOD_PATCH, datos)
	if error != OK:
		push_warning("No se pudo iniciar la subida del contador: " + error_string(error))


func _preguntar_a_la_nube() -> void:
	if http_bajar.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		var error := http_bajar.request(URL_FIREBASE)
		if error != OK:
			push_warning("No se pudo consultar el contador: " + error_string(error))


func _on_subida_completada(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code >= 200 and response_code < 300:
		print("Subida a la nube OK")
	else:
		push_warning("Error al subir (%d): %s" % [response_code, body.get_string_from_utf8()])


func _on_datos_nube_recibidos(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json is Dictionary and json.has("total"):
		var total_nube := int(json["total"])
		if contador != total_nube:
			var anterior := contador
			contador = total_nube
			_actualizar_etiqueta()
			_animar_numero()
			_comprobar_hito(anterior, contador)
			guardar_progreso()


func _on_boton_sumar_pressed() -> void:
	if guardando_avistamiento:
		return
	_animar_boton(boton_sumar)
	_limpiar_seleccion_color()
	panel_avistamiento.visible = true
	estado_avistamiento.text = ""
	panel_avistamiento.pivot_offset = panel_avistamiento.size * 0.5
	panel_avistamiento.scale = Vector2(0.82, 0.82)
	panel_avistamiento.modulate = Color(1, 1, 1, 0)
	if tween_panel_avistamiento and tween_panel_avistamiento.is_valid():
		tween_panel_avistamiento.kill()
	tween_panel_avistamiento = create_tween().set_parallel(true)
	tween_panel_avistamiento.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_panel_avistamiento.tween_property(panel_avistamiento, "scale", Vector2.ONE, 0.28)
	tween_panel_avistamiento.tween_property(panel_avistamiento, "modulate:a", 1.0, 0.2)


func _on_cancelar_avistamiento() -> void:
	_cerrar_panel_avistamiento()


func _on_confirmar_avistamiento() -> void:
	if guardando_avistamiento:
		return
	if color_seleccionado < 0:
		estado_avistamiento.text = "Elegí primero el pelaje del salchicha."
		_sacudir_panel(panel_avistamiento)
		return
	var localidad := campo_localidad.text.strip_edges()
	if localidad.is_empty():
		estado_avistamiento.text = "Escribi la localidad donde lo vieron."
		_sacudir_panel(panel_avistamiento)
		return

	var datos_color: Dictionary = SALCHICHAS[color_seleccionado]
	var color := str(datos_color["nombre"])
	var rareza := str(datos_color["rareza"])
	_guardar_ultima_localidad(localidad)
	guardando_avistamiento = true
	boton_confirmar_avistamiento.disabled = true
	boton_cancelar_avistamiento.disabled = true
	boton_sumar.disabled = true
	_cerrar_panel_avistamiento()
	# La ficha desaparece antes de sumar para que la celebración se vea completa.
	await get_tree().create_timer(0.24).timeout
	var anterior := contador
	contador += 1
	_actualizar_etiqueta()
	sonido_suma.play()
	_animar_numero()
	_comprobar_hito(anterior, contador)
	_subir_a_la_nube()
	guardar_progreso()
	_enviar_avistamiento(color, localidad, rareza)
	if contador % INTERVALO_NOTIFICACION == 0:
		_solicitar_notificacion_hito(contador)
	_mostrar_notificacion_en_app("¡Salchicha registrado!", "%s · %s · %s" % [color, rareza, localidad], 2.6)


func _enviar_avistamiento(color: String, localidad: String, rareza: String) -> void:
	var datos := JSON.stringify({
		"color": color,
		"rareza": rareza,
		"localidad": localidad,
		"contador_total": contador,
		"fecha_unix": int(Time.get_unix_time_from_system()),
		"plataforma": OS.get_name()
	})
	var headers := PackedStringArray(["Content-Type: application/json"])
	guardando_avistamiento = true
	boton_sumar.disabled = true
	var error := http_avistamiento.request(URL_AVISTAMIENTOS, headers, HTTPClient.METHOD_POST, datos)
	if error != OK:
		guardando_avistamiento = false
		boton_sumar.disabled = false
		boton_confirmar_avistamiento.disabled = false
		boton_cancelar_avistamiento.disabled = false
		push_warning("No se pudo iniciar el guardado del avistamiento: " + error_string(error))


func _on_avistamiento_guardado(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	guardando_avistamiento = false
	boton_sumar.disabled = false
	boton_confirmar_avistamiento.disabled = false
	boton_cancelar_avistamiento.disabled = false
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300:
		print("Avistamiento guardado en Firebase.")
	else:
		push_warning("El conteo se guardo, pero fallo el detalle del avistamiento (%d): %s" % [response_code, body.get_string_from_utf8()])


func _guardar_ultima_localidad(localidad: String) -> void:
	var preferencias := ConfigFile.new()
	preferencias.set_value("avistamiento", "ultima_localidad", localidad)
	preferencias.save(ruta_preferencias)


func _cerrar_panel_avistamiento() -> void:
	if not panel_avistamiento.visible:
		return
	if tween_panel_avistamiento and tween_panel_avistamiento.is_valid():
		tween_panel_avistamiento.kill()
	tween_panel_avistamiento = create_tween().set_parallel(true)
	tween_panel_avistamiento.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween_panel_avistamiento.tween_property(panel_avistamiento, "scale", Vector2(0.88, 0.88), 0.16)
	tween_panel_avistamiento.tween_property(panel_avistamiento, "modulate:a", 0.0, 0.14)
	tween_panel_avistamiento.chain().tween_callback(func(): panel_avistamiento.visible = false)


func _sacudir_panel(panel: Control) -> void:
	var posicion_inicial := panel.position
	var tween := create_tween()
	tween.tween_property(panel, "position:x", posicion_inicial.x - 18.0, 0.05)
	tween.tween_property(panel, "position:x", posicion_inicial.x + 18.0, 0.08)
	tween.tween_property(panel, "position:x", posicion_inicial.x, 0.05)


func _iniciar_animacion_ambiente() -> void:
	tween_ambiente = create_tween().set_loops()
	tween_ambiente.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_ambiente.tween_property(fondo, "modulate", Color(0.94, 0.97, 1.0, 1.0), 3.2)
	tween_ambiente.tween_property(fondo, "modulate", Color.WHITE, 3.2)


func _on_boton_restar_pressed() -> void:
	if contador <= 0:
		return
	contador -= 1
	_actualizar_etiqueta()
	sonido_resta.play()
	_animar_boton(boton_restar)
	_animar_numero()
	_subir_a_la_nube()
	guardar_progreso()


func _actualizar_etiqueta() -> void:
	etiqueta_numero.text = str(contador)


func _hito_actual(valor: int) -> int:
	return int(valor / INTERVALO_LOGRO) * INTERVALO_LOGRO


func _comprobar_hito(anterior: int, nuevo: int) -> void:
	if nuevo <= anterior:
		return
	var hito := _hito_actual(nuevo)
	if hito > 0 and hito > _hito_actual(anterior) and hito > ultimo_hito_celebrado:
		ultimo_hito_celebrado = hito
		_celebrar_hito(hito)


func _celebrar_hito(hito: int) -> void:
	confeti.restart()
	confeti.emitting = true
	sonido_fiesta.play()
	Input.vibrate_handheld(500)
	var titulo := "¡Logro salchicha!"
	var mensajes := [
		"¡%d avistamientos y contando!" % hito,
		"La patrulla salchicha llego a %d." % hito,
		"¡Ya van %d patitas cortas registradas!" % hito,
		"Nivel salchicha %d desbloqueado." % int(hito / INTERVALO_LOGRO)
	]
	if hito % INTERVALO_NOTIFICACION == 0:
		titulo = "¡Hito gigante desbloqueado!"
	_mostrar_notificacion_en_app(titulo, mensajes[int(hito / INTERVALO_LOGRO) % mensajes.size()], 4.0)

	if tween_numero and tween_numero.is_valid():
		tween_numero.kill()
	etiqueta_numero.scale = Vector2.ONE
	etiqueta_numero.rotation = 0.0
	tween_numero = create_tween().set_parallel(true)
	tween_numero.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_numero.tween_property(etiqueta_numero, "scale", Vector2(1.22, 1.22), 0.28)
	tween_numero.tween_property(etiqueta_numero, "rotation", deg_to_rad(4.0), 0.14)
	tween_numero.chain().tween_property(etiqueta_numero, "scale", Vector2.ONE, 0.38)
	tween_numero.chain().tween_property(etiqueta_numero, "rotation", 0.0, 0.2)


func _animar_boton(boton: Control) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(boton, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(boton, "scale", Vector2.ONE, 0.18)


func _animar_numero() -> void:
	if tween_numero and tween_numero.is_valid():
		tween_numero.kill()
	etiqueta_numero.scale = Vector2.ONE
	tween_numero = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_numero.tween_property(etiqueta_numero, "scale", Vector2(1.08, 1.08), 0.1)
	tween_numero.tween_property(etiqueta_numero, "scale", Vector2.ONE, 0.17)


func _mostrar_notificacion_en_app(titulo: String, cuerpo: String, duracion := 5.0) -> void:
	titulo_notificacion.text = titulo if not titulo.strip_edges().is_empty() else "Mensaje salchicha"
	cuerpo_notificacion.text = cuerpo
	notificacion_en_app.visible = true
	notificacion_en_app.modulate = Color(1, 1, 1, 0)
	notificacion_en_app.position.y = -60.0

	if tween_notificacion and tween_notificacion.is_valid():
		tween_notificacion.kill()
	tween_notificacion = create_tween()
	tween_notificacion.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_notificacion.tween_property(notificacion_en_app, "modulate:a", 1.0, 0.22)
	tween_notificacion.parallel().tween_property(notificacion_en_app, "position:y", 0.0, 0.3)
	tween_notificacion.tween_interval(duracion)
	tween_notificacion.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween_notificacion.tween_property(notificacion_en_app, "modulate:a", 0.0, 0.22)
	tween_notificacion.tween_callback(func(): notificacion_en_app.visible = false)


func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toques_admin += 1
		timer_reset_toques.start()
		if toques_admin >= 7:
			panel_admin.visible = true
			estado_envio.text = ""
			caja_mensaje.grab_focus()
			toques_admin = 0


func _reiniciar_toques_admin() -> void:
	toques_admin = 0


func _on_boton_enviar_pressed() -> void:
	if enviando_notificacion:
		return
	var mensaje := caja_mensaje.text.strip_edges()
	if mensaje.is_empty():
		estado_envio.text = "Escribi un mensaje antes de enviarlo."
		return

	var titulo := caja_titulo.text.strip_edges()
	if titulo.is_empty():
		titulo = "Mensaje salchicha"
	titulo_envio_pendiente = titulo
	mensaje_envio_pendiente = mensaje
	envio_confirmado_por_fcm = false
	var datos := JSON.stringify({
		"tipo": "manual",
		"titulo": titulo,
		"mensaje": mensaje
	})
	var headers := PackedStringArray(["Content-Type: application/json"])

	enviando_notificacion = true
	boton_enviar.disabled = true
	estado_envio.text = "Enviando..."
	var error := http_notificacion.request(URL_NOTIFICACIONES, headers, HTTPClient.METHOD_POST, datos)
	if error != OK:
		_finalizar_envio_con_error("No se pudo conectar: " + error_string(error))


func _on_notificacion_completada(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if envio_confirmado_por_fcm:
		enviando_notificacion = false
		boton_enviar.disabled = false
		estado_envio.text = "¡Notificacion enviada y recibida!"
		return
	enviando_notificacion = false
	boton_enviar.disabled = false
	var respuesta := body.get_string_from_utf8()
	var json = JSON.parse_string(respuesta)
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300 and json is Dictionary and bool(json.get("ok", false)):
		estado_envio.text = "¡Notificacion enviada!"
		caja_mensaje.clear()
		print("Servidor de notificaciones: ", respuesta)
	else:
		var detalle := ""
		if json is Dictionary and json.has("error"):
			detalle = " " + str(json["error"])
		elif respuesta.strip_edges().is_empty():
			detalle = " El servidor no devolvio una respuesta."
		else:
			detalle = " Respuesta inesperada del servidor."
		_finalizar_envio_con_error("Error al enviar (%d).%s" % [response_code, detalle])


func _solicitar_notificacion_hito(total: int) -> void:
	if http_hito.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		push_warning("El aviso del hito %d ya tiene otra solicitud en curso." % total)
		return
	var datos := JSON.stringify({
		"tipo": "hito",
		"total": total
	})
	var headers := PackedStringArray(["Content-Type: application/json"])
	var error := http_hito.request(URL_NOTIFICACIONES, headers, HTTPClient.METHOD_POST, datos)
	if error != OK:
		push_warning("No se pudo solicitar la notificacion del hito %d: %s" % [total, error_string(error)])


func _on_hito_notificacion_completada(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var respuesta := body.get_string_from_utf8()
	var json = JSON.parse_string(respuesta)
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300 and json is Dictionary and bool(json.get("ok", false)):
		if bool(json.get("duplicado", false)):
			print("El aviso de este hito ya habia sido enviado.")
		else:
			print("Notificacion automatica de hito enviada: ", respuesta)
		return
	var detalle := str(json.get("error", respuesta)) if json is Dictionary else respuesta
	push_warning("Fallo la notificacion automatica (%d): %s" % [response_code, detalle])


func _finalizar_envio_con_error(mensaje: String) -> void:
	if envio_confirmado_por_fcm:
		estado_envio.text = "¡Notificacion enviada y recibida!"
		return
	enviando_notificacion = false
	boton_enviar.disabled = false
	estado_envio.text = mensaje
	push_warning(mensaje)


func guardar_progreso() -> void:
	var archivo := FileAccess.open(ruta_guardado, FileAccess.WRITE)
	if archivo:
		archivo.store_var(contador)


func cargar_progreso() -> void:
	if FileAccess.file_exists(ruta_guardado):
		var archivo := FileAccess.open(ruta_guardado, FileAccess.READ)
		if archivo:
			contador = maxi(0, int(archivo.get_var()))


# Atajo de diagnostico en PC/Android: clic derecho para volver a solicitar el token.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if firebase_messaging:
			firebase_messaging.get_token()


func _exit_tree() -> void:
	if tween_ambiente and tween_ambiente.is_valid():
		tween_ambiente.kill()

# Si algo no funciona, hay que seguir tirandose al suelo y seguir llorando
