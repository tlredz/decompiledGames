local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local RipMyGranny = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local ripMyGranny = workspace.Sounds.RipMyGranny
local remoteEvent = Net:RemoteEvent("EventService/Rip My Granny/Projectile")
local remoteEvent2 = Net:RemoteEvent("EventService/Rip My Granny/Burst")
local maid = Trove.new()
local _ = workspace.CurrentCamera

local function enterSharedPhase()
	local ripMyGrannySharedPhase = ReplicatedStorage:GetAttribute("RipMyGrannySharedPhase") or workspace:GetServerTimeNow()
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	local clone

	if ServerData.IsBiggerServer() then
		clone = maid:Clone(script.BiggerGrannyMap)
	elseif ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.TsunamiGrannyMap)
	else
		clone = maid:Clone(script.GrannyMap)
	end

	clone.Parent = workspace
	CycleController:Update()
	SoundController:UpdateOST()
	maid:Add(task.spawn(function()
		ripMyGranny.SoundId = ""
		ripMyGranny.SoundId = "rbxassetid://97964528695055"

		while not ripMyGranny.IsLoaded do
			task.wait()
		end

		ripMyGranny.Looped = true
		local v = workspace:GetServerTimeNow() - ripMyGrannySharedPhase

		if ripMyGranny.TimeLength > 0 then
			ripMyGranny.TimePosition = v % 108.173
		end

		if v < 216.346 then
			ripMyGranny:Play()
		end

		maid:Add(task.delay(ripMyGrannySharedPhase + 216.346 - workspace:GetServerTimeNow(), function()
			ripMyGranny.Looped = false
			ripMyGranny:Stop()
		end))
		maid:Add(function()
			ripMyGranny.Looped = false
			ripMyGranny:Stop()
		end)
	end))
	EffectController:Run("RipMyGrannyEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("RipMyGrannyEvent", "GrassRecolor")
	end)
end

local v = nil

function RipMyGranny.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	CycleController:Update()
	SoundController:UpdateOST()
	local v2 = typeof(ReplicatedStorage:GetAttribute("RipMyGrannySharedPhase")) == "number"
	local maid2 = maid:Extend()

	if not v2 then
		local clone = maid2:Clone(script.RipMyGrannySammyRig)
		local pivot = clone:GetPivot()

		if ServerData.IsBiggerServer() then
			pivot += createVector(0, 0, -251)
		end

		clone:PivotTo(CFrame.new(0, 100000, 100000))
		clone.Parent = workspace
		local animation = SharedEventUtils.loadAnimation(maid2, clone.Humanoid.Animator, script.SammySpawn)
		animation.Looped = false
		animation.Priority = Enum.AnimationPriority.Action
		v = SharedEventUtils.loadAnimation(maid2, clone.Humanoid.Animator, script.SammyShoot)
		assert(v)
		v.Looped = false
		v.Priority = Enum.AnimationPriority.Action4
		maid:Add(function()
			v = nil
		end)
		local animation2 = SharedEventUtils.loadAnimation(maid2, clone.Humanoid.Animator, script.SammyIdle)
		animation2.Priority = Enum.AnimationPriority.Idle
		maid2:Add(task.spawn(function()
			while animation.Length == 0 do
				task.wait()
			end

			local timePosition = workspace:GetServerTimeNow() - activeEventData.startedAt

			if animation.Length < timePosition then
				return
			end

			animation.TimePosition = timePosition
			animation:Play(0)
			animation.TimePosition = timePosition
			animation2:Play(0)

			while not animation.IsPlaying do
				if animation.Length < timePosition then
					clone:PivotTo(pivot)
					return
				else
					task.wait()
				end
			end

			animation.TimePosition = timePosition
			clone:PivotTo(pivot)
		end))
	end

	maid:Add(Observers.observeTag("FlyingGrannyEvent", function(part)
		local maid3 = Trove.new()
		local clone = maid3:Clone(script.FlyingGranny)
		clone.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = part
		weld.C0 = clone.PrimaryPart.PivotOffset
		weld.Parent = clone.PrimaryPart
		local animation = SharedEventUtils.loadAnimation(
			maid3,
			clone.AnimationController.Animator,
			script.FlyingGrannyIdle
		)
		animation.Priority = Enum.AnimationPriority.Idle
		animation.Looped = true
		animation:Play()
		local animation2 = SharedEventUtils.loadAnimation(
			maid3,
			clone.AnimationController.Animator,
			script.FlyingGrannyWalk
		)
		animation2.Priority = Enum.AnimationPriority.Action
		animation2.Looped = true
		local animation3 = SharedEventUtils.loadAnimation(
			maid3,
			clone.AnimationController.Animator,
			script.FlyingGrannyAttack
		)
		animation3.Priority = Enum.AnimationPriority.Action2
		animation3.Looped = false
		maid3:Add(part:GetAttributeChangedSignal("Attack"):Connect(function()
			animation3:Play()
		end))
		maid3:Add(Observers.observeAttribute(part, "Flying", function(p)
			if p then
				animation2:Play()
			else
				animation2:Stop()
			end

			return nil
		end))
		maid3:Add(part:GetAttributeChangedSignal("Attack"):Connect(function() end))
		return maid3:WrapClean()
	end, { workspace }))
	maid:Add(Observers.observeTag("HideInRipMyGranny", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))

	if not ReplicatedStorage:GetAttribute("RipMyGrannySharedPhase") then
		maid:Add(ReplicatedStorage:GetAttributeChangedSignal("RipMyGrannySharedPhase"):Connect(function()
			if ReplicatedStorage:GetAttribute("RipMyGrannySharedPhase") then
				maid2:Clean()
				enterSharedPhase()
			end
		end))
		return
	end

	maid2:Clean()
	enterSharedPhase()
