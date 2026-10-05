local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script:WaitForChild("Assets")
local DebrisModule = require(CAM.DebrisModule)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills["Flower Breathing"]["Peonies of Futility"].Config)
local v = {
	Startup = true,
	Jump = true,
	Impact = true
}
local v2 = {
	Startup = "activate_shake",
	Jump = "activate_shake",
	SlashProjEmit = {
		FadeInTime = 0,
		Frequency = 0.12,
		Amplitude = 1,
		SustainTime = 0.05,
		FadeOutTime = 0.2,
		RotationInfluence = createVector(0.1, 0.1, 0.1),
		PositionInfluence = createVector(0.5, 0.5, 0.5)
	},
	Impact = "activate_shake"
}
local v3 = {
	FadeInTime = 0,
	Frequency = 0.082,
	Amplitude = 0.12,
	SustainTime = Config.BARRAGE_DURATION,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.1, 0.1, 0.1),
	PositionInfluence = createVector(0.4, 0.4, 0.4)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-PeoniesOfFutilityVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-PeoniesOfFutilityVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 7.9)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return workspace.Debree:FindFirstChild((`{instance.Name}-PeoniesOfFutilityVFX`))
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

local function emitAt(instance, folder, childName: string, cframe: CFrame)
	local child = assets:FindFirstChild(childName)

	if child == nil then
		return
	end

	local clone = child:Clone()
	clone:PivotTo(cframe)
	clone.Parent = folder
	DebrisModule:AddItem(clone, 4)
	local v4

	if v[childName] then
		v4 = groundDust(cframe.Position)
	end

	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v4))
	local v5 = v2[childName]

	if v5 ~= nil then
		Cam_Shaker(cframe.Position, v5)
	end
end

return function(instance, p: string, cFrame, part)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		if p == "Slash" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-PeoniesOfFutilityVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 7.9)

			if typeof(cFrame) ~= "CFrame" then
				cFrame = humanoidRootPart.CFrame
			end

			emitAt(instance, configuration, "Startup", cFrame)
		else
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			if p == "Rise" then
				if typeof(cFrame) ~= "CFrame" then
					cFrame = humanoidRootPart.CFrame
				end

				emitAt(instance, folder, "Jump", cFrame)
			elseif p == "Throw" then
				emitAt(instance, folder, "SlashProjEmit", humanoidRootPart.CFrame)

				if typeof(part) ~= "Instance" and type(cFrame) == "string" then
					part = workspace.Debree.Projectiles:WaitForChild(cFrame, 0.2)
				end

				if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
					return
				end

				local clone = assets.SlashProj:Clone()
				local root = clone:FindFirstChild("Root")

				if root == nil then
					return
				end

				clone:PivotTo(part.CFrame)
				clone.Parent = part
				local weld = Instance.new("Weld")
				weld.Part0 = part
				weld.Part1 = root
				weld.Parent = part
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			elseif p == "Explode" then
				if typeof(cFrame) ~= "Vector3" then
					return
				end

				emitAt(instance, folder, "Impact", CFrame.new(cFrame))
				Cam_Shaker(cFrame, v3)
			end
		end
	end
end