local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local wallClimb = require(ReplicatedStorage._FRAMEWORK.Libraries.wallClimb)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Config = require(script.Config)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local WallClimb = {
	onReady = Signal.new(),
	onLost = Signal.new(),
	onBoost = Signal.new()
}
local maid = nil
local v = nil

local function attachToCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

	if humanoid == nil or humanoidRootPart == nil then
		logger:warn(
			"Character never exposed a Humanoid and a HumanoidRootPart, wall climb stays off for",
			character:GetFullName()
		)
		return
	end

	v = humanoid
	wallClimb.bind(character)
end

local function resolveUp()
	return GravityController.getUp()
end

local function resolveAirborne(p)
	if GravityController.isActive() then
		return GravityController.isAirborne()
	end

	return p.FloorMaterial == Enum.Material.Air
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

local function startClient()
	local localPlayer = Players.LocalPlayer
	wallClimb.configure(Config.overrides)
	wallClimb.configure({
		getUp = resolveUp,
		getGravity = GravityController.getLaunchGravity,
		getMoveDirection = resolveMoveDirection,
		isAirborne = resolveAirborne
	})
	wallClimb.configure({
		onReady = function(p)
			WallClimb.onReady:Fire(p.part)
		end,
		onLost = function()
			WallClimb.onLost:Fire()
		end,
		onBoost = function(p)
			GravityController.notifyLaunch()
			WallClimb.onBoost:Fire(p)
		end
	})
	wallClimb.bindDefaultInput()
	maid = Janitor.new()
	maid:Add(localPlayer.CharacterAdded:Connect(function(character)
		attachToCharacter(character)
	end))
	maid:Add(localPlayer.CharacterRemoving:Connect(function()
		wallClimb.unbind()
		v = nil
	end))
	local character = localPlayer.Character

	if character ~= nil then
		task.spawn(attachToCharacter, character)
	end
end

function WallClimb.isBoostReady()
	return wallClimb.isReady()
end

function WallClimb.setEnabled(flag: boolean)
	wallClimb.setEnabled(flag)
end

function WallClimb.setProbeListener(onProbe)
	wallClimb.configure({
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
			wallClimb.update(Common.GetDeltatime())
		end
	end
})
return WallClimb