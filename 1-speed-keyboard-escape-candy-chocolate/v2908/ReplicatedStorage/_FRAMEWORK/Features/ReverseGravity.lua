local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local GravityController = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.GravityController)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local remo = require(ReplicatedStorage.Packages.remo)
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local GameEvents

if RunService:IsServer() then
	GameEvents = require(ServerScriptService.GameEvents)
else
	GameEvents = nil
end

local ReverseGravity = {
	remotes = remo.createRemotes({
		toggleWorldReversed = remo.remote(),
		resetGravity = remo.remote()
	})
}
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = false
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function applyReversed(flag: boolean)
	v = flag
	GravityController.setSource("ReverseGravity", flag and createVector(-0, -1, -0) or nil, 100)
end

local function startClient()
	local maid = Janitor.new()
	v2 = maid
	maid:Add(ReverseGravity.remotes.toggleWorldReversed:connect(function()
		applyReversed(not v) -- equivalent call inferred; original call site unknown
	end))
	maid:Add(ReverseGravity.remotes.resetGravity:connect(GravityController.resetGravity))
	maid:Add(GravityController.onReset:Connect(function()
		applyReversed(false) -- equivalent call inferred; original call site unknown
	end))
	logger:info("ReverseGravity client feature started")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startServer()
	local maid = Janitor.new()
	v2 = maid
	maid:Add(GameEvents.PlayerTeleported:Connect(function(p)
		ReverseGravity.resetGravity(p)
	end))
end

function ReverseGravity.reverseGravity(p)
	assert(Common.IsServer(), "reverseGravity is server-only")
	ReverseGravity.remotes.toggleWorldReversed:fire(p)
	logger:info("gravity flip requested for", p.Name)
end

function ReverseGravity.resetGravity(p)
	assert(Common.IsServer(), "resetGravity is server-only")
	ReverseGravity.remotes.resetGravity:fire(p)
end

function ReverseGravity.setReversed(flag: boolean)
	assert(Common.IsClient(), "setReversed is client-only")
	applyReversed(flag) -- equivalent call inferred; original call site unknown
end

function ReverseGravity.isReversed()
	return v
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if Common.IsClient() then
			startClient()
			return
		end

		startServer() -- equivalent call inferred; original call site unknown
	end
})
return ReverseGravity