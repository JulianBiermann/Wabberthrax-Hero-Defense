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

extends WindowDialog
class_name SettingsDialog

const PERCENTAGE_MULTIPLIER := 100.0
const MASTER_BUS_NAME := "Master"
const SFX_BUS_NAME := "Sound Effects"
const MUSIC_BUS_NAME := "Background Music"

onready var masterVolumeSlider := $GridContainer/MasterVolumeSlider
onready var sfxVolumeSlider := $GridContainer/SFXVolumeSlider
onready var musicVolumeSlider := $GridContainer/MusicVolumeSlider
onready var saveButton := $GridContainer/SaveButton

var initialMasterVolume := 0.0
var initialSFXVolume := 0.0
var initialMusicVolume := 0.0

func _ready() -> void:
	initialMasterVolume = _get_bus_volume(MASTER_BUS_NAME)
	masterVolumeSlider.value = initialMasterVolume
	masterVolumeSlider.connect("value_changed", self, "onMasterVolumeSliderChanged")
	initialSFXVolume = _get_bus_volume(SFX_BUS_NAME)
	sfxVolumeSlider.value = initialSFXVolume
	sfxVolumeSlider.connect("value_changed", self, "onSFXVolumeSliderChanged")
	initialMusicVolume = _get_bus_volume(MUSIC_BUS_NAME)
	musicVolumeSlider.value = initialMusicVolume
	musicVolumeSlider.connect("value_changed", self, "onMusicVolumeSliderChanged")
	get_close_button().connect("pressed", self, "onCancelButtonPressed")

func _get_bus_volume(busName: String) -> float:
	return db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(busName))) * PERCENTAGE_MULTIPLIER

func _set_bus_volume(busName: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear2db(value / PERCENTAGE_MULTIPLIER))

func onMasterVolumeSliderChanged(value: float) -> void:
	_set_bus_volume(MASTER_BUS_NAME, value)
	_enableSaveButton()

func onSFXVolumeSliderChanged(value: float) -> void:
	_set_bus_volume(SFX_BUS_NAME, value)
	_enableSaveButton()

func onMusicVolumeSliderChanged(value: float) -> void:
	_set_bus_volume(MUSIC_BUS_NAME, value)
	_enableSaveButton()

func _enableSaveButton() -> void:
	saveButton.disabled = false

func _disableSaveButton() -> void:
	saveButton.disabled = true

func onSaveButtonPressed() -> void:
	# TODO: Save options to file
	_disableSaveButton()
	initialMasterVolume = _get_bus_volume(MASTER_BUS_NAME)
	initialSFXVolume = _get_bus_volume(SFX_BUS_NAME)
	initialMusicVolume = _get_bus_volume(MUSIC_BUS_NAME)

func onCancelButtonPressed() -> void:
	_disableSaveButton()
	_set_bus_volume(MASTER_BUS_NAME, initialMasterVolume)
	_set_bus_volume(SFX_BUS_NAME, initialSFXVolume)
	_set_bus_volume(MUSIC_BUS_NAME, initialMusicVolume)
	masterVolumeSlider.value = initialMasterVolume
	sfxVolumeSlider.value = initialSFXVolume
	musicVolumeSlider.value = initialMusicVolume
	queue_free()
