local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Shared.Globals.Constants)
local Gears = require(ReplicatedStorage.Data.Gears)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local v = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true
}
local v2 = {
	[Enum.KeyCode.ButtonR2] = true
}
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local function isBatTool(tool)
			local gearName = tool:GetAttribute("GearName")
			t.strict(t.optional(t.string))(gearName)

			if gearName == nil then
				return false
			end

			return Gears.GearNameExists(gearName) and Gears.Directory[gearName].BatControllerData ~= nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isActivationInput(p)
			return v[p.UserInputType] == true or v2[p.KeyCode] == true
		end

		local function trySendActivation()
			local v3 = localPlayer

			if not v3 then
				return
			end

			local character = v3.Character

			if not character then
				return
			end

			local tool = character:FindFirstChildWhichIsA("Tool")

			if not tool or not ToolGameplayGuard.AllowsLocalUse(tool) or isBatTool(tool) then
				return
			end

			Remotes.ToolTrigger.Trigger:FireServer(tool)
		end

		UserInputService.InputBegan:Connect(function(input)
			if not isActivationInput(input) then
				return
			end

			trySendActivation()
		end)
	end
}