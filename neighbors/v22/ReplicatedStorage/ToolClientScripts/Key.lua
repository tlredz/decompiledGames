local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
Players.LocalPlayer:GetMouse()
require(ReplicatedStorage.Modules.Tool)
local Key = {}
local localPlayer = Players.LocalPlayer
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2.Modules.PlayerStates)
local Network = require(ReplicatedStorage2.Modules.Network)
local House = require(ReplicatedStorage2.Modules.Neighbors.House)
local v = nil
local postSimulationConnection = nil
local color = Color3.fromRGB(85, 255, 127)
local color2 = Color3.fromRGB(255, 85, 127)
local highlight = Instance.new("Highlight")
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.FillTransparency = 0.75
highlight.Parent = nil
local proximityPrompt = Instance.new("ProximityPrompt")
proximityPrompt.RequiresLineOfSight = false
proximityPrompt.MaxActivationDistance = 10
proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
proximityPrompt.Triggered:Connect(function()
	Network:fire("TriggerDoorLock", proximityPrompt.Parent.Parent.Name)
end)

local function Disconnect()
	if postSimulationConnection then
		postSimulationConnection:Disconnect()
		postSimulationConnection = nil
	end

	proximityPrompt.Parent = script
	highlight.Adornee = nil
	highlight.Parent = nil
	local v2 = v

	if v2 and v2.Knob:FindFirstChild("Locks") then
		local locks = v2.Knob:FindFirstChild("Locks")
		locks.Surface1.AlwaysOnTop = false
		local locks_2 = v2.Knob:FindFirstChild("Locks")
		locks_2.Surface2.AlwaysOnTop = false
	end

	v = nil
end

local function GetClosestDoor()
	local v2 = {}
	local currentPrefab = House:GetCurrentPrefab()

	if not currentPrefab then
		return
	end

	for _, door in next, currentPrefab.Doors, nil do
		table.insert(v2, {
			Object = door,
			Distance = localPlayer:DistanceFromCharacter(door.Door.Position)
		})
	end

	table.sort(v2, function(a, b)
		return a.Distance < b.Distance
	end)
	return v2[1].Object
end

function Key.Equipped(_)
	proximityPrompt.Parent = script
	local RunService = game:GetService("RunService")
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		if not localPlayer:GetAttribute("CurrentInternalMap") then
			return
		end

		local closestDoor = GetClosestDoor()

		if v ~= closestDoor then
			local v3 = v

			if v3 and v3.Knob:FindFirstChild("Locks") then
				local locks = v3.Knob:FindFirstChild("Locks")
				locks.Surface1.AlwaysOnTop = false
				local locks_2 = v3.Knob:FindFirstChild("Locks")
				locks_2.Surface2.AlwaysOnTop = false
			end

			v = closestDoor
			highlight.Adornee = v.Door
			proximityPrompt.Parent = v.Door
			highlight.Parent = v.Door
			proximityPrompt.Enabled = false
			local RunService2 = game:GetService("RunService")
			RunService2.Heartbeat:Wait()
			proximityPrompt.Enabled = true
		end

		if v.Part.HingeConstraint.LimitsEnabled then
			highlight.FillColor = color2
			proximityPrompt.ActionText = "Unlock"
		else
			highlight.FillColor = color
			proximityPrompt.ActionText = "Lock"
		end

		if v and v.Knob:FindFirstChild("Locks") then
			local locks_3 = v.Knob:FindFirstChild("Locks")
			locks_3.Surface1.AlwaysOnTop = true
			local locks_4 = v.Knob:FindFirstChild("Locks")
			locks_4.Surface2.AlwaysOnTop = true
		end
	end)
end

function Key.Unequipped(_)
	Disconnect()
end

function Key.Destroyed(_)
	Disconnect()
end

return Key