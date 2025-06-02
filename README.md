# Match Tree Mod Loader

<!-- TODO: Clean up and extend. -->

## Overview

`mod_loader` contains the code for loading mods. Must be used as-is. <br>
`mods/api` contains the code for the modding API. Must be exported as PCK. <br>
`definitions` contains type definitions for components of the game. Can be used for type checking in mods. Must not be exported.

## Mod installation

Mods must be placed in the `mods` directory (or a folder inside the `mods` directory) which can be found in the game's installation directory. <br>
Mods consist of two files which need to have the same base name: A .pck with the mod's content and a .mod file. The .mod file is a JSON configuration file. It needs to have the following structure:
```json
{
  "name": "Mod name",
  "description": "A description of the mod.",
  "author": "Author name",
  "version": "1.0.0",
  "supported_game_version": "0.5.0",
  "supported_mod_loader_version": "0.1.0"
}
```

## Mod content

The mod's content must be exported inside a single .pck file. <br>
It can include two kinds of files:

- Overwriting files: Files that already exist in the game that shall be overwritten. They must have the same path inside the mod's .pck as they have in the game.
- Additional files: Files not present in the game must be placed in a subdirectory called `mods/<mod_name>` inside the .pck file.

There must be at least a single file in the .pck: `mods/<mod_name>/mod.gd`. The mod loader will load this file (after loading the .pck).

## Mod loading

The mod's `mod.gd` is loaded after the game's base .pck but before the game's main scene has been instantiated. This means that when the `mod.gd`s `_ready` function is called, the game's autoloads are already present but not the game itself. <br>
If the `mod.gd` file has a function `_game_ready` it will be called after the game has been fully loaded and the main scene is instantiated.

The `mod.gd`s position in the tree is `/root/ModdingApi/<mod>`.

## Modding API

The modding API can be accessed either from the tree node `/root/ModdingApi` or from the parent of the mod's `mod.gd` node.
