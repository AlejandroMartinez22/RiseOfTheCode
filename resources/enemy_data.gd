# Este recurso agrupa diversos atributos que comparten todos los enemigos
# a lo largo del juego. De esta manera se evita repetir código.
# Cuando creamos un archivo .tres (que contiene la info del enemigo), podemos asignar
# desde el inspector todas las características definidas en este recurso.

extends Resource
class_name EnemyData

@export var max_health: int = 10 #Vida máxima del enemigo
@export var speed: float = 50.0 #Velocidad de desplazamiento
@export var attack_range: float = 120.0 #Rango para que el enemigo ataque, que tan lejos o cerca puede atacar
@export var fire_rate: float = 1.5 #Que tan rápido dispara el enemigo
@export var damage: int = 2   #Para ataques cuerpo a cuerpo (algunos enemigos usan este atributo, otros no)

#Probabilidad de soltar corazón (0.0 = nunca, 1.0 = siempre)
@export_range(0.0, 1.0, 0.01)
var heart_drop_chance: float = 0.35
