local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local gravityController = require(ReplicatedStorage._FRAMEWORK.Libraries.gravityController)
require(ReplicatedStorage._FRAMEWORK.Libraries.gravityController.Types)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local Signal = require(ReplicatedStorage.Utilities.Signal)
local Config = require(script.Config)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local GravityController = {
	onReset = Signal.new()
}
local v = nil
local v2 = nil
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function resetGravity()
	gravityController.resetSources()
	GravityController.onReset:Fire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterAdded(character)
	v2 = character
	gravityController.bind(character)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseCharacter()
	v2 = nil
	gravityController.unbind()
	resetGravity() -- equivalent call inferred; original call site unknown
end

local function checkFallEscape()
	local v4 = v2
	local fallLanding = gravityController.getFallLanding()
	local v5

	if fallLanding == nil then
		v5 = Config.fallKillDistance
	else
		v5 = math.max(Config.fallKillDistance, Config.landingOvershoot - fallLanding)
	end

	local v6 = gravityController.isActive() and gravityController.getFallDistance() < -v5

	if v4 ~= nil and v6 then
		local humanoid = v4:FindFirstChildOfClass("Humanoid")

		if humanoid ~= nil and humanoid.Health > 0 then
			logger:warn("character travelled past the fall limit under custom gravity, ending the run")
			humanoid.Health = 0
		end
	end
end

local function refreshUnfollowedInstances()
	local children = {}

	for _, childName in Config.unfollowedFolderNames do
		local child = workspace:FindFirstChild(childName)

		if child ~= nil then
			table.insert(children, child)
		end
	end

	gravityController.configure({
		unfollowedInstances = children
	})
end

local function onUnfollowedFolderChanged(p)
	if table.find(Config.unfollowedFolderNames, p.Name) ~= nil then
		refreshUnfollowedInstances()
	end
end

local function startClient()
	local localPlayer = Players.LocalPlayer
	gravityController.configure(Config.overrides)
	refreshUnfollowedInstances()
	local maid = Janitor.new()
	v = maid
	maid:Add(localPlayer.CharacterAdded:Connect(onCharacterAdded))
	maid:Add(localPlayer.CharacterRemoving:Connect(releaseCharacter))
	maid:Add(workspace.ChildAdded:Connect(onUnfollowedFolderChanged))
	maid:Add(workspace.ChildRemoved:Connect(onUnfollowedFolderChanged))

	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
	end

	logger:info("GravityController client feature started")
end

function GravityController.setSource(p: string, vector: Vector3?, p2: number)
	gravityController.setSource(p, vector, p2)
end

function GravityController.getUp()
	return gravityController.getUp()
end

function GravityController.getMoveDirection()
	return gravityController.getMoveDirection()
end

function GravityController.setCameraRelative(flag: boolean)
	assert(Common.IsClient(), "GravityController is client-only")
	gravityController.setCameraRelative(flag)
end

function GravityController.suspendMotion(p: string, flag: boolean)
	assert(Common.IsClient(), "GravityController is client-only")
	gravityController.suspendMotion(p, flag)
end

function GravityController.isMotionSuspended()
	return gravityController.isMotionSuspended()
end

function GravityController.notifyLaunch()
	assert(Common.IsClient(), "GravityController is client-only")
	gravityController.notifyLaunch()
end

function GravityController.getSourceKey()
	return gravityController.getSourceKey()
end

function GravityController.isActive()
	return gravityController.isActive()
end

function GravityController.isCameraLinked()
	return gravityController.isCameraLinked()
end

function GravityController.isGrounded()
	return gravityController.isGrounded()
end

function GravityController.isAirborne()
	return gravityController.isAirborne()
end

function GravityController.getState()
	return gravityController.getState()
end

function GravityController.getStandingPart()
	return gravityController.getStandingPart()
end

function GravityController.getRootPart()
	return gravityController.getRootPart()
end

function GravityController.getLaunchGravity()
	return gravityController.getLaunchGravity()
end

function GravityController.resetGravity()
	assert(Common.IsClient(), "GravityController is client-only")
	resetGravity() -- equivalent call inferred; original call site unknown
end

function GravityController.setProbeListener(onProbe)
	assert(Common.IsClient(), "GravityController is client-only")
	gravityController.configure({
		onProbe = onProbe
	})
end

FeatureManager.RegisterFeature(script.Name, {
	Priority = 0,
	OnInit = function()
		if Common.IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if Common.IsClient() then
			gravityController.update(Common.GetDeltatime())
			checkFallEscape()
		end
	end,
	OnRender = function()
		if Common.IsClient() then
			local v4 = v2

			if v4 == nil or gravityController.isBound() then
				if v4 ~= nil and not gravityController.isAlive() then
					releaseCharacter() -- equivalent call inferred; original call site unknown
				end
			else
				gravityController.bind(v4)
			end

			gravityController.render(Common.GetDeltatime())

			if gravityController.isActive() and not (v3 or gravityController.isCameraLinked()) then
				v3 = true
				logger:warn("PlayerModule carries no gravity camera patch, the view will stay world-up (see docs/GravitySystem_Plan.md)")
			end
		end
	end
})
return GravityController