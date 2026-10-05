local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Classes.PlotClient)
local PlotController = require(ReplicatedStorage.Controllers.PlotController)
local Friends = require(ReplicatedStorage.Shared.Friends)
local ABTests = require(ReplicatedStorage.UserGenerated.ABTests)
local Net = require(ReplicatedStorage.Packages.Net)
local overlapParams = OverlapParams.new()
overlapParams.FilterDescendantsInstances = {}
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.MaxParts = 1

local function PlotSearch(pivot: CFrame)
	for _, v in pairs(PlotController:GetPlots()) do
		if not v:GetOwner() then
			continue
		end

		overlapParams.FilterDescendantsInstances = { v.PlotModel:FindFirstChild("StealHitbox") }

		if #workspace:GetPartBoundsInBox(pivot, createVector(0.01, 0.01, 0.01), overlapParams) > 0 then
			return v, 1
		end
	end

	return nil, 0
end

local function PlotSearchPlayer(player)
	local character = player.Character

	if not (character and character.PrimaryPart) then
		return nil, 0
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return nil, 0
	end

	local v, v2 = PlotSearch(character:GetPivot())
	return v, v2
end

local v = { "BlockEndTimeFirstFloor", "BlockEndTimeSecondFloor", "BlockEndTimeThirdFloor" }

local function IsBlocked(player, object, _: number)
	local owner = object:GetOwner()

	if not owner or owner == player or player:GetAttribute("IgnoreLasers") then
		return false
	end

	local v2 = false

	for _, v4 in ipairs(v) do
		if object.Channel:Get(v4) == nil then
			continue
		end

		v2 = true
		break
	end

	if not v2 or object.Channel:Get("FriendsAllowed") == true and table.find(Friends:GetInGameFriends(player), owner) then
		return false
	end

	return true
end

local function TestEligible(localPlayer)
	if not ABTests.GetAttribute(localPlayer, "LeaveBaseButton", false) or localPlayer:GetAttribute("InNorthPole") or localPlayer:GetAttribute("Web") or localPlayer:GetAttribute("Freeze") then
		return false
	end

	if localPlayer:GetAttribute("Stealing") then
		return false
	end

	local character = localPlayer.Character
	local v2, v3

	if character and character.PrimaryPart then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and not (humanoid.Health <= 0) then
			v2, v3 = PlotSearch(character:GetPivot())
		else
			v3 = 0
		end
	else
		v3 = 0
	end

	if not v2 then
		return false
	end

	if IsBlocked(localPlayer, v2, v3) then
		return true
	end

	return false
end

local localPlayer = Players.LocalPlayer
local leaveBase = localPlayer.PlayerGui:WaitForChild("ToolsFrames"):WaitForChild("LeaveBase")
task.spawn(function()
	while true do
		leaveBase.Visible = TestEligible(localPlayer)
		task.wait(0.1)
	end
end)
leaveBase.Activate.Activated:Connect(function()
	if not leaveBase.Visible then
		return
	end

	Net:RemoteEvent("PlotService/Leave"):FireServer()
end)