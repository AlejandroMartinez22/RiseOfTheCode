#Creamos un recurso para alamcenar ciertas variables que comparten todos los proyectiles
#Como la velocidad y el daño que hacen.
extends Resource
class_name BulletData

@export var speed: float = 120.0 #Se asignan valores por defecto que luego se cambiarán
@export var damage: int = 10 #Al crear un archivo .tre
