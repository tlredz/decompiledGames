local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
require3("@game/ReplicatedStorage/Types/Templates")
local v3 = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)

if RunService:IsServer() then
	function script.RaptureCollisionResponse.OnInvoke(instance, _, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and instance:GetAttribute("IsRapture")) then
			return "Continue"
		end

		instance:SetAttribute("IsRapture", nil)
		data.Parry:Invoke(instance)
		data.SetSpeed:Invoke(data.GetSpeed:Invoke() + 120)
		data.AddTargetModifier:Invoke({
			direction = humanoidRootPart.CFrame:VectorToWorldSpace(createVector(0, 1, -1))
		}, 5, 0.35)
		local clone = ReplicatedStorage2.Misc.RaptureSuccess:Clone()
		clone.Parent = workspace.Runtime
		clone.CFrame = instance:GetPivot()
		clone.MeshPart.CFrame = clone.CFrame * CFrame.new(0, -3, -24)
		clone.Parried:Play()
		clone.ParryAttempt.TimePosition = 0.2
		clone.ParryAttempt:Play()
		clone.Sound2:Play()
		clone.AT.ParticleEmitter:Emit(40)
		clone.AT.Specs1:Emit(40)
		clone.At2.ParticleEmitter:Emit(10)
		clone.At2.RealLa:Emit(2)
		Debris:AddItem(clone, 8)
		local animator = instance:FindFirstChildWhichIsA("Animator", true)

		if animator then
			for _, v4 in animator:GetPlayingAnimationTracks() do
				if v4.Animation == script.RaptureAttempt then
					v4:Stop(0)
				end
			end

			animator:LoadAnimation(script.RaptureSuccess):Play()
		end

		local humanoid = instance:FindFirstChildWhichIsA("Humanoid", true)

		if humanoid then
			v2:RemoveModifierFor(instance, "Rapture")

			if humanoid.FloorMaterial ~= Enum.Material.Air then
				clone.MeshPart.Transparency = 0
				task.spawn(function()
					TweenService:Create(
						clone.MeshPart,
						TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Color = Color3.fromRGB(255, 145, 94)
						}
					):Play()
					task.wait(0.3)
					TweenService:Create(
						clone.MeshPart,
						TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Color = Color3.new(0, 0, 0)
						}
					):Play()
					task.wait(0.5)
					TweenService:Create(
						clone.MeshPart,
						TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end

		for _, player in Players:GetPlayers() do
			if not (player.Character and player.Character.Parent == workspace.Alive and player:DistanceFromCharacter(instance:GetPivot().Position) <= 20) then
				continue
			end

			script.CCEffect:FireClient(player)
		end

		v({
			cframe = instance:GetPivot(),
			diameter = 40,
			color = Color3.fromRGB(255, 166, 125)
		})
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {
			workspace.Alive,
			workspace.Balls,
			workspace.Dead,
			workspace.TrainingBalls
		}
		local raycastResult = workspace:Raycast(instance:GetPivot().Position, createVector(0, -100, 0), raycastParams)

		if not raycastResult or not humanoid or humanoid.FloorMaterial == Enum.Material.Air then
			return "CancelAndInvalidate"
		end

		clone.MeshPart.dust.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone.MeshPart.rocks.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone.MeshPart.dots.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone.MeshPart.dust:Emit(40)

		if raycastResult.Material == Enum.Material.Slate then
			clone.MeshPart.rocks:Emit(25)
		else
			clone.MeshPart.dots:Emit(25)
		end

		local clone2 = ReplicatedStorage2.Misc.Rocks:Clone()
		clone2:PivotTo(clone.CFrame * CFrame.new(0, 1, -6))
		clone2.Parent = workspace.Runtime
		Debris:AddItem(clone2, 8)

		for _, part in clone2:GetChildren() do
			if not (part.Name == "Wedge" and part:IsA("BasePart")) then
				continue
			end

			local v4 = part
			task.spawn(function()
				v4.Color = raycastResult.Instance.Color
				v4.Material = raycastResult.Material
				local position = v4.Position
				local wedgeR = clone2:FindFirstChild("wedgeR")
				local X = v4.Position.X
				local v5

				if wedgeR then
					v5 = wedgeR.Position.Y
				else
					v5 = v4.Position.Y
				end

				local vector2 = Vector3.new(X, v5, v4.Position.Z)
				v4.Position = vector2
				local size = v4.Size
				v4.Size = createVector(0, 0, 0)
				TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = size * 1.2,
					Position = position
				})
				task.wait(0.25)
				TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = size
				})
				task.wait(4)
				TweenService:Create(v4, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Position = vector2
				})
			end)
		end

		return "CancelAndInvalidate"
	end

	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		child.AddCustomCollisionResponse:Invoke(script.RaptureCollisionResponse, 60)
	end)
else
	script.CCEffect.OnClientEvent:Connect(function()
		Lighting.cc1.Enabled = true
		task.delay(0.08, function()
			Lighting.cc1.Enabled = false
		end)
	end)
end

local Rapture = {}
Rapture.cooldown = 30
Rapture.iconId = "rbxassetid://14722857062"

function Rapture.canBeUsed(p)
	if v3.GetCharacterTargetCharacter(p.character) then
		return true
	end

	return false
end

function Rapture.localOwnerActivation(p)
	local DELAY_DURATION = 0.8
	ReplicatedStorage2.Remotes.M1Stop:Fire(true)
	local isRaptureChangedConnection = nil
	isRaptureChangedConnection = p.character:GetAttributeChangedSignal("IsRapture"):Connect(function()
		if p.character:GetAttribute("IsRapture") then
			return
		end

		isRaptureChangedConnection:Disconnect()
		ReplicatedStorage2.Remotes.M1Stop:Fire(false)
	end)
	task.delay(DELAY_DURATION, function()
		ReplicatedStorage2.Remotes.M1Stop:Fire(false)
	end)
	local characterTargetCharacter = v3.GetCharacterTargetCharacter(p.character)
	local v4 = v2:SetModifierFor(p.character, "Rapture", v2.Utils.MinDebuff(p.character, 0), v2.Priority.DEBUFF)
	task.delay(DELAY_DURATION, v4)
	local track = p.animator:LoadAnimation(script.RaptureAttempt)
	track:Play()
	task.delay(DELAY_DURATION, function()
		track:Stop(0.2)
	end)
	return {
		target = characterTargetCharacter
	}
end

function Rapture.serverActivationAsync(p)
	p.character:SetAttribute("IsRapture", true)
	task.delay(0.8, p.character.SetAttribute, p.character, "IsRapture", nil)
	local clone = ReplicatedStorage2.Misc.RaptureAttempt:Clone()
	clone.Parent = p.rootPart
	clone.CFrame = clone.Parent.CFrame
	clone.WeldConstraint.Part1 = clone.Parent
	Debris:AddItem(clone, 3)
	clone.Sound:Play()
	clone.Attachment.Wind:Emit(4)
	task.delay(1, function()
		clone.Sound:Stop()
	end)
end

return Rapture