extends Node
class_name ModdingApi

signal level_loaded (level: Node2D)
signal options_menu_loaded (options_menu: CanvasLayer)
signal start_menu_loaded (start_menu: CanvasLayer)
signal world_map_loaded (world_map: Node2D)

func _init ():
    #print("Base Mod: Init")
    pass

func _enter_tree ():
    get_tree().node_added.connect(_on_node_added_to_scene_tree)

func _exit_tree ():
    get_tree().node_added.disconnect(_on_node_added_to_scene_tree)

func _ready ():
    #print("Base Mod: Ready")
    pass

func _game_ready ():
    #print("Base Mod: Game Ready")
    pass

func _on_node_added_to_scene_tree (node: Node):
    match node.get_path():
        ^"/root/baselevel":
            level_loaded.emit(node)
        ^"/root/SceneManager/OptionsMenu":
            options_menu_loaded.emit(node)
        ^"/root/StartMenu":
            start_menu_loaded.emit(node)
        ^"/root/Worldmap":
            world_map_loaded.emit(node)
