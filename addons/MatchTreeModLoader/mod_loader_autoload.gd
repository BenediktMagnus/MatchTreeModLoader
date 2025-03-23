extends Node

func _init ():
    print("Mod Loader: Init")

func _ready ():
    print("Mod Loader: Ready")

    var success := ProjectSettings.load_resource_pack("res://mod.pck")
    print(success)

    if success:
        var ModScene = load("res://mods/mod/mod.tscn")
        var mod_scene = ModScene.instantiate()
        add_child(mod_scene)
