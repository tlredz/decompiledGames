local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local CrabRave = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteEvent = Net:RemoteEvent("EventService/Crab Rave/Hit")
local localPlayer = Players.LocalPlayer
local crabRave = workspace.Sounds.CrabRave
local name = script.Name
local maid = Trove.new()

function CrabRave.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("CrabRave", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("CrabRave", nil)
		CycleController:Update()
		SoundController:UpdateOST()
	end)
	maid:Add(task.spawn(function()
		while not crabRave.IsLoaded do
			task.wait()
		end

		crabRave.TimePosition = math.max(
			crabRave.TimePosition,
			workspace:GetServerTimeNow() - activeEventData.startedAt
		)
	end))
	CycleController:Update()
	SoundController:UpdateOST()
	local isTsunamiServer = ServerData.IsTsunamiServer()
	local v = maid:Add(Instance.new("ColorCorrectionEffect"))
	v.Parent = workspace.CurrentCamera

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTimeLeftForSync(p: number, p2: number?)
		return activeEventData.startedAt + p - (p2 or workspace:GetServerTimeNow())
	end

	local oceanparticles

	if ServerData.IsJumpLTMServer() then
		oceanparticles = nil
	else
		local clone

		if ServerData.IsBiggerServer() then
			clone = maid:Clone(script.OceanBigger)
		else
			clone = maid:Clone(script.Ocean)
		end

		local X = ServerData.IsBiggerServer() and 902 or 400
		local v2 = 45

		if isTsunamiServer then
			local areas = workspace.Map:FindFirstChild("Areas")
			local _1 = areas and areas:FindFirstChild("1")

			if _1 then
				local pivot = _1:GetPivot()
				local v3 = pivot.Position.X + _1.Size.X / 2
				local Y = pivot.Position.Y
				clone:PivotTo(CFrame.new(v3, Y + 0.2, pivot.Position.Z) * CFrame.Angles(
					0,
					-1.5707963267948966,
					1.5707963267948966
				))
				X = _1.Size.X
				v2 = 45 * (_1.Size.X / 400)
				local Z = _1.Size.Z

				for _, beam in clone:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Width0 = Z
					beam.Width1 = Z
				end
			end
		end

		clone.Parent = workspace
		local ocean = clone:FindFirstChild("ocean")
		local att1 = clone:FindFirstChild("att1")
		oceanparticles = clone:FindFirstChild("oceanparticles")

		for _, beam in clone:GetChildren() do
			if not beam:IsA("Beam") then
				continue
			end

			local textureLength = beam.TextureLength
			beam.TextureLength = 0

			if ocean then
				TweenService:Create(
					ocean,
					TweenInfo.new(
						activeEventData.startedAt + v2 - workspace:GetServerTimeNow(),
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.In
					),
					{
						TextureLength = textureLength
					}
				):Play()
			end
		end

		if att1 then
			TweenService:Create(
				att1,
				TweenInfo.new(
					activeEventData.startedAt + v2 - workspace:GetServerTimeNow(),
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.In
				),
				{
					Position = Vector3.new(0, 0, X)
				}
			):Play()
		end
	end

	local v2 = maid:Add(Instance.new("Highlight"))
	assert(v2)
	v2.DepthMode = Enum.HighlightDepthMode.Occluded
	v2.FillColor = Color3.new(1, 1, 1)
	v2.FillTransparency = 1
	v2.OutlineTransparency = 1
	TweenService:Create(v, TweenInfo.new(activeEventData.startedAt + 1.95 - workspace:GetServerTimeNow()), {
		Brightness = -1.2
	}):Play()

	if oceanparticles then
		maid:Add(task.delay(activeEventData.startedAt + 45 - workspace:GetServerTimeNow(), function()
			VFX.enable(oceanparticles)
		end))
	end

	EffectController:Run("CrabRaveEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("CrabRaveEvent", "GrassRecolor")
	end)
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	maid:Add(Observers.observeTag("CrabRaveCrabFolder", function(parent)
		if v2 then
			v2.Parent = parent
		end

		return nil
	end))
	maid:Add(Observers.observeTag("CrabRaveCrabs", function(parent)
		local maid2 = Trove.new()
		local name2 = parent.Parent.Name
		local clone = maid2:Clone(script.Crab)
		local clone2 = nil
		local clone3 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function loadAnimation(animation)
			local track = clone.AnimationController:LoadAnimation(animation)
			maid2:Add(function()
				track:Stop(0)
				track:Destroy()
			end)
			return track
		end

		clone["Cylinder.005"].Transparency = 1
		maid2:Add(task.delay(activeEventData.startedAt + 2 - workspace:GetServerTimeNow(), function()
			clone["Cylinder.005"].Transparency = 0
		end))
		local v3 = maid2:Add(Instance.new("Weld"))
		v3.Part0 = clone["Cylinder.005"]
		v3.Part1 = parent.HumanoidRootPart
		v3.C1 = CFrame.new(0, 3.6, 0)
		v3.Parent = clone

		if FFlags:GetInstant("Optimisation.HumanoidBrainrotModels", ServerData.IsNewPlayersServer()) then
			local animationController = parent:FindFirstChild("AnimationController")

			if animationController then
				animationController:Destroy()
			end

			local humanoid = Instance.new("Humanoid", parent)
			Instance.new("Animator", humanoid)
			humanoid.Name = "AnimationController"
			humanoid.EvaluateStateMachine = false
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.PlatformStand = true
			humanoid.Parent = parent
		end

		local v4 = 0
		local v5 = 0
		local cframe = CFrame.new(0, 3.6, 0)
		maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
			debug.profilebegin("Crab Rave:Crab:Rotate")

			if math.abs(v5 - v4) < 0.1 then
				return
			end

			v4 = v5 + (v4 - v5) * math.exp(dt * -1)
			v3.C1 = cframe * CFrame.Angles(0, v4, 0)
			debug.profileend()
		end))
		clone.Parent = parent
		local track2 = loadAnimation(script.Animation1) -- equivalent call inferred; original call site unknown
		local track3 = loadAnimation(script.Animation2) -- equivalent call inferred; original call site unknown
		local track4 = loadAnimation(script.Animation3_Right) -- equivalent call inferred; original call site unknown
		local track5 = loadAnimation(script.Animation3_Left) -- equivalent call inferred; original call site unknown
		track5.Priority = Enum.AnimationPriority.Action
		local track6 = loadAnimation(script.Animation4_Walk) -- equivalent call inferred; original call site unknown
		track6.Priority = Enum.AnimationPriority.Action
		local track7 = loadAnimation(script.Animation4_Attack) -- equivalent call inferred; original call site unknown
		track7.Priority = Enum.AnimationPriority.Action4
		local v12 = track6

		local function switchWalkAnimationTrack(p, flag: boolean?)
			if v12 == p then
				return
			end

			local isPlaying = v12.IsPlaying

			if isPlaying then
				v12:Stop()
			end

			v12 = p

			if isPlaying and not flag then
				v12:Play()
			end
		end

		track2:Play()
		maid2:Add(parent:GetAttributeChangedSignal("IsRunning"):Connect(function()
			if parent:GetAttribute("IsRunning") then
				if not v12.IsPlaying then
					v12:Play()
				end

				if clone2 then
					clone2.ParticleEmitter.Enabled = true
				end

				if clone3 then
					clone3.ParticleEmitter.Enabled = true
				end
			else
				if v12.IsPlaying then
					v12:Stop()
				end

				if clone2 then
					clone2.ParticleEmitter.Enabled = false
				end

				if clone3 then
					clone3.ParticleEmitter.Enabled = false
				end
			end
		end))
		maid2:Add(parent:GetAttributeChangedSignal("Attack"):Connect(function()
			track7:Play()
		end))
		local track8 = loadAnimation(script.Animation5) -- equivalent call inferred; original call site unknown
		track8.Priority = Enum.AnimationPriority.Action2
		local track9 = loadAnimation(script.Animation6) -- equivalent call inferred; original call site unknown
		track9.Priority = Enum.AnimationPriority.Action2
		local track10 = loadAnimation(script.Animation7) -- equivalent call inferred; original call site unknown
		track10.Priority = Enum.AnimationPriority.Action2
		local track11 = loadAnimation(script.Animation8) -- equivalent call inferred; original call site unknown
		track11.Priority = Enum.AnimationPriority.Action2
		local v17 = {
			track8,
			track9,
			track10,
			track11
		}
		local v18 = nil
		maid2:Add(parent:GetAttributeChangedSignal("Dance"):Connect(function()
			local v19 = activeEventData.startedAt + 85 - workspace:GetServerTimeNow()
			local v20 = activeEventData.startedAt + 105 - workspace:GetServerTimeNow()
			local v21 = v19 <= 0 and v20 > 0 and 4 or parent:GetAttribute("Dance")

			if v21 and v17[v21] and v18 == v17[v21] then
				return
			end

			if v18 then
				v18:Stop()
				v18 = nil
			end

			if v21 ~= nil then
				v18 = v17[v21]
				assert(v18)
				v18:Play()
			end
		end))
		local clone4 = nil
		maid2:Add(task.delay(activeEventData.startedAt + 7 - workspace:GetServerTimeNow(), function()
			track2:Stop()
			track3:Play()
		end))

		if name2 == "Ground" then
			maid2:Add(parent:GetAttributeChangedSignal("ReachedFirstTarget"):Once(function()
				clone4 = maid2:Clone(script.SanddrumRoll)
				local v19 = maid2:Add(Instance.new("Weld"))
				v19.Part0 = clone4
				v19.Part1 = clone["Cylinder.005"]
				v19.C0 = CFrame.new(0.2, 3.629, 4.378)
				v19.Parent = clone4
				clone4.Parent = clone
			end))
		end

		maid2:Add(task.delay(activeEventData.startedAt + 27.5 - workspace:GetServerTimeNow(), function()
			if name2 == "Ground" then
				parent:GetPivot()

				if clone4 then
					local v19 = clone4
					v19.ParticleEmitter.Enabled = false
					task.delay(3, function()
						maid2:Remove(v19)
					end)
					clone4 = nil
				end

				local v19 = track5

				if v12 ~= v19 then
					if v12.IsPlaying then
						v12:Stop()
					end

					v12 = v19
				end

				track5:Play(nil, nil, 0.3333333333333333)
				v5 = 1.5707963267948966
			end
		end))
		maid2:Add(task.delay(activeEventData.startedAt + 31 - workspace:GetServerTimeNow(), function()
			if name2 == "Ground" then
				track5:AdjustSpeed(1)
				clone2 = maid2:Clone(script.WalkPart)
				assert(clone2)
				local v19 = maid2:Add(Instance.new("Weld"))
				v19.Part0 = clone2
				v19.Part1 = clone["Cylinder.005"]
				v19.C0 = CFrame.new(0.614, 3.129, 4.731) * CFrame.fromOrientation(0, -1.5707963267948966, 0)
				v19.Parent = clone2
				clone2.Parent = clone
				clone3 = maid2:Clone(script.WalkPart)
				assert(clone3)
				local v20 = maid2:Add(Instance.new("Weld"))
				v20.Part0 = clone3
				v20.Part1 = clone["Cylinder.005"]
				v20.C0 = CFrame.new(0.414, 3.129, -4.78) * CFrame.fromOrientation(0, -1.5707963267948966, 0)
				v20.Parent = clone3
				clone3.Parent = clone
			elseif name2 == "Wall" then
				track3:Stop()
				track2:Play()
			end
		end))
		maid2:Add(task.delay(activeEventData.startedAt + 43 - workspace:GetServerTimeNow(), function()
			track4:Play(nil, nil, 0.3333333333333333)
			v5 = 0
		end))
		maid2:Add(task.delay(activeEventData.startedAt + 46 - workspace:GetServerTimeNow(), function()
			track4:Stop()
			local v19 = track6

			if v12 ~= v19 then
				local isPlaying = v12.IsPlaying

				if isPlaying then
					v12:Stop()
				end

				v12 = v19

				if isPlaying then
					v12:Play()
				end
			end

			if name2 == "Wall" then
				track3:Stop()
				track2:Play()
			end
		end))
		maid2:Add(task.delay(activeEventData.startedAt + 141 - workspace:GetServerTimeNow(), function()
			local v19 = activeEventData.startedAt + 161 - workspace:GetServerTimeNow()
			local total = 0
			maid2:Add(RunService.PreSimulation:Connect(function(dt: number)
				debug.profilebegin("Crab Rave:Crab:Adjust Dance Speed")
				total += dt
				local v20 = math.lerp(1, 0.1, total / v19)
				track8:AdjustSpeed(v20)
				track9:AdjustSpeed(v20)
				track10:AdjustSpeed(v20)
				track11:AdjustSpeed(v20)
				debug.profileend()
			end))
		end))
		return function()
			maid2:Destroy()
		end
	end))
	local _ = workspace.CurrentCamera
	local v3 = 0
	local v4 = 0
	maid:Add(RunService.PostSimulation:Connect(function(dt)
		debug.profilebegin("Crab Rave:Update")
		v4 -= dt
		v3 -= dt
		local v5 = math.clamp((crabRave.PlaybackLoudness - 100) / 900, 0, 1)

		if v3 <= 0 and v2 then
			v3 = 0.5
			v2.FillTransparency = 0
			TweenService:Create(v2, TweenInfo.new(0.3), {
				FillTransparency = 1
			}):Play()
		end

		if v5 >= 0.25 and v4 <= 0 then
			v4 = 0.1
			CameraController:Fov((v5 - 0.25) * 20 + 70, 0.1)
		end

		debug.profileend()
	end))
	maid:Add(task.delay(activeEventData.startedAt + 7 - workspace:GetServerTimeNow(), function()
		if v2 then
			v2:Destroy()
			v2 = nil
		end

		local tween = TweenService:Create(v, TweenInfo.new(1), {
			Brightness = 0
		})
		tween:Play()
		tween.Completed:Once(function()
			tween:Cancel()
			tween:Destroy()
		end)
	end))
	maid:Add(task.delay(activeEventData.startedAt + 46 - workspace:GetServerTimeNow(), function()
		maid:Add(Signal.new())
		local v5 = maid:Add(Observers.observeCharacter(Players.LocalPlayer, function(_, instance)
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

				local track = animator:LoadAnimation(script.Dance)
				track.Priority = Enum.AnimationPriority.Action
				track:Play(2)
				local total = 0
				local v6 = 0
				maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
					debug.profilebegin("Crab Rave:Player:Dance")
					local serverTimeNow = workspace:GetServerTimeNow()

					if getTimeLeftForSync(66, serverTimeNow) > 0 then
						if not track.IsPlaying then
							track:Play()
							track.TimePosition = (serverTimeNow - activeEventData.startedAt) % track.Length
						end

						debug.profileend()
					else
						local length = track.Length

						if v6 ~= length and length > 0 then
							v6 = length
							track.TimePosition = (serverTimeNow - activeEventData.startedAt) % length
						end

						if humanoid.MoveDirection ~= createVector(0, 0, 0) or localPlayer:GetAttribute("Stealing") then
							total = 0

							if track.IsPlaying then
								track:Stop()
							end
						elseif total < 3 then
							total += dt
						elseif not track.IsPlaying then
							track:Play()
							track.TimePosition = (serverTimeNow - activeEventData.startedAt) % track.Length
						end

						debug.profileend()
					end
				end))
				maid2:Add(function()
					track:Stop()
					track:Destroy()
				end)
			end))
			return maid2:WrapClean()
		end))
		maid:Add(task.delay(activeEventData.startedAt + 140 - workspace:GetServerTimeNow(), v5))
	end))
end

function CrabRave.OnStop(_)
	maid:Destroy()
end

function CrabRave.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		if not CrabRave.Active then
			return
		end

		ClientEventUtils.playBurst(script.CrabHit, p)
	end)
end

return CrabRave