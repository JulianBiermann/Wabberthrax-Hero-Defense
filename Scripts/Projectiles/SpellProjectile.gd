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
class_name SpellProjectile

const ON_SPELL_PROJECTILE_HIT_METHOD := "onSpellProjectileHit"

export (float) var gravity := 10.0
export (float) var initialAccelaration := 100.0

var velocity := Vector2.ZERO
var transmutation: Transmutation
var element: int = Element.Type.NEUTRAL

func apply(position: Vector2, element, transmutation: Transmutation) -> void:
	global_position = position
	self.transmutation = transmutation
	self.element = element
	_disable()

func _physics_process(delta: float) -> void:
	_applyGravity(delta)
	_rotateProjectile()
	_applyVelocity(delta)

func _applyGravity(delta: float) -> void:
	velocity.y = velocity.y + gravity

func _rotateProjectile() -> void:
	rotation = velocity.angle()

func _applyVelocity(delta: float) -> void:
	_handleCollision(move_and_collide(velocity * delta))

func _handleCollision(collision: KinematicCollision2D) -> void:
	if collision == null:
		return
	var collider: Node2D = collision.collider
	if collider.has_method(ON_SPELL_PROJECTILE_HIT_METHOD):
		var hasDealtDamage = collider.onSpellProjectileHit(self)
		if hasDealtDamage:
			_transmuteAt(collider.global_position)
	_destroy()

func fire(initialVelocity: Vector2) -> void:
	_enable()
	velocity = initialVelocity

func _transmuteAt(spawnPosition: Vector2) -> void:
	transmutation.apply(spawnPosition)
	get_tree().current_scene.add_child(transmutation)

func _destroy() -> void:
	_disable()
	queue_free()

func _enable() -> void:
	set_physics_process(true)
	set_process(true)

func _disable() -> void:
	set_physics_process(false)
	set_process(false)
