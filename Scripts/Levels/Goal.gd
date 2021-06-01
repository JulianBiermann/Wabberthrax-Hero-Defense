# MIT License
#
# Copyright (c) 2021 Julian Biermann (https://github.com/JulianBiermann/Wabberthrax-Hero-Defense)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Area2D
class_name Goal, "res://Sprites/Level/blue-portal.png"

signal hero_entered()
signal portal_destroyed()

const ON_GOAL_ENTERED_METHOD := "onGoalEntered"

export (int) var healthPoints := 5

onready var enteringParticles := $EnteringParticles
onready var sprite := $Sprite
onready var audio := $AudioStreamPlayer

var opacityLossPerHealthPointLost := 1.0 / healthPoints

func on_body_entered(body: Node) -> void:
	if body.has_method(ON_GOAL_ENTERED_METHOD):
		body.onGoalEntered()
	enteringParticles.emitting = true
	enteringParticles.restart()
	takeDamage()
	reduceOpacity()
	emit_signal("hero_entered")

func takeDamage() -> void:
	healthPoints = clamp(healthPoints - 1, 0, healthPoints)
	audio.play()
	checkIsAlive()

func checkIsAlive() -> void:
	if healthPoints <= 0:
		emit_signal("portal_destroyed")

func reduceOpacity() -> void:
	sprite.modulate.a -= opacityLossPerHealthPointLost
