local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
return function(instance, p)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	local parent = workspace:FindFirstChild("Debree")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "Debree"
		parent.Parent = workspace
	end

	if p == "Cancel" then
		return
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

	if p == "Slice1" then
		local clone = script.Strike1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -4.5))
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(script, "PS2clawsPredatorClawsSlash1", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Slice2" then
		local clone = script.Strike2:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -4.5))
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(script, "PS2clawsPredatorClawsSlash2", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.3,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Slice3" then
		local clone = script.Slash3:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(script, "PS2clawsPredatorClawsDashFORWARD", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Slash4" then
		local clone = script.Slash4:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 14.5))
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
		DebrisModule:AddItem(clone, 5)
		vfxUtility.PlaySound(script, "PS2clawsPredatorClawsDashBACKWARDS", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.125,
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	end
end