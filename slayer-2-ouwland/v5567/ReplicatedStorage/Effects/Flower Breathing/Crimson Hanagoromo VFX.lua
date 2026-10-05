local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local effects = script:WaitForChild("Effects")
local DebrisModule = require(CAM.DebrisModule)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills["Flower Breathing"]["Crimson Hanagoromo"].Config)
local v = {
	FadeInTime = 0,
	Frequency = 0.082,
	Amplitude = 0.12,
	SustainTime = Config.MAX_HOLD,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.1, 0.1, 0.1),
	PositionInfluence = createVector(0.4, 0.4, 0.4)
}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function endBarrage(p)
	local v3 = v2[p]

	if v3 == nil then
		return
	end

	v2[p] = nil

	if v3.barrage ~= nil and v3.barrage.Parent ~= nil then
		v3.barrage:Destroy()
	end

	if v3.shake ~= nil then
		v3.shake:StopSustain()
	end
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

local function destroyFolder(p)
	endBarrage(p) -- equivalent call inferred; original call site unknown
	local child = workspace.Debree:FindFirstChild((`{p.Name}-CrimsonHanagoromoVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-CrimsonHanagoromoVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 6)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return workspace.Debree:FindFirstChild((`{instance.Name}-CrimsonHanagoromoVFX`))
end

return function(instance, p: string, cFrame)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Start" then
		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-CrimsonHanagoromoVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 6)
		local v3 = {
			barrage = nil,
			shake = nil
		}
		v2[instance] = v3
		local clone = effects.Barrage:Clone()
		local root = clone:FindFirstChild("Root")

		if root ~= nil then
			clone:PivotTo(humanoidRootPart.CFrame)
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart
			weld.Part1 = root
			weld.Parent = clone
			clone.Parent = configuration
			DebrisModule:AddItem(clone, Config.MAX_HOLD)
			Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(humanoidRootPart.Position)))
			v3.barrage = clone
		end

		v3.shake = Cam_Shaker(humanoidRootPart, v)
	elseif p == "Final" then
		local parent = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not parent then
			destroyFolder(instance)
			parent = Instance.new("Configuration")
			parent.Name = `{instance.Name}-CrimsonHanagoromoVFX`
			parent.Parent = workspace.Debree
			DebrisModule:AddItem(parent, 6)
		end

		endBarrage(instance) -- equivalent call inferred; original call site unknown

		if typeof(cFrame) ~= "CFrame" then
			cFrame = humanoidRootPart.CFrame
		end

		local clone = effects.Impact:Clone()
		clone:PivotTo(cFrame)
		clone.Parent = parent
		DebrisModule:AddItem(clone, 4)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, groundDust(cFrame.Position)))
		Cam_Shaker(cFrame.Position, "activate_shake")
	end
end