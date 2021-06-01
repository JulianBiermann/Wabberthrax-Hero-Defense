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
class_name Hero

signal killed()

export (float) var movementSpeed := 20.0
export (float) var snapLength := 1.0
export (float) var gravity := 90.0
export (float) var movementSpeedBuff := 5.0
export (float, 0.0, 1.0) var movementSpeedDebuffPercentage = 0.2
export (int) var healthPoints := 1
export (int) var healthPointsBuff := 1
export (Element.Type, FLAGS) var defenseElement = Element.Type.NEUTRAL

var velocity := Vector2.ZERO

onready var sprite := $Sprite
onready var collisionShape := $CollisionShape2D
onready var spriteAnimationPlayer := $SpriteAnimationPlayer
onready var hitAnimationPlayer := $HitAnimationPlayer
onready var buffAudioPlayer := $BuffAudioPlayer

func get_class() -> String:
	return "Hero"

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	velocity.x = Vector2.LEFT.x * movementSpeed
	velocity.y = velocity.y + gravity * delta
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * snapLength, Vector2.UP)

func onGoalEntered() -> void:
	PlayerStatistic.incrementHeroPortalEnteredCount()
	queue_free()

func onSpellProjectileHit(projectile: SpellProjectile) -> bool:
	return handleSpellElement(projectile)

func handleSpellElement(projectile: SpellProjectile) -> bool:
	if Element.isBuffed(projectile.element, defenseElement):
		buff()
		return false
	else:
		return takeDamage(projectile)

func buff() -> void:
	movementSpeed += movementSpeedBuff
	healthPoints += healthPointsBuff
	hitAnimationPlayer.play("buffed")
	buffAudioPlayer.play()

func takeDamage(projectile: SpellProjectile) -> bool:
	healthPoints -= 1
	if isKilled():
		die()
		return true
	else:
		hitAnimationPlayer.play("hit")
		debuff(projectile)
		return false

func isKilled() -> bool:
	return healthPoints <= 0

func debuff(projectile: SpellProjectile) -> void:
	if projectile.element == Element.Type.FROST:
		movementSpeed = movementSpeed * 1.0 - movementSpeedDebuffPercentage
		hitAnimationPlayer.play("freeze")

func die() -> void:
	disable()
	PlayerStatistic.incrementHeroTransmutationCount()
	queue_free()
	emit_signal("killed")

func disable() -> void:
	set_process(false)
	set_physics_process(false)
	sprite.visible = false
	collisionShape.disabled = true

func disableMovement() -> void:
	set_physics_process(false)
	spriteAnimationPlayer.stop()
