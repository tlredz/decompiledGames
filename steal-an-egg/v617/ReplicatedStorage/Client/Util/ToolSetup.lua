local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolCooldown = require(ReplicatedStorage.Shared.Util.ToolCooldown)
local ToolSession = require(ReplicatedStorage.Client.Util.ToolSession)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.array(t.string))
local localPlayer = Players.LocalPlayer
local ToolSetup = {}

function ToolSetup.Attach(value, options)
	local accepts = type(value) == "string" and { value } or value
	strict(accepts)
	local v2 = {
		accepts = accepts,
		hooks = options or {},
		spawns = Trove.new(),
		grip = nil,
		held = nil
	}
	local character = localPlayer.Character

	if character then
		ToolSession.Follow(v2, character)
	end

	v2.spawns:Add(localPlayer.CharacterAdded:Connect(function(character2)
		ToolSession.Follow(v2, character2)
	end))
	return {
		GetCurrentTool = function()
			return v2.held
		end,
		GetCurrentToolGearName = function()
			return ToolSession.GearNameOf(v2.held)
		end,
		IsActive = function()
			return v2.held ~= nil
		end,
		Cleanup = function()
			ToolSession.Shut(v2)
		end
	}
end

function ToolSetup.ApplyCooldown(object, p: number)
	local currentTool = object:GetCurrentTool()

	if currentTool and currentTool.Parent then
		ToolCooldown.Begin(currentTool, p)
	end
end

return ToolSetup