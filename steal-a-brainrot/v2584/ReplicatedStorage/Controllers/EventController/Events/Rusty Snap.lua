game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("TweenService")
game:GetService("SoundService")
game:GetService("HttpService")
game:GetService("StarterGui")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local RustySnap = {}
local SkullEmojiEffectController = require(ReplicatedStorage.Controllers.SkullEmojiEffectController)
require(ReplicatedStorage.Controllers.CharacterController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.Serialization)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.ShakePresets)
require(ReplicatedStorage.Packages.TopbarPlus)
require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Packages.Moonlite)
require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.Squash)
require(ReplicatedStorage.Packages.Shake)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local _ = workspace.RenderedMovingAnimals
local name = script.Name
local maid = Trove.new()

function RustySnap.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p: number)
		return activeEventData.startedAt + 0 + p - workspace:GetServerTimeNow()
	end

	local clone = maid:Clone(script.Rusty)
	clone.Parent = workspace
	local clone2 = maid:Clone(ReplicatedStorage.Sounds.Events["Rusty Snap"].Fire)
	clone2.Parent = clone.HumanoidRootPart
	clone2:Play()
	local clone3 = maid:Clone(ReplicatedStorage.Sounds.Events["Rusty Snap"].Walk)
	clone3.Parent = clone.HumanoidRootPart
	clone3:Play()
	local _ = activeEventData.startedAt + 11.17 - workspace:GetServerTimeNow()
	local track = clone.Humanoid.Animator:LoadAnimation(script.WalkAnimation)
	track.Looped = true
	maid:Add(track, "Stop")
	maid:Add(track)
	local track2 = clone.Humanoid.Animator:LoadAnimation(script.SnapAnimation)
	track2.Looped = false
	maid:Add(track2, "Stop")
	maid:Add(track2)
	maid:Add(track2:GetMarkerReachedSignal("Freeze"):Connect(function()
		track2:AdjustSpeed(0)
	end))
	track:Play()
	local v = ServerData.IsTsunamiServer() and 350 or ServerData.IsBiggerServer() and 250 or 150
	local cFrame

	if ServerData.IsTsunamiServer() then
		cFrame = script.StartTsunami.CFrame
	else
		cFrame = workspace.Road.StartGround.CFrame
	end

	local v2 = ServerData.IsTsunamiServer() and 10 or 1
	local v3 = ServerData.IsTsunamiServer() and 50 or 13.9
	maid:Add(RunService.PostSimulation:Connect(function(_: number)
		debug.profilebegin("Rusty Snap:Update")
		local v4 = math.clamp((9 - calculateTimeLeftFor(9)) / 9, 0, 1)
		clone:PivotTo(cFrame:Lerp(cFrame + Vector3.new(0, 0, v), v4))
		clone:ScaleTo((math.lerp(v2, v3, v4 * v4)))
		debug.profileend()
	end))
	maid:Add(task.delay(calculateTimeLeftFor(9), function()
		track2:Play()
	end))
	maid:Add(task.delay(calculateTimeLeftFor(9.5), function()
		SkullEmojiEffectController:Play(2.5, "Lower")
	end))
	maid:Add(task.delay(calculateTimeLeftFor(9.5), function()
		ReplicatedStorage.Sounds.Events["Rusty Snap"].Snap:Play()
		local leftHand = clone.LeftHand
		local clone4 = maid:Clone(script.Snap)
		clone4.CFrame = leftHand.CFrame
		clone4.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone4
		weld.Part1 = leftHand
		weld.Parent = clone4
		VFX.emit(clone4)
	end))
	maid:Add(task.delay(calculateTimeLeftFor(12), function()
		SkullEmojiEffectController:Stop()
		EffectController:Activate("Blink")
		maid:Remove(clone)
	end))
end

function RustySnap.OnStop(_)
	maid:Destroy()
end

function RustySnap.OnLoad(_) end

return RustySnap