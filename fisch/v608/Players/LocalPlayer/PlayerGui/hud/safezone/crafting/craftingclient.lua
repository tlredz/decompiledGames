local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local WorldController = require(ReplicatedStorage.client.legacyControllers.WorldController)

if WorldController:GetCurrentWorldIndex() ~= "Sea 1" then
	return
end

local parent = script.Parent

local function DisableUIIfTool(tool)
	if not tool:IsA("Tool") or DataController.getItemFromLink(tool) then
		return
	end

	parent.Visible = false
end

local function OnCharacterAdded(instance)
	instance.ChildAdded:Connect(function(tool)
		if not tool:IsA("Tool") or DataController.getItemFromLink(tool) then
			return
		end

		parent.Visible = false
	end)
end

if localPlayer.Character then
	task.spawn(OnCharacterAdded, localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)
require(script:WaitForChild("CraftingController"))