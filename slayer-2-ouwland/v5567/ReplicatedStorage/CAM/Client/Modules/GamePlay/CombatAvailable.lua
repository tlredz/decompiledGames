local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local curPower = ReplicatedStorage.CAM.Client.Controllers.Skills_Provider:WaitForChild("CurPower")
local animations = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations")
return {
	Is = function()
		for _, v in string.split(curPower.Value, ",") do
			if v ~= "" and animations:FindFirstChild(v .. "_Combat_Anims") ~= nil then
				return true
			end
		end

		local get_equipped_tool = Character_info_provider.Get_equipped_tool(Players.LocalPlayer)

		if get_equipped_tool == nil then
			return false
		end

		local item = Items[get_equipped_tool.Name]
		return item ~= nil and item.HasCombat == true or animations:FindFirstChild(get_equipped_tool.Name .. "_Combat_Anims") ~= nil
	end
}