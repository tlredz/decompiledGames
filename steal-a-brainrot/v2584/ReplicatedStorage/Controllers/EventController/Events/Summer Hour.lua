local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local SummerHour = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Spring = require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/SummerHour/Projectile")
local remoteEvent2 = Net:RemoteEvent("EventService/SummerHour/Burst")
local maid = Trove.new()
local v = Spring.new(11.203)
v.Speed = 10
v.Damper = 0.4
local v2 = Spring.new(0)
v2.Speed = 3
v2.Damper = 0.4
local v3 = Spring.new(0)
v3.Speed = 3
v3.Damper = 0.4
local v4 = Spring.new(0)
v4.Speed = 3
v4.Damper = 0.4
local target = 0.25
local target2 = 0
local target3 = 0
local v8 = false
local v9 = nil
local home = nil
local v10 = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getSun()
	local child = workspace.Events:FindFirstChild(name)
	return child and child:FindFirstChild("SunTrait")
end

local function aimEulerTo(vector2: Vector3)
	if not home then
		return 0, 0, 0
	end

	local rotation = CFrame.lookAt(home.Position, vector2).Rotation
	return (home.Rotation:Inverse() * rotation):ToEulerAnglesXYZ()
end

local function pulse(p: string)
	local animalPosition = ClientEventUtils.getAnimalPosition(p, {
		top = true
	})

	if not v9 or not home or animalPosition == createVector(0, 0, 0) then
		return
	end

	v:Impulse(130)
	task.spawn(function()
		VFX.emit(v9.RootPart.Bone.Burst)
		SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Summer Hour"].Shoot, v9:GetPivot().Position, false)
	end)
	local clone = v9:Clone()
	clone.Parent = workspace
	local animator = clone:FindFirstChildWhichIsA("Animator", true)
	local idleAnimation = script:FindFirstChild("IdleAnimation")

	if animator and idleAnimation and idleAnimation:IsA("Animation") then
		local track = animator:LoadAnimation(idleAnimation)
		track.Looped = true
		track:Play()
	end

	local pivot = v9:GetPivot()
	local position = pivot.Position
	local rotation = pivot.Rotation
	local serverTimeNow = workspace:GetServerTimeNow()
	local v11 = (animalPosition - position).Magnitude / 90
	local v12 = animalPosition
	local postSimulationConnection = nil
	postSimulationConnection = RunService.PostSimulation:Connect(function()
		local animalPosition2 = ClientEventUtils.getAnimalPosition(p, {
			top = true
		})

		if animalPosition2 ~= createVector(0, 0, 0) then
			v12 = animalPosition2
		end

		local v13 = workspace:GetServerTimeNow() - serverTimeNow
		local value = TweenService:GetValue(
			v11 == 0 and 1 or math.clamp(v13 / v11, 0, 1),
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		)
		local lerped = position:Lerp(v12, value)
		clone:PivotTo(CFrame.new(lerped) * rotation * CFrame.Angles(0, 0, value * 3.141592653589793 * 8))
		clone:ScaleTo((math.lerp(14.203, 1, value)))

		if value >= 1 then
			postSimulationConnection:Disconnect()
			clone:Destroy()
		end
	end)
	task.delay(10, function()
		if postSimulationConnection.Connected then
			postSimulationConnection:Disconnect()
		end

		if clone.Parent then
			clone:Destroy()
		end
	end)
end

function SummerHour.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	EffectController:Run("SummerHourEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("SummerHourEvent", "GrassRecolor")
	end)
	EffectController:Run("SummerHourEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("SummerHourEvent", "WallRecolor")
	end)
	EffectController:Run("SummerHourEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("SummerHourEvent", "WallBottomRecolor")
	end)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	v9 = getSun()

	if not v9 then
		return
	end

	home = v9:GetAttribute("Home") or v9:GetPivot()
	flag = true
	local animator = v9:FindFirstChildWhichIsA("Animator", true)
	local idleAnimation = script:FindFirstChild("IdleAnimation")

	if animator and idleAnimation and idleAnimation:IsA("Animation") then
		local track = animator:LoadAnimation(idleAnimation)
		track.Looped = true
		track:Play()
		v10 = track
	end

	target = 0.25
	target2 = 0
	target3 = 0
	maid:Add(RunService.PostSimulation:Connect(function()
		if not (flag and v9 and home) then
			return
		end

		local now = os.clock()
		v2.Target = target
		v3.Target = target2
		v4.Target = target3
		v9:ScaleTo(v.Position)
		v9:PivotTo(home * CFrame.Angles(v2.Position, v3.Position, v4.Position) + Vector3.new(
			0,
			math.sin(now * 1.75) * 7,
			0
		))
	end))
	maid:Add(task.spawn(function()
		while flag do
			if not v8 then
				target2 = 0
				target3 = 0
			end

			local v11 = os.clock() + math.random(20, 50) / 10
			local v12

			if math.random() < 0.5 then
				v12 = true
			else
				v12 = false
			end

			while flag and os.clock() < v11 do
				if not v8 then
					target = v12 and 0.5 or 0
					v12 = not v12
				end

				task.wait(math.random(80, 160) / 100)
			end

			task.wait(0.1)
		end
	end))
	maid:Add(function()
		flag = false
		v8 = false

		if v10 then
			v10:Stop(0)
			v10:Destroy()
			v10 = nil
		end

		if v9 then
			v9:ScaleTo(1)
		end

		v9 = nil
		home = nil
	end)
end

function SummerHour.OnStop(_)
	maid:Destroy()
end

function SummerHour.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, _: number, _: number, value: number, _: number)
		if not (flag and v9) then
			return
		end

		v8 = true
		local animalPosition = ClientEventUtils.getAnimalPosition(p, {
			top = true
		})
		local v11, v12, v13

		if home then
			local rotation = CFrame.lookAt(home.Position, animalPosition).Rotation
			v11, v12, v13 = (home.Rotation:Inverse() * rotation):ToEulerAnglesXYZ()
		else
			v11 = 0
			v12 = 0
			v13 = 0
		end

		target = v11
		target2 = v12
		target3 = v13
		task.wait(value or 0.7)

		if flag and v9 then
			pulse(p)
			task.delay(0.5, function()
				target = 0.25
				target2 = 0
				target3 = 0
				v8 = false
			end)
		else
			v8 = false
		end
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: string)
		local burst = script:FindFirstChild("Burst")

		if not burst then
			return
		end

		ClientEventUtils.playBurst(burst, p, { ReplicatedStorage.Sounds.Events["Summer Hour"].Burst })
	end)
end

return SummerHour