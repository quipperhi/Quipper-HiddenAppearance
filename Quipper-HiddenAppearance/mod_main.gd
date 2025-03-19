extends Node

const QUIPPER_HIDDEN_APPEARANCE_DIR:String = "Quipper-HiddenAppearance/"
const QUIPPER_HIDDEN_APPEARANCE_LOG:String = "Quipper-HiddenAppearance"
const QUIPPER_HIDDEN_APPEARANCE_EVENT_LISTENER_NAME:String = "Quipper-HiddenAppearance-EventListener"

var quipper_hidden_appearance_dir:String = ""
var quipper_hidden_appearance_extensions_dir:String = ""
var quipper_hidden_appearance_translations_dir:String = ""
var quipper_hidden_appearance_supported_languages: Array = ["en", "zh_Hans_CN", "zh_Hant_TW"]

func _init():
	ModLoaderLog.info("Init!", QUIPPER_HIDDEN_APPEARANCE_LOG)
	quipper_hidden_appearance_dir = ModLoaderMod.get_unpacked_dir().plus_file(QUIPPER_HIDDEN_APPEARANCE_DIR)
	quipper_hidden_appearance_extensions_dir = quipper_hidden_appearance_dir.plus_file("extensions")
	quipper_hidden_appearance_translations_dir = quipper_hidden_appearance_dir.plus_file("translations")

	_quipper_hidden_appearance_install_script_extensions()
	_quipper_hidden_appearance_add_translations()

func _ready():
	ModLoaderLog.info("Ready!", QUIPPER_HIDDEN_APPEARANCE_LOG)
	_quipper_hidden_appearance_add_event_listener()

func _quipper_hidden_appearance_add_event_listener() -> void:
	var quipper_hidden_appearance_event_listener_dir:String = quipper_hidden_appearance_dir.plus_file("quipper_hidden_appearance_event_listener.gd")
	var quipper_hidden_appearance_event_listener = load(quipper_hidden_appearance_event_listener_dir).new()
	quipper_hidden_appearance_event_listener.name = QUIPPER_HIDDEN_APPEARANCE_EVENT_LISTENER_NAME
	add_child(quipper_hidden_appearance_event_listener)

func _quipper_hidden_appearance_install_script_extensions() -> void:
	var quipper_hidden_appearance_extensions:Array = [
		"entities/units/player/player.gd",
		"ui/menus/pages/menu_choose_options.gd"
	]

	for quipper_hidden_appearance_extension in quipper_hidden_appearance_extensions:
		ModLoaderMod.install_script_extension(quipper_hidden_appearance_extensions_dir.plus_file(quipper_hidden_appearance_extension))

func _quipper_hidden_appearance_add_translations() -> void:
	for language in quipper_hidden_appearance_supported_languages:
		ModLoaderMod.add_translation(quipper_hidden_appearance_translations_dir.plus_file("Quipper-HiddenAppearance.%s.translation" % language))
