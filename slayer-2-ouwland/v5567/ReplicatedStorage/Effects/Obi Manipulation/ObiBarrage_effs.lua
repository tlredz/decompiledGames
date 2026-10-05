local createVector = vector.create
game:GetService("Players")
game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local debree = workspace.Debree
local skillAssets = script:FindFirstChild("SkillAssets")
local sounds = script:FindFirstChild("Sounds")
script:FindFirstChild("Rigs")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local DebrisModule = require(CAM.DebrisModule)
local Cam_Shaker = require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterExtension)
local token = modules.Effects.Token
local TokenKit = require(token.TokenKit)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
local _ = { "Raycast" }
local _ = { "Raycast", "GroundDust" }
return function(instance, p: string, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil or p ~= "Cancel" and (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	instance:FindFirstChild("UpperTorso")
	local name = string.format("%s Obi_Barrage_Effects", instance.Name)
	local parent2 = debree:FindFirstChild(name)

	if p == "Start" then
		if parent2 ~= nil then
			parent2:Destroy()
		end

		parent2 = Instance.new("Folder")
		parent2.Name = name
		parent2.Parent = debree
		DebrisModule:AddItem(parent2, 12)
		local clone = skillAssets.Jump:Clone()
		clone.Parent = parent2
		clone:PivotTo(humanoidRootPart.CFrame)
		DebrisModule:AddItem(clone, 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v3))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif parent2 == nil then
		return
	end

	if p == "Barrage" then
		local clone = skillAssets.initial:Clone()
		clone.Parent = parent2
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.1961669921875, -0.6954622268676758, -2.12188720703125) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			2.755462884902954
		)
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone
		weld.Parent = humanoidRootPart
		weld.C0 = CFrame.new(-0.1961669921875, -0.6954622268676758, -2.12188720703125) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			2.755462884902954
		)
		local flag = true
		local v3 = vfxUtility.PlaySound(sounds, "PS2FleshManiObiBRRGswingloop", humanoidRootPart, false)
		parent2:SetAttribute("Active", true)
		clone.AncestryChanged:Connect(function(_, parent)
			if not parent then
				flag = false
				v3:Stop()
				vfxUtility.PlaySound(sounds, "PS2FleshManiObiBRRGbrrgSTOP", humanoidRootPart, true)
			end
		end)
		task.spawn(function()
			while flag do
				local clone2 = skillAssets.Mini:Clone()
				clone2.Parent = parent2
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(
					math.random(-5, 5),
					-9.596467018127441,
					math.random(-10, -2)
				) * CFrame.fromEulerAnglesYXZ(-0, -1.5707963705062866, 0)
				local raycastResult = workspace:Raycast(
					clone2.Position + createVector(0, 1, 0),
					createVector(-0, -2, -0),
					raycastParams
				)

				if raycastResult then
					local clone3 = skillAssets:FindFirstChild("ImpactGround"):Clone()
					clone3.Parent = parent2
					clone3.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone3.CFrame *= CFrame.new(0, clone3.Size.Y, 0)
					DebrisModule:AddItem(clone3, 6)
					local cFrame = clone3.CFrame
					local raycastResult2 = workspace:Raycast(
						cFrame.Position + createVector(0, 5, 0),
						createVector(-0, -15, -0),
						RaycastHelper.Crater
					)
					local v4 = raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
					Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v4))
					vfxUtility.PlaySound(
						sounds,
						"PS2FleshManiObiBRRGgroundimp" .. tostring(math.random(1, 2)),
						humanoidRootPart,
						true
					)
				end

				vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
				DebrisModule:AddItem(clone2, 3.5)
				Cam_Shaker(clone2.Position, {
					FadeInTime = 0,
					Frequency = 0.05,
					Amplitude = 0.05,
					SustainTime = 0.1,
					FadeOutTime = 0.1,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(3.5, 3.5, 3.5)
				})
				task.wait(0.05)
			end
		end)
	end

	if p == "Final" then
		parent2.Name = "--"
		parent2:SetAttribute("Active")
		local initial = parent2:FindFirstChild("initial")

		if initial then
			initial:Destroy()
		end

		local clone = skillAssets.Thrust:Clone()
		clone.Parent = parent2
		clone:PivotTo(humanoidRootPart.CFrame)
		DebrisModule:AddItem(clone, 3)
		local cFrame = humanoidRootPart.CFrame
		local raycastResult = workspace:Raycast(
			cFrame.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v3 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v3))
		vfxUtility.PlaySound(sounds, "PS2FleshManiObiBRRGlaunch", humanoidRootPart, true)
		task.wait(0.1)
		local clone2 = skillAssets.Final:Clone()
		clone2.Parent = parent2
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0.77081298828125, -10.596467018127441, -6.23773193359375) * CFrame.fromEulerAnglesYXZ(
			-0,
			-1.5707963705062866,
			0
		)
		vfxUtility.PlaySound(sounds, "PS2FleshManiObiBRRGfinale", clone2, true)
		local raycastResult2 = workspace:Raycast(
			clone2.Position + createVector(0, 5, 0),
			createVector(-0, -10, -0),
			raycastParams
		)

		if raycastResult2 then
			local clone3 = skillAssets:FindFirstChild("FinalGround"):Clone()
			clone3.Parent = parent2
			clone3.CFrame = CFrame.new(raycastResult2.Position, raycastResult2.Position - raycastResult2.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone3.CFrame *= CFrame.new(0, clone3.Size.Y, 0)
			DebrisModule:AddItem(clone3, 6)
			local cFrame2 = clone3.CFrame
			local raycastResult3 = workspace:Raycast(
				cFrame2.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local v4 = raycastResult3 and vfxUtility.GetDustColorSettings(raycastResult3.Instance) or nil
			Ouwmit.Emit(clone3, Ouwmit.Owned(instance, v4))
		end

		local cFrame2 = clone2.CFrame
		local raycastResult3 = workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v4 = raycastResult3 and vfxUtility.GetDustColorSettings(raycastResult3.Instance) or nil
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v4))
		DebrisModule:AddItem(clone2, 3)
		OuwCraters.Scales({
			Center = clone2.CFrame,
			Duration = 2.5,
			Radius = 12,
			ScaleMult = 0.8
		})
		task.spawn(TokenKit.GroundRocks, {
			CF = clone2.CFrame,
			InnerRadius = 19,
			OuterRadius = 21,
			Velocity = {
				Min = 20,
				Max = 40
			},
			Size = {
				Min = 1,
				Max = 3
			}
		})
	end

	local child = p == "Cancel" and debree:FindFirstChild(name)

	if child then
		local initial = child:FindFirstChild("initial")

		if initial then
			initial:Destroy()
		end

		child.Name = "_"
		child:SetAttribute("Active", false)
		DebrisModule:AddItem(child, 2)
	end
end