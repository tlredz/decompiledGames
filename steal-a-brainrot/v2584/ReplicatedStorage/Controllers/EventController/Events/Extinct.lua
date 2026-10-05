local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.EventTypes)
local Extinct = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Extinct/Burst")
local maid = Trove.new()

function Extinct.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	EffectController:Run("ExtinctEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("ExtinctEvent", "GrassRecolor")
	end)
	EffectController:Run("ExtinctEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("ExtinctEvent", "WallRecolor")
	end)
	local clone = maid:Clone(script.Map)
	clone.Parent = workspace
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	CycleController:Update()
	SoundController:UpdateOST()
	EffectController:Activate("Blink")
end

function Extinct.OnStop(_)
	maid:Destroy()
end

function Extinct.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Extinct.Hit })
	end)
end

return Extinct