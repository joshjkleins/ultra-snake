extends Node2D


func explode(amount):
	$CPUParticles2D.amount = amount
	$CPUParticles2D.emitting = true
