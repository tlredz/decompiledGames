local parent = script.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local emotes = parent.Emotes
_G.EmoteFrame = emotes
local EmoteModule = require(game.ReplicatedStorage.Modules.EmoteModule)
EmoteModule.EmoteGUI = emotes
EmoteModule.GenerateEmotes(ProfileData.Emotes.Owned, emotes)
EmoteModule.SetupPageButtons()
_G.UpdateEmotes()
local ContextActionService = game:GetService("ContextActionService")
local names = {}

local function SetSelectionGroup(emotePages)
	for _, v in pairs(names) do
		local GuiService = game:GetService("GuiService")
		GuiService:RemoveSelectionGroup(v)
	end

	if emotePages then
		local GuiService = game:GetService("GuiService")
		GuiService:AddSelectionParent(emotePages.Name, emotePages)
		table.insert(names, emotePages.Name)
	end
end

local function fn()
	for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
		if not (tool:IsA("Tool") and tool.Name == "Emotes") then
			continue
		end

		_G.ResetDock()
		tool.Parent = game.Players.LocalPlayer.Character
		SetSelectionGroup(emotes.EmotePages)
		local GuiService = game:GetService("GuiService")
		GuiService.SelectedObject = emotes.EmotePages[_G.CurrentPage or "RobloxEmotes"].Container:GetChildren()[1].Container.Button
		return
	end

	for _, tool in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if not (tool:IsA("Tool") and tool.Name == "Emotes") then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Backpack
		break
	end
end

ContextActionService:BindAction("Emotes", function(_, p)
	if p == Enum.UserInputState.Begin and not _G.PauseBinds then
		fn()
	end
end, false, Enum.KeyCode.DPadRight)