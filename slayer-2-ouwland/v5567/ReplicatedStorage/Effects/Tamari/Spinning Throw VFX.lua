local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local assets = script.Assets

local function bumpFolderLifetime(instance, p: number)
	local v = os.clock() + p + 0.4
	local lifetimeDeadline = instance:GetAttribute("LifetimeDeadline")

	if lifetimeDeadline and v <= lifetimeDeadline then
		return
	end

	instance:SetAttribute("LifetimeDeadline", v)

	if instance:GetAttribute("LifetimeScheduled") then
		return
	end

	instance:SetAttribute("LifetimeScheduled", true)
	task.spawn(function()
		while true do
			local lifetimeDeadline2 = instance.Parent and instance:GetAttribute("LifetimeDeadline")

			if not lifetimeDeadline2 then
				break
			end

			local v2 = lifetimeDeadline2 - os.clock()

			if v2 <= 0 then
				break
			else
				task.wait(v2)
			end
		end

		if instance.Parent then
			instance:Destroy()
		end
	end)
end

local function destroyFolder(folder)
	local formatted = `{folder.Name}-SpinningThrowVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		local ball = child:FindFirstChild("Ball")

		if ball then
			ball:Destroy()
		end

		child.Name = "--"
	end

	for _, sound in folder:GetDescendants() do
		if not (sound:IsA("Sound") and string.find(sound.Name, "PS2tamariSPINNINGTHROW", 1, true)) then
			continue
		end

		sound:Stop()
		sound:Destroy()
	end
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-SpinningThrowVFX`
	configuration.Parent = workspace.Debree
	bumpFolderLifetime(configuration, 0)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-SpinningThrowVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shotFolderName(p, p2: number)
	return (`{p.Name}-SpinningThrowVFX-shootno{p2}`)
end

local function findShotFolder(p, p2: number)
	return (workspace.Debree:FindFirstChild((`{p.Name}-SpinningThrowVFX-shootno{p2}`)))
end

local function createShotFolder(instance, p: number)
	local name = shotFolderName(instance, p) -- equivalent call inferred; original call site unknown
	local child = workspace.Debree:FindFirstChild(name)

	if child then
		child:Destroy()
	end

	local configuration = Instance.new("Configuration")
	configuration.Name = name
	configuration.Parent = workspace.Debree
	bumpFolderLifetime(configuration, 0)
	return configuration
end

local function addAsset(p, p2, p3: string, cframe: CFrame?, p4: number?)
	local asset = vfxUtility.cloneAsset(p2, p, p3, cframe, p4)

	if asset and p4 then
		bumpFolderLifetime(p, p4)
	end

	return asset
end

