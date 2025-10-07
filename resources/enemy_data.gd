# Este recurso define un conjunto de atributos comunes a todos los enemigos. Permite centralizar la configuración 
# de parámetros como vida, velocidad o daño, evitando repetir código.

# Cuando se crea un archivo .tres basado en este recurso, puede configurarse
# desde el inspector para asignar valores específicos a cada tipo de enemigo.
extends Resource
class_name EnemyData

#Valores por defecto (luego pueden redefinirse en cada archivo .tres)
@export var max_health: int = 10       # Vida máxima del enemigo
@export var speed: float = 50.0        # Velocidad de desplazamiento
@export var attack_range: float = 120.0 # Distancia a la que puede atacar
@export var fire_rate: float = 1.5     # Frecuencia de ataque o disparo (segundos entre cada acción)
@export var damage: int = 2            # Daño causado por ataques cuerpo a cuerpo (si aplica)

# Drop del corazón
@export_range(0.0, 1.0, 0.01)
var heart_drop_chance: float = 0.35   # Probabilidad de soltar un corazón al morir (0.0 = nunca, 1.0 = siempre)
