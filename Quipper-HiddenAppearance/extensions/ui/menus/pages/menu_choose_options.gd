extends "res://ui/menus/pages/menu_choose_options.gd"

func _ready():
    var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
    if ModsConfigInterface == null or !is_instance_valid(ModsConfigInterface):
        return
    if ModsConfigInterface.has_user_signal("quipper_hidden_appearance_container_ready"):
        ModsConfigInterface.emit_signal("quipper_hidden_appearance_container_ready", self)