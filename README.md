# asepriteexporttogm
A script that allows you to export your sprites to GameMaker Studio 2 directly from Aseprite.

Please note that this script is very hacky in many ways, and is probably prone to breaking. Make sure to backup your project before using this script.

## This script requires your sprite to have at least one tag in it.

## Options
- GMS2 Project Path: The path to your GMS2 project (ex. C:\Users\<username>\Documents\GameMakerStudio2\<project name>)
- Sprite Name: The name of the sprite you want to export (ex. spr_test) Note that any tags will have their name appended to the sprites (ex. spr_test_tag1)
- Piggyback Sprite Name: The name of the sprite you want the exported sprite's .yy file to "piggyback" off of. This is used for the keyframe definitions.
- Game FPS: The FPS target of your game. This is used to separate the frames into new ones depending on their duration so that they appear the same in GMS2 as they would in Aseprite.
