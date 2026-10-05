local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local debree = workspace.Debree

local function emitAtRoot(childName: string, cframe: CFrame, p: number, instance)
	local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -20, 0), RaycastHelper.Crater)
	local v

	if raycastResult then
		v = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	end

	if raycastResult ~= nil then
		local lookVector = cframe.LookVector
		local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v2 = not (vector2.Magnitude > 0.001) and createVector(0, 0, 1) or vector2.Unit
		local v3 = raycastResult.Position + createVector(0, 3, 0)
		cframe = CFrame.lookAt(v3, v3 + v2)
	end

	local child = script:FindFirstChild(childName)

	if child == nil then
		return raycastResult
	end

	local clone = child:Clone()
	local root = clone:FindFirstChild("Root")

	if root == nil then
		clone:PivotTo(cframe)
	else
		clone:PivotTo(cframe * root.CFrame:ToObjectSpace(clone:GetPivot()))
	end

	clone.Parent = debree
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
	DebrisModule:AddItem(clone, p)
	return raycastResult
end

return function(instance, p: string?, p2)
	if p == "Slam" then
		if typeof(p2) ~= "CFrame" or (p2.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		local humanoidRootPart = instance and (instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart)

		if humanoidRootPart then
			vfxUtility.PlaySound(script.Sounds, "PS2evilspiritGROUNDSLAM", humanoidRootPart, true)
		end

		Cam_Shaker(p2.Position, {
			FadeInTime = 0,
			Frequency = 0.24,
			Amplitude = 1,
			SustainTime = 0.1,
			FadeOutTime = 1.25,
			RotationInfluence = createVector(0.4, 0.4, 0.4),
			PositionInfluence = createVector(0.8, 0.8, 0.8)
		})
		local v = emitAtRoot("SlamEffect", p2, 3, instance)

		if v ~= nil then
			OuwCraters.Scales({
				Center = CFrame.new(v.Position),
				Count = 6,
				Radius = 5,
				ScaleMult = 0.6
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
			emitAtRoot("Startup", humanoidRootPart.CFrame, 3, instance)
		end
	end
end