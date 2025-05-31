extends Node

func _ready ():
    print("Mod Loader starting...")

    await get_tree().process_frame

    var modding_api := _load_modding_api()
    var mod_nodes: Array[Node] = []
    if modding_api != null:
        mod_nodes = _load_mods()

        print("Mod Loader ready.")

    await get_tree().process_frame

    for mod_node: Node in mod_nodes:
        modding_api.add_child(mod_node)

    get_tree().change_scene_to_file("res://UI/StartMenu/StartMenu.tscn")

    if modding_api != null:
        modding_api._game_ready()

    for mod_node: Node in mod_nodes:
        if mod_node.has_method("_game_ready"):
            mod_node._game_ready()

func _load_modding_api () -> Node:
    var success := ProjectSettings.load_resource_pack("res://mod_loader/modding_api.pck")

    if not success:
        printerr("Failed to load modding API.")
        return null

    var ModApiScene = load("res://mods/api/api.tscn")
    var mod_api_scene := ModApiScene.instantiate() as Node
    get_tree().get_root().add_child(mod_api_scene)

    return mod_api_scene

func _load_mods () -> Array[Node]:
    var mod_pack_file_paths := _find_pack_files()

    var mod_nodes: Array[Node] = []

    for mod_pack_file_path: String in mod_pack_file_paths:
        var success := ProjectSettings.load_resource_pack(mod_pack_file_path)

        if not success:
            printerr("Failed to load mod pack: " + mod_pack_file_path)
            continue

        var mod_name = mod_pack_file_path.get_file().get_basename()
        var mod_scene := load("res://mods/" + mod_name + "/mod.tscn")
        if mod_scene == null:
            printerr("Failed to load mod scene for: " + mod_pack_file_path)
            continue

        var mod_node := mod_scene.instantiate() as Node
        if mod_node == null:
            printerr("Failed to instantiate mod node for: " + mod_pack_file_path)
            continue

        mod_nodes.append(mod_node)

    return mod_nodes

func _find_pack_files () -> Array[String]:
    var mods_path = ProjectSettings.globalize_path("res://mods")

    var mod_directory := DirAccess.open(mods_path)

    if mod_directory == null:
        printerr("Failed to open mods directory.")
        return []

    var mod_pack_file_paths := _get_pcks_in_folder(mods_path)

    mod_directory.include_navigational = false
    mod_directory.include_hidden = true

    mod_directory.list_dir_begin()

    for directory_name: String in mod_directory.get_directories():
        var more_mod_pack_file_paths = _get_pcks_in_folder(mods_path + "/" + directory_name)
        mod_pack_file_paths.append_array(more_mod_pack_file_paths)

    return mod_pack_file_paths


func _get_pcks_in_folder (path: String) -> Array[String]:
    var directory := DirAccess.open(path)
    if directory == null:
        return []

    directory.include_navigational = false
    directory.include_hidden = true

    directory.list_dir_begin()
    var current_directory := directory.get_current_dir()

    var packs: Array[String] = []

    for file: String in directory.get_files():
        if file.ends_with(".pck"):
            packs.append(current_directory + "/" + file)

    return packs
