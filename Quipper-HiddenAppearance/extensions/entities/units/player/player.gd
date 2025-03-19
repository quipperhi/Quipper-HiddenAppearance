extends "res://entities/units/player/player.gd"

var quipper_hidden_appearance_character_appearances:Array = []
var quipper_hidden_appearance_player_appearances:Array = []

func _ready() -> void:
	var QuipperHiddenAppearanceEventListener = get_node_or_null("/root/ModLoader/Quipper-HiddenAppearance/Quipper-HiddenAppearance-EventListener")
	if QuipperHiddenAppearanceEventListener == null:
		return
	if QuipperHiddenAppearanceEventListener.quipper_hidden_appearance_is_mod_options_loaded:
		QuipperHiddenAppearanceEventListener.connect("quipper_hidden_appearance_setting_changed", self, "on_quipper_hidden_appearance_setting_changed")
		

func on_quipper_hidden_appearance_setting_changed(quipper_hidden_appearance_player_index:int, quipper_hidden_appearance_value:bool, quipper_hidden_appearance_is_coop:bool) -> void:
	if dead:
		return
	if player_index != quipper_hidden_appearance_player_index:
		return
	if RunData.is_coop_run != quipper_hidden_appearance_is_coop:
		return
	quipper_hidden_appearance_apply_setting(quipper_hidden_appearance_value)

func quipper_hidden_appearance_apply_setting(quipper_hidden_appearance_value:bool) -> void:
	if quipper_hidden_appearance_value:
		quipper_hidden_appearance_hide_player_appearances_and_show_character_appearances()
	else:
		quipper_hidden_appearance_show_player_appearances_and_hide_character_appearances()

func quipper_hidden_appearance_hide_player_appearances_and_show_character_appearances() -> void:
	for appearance in quipper_hidden_appearance_player_appearances:
		appearance.visible = false
	for character_appearance in quipper_hidden_appearance_character_appearances:
		character_appearance.visible = true

func quipper_hidden_appearance_show_player_appearances_and_hide_character_appearances() -> void:
	for appearance in quipper_hidden_appearance_player_appearances:
		appearance.visible = true
	for character_appearance in quipper_hidden_appearance_character_appearances:
		character_appearance.visible = false

func apply_items_effects() -> void:
    .apply_items_effects()

    var quipper_hidden_appearance_animation_node = $Animation

    var quipper_hidden_appearance_appearances_behind:Array = []

    for appearance in _item_appearances:
        quipper_hidden_appearance_player_appearances.push_back(appearance)

    for character_appearance in RunData.get_player_character(player_index).item_appearances:
        var item_sprite = Sprite.new()
        item_sprite.texture = character_appearance.get_sprite()
        quipper_hidden_appearance_animation_node.add_child(item_sprite)

        if character_appearance.depth < - 1:
            quipper_hidden_appearance_appearances_behind.push_back(item_sprite)

        quipper_hidden_appearance_character_appearances.push_back(item_sprite)
        _item_appearances.push_back(item_sprite)

    var popped = quipper_hidden_appearance_appearances_behind.pop_back()

    while popped != null:
        quipper_hidden_appearance_animation_node.move_child(popped, 0)
        popped = quipper_hidden_appearance_appearances_behind.pop_back()

    var QuipperHiddenAppearanceEventListener = get_node_or_null("/root/ModLoader/Quipper-HiddenAppearance/Quipper-HiddenAppearance-EventListener")
    if QuipperHiddenAppearanceEventListener == null:
        return

    if !QuipperHiddenAppearanceEventListener.quipper_hidden_appearance_is_mod_options_loaded:
        quipper_hidden_appearance_hide_player_appearances_and_show_character_appearances()
        return

    var quipper_hidden_appearance_value:bool = QuipperHiddenAppearanceEventListener.quipper_hidden_appearance_get_setting(player_index, RunData.is_coop_run)
    quipper_hidden_appearance_apply_setting(quipper_hidden_appearance_value)

