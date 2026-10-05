local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script.Sounds
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)

local function destroyFolder(p)
	local formatted = `{p.Name}-FleshBarrageVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		child:SetAttribute("Cancelled", true)
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function folderAlive(instance)
	return instance.Parent ~= nil and not instance:GetAttribute("Cancelled")
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-FleshBarrageVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 7)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-FleshBarrageVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

return function(instance, p: string, p2)
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

	if p == "Startup" then
		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-FleshBarrageVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 7)
		local asset = vfxUtility.cloneAsset(assets, configuration, "Startup", humanoidRootPart.CFrame, 4)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, v))
		local auraCharge = asset:FindFirstChild("AuraCharge")

		if auraCharge then
			vfxUtility.WeldConstraint(humanoidRootPart, auraCharge)
		end

		vfxUtility.PlaySound(sounds, "PS2dreamFLESHBARRAGEinit", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	elseif p == "Tentacle" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local raycastResult = workspace:Raycast(
			p2.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil

		if folder:FindFirstChild("BarrageSoundAnchor") == nil then
			local part = Instance.new("Part")
			part.Name = "BarrageSoundAnchor"
			part.Size = createVector(0.1, 0.1, 0.1)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(p2.Position)
			part.Parent = folder
			vfxUtility.PlaySound(sounds, "PS2dreamFLESHBARRAGEbarrage", part, true)
		end

		local asset = vfxUtility.cloneAsset(assets, folder, "Tentacle", p2, 4)

		if asset == nil then
			return
		end

		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, v))
		local animator = asset:FindFirstChildWhichIsA("Animator", true)

		if animator == nil then
			return
		end

		local track = animator:LoadAnimation(assets.FleshBarrageTentacle)
		track:Play()
		track:AdjustSpeed(0)
		task.wait(0.3)
		local v2

		if folder.Parent == nil then
			v2 = false
		else
			v2 = not folder:GetAttribute("Cancelled")
		end

		if not v2 then
			return
		end

		track:AdjustSpeed(1)

		for _, v3 in asset:QueryDescendants("[$HideOnSpawn]") do
			v3.Transparency = 0
		end

		task.wait(0.1)
		local v3

		if folder.Parent == nil then
			v3 = false
		else
			v3 = not folder:GetAttribute("Cancelled")
		end

		if not v3 or asset.Parent == nil then
			return
		end

		local raycastResult2 = workspace:Raycast(
			p2.Position + p2.LookVector * 5,
			-p2.LookVector * 10,
			RaycastHelper.Crater
		)
		local attachment21 = raycastResult2 and asset:FindFirstChild("Attachment21", true)

		if attachment21 then
			local asset2 = vfxUtility.cloneAsset(
				assets,
				folder,
				"Hit",
				CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				),
				3
			)
			vfxUtility.EmitAll(
				asset2,
				vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance))
			)
			Cam_Shaker(attachment21.WorldCFrame.Position, {
				FadeInTime = 0.05,
				Frequency = 0.25,
				Amplitude = 0.2,
				SustainTime = 0.1,
				FadeOutTime = 0.3,
				RotationInfluence = createVector(0.5, 0.5, 0.5),
				PositionInfluence = createVector(1.5, 1.5, 1.5)
			})
		end

		task.wait(0.5)
		local v4

		if folder.Parent == nil then
			v4 = false
		else
			v4 = not folder:GetAttribute("Cancelled")
		end

		if not v4 or asset.Parent == nil then
			return
		end

		asset.Rig:Destroy()
	end
end