return function(instance, p: string, value, vector2, part, value2, value3)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	local function spawnHandBall(instance2, childName: string, flag: boolean?)
		local child = instance:FindFirstChild(childName, true)

		if child == nil then
			return
		end

		local ball = instance2:FindFirstChild("Ball")

		if ball then
			ball:Destroy()
		end

		local clone = assets.Part.HandAttach:Clone()
		clone.Parent = child
		DebrisModule:AddItem(clone, 2)
		local asset = vfxUtility.cloneAsset(assets, instance2, "Ball", nil, 2)

		if asset then
			bumpFolderLifetime(instance2, 2)
		end

		if asset == nil then
			return
		end

		if flag then
			vfxUtility.PlaySound(script.Sounds, "PS2tamariSUMMON", asset, true)
		end

		asset.rigid.RigidConstraint.Attachment0 = clone
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		vfxUtility.EmitAll(
			asset,
			vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
		)
	end

	if p == "Start" then
		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-SpinningThrowVFX`
		configuration.Parent = workspace.Debree
		bumpFolderLifetime(configuration, 0)
		spawnHandBall(configuration, value or "LeftHand", true)
	elseif p == "DashStart" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local cFrame = humanoidRootPart.CFrame
		local asset = vfxUtility.cloneAsset(assets, folder, "DashStart", cFrame, 3)

		if asset then
			bumpFolderLifetime(folder, 3)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		vfxUtility.EmitAll(
			asset,
			vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
		)
		vfxUtility.PlaySound(script.Sounds, "PS2tamariSPINNINGTHROWvar1throw", humanoidRootPart, true)
	elseif p == "HandBall" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		spawnHandBall(folder, value or "LeftHand", part)
	elseif p == "Projectile" then
		if not value then
			return
		end

		local v

		if typeof(value2) == "number" then
			v = value2
		end

		local v2

		if v then
			v2 = createShotFolder(instance, v)
		else
			v2 = findFolder(instance)
		end

		if v2 == nil then
			return
		end

		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown
		local ball = folder and folder:FindFirstChild("Ball")

		if ball then
			ball:Destroy()
		end

		if value3 then
			vfxUtility.PlaySound(script.Sounds, "PS2tamariSPINNINGTHROWvar1throw2", humanoidRootPart, true)
		elseif value2 == 1 then
			vfxUtility.PlaySound(script.Sounds, "PS2tamariSPINNINGTHROWvar2shoot", humanoidRootPart, true)
		end

		if typeof(part) ~= "Instance" then
			part = nil
		end

		if not (part and part:IsA("BasePart")) then
			part = (workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree):WaitForChild(value, 2)
		end

		if not (part and part:IsA("BasePart")) then
			return
		end

		local cframe

		if vector2 then
			cframe = CFrame.lookAlong(humanoidRootPart.Position, vector2)
		else
			cframe = humanoidRootPart.CFrame
		end

		local v4 = cframe * CFrame.new(0, -0.275, -5.659) * CFrame.Angles(0, 1.5707963267948966, 0)
		local asset = vfxUtility.cloneAsset(assets, v2, "Shoot", v4, 3)

		if asset then
			bumpFolderLifetime(v2, 3)
		end

		if asset then
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
			)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.1,
			FadeOutTime = 0.1,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local clone = assets.Ball:Clone()
		clone.CFrame = part.CFrame
		clone.Parent = part
		vfxUtility.WeldConstraint(part, clone)
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
	elseif p == "Impact" then
		if typeof(value3) ~= "number" then
			value3 = nil
		end

		local child

		if value3 then
			child = workspace.Debree:FindFirstChild((`{instance.Name}-SpinningThrowVFX-shootno{value3}`))
		end

		if child == nil then
			if value3 then
				child = createShotFolder(instance, value3)
			else
				child = findFolder(instance)
			end
		end

		if child == nil then
			return
		end

		local cframe

		if vector2 then
			cframe = CFrame.new(value, value - vector2) * CFrame.Angles(1.5707963267948966, 0, 0)
		else
			local raycastResult = workspace:Raycast(
				value + createVector(0, 2, 0),
				createVector(-0, -8, -0),
				RaycastHelper.Crater
			)

			if raycastResult then
				cframe = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			else
				cframe = CFrame.new(value)
			end
		end

		local v = part == "Final" or part == "NonVariant"
		local raycastResult

		if value2 and vector2 and vector2:Dot(createVector(0, 1, 0)) < 0.85 then
			raycastResult = workspace:Raycast(value - value2 * 2, value2 * 6, RaycastHelper.Crater)
		else
			raycastResult = workspace:Raycast(
				value + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
		end

		local asset = vfxUtility.cloneAsset(assets, child, v and "Impact2" or "Impact1", cframe, 5)

		if asset then
			bumpFolderLifetime(child, 5)
		end

		if asset then
			vfxUtility.PlaySound(script.Sounds, "PS2tamariSPINNINGTHROWexplo", asset, true)
			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
			)
		end

		if part ~= "Shot" then
			OuwCraters.Scales({
				Center = asset,
				Radius = 6,
				Count = 15,
				ScaleMult = 0.7,
				OffsetMargin = 3
			})
		end

		Cam_Shaker(value, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end