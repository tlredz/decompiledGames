local createVector = vector.create
game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local debree = workspace.Debree
local assets = script:FindFirstChild("Assets")
local rigs = script:FindFirstChild("Rigs")
local token = modules.Effects.Token
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local TokenKit = require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local currentCamera = workspace.CurrentCamera
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)

function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 5
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

local v = {
	ArrowEruption = true,
	Cancel = true
}
return function(instance, p: string, _)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Arrow_Eruption_Effects", instance.Name)
	local parent = debree:FindFirstChild(name)

	if not v[p] then
		if parent ~= nil then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 12)
	end

	if parent == nil then
		return
	end

	if p == "Start" then
		local rightHand = instance:FindFirstChild("RightHand")
		local clone = assets.hand:Clone()
		clone.Parent = parent
		clone:PivotTo(rightHand.CFrame)
		clone.Anchored = false
		local clone2 = script.Sounds.arroweruptionpt1:Clone()
		clone2.Parent = clone
		clone2:Play()
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		local weld = Instance.new("Weld")
		weld.Parent = rightHand
		weld.Part0 = rightHand
		weld.Part1 = clone
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.6,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "ArrowEruption" then
		if humanoidRootPart == nil then
			return
		end

		local clone = rigs.EruptionRe:Clone()
		clone.Parent = parent
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 3, 0),
			createVector(0, -15, 0),
			RaycastHelper.Crater
		)
		local instance2

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			instance2 = raycastResult.Instance
		end

		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3, -1.29))
		DebrisModule:AddItem(clone, 3.25)
		clone.AnimationController.Animator:LoadAnimation(assets.RigAnimation):Play()
		task.delay(1.2, function()
			if clone == nil or clone.Parent == nil then
				return
			end

			local clone2 = script.Sounds.arroweruptionpt2:Clone()
			clone2.Parent = clone.RootPart
			clone2:Play()

			if clone == nil or clone.Parent == nil then
				return
			end

			task.wait(1.25)

			if clone == nil or clone.Parent == nil then
				return
			end

			TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.5), {
				CFrame = clone.PrimaryPart.CFrame * CFrame.new(0, -15, 0)
			})

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end

				if not (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("Model") and descendant.Transparency == 0) then
					continue
				end

				TweenService:Create(descendant, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end
		end)
		local clone2 = assets.First:Clone()
		clone2.Parent = parent
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.5, -2.8, 0.5)
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(instance2)))
		DebrisModule:AddItem(clone2, 6)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = humanoidRootPart.CFrame,
			InnerRadius = 5,
			OuterRadius = 25,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		BlurEffect(0.2)
		task.wait(1.5)

		if clone == nil or clone.Parent == nil then
			return
		end

		local clone3 = assets.Second:Clone()
		clone3.Parent = parent
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.5, -2.8, 0.5)
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(instance2)))
		DebrisModule:AddItem(clone3, 6)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone3.CFrame,
			InnerRadius = 5,
			OuterRadius = 25,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 0.5,
				Max = 1
			}
		})
		BlurEffect(0.2)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Cancel" then
		parent:Destroy()
	end
end