local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local TrickOrTreat = {}
require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.CameraController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Shared.SharedEventUtils)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Observers = require(ReplicatedStorage.Packages.Observers)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Animals = require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Trick or Treat/BrainrotCandyAnimation")
local remoteEvent2 = Net:RemoteEvent("EventService/Trick or Treat/BrainrotHitAnimation")
local remoteEvent3 = Net:RemoteEvent("EventService/Trick or Treat/PlayerCandyAnimation")
local remoteEvent4 = Net:RemoteEvent("EventService/Trick or Treat/ScreenCandyAnimation")
local remoteEvent5 = Net:RemoteEvent("EventService/Trick or Treat/Burst")
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

function TrickOrTreat.OnStart(_)
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

	maid:Add(Observers.observeTag("HideInTrickOrTreat", function(p)
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
	EffectController:Run("TrickOrTreatEvent", "GrassRecolor")
	EffectController:Run("TrickOrTreatEvent", "WallRecolor")
	EffectController:Run("TrickOrTreatEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("TrickOrTreatEvent", "GrassRecolor")
		EffectController:Stop("TrickOrTreatEvent", "WallRecolor")
		EffectController:Stop("TrickOrTreatEvent", "WallBottomRecolor")
	end)
	maid:Add(Observers.observeTag("TrickOrTreatDoor", function(instance)
		local pivot = instance:GetPivot()
		return Observers.observeAttribute(instance, "Open", function(p)
			if p then
				Spr.target(instance, 0.75, 3.5, {
					Pivot = pivot * CFrame.Angles(0, 1.5707963267948966, 0)
				})
			else
				Spr.target(instance, 0.75, 3.5, {
					Pivot = pivot
				})
			end

			return nil
		end)
	end))
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.SkyTrickOrTreat)
	clone_2.Parent = Lighting
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.AtmosphereTrickOrTreat)
	clone_3.Parent = Lighting

	local function spawnBrainrot(instance, childName: string, cframe: CFrame, p: number)
		local v = Trove.new()
		local animatedModel = Animals:GetAnimatedModel(childName, "Idle")

		if not animatedModel then
			return
		end

		v:Add(animatedModel)

		if not animatedModel.PrimaryPart then
			v:Destroy()
			return
		end

		task.delay(math.max(0, p - workspace:GetServerTimeNow()), function()
			v:Destroy()
		end)
		animatedModel.PrimaryPart.Anchored = true
		animatedModel:PivotTo(cframe)
		local animationController = animatedModel:FindFirstChild("AnimationController")
		local animator = animationController and animationController:FindFirstChild("Animator")
		local animation = instance:FindFirstChild(childName)

		if not (animator and animation and animation:IsA("Animation")) then
			return
		end

		local track = loadAnimation(animator, animation, v) -- equivalent call inferred; original call site unknown
		track.Priority = Enum.AnimationPriority.Action4
		track.Looped = false
		task.delay(1, function()
			track:Play()
		end)
	end

	maid:Add(remoteEvent2.OnClientEvent:Connect(function(p: string, cframe: CFrame, p2: number)
		spawnBrainrot(script.HitAnimations, p, cframe, p2)
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: string, cframe: CFrame, p2: number)
		spawnBrainrot(script.Animations, p, cframe, p2)
		local cFrame = cframe * CFrame.new(0, 0, -3) * CFrame.Angles(0, -1.5707963267948966, 1.5707963267948966) + createVector(
			0,
			6,
			0
		)
		local clone2 = script.CandyCornThrow:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = workspace
		task.delay(1, VFX.emit, clone2)
		task.delay(6, function()
			clone2:Destroy()
		end)
	end))
	maid:Add(remoteEvent4.OnClientEvent:Connect(function(_: number)
		local random = Random.new()

		for _ = 1, 20 do
			local clone2 = script.Image:Clone()
			clone2.Position = UDim2.fromScale(random:NextNumber(-0.25, 1.25), -0.25)
			clone2.Rotation = random:NextNumber(-120, 120)
			local number = random:NextNumber(0.15, 0.2)
			clone2.Size = UDim2.fromScale(number, number)
			clone2.Parent = localPlayer.PlayerGui:FindFirstChild("Effects")
			CreateTween(
				clone2,
				TweenInfo.new(random:NextNumber(0.75, 1.3), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Position = clone2.Position + UDim2.fromScale(0, 1.5),
					Rotation = clone2.Rotation + random:NextInteger(-3, 3) * 10
				},
				true
			).Completed:Once(function()
				task.wait(1)
				clone2:Destroy()
			end)
		end
	end))
	maid:Add(remoteEvent3.OnClientEvent:Connect(function(vector2: Vector3, player)
		local total = 0
		local clone2 = script.CandyCorn:Clone()
		clone2.Parent = workspace
		local v = nil
		v = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
			debug.profilebegin("Trick or Treat:UpdateCandyCorn")
			total += dt
			local position = player.Character and player.Character:GetPivot().Position or createVector(0, 0, 0)
			local v2 = vector2 + (position - vector2) * 0.5 + createVector(0, 15, 0)
			local value = TweenService:GetValue(total / 0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			clone2:PivotTo(CFrame.new(MathUtils.quadBezier(value, vector2, v2, position)))

			if value >= 1 and v then
				maid:Remove(v)
				v = nil

				for _, part in clone2:GetDescendants() do
					if part:IsA("BasePart") then
						part.Transparency = 1
					end
				end

				task.delay(3, function()
					clone2:Destroy()
				end)
			end

			debug.profileend()
		end))
	end))
	maid:Add(Observers.observeTag("TrickOrTreatEventPumpkin", function(part)
		local maid2 = Trove.new()
		local clone2 = maid2:Clone(script.Pumpkin)
		clone2:ScaleTo(part:GetAttribute("Scale") or 1)
		clone2.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone2.PrimaryPart
		weld.Part1 = part
		weld.C0 = clone2.PrimaryPart.PivotOffset
		weld.Parent = clone2.PrimaryPart
		local track = clone2.AnimationController.Animator:LoadAnimation(script.Idle)
		maid:Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true
		track:Play()
		local track2 = clone2.AnimationController.Animator:LoadAnimation(script.Move)
		maid:Add(function()
			track2:Stop(0)
			track2:Destroy()
		end)
		track2.Priority = Enum.AnimationPriority.Action
		track2.Looped = true
		maid2:Add(Observers.observeAttribute(part, "Moving", function(p)
			if p then
				track2:Play()
			else
				track2:Stop()
			end

			return nil
		end))
		return maid2:WrapClean()
	end, { workspace }))
end

function TrickOrTreat.OnStop(_)
	maid:Destroy()
end

function TrickOrTreat.OnLoad(_)
	remoteEvent5.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Trick or Treat"].BrainrotHit })
	end)
end

return TrickOrTreat