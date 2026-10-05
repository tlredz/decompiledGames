local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local sounds = script.Sounds
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)

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

local function addAsset(p, p2, p3: string, cframe: CFrame?, p4: number?)
	local asset = vfxUtility.cloneAsset(p2, p, p3, cframe, p4)

	if asset and p4 then
		bumpFolderLifetime(p, p4)
	end

	return asset
end

local function destroyFolder(p)
	local formatted = `{p.Name}-PiercingFleshVFX`
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
	configuration.Name = `{p.Name}-PiercingFleshVFX`
	configuration.Parent = workspace.Debree
	bumpFolderLifetime(configuration, 6)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-PiercingFleshVFX`
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
		configuration.Name = `{instance.Name}-PiercingFleshVFX`
		configuration.Parent = workspace.Debree
		bumpFolderLifetime(configuration, 6)
		local pivot = instance:GetPivot()
		local raycastResult = workspace:Raycast(
			pivot.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local asset = vfxUtility.cloneAsset(assets, configuration, "Startup", pivot, 4)

		if asset then
			bumpFolderLifetime(configuration, 4)
		end

		vfxUtility.EmitAll(
			asset,
			vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		vfxUtility.PlaySound(sounds, "PS2dreamPIERCINGFLESHinit", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.15,
			SustainTime = 0.2,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.2, 0.2, 0.2),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
	elseif p == "Miss" then
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
		local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -2)).Position
		local raycastResult2 = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)

		if raycastResult2 then
			local v3 = CFrame.new(raycastResult2.Position, raycastResult2.Position - raycastResult2.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			local asset = vfxUtility.cloneAsset(assets, folder, "HandGroundImpact", v3, 4)

			if asset then
				bumpFolderLifetime(folder, 4)
			end

			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance))
			)
		end

		local asset = vfxUtility.cloneAsset(assets, folder, "Tentacle", p2, 4)

		if asset then
			bumpFolderLifetime(folder, 4)
		end

		asset.MainAura.Jsdelete:Destroy()
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, v))
		vfxUtility.PlaySound(sounds, "PS2dreamPIERCINGFLESHsummon", asset.PrimaryPart, true)
		task.wait(0.2)
		local v3

		if folder.Parent == nil then
			v3 = false
		else
			v3 = not folder:GetAttribute("Cancelled")
		end

		if not v3 then
			return
		end

		Cam_Shaker(asset.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(0.05)
		local v4

		if folder.Parent == nil then
			v4 = false
		else
			v4 = not folder:GetAttribute("Cancelled")
		end

		if not v4 then
			return
		end

		asset:FindFirstChildWhichIsA("Animator", true):LoadAnimation(assets.PiercingFleshTentacleMiss):Play()
		task.wait(0.1)
		local v5

		if folder.Parent == nil then
			v5 = false
		else
			v5 = not folder:GetAttribute("Cancelled")
		end

		if not v5 then
			return
		end

		for _, v6 in asset:QueryDescendants("[$HideOnSpawn]") do
			v6.Transparency = 0
		end

		task.wait(0.5)
		local v6

		if folder.Parent == nil then
			v6 = false
		else
			v6 = not folder:GetAttribute("Cancelled")
		end

		if not v6 then
			return
		end

		vfxUtility.PlaySound(sounds, "PS2dreamPIERCINGFLESHdesummon", asset.PrimaryPart, true)
		task.wait(0.67)
		local v7

		if folder.Parent == nil then
			v7 = false
		else
			v7 = not folder:GetAttribute("Cancelled")
		end

		if not v7 then
			return
		end

		for _, v8 in asset:QueryDescendants("[$HideOnSpawn]") do
			v8:Destroy()
		end
	elseif p == "Hit" then
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
		local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -2)).Position
		local raycastResult2 = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)

		if raycastResult2 then
			local v3 = CFrame.new(raycastResult2.Position, raycastResult2.Position - raycastResult2.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			local asset = vfxUtility.cloneAsset(assets, folder, "HandGroundImpact", v3, 4)

			if asset then
				bumpFolderLifetime(folder, 4)
			end

			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance))
			)
		end

		local asset = vfxUtility.cloneAsset(assets, folder, "Tentacle", p2, 6)

		if asset then
			bumpFolderLifetime(folder, 6)
		end

		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, v))
		task.wait(0.25)
		local v3

		if folder.Parent == nil then
			v3 = false
		else
			v3 = not folder:GetAttribute("Cancelled")
		end

		if not v3 then
			return
		end

		Cam_Shaker(asset.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		asset:FindFirstChildWhichIsA("Animator", true):LoadAnimation(assets.PiercingFleshTentacleHit):Play()
		vfxUtility.PlaySound(sounds, "PS2dreamPIERCINGFLESHgrabcombo", asset.PrimaryPart, true)
		task.wait(0.1)
		local v4

		if folder.Parent == nil then
			v4 = false
		else
			v4 = not folder:GetAttribute("Cancelled")
		end

		if not v4 then
			return
		end

		for _, v5 in asset:QueryDescendants("[$HideOnSpawn]") do
			v5.Transparency = 0
		end

		task.wait(0.9833333333333333)
		local v5

		if folder.Parent == nil then
			v5 = false
		else
			v5 = not folder:GetAttribute("Cancelled")
		end

		if not v5 then
			return
		end

		local cFrame = asset.PrimaryPart.CFrame
		local asset2 = vfxUtility.cloneAsset(assets, folder, "Explosion", cFrame, 4)

		if asset2 then
			bumpFolderLifetime(folder, 4)
		end

		vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance, v))
		local position2 = (asset.PrimaryPart.CFrame * CFrame.new(0, 0, -4)).Position
		local raycastResult3 = workspace:Raycast(
			position2 + createVector(0, 5, 0),
			createVector(-0, -25, -0),
			RaycastHelper.Crater
		)

		if raycastResult3 then
			OuwCraters.Scales({
				Center = CFrame.new(raycastResult3.Position),
				Radius = 7,
				Count = 7,
				ScaleMult = 0.6
			})
		end

		Cam_Shaker(asset.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(0.16666666666666666)
		local v7

		if folder.Parent == nil then
			v7 = false
		else
			v7 = not folder:GetAttribute("Cancelled")
		end

		if not v7 then
			return
		end

		local handDemon004 = asset:FindFirstChild("Hand Demon.004", true)
		local v8 = v and ({
			Color = v.Color,
			ColorWhitelist = "Debris",
			ColorBlacklist = v.ColorBlacklist
		} or nil) or nil
		local clones = {}

		if handDemon004 ~= nil then
			for _, child in assets:GetChildren() do
				if child.Name ~= "Debris" then
					continue
				end

				local clone = child:Clone()
				clone.Parent = handDemon004
				vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance, v8))
				table.insert(clones, clone)
			end
		end

		task.wait(0.8166666666666667)
		local v9

		if folder.Parent == nil then
			v9 = false
		else
			v9 = not folder:GetAttribute("Cancelled")
		end

		if not v9 then
			return
		end

		Cam_Shaker(asset.PrimaryPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local cFrame2 = asset.PrimaryPart.CFrame
		local asset3 = vfxUtility.cloneAsset(assets, folder, "Throw", cFrame2, 4)

		if asset3 then
			bumpFolderLifetime(folder, 4)
		end

		vfxUtility.EmitAll(asset3, vfxUtility.Owned(instance, v))
		vfxUtility.PlaySound(sounds, "PS2dreamPIERCINGFLESHslam", asset.PrimaryPart, true)
		task.wait(0.016666666666666666)
		local v11

		if folder.Parent == nil then
			v11 = false
		else
			v11 = not folder:GetAttribute("Cancelled")
		end

		if not v11 then
			return
		end

		for _, v12 in clones do
			vfxUtility.EnableAll(v12, false)
		end

		task.wait(0.9166666666666666)
		local v12

		if folder.Parent == nil then
			v12 = false
		else
			v12 = not folder:GetAttribute("Cancelled")
		end

		if not v12 then
			return
		end

		for _, v13 in asset:QueryDescendants("[$HideOnSpawn]") do
			v13:Destroy()
		end
	end
end