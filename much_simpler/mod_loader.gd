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
        # TODO: add_child können wir nicht machen, wenn wir unten change_scene_to_file ausführen.
        #       Das entfernt uns nämlich aus dem Szenenbaum.
        #       Stattdessen bräuchten wir einen festen Ort im Baum, evtl. einen Node, den wir dort hinzufügen.

    get_tree().change_scene_to_file("res://UI/Map/NewWorld.tscn")
