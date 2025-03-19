class_name QuipperHiddenAppearanceEventListener
extends Node

signal quipper_hidden_appearance_setting_changed(player_index, value, is_coop)

const QUIPPER_HIDDEN_APPEARANCE_MODOPTIONS_MOD:String = "dami-ModOptions"
const QUIPPER_HIDDEN_APPEARANCE_CONFIG_NAME:String = "hidden_appearance_config"
const QUIPPER_HIDDEN_APPEARANCE_CONFIG_FOLDER_NAME:String = "ha_config"
const QUIPPER_HIDDEN_APPEARANCE_LOG:String = "Quipper-HiddenAppearance"

const QUIPPER_HIDDEN_APPEARANCE_SHOW_OPTIONS:String = "QUIPPER_HIDDEN_APPEARANCE_SHOW_OPTIONS"
const QUIPPER_HIDDEN_APPEARANCE_PLAYER_1_SETTINGS_HIDDEN:String = "QUIPPER_HIDDEN_APPEARANCE_PLAYER_1_SETTINGS_HIDDEN"
const QUIPPER_HIDDEN_APPEARANCE_PLAYER_2_SETTINGS_HIDDEN:String = "QUIPPER_HIDDEN_APPEARANCE_PLAYER_2_SETTINGS_HIDDEN"
const QUIPPER_HIDDEN_APPEARANCE_PLAYER_3_SETTINGS_HIDDEN:String = "QUIPPER_HIDDEN_APPEARANCE_PLAYER_3_SETTINGS_HIDDEN"
const QUIPPER_HIDDEN_APPEARANCE_PLAYER_4_SETTINGS_HIDDEN:String = "QUIPPER_HIDDEN_APPEARANCE_PLAYER_4_SETTINGS_HIDDEN"
const QUIPPER_HIDDEN_APPEARANCE_SOLO_SETTINGS_HIDDEN:String = "QUIPPER_HIDDEN_APPEARANCE_SOLO_SETTINGS_HIDDEN"

const QUIPPER_HIDDEN_APPEARANCE_DEFAULT_SETTINGS:Dictionary = {
	QUIPPER_HIDDEN_APPEARANCE_SHOW_OPTIONS : true,
	QUIPPER_HIDDEN_APPEARANCE_PLAYER_1_SETTINGS_HIDDEN : true,
	QUIPPER_HIDDEN_APPEARANCE_PLAYER_2_SETTINGS_HIDDEN : true,
	QUIPPER_HIDDEN_APPEARANCE_PLAYER_3_SETTINGS_HIDDEN : true,
	QUIPPER_HIDDEN_APPEARANCE_PLAYER_4_SETTINGS_HIDDEN : true,
	QUIPPER_HIDDEN_APPEARANCE_SOLO_SETTINGS_HIDDEN : true,
}

var quipper_hidden_appearance_save_path:String = ""
var quipper_hidden_appearance_settings_dict:Dictionary = QUIPPER_HIDDEN_APPEARANCE_DEFAULT_SETTINGS.duplicate()
var quipper_hidden_appearance_is_mod_options_loaded:bool = false
var quipper_hidden_appearance_setting_container:VBoxContainer = null

func _ready():
	call_deferred("_load_quipper_hidden_appearance_settings")
	call_deferred("_save_quipper_hidden_appearance_settings")

func quipper_hidden_appearance_get_setting(player_index:int, is_coop:bool) -> bool:
	if !is_coop:
		return quipper_hidden_appearance_settings_dict[QUIPPER_HIDDEN_APPEARANCE_SOLO_SETTINGS_HIDDEN]
	match player_index:
		0:
			return quipper_hidden_appearance_settings_dict[QUIPPER_HIDDEN_APPEARANCE_PLAYER_1_SETTINGS_HIDDEN]
		1:
			return quipper_hidden_appearance_settings_dict[QUIPPER_HIDDEN_APPEARANCE_PLAYER_2_SETTINGS_HIDDEN]
		2:
			return quipper_hidden_appearance_settings_dict[QUIPPER_HIDDEN_APPEARANCE_PLAYER_3_SETTINGS_HIDDEN]
		3:
			return quipper_hidden_appearance_settings_dict[QUIPPER_HIDDEN_APPEARANCE_PLAYER_4_SETTINGS_HIDDEN]
	return true

