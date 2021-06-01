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

extends Node
class_name SpellQueue

signal spell_popped(spell)

export (float) var queueSize := 5

var availableSpells: Array = []
var spellQueue: Array = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func init(spells: Array) -> void:
	availableSpells = spells
	while(spellQueue.size() < queueSize):
		spellQueue.push_back(pickRandomSpell(availableSpells))

func pickRandomSpell(spells: Array) -> Spell:
	var randomIndex = rng.randi_range(0, spells.size() - 1)
	return spells[randomIndex]

func pop() -> Spell:
	if spellQueue.size() == 0:
		return null
	var spell = spellQueue.pop_front()
	init(availableSpells)
	emit_signal("spell_popped", spell)
	return spell

func peak() -> Spell:
	if spellQueue.size() == 0:
		return null
	return spellQueue[0]
