local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local v = {
	FadeInTime = 0,
	Frequency = 0.22,
	Amplitude = 1.2,
	SustainTime = 0.05,
	FadeOutTime = 0.8,
	RotationInfluence = createVector(0.35, 0.35, 0.35),
	PositionInfluence = createVector(1, 1, 1)
}

local function burst(childName: string, cframe: CFrame, p, p2, instance)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	local clone = child:Clone()
	clone:PivotTo(cframe)
	clone.Parent = p2 or workspace.Debree
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, p))
	DebrisModule:AddItem(clone, 4)
	return clone
end

local function soundPart(instance)
	if instance == nil then
		return nil
	end

	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	end

	return instance:FindFirstChildWhichIsA("BasePart")
end

local function rockName(value: string?)
	return (`HandDemonRock-{value or ""}`)
end

local function rideProjectile(child, value: string?, p, folder, instance)
	local rockType = script:FindFirstChild("RockType")

	if rockType == nil then
		return
	end

	local v2 = os.clock() + 1

	while child == nil and os.clock() < v2 do
		local debree = workspace:FindFirstChild("Debree")
		local projectiles = debree and (debree:FindFirstChild("Projectiles") or debree)
		child = projectiles and projectiles:FindFirstChild((`{value} Boulder`))

		if child == nil then
			task.wait()
		end
	end

	if child == nil or child.Parent == nil then
		return
	end

	local clone = rockType:Clone()
	local primaryPart

	if clone:IsA("BasePart") then
		primaryPart = clone
	else
		primaryPart = clone.PrimaryPart or clone:FindFirstChild("Root")
	end

	if primaryPart == nil then
		return
	end

	primaryPart.Anchored = false
	clone:PivotTo(child.CFrame)
	local weld = Instance.new("Weld")
	weld.Part0 = child
	weld.Part1 = primaryPart
	weld.Parent = primaryPart
	clone.Name = `HandDemonRock-{value or ""}`
	clone.Parent = folder or workspace.Debree
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, p))
	DebrisModule:AddItem(clone, 10)
end

return function(instance, p: string?, value: string?, cframe)
	if p == "Explode" then
		if typeof(cframe) ~= "CFrame" then
			return
		end

		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 3, 0),
			createVector(0, -60, 0),
			RaycastHelper.Crater
		)
		local v2

		if raycastResult ~= nil then
			cframe = CFrame.new(raycastResult.Position)
			v2 = vfxUtility.GetDustColorSettings(raycastResult.Instance)
			OuwCraters.Scales({
				Center = cframe,
				Count = 7,
				Radius = 10
			})
			OuwCraters.Scales({
				Center = cframe,
				Count = 9,
				ScaleMult = 1.5,
				Radius = 15
			})
		end

		Cam_Shaker(cframe.Position, v)
		local primaryPart = burst("EndExplosion", cframe, v2, nil, instance)

		if primaryPart == nil then
			primaryPart = nil
		elseif not primaryPart:IsA("BasePart") then
			if primaryPart:IsA("Model") then
				primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart")
			else
				primaryPart = primaryPart:FindFirstChildWhichIsA("BasePart")
			end
		end

		if primaryPart ~= nil then
			vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSboulderthrowEXPLODE", primaryPart, true)
		end

		local part = workspace.Debree:FindFirstChild(`HandDemonRock-{value or ""}`, true)

		if part ~= nil then
			local primaryPart2

			if part:IsA("BasePart") then
				primaryPart2 = part
			else
				primaryPart2 = part.PrimaryPart or part:FindFirstChild("Root")
			end

			if primaryPart2 ~= nil then
				primaryPart2.Anchored = true
				primaryPart2.Transparency = 1
			end

			local highlight = part:FindFirstChildOfClass("Highlight")

			if highlight ~= nil then
				highlight:Destroy()
			end

			part.Name = "--"
			Ouwmit.Enable(part, false)
			DebrisModule:AddItem(part, 2)
		end
	elseif p == "Cancel" then
		local humanoidRootPart = instance and (instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart)
		local pS2handdemonSKILLSboulderthrowGRAB = humanoidRootPart and humanoidRootPart:FindFirstChild("PS2handdemonSKILLSboulderthrowGRAB")

		if pS2handdemonSKILLSboulderthrowGRAB ~= nil and pS2handdemonSKILLSboulderthrowGRAB:IsA("Sound") then
			pS2handdemonSKILLSboulderthrowGRAB:Stop()
		end
	else
		if instance == nil then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Reach" then
			burst("GrabRock", humanoidRootPart.CFrame, groundDust(humanoidRootPart.Position), nil, instance)
			vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSboulderthrowGRAB", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.2,
				Amplitude = 0.6,
				SustainTime = 0.1,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
		elseif p == "Throw" then
			local v2 = groundDust(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.225,
				Amplitude = 0.6,
				SustainTime = 1,
				FadeOutTime = 0.5,
				RotationInfluence = createVector(0.5, 0.5, 0.5),
				PositionInfluence = createVector(1, 1, 1)
			})
			local folder = Instance.new("Folder")
			folder.Name = `HandDemonBoulderThrow-{value or ""}`
			folder.Parent = workspace.Debree
			DebrisModule:AddItem(folder, 12)
			burst("Throw", humanoidRootPart.CFrame, v2, folder, instance)
			vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSboulderthrowTHROW", humanoidRootPart, true)
			rideProjectile(cframe, value, v2, folder, instance)
		end
	end
end