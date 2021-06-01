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
class_name Player

export (Array, Resource) var availableSpells = []
export (float) var maxCharges := 2.0
export (float) var minCharges := 1.0
export (float) var chargesPerTick := 1.0

var isCasting := false
var currentCharges := 0.0
var currentSpellProjectile: SpellProjectile

onready var spellSpawnPoint := $ArmSprite/ProjectileSpawnPoint
onready var arm := $ArmSprite
onready var spellIcon := $SkillIconContainerSprite/SpellIcon
onready var spellQueue := $SpellQueue
onready var castDelay := $CastDelay
onready var chargeSfxPlayer := $ChargeSfxPlayer
onready var releaseSfxPlayer := $ReleaseSfxPlayer

func get_class() -> String:
	return "Player"

func _ready() -> void:
	spellQueue.init(availableSpells)
	spellIcon.texture = spellQueue.peak().iconTexture

func _process(delta: float) -> void:
	chargeSpell(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_handleAction(event)

func _handleAction(event: InputEventKey) -> void:
	if event.is_action_pressed("charge_spell"):
		startChargingSpell()
	if event.is_action_released("charge_spell"):
		releaseSpell()

func startChargingSpell() -> void:
	if hasCastDelay():
		return
	isCasting = true
	currentCharges = minCharges
	var spell: Spell = spellQueue.pop()
	chargeSfxPlayer.stream = spell.chargeSfx
	releaseSfxPlayer.stream = spell.releaseSfx
	chargeSfxPlayer.play()
	currentSpellProjectile = spell.createProjectile(spellSpawnPoint.global_position)
	currentSpellProjectile.scale = Vector2(0.1, 0.1)
	get_tree().current_scene.add_child(currentSpellProjectile)

func releaseSpell() -> void:
	if !isCasting:
		return
	isCasting = false
	chargeSfxPlayer.stop()
	releaseSfxPlayer.play()
	spawnSpellProjectile()
	currentCharges = 0.0
	currentSpellProjectile = null
	castDelay.start()

func spawnSpellProjectile() -> void:
	var direction = Vector2(cos(arm.rotation), sin(arm.rotation))
	currentSpellProjectile.fire(direction * currentSpellProjectile.initialAccelaration * currentCharges)

func chargeSpell(delta: float) -> void:
	if not isCasting:
		return
	currentSpellProjectile.global_position = spellSpawnPoint.global_position
	currentSpellProjectile.rotation = arm.rotation
	currentCharges = clamp(currentCharges + chargesPerTick * delta, minCharges, maxCharges)
	var projectileScale = clamp(currentCharges / maxCharges , 0.1, 1.0)
	currentSpellProjectile.scale = Vector2(projectileScale, projectileScale)

func hasCastDelay() -> bool:
	return castDelay.time_left > 0

func onSpellQueueSpellPopped(_spell: Spell) -> void:
	spellIcon.texture = spellQueue.peak().iconTexture

func disable() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
