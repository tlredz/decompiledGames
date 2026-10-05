local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local v = {}

for _, v2 in ipairs(ReplicatedStorage.CAM.Global.Training:QueryDescendants("ModuleScript#Client")) do
	local success, result = pcall(require, v2)

	if success then
		v[v2.Parent.Name] = result
	else
		warn((`[Training] client module {v2.Parent.Name} failed to load: {result}`))
	end
end

local v2 = {}
getvaluesfolder.ChildAdded:Connect(function(child)
	if child.Name ~= "Training" then
		return
	end

	local type = child:GetAttribute("Type")

	if v[type] == nil then
		return
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local items_Config = localPlayer:FindFirstChild("Items_Config")

	if items_Config and items_Config:FindFirstChild("Equipped") then
		items_Config.Equipped.Value = 0
	end

	v2[child] = {
		Type = type,
		Character = character
	}
	local prompt = child:WaitForChild("Prompt", 5)

	if v2[child] == nil then
		return
	end

	v[type].Do(localPlayer, character, child, prompt and prompt.Value)
end)
getvaluesfolder.ChildRemoved:Connect(function(child)
	local v3 = v2[child]

	if v3 == nil then
		return
	end

	v2[child] = nil
	v[v3.Type].Stop(localPlayer, v3.Character, child)
end)