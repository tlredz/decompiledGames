local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Snow = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
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
local remoteEvent = Net:RemoteEvent("EventService/Snow/Hit")
local maid = Trove.new()

function Snow.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("Snow", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("Snow", nil)
	end)

	local function getTimeLeftForSync(p: number, p2: number?)
		return activeEventData.startedAt + p - (p2 or workspace:GetServerTimeNow())
	end

	local v = activeEventData.startedAt + 4 - workspace:GetServerTimeNow()
	local clone

	if ServerData.IsJumpLTMServer() then
		clone = nil
	elseif ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.SnowWeatherTsunami)
	else
		clone = maid:Clone(script.SnowWeather)
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

		local clone_2 = maid:Clone(script.AtmosphereSnow)
		clone_2.Parent = Lighting
		local cartoon = Lighting:FindFirstChild("Cartoon")

		if cartoon then
			cartoon.Parent = script
			maid:Add(function()
				cartoon.Parent = Lighting
			end)
		end

		local clone_3 = maid:Clone(script.SkySnow)
		clone_3.Parent = Lighting

		if ServerData.IsJumpLTMServer() then
			maid:Add(JumpLTMWeather.Cover(script.SnowWeather))
		elseif clone then
			VFX.enable(clone)
		end
	end))
	EffectController:Run("Snow", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("Snow", "GrassRecolor")
	end)
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Snow.OnStop(_)
	maid:Destroy()
end

function Snow.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.StruckVFX, p, { ReplicatedStorage.Sounds.Events.Snow.Burst })
	end)

	local function tweenPile(instance)
		task.wait(math.random() * 0.8)
		local v = instance:GetPivot() * CFrame.new(0, 10, 0)
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = instance:GetPivot()
		local changedConnection = cFrameValue.Changed:Connect(function(cframe)
			instance:PivotTo(cframe)
		end)
		local tween = TweenService:Create(cFrameValue, TweenInfo.new(1.2), {
			Value = v
		})
		tween:Play()
		tween.Completed:Connect(function()
			changedConnection:Disconnect()
			cFrameValue:Destroy()
			instance:PivotTo(v)
		end)
	end

	local function onPilesAdded(instance)
		for _, part in instance:GetChildren() do
			if part:IsA("BasePart") then
				task.spawn(tweenPile, part)
			end
		end
	end

	maid:Add(CollectionService:GetInstanceAddedSignal("SnowPile"):Connect(function(model)
		if model:IsA("Model") then
			task.spawn(tweenPile, model)
		end
	end))

	for _, model in CollectionService:GetTagged("SnowPile") do
		if model:IsA("Model") then
			task.spawn(tweenPile, model)
		end
	end
end

return Snow