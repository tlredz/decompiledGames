local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

if not localPlayer.Character then
	localPlayer.CharacterAdded:Wait()
end

local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local data = Utility.GetData(localPlayer, true)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local equipped = localPlayer:WaitForChild("Items_Config"):WaitForChild("Equipped")

function updToolEquipped()
	local get_equipped_tool = Character_info_provider.Get_equipped_tool(localPlayer)
	Character_info_provider.EquippedTool = get_equipped_tool and get_equipped_tool.Name or nil
end

updToolEquipped()
equipped.Changed:Connect(updToolEquipped)
local v = {
	One = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5
}

for _, child in pairs(data.Inventory.Toolbar:GetChildren()) do
	local v3 = v[child.Name]
	child.Changed:Connect(function()
		if equipped.Value == v3 then
			updToolEquipped()
		end
	end)
end