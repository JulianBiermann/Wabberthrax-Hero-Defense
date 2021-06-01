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

extends Sprite
class_name Spawn, "res://Sprites/Level/door.png"

signal hero_spawned(hero)

export (Array, PackedScene) var spawnableHeroScenes = []
export (float) var minSpawnDelay := 2.0
export (float) var maxSpawnDelay := 3.0

onready var timer := $Timer

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	randomizeSpawnDelay()

func on_timer_timeout() -> void:
	spawnRandomObject()
	randomizeSpawnDelay()

func spawnRandomObject() -> void:
	if (spawnableHeroScenes.size() == 0):
		return
	var randomIndex = rng.randi_range(0, spawnableHeroScenes.size() - 1)
	var randomHeroScene: PackedScene = spawnableHeroScenes[randomIndex]
	var randomHero: Hero = randomHeroScene.instance()
	randomHero.global_position = global_position
	get_tree().current_scene.add_child(randomHero)
	emit_signal("hero_spawned", randomHero)

func randomizeSpawnDelay() -> void:
	timer.wait_time = rng.randf_range(minSpawnDelay, maxSpawnDelay)

func disable() -> void:
	timer.stop()
