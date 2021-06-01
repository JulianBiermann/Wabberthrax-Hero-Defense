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
class_name MenuPlayer

export (float) var movementSpeed := 200.0

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

func get_class() -> String:
	return "MenuPlayer"

func _process(delta: float) -> void:
	handleInput()
	move(delta)

func handleInput() -> void:
	var xMovement := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var yMovement := Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	direction = Vector2(xMovement, yMovement).normalized()

func move(delta: float) -> void:
	velocity = direction * movementSpeed
	velocity = move_and_slide(velocity, Vector2.UP)

func disable() -> void:
	set_process(false)
	set_physics_process(false)
