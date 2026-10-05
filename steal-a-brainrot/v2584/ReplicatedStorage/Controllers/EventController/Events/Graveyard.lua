local createVector = vector.create
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("ContentProvider")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Graveyard = {}
require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local AnimalController = require(ReplicatedStorage.Controllers.AnimalController)
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
local FFlags = require(ReplicatedStorage.Packages.FFlags)
require(ReplicatedStorage.Packages.Signal)
require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local digging = localPlayer.PlayerGui:WaitForChild("Digging")
local _ = workspace.CurrentCamera
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Graveyard/DigStart")
local remoteEvent2 = Net:RemoteEvent("EventService/Graveyard/DigEnd")
local remoteEvent3 = Net:RemoteEvent("EventService/Graveyard/PlayGraveyardAnimation")
local remoteEvent4 = Net:RemoteEvent("EventService/Graveyard/DigCollectVFX")
local remoteEvent5 = Net:RemoteEvent("EventService/Graveyard/Burst")
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

function Graveyard.OnStart(_)
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
	local clone = maid:Clone(script.Map)
	clone.Parent = workspace

	if ServerData.IsBiggerServer() then
		ClientEventUtils.resizeEffects(clone.MapVFX, 2)
	end

	maid:Add(Observers.observeTag("HideInGraveyard", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(Observers.observeTag("HideInGraveyardTransparency", function(p)
		p.Transparency = 1
		return function()
			p.Transparency = 0
		end
	end, { workspace }))
	EffectController:Activate("Blink")
	CycleController:Update()
	SoundController:UpdateOST()
	EffectController:Run("GraveyardEvent", "GrassRecolor")
	EffectController:Run("GraveyardEvent", "WallRecolor")
	EffectController:Run("GraveyardEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("GraveyardEvent", "GrassRecolor")
		EffectController:Stop("GraveyardEvent", "WallRecolor")
		EffectController:Stop("GraveyardEvent", "WallBottomRecolor")
	end)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereGraveyard)
	clone_2.Parent = Lighting
	maid:Add(Observers.observeCharacter(localPlayer, function(_, instance)
		return Observers.observeChildren(instance, function(tool)
			if not tool:IsA("Tool") or tool.Name ~= "Agarrini Shovel" then
				return nil
			end

			local animator = instance:FindFirstChildWhichIsA("Animator", true)

			if not animator then
				return nil
			end

			local track = loadAnimation(animator, script.Idle) -- equivalent call inferred; original call site unknown
			track:Play(0)
			return function()
				track:Stop()
			end
		end)
	end))
end

function Graveyard.OnStop(_)
	maid:Destroy()
end

function Graveyard.OnLoad(_)
	local maid2 = Trove.new()
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: number)
		maid2:Clean()
		local fill = digging.Fillbar.Fill
		local mover = digging.Fillbar.Mover
		local textLabel = digging.Fillbar.LabelHolder.TextLabel
		local uIScale = digging.Fillbar.LabelHolder.UIScale
		digging.Fillbar.Visible = true
		local v = 0
		local instant = FFlags:GetInstant("GraveyardDigDecreaseTimer", 0.7)
		local instant2 = FFlags:GetInstant("GraveyardDigDecreaseAmount", 0.1)
		local total = 0
		maid2:Add(RunService.PostSimulation:Connect(function(dt: number)
			total += dt

			if total < instant then
				return
			end

			total = 0
			local v2 = instant2 * p2
			v = math.max(v - v2, 0)
			Spr.target(fill, 1, 7, {
				Size = UDim2.fromScale(v, 1)
			})
			Spr.target(mover, 1, 7, {
				Position = UDim2.fromScale(v, 0.5)
			})
		end))
		local v2 = nil
		maid2:Add(Observers.observeCharacter(localPlayer, function(_, p3)
			return Observers.observeChildren(p3, function(humanoid)
				if humanoid:IsA("Humanoid") then
					return Observers.observeChildren(humanoid, function(animator)
						if not animator:IsA("Animator") then
							return nil
						end

						local maid3 = Trove.new()
						local track = loadAnimation(animator, script.Dig) -- equivalent call inferred; original call site unknown
						v2 = track
						maid3:Add(function()
							if v2 == track then
								v2 = nil
							end
						end)
						return maid3:WrapClean()
					end)
				end

				return nil
			end)
		end))
		local instant3 = FFlags:GetInstant("GraveyardDigIncreasePerClick", 0.04)
		local instant4 = FFlags:GetInstant("GraveyardDigClickCooldown", 0.05)
		local v3 = 0
		local count = 0
		ContextActionService:BindActionAtPriority("Dig", function(_, p3, _)
			if p3 ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end

			local now = os.clock()

			if now - v3 < instant4 then
				return Enum.ContextActionResult.Sink
			end

			v = math.min(v + instant3, 1)
			v3 = now
			count += 1
			textLabel.Text = `Click Anywhere! ({string.format("%0.3d", count)})`

			if v2 and not v2.IsPlaying then
				v2:Play()
				SoundController:PlaySound(ReplicatedStorage.Sounds.Events.Graveyard.Dig, nil, false)
			end

			Spr.target(fill, 1, 7, {
				Size = UDim2.fromScale(v, 1)
			})
			Spr.target(mover, 1, 7, {
				Position = UDim2.fromScale(v, 0.5)
			})
			Spr.stop(uIScale)
			uIScale.Scale = 1.2
			Spr.target(uIScale, 0.8, 5, {
				Scale = 1
			})

			if v >= 1 then
				remoteEvent2:FireServer(p)
			end

			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonX, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
		maid2:Add(function()
			Spr.stop(uIScale)
			Spr.stop(mover)
			Spr.stop(fill)
			fill.Size = UDim2.fromScale(0, 1)
			mover.Position = UDim2.fromScale(0, 0.5)
			uIScale.Scale = 1
			textLabel.Text = `Click Anywhere! ({string.format("%0.3d", 0)})`
		end)
		maid2:Add(function()
			ContextActionService:UnbindAction("Dig")
		end)
	end)
	remoteEvent2.OnClientEvent:Connect(function()
		digging.Fillbar.Visible = false
		maid2:Clean()
	end)
	remoteEvent4.OnClientEvent:Connect(function(cframe: CFrame, childName: string)
		local child = script.DigVFX:FindFirstChild(childName)

		if not child then
			return
		end

		local clone = child:Clone()
		clone:PivotTo(cframe)
		clone.Parent = workspace
		VFX.emit(clone)
		task.delay(5, function()
			clone:Destroy()
		end)
		local SFX = child:FindFirstChild("SFX")

		if SFX then
			SoundController:PlaySound(SFX, cframe.Position + createVector(0, 3, 0), false)
		end
	end)
	remoteEvent5.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Graveyard.BrainrotHit })
	end)
	remoteEvent3.OnClientEvent:Connect(function(childName, p)
		local v = AnimalController:GetAnimals()[p]

		if not v then
			return
		end

		local child = script.Animations:FindFirstChild(childName)

		if not child then
			return
		end

		local animalModel = v.AnimalModel
		local animationController = animalModel:FindFirstChild("AnimationController") or Instance.new(
			"AnimationController",
			animalModel
		)
		local track = (animationController:FindFirstChild("Animator") or Instance.new("Animator", animationController)):LoadAnimation(child)
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = false
		track:Play()
		track.Ended:Connect(function()
			track:Stop(0)
			track:Destroy()
		end)
	end)
end

return Graveyard