end

function RipMyGranny.OnStop(_)
	maid:Destroy()
end

function RipMyGranny.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: number, p3: number, p4: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function getFromCFrame()
			local ripMyGrannySammyRig = workspace:FindFirstChild("RipMyGrannySammyRig")
			return ripMyGrannySammyRig and ripMyGrannySammyRig["Sammy Bazooka"].Ammo.CFrame or script.RipMyGrannySammyRig["Sammy Bazooka"].Ammo.CFrame
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getWaist()
			local ripMyGrannySammyRig = workspace:FindFirstChild("RipMyGrannySammyRig")
			return ripMyGrannySammyRig and ripMyGrannySammyRig.UpperTorso.Waist
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getRootPosition()
			local ripMyGrannySammyRig = workspace:FindFirstChild("RipMyGrannySammyRig")
			return ripMyGrannySammyRig and ripMyGrannySammyRig.HumanoidRootPart.CFrame
		end

		local v2 = false
		local clone = maid:Clone(script.Projectile)
		local v3 = p2 + p4
		local v4 = v3 + p3
		local C0 = nil
		local v5 = nil
		local v6 = nil
		v6 = maid:Add(RunService.PreRender:Connect(function()
			debug.profilebegin("RipMyGranny:Projectile")
			local serverTimeNow = workspace:GetServerTimeNow()
			local v7 = math.max(v4 - serverTimeNow, 0)
			local v8 = serverTimeNow < v3 and 0 or 1 - v7 / p3

			if v8 >= 0.95 then
				if v6 then
					maid:Remove(v6)
					v6 = nil
				end

				maid:Remove(clone)
				ClientEventUtils.playBurst(script.Explosion, ClientEventUtils.getAnimalPosition(p, {
					top = true
				}), {})
				debug.profileend()
			else
				local animalPosition = ClientEventUtils.getAnimalPosition(p)

				if v8 > 0 and not v2 then
					v2 = true
					local position = (getFromCFrame()).Position
					clone:PivotTo(CFrame.lookAt(position, position + (animalPosition - position).Unit))
					clone.Parent = workspace
					task.spawn(function()
						SoundController:PlaySound(
							ReplicatedStorage.Sounds.Events["Rip My Granny"].EventShoot,
							position,
							false
						)
					end)

					if v then
						v:Play(0.05, 1, 1.5)
					end

					local ripMyGrannySammyRig = workspace:FindFirstChild("RipMyGrannySammyRig")

					if ripMyGrannySammyRig then
						ripMyGrannySammyRig["Sammy Bazooka"].Ammo.Transparency = 1
					end
				end

				local waist = getWaist() -- equivalent call inferred; original call site unknown
				local rootPosition = getRootPosition() -- equivalent call inferred; original call site unknown

				if waist and rootPosition then
					if not C0 then
						C0 = waist.C0
					end

					local vectorToObjectSpace = rootPosition:VectorToObjectSpace((animalPosition - rootPosition.Position).Unit)
					local v9 = math.clamp(
						math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
						-1.0471975511965976,
						1.0471975511965976
					)
					local v10 = math.clamp(
						math.asin((math.clamp(vectorToObjectSpace.Y, -1, 1))),
						-0.2617993877991494,
						0.2617993877991494
					)
					Spr.target(waist, 1, 2, {
						C0 = C0 * CFrame.Angles(v10, v9, 0)
					})
				end

				if v8 <= 0 then
					debug.profileend()
					return
				end

				local value = TweenService:GetValue(v8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

				if not v5 then
					v5 = getFromCFrame()
				end

				local position = v5.Position
				local lerped = position:Lerp(animalPosition, value)
				clone:PivotTo(CFrame.lookAt(lerped, lerped + (animalPosition - position).Unit) * CFrame.Angles(
					0,
					0,
					-value * 6 * 3.141592653589793
				))
				clone.Size = script.Projectile.Size:Lerp(script.Projectile.Size / 5, value)
				debug.profileend()
			end
		end))
	end)
	remoteEvent2.OnClientEvent:Connect(function(_: string, p: string)
		maid:Add(ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Rip My Granny"].Hit }))
	end)
end

return RipMyGranny