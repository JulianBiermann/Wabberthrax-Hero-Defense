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

extends Node2D
class_name Level

const EscapeDialogScene: PackedScene = preload("res://Scenes/Levels/EscapeDialog.tscn")

export (NodePath) var heroGoalPath
export (Array, NodePath) var heroSpawnPaths
export (PackedScene) var nextLevelScene
export (PackedScene) var looseScene
export (PackedScene) var winLooseTransition
export (int) var requiredHeroKills := 10

onready var heroGoal: Goal = get_node(heroGoalPath)

var currentHeroKills := 0
var currentHeroEnterings := 0

func _ready() -> void:
	if not BGMAudioStreamPlayer.playing:
		BGMAudioStreamPlayer.play()
	TransitionLayer.fadeOut()
	yield(TransitionLayer, "fade_out_finished")
	registerHeroSpawnedSignals()
	registerPortalDestroyedSignal()

func registerHeroSpawnedSignals() -> void:
	for path in heroSpawnPaths:
		get_node(path).connect("hero_spawned", self, "onHeroSpawnHeroSpawned")

func registerPortalDestroyedSignal() -> void:
	heroGoal.connect("portal_destroyed", self, "onPortalDestroyed")

func _input(event: InputEvent) -> void:
	handleQuitEvent(event)

func handleQuitEvent(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		_showEscapeDialog()

func onHeroSpawnHeroSpawned(hero: Hero) -> void:
	hero.connect("killed", self, "onHeroKilled")

func onHeroKilled() -> void:
	currentHeroKills += 1
	checkWinCondition()

func onPortalDestroyed() -> void:
	loose()

func checkWinCondition() -> void:
	if currentHeroKills == requiredHeroKills:
		win()

func win() -> void:
	deactivateSpawns()
	transmuteRemainingHeroes()
	getPlayerNode().disable()
	LevelManager.currentLevel = nextLevelScene
	changeLevel(nextLevelScene)

func deactivateSpawns() -> void:
	for path in heroSpawnPaths:
		get_node(path).disable()

func transmuteRemainingHeroes() -> void:
	var count = 0
	for hero in getHeroNodes():
		var transmutation: Transmutation = winLooseTransition.instance()
		if count == 0:
			transmutation.apply(hero.global_position, true)
		else:
			transmutation.apply(hero.global_position, false)
		add_child(transmutation)
		hero.queue_free()
		count += 1

func getHeroNodes() -> Array:
	var heroNodes = []
	for node in get_children():
		var typedNode = node as Node
		if typedNode.get_class() == "Hero" and not typedNode.is_queued_for_deletion():
			heroNodes.append(typedNode)
	return heroNodes

func getPlayerNode() -> Player:
	for node in get_children():
		var typedNode = node as Node
		if typedNode.get_class() == "Player":
			return typedNode
	return null

func loose() -> void:
	deactivateSpawns()
	deactivateHeroMovements()
	transmutePlayer()
	BGMAudioStreamPlayer.stop()
	changeLevel(looseScene)

func deactivateHeroMovements() -> void:
	for hero in getHeroNodes():
		var typeHero: Hero = hero
		typeHero.disableMovement()

func transmutePlayer() -> void:
	var player: Player = getPlayerNode()
	var transmutation: Transmutation = winLooseTransition.instance()
	transmutation.apply(player.global_position)
	call_deferred("add_child", transmutation)
	player.disable()
	player.queue_free()

func changeLevel(nextLevelScene: PackedScene, delay := 0.5) -> void:
	yield(get_tree().create_timer(delay), "timeout")
	TransitionLayer.fadeIn()
	yield(TransitionLayer, "fade_in_finished")
	get_tree().change_scene_to(nextLevelScene)

func _showEscapeDialog() -> void:
	var dialog = EscapeDialogScene.instance()
	UILayer.rootControl.add_child(dialog)
	dialog.popup_centered()
