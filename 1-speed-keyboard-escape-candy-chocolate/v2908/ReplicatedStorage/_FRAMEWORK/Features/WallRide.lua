local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local wallRide = require(ReplicatedStorage._FRAMEWORK.Libraries.wallRide)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Config = require(script.Config)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local WallRide = {
	onAttach = Signal.new(),
	onDetach = Signal.new(),
	onJump = Signal.new()
}
local maid = nil
local v = nil

local function attachToCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

	if humanoid == nil or humanoidRootPart == nil then
		logger:warn(
			"Character never exposed a Humanoid and a HumanoidRootPart, wall ride stays off for",
			character:GetFullName()
		)
		return
	end

	v = humanoid
	wallRide.bind(character)
end

local function resolveUp()
	return GravityController.getUp()
end

local function resolveMoveDirection()
	local v2 = v

	if GravityController.isActive() then
		return GravityController.getMoveDirection()
	end

	if v2 == nil then
		return createVector(0, 0, 0)
	end

	return v2.MoveDirection
end

local function resolveHostDriven()
	return GravityController.isActive() and not GravityController.isMotionSuspended()
end

local function onMotionOwned(flag: boolean)
	GravityController.suspendMotion(script.Name, flag)
end

local function startClient()
	local localPlayer = Players.LocalPlayer
	wallRide.configure(Config.overrides)
	wallRide.configure({
		getUp = resolveUp,
		getMoveDirection = resolveMoveDirection,
		isHostDriven = resolveHostDriven,
		onMotionOwned = onMotionOwned
	})
	wallRide.configure({
		onAttach = function(p)
			WallRide.onAttach:Fire(p.part, p.side)
		end,
		onDetach = function(p)
			WallRide.onDetach:Fire(p)
		end,
		onJump = function(p)
			GravityController.notifyLaunch()
			WallRide.onJump:Fire(p)
		end
	})
	wallRide.bindDefaultInput()
	maid = Janitor.new()
	maid:Add(localPlayer.CharacterAdded:Connect(function(character)
		attachToCharacter(character)
	end))
	maid:Add(localPlayer.CharacterRemoving:Connect(function()
		wallRide.unbind()
		v = nil
	end))
	local character = localPlayer.Character

	if character ~= nil then
		task.spawn(attachToCharacter, character)
	end
end

function WallRide.isRiding()
	return wallRide.isRiding()
end

function WallRide.setEnabled(flag: boolean)
	wallRide.setEnabled(flag)
end

function WallRide.setProbeListener(onProbe)
	wallRide.configure({
		onProbe = onProbe
	})
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if Common.IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if Common.IsClient() then
			wallRide.update(Common.GetDeltatime())
		end
	end
})
return WallRide