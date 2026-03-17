extends Control

# Variables para guardar lod nodos y el contador
var contador = 0
# ... tus otras variables ...
@onready var confeti = $Confeti
@onready var sonido_fiesta = $SonidoFiesta
var ruta_guardado = "user://progreso.dat"

# Referencias a los nodos de la escena
@onready var etiqueta_numero = $Label #Numero de Salchichas
@onready var boton_sumar = $Button #boton pa sumar
@onready var boton_restar = $ButtonResta #Boton pa restar

# Esta función se ejecuta cuando la escena está lista
func _ready():
	cargar_progreso()
	etiqueta_numero.text = str(contador) # Actualiza el texto inicial

	# Conectamos la señal 'pressed' del botón a nuestra función
	boton_sumar.pressed.connect(self._on_boton_sumar_pressed)
	boton_restar.pressed.connect(self._on_boton_restar_pressed)

# Esta función se llamará cada vez que se presione el botón de sumar salchicha
func _on_boton_sumar_pressed():
	contador += 1 # Aumenta el contador en 1
	etiqueta_numero.text = str(contador) # Actualiza el texto en pantalla
	# El símbolo % (Módulo) nos da el resto de una división.
	# Si contador dividido 50 da resto 0, es un múltiplo (50, 100, 150...)
	if contador % 50 == 0:
		celebrar()
	guardar_progreso()

# Esta función se llamará cada vez que se presione el botón de resta salchicha
func _on_boton_restar_pressed():
	if contador > 0: # <-- Opcional: Evitar que el contador sea negativo
		contador -= 1
	etiqueta_numero.text = str(contador) # Actualiza el texto en pantalla
	guardar_progreso()

# Función para guardar el progreso
func guardar_progreso():
	var archivo = FileAccess.open(ruta_guardado, FileAccess.WRITE)
	archivo.store_var(contador)
	archivo.close()

# Función para cargar el progreso
func cargar_progreso():
	if FileAccess.file_exists(ruta_guardado):
		var archivo = FileAccess.open(ruta_guardado, FileAccess.READ)
		contador = archivo.get_var()
		archivo.close()
# Ahora veamos si funciona, si no funciona la solucion es tirarte en el piso y llorar

func celebrar():
	# Reinicia las partículas para que puedan volver a explotar
	confeti.restart()
	confeti.emitting = true
	
	# Reproduce el sonido
	sonido_fiesta.play()
