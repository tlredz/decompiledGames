local game2 = script.Parent.Parent:WaitForChild("Game")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local emotes = game2.Emotes
_G.EmoteFrame = emotes
local EmoteModule = require(game.ReplicatedStorage.Modules.EmoteModule)
EmoteModule.EmoteGUI = emotes
EmoteModule.GenerateEmotes(ProfileData.Emotes.Owned, emotes)
EmoteModule.SetupPageButtons()
_G.UpdateEmotes()