local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Rain = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
require(ReplicatedStorage.Controllers.AnimalController)
require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.ShakePresets)
require(ReplicatedStorage.Packages.Observers)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Rain/Hit")
local maid = Trove.new()

function Rain.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("Rain", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("Rain", nil)
	end)

	local function getTimeLeftForSync(p: number, p2: number?)
		return activeEventData.startedAt + p - (p2 or workspace:GetServerTimeNow())
	end

	local v = activeEventData.startedAt + 4 - workspace:GetServerTimeNow()
	local clone

	if ServerData.IsJumpLTMServer() then
		clone = nil
	elseif ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.RainWeatherTsunami)
	else
		clone = maid:Clone(script.RainWeather)
	end

	if clone then
		VFX.disable(clone)
		clone.Parent = workspace
	end

	if clone and ServerData.IsBiggerServer() then
		ClientEventUtils.resizeEffects(clone, 2)
	end

	maid:Add(task.delay(v, function()
		local atmosphere = Lighting:FindFirstChild("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone_2 = maid:Clone(script.AtmosphereRain)
		clone_2.Parent = Lighting
		local cartoon = Lighting:FindFirstChild("Cartoon")

		if cartoon then
			cartoon.Parent = script
			maid:Add(function()
				cartoon.Parent = Lighting
			end)
		end

		local clone_3 = maid:Clone(script.SkyRain)
		clone_3.Parent = Lighting

		if ServerData.IsJumpLTMServer() then
			maid:Add(JumpLTMWeather.Cover(script.RainWeather))
		elseif clone then
			VFX.enable(clone)
		end
	end))
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Rain.OnStop(_)
	maid:Destroy()
end

function Rain.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.StruckVFX, p, { ReplicatedStorage.Sounds.Events.Rain.Burst })
	end)
end

return Rain