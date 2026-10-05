local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local script2 = script
local sounds = script:WaitForChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local BeastAura = require(script.Parent.BeastAura)
local v = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.075,
	SustainTime = 0.5,
	FadeOutTime = 0.2,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(1, 1, 1)
}
local v2 = {
	FadeInTime = 0,
	Frequency = 0.1,
	Amplitude = 0.5,
	SustainTime = 0.1,
	FadeOutTime = 0.3,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(3.5, 3.5, 3.5)
}
local v3 = {
	FadeInTime = 0.05,
	Frequency = 0.18,
	Amplitude = 0.6,
	SustainTime = 0.14,
	FadeOutTime = 0.7,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(3.5, 3.5, 3.5)
}
local v4 = {
	FadeInTime = 0.03,
	Frequency = 0.18,
	Amplitude = 0.1,
	SustainTime = 0.1,
	FadeOutTime = 0.3,
	RotationInfluence = createVector(0.3, 0.3, 0.3),
	PositionInfluence = createVector(3.5, 3.5, 3.5)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-PalisadeBiteVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-PalisadeBiteVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 9.3)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return workspace.Debree:FindFirstChild((`{instance.Name}-PalisadeBiteVFX`))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local v5 = {
	Teleport = "PS2beastPELISADEBITEteleport",
	Barrage = "PS2beastPELISADEBITEbarrage",
	Slash = "PS2beastPELISADEBITEfinalslash"
}

local function emit(instance, folder, p: string, cframe: CFrame)
	local asset = vfxUtility.cloneAsset(script2, folder, p, cframe, 4)

	if asset == nil then
		return
	end

	Ouwmit.Emit(asset, Ouwmit.Owned(instance, groundDust(cframe.Position)))
	local v6 = v5[p]
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if v6 ~= nil and humanoidRootPart ~= nil then
		vfxUtility.PlaySound(sounds, v6, humanoidRootPart, true)
	end
end

return function(instance, p: string, p2, p3)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	elseif p == "Start" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-PalisadeBiteVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 9.3)
		BeastAura(instance)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			Cam_Shaker(humanoidRootPart.Position, v)
		end
	else
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		if p == "Teleport" then
			if typeof(p2) ~= "CFrame" or typeof(p3) ~= "CFrame" then
				return
			end

			emit(instance, folder, "Teleport", p2)
			task.wait()

			if folder.Parent == nil or folder.Name == "--" then
				return
			end

			emit(instance, folder, "Impale", p3)
			Cam_Shaker(p3.Position, v2)
		elseif p == "Barrage" then
			if typeof(p2) ~= "CFrame" then
				return
			end

			emit(instance, folder, "Barrage", p2)
		elseif p == "Wave" then
			if typeof(p2) ~= "CFrame" then
				return
			end

			Cam_Shaker(p2.Position, v4)
		elseif p == "Slash" then
			if typeof(p2) ~= "CFrame" then
				return
			end

			emit(instance, folder, "Slash", p2)
			Cam_Shaker(p2.Position, v4)
			Cam_Shaker(p2.Position, v3)
		end
	end
end