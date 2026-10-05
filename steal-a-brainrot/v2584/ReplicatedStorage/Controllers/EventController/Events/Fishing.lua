local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Fishing = {}
require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
local TweenPivot = require(ReplicatedStorage.Shared.TweenPivot)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local Mutations2 = require(ReplicatedStorage.Shared.Mutations)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Shared.VFX)
local _ = Players.LocalPlayer
local _ = workspace.CurrentCamera
local name = script.Name
local maid = Trove.new()

local function loadAnimation(animator, animation, p)
	local track = animator:LoadAnimation(animation);
	(p or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

function Fishing.OnStart(_)
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

	if ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.FishingMapTsunami)
	elseif ServerData.IsBiggerServer() then
		clone = maid:Clone(script.FishingMapBigger)
	else
		clone = maid:Clone(script.FishingMap)
	end

	clone.Parent = workspace
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	local pivot = clone.Flood:GetPivot()
	clone.Flood:PivotTo(pivot - createVector(0, 3, 0))
	maid:Add(TweenPivot(
		clone.Flood,
		TweenInfo.new(
			activeEventData.startedAt + 3 - workspace:GetServerTimeNow(),
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut
		),
		pivot
	)):Play()
	maid:Add(Observers.observeTag("FishermanPrompt", function(p)
		local triggeredConnection = p.Triggered:Connect(function()
			InterfaceController:Toggle("RodsShop")
		end)
		return function()
			triggeredConnection:Disconnect()
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function darken(mainColor: Color3, value: number)
		local v = math.clamp(value, 0, 1)
		local HSV, v2, v3 = mainColor:ToHSV()
		local v4 = v3 * v
		return Color3.fromHSV(HSV, v2, v4)
	end

	local function updateFloodColor()
		local v = Mutations2.get()

		if v then
			local mutation = Mutations[v]
			Spr.target(clone.Flood.TopWater["Water.001"], 1, 4, {
				Color = mutation.MainColor
			})
			Spr.target(clone.Flood.Water["Water.001"], 1, 4, {
				Color = darken(mutation.MainColor, 0.5)
			})
		else
			Spr.target(clone.Flood.TopWater["Water.001"], 1, 4, {
				Color = Color3.fromRGB(73, 161, 255)
			})
			Spr.target(clone.Flood.Water["Water.001"], 1, 4, {
				Color = Color3.fromRGB(0, 103, 172)
			})
		end
	end

	maid:Add(Mutations2.watch(updateFloodColor))
	updateFloodColor()
end

function Fishing.OnStop(_)
	maid:Destroy()
end

function Fishing.OnLoad(_) end

return Fishing