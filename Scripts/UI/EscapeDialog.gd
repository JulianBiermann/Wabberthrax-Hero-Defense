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

extends PopupDialog
class_name EscapeDialog

func _ready() -> void:
	_pause()

func onResumeButtonPressed() -> void:
	_unpause()
	queue_free()

func onSettingsButtonPressed() -> void:
	var settingsDialogScene := load("res://Scenes/Levels/SettingsDialog.tscn") as PackedScene
	var settingsDialog: SettingsDialog = settingsDialogScene.instance()
	add_child(settingsDialog)
	settingsDialog.popup_centered()

func onExitToMenuButtonPressed() -> void:
	_unpause()
	TransitionLayer.fadeIn()
	yield(TransitionLayer, "fade_in_finished")
	get_tree().change_scene("res://Scenes/Levels/MainMenu.tscn")
	queue_free()

func onExitGameButtonPressed() -> void:
	_unpause()
	TransitionLayer.fadeIn()
	yield(TransitionLayer, "fade_in_finished")
	get_tree().quit()
	queue_free()

func _pause() -> void:
	get_tree().paused = true

func _unpause() -> void:
	get_tree().paused = false