func _quipper_hidden_appearance_on_setting_changed(setting_name:String, value:bool, mod_name:String) -> void:
	if mod_name != QUIPPER_HIDDEN_APPEARANCE_LOG:
		return
	
	quipper_hidden_appearance_settings_dict[setting_name] = value

	match setting_name:
		QUIPPER_HIDDEN_APPEARANCE_SHOW_OPTIONS:
			_quipper_hidden_appearance_set_collapse_setting(value)
		QUIPPER_HIDDEN_APPEARANCE_PLAYER_1_SETTINGS_HIDDEN:
			emit_signal("quipper_hidden_appearance_setting_changed", 0, value, true)
		QUIPPER_HIDDEN_APPEARANCE_PLAYER_2_SETTINGS_HIDDEN:
			emit_signal("quipper_hidden_appearance_setting_changed", 1, value, true)
		QUIPPER_HIDDEN_APPEARANCE_PLAYER_3_SETTINGS_HIDDEN:
			emit_signal("quipper_hidden_appearance_setting_changed", 2, value, true)
		QUIPPER_HIDDEN_APPEARANCE_PLAYER_4_SETTINGS_HIDDEN:
			emit_signal("quipper_hidden_appearance_setting_changed", 3, value, true)
		QUIPPER_HIDDEN_APPEARANCE_SOLO_SETTINGS_HIDDEN:
			emit_signal("quipper_hidden_appearance_setting_changed", 0, value, false)

	_save_quipper_hidden_appearance_settings()

func _save_quipper_hidden_appearance_settings() -> void:
	if quipper_hidden_appearance_save_path.empty():
		return
    
	var file_dir:String = quipper_hidden_appearance_save_path.get_base_dir()
	var dir:Directory = Directory.new()

	if !dir.dir_exists(file_dir):
		var make_dir:int = dir.make_dir_recursive(file_dir)
		if make_dir != OK:
			ModLoaderLog.info("Encountered an error (%s) when attempting to create a directory, with the path: %s" % [make_dir, file_dir], QUIPPER_HIDDEN_APPEARANCE_LOG)
			return

	var file:File = File.new()
	var file_open:int = file.open(quipper_hidden_appearance_save_path, File.WRITE)

	if file_open != OK:
		ModLoaderLog.info("Encountered an error (%s) when attempting to write to a file, with the path: %s" % [file_open, quipper_hidden_appearance_save_path], QUIPPER_HIDDEN_APPEARANCE_LOG)
		return
	
	var content:String = to_json(quipper_hidden_appearance_settings_dict)
	file.store_string(content)
	file.flush()
	file.close()

func _load_quipper_hidden_appearance_settings() -> void:
	quipper_hidden_appearance_is_mod_options_loaded = ModLoaderMod.is_mod_loaded(QUIPPER_HIDDEN_APPEARANCE_MODOPTIONS_MOD)
	var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	
	if ModsConfigInterface == null or !is_instance_valid(ModsConfigInterface):
		return
	
	_quipper_hidden_appearance_get_save_path()

	if _quipper_hidden_appearance_has_config_file():
		var load_settings_dict:Dictionary = _quipper_hidden_appearance_load_dict_from_json_file()
		_quipper_hidden_appearance_load_file_settings(load_settings_dict)
	
	for key in quipper_hidden_appearance_settings_dict.keys():
		ModsConfigInterface.on_setting_changed(key, quipper_hidden_appearance_settings_dict[key], QUIPPER_HIDDEN_APPEARANCE_LOG)
	
	ModsConfigInterface.connect("setting_changed", self, "_quipper_hidden_appearance_on_setting_changed")

	_quipper_hidden_appearance_add_signal_to_menu_choose_options()

