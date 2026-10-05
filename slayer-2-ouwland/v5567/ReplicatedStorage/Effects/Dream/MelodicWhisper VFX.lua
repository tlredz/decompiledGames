local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script.Sounds
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)

local function destroyFolder(instance)
	local formatted = `{instance.Name}-MelodicWhisperVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		child:SetAttribute("Cancelled", true)
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end

	local rightHand = instance:FindFirstChild("RightHand")
	local starImpact = rightHand and rightHand:FindFirstChild("StarImpact")

	if starImpact then
		starImpact:Destroy()
	end
end

local function folderAlive(instance)
	return instance.Parent ~= nil and not instance:GetAttribute("Cancelled")
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-MelodicWhisperVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 12)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-MelodicWhisperVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

return function(instance, p: string, p2, part)
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

	if p == "CloseHold" then
		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-MelodicWhisperVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 12)
		local asset = vfxUtility.cloneAsset(
			assets,
			instance:FindFirstChild("RightHand") or configuration,
			"StarImpact",
			nil,
			4
		)
		Ouwmit.Enable(asset, true, Ouwmit.Owned(instance))
		vfxUtility.PlaySound(sounds, "PS2dreamMELODICWHISPERshortCHARGE", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
	elseif p == "Close" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not folder then
			destroyFolder(instance)
			folder = Instance.new("Configuration")
			folder.Name = `{instance.Name}-MelodicWhisperVFX`
			folder.Parent = workspace.Debree
			DebrisModule:AddItem(folder, 12)
		end

		local rightHand = instance:FindFirstChild("RightHand")
		local starImpact = rightHand and rightHand:FindFirstChild("StarImpact")

		if starImpact ~= nil then
			starImpact.Name = "--"
		end

		task.wait(0.3333333333333333)
		local v2

		if folder.Parent == nil then
			v2 = false
		else
			v2 = not folder:GetAttribute("Cancelled")
		end

		if not v2 then
			return
		end

		if starImpact then
			Ouwmit.Enable(starImpact, false)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local asset = vfxUtility.cloneAsset(assets, folder, "CloseImpact", humanoidRootPart.CFrame, 5)
		Ouwmit.Emit(
			asset,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		vfxUtility.PlaySound(sounds, "PS2dreamMELODICWHISPERshortSHOOT", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.4,
			SustainTime = 0.2,
			FadeOutTime = 0.25,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
	elseif p == "CloseHit" then
		if findFolder(instance) == nil then
			return
		end

		if p2 then
			local clone = assets.Highlight:Clone()
			clone.Parent = p2.Parent
			TweenService:Create(clone, TweenInfo.new(0.3), {
				FillTransparency = 1
			}):Play()
			DebrisModule:AddItem(clone, 1)
		end
	elseif p == "Far" then
		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-MelodicWhisperVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 12)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			local asset = vfxUtility.cloneAsset(
				assets,
				configuration,
				"Jump",
				CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				),
				5
			)
			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
			)
		end

		vfxUtility.PlaySound(sounds, "PS2dreamMELODICWHISPERlongJUMP", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.175,
			Amplitude = 0.35,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
	elseif p == "FarOrb" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local asset = vfxUtility.cloneAsset(assets, folder, "Kick", humanoidRootPart.CFrame, 2)
		Ouwmit.Emit(asset, Ouwmit.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.25,
			SustainTime = 0.08,
			FadeOutTime = 0.15,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})

		if not p2 then
			return
		end

		if typeof(part) ~= "Instance" then
			part = nil
		end

		if not (part and part:IsA("BasePart")) then
			part = (workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree):WaitForChild(p2, 0.5)
		end

		if not (part and part:IsA("BasePart")) then
			return
		end

		local clone = assets.Orb:Clone()
		clone.CFrame = part.CFrame
		clone.Parent = part
		vfxUtility.WeldConstraint(part, clone)
		Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
		local v = math.random(1, 2)
		vfxUtility.PlaySound(sounds, `PS2dreamMELODICWHISPERlongSHOOT{v}`, part, true)
	elseif p == "FarImpact" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local cframe = CFrame.new(p2, p2 + (part or createVector(0, 1, 0)))
		local raycastResult = workspace:Raycast(
			p2 + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		local asset = vfxUtility.cloneAsset(assets, folder, "DreamHit", cframe, 5)
		Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
		local part2 = Instance.new("Part")
		part2.Size = createVector(0.1, 0.1, 0.1)
		part2.Transparency = 1
		part2.Anchored = true
		part2.CanCollide = false
		part2.CFrame = CFrame.new(p2)
		part2.Parent = folder
		local v2 = vfxUtility.PlaySound(sounds, "PS2dreamMELODICWHISPERlongEXPL", part2, true)

		if v2 then
			DebrisModule:AddItem(part2, v2.TimeLength + 0.2)
		end

		Cam_Shaker(p2, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.5,
			SustainTime = 0.15,
			FadeOutTime = 0.3,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
	end
end