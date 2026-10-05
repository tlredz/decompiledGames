local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local v = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.6,
	SustainTime = 0.1,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(1, 1, 1)
}
local v2 = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.3,
	SustainTime = 0.05,
	FadeOutTime = 0.4,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(1, 1, 1)
}
local v3 = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 1,
	SustainTime = 0.05,
	FadeOutTime = 0.8,
	RotationInfluence = createVector(0.35, 0.35, 0.35),
	PositionInfluence = createVector(1, 1, 1)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function groupName(value: string?)
	return (`HandDemonPursuit-{value or ""}`)
end

local function weldToRoot(childName: string, humanoidRootPart, folder)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return nil, nil
	end

	local clone = child:Clone()
	local primaryPart

	if clone:IsA("BasePart") then
		primaryPart = clone
	else
		primaryPart = clone.PrimaryPart or clone:FindFirstChild("Root")
	end

	if primaryPart == nil then
		return nil, nil
	end

	primaryPart.Anchored = false
	clone:PivotTo(humanoidRootPart.CFrame)
	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = primaryPart
	weld.Parent = primaryPart
	clone.Parent = folder
	return clone, primaryPart
end

local function stopGroup(value: string?)
	local child = workspace.Debree:FindFirstChild((`HandDemonPursuit-{value or ""}`))

	if child ~= nil then
		child.Name = "--"

		for _, child2 in child:GetChildren() do
			Ouwmit.Enable(child2, false)
		end

		local pS2handdemonSKILLSpursuitCHASE = child:FindFirstChild("PS2handdemonSKILLSpursuitCHASE", true)

		if pS2handdemonSKILLSpursuitCHASE ~= nil and pS2handdemonSKILLSpursuitCHASE:IsA("Sound") then
			pS2handdemonSKILLSpursuitCHASE:Stop()
		end

		DebrisModule:AddItem(child, 2.5)
	end
end

return function(instance, p: string?, value: string?)
	if p == "End" or p == "Cancel" then
		stopGroup(value)

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

	if p == "Start" then
		if workspace.Debree:FindFirstChild((`HandDemonPursuit-{value or ""}`)) ~= nil then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, v)
		local folder = Instance.new("Folder")
		folder.Name = `HandDemonPursuit-{value or ""}`
		folder.Parent = workspace.Debree
		DebrisModule:AddItem(folder, 6)
		vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSpursuitINIT", humanoidRootPart, true)
		local v4, v5 = weldToRoot("Constant", humanoidRootPart, folder)

		if v4 ~= nil then
			Ouwmit.Enable(v4, true, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
			vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSpursuitCHASE", v5)
		end

		local v6 = weldToRoot("Every", humanoidRootPart, folder)

		if v6 ~= nil then
			task.spawn(function()
				task.wait(0.5833333333333334)

				while folder.Parent ~= nil and folder.Name == `HandDemonPursuit-{value or ""}` and humanoidRootPart.Parent ~= nil do
					Ouwmit.Emit(v6, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
					Cam_Shaker(humanoidRootPart, v2)
					task.wait(0.5)
				end
			end)
		end
	elseif p == "End" then
		Cam_Shaker(humanoidRootPart.Position, v3)
		vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSpursuitEND", humanoidRootPart, true)
		local ending = script:FindFirstChild("Ending")

		if ending ~= nil then
			local clone = ending:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace.Debree
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
			DebrisModule:AddItem(clone, 4)
		end
	end
end