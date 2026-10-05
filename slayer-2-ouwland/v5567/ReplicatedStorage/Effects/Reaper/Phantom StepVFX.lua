local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
game:GetService("RunService")
return function(instance, p: string, _)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or p ~= "Cancel" and vector.magnitude(humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position) > 200 then
		return
	end

	string.format("%s %s", instance.Name, script.Name)
	local upperTorso = instance:WaitForChild("UpperTorso")

	if p == "Start" then
		local cFrame = humanoidRootPart.CFrame
		Cam_Shaker(cFrame.Position, "activate_shake")
		local upperTorso2 = instance:FindFirstChild("UpperTorso")

		if upperTorso2 ~= nil then
			local clone = script.Parent["Reap Of DespairVFX"].SkillAssets.Init["Root/TorsoEnable"]:Clone()
			clone.Parent = upperTorso2
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone, 2)
		end

		local clone = script.Parent["Reap Of DespairVFX"].SkillAssets.Init.Startup:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		local raycastResult = workspace:Raycast(cFrame.Position, cFrame.UpVector * -8, RaycastHelper.Crater)
		local color

		if not (raycastResult == nil or raycastResult.Instance == nil) then
			color = raycastResult.Instance.Color
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, {
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		}))
		DebrisModule:AddItem(clone, 2)
		local clone2 = script.Sounds.PS2reaperDASHinititate:Clone()
		clone2.Parent = clone.Root
		clone2:Play()
	elseif p == "Step" then
		local torsoDust = upperTorso:FindFirstChild("TorsoDust")

		if torsoDust ~= nil then
			torsoDust:Destroy()
		end

		local clone = script.SkillAssets.TorsoDust:Clone()
		clone.Parent = upperTorso
		DebrisModule:AddItem(clone, 4)
		task.wait(2.7)

		if clone == nil or clone.Parent == nil or clone.Name == "--" then
			return
		end

		vfxUtility.EnableAll(clone, false)
	elseif p == "ZigZag" then
		local emitLRHRP = humanoidRootPart:FindFirstChild("EmitLRHRP")

		if emitLRHRP ~= nil then
			emitLRHRP:Destroy()
		end

		local clone = script.SkillAssets.EmitLRHRP:Clone()
		clone.Parent = humanoidRootPart
		DebrisModule:AddItem(clone, 3)
		local clone2 = script.Sounds.PS2reaperDASHloop:Clone()
		clone2.Name = "Sound"
		clone2.Parent = clone
		clone2:Play()
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local color

		if raycastResult and raycastResult.Instance ~= nil then
			color = raycastResult.Instance.Color
		end

		for _ = 1, 2 do
			if clone == nil or clone.Parent == nil or clone.Name == "--" then
				return
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			} or nil) or nil))
			task.wait(0.4166666666666667)
		end

		for _ = 1, 2 do
			if clone == nil or clone.Parent == nil or clone.Name == "--" then
				return
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			} or nil) or nil))
			task.wait(0.25)
		end

		for _ = 1, 2 do
			if clone == nil or clone.Parent == nil or clone.Name == "--" then
				return
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.2,
				SustainTime = 0.2,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(2.5, 2.5, 2.5)
			})
			vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
				Color = color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			} or nil) or nil))
			task.wait(0.16666666666666666)
		end

		if clone == nil or clone.Parent == nil or clone.Name == "--" then
			return
		end

		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance, color ~= nil and ({
			Color = color,
			ColorWhitelist = { "DustRaycast", "dustraycast" }
		} or nil) or nil))
	elseif p == "Cancel" then
		if upperTorso ~= nil then
			local torsoDust = upperTorso:FindFirstChild("TorsoDust")

			if torsoDust ~= nil then
				vfxUtility.EnableAll(torsoDust, false)
				torsoDust.Name = "--"
				DebrisModule:AddItem(torsoDust, 2)
			end
		end

		local emitLRHRP = humanoidRootPart:FindFirstChild("EmitLRHRP")

		if emitLRHRP ~= nil then
			emitLRHRP.Name = "--"
			local sound = emitLRHRP:FindFirstChild("Sound")

			if sound ~= nil then
				TweenService:Create(sound, TweenInfo.new(0.3), {
					Volume = 0
				}):Play()
				DebrisModule:AddItem(sound, 0.3)
			end

			DebrisModule:AddItem(emitLRHRP, 2)
		end
	elseif p == "End" then
		local configuration = Instance.new("Configuration", workspace.Debree)
		DebrisModule:AddItem(configuration, 4)

		if upperTorso ~= nil then
			local torsoDust = upperTorso:FindFirstChild("TorsoDust")

			if torsoDust ~= nil then
				vfxUtility.EnableAll(torsoDust, false)
				torsoDust.Name = "--"
				DebrisModule:AddItem(torsoDust, 2)
			end
		end

		local emitLRHRP = humanoidRootPart:FindFirstChild("EmitLRHRP")

		if emitLRHRP ~= nil then
			emitLRHRP.Name = "--"
			local sound = emitLRHRP:FindFirstChild("Sound")

			if sound ~= nil then
				TweenService:Create(sound, TweenInfo.new(0.3), {
					Volume = 0
				}):Play()
				DebrisModule:AddItem(sound, 0.3)
			end

			DebrisModule:AddItem(emitLRHRP, 2)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		local clone = script.SkillAssets.Dash:Clone()
		clone.Parent = configuration
		local clone2 = script.Sounds.PS2reaperDASHdash:Clone()
		clone2.Parent = clone.HumanoidRootPart
		clone2:Play()
		clone:PivotTo(humanoidRootPart.CFrame)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		local clone3 = script.SkillAssets.GroundCracks:Clone()
		clone3.Parent = configuration
		clone3:PivotTo(humanoidRootPart.CFrame)
		vfxUtility.EmitAll(clone3, vfxUtility.Owned(instance))
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 3)
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone3.PrimaryPart
		weld.Parent = clone3.PrimaryPart
		TweenService:Create(clone3.MaceHit.lightattach.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone3.MaceHit.Point.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone3.MaceHit.Attachment.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
		task.wait(0.5)
		vfxUtility.EnableAll(clone3, false)
		local clone4 = script.SkillAssets.EndingFinish:Clone()
		clone4:PivotTo(humanoidRootPart.CFrame)
		clone4.Parent = configuration
		DebrisModule:AddItem(clone4, 2.8)
		local raycastResult = workspace:Raycast(
			clone4.PrimaryPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance, {
				Color = raycastResult.Instance.Color,
				ColorWhitelist = { "DustRaycast", "dustraycast" }
			}))
		else
			vfxUtility.EmitAll(clone4, vfxUtility.Owned(instance))
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.275,
			SustainTime = 0.5,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	end
end