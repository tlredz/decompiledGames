-- failed to load script (decompiled with syntax error):
-- JbNedzXKRBcMcleuGOyhnzbcb:123: Expected identifier when parsing expression, got `FocusMyGame43_{

local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Mygame43 = {}
local SkullEmojiEffectController = require(ReplicatedStorage.Controllers.SkullEmojiEffectController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Shared.MapInformation)
require(ReplicatedStorage.Packages.CreateTween)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Shake = require(ReplicatedStorage.Packages.Shake)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Mygame43/CreateLightningOrb")
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Events["Los Matteos"].Areas }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local currentCamera = workspace.CurrentCamera
local maid = Trove.new()
local v = Shake.new()
v.Amplitude = 5.5
v.Frequency = 0.05
v.FadeInTime = 0
v.FadeOutTime = 0.6
v.PositionInfluence = createVector(0.5, 0.5, 0.5)
v.RotationInfluence = createVector(2.5, 0.5, 0.5)

local function shakeCameraBasedOnProximity(position: Vector3)
	local magnitude = (currentCamera.CFrame.Position - position).Magnitude

	if magnitude <= 300 then
		local clone = v:Clone()
		local v2 = (1 - magnitude / 300 * 0.5) ^ 2
		clone.Amplitude *= v2
		clone.RotationInfluence *= v2
		maid:Add(ShakePresets.BindShakeToCamera(clone))
		clone:Start()
	end
end

function Mygame43.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p: number)
		return activeEventData.startedAt + p - workspace:GetServerTimeNow()
	end

	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	local v2 = nil

	local function getOrbPosition(p: number)
		local v3 = (p == 2 or p == 3) and 70 or 50
		local cframe = CFrame.new((p - 1) * 30 + -45, v3, 15)

		if v2 then
			return v2.HumanoidRootPart.CFrame * cframe
		end

		return cframe
	end

	ReplicatedStorage.Sounds.Events.Mygame43.Appear:Play()
	maid:Add(Observers.observeTag("Mygame43", function(p)
		v2 = p
		assert(v2)
		local track = v2.Humanoid.Animator:LoadAnimation(script.Idle)
		local track2 = v2.Humanoid.Animator:LoadAnimation(script.Spawn)
		track:Play()
		track2:Play()
		track2.TimePosition = 7 - calculateTimeLeftFor(7)
		maid:Add(task.delay(calculateTimeLeftFor(7.7), function()
			for i = 1, 4 do
				local v3 = (i == 2 or i == 3) and 70 or 50
				local cframe = CFrame.new((i - 1) * 30 + -45, v3, 15)

				if v2 then
					cframe = v2.HumanoidRootPart.CFrame * cframe
				end

				local clone = maid:Clone(script.Orb)
				clone.CFrame = cframe - createVector(0, 100, 0)
				clone.Parent = workspace
				maid:Add(function()
					Spr.stop(clone)
				end)
				local v5 = clone
				local v7 = i
				local v8 = Random.new():NextNumber(2, 3)
				maid:Add(RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("Mygame43:FloatOrb")
					Spr.target(v5, 0.8, 1, {
						Pivot = cframe + Vector3.new(0, math.sin((os.clock() + v7 * 90) * v8) * 4, 0)
					})
					debug.profileend()
				end))
			end
		end))
		maid:Add(task.delay(calculateTimeLeftFor(3.6999999999999997), function()
			VFX.enable(v2);
			`FocusMyGame43_{os.clock() // 1}`
			local preRenderConnection = RunService.PreRender:Connect(function(dt: number)
				debug.profilebegin("Mygame43:Focus")
				local cFrame = currentCamera.CFrame
				currentCamera.CFrame = cFrame:Lerp(CFrame.lookAt(cFrame.Position, v2:GetPivot().Position), dt ^ 0.45)
				debug.profileend()
			end)
			task.delay(0.6, function()
				preRenderConnection:Disconnect()
				SkullEmojiEffectController:Play(3, "Lower")
			end)
		end))
		return nil
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: number, p2: number, position: Vector3, p3: number, flag: boolean?)
		local v3 = (p2 == 2 or p2 == 3) and 70 or 50
		local cframe = CFrame.new((p2 - 1) * 30 + -45, v3, 15)

		if v2 then
			cframe = v2.HumanoidRootPart.CFrame * cframe
		end

		local position2 = cframe.Position
		local clone = maid:Clone(script.OrbSmaller)
		clone.CFrame = CFrame.new(position2)
		local clone2 = ReplicatedStorage.Sounds.Events.Mygame43.OrbFlying:Clone()
		clone2.Parent = clone
		clone.Parent = workspace
		clone2:Play()
		VFX.enable(clone)
		local random = Random.new(p)
		local v4 = position2 + (position - position2) * 0.25 + Vector3.new(
			random:NextNumber(50, 100) * (random:NextInteger(0, 1) * 2 - 1),
			random:NextInteger(300, 400),
			0
		)
		local v5 = position2 + (position - position2) * 0.6 + Vector3.new(
			random:NextNumber(50, 150) * (random:NextInteger(0, 1) * 2 - 1),
			random:NextInteger(100, 200),
			0
		)
		local total = 0
		local v6 = nil
		v6 = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
			debug.profilebegin("Mygame43:UpdateOrb")
			total += dt
			local value = TweenService:GetValue(total / p3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			SharedEventUtils.pushPartCFrame(
				clone,
				CFrame.new(MathUtils.cubicBezier(value, position2, v4, v5, position))
			)

			if value >= 1 and v6 then
				maid:Remove(v6)
				v6 = nil
				VFX.disable(clone)
				task.delay(3, function()
					maid:Remove(clone)
				end)
				shakeCameraBasedOnProximity(position)
				local clone3

				if flag then
					clone3 = script.StrikeBrainrot:Clone()
				else
					clone3 = script.Strike:Clone()
				end

				clone3.Position = position
				clone3.Parent = workspace
				VFX.emit(clone3)
				task.delay(4, function()
					clone3:Destroy()
				end)

				if flag then
					SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Los Matteos"].Hit, position, false)
				else
					SoundController:PlaySound(ReplicatedStorage.Sounds.Events.Mygame43.OrbHitNothing, position, false)
				end
			end

			debug.profileend()
		end))
	end))
end

function Mygame43.OnStop(_)
	maid:Destroy()
end

function Mygame43.OnLoad(_) end

return Mygame43