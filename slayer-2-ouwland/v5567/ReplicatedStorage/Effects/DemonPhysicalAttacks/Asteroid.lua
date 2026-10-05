local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local jump = script:WaitForChild("Jump")
local v = script:WaitForChild("End")
local debree = workspace.Debree

local function emitAtRoot(instance, cframe: CFrame, p: number, instance2)
	local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -20, 0), RaycastHelper.Crater)
	local v2

	if raycastResult then
		v2 = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	end

	if raycastResult ~= nil then
		local lookVector = cframe.LookVector
		local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v3 = not (vector2.Magnitude > 0.001) and createVector(0, 0, 1) or vector2.Unit
		local v4 = raycastResult.Position + createVector(0, 3, 0)
		cframe = CFrame.lookAt(v4, v4 + v3)
	end

	local clone = instance:Clone()
	clone:PivotTo(cframe * clone.Root.CFrame:ToObjectSpace(clone:GetPivot()))
	clone.Parent = debree
	Ouwmit.Emit(clone, Ouwmit.Owned(instance2, v2))
	DebrisModule:AddItem(clone, p)
	return raycastResult, clone
end

return function(instance, p: string?, p2)
	if p == "Crash" then
		if typeof(p2) ~= "CFrame" or (p2.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		Cam_Shaker(p2.Position, {
			FadeInTime = 0,
			Frequency = 0.22,
			Amplitude = 1,
			SustainTime = 0.05,
			FadeOutTime = 0.8,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(1, 1, 1)
		})
		local v2, v3 = emitAtRoot(v, p2, 3, instance)
		vfxUtility.PlaySound(script.Sounds, "PS2evilspiritASTEROIDslam", v3.Root, true)

		if v2 ~= nil then
			OuwCraters.Scales({
				Center = CFrame.new(v2.Position),
				Count = 6,
				Radius = 5,
				ScaleMult = 0.8
			})
		end
	else
		if instance == nil then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		if p == "Startup" then
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.3,
				Amplitude = 0.25,
				SustainTime = 0.2,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
		elseif p == "Jump" then
			vfxUtility.PlaySound(script.Sounds, "PS2evilspiritASTEROIDjump", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.25,
				Amplitude = 0.4,
				SustainTime = 0.1,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(0.5, 0.5, 0.5)
			})
			emitAtRoot(jump, humanoidRootPart.CFrame, 3, instance)
		end
	end
end