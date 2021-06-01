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

extends KinematicBody2D
class_name Transmutation

export (Vector2) var initialVelocity := Vector2.UP
export (Vector2) var gravity := Vector2.UP * 9.8
export (float) var rotationDegrees := 0.0
export (float) var lifetime := 5

var velocity := Vector2.ZERO
var playAudio := true

onready var audioPlayer := $AudioStreamPlayer
onready var smokeParticles := $SmokeParticles

func apply(initialPosition: Vector2, shouldPlayAudioOnSpawn := true) -> void:
	global_position = initialPosition
	playAudio = shouldPlayAudioOnSpawn

func _ready() -> void:
	velocity = initialVelocity
	if playAudio:
		audioPlayer.play()
	smokeParticles.emitting = true
	var timer := get_tree().create_timer(lifetime)
	timer.connect("timeout", self, "_onLifetimeTimerTimeout")

func _process(delta: float) -> void:
	rotate(deg2rad(rotationDegrees))
	velocity += gravity * delta
	move_and_collide(velocity * delta)

func _onLifetimeTimerTimeout() -> void:
	queue_free()
