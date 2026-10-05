game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local FatSammy = {
	Duration = {
		Default = 600
	}
}
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Animals = require(ReplicatedStorage.Datas.Animals)
require(ReplicatedStorage.Utils.TimeUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local remoteEvent = Net:RemoteEvent("EventService/FatSammy/PlaySpawnSequence")
local remoteEvent2 = Net:RemoteEvent("EventService/FatSammy/PlayEatAnimation")
local remoteEvent3 = Net:RemoteEvent("EventService/FatSammy/Delivery")
local name = script.Name
local localPlayer = Players.LocalPlayer
local model = workspace.Events.FatSammy.Model
local sammy = model.Sammy
local animator = sammy.AnimationController.Animator
local flag = false
local maid = Trove.new()

function FatSammy.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local maid2 = Trove.new()
	maid:Add(function()
		while flag do
			task.wait()
		end

		maid2:Destroy()
	end)
	local animation = SharedEventUtils.loadAnimation(maid2, animator, script.Idle)
	local animation2 = SharedEventUtils.loadAnimation(maid2, animator, script.PointUp)
	local animation3 = SharedEventUtils.loadAnimation(maid2, animator, script.PoseToBeam)
	local animation4 = SharedEventUtils.loadAnimation(maid2, animator, script.BeamLoop)
	local animation5 = SharedEventUtils.loadAnimation(maid2, animator, script.BeamResume)
	local animation6 = SharedEventUtils.loadAnimation(maid2, animator, script.Eat)
	maid2:Add(animation2:GetMarkerReachedSignal("Freeze"):Connect(function()
		animation2:AdjustSpeed(0)
	end))
	animation.Looped = true
	animation:Play()
	maid:Add(remoteEvent2.OnClientEvent:Connect(function()
		if flag then
			return
		end

		animation6:AdjustWeight(1)
		animation6:Play()
		task.wait(0.1)
		SoundController:PlaySound(ReplicatedStorage.Sounds.Events.FatSammy.Eat, sammy:GetPivot().Position)
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: number)
		local function getTimeUntil(p2: number)
			return (math.max(p + p2 - workspace:GetServerTimeNow(), 0))
		end

		local function waitUntil(p2: number)
			return task.wait((math.max(p + p2 - workspace:GetServerTimeNow(), 0)))
		end

		local maid3 = Trove.new()
		flag = true
		maid3:Add(function()
			flag = false
		end)
		maid3:Add(task.delay(math.max(p + 11 - workspace:GetServerTimeNow(), 0), function()
			maid3:Destroy()
		end))
		animation2:Play()
		animation6:AdjustWeight(0)

		if math.max(p + 5.5 - workspace:GetServerTimeNow(), 0) >= 4.5 then
			SoundController:PlaySound(ReplicatedStorage.Sounds.Events.FatSammy.Charge, sammy:GetPivot().Position, false)
		end

		task.wait((math.max(p + 0.5 - workspace:GetServerTimeNow(), 0)))
		local copy = VFX.copy(script.Absorb, sammy.Taco.CFrame, sammy.Taco)
		maid3:Add(copy)
		VFX.weldPosition(copy, sammy.Taco)
		VFX.enable(copy)
		local copy2 = VFX.copy(script.Orb, sammy.Taco.CFrame, sammy.Taco)
		maid3:Add(copy2)
		VFX.weldPosition(copy2, sammy.Taco)
		VFX.enable(copy2)
		local model2 = Instance.new("Model")
		maid3:Add(model2)
		copy2.Parent = model2
		model2.Parent = sammy.Taco
		local numberValue = Instance.new("NumberValue")
		maid3:Add(numberValue)
		numberValue.Value = 0.1
		model2:ScaleTo(0.1)
		numberValue.Changed:Connect(function(p2)
			model2:ScaleTo(p2)
		end)
		local tween = CreateTween(
			numberValue,
			TweenInfo.new(
				math.max(p + 5 - workspace:GetServerTimeNow(), 0),
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.In
			),
			{
				Value = 1
			}
		)
		task.wait((math.max(p + 5 - workspace:GetServerTimeNow(), 0)))
		tween:Cancel()
		tween:Destroy()
		model2:ScaleTo(1)
		VFX.disable(copy)
		animation3:Play()
		task.wait((math.max(p + 5.5 - workspace:GetServerTimeNow(), 0)))
		local clone = maid3:Clone(script.Beam)
		clone.Parent = workspace
		VFX.enable(clone)
		local att0 = clone.att0
		local worldPosition = clone.att0.WorldPosition
		maid3:Add(att0)
		att0.Parent = workspace.Terrain
		att0.WorldCFrame = copy2.att1.WorldCFrame

		for _, beam in clone.beams:GetChildren() do
			if beam:IsA("Beam") then
				beam.Attachment1 = copy2.att1
			end
		end

		local copy3 = VFX.copy(script.Burst, sammy.Taco.CFrame, workspace)
		maid3:Add(copy3)
		VFX.emit(copy3)
		animation2:Stop()
		animation4:Play()
		VFX.disable(copy2)
		CreateTween(
			att0,
			TweenInfo.new(
				math.max(p + 6.5 - workspace:GetServerTimeNow(), 0),
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.Out
			),
			{
				Position = worldPosition
			}
		)
		local v2 = math.max(p + 6.5 - workspace:GetServerTimeNow(), 0) >= 0.5 and SoundController:PlaySound(
			ReplicatedStorage.Sounds.Events.FatSammy.Shot,
			nil,
			false
		)

		if v2 then
			v2.Parent = att0
		end

		task.wait((math.max(p + 6.5 - workspace:GetServerTimeNow(), 0)))
		VFX.disable(att0)

		for _, beam in clone.beams:GetChildren() do
			if beam:IsA("Beam") then
				CreateTween(
					beam,
					TweenInfo.new(
						math.max(p + 7.7 - workspace:GetServerTimeNow(), 0),
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.Out
					),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
			end
		end

		task.wait((math.max(p + 7.3 - workspace:GetServerTimeNow(), 0)))
		animation5:Play()
		task.delay(0.5, function()
			animation4:Stop()
		end)
	end))
end

function FatSammy.OnStop(_)
	maid:Destroy()
end

function FatSammy.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)

	local function updateScale()
		local scaleAlpha = sammy:GetAttribute("ScaleAlpha") or 0
		local scale = math.lerp(1, 2, scaleAlpha)
		sammy:PivotTo(model.SammySpawnPosition:GetPivot())
		Spr.target(model.SammyBelly.Upper.Motor, 0.8, 1.5, {
			C0 = CFrame.new(0, scale * -0.454, scale * 0.445),
			C1 = CFrame.new(0, 0, (1 - scaleAlpha) * 0.445 * scale)
		})
		Spr.target(model.SammyBelly.Bottom.Motor, 0.8, 1.5, {
			C0 = CFrame.new(0, scale * 0.433, scale * 0.951),
			C1 = CFrame.new(0, 0, (1 - scaleAlpha) * 0.951 * scale)
		})
		Spr.target(sammy, 0.8, 1.5, {
			Scale = scale
		})
		Spr.target(model.SammyBelly, 0.8, 1.5, {
			Scale = math.lerp(0.45, 0.667, scaleAlpha) * scale
		})

		for _, child in model.SammyArms:GetChildren() do
			Spr.target(child, 0.8, 1.5, {
				Scale = math.lerp(0.6, 1, scaleAlpha) * scale
			})
		end
	end

	sammy:GetAttributeChangedSignal("ScaleAlpha"):Connect(updateScale)
	task.spawn(updateScale)
	local v = false
	Observers.observeTag("FatSammyDeliveryHitbox", function(p)
		local touchedConnection = p.Touched:Connect(function(otherPart)
			if otherPart.Name ~= "HumanoidRootPart" then
				return
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

			if not (playerFromCharacter and playerFromCharacter == localPlayer) then
				return
			end

			if ConfirmationController:IsInPrompt() or v or flag then
				return
			end

			local stealingIndex = playerFromCharacter:GetAttribute("StealingIndex")

			if not stealingIndex then
				return
			end

			v = true
			task.delay(0.5, function()
				v = false
			end)
			local rarity = Animals[stealingIndex].Rarity

			if Animals2:GetRarityWeight(rarity) >= 5 and not ConfirmationController:Show((`Are you sure you want to give this {rarity} Brainrot to Sammy?`)) then
				return
			end

			remoteEvent3:FireServer()
		end)
		return function()
			touchedConnection:Disconnect()
		end
	end)
end

return FatSammy