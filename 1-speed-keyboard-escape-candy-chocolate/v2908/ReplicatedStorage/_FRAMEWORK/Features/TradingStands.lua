local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local isServer = RunService:IsServer()
local Claims

if isServer then
	Claims = require(script.Claims)
else
	Claims = nil
end

local strictInterface = t.strictInterface({
	Key = t.string,
	Tier = t.integer,
	Limited = t.optional(t.integer),
	MaxLimited = t.optional(t.integer),
	Signature = t.optional(t.integer)
})
local TradingStands = {
	remotes = remo.createRemotes({
		tradingStands = remo.namespace({
			openStandConfig = remo.remote(),
			setStandHighlights = remo.remote(t.array(strictInterface)).middleware(remo.throttleMiddleware(0.35))
		})
	}).tradingStands
}
FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if isServer then
			local remotes = TradingStands.remotes
			remotes.setStandHighlights:connect(function(p, p2)
				Claims.setHighlights(p, p2)
			end)
			Claims.start(remotes)
		end
	end,
	OnUIInit = not isServer and function()
		local StandConfigModal = require(script.Client.StandConfigModal)
		local StandDisplay = require(script.Client.StandDisplay)
		StandDisplay.bind()
		StandConfigModal.bind(TradingStands.remotes)
	end or nil
})
return TradingStands