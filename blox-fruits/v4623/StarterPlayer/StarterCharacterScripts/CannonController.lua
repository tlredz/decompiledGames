local localPlayer = game.Players.LocalPlayer
local value = nil
local cannon = false
local v = {
	Boats = {},
	NPCs = {}
}
local v2 = nil
local v3 = false
local v4 = nil
local v5 = nil

local function onScreen(vector: Vector3)
	local worldToViewportPoint, v6 = workspace.CurrentCamera:WorldToViewportPoint(vector)
	return v6 and worldToViewportPoint.Z > 0
end

local function checkIsAlly(instance, player, player2)
	if not (player and player2) then
		return
	end

	if instance:IsDescendantOf(workspace.Enemies) then
		return false
	end

	if player:IsA("Player") and player2:IsA("Player") and player.Team == player2.Team then
		return true
	end

	if player == player2 or game.CollectionService:HasTag(player2, "Ally" .. player.Name) or game.CollectionService:HasTag(
		player,
		"Ally" .. player2.Name
	) then
		return true
	end

	return false
end

local function getDriver(instance)
	local vehicleSeat = instance:FindFirstChildOfClass("VehicleSeat")

	if vehicleSeat then
		return vehicleSeat.Occupant and vehicleSeat:FindFirstChild("SeatWeld") and game.Players:GetPlayerFromCharacter(vehicleSeat.Occupant.Parent)
	end
end

local function targetAdded(_) end

local function updateTargets() end

script.ChildAdded:Connect(function(child)
	if child.Value.Name == "Harpoon" then
		local Harpoon = require(game.ReplicatedStorage.Harpoon)
		Harpoon(child.Value)
	else
		value = child.Value
	end

	cannon = value and value:FindFirstChild("Cannon")
	task.defer(updateTargets)
end)
script.ChildRemoved:Connect(function(_)
	value = nil
	cannon = false
	task.defer(updateTargets)
	local Harpoon = require(game.ReplicatedStorage.Harpoon)
	Harpoon()
end)
local UserInputService = game:GetService("UserInputService")
local Mouse = require(game.ReplicatedStorage:WaitForChild("Mouse"))
UserInputService.InputBegan:connect(function(p, p2)
	if not value or p2 or not localPlayer.Character or not UserInputService.GamepadEnabled and (p.UserInputState ~= Enum.UserInputState.Begin or p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.Touch) then
		return
	end

	if localPlayer.Character.Busy.Value or localPlayer.Character.Humanoid.Sit == false then
		return
	end

	game.ReplicatedStorage.Remotes.CommF_:InvokeServer("FireCannon", Mouse.Hit.p)
end)
UserInputService.TouchTapInWorld:connect(function(_, p)
	if not value or p or not localPlayer.Character or localPlayer.Character.Busy.Value then
		return
	end

	if localPlayer.Character.Humanoid.Sit == false then
		return
	end

	game.ReplicatedStorage.Remotes.CommF_:InvokeServer("FireCannon", Mouse.Hit.p)
end)