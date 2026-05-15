extends Control

const CONFIG_PATH := "user://settings.cfg"

@onready var master_volume: HSlider = (
	$VBoxContainer/HBoxContainer/MasterVolume
)

@onready var music_volume: HSlider = (
	$VBoxContainer/HBoxContainer2/MusicVolume
)

@onready var sfx_volume: HSlider = (
	$VBoxContainer/HBoxContainer3/SFXVolume
)

@onready var fullscreen_toggle: CheckButton = (
	$VBoxContainer/HBoxContainer4/FullScreen
)

@onready var resolution_selector: OptionButton = (
	$VBoxContainer/HBoxContainer5/Resolution
)

@onready var back_button: Button = (
	$VBoxContainer/HBoxContainer6/BackButton
)

var config := ConfigFile.new()

func _ready() -> void:

	_setup_resolutions()

	_load_settings()

	master_volume.value_changed.connect(
		_on_master_changed
	)

	music_volume.value_changed.connect(
		_on_music_changed
	)

	sfx_volume.value_changed.connect(
		_on_sfx_changed
	)

	fullscreen_toggle.toggled.connect(
		_on_fullscreen_toggled
	)

	resolution_selector.item_selected.connect(
		_on_resolution_selected
	)

	back_button.pressed.connect(
		_on_back_pressed
	)

func _setup_resolutions() -> void:

	resolution_selector.clear()

	resolution_selector.add_item("1280x720")
	resolution_selector.add_item("1600x900")
	resolution_selector.add_item("1920x1080")

func _on_master_changed(value: float) -> void:

	var bus := AudioServer.get_bus_index("Master")

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value / 100.0)
	)

	_save_settings()

func _on_music_changed(value: float) -> void:

	var bus := AudioServer.get_bus_index("Music")

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value / 100.0)
	)

	_save_settings()

func _on_sfx_changed(value: float) -> void:

	var bus := AudioServer.get_bus_index("SFX")

	AudioServer.set_bus_volume_db(
		bus,
		linear_to_db(value / 100.0)
	)

	_save_settings()

func _on_fullscreen_toggled(enabled: bool) -> void:

	if enabled:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)

	else:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

	_save_settings()

func _on_resolution_selected(index: int) -> void:

	var resolutions := [
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1920, 1080),
	]

	DisplayServer.window_set_size(
		resolutions[index]
	)

	_save_settings()

func _on_back_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://stages/menu/menu.tscn"
	)

func _save_settings() -> void:

	config.set_value(
		"audio",
		"master",
		master_volume.value
	)

	config.set_value(
		"audio",
		"music",
		music_volume.value
	)

	config.set_value(
		"audio",
		"sfx",
		sfx_volume.value
	)

	config.set_value(
		"video",
		"fullscreen",
		fullscreen_toggle.button_pressed
	)

	config.set_value(
		"video",
		"resolution",
		resolution_selector.selected
	)

	config.save(CONFIG_PATH)

func _load_settings() -> void:

	if config.load(CONFIG_PATH) != OK:
		return

	master_volume.value = config.get_value(
		"audio",
		"master",
		100.0
	)

	music_volume.value = config.get_value(
		"audio",
		"music",
		100.0
	)

	sfx_volume.value = config.get_value(
		"audio",
		"sfx",
		100.0
	)

	fullscreen_toggle.button_pressed = config.get_value(
		"video",
		"fullscreen",
		false
	)

	resolution_selector.selected = config.get_value(
		"video",
		"resolution",
		0
	)

	_on_resolution_selected(
		resolution_selector.selected
	)

	_on_fullscreen_toggled(
		fullscreen_toggle.button_pressed
	)
