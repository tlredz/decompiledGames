local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
require(ReplicatedStorage.Shared.Globals.Constants)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ToolGameplayGuard = require(ReplicatedStorage.Client.ToolGameplayGuard)
local v = 0

local function onActivated()
	if not ToolGameplayGuard.AllowsLocalUse(parent) then
		return
	end

	local now = tick()

	if now - v < 1 or not (localPlayer.Character and localPlayer.Character.PrimaryPart) then
		return
	end

	v = now
	local character = localPlayer.Character
	local primaryPart = character.PrimaryPart
	local lookVector = primaryPart.CFrame.LookVector
	local position = primaryPart.Position + lookVector * 4
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { character }

	if workspace:Raycast(primaryPart.Position, lookVector * 4, raycastParams) then
		return
	end

	local vector2 = Vector3.new(position.X, position.Y + 5, position.Z)
	local raycastResult = workspace:Raycast(vector2, createVector(0, -100, 0), raycastParams)

	if raycastResult then
		position = raycastResult.Position
	end

	local gearName = parent:GetAttribute("GearName")

	if typeof(gearName) ~= "string" then
		gearName = parent.Name
	end

	Remotes.TrapPlacement.AskPlace:FireServer(gearName, position)
end

parent.Activated:Connect(onActivated)