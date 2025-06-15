extends Node

const MOD_LOADER_VERSION = "0.1.5"
const SUPPORTED_GAME_VERSION = "0.5.299"
const GAME_MAIN_SCENE_PATH = "res://UI/StartMenu/StartMenu.tscn"

const MODS_PATH = "res://mods"

class ModConfig:
    var name: String
    var description: String
    var author: String
    var version: String
    var supported_game_version: String
    var supported_mod_loader_version: String

    func _init (
        _name: String,
        _description: String,
        _author: String,
        _version: String,
        _supported_game_version: String,
        _supported_mod_loader_version
    ):
        name = _name
        description = _description
        author = _author
        version = _version
        supported_game_version = _supported_game_version
        supported_mod_loader_version = _supported_mod_loader_version

func _ready ():
    print("Mod Loader Version: " + MOD_LOADER_VERSION)

    await get_tree().process_frame

    if Globals.VERSION != SUPPORTED_GAME_VERSION:
        printerr("This mod loader is not compatible with the current game version. Expected: " + SUPPORTED_GAME_VERSION)
        get_tree().change_scene_to_file(GAME_MAIN_SCENE_PATH)
        return

    var modding_api := _load_modding_api()

    if modding_api == null:
        printerr("Failed to load modding API.")
        get_tree().change_scene_to_file(GAME_MAIN_SCENE_PATH)
        return

    var mod_nodes := _load_mods()

    await get_tree().process_frame

    for mod_node: Node in mod_nodes:
        modding_api.add_child(mod_node)

    get_tree().change_scene_to_file(GAME_MAIN_SCENE_PATH)

    modding_api._game_ready()

    for mod_node: Node in mod_nodes:
        if mod_node.has_method("_game_ready"):
            mod_node._game_ready()

    print("Mod loader finished.")

func _load_modding_api () -> Node:
    var success := ProjectSettings.load_resource_pack("res://mod_loader/modding_api.pck")

    if not success:
        return null

    var ModApiScene = load(MODS_PATH + "/modding_api/modding_api.tscn")
    var mod_api_scene := ModApiScene.instantiate() as Node
    get_tree().get_root().add_child(mod_api_scene)

    return mod_api_scene

func _load_mods () -> Array[Node]:
    var mod_pack_file_paths := _find_pack_files()

    var mod_nodes: Array[Node] = []

    for mod_pack_file_path: String in mod_pack_file_paths:
        var pck_name := mod_pack_file_path.get_file()
        var mod_file_name := pck_name.get_basename()

        var mod_config := _load_mod_config_for_pck(mod_pack_file_path)
        if mod_config == null:
            printerr("Failed to load mod config for: " + pck_name)
            continue

        if mod_config.supported_mod_loader_version != MOD_LOADER_VERSION:
            printerr("Mod \"" + mod_config.name + "\" is not compatible with this mod loader version (" + MOD_LOADER_VERSION + ").")
            # TODO: It should be possible to replace a part of the version with a catchall like "*" to support a range of versions.
            continue

        if mod_config.supported_game_version != Globals.VERSION:
            printerr("Mod \"" + mod_config.name + "\" is not compatible with this game version (" + Globals.VERSION + ").")
            # TODO: It should be possible to replace a part of the version with a catchall like "*" to support a range of versions.
            continue

        var success := ProjectSettings.load_resource_pack(mod_pack_file_path)

        if not success:
            printerr("Failed to load mod pack: " + mod_pack_file_path)
            continue

        var mod_scene := load(MODS_PATH + "/" + mod_file_name + "/mod.tscn")
        if mod_scene == null:
            printerr("Failed to load mod scene for: " + mod_pack_file_path)
            continue

        var mod_node := mod_scene.instantiate() as Node
        if mod_node == null:
            printerr("Failed to instantiate mod node for: " + mod_pack_file_path)
            continue

        print("Loaded mod: \"" + mod_config.name + "\" (" + mod_config.version + ")")

        mod_nodes.append(mod_node)

    return mod_nodes

func _find_pack_files () -> Array[String]:
    var mods_path = ProjectSettings.globalize_path(MODS_PATH)

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

func _load_mod_config_for_pck (pck_path: String) -> ModConfig:
    var config_path := pck_path.get_basename() + ".mod"

    if not FileAccess.file_exists(config_path):
        return null

    var config_file := FileAccess.get_file_as_string(config_path)

    var config_json = JSON.parse_string(config_file) as Dictionary

    if !config_json.has("name") or \
        !config_json.has("description") or \
        !config_json.has("author") or \
        !config_json.has("version") or \
        !config_json.has("supported_game_version") or \
        !config_json.has("supported_mod_loader_version"):
        return null

    var mod_config = ModConfig.new(
        config_json["name"],
        config_json["description"],
        config_json["author"],
        config_json["version"],
        config_json["supported_game_version"],
        config_json["supported_mod_loader_version"]
    )

    return mod_config
