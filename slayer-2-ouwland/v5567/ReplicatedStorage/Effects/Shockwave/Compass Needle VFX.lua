local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local CraterExtension = require(CAM.Client.Modules.Effects.Craters.CraterExtension)
local debree = workspace.Debree
local v = CFrame.new(1.25, -2.83, -0.984) * CFrame.Angles(-3.141592653589793, 1.566, -3.141592653589793)
local cframe = CFrame.new(0, -1.5, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-CompassNeedle`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-CompassNeedle`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, 10)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(parent)
	return (debree:FindFirstChild((`{parent.Name}-CompassNeedle`)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shake(position: Vector3, amplitude: number)
	Cam_Shaker(position, {
		FadeInTime = 0,
		Frequency = 0.1,
		Amplitude = amplitude,
		SustainTime = 0.3,
		FadeOutTime = 0.2,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(0, 0, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getFlatCFrame(humanoidRootPart)
	local position = humanoidRootPart.Position
	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude <= 0.001 then
		return CFrame.new(position)
	end

	return CFrame.lookAt(position, position + vector2, createVector(0, 1, 0))
end

return function(parent, p: string, _)
	if not parent then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart") or parent.PrimaryPart

	if not humanoidRootPart or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "Start" then
		destroyFolder(parent) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{parent.Name}-CompassNeedle`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, 10)
		local configuration2 = Instance.new("Configuration")
		configuration2.Name = "StartState"
		configuration2.Parent = configuration
		DebrisModule:AddItem(configuration2, 8)
		local rightFoot = parent:FindFirstChild("RightFoot")

		if rightFoot then
			CraterExtension.Ground(rightFoot.Position, 15, createVector(0.3, 0.5, 0.5), nil, 3, false, 0.5)
		end

		vfxUtility.PlaySound(script.Sounds, "PS2shockwaveCOMPASSNEEDLE", humanoidRootPart, true)
		local flatCFrame = getFlatCFrame(humanoidRootPart) -- equivalent call inferred; original call site unknown
		local asset = vfxUtility.cloneAsset(script.Assets, configuration2, "CompassNeedle", flatCFrame * v, 8)

		if asset then
			vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
		end

		vfxUtility.PlaySound(script.Sounds, "CompassNeedleStart", humanoidRootPart, true)
		shake(humanoidRootPart.Position, 0.1) -- equivalent call inferred; original call site unknown
		task.wait(0.5)

		if configuration2.Parent == nil then
			return
		end

		shake(humanoidRootPart.Position, 0.08) -- equivalent call inferred; original call site unknown
		task.wait(0.9166666666666666)

		if configuration2.Parent == nil then
			return
		end

		shake(humanoidRootPart.Position, 0.08) -- equivalent call inferred; original call site unknown
	elseif p == "Counter" then
		local parent2 = findFolder(parent) -- equivalent call inferred; original call site unknown

		if not parent2 then
			destroyFolder(parent) -- equivalent call inferred; original call site unknown
			parent2 = Instance.new("Configuration")
			parent2.Name = `{parent.Name}-CompassNeedle`
			parent2.Parent = debree
			DebrisModule:AddItem(parent2, 10)
		end

		local configuration = Instance.new("Configuration")
		configuration.Name = "CounterState"
		configuration.Parent = parent2
		DebrisModule:AddItem(configuration, 4)
		local iceHighlight = script.Assets.Attachments:FindFirstChild("IceHighlight")
		local clone = iceHighlight and iceHighlight:Clone()

		if clone and clone:IsA("Highlight") then
			clone.Parent = parent
			TweenService:Create(clone, TweenInfo.new(0.1), {
				FillTransparency = 0.1
			}):Play()
			DebrisModule:AddItem(clone, 0.15)
		end

		local flatCFrame = getFlatCFrame(humanoidRootPart) -- equivalent call inferred; original call site unknown
		local asset = vfxUtility.cloneAsset(script.Assets, configuration, "Intensitylines", flatCFrame * cframe, 0.1)

		if asset then
			vfxUtility.EmitAll(asset, vfxUtility.Owned(parent))
		end

		local asset2 = vfxUtility.cloneAsset(
			script.Assets,
			configuration,
			"JumpEff",
			flatCFrame * CFrame.new(0, -2.5, 0),
			4
		)

		if asset2 then
			vfxUtility.EmitAll(asset2, vfxUtility.Owned(parent))
		end

		vfxUtility.PlaySound(script.Sounds, "CompassNeedleCounter", humanoidRootPart, true)
		shake(flatCFrame.Position, 0.1) -- equivalent call inferred; original call site unknown
		vfxUtility.PlaySound(script.Sounds, "PS2shockwaveCOMPASSNEEDLEkickup", humanoidRootPart, true)
		task.wait(0.1)

		if configuration.Parent == nil then
			return
		end

		local asset3 = vfxUtility.cloneAsset(script.Assets, configuration, "Vanish", flatCFrame * cframe, 1)

		if asset3 then
			vfxUtility.EmitAll(asset3, vfxUtility.Owned(parent))
		end

		local asset4 = vfxUtility.cloneAsset(script.Assets, configuration, "Intensitylines", flatCFrame * cframe, 0.1)

		if asset4 then
			vfxUtility.EmitAll(asset4, vfxUtility.Owned(parent))
		end

		task.wait(0.1)

		if configuration.Parent == nil then
			return
		end

		local asset5 = vfxUtility.cloneAsset(script.Assets, configuration, "Vanish", flatCFrame * cframe, 1)

		if asset5 then
			vfxUtility.EmitAll(asset5, vfxUtility.Owned(parent))
		end
	elseif p == "Cancel" then
		destroyFolder(parent) -- equivalent call inferred; original call site unknown
	end
end