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
script:FindFirstChild("Sounds")
local token = modules.Effects.Token
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
local CraterExtension = require(modules.Effects.Craters.CraterExtension)
require(modules.Effects.Craters.CraterEffects)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
require(modules.Effects.BoatTween)
require(token.BezierCurve)
require(token.TokenUtility)
local TokenKit = require(token.TokenKit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local RaycastHelper = require(ReplicatedStorage2.CAM.Global.RaycastHelper)
local v = {
	CFrame.new(0.2410888671875, -1.4503211975097656, -11.24835205078125) * CFrame.fromEulerAnglesYXZ(
		0.6584060192108154,
		-1.554336428642273,
		2.4937963485717773
	),
	CFrame.new(3.318603515625, -0.41973114013671875, -12.170654296875) * CFrame.fromEulerAnglesYXZ(
		0.7293819785118103,
		1.1829335689544678,
		-2.0760233402252197
	),
	CFrame.new(-0.89459228515625, 7.360927581787109, -15.89605712890625) * CFrame.fromEulerAnglesYXZ(
		0.8402900695800781,
		-1.511429786682129,
		1.7567439079284668
	),
	CFrame.new(6.51812744140625, 14.491706848144531, -13.81488037109375) * CFrame.fromEulerAnglesYXZ(
		0.8127686381340027,
		1.4466707706451416,
		-1.8915178775787354
	)
}
local v2 = {
	Cancel = true,
	Hit = true,
	UltimateCamera = true
}
return function(instance, p: string, instance2, cFrame: CFrame, instance3)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	instance:FindFirstChild("UpperTorso")

	if p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	local name = string.format("%s Torrential_Arrows_Effects", instance.Name)
	local parent = debree:FindFirstChild(name)

	if not v2[p] then
		if parent ~= nil then
			parent:Destroy()
		end

		parent = Instance.new("Folder")
		parent.Name = name
		parent.Parent = debree
		DebrisModule:AddItem(parent, 8)
	end

	if p == "Start" then
		local clone = assets.Part:Clone()
		clone.Parent = parent
		clone.CFrame = cFrame
		DebrisModule:AddItem(clone, 3)
		local clone2 = script.Sounds.PS2arrowELEVATORsummon:Clone()
		clone2.Parent = clone
		clone2:Play()
		task.delay(0.4, function()
			if clone ~= nil and clone.Parent ~= nil then
				local clone3 = script.Sounds.PS2arrowELEVATORstabgrab:Clone()
				clone3.Parent = clone
				clone3:Play()
			end
		end)
		local position = clone.Position

		for i = 1, 5 do
			local v5 = (i - 1) * 1.2566370614359172
			local v6 = math.cos(v5) * 10
			local v7 = math.sin(v5) * 10
			local v8 = position + Vector3.new(v6, math.random(5, 7), v7)
			local clone3 = assets.ArrowModel:Clone()
			clone3.Parent = parent
			clone3:PivotTo(CFrame.new(v8) * CFrame.Angles(0, v5, 0))
			clone3.PrimaryPart.CFrame = CFrame.lookAt(clone3.PrimaryPart.Position, clone.Position)

			for _, descendant in clone3:GetDescendants() do
				if descendant.ClassName == "ParticleEmitter" then
					descendant:Emit(descendant:GetAttribute("EmitCount"))
				end

				if descendant.ClassName == "Trail" then
					descendant.Enabled = true
				end

				if descendant.ClassName == "Decal" then
					descendant.Transparency = 0
				end
			end

			DebrisModule:AddItem(clone3, 5)
			local folder = clone3
			task.delay(0.1, function()
				TweenService:Create(folder.PrimaryPart, TweenInfo.new(0.3), {
					CFrame = folder.PrimaryPart.CFrame * CFrame.new(0, 0, -15)
				}):Play()
				task.wait(0.3)

				for i2, descendant in folder:GetDescendants() do
					if descendant.ClassName == "ParticleEmitter" then
						descendant.Enabled = false
					end

					if descendant.ClassName == "Trail" then
						descendant.Enabled = false
					end

					if descendant.ClassName == "Decal" then
						TweenService:Create(descendant, TweenInfo.new(0.2), {
							Transparency = 1
						}):Play()
					end
				end
			end)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Hit" then
		if not instance2 then
			return
		end

		local rootPart = instance2:FindFirstChild("Humanoid").RootPart

		if not parent:IsDescendantOf(workspace.Debree) then
			return
		end

		local clone = script.Sounds.PS2arrowELEVATORcinematic:Clone()
		clone.Parent = rootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		local clone2 = assets.HumanoidRootPart:Clone()
		clone2.Parent = parent
		clone2.CFrame = rootPart.CFrame
		vfxUtility.EmitAll(clone2:GetDescendants(), vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 3)
		task.spawn(function()
			task.wait(0.25)

			for i = 1, 4 do
				if not parent:IsDescendantOf(workspace.Debree) then
					break
				end

				local clone3 = assets.ArrowModel:Clone()
				clone3.Parent = parent
				clone3:PivotTo(rootPart.CFrame * v[i])
				DebrisModule:AddItem(clone3, 0.5)

				for _, descendant in clone3:GetDescendants() do
					if descendant.ClassName == "Trail" then
						descendant.Enabled = true
					end

					if descendant.ClassName == "Decal" then
						descendant.Transparency = 0
					end
				end

				TweenService:Create(clone3.PrimaryPart, TweenInfo.new(0.2), {
					CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, 0, -10)
				}):Play()
				local folder = clone3
				task.delay(0.25, function()
					for i2, descendant in folder:GetDescendants() do
						if descendant.ClassName == "Trail" then
							descendant.Enabled = false
						end

						if descendant.ClassName == "Decal" then
							TweenService:Create(descendant, TweenInfo.new(0.1), {
								Transparency = 1
							}):Play()
						end
					end
				end)
				task.wait(0.25)
			end
		end)
		task.delay(1.4, function()
			if not parent:IsDescendantOf(workspace.Debree) then
				return
			end

			local clone3 = assets.Part.SummonPurp:Clone()
			clone3.Parent = instance.LeftHand
			DebrisModule:AddItem(clone3, 3)
			vfxUtility.EmitAll(clone3:GetDescendants(), vfxUtility.Owned(instance))
		end)
		task.wait(1.2)

		if not parent:IsDescendantOf(workspace.Debree) then
			return
		end

		local clone3 = assets.ArrowModel:Clone()
		clone3.Parent = parent
		clone3:PivotTo(rootPart.CFrame * CFrame.new(1.015380859375, 19.71856117248535, -17.26824951171875) * CFrame.fromEulerAnglesYXZ(
			-1.5392810106277466,
			-2.3048222064971924,
			2.305187702178955
		))
		DebrisModule:AddItem(clone3, 3)

		for _, descendant in clone3:GetDescendants() do
			if descendant.ClassName == "ParticleEmitter" then
				descendant:Emit(descendant:GetAttribute("EmitCount"))
			end

			if descendant.ClassName == "Trail" then
				descendant.Enabled = true
			end

			if descendant.ClassName == "Decal" then
				descendant.Transparency = 0
			end
		end

		task.wait(0.9)

		if not parent:IsDescendantOf(workspace.Debree) then
			return
		end

		vfxUtility.EnableAll(clone3.MainPart, true, vfxUtility.Owned(instance))
		TweenService:Create(clone3.PrimaryPart, TweenInfo.new(0.6), {
			CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, 0, -30)
		}):Play()
		task.wait(0.1)

		if not parent:IsDescendantOf(workspace.Debree) then
			return
		end

		local upperTorso = instance2:FindFirstChild("UpperTorso") or instance2:FindFirstChild("Torso") or instance2:FindFirstChild("HumanoidRootPart")

		if upperTorso == nil then
			return
		end

		local raycastResult = workspace:Raycast(upperTorso.Position, createVector(0, -70, 0), RaycastHelper.Crater)
		local clone4 = assets.ArrowHit2:Clone()
		clone4.Parent = parent
		clone4.CFrame = CFrame.new(raycastResult.Position)
		vfxUtility.EnableAll(clone3, false)

		for _, descendant in clone3:GetDescendants() do
			if descendant.ClassName == "Trail" then
				descendant.Enabled = false
			end

			if descendant.ClassName == "Decal" then
				TweenService:Create(descendant, TweenInfo.new(0.6), {
					Transparency = 1
				}):Play()
			end
		end

		vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone4, 6)
		CraterExtension.Ground(clone4.Position, 10, createVector(2.5, 2.5, 2), nil, 2, false, 2)
		CraterExtension.Ground(clone4.Position, 8, createVector(2.5, 2.5, 2), nil, 5, false, 2)
		task.spawn(TokenKit.GroundRocks, {
			CF = clone4.CFrame,
			InnerRadius = 5,
			OuterRadius = 10,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 1,
				Max = 3
			}
		})
		Cam_Shaker(clone4.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.4,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "UltimateCamera" then
		local clone = assets.CameraVFX:Clone()
		clone.Parent = parent
		local rigidConstraint = clone.Bone.Attachment.RigidConstraint
		local camattach = clone.Bone.camattach
		DebrisModule:AddItem(clone, 6)
		camattach.Parent = instance3:FindFirstChild("Bone")
		rigidConstraint.Attachment1 = camattach
		task.delay(2, function()
			Ouwmit.Emit(clone.DunkCameraVertical, Ouwmit.Owned(instance))
		end)
	elseif p == "Cancel" then
		if parent == nil or parent.Parent == nil then
			return
		else
			parent:Destroy()
		end
	end
end