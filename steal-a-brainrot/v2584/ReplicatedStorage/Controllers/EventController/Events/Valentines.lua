local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Valentines = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Valentines/Hit")
local maid = Trove.new()

function Valentines.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	ReplicatedStorage:SetAttribute("ValentinesEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("ValentinesEvent", nil)
	end)
	local clone

	if ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.MapTsunami)
	elseif ServerData.IsBiggerServer() then
		clone = maid:Clone(script.MapBigger)
	else
		clone = maid:Clone(script.Map)
	end

	clone.Parent = workspace
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereValentines)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.SkyValentines)
	clone_3.Parent = Lighting
	maid:Add(Observers.observeTag("HideInValentines", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	EffectController:Run("ValentinesEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("ValentinesEvent", "GrassRecolor")
	end)
	EffectController:Run("ValentinesEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("ValentinesEvent", "WallRecolor")
	end)
	EffectController:Run("ValentinesEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("ValentinesEvent", "WallBottomRecolor")
	end)
end

function Valentines.OnStop(_)
	maid:Destroy()
end

function Valentines.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Valentines.Hit })
	end)
end

return Valentines