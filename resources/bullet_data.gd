
# Creamos un recurso para almacenar ciertos atributos o características que comparten todos los proyectiles
extends Resource
class_name BulletData

#Valores por defecto (luego pueden redefinirse en cada archivo .tres)
@export var speed: float = 120.0 #Velocidad del proyectiles
@export var damage: int = 10 #Daño del proyectil