func _quipper_hidden_appearance_add_signal_to_menu_choose_options() -> void:
	var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if ModsConfigInterface == null or !is_instance_valid(ModsConfigInterface):
		return
	if !ModsConfigInterface.has_user_signal("quipper_hidden_appearance_container_ready"):
		ModsConfigInterface.add_user_signal("quipper_hidden_appearance_container_ready")
		ModsConfigInterface.connect("quipper_hidden_appearance_container_ready", self, "_on_quipper_hidden_appearance_container_ready")

func _on_quipper_hidden_appearance_container_ready(menu_choose_options_node:Node) -> void:
	call_deferred("_quipper_hidden_appearance_setting_container", menu_choose_options_node)

func _quipper_hidden_appearance_setting_container(menu_choose_options_node:Node) -> void:
	if menu_choose_options_node == null or !is_instance_valid(menu_choose_options_node):
		return
	
	var menu_mods_options_path:String = str(menu_choose_options_node.get_path()).replace("/MenuChooseOptions", "/MenuModsOptions")
	var menu_mods_options_node:Node = get_node_or_null(menu_mods_options_path)

	if menu_mods_options_node == null or !is_instance_valid(menu_mods_options_node):
		return

	var mod_list_vbox:VBoxContainer = menu_mods_options_node.get("mod_list_vbox")
	var mod_setting_lists:Array = mod_list_vbox.get_children()
	
	for mod_setting_list in mod_setting_lists:
		var mod_label:Label = mod_setting_list.get_child(0)
		var text:String = mod_label.text
		if text == QUIPPER_HIDDEN_APPEARANCE_LOG:
			quipper_hidden_appearance_setting_container = mod_setting_list.get_child(1)
			break
	
	_quipper_hidden_appearance_set_collapse_setting(quipper_hidden_appearance_settings_dict[QUIPPER_HIDDEN_APPEARANCE_SHOW_OPTIONS])

func _quipper_hidden_appearance_set_collapse_setting(value:bool) -> void:
    if quipper_hidden_appearance_setting_container == null or !is_instance_valid(quipper_hidden_appearance_setting_container):
        return
    var quipper_hidden_appearance_setting_options:Array = quipper_hidden_appearance_setting_container.get_children()
    quipper_hidden_appearance_setting_options.remove(0)

    if value:
        for quipper_hidden_appearance_setting_option in quipper_hidden_appearance_setting_options:
            quipper_hidden_appearance_setting_option.visible = true	
    else:
        for quipper_hidden_appearance_setting_option in quipper_hidden_appearance_setting_options:
            quipper_hidden_appearance_setting_option.visible = false 

func _quipper_hidden_appearance_load_file_settings(load_settings_dict:Dictionary) -> void:
	for key in quipper_hidden_appearance_settings_dict.keys():
		if !load_settings_dict.has(key):
			continue
		quipper_hidden_appearance_settings_dict[key] = load_settings_dict[key]

func _quipper_hidden_appearance_load_dict_from_json_file() -> Dictionary:
	var file:File = File.new()
	var err:int = file.open(quipper_hidden_appearance_save_path, file.READ)

	if err != OK:
		ModLoaderLog.error("Fail to open file. Code: %s" % err, QUIPPER_HIDDEN_APPEARANCE_LOG)
		return {}
	
	var content:String = file.get_as_text()
	file.close()

	var result:JSONParseResult = JSON.parse(content)
	if result.error != OK:
		ModLoaderLog.error("Fail to parse json file. Code: %s, Json: %s" % [result.error, content], QUIPPER_HIDDEN_APPEARANCE_LOG)
		return{}
	
	return result.result

func _quipper_hidden_appearance_has_config_file() -> bool:
	var file:File = File.new()
	return file.file_exists(quipper_hidden_appearance_save_path)

func _quipper_hidden_appearance_get_save_path() -> void:
    var base_dir:String = ProgressData.SAVE_PATH.get_base_dir()
    var config_dir:String = base_dir.plus_file(QUIPPER_HIDDEN_APPEARANCE_CONFIG_FOLDER_NAME)
    quipper_hidden_appearance_save_path = config_dir.plus_file(QUIPPER_HIDDEN_APPEARANCE_CONFIG_NAME + ".json")
