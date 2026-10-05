local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

local function template(childName: string)
	local child = script:FindFirstChild(childName)

	if child == nil then
		warn((`[BreathingBoostVFX] missing template "{childName}" under {script:GetFullName()}`))
	end

	return child
end

local function loopName(p)
	return (`{p.Name}'s Breathing Boost`)
end

local function loopSoundName(p)
	return (`{p.Name}'s Breathing Boost Loop`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLoopSound(instance, humanoidRootPart)
	local child = humanoidRootPart:FindFirstChild((`{instance.Name}'s Breathing Boost Loop`))

	if child == nil then
		return
	end

	child:Destroy()
	vfxUtility.PlaySound(script, "PS2boostrunSTOP", humanoidRootPart, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function getLoop(instance, humanoidRootPart)
	local child = workspace.Debree:FindFirstChild((`{instance.Name}'s Breathing Boost`))

	if child ~= nil then
		return child
	end

	local loop = script:FindFirstChild("Loop")

	if loop == nil then
		warn((`[BreathingBoostVFX] missing template "Loop" under {script:GetFullName()}`))
	end

	if loop == nil then
		return nil
	end

	local clone = loop:Clone()
	local root = clone:FindFirstChild("Root")

	if root == nil then
		warn("[BreathingBoostVFX] Loop has no Root part to weld")
		clone:Destroy()
		return nil
	else
		clone.Name = `{instance.Name}'s Breathing Boost`
		clone:PivotTo(humanoidRootPart.CFrame)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = humanoidRootPart
		weldConstraint.Part1 = root
		weldConstraint.Parent = root
		clone.Parent = workspace.Debree
		return clone
	end
end

return function(instance, p: string)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Initiate" then
		local startup = script:FindFirstChild("Startup")

		if startup == nil then
			warn((`[BreathingBoostVFX] missing template "Startup" under {script:GetFullName()}`))
		end

		if startup == nil then
			return
		end

		local clone = startup:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = workspace.Debree
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
		DebrisModule:AddItem(clone, 3)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		vfxUtility.PlaySound(script, "PS2boostrunINIT", humanoidRootPart, true)
	elseif p == "Run" then
		Ouwmit.Enable(
			getLoop(instance, humanoidRootPart),
			true,
			Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position))
		)

		if humanoidRootPart:FindFirstChild((`{instance.Name}'s Breathing Boost Loop`)) == nil then
			local v = vfxUtility.PlaySound(script, "PS2boostrunLOOP", humanoidRootPart, false)

			if v ~= nil then
				v.Name = `{instance.Name}'s Breathing Boost Loop`
				v.Looped = true
			end
		end
	elseif p == "Stop" then
		Ouwmit.Enable(workspace.Debree:FindFirstChild((`{instance.Name}'s Breathing Boost`)), false)
		stopLoopSound(instance, humanoidRootPart) -- equivalent call inferred; original call site unknown
	elseif p == "End" then
		stopLoopSound(instance, humanoidRootPart) -- equivalent call inferred; original call site unknown
		local child = workspace.Debree:FindFirstChild((`{instance.Name}'s Breathing Boost`))

		if child == nil then
			return
		end

		Ouwmit.Enable(child, false)
		child.Name ..= " (ending)"
		DebrisModule:AddItem(child, 3)
	end
end