local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local GravityZone = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityZone)
local ReverseGravity = require(ReplicatedStorage._FRAMEWORK.Features.ReverseGravity)
require(script.Parent.Types)
local Config = require(script.Parent.Config)
local wallClimb = require(ReplicatedStorage._FRAMEWORK.Libraries.wallClimb)
local wallRide = require(ReplicatedStorage._FRAMEWORK.Libraries.wallRide)

local function formatVector(vector: Vector3?)
	if vector then
		return string.format("%.2f, %.2f, %.2f", vector.X, vector.Y, vector.Z)
	end

	return "--"
end

local function formatNumber(p: number)
	return string.format("%.1f", p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatInstance(p)
	if p then
		return p.Name
	end

	return "--"
end

local function formatBool(flag: boolean)
	if flag then
		return "true"
	end

	return "false"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function boolTone(flag: boolean, flag2: boolean)
	if flag == flag2 then
		return "good"
	end

	return "neutral"
end

local function readGravityControllerRows()
	local active = GravityController.isActive()
	local grounded = GravityController.isGrounded()
	local cameraLinked = GravityController.isCameraLinked()
	local motionSuspended = GravityController.isMotionSuspended()
	local v = {
		label = "active",
		value = active and "true" or "false",
		tone = boolTone(active, true)
	}
	local v2 = {
		label = "source",
		value = GravityController.getSourceKey() or "--"
	}
	local up = GravityController.getUp()
	return {
		v,
		v2,
		{
			label = "up",
			value = not up and "--" or string.format("%.2f, %.2f, %.2f", up.X, up.Y, up.Z)
		},
		{
			label = "cameraLinked",
			value = cameraLinked and "true" or "false",
			tone = boolTone(cameraLinked, true)
		},
		{
			label = "grounded",
			value = grounded and "true" or "false",
			tone = grounded and "neutral" or "warn"
		},
		{
			label = "state",
			value = GravityController.getState()
		},
		{
			label = "standingPart",
			value = formatInstance(GravityController.getStandingPart())
		},
		{
			label = "motionSuspended",
			value = motionSuspended and "true" or "false",
			tone = motionSuspended and "warn" or "neutral"
		}
	}
end

local function readGravityZoneRows()
	local taggedCount = GravityZone.getTaggedCount()
	return {
		{
			label = "activePart",
			value = formatInstance(GravityZone.getActivePart())
		},
		{
			label = "taggedParts",
			value = tostring(taggedCount),
			tone = taggedCount > 0 and "neutral" or "warn"
		}
	}
end

local function readReverseGravityRows()
	local reversed = ReverseGravity.isReversed()
	return {
		{
			label = "reversed",
			value = reversed and "true" or "false",
			tone = boolTone(reversed, true)
		},
		{
			label = "gravitySource",
			value = GravityController.getSourceKey() or "--"
		}
	}
end

local function readWallClimbRows()
	local state = wallClimb.getState()
	local enabled = wallClimb.isEnabled()
	local surface = wallClimb.getSurface()
	local v2 = {
		label = "state",
		value = state,
		tone = state == "ready" and "good" or state == "spent" and "warn" or "neutral"
	}
	local v3 = {
		label = "enabled",
		value = enabled and "true" or "false",
		tone = boolTone(enabled, true)
	}
	local wallHeight = wallClimb.getWallHeight()
	local v4 = {
		label = "wallHeight",
		value = string.format("%.1f", wallHeight)
	}
	local boostSpeed = wallClimb.getBoostSpeed()
	local v5 = {
		label = "boostSpeed",
		value = string.format("%.1f", boostSpeed)
	}
	local part

	if surface then
		part = surface.part
	end

	local v6 = {
		label = "surface",
		value = formatInstance(part)
	}
	local normal

	if surface then
		normal = surface.normal
	end

	return {
		v2,
		v3,
		v4,
		v5,
		v6,
		{
			label = "normal",
			value = not normal and "--" or string.format("%.2f, %.2f, %.2f", normal.X, normal.Y, normal.Z)
		}
	}
end

local function readWallRideRows()
	local state = wallRide.getState()
	local enabled = wallRide.isEnabled()
	local surface = wallRide.getSurface()
	local v2 = {
		label = "state",
		value = state,
		tone = state == "riding" and "good" or state == "cooldown" and "warn" or "neutral"
	}
	local v3 = {
		label = "enabled",
		value = enabled and "true" or "false",
		tone = boolTone(enabled, true)
	}
	local v4 = {
		label = "side",
		value = wallRide.getSide() or "--"
	}
	local rideSpeed = wallRide.getRideSpeed()
	local v5 = {
		label = "rideSpeed",
		value = string.format("%.1f", rideSpeed)
	}
	local riddenDistance = wallRide.getRiddenDistance()
	local v6 = {
		label = "ridden",
		value = string.format("%.1f", riddenDistance)
	}
	local part

	if surface then
		part = surface.part
	end

	return {
		v2,
		v3,
		v4,
		v5,
		v6,
		{
			label = "surface",
			value = formatInstance(part)
		}
	}
end

return {
	list = function()
		local systemColors = Config.systemColors
		return {
			{
				id = "gravityController",
				label = "Gravity",
				color = systemColors.gravityController,
				drawsProbes = true,
				readRows = readGravityControllerRows
			},
			{
				id = "gravityZone",
				label = "Zone",
				color = systemColors.gravityZone,
				drawsProbes = true,
				readRows = readGravityZoneRows
			},
			{
				id = "reverseGravity",
				label = "Reverse",
				color = systemColors.reverseGravity,
				drawsProbes = false,
				readRows = readReverseGravityRows
			},
			{
				id = "wallClimb",
				label = "Climb",
				color = systemColors.wallClimb,
				drawsProbes = true,
				readRows = readWallClimbRows
			},
			{
				id = "wallRide",
				label = "Ride",
				color = systemColors.wallRide,
				drawsProbes = true,
				readRows = readWallRideRows
			}
		}
	end
}