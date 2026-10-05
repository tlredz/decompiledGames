local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(humanoidRootPart)
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(parent, instance, p: string)
	if parent == nil then
		return
	end

	local humanoidRootPart = instance and (instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart)

	if p == "SprintActivated" then
		if humanoidRootPart == nil then
			return
		end

		local clone = script.HorseGallop:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent
		Ouwmit.Emit(clone, Ouwmit.Owned(parent, groundDust(humanoidRootPart)))
		DebrisModule:AddItem(clone, 3)
	else
		local v = p == "Gallop" or p == "Sprint"
		local horseRunEffect = parent:FindFirstChild("HorseRunEffect")

		if v then
			local humanoidRootPart2 = horseRunEffect == nil and parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				local clone = script.HorseRun:Clone()
				clone.Name = "HorseRunEffect"
				clone.Root.Weld.Part0 = humanoidRootPart2
				clone.Parent = parent
				Ouwmit.Enable(clone, true, Ouwmit.Owned(parent, groundDust(humanoidRootPart2)))
				DebrisModule:AddItem(clone, 100)
			end
		elseif horseRunEffect then
			horseRunEffect.Name = "--"
			Ouwmit.Enable(horseRunEffect, false)
			DebrisModule:AddItem(horseRunEffect, 2.5)
		end
	end
end