local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Systems = require(script.Systems)
require(script.Types)
local rayDebug = require(ReplicatedStorage._FRAMEWORK.Libraries.rayDebug)
local WallClimb = require(ReplicatedStorage._FRAMEWORK.Features.WallClimb)
local WallRide = require(ReplicatedStorage._FRAMEWORK.Features.WallRide)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local GravityZone = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityZone)
local Config = require(script.Config)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local MovementDebug = {}
local v = {}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshViewerMaster()
	local v3 = false

	for _, v4 in v2 do
		if v4 then
			v3 = true
		end
	end

	rayDebug.setEnabled(v3)
end

local function forwardTo(p: string)
	local systemColor = Config.systemColors[p]
	return function(p2, p3, p4, p5)
		if v2[p] and rayDebug.isEnabled() then
			rayDebug.draw(`{p}:{p2}`, p3, p4, p5, systemColor)
		end
	end
end

local function startClient()
	rayDebug.configure(Config.overrides)
	v = Systems.list()
	local v3 = Config.enabledInStudio and Common.IsStudio()

	for _, v4 in v do
		v2[v4.id] = v4.drawsProbes and v3
	end

	refreshViewerMaster() -- equivalent call inferred; original call site unknown
	local setProbeListener = WallClimb.setProbeListener
	local wallClimb = Config.systemColors.wallClimb
	local v4 = "wallClimb"
	setProbeListener(function(p, p2, p3, p4)
		if v2[v4] and rayDebug.isEnabled() then
			rayDebug.draw(`{v4}:{p}`, p2, p3, p4, wallClimb)
		end
	end)
	local setProbeListener2 = WallRide.setProbeListener
	local wallRide = Config.systemColors.wallRide
	local v5 = "wallRide"
	setProbeListener2(function(p, p2, p3, p4)
		if v2[v5] and rayDebug.isEnabled() then
			rayDebug.draw(`{v5}:{p}`, p2, p3, p4, wallRide)
		end
	end)
	local setProbeListener3 = GravityController.setProbeListener
	local gravityController = Config.systemColors.gravityController
	local v6 = "gravityController"
	setProbeListener3(function(p, p2, p3, p4)
		if v2[v6] and rayDebug.isEnabled() then
			rayDebug.draw(`{v6}:{p}`, p2, p3, p4, gravityController)
		end
	end)
	local setProbeListener4 = GravityZone.setProbeListener
	local gravityZone = Config.systemColors.gravityZone
	local v7 = "gravityZone"
	setProbeListener4(function(p, p2, p3, p4)
		if v2[v7] and rayDebug.isEnabled() then
			rayDebug.draw(`{v7}:{p}`, p2, p3, p4, gravityZone)
		end
	end)
	logger:info("Movement raycast viewer ready,", #v, "systems, drawing:", rayDebug.isEnabled())
end

function MovementDebug.getSystems()
	return v
end

function MovementDebug.setViewerEnabled(p: string, flag: boolean)
	assert(Common.IsClient(), "MovementDebug is client-only")
	v2[p] = flag
	refreshViewerMaster() -- equivalent call inferred; original call site unknown
end

function MovementDebug.isViewerEnabled(p: string)
	return v2[p] == true
end

function MovementDebug.setEnabled(flag: boolean)
	assert(Common.IsClient(), "MovementDebug is client-only")

	for _, v3 in v do
		v2[v3.id] = flag and v3.drawsProbes
	end

	refreshViewerMaster() -- equivalent call inferred; original call site unknown
end

function MovementDebug.isEnabled()
	return rayDebug.isEnabled()
end

function MovementDebug.toggle()
	MovementDebug.setEnabled(not rayDebug.isEnabled())
	return rayDebug.isEnabled()
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if Common.IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if Common.IsClient() then
			rayDebug.step()
		end
	end
})
return MovementDebug