@tool
extends EditorPlugin

const AUTOLOAD_NAME = "MatchTreeModLoader"

func _enable_plugin ():
    add_autoload_singleton(AUTOLOAD_NAME, "res://addons/MatchTreeModLoader/mod_loader_autoload.gd")

func _disable_plugin():
    remove_autoload_singleton(AUTOLOAD_NAME)
