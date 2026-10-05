local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local ayMiGatito = workspace.Sounds.AyMiGatito
local localPlayer = Players.LocalPlayer
local name = script.Name
local maid = Trove.new()
local remoteEvent = Net:RemoteEvent("EventService/AyMiGatito/Burst")

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, p)
	local track = animator:LoadAnimation(animation);
	(p or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function calculateSpeedFromMusicPosition(p: number)
	if p >= 43 and p < 48 then
		return 0.4
	end

	if p >= 48 and p < 50 then
		return (p - 48) / 2 * 0.3 + 0.4
	end

	if p >= 50 and p < 55.5 then
		return 0.7
	end

	if p >= 55.5 and p < 57 then
		return (p - 55.5) / 1.5 * 0.3 + 0.7
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function calculateAnimationSpeed(p: number, _: boolean)
	if p < 7 then
		return 0
	end

	local v = p - 7

	if p >= 222.313 then
		return (math.max(0, 1 - (p - 222.313) / 3))
	end

	return calculateSpeedFromMusicPosition(v % 72.771)
end

local function calculateMusicTimePosition(p: number)
	if p < 7 then
		return 0, false
	end

	local v = p - 7
	return v % 72.771, v < 218.313
end

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v = table.create(2)
	maid2:Add(function()
		table.clear(v)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Ay Mi Gatito Event Activation")
		total += dt

		for k, v2 in v do
			if not (v2.target and v2.targetAttachment) then
				continue
			end

			v2.beam.First.Enabled = true
			v2.beam.Second.Enabled = true
			local v3 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v2.beam.WorldPosition
			v2.targetAttachment.Position = worldPosition + (v2.target:GetPivot().Position - worldPosition) * v3
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("AyMiGatitoPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local ayMiGatitoIndex = parent:GetAttribute("AyMiGatitoIndex")
		v[ayMiGatitoIndex] = {
			beam = clone,
			target = nil
		}
		local v2 = Observers.observeTag("AyMiGatitoPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("AyMiGatitoIndex") == parent:GetAttribute("AyMiGatitoIndex") % 2 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v3 = v[parent:GetAttribute("AyMiGatitoIndex")]
			v3.target = target
			v3.beam.First.Attachment0 = attachment
			v3.beam.Second.Attachment0 = attachment
			v3.targetAttachment = attachment
			return function()
				attachment:Destroy()
			end
		end)
		return function()
			clone2:Destroy()
			clone:Destroy()
			v2()
			v[ayMiGatitoIndex] = nil
		end
	end))
end

local function initGatitoObserver(activeEventData)
	local v = {}
	maid:Add(RunService.PostSimulation:Connect(function(_: number)
		if #v == 0 then
			return
		end

		local v2 = workspace:GetServerTimeNow() - activeEventData.startedAt

		if not (v2 < 7) then
			local v3 = v2 - 7
			local _ = v3 % 72.771
			local _ = v3 < 218.313
		end

		local animationSpeed = calculateAnimationSpeed(v2) -- equivalent call inferred; original call site unknown

		for _, v4 in v do
			if v4.dance and v4.dance.IsPlaying then
				v4.dance:AdjustSpeed(animationSpeed)
			end

			if v4.walk and v4.walk.IsPlaying then
				v4.walk:AdjustSpeed(animationSpeed)
			end

			if v4.idle and v4.idle.IsPlaying then
				v4.idle:AdjustSpeed(animationSpeed)
			end
		end
	end))
	maid:Add(function()
		table.clear(v)
	end)
	maid:Add(Observers.observeTag("Gatito", function(parent)
		local maid2 = Trove.new()
		local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
		local variant = parent:GetAttribute("Variant") or "Gatito"
		local clone = maid2:Clone(script.Gatitos:FindFirstChild(variant) or script.Gatitos.Gatito)
		local v2 = maid2:Add(Instance.new("Weld"))
		v2.Part0 = clone.PrimaryPart
		v2.Part1 = humanoidRootPart
		v2.Parent = clone.PrimaryPart
		clone.Parent = parent
		local animationController = clone:FindFirstChild("AnimationController")

		if animationController then
			animationController:Destroy()
		end

		local humanoid = Instance.new("Humanoid", clone)
		Instance.new("Animator", humanoid)
		humanoid.Name = "AnimationController"
		humanoid.EvaluateStateMachine = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.PlatformStand = true
		humanoid.Parent = clone
		local animator = clone.AnimationController.Animator
		local track = nil
		local track2 = nil
		local gatitoDance1 = script:FindFirstChild("GatitoDance1")
		local track3

		if gatitoDance1 then
			track3 = animator:LoadAnimation(gatitoDance1);
			(maid2 or maid):Add(function()
				track3:Stop(0)
				track3:Destroy()
			end)
			track3.Looped = true
			track3.Priority = Enum.AnimationPriority.Action
		else
			track3 = nil
		end

		local gatitoWalk = script:FindFirstChild("GatitoWalk")

		if gatitoWalk then
			track = animator:LoadAnimation(gatitoWalk);
			(maid2 or maid):Add(function()
				track:Stop(0)
				track:Destroy()
			end)
			track.Priority = Enum.AnimationPriority.Action2
		end

		local gatitoIdle = script:FindFirstChild("GatitoIdle")

		if gatitoIdle then
			track2 = animator:LoadAnimation(gatitoIdle);
			(maid2 or maid):Add(function()
				track2:Stop(0)
				track2:Destroy()
			end)
			track2.Looped = true
			track2.Priority = Enum.AnimationPriority.Idle
		end

		maid2:Add(parent:GetAttributeChangedSignal("AttackAnimation"):Connect(function()
			local gatitoAttack = script:FindFirstChild("GatitoAttack")

			if gatitoAttack then
				local track4 = loadAnimation(animator, gatitoAttack, maid2) -- equivalent call inferred; original call site unknown
				track4.Looped = false
				track4.Priority = Enum.AnimationPriority.Action4
				track4:Play()
			end
		end))

		if track then
			maid2:Add(Observers.observeAttribute(parent, "IsRunning", function(p)
				if p then
					track:Play()

					if track2 and track2.IsPlaying then
						track2:Stop()
					end

					if track3 and track3.IsPlaying then
						track3:Stop()
					end
				else
					track:Stop()

					if track3 and parent:GetAttribute("Dance") and not track3.IsPlaying then
						track3:Play()
					end
				end

				return nil
			end))
		end

		maid2:Add(Observers.observeAttribute(parent, "Dance", function(p)
			if p then
				if track2 and track2.IsPlaying then
					track2:Stop()
				end

				if track3 then
					track3:Play()
				end
			else
				if track3 then
					track3:Stop()
				end

				if track2 then
					track2:Play()
				end
			end

			return nil
		end))
		local v3 = {
			dance = track3,
			walk = track,
			idle = track2
		}
		table.insert(v, v3)
		maid2:Add(function()
			local index = table.find(v, v3)

			if index then
				table.remove(v, index)
			end
		end)
		return maid2:WrapClean()
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initMusicController(p)
	maid:Add(task.spawn(function()
		local v = workspace:GetServerTimeNow() - p.startedAt

		if not (v < 7) then
			local v2 = v - 7
			local _ = v2 % 72.771
			local _ = v2 < 218.313
		end

		local v2 = v - 7

		if v2 >= 0 and v2 < 218.313 then
			ayMiGatito.TimePosition = v2 % 72.771
			ayMiGatito:Play()
		end

		maid:Add(function()
			ayMiGatito:Stop()
		end)
		local v3 = -1
		maid:Add(RunService.PostSimulation:Connect(function(_: number)
			local v4 = workspace:GetServerTimeNow() - p.startedAt
			local v5 = v4 - 7

			if v4 >= 225.313 then
				ayMiGatito:Stop()
				return
			end

			if v5 < 0 then
				return
			end

			local v6 = math.floor(v5 / 72.771)
			local timePosition = v5 % 72.771

			if v6 ~= v3 and v3 >= 0 then
				ayMiGatito.TimePosition = 0
			end

			v3 = v6

			if math.abs(ayMiGatito.TimePosition - timePosition) > 0.5 then
				ayMiGatito.TimePosition = timePosition
			end
		end))
	end))
end

local function initAnimatedInstancesObserver(activeEventData)
	local v = {}
	maid:Add(RunService.PostSimulation:Connect(function(_: number)
		if #v == 0 then
			return
		end

		local v2 = workspace:GetServerTimeNow() - activeEventData.startedAt

		if not (v2 < 7) then
			local v3 = v2 - 7
			local _ = v3 % 72.771
			local _ = v3 < 218.313
		end

		local animationSpeed = calculateAnimationSpeed(v2) -- equivalent call inferred; original call site unknown

		for _, v4 in v do
			if v4.IsPlaying then
				v4:AdjustSpeed(animationSpeed)
			end
		end
	end))
	maid:Add(function()
		table.clear(v)
	end)
	maid:Add(Observers.observeTag("AyMiGatitoAnimatedInstance", function(instance)
		local maid2 = Trove.new()
		local animationController = instance:FindFirstChild("AnimationController")

		if not animationController then
			return maid2:WrapClean()
		end

		local animator = animationController:FindFirstChild("Animator")

		if not animator then
			return maid2:WrapClean()
		end

		local animation = instance:FindFirstChild("Animation")

		if not animation then
			return maid2:WrapClean()
		end

		local track = loadAnimation(animator, animation, maid2) -- equivalent call inferred; original call site unknown
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		table.insert(v, track)
		maid2:Add(function()
			local index = table.find(v, track)

			if index then
				table.remove(v, index)
			end
		end)
		return maid2:WrapClean()
	end, { workspace }))
end

local function initPlayerDanceController(activeEventData)
	maid:Add(task.delay(activeEventData.startedAt + 7 + 7.308 - workspace:GetServerTimeNow(), function()
		maid:Add(Observers.observeCharacters(function(_, instance)
			local maid2 = Trove.new()
			maid2:Add(task.spawn(function()
				local humanoid = instance:WaitForChild("Humanoid")

				if not humanoid then
					return
				end

				local animator = humanoid:WaitForChild("Animator")

				if not animator then
					return
				end

				local playerDance1 = script:FindFirstChild("PlayerDance1")
				local playerDance2 = script:FindFirstChild("PlayerDance2")
				local track = nil
				local track2

				if playerDance1 then
					track2 = animator:LoadAnimation(playerDance1)
					track2.Priority = Enum.AnimationPriority.Action
				else
					track2 = nil
				end

				if playerDance2 then
					track = animator:LoadAnimation(playerDance2)
					track.Priority = Enum.AnimationPriority.Action
				end

				local total = 0
				local v = 1
				maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("AyMiGatito:Player:Dance")
					local v2 = workspace:GetServerTimeNow() - activeEventData.startedAt
					local v3 = v2 - 7
					v = 1

					if v3 >= 0 then
						local v4 = math.floor(v3 / 72.771) + 1
						local v5 = v3 % 72.771

						if v4 == 2 and v5 >= 7.308 and v5 < 29.126 then
							v = 2
						end
					end

					local v4

					if v == 1 then
						v4 = track2
					else
						v4 = track
					end

					local v5

					if v == 1 then
						v5 = track
					else
						v5 = track2
					end

					if not (v2 < 7) then
						local v6 = v2 - 7
						local _ = v6 % 72.771
						local _ = v6 < 218.313
					end

					local animationSpeed = calculateAnimationSpeed(v2) -- equivalent call inferred; original call site unknown
					local v7

					if v3 >= 0 then
						v7 = v3 <= 20
					else
						v7 = false
					end

					if (humanoid.MoveDirection ~= createVector(0, 0, 0) or localPlayer:GetAttribute("Stealing")) and not v7 then
						total = 0

						if track2 and track2.IsPlaying then
							track2:Stop()
						end

						if track and track.IsPlaying then
							track:Stop()
						end
					else
						if total < 3 and not v7 then
							total += dt
						elseif v4 and not v4.IsPlaying then
							if v5 and v5.IsPlaying then
								v5:Stop()
							end

							v4:Play()
						end

						if v4 and v4.IsPlaying then
							v4:AdjustSpeed(animationSpeed)
						end
					end

					debug.profileend()
				end))
				maid2:Add(function()
					if track2 then
						track2:Stop()
						track2:Destroy()
					end

					if track then
						track:Stop()
						track:Destroy()
					end
				end)
			end))
			return maid2:WrapClean()
		end))
	end))
end

local AyMiGatito = {}

function AyMiGatito.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("AyMiGatitoEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("AyMiGatitoEvent", nil)
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	maid:Add(task.delay(activeEventData.startedAt + 7 - workspace:GetServerTimeNow(), function()
		if ServerData.IsJumpLTMServer() then
			maid:Add(JumpLTMWeather.Cover(script.MapVFX))
		elseif ServerData.IsTsunamiServer() then
			local clone = maid:Clone(script.MapVFXTsunami)
			clone.Parent = workspace
		elseif ServerData.IsBiggerServer() then
			local clone_2 = maid:Clone(script.MapVFXBigger)
			clone_2.Parent = workspace
		else
			local clone_3 = maid:Clone(script.MapVFX)
			clone_3.Parent = workspace
		end

		if not ServerData.IsJumpLTMServer() then
			if ServerData.IsTsunamiServer() then
				local clone_4 = maid:Clone(script.GatitoMapTsunami)
				clone_4.Parent = workspace
			elseif ServerData.IsBiggerServer() then
				local clone_5 = maid:Clone(script.GatitoMapBigger)
				clone_5.Parent = workspace
			else
				local clone_6 = maid:Clone(script.GatitoMap)
				clone_6.Parent = workspace
			end
		end

		EffectController:Run("AyMiGatitoEvent", "GrassRecolor")
		maid:Add(function()
			EffectController:Stop("AyMiGatitoEvent", "GrassRecolor")
		end)
		EffectController:Run("AyMiGatitoEvent", "WallRecolor")
		maid:Add(function()
			EffectController:Stop("AyMiGatitoEvent", "WallRecolor")
		end)
		EffectController:Run("AyMiGatitoEvent", "WallBottomRecolor")
		maid:Add(function()
			EffectController:Stop("AyMiGatitoEvent", "WallBottomRecolor")
		end)
		local atmosphere = Lighting:FindFirstChild("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone_7 = maid:Clone(script.AtmosphereAyMiGatito)
		clone_7.Parent = Lighting
		maid:Add(Observers.observeTag("HideInAyMiGatito", function(p)
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
		EffectController:Activate("Blink")
		initMusicController(activeEventData) -- equivalent call inferred; original call site unknown
		initGatitoObserver(activeEventData)
		initAnimatedInstancesObserver(activeEventData)
		initPlayerDanceController(activeEventData)
	end))
	maid:Add(task.spawn(function()
		initActivationVisual()
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Ay Mi Gatito"].Hit })
	end))
end

function AyMiGatito.OnStop(_)
	maid:Destroy()
end

function AyMiGatito.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
		ContentProvider:PreloadAsync({ ayMiGatito })
	end)
end

return AyMiGatito