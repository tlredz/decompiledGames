local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(p)
	local raycastResult = workspace:Raycast(
		p.Position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local v = {
	FadeInTime = 0,
	Frequency = 0.16,
	Amplitude = 2,
	SustainTime = 0.05,
	FadeOutTime = 1,
	RotationInfluence = createVector(0.35, 0.35, 0.35),
	PositionInfluence = createVector(1, 1, 1)
}

local function burst(childName: string, humanoidRootPart)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone:PivotTo(humanoidRootPart.CFrame)
	clone.Parent = workspace.Debree
	Ouwmit.Emit(clone, Ouwmit.Owned(humanoidRootPart, groundDust(humanoidRootPart)))
	DebrisModule:AddItem(clone, 4)
end

local function activeName(value: string?)
	return (`HandDemonScreamActive-{value or ""}`)
end

local function stopActive(value: string?)
	local child = workspace.Debree:FindFirstChild((`HandDemonScreamActive-{value or ""}`))

	if child ~= nil then
		child.Name = "--"
		Ouwmit.Enable(child, false)
		local pS2handdemonSKILLSscreamSCREAM = child:FindFirstChild("PS2handdemonSKILLSscreamSCREAM", true)

		if pS2handdemonSKILLSscreamSCREAM ~= nil then
			pS2handdemonSKILLSscreamSCREAM:Stop()
		end

		DebrisModule:AddItem(child, 2.5)
	end
end

return function(instance, p: string?, value: string?)
	if p == "Finish" or p == "Cancel" then
		stopActive(value)

		if p == "Cancel" then
			return
		end
	end

	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "Windup" then
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.2,
			Amplitude = 0.4,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1, 1, 1)
		})
		burst("Initial", humanoidRootPart)
		vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSscreamINIT", humanoidRootPart, true)
	elseif p == "Scream" then
		if workspace.Debree:FindFirstChild((`HandDemonScreamActive-{value or ""}`)) == nil then
			local active = script:FindFirstChild("Active")

			if active ~= nil then
				Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0,
					Frequency = 0.2,
					Amplitude = 0.4,
					SustainTime = 2,
					FadeOutTime = 1,
					RotationInfluence = createVector(0.5, 0.5, 0.5),
					PositionInfluence = createVector(1, 1, 1)
				})
				local clone = active:Clone()
				clone.Name = `HandDemonScreamActive-{value or ""}`
				clone:PivotTo(humanoidRootPart.CFrame)
				clone.Parent = workspace.Debree
				Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart)))
				local v2

				if clone:IsA("Model") then
					v2 = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart") or clone
				else
					v2 = clone
				end

				vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSscreamSCREAM", v2)
				DebrisModule:AddItem(clone, 8)
			end
		end
	elseif p == "Finish" then
		Cam_Shaker(humanoidRootPart.Position, v)
		burst("Ending", humanoidRootPart)
		vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSscreamEND", humanoidRootPart, true)
	end
end