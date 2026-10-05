local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Mexico = {}
local EncryptedAssetsController = require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Utils.MathUtils)
local Signal = require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local mexicoEvent = workspace.Sounds.MexicoEvent
local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
local name = script.Name
local _ = workspace.RenderedMovingAnimals
local remoteEvent = Net:RemoteEvent("EventService/Mexico/Burst")
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function loadAnimation(animator, animation, p)
	local track = animator:LoadAnimation(animation);
	(p or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local function playTracksSynced(items)
	return task.spawn(function()
		for _, item in items do
			item:Play(0)
		end

		while true do
			local flag = true

			for _, item in items do
				if item.Length == 0 then
					flag = false
				else
					item:Stop(0)
				end
			end

			if flag then
				for _, item in items do
					item:Stop(0)
				end

				for _, item in items do
					item:Play(0)
				end

				break
			else
				task.wait()
			end
		end
	end)
end

local function setupSpeedTracks(items)
	return RunService.PostSimulation:Connect(function(_: number)
		if mexicoEvent.TimePosition >= 28.5 then
			for _, item in items do
				item:AdjustSpeed(1.5)
			end
		end
	end)
end

function Mexico.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeft(p: number)
		return (math.max(activeEventData.startedAt + p - workspace:GetServerTimeNow(), 0))
	end

	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
	end)
	local clone

	if not ServerData.IsJumpLTMServer() then
		if ServerData.IsTsunamiServer() then
			clone = maid:Clone(script.MapTsunami)
		elseif ServerData.IsBiggerServer() then
			clone = maid:Clone(script.MapBigger)
		else
			clone = maid:Clone(script.Map)
		end

		clone.Parent = workspace
	end

	maid:Add(Observers.observeTag("HideInMexico", function(p)
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
	EffectController:Run("MexicoEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("MexicoEvent", "GrassRecolor")
	end)
	EffectController:Run("MexicoEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("MexicoEvent", "WallRecolor")
	end)
	EffectController:Run("MexicoEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("MexicoEvent", "WallBottomRecolor")
	end)
	maid:Add(Observers.observeTag("Roach", function(parent)
		local maid2 = Trove.new()
		local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
		local clone2 = maid2:Clone(script.Cockroach)
		local v = maid2:Add(Instance.new("Weld"))
		v.Part0 = clone2.PrimaryPart
		v.Part1 = humanoidRootPart
		v.Parent = clone2.PrimaryPart
		clone2.Parent = parent
		local animationController = clone2:FindFirstChild("AnimationController")

		if animationController then
			animationController:Destroy()
		end

		local humanoid = Instance.new("Humanoid", clone2)
		Instance.new("Animator", humanoid)
		humanoid.Name = "AnimationController"
		humanoid.EvaluateStateMachine = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.PlatformStand = true
		humanoid.Parent = clone2
		local animator = clone2.AnimationController.Animator
		local track = animator:LoadAnimation(script.TakeHat)
		track.Looped = false
		track.Priority = Enum.AnimationPriority.Action3
		local track2 = animator:LoadAnimation(script.PutHat)
		track2.Looped = false
		track2.Priority = Enum.AnimationPriority.Action4
		maid2:Add(parent:GetAttributeChangedSignal("AttackAnimation"):Connect(function()
			track2:Play()
		end))
		parent:SetAttribute("Shuffle", false)
		maid2:Add(Observers.observeAttribute(parent, "Shuffle", function(p)
			if not p then
				return Observers.observeAttribute(parent, "Instrument", function(childName)
					local maid3 = Trove.new()

					if childName == "Sombrero" then
						track:Play()
						VFX.disable(clone2.RootPart.VFX)
					else
						VFX.enable(clone2.RootPart.VFX)
					end

					local track4 = loadAnimation(
						animator,
						script:FindFirstChild((`RoachWalk{childName}`)) or script.RoachWalk,
						maid3
					) -- equivalent call inferred; original call site unknown
					track4.Priority = Enum.AnimationPriority.Action2
					maid3:Add(Observers.observeAttribute(parent, "IsRunning", function(p2)
						if p2 then
							track4:Play()
						else
							track4:Stop()
						end

						return nil
					end))
					local child = script.Instruments:FindFirstChild(childName)
					local clone3

					if child then
						clone3 = maid3:Clone(child)

						if clone3.PrimaryPart then
							local weld = Instance.new("Weld")
							weld.Part0 = clone3.PrimaryPart
							weld.Part1 = clone2.PrimaryPart
							weld.C0 = CFrame.new(0, 3.5, 0)
							weld.Parent = clone3.PrimaryPart
						end

						for _, child2 in clone3:GetChildren() do
							local rigidConstraint = child2:FindFirstChildOfClass("RigidConstraint")

							if not rigidConstraint then
								continue
							end

							local attachment0 = rigidConstraint.Attachment0

							if not attachment0 then
								continue
							end

							local child3 = clone2:FindFirstChild(attachment0.Name, true)

							if child3 then
								rigidConstraint.Attachment1 = child3
							end
						end

						clone3.Parent = clone2.PrimaryPart
					else
						clone3 = nil
					end

					maid3:Add(Observers.observeAttribute(parent, "Dance", function(p2)
						if not p2 then
							return nil
						end

						local maid4 = Trove.new()
						local child2 = script:FindFirstChild((`Roach{childName}`))
						local track3

						if child2 then
							track3 = animator:LoadAnimation(child2);
							(maid4 or maid):Add(function()
								track3:Stop(0)
								track3:Destroy()
							end)
							track3.Looped = true
							track3.Priority = Enum.AnimationPriority.Action
							track3:Play()

							if childName == "Maracas" then
								track3:AdjustSpeed(0.65)
							end
						else
							track3 = nil
						end

						local v3 = nil

						if clone3 and clone3:FindFirstChild("AnimationController") then
							local child3 = script:FindFirstChild(childName)

							if child3 then
								v3 = loadAnimation(clone3.AnimationController.Animator, child3, maid4)
								v3.Looped = true
								v3.Priority = Enum.AnimationPriority.Action
								v3:Play()

								if track3 then
									maid:Add(track3.DidLoop:Connect(function()
										v3.TimePosition = 0
									end))
								end
							end

							local child4 = script:FindFirstChild((`Walk{childName}`))

							if child4 then
								local track5 = loadAnimation(clone3.AnimationController.Animator, child4, maid4) -- equivalent call inferred; original call site unknown
								track5.Priority = Enum.AnimationPriority.Action2
								maid4:Add(Observers.observeAttribute(parent, "IsRunning", function(p3)
									if p3 then
										track5:Play()
									else
										track5:Stop()
									end

									return nil
								end))
							end
						end

						maid4:Add(setupSpeedTracks({ track3, v3 }))
						return maid4:WrapClean()
					end))
					return maid3:WrapClean()
				end)
			end

			local v2 = Trove.new()
			local track6 = loadAnimation(animator, script.Shuffle, v2) -- equivalent call inferred; original call site unknown
			track6.Looped = true
			track6:Play()
			track6:AdjustSpeed(1.5)
			return v2:WrapClean()
		end))
		local timeLeft = calculateTimeLeft(28.5) -- equivalent call inferred; original call site unknown
		maid2:Add(maid:Add(task.delay(timeLeft, function()
			parent:SetAttribute("Shuffle", true)
			maid2:Add(maid:Add(task.delay(
				math.max(activeEventData.startedAt + 34.5 - workspace:GetServerTimeNow(), 0),
				function()
					parent:SetAttribute("Shuffle", false)
				end
			)))
		end)))
		return maid2:WrapClean()
	end))

	for _, v in not clone and {} or clone.WallRoaches:GetChildren() do
		local instrument = v:GetAttribute("Instrument") or "Violin"
		local clone2 = maid:Clone(script.Wall)
		clone2:PivotTo(v:GetPivot())

		for _, child in clone2.Instruments:GetChildren() do
			if child.Name ~= instrument then
				child:Destroy()
			end
		end

		clone2.Parent = workspace
		local track = clone2.Cockroach.AnimationController.Animator:LoadAnimation(script[`Roach{instrument}`])
		maid:Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		track:Play()
		local track2 = clone2.Instruments[instrument].AnimationController.Animator:LoadAnimation(script[instrument])
		maid:Add(function()
			track2:Stop(0)
			track2:Destroy()
		end)
		track2:Play()
		local v4 = track2
		maid:Add(track.DidLoop:Connect(function()
			v4.TimePosition = 0
		end))
		local v5 = { track2, track }
		maid:Add(playTracksSynced(v5))
		maid:Add(setupSpeedTracks(v5))
	end

	maid:Add(task.spawn(function()
		EncryptedAssetsController:WaitForAssetId("rbxassetid://101252122546671")
		mexicoEvent.SoundId = ""
		mexicoEvent.SoundId = "rbxassetid://101252122546671"

		while not mexicoEvent.IsLoaded do
			task.wait()
		end

		mexicoEvent.TimePosition = workspace:GetServerTimeNow() - activeEventData.startedAt
		mexicoEvent:Play()
		maid:Add(function()
			mexicoEvent:Stop()
		end)
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Mexico.Hit })
	end))
	maid:Add(task.delay(math.max(activeEventData.startedAt + 28.5 - workspace:GetServerTimeNow(), 0), function()
		maid:Add(Signal.new())
		maid:Add(Observers.observeCharacters(function(_, parent)
			local maid2 = Trove.new()
			maid2:Add(task.spawn(function()
				local humanoid = parent:WaitForChild("Humanoid")

				if not humanoid then
					return
				end

				local animator = humanoid:WaitForChild("Animator")

				if not animator then
					return
				end

				local track = animator:LoadAnimation(script.PlayerDance)
				track.Priority = Enum.AnimationPriority.Action
				local v = nil

				local function tryCreateMaracas()
					if v then
						return
					end

					local clone2 = maid2:Clone(script.PlayerMaracas)

					for _, child in clone2:GetChildren() do
						local rigidConstraint = child:FindFirstChildOfClass("RigidConstraint")

						if not rigidConstraint then
							continue
						end

						local attachment0 = rigidConstraint.Attachment0

						if not attachment0 then
							continue
						end

						local attachment = parent:FindFirstChild(attachment0.Name, true)

						if attachment and attachment:IsA("Attachment") then
							rigidConstraint.Attachment1 = attachment
						end
					end

					clone2.Parent = parent
					v = clone2
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function tryDestroyMaracas()
					if v then
						maid2:Remove(v)
						v = nil
					end
				end

				local total = 0
				maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("Mexico:Player:Dance")
					workspace:GetServerTimeNow()

					if math.max(activeEventData.startedAt + 43.5 - workspace:GetServerTimeNow(), 0) > 0 then
						if not track.IsPlaying then
							track:Play()
							tryCreateMaracas()
						end
					elseif humanoid.MoveDirection ~= createVector(0, 0, 0) or localPlayer:GetAttribute("Stealing") then
						total = 0

						if track.IsPlaying then
							track:Stop()
							tryDestroyMaracas() -- equivalent call inferred; original call site unknown
						end
					elseif total < 3 then
						total += dt
					elseif not track.IsPlaying then
						track:Play()
						tryCreateMaracas()
					end

					debug.profileend()
				end))
				maid2:Add(function()
					track:Stop()
					track:Destroy()
				end)
			end))
			return maid2:WrapClean()
		end))
	end))
end

function Mexico.OnStop(_)
	maid:Destroy()
end

function Mexico.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	task.spawn(function()
		EncryptedAssetsController:WaitForAssetId("rbxassetid://101252122546671")
		mexicoEvent.SoundId = "rbxassetid://101252122546671"
		ContentProvider:PreloadAsync({ mexicoEvent })
	end)
end

return Mexico