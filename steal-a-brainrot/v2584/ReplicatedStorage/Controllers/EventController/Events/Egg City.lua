local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.EventTypes)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local WorldBrainrotController = require(ReplicatedStorage.Controllers.WorldBrainrotController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Trove = require(ReplicatedStorage.Packages.Trove)
local EggVisuals = require(script.EggVisuals)
local name = script.Name
local maid = Trove.new()
local EggCity = {}

function EggCity.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	EffectController:Run("EggCityEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("EggCityEvent", "GrassRecolor")
	end)
	EffectController:Run("EggCityEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("EggCityEvent", "WallRecolor")
	end)
	EffectController:Run("EggCityEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("EggCityEvent", "WallBottomRecolor")
	end)
	maid:Add(Observers.observeTag("HideInEggCity", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			p.Parent = parent
		end
	end, { workspace, script }))
	maid:Add(Observers.observeTag("EggCityDoor", function(instance)
		local pivot = instance:GetPivot()
		return Observers.observeAttribute(instance, "Open", function(p)
			if p then
				Spr.target(instance, 0.75, 3.5, {
					Pivot = pivot * CFrame.Angles(0, 1.5707963267948966, 0)
				})
			else
				Spr.target(instance, 0.75, 3.5, {
					Pivot = pivot
				})
			end

			return nil
		end)
	end))

	if ServerData.IsBiggerServer() then
		local clone = maid:Clone(script.EggCityMapBigger)
		clone.Parent = workspace
	else
		local clone_2 = maid:Clone(script.EggCityMap)
		clone_2.Parent = workspace
	end

	maid:Add(EggVisuals:Start())
	maid:Add(WorldBrainrotController:RenderPool({
		PoolId = "EggCity/Brainrots",
		ReplicatorId = "EggCity/Brainrots",
		ShowTimer = true,
		ShowDropButton = true,
		GrabHoldDuration = 2,
		GrabMaxDistance = 10
	}))
	return nil
end

function EggCity.OnStop(_)
	maid:Destroy()
end

function EggCity.OnLoad(_)
	Observers.observeTag("ShowInEggCity", function(instance)
		local parent = instance.Parent
		local v = false
		local destroyingConnection = parent.Destroying:Once(function()
			v = true
			instance:Destroy()
		end)
		instance.Parent = script
		return function()
			destroyingConnection:Disconnect()

			if not v then
				pcall(function()
					instance.Parent = parent
				end)
			end
		end
	end, { workspace, script })
end

return EggCity