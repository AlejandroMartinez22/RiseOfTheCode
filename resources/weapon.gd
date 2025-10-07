# Este recurso define los atributos comunes que comparten todas las armas del juego.
# Cada una tendrá su propio archivo .tres que instancia este recurso,
# donde se asignan sus valores específicos

extends Resource
class_name Weapon

@export var name: String = "Weapon" # Nombre del arma (por ejemplo: "laser_gun").
@export var projectile_scene: PackedScene # Escena del proyectil que dispara esta arma (por ejemplo, una bala o rayo).
@export var shoot_sound: AudioStream # Sonido que se reproduce al disparar el arma.
@export var shoot_anim_prefix: String = "shoot" #Prefijo del nombre de la animación de disparo.
#Permite identificar y reproducir la animación correcta (por ejemplo: "shoot_left", "shoot_right").
@export var shoot_speed_scale: float = 1.0 # Escala de velocidad para la animación de disparo.
@export var pickup_sound: AudioStream # Sonido que se reproduce cuando el jugador recoge el arma del suelo.
