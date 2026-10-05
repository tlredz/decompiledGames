local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local EncryptedAssetsController = require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local TweenPivot = require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local indonesiaEvent = workspace.Sounds.IndonesiaEvent
local _ = Players.LocalPlayer
local _ = workspace.CurrentCamera
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Indonesia/Burst")
local _ = workspace.RenderedMovingAnimals
local maid = Trove.new()

local function loadAnimation(animator, animation, p)
	local track = animator:LoadAnimation(animation);
	(p or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local Indonesia = {}

function Indonesia.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	local function calculateTimeLeft(p: number)
		return (math.max(activeEventData.startedAt + p - workspace:GetServerTimeNow(), 0))
	end

	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
	end)
	local clone

	if ServerData.IsBiggerServer() then
		clone = maid:Clone(script.MapBigger)
	else
		clone = maid:Clone(script.Map)
	end

	clone.Parent = workspace
	maid:Add(Observers.observeTag("HideInIndonesia", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	EffectController:Run("IndonesiaEvent", "GrassRecolor")
	EffectController:Run("IndonesiaEvent", "WallRecolor")
	EffectController:Run("IndonesiaEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("IndonesiaEvent", "GrassRecolor")
		EffectController:Stop("IndonesiaEvent", "WallRecolor")
		EffectController:Stop("IndonesiaEvent", "WallBottomRecolor")
	end)

	if ServerData.IsBiggerServer() then
		ClientEventUtils.resizeEffects(clone.MapVFX, 2)
	end

	VFX.enable(clone.MapVFX.Waterfall)
	local v = activeEventData.startedAt + 13 - workspace:GetServerTimeNow()
	task.spawn(function()
		if v > 10 then
			SoundController:PlaySound(
				ReplicatedStorage.Sounds.Events.Indonesia.Activating,
				clone.MapVFX.Waterfall.indonesiawaterfall.Position,
				false
			)
		end
	end)
	local pivot = clone.Flood:GetPivot()
	clone.Flood:PivotTo(pivot - createVector(0, 3, 0))
	maid:Add(TweenPivot(clone.Flood, TweenInfo.new(v, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), pivot)):Play()
	maid:Add(task.delay(activeEventData.startedAt + 87.78999999999999 - workspace:GetServerTimeNow(), function()
		ReplicatedStorage:SetAttribute("IndonesiaEventPart2", true)
		CycleController:Update()
		SoundController:UpdateOST()
		maid:Add(function()
			ReplicatedStorage:SetAttribute("IndonesiaEventPart2", nil)
			CycleController:Update()
			SoundController:UpdateOST()
		end)
	end))
	maid:Add(task.delay(v, function()
		VFX.disable(clone.MapVFX.Waterfall)
		ReplicatedStorage:SetAttribute("IndonesiaEventAmbience", true)
		maid:Add(function()
			ReplicatedStorage:SetAttribute("IndonesiaEventAmbience", nil)
		end)
	end))
	maid:Add(task.spawn(function()
		indonesiaEvent.Volume = 0
		CreateTween(indonesiaEvent, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Volume = 0.35
		})
		EncryptedAssetsController:WaitForAssetId("rbxassetid://123847828745026")
		indonesiaEvent.SoundId = ""
		indonesiaEvent.SoundId = "rbxassetid://123847828745026"

		while not indonesiaEvent.IsLoaded do
			task.wait()
		end

		indonesiaEvent.TimePosition = 62 + (workspace:GetServerTimeNow() - activeEventData.startedAt)
		indonesiaEvent:Play()
		maid:Add(function()
			indonesiaEvent:Stop()
		end)
	end))
end

function Indonesia.OnStop(_)
	maid:Destroy()
end

function Indonesia.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	task.spawn(function()
		EncryptedAssetsController:WaitForAssetId("rbxassetid://123847828745026")
		indonesiaEvent.SoundId = "rbxassetid://123847828745026"
		ContentProvider:PreloadAsync({ indonesiaEvent })
	end)
	Observers.observeTag("IndonesiaCanoe", function(p)
		local maid2 = Trove.new()
		local clone = maid2:Clone(script.Canoe)
		local primaryPart = clone.PrimaryPart
		clone.Parent = p
		local weld = Instance.new("Weld")
		weld.Part0 = primaryPart
		weld.Part1 = p
		weld.C0 = CFrame.Angles(0, 3.141592653589793, 0)
		weld.Parent = primaryPart
		local track = clone["Bambu Bambu Sahur"].AnimationController.Animator:LoadAnimation(script.BambuDance);
		(maid2 or maid):Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		track.Looped = true
		track:Play()
		maid2:Add(RunService.PreRender:Connect(function()
			local v = math.clamp(indonesiaEvent.PlaybackLoudness / 1000, 0, 1)
			track:AdjustSpeed((math.lerp(1.3, 2, v)))
		end))
		return maid2:WrapClean()
	end, { workspace })
	remoteEvent.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Indonesia.BrainrotHit })
	end)
end

return Indonesia