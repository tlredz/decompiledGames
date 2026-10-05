local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local v = {
	FadeInTime = 0,
	Frequency = 0.1,
	Amplitude = 0.65,
	SustainTime = 0.2,
	FadeOutTime = 0.2,
	RotationInfluence = createVector(0.2, 0.2, 0.2),
	PositionInfluence = createVector(2.5, 2.5, 2.5)
}

local function destroyFolder(p)
	local formatted = `{p.Name}-FleshMonsterVFX`
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
	configuration.Name = `{p.Name}-FleshMonsterVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 22)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-FleshMonsterVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local function makeKinematic(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setDriven(instance, anchored: boolean)
	local primaryPart = instance.PrimaryPart

	if primaryPart == nil then
		return
	end

	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	primaryPart.Anchored = anchored
end

local function playMonsterAnim(instance, p: string, priority)
	local monster = instance:FindFirstChild("Monster")

	if not monster then
		return nil
	end

	local animator = monster:FindFirstChildWhichIsA("Animator", true)

	if not animator then
		return nil
	end

	local track = animator:LoadAnimation(assets[p])

	if priority then
		track.Priority = priority
	end

	track:Play()
	DebrisModule:AddItem(track, 22)
	return track
end

return function(instance, p: string, cframe: CFrame?)
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

	if p == "Spawn" then
		destroyFolder(instance)
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-FleshMonsterVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 22)
		vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERspawn", humanoidRootPart, true)
		local cFrame = cframe or humanoidRootPart.CFrame
		local asset = vfxUtility.cloneAsset(assets, configuration, "Monster", cFrame * CFrame.new(0, -100, 0), 22)

		if asset == nil then
			return
		end

		makeKinematic(asset)
		setDriven(asset, true) -- equivalent call inferred; original call site unknown
		playMonsterAnim(configuration, "FleshMonsterStartup", Enum.AnimationPriority.Movement)
		TweenService:Create(asset.PrimaryPart, TweenInfo.new(0.5), {
			CFrame = cFrame
		}):Play()
		task.wait(0.16666666666666666)
		local v3

		if configuration.Parent == nil then
			v3 = false
		else
			v3 = not configuration:GetAttribute("Cancelled")
		end

		if not v3 then
			return
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local asset2 = vfxUtility.cloneAsset(assets, configuration, "StartupFX", humanoidRootPart.CFrame, 8)
		Ouwmit.Emit(
			asset2,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)
		Cam_Shaker(humanoidRootPart.Position, v)
		task.wait(0.3333333333333333)
		local v4

		if configuration.Parent == nil then
			v4 = false
		else
			v4 = not configuration:GetAttribute("Cancelled")
		end

		if not v4 or asset.Parent == nil then
			return
		end

		setDriven(asset, false) -- equivalent call inferred; original call site unknown
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = asset.PrimaryPart
		weld.Parent = asset.PrimaryPart
		task.wait(0.16666666666666666)
		local v5

		if configuration.Parent == nil then
			v5 = false
		else
			v5 = not configuration:GetAttribute("Cancelled")
		end

		if not v5 then
			return
		end

		local raycastResult2 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local asset3 = vfxUtility.cloneAsset(assets, configuration, "Up", humanoidRootPart.CFrame, 8)
		Ouwmit.Emit(
			asset3,
			Ouwmit.Owned(instance, raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil)
		)
		Cam_Shaker(humanoidRootPart.Position, v)
		task.wait(1)
		local v6

		if configuration.Parent == nil then
			v6 = false
		else
			v6 = not configuration:GetAttribute("Cancelled")
		end

		if not v6 then
			return
		end

		local raycastResult3 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -15, -0),
			RaycastHelper.Crater
		)
		local asset4 = vfxUtility.cloneAsset(assets, configuration, "Miasma", humanoidRootPart.CFrame, 20)
		Ouwmit.Emit(
			asset4,
			Ouwmit.Owned(instance, raycastResult3 and vfxUtility.GetDustColorSettings(raycastResult3.Instance) or nil)
		)
		Cam_Shaker(humanoidRootPart.Position, v)
		task.wait(0.7633333333333333)
		local v7

		if configuration.Parent == nil then
			v7 = false
		else
			v7 = not configuration:GetAttribute("Cancelled")
		end

		if not v7 then
			return
		end

		playMonsterAnim(configuration, "FleshMonsterIdle", Enum.AnimationPriority.Movement)
	else
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		if p == "Hit1" then
			playMonsterAnim(folder, "FleshMonsterFirstHit", Enum.AnimationPriority.Action)
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERswing1", humanoidRootPart, true)
			task.wait(0.62)
			local v2

			if folder.Parent == nil then
				v2 = false
			else
				v2 = not folder:GetAttribute("Cancelled")
			end

			if not v2 then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local asset = vfxUtility.cloneAsset(assets, folder, "Hit1", humanoidRootPart.CFrame, 8)
			Ouwmit.Emit(
				asset,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERslam1", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, v)
		elseif p == "Hit2" then
			playMonsterAnim(folder, "FleshMonsterSecondHit", Enum.AnimationPriority.Action2)
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERswing2", humanoidRootPart, true)
			task.wait(0.5700000000000001)
			local v2

			if folder.Parent == nil then
				v2 = false
			else
				v2 = not folder:GetAttribute("Cancelled")
			end

			if not v2 then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local asset = vfxUtility.cloneAsset(assets, folder, "Hit2", humanoidRootPart.CFrame, 8)
			Ouwmit.Emit(
				asset,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERslam2", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, v)
		elseif p == "Hit3" then
			playMonsterAnim(folder, "FleshMonsterLastHit", Enum.AnimationPriority.Action3)
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERswing3", humanoidRootPart, true)
			task.wait(0.8200000000000001)
			local v2

			if folder.Parent == nil then
				v2 = false
			else
				v2 = not folder:GetAttribute("Cancelled")
			end

			if not v2 then
				return
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -15, -0),
				RaycastHelper.Crater
			)
			local asset = vfxUtility.cloneAsset(assets, folder, "Hit3", humanoidRootPart.CFrame, 8)
			Ouwmit.Emit(
				asset,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERslam3", humanoidRootPart, true)
			Cam_Shaker(humanoidRootPart.Position, v)
			task.wait(0.5)
			local v3

			if folder.Parent == nil then
				v3 = false
			else
				v3 = not folder:GetAttribute("Cancelled")
			end

			if not v3 then
				return
			end

			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Size = 5
			blurEffect.Parent = Lighting
			DebrisModule:AddItem(blurEffect, 0.3)
			local colorCorrection = Lighting:FindFirstChild("ColorCorrection")

			if colorCorrection then
				colorCorrection.Enabled = false
				local clone = assets.ColorCorrection1:Clone()
				clone.Enabled = true
				clone.Parent = Lighting
				task.wait(0.03333333333333333)
				clone:Destroy()
				local clone2 = assets.ColorCorrection2:Clone()
				clone2.Enabled = true
				clone2.Parent = Lighting
				task.wait(0.03333333333333333)
				clone2:Destroy()
				colorCorrection.Enabled = true
			end

			Cam_Shaker(humanoidRootPart.Position, v)
		elseif p == "Exit" then
			vfxUtility.PlaySound(script.Sounds, "PS2dreamFLESHMONSTERdespawn", humanoidRootPart, true)
			local monster = folder:FindFirstChild("Monster")

			if monster and monster:IsA("Model") and monster.PrimaryPart then
				local weld = monster.PrimaryPart:FindFirstChildWhichIsA("Weld")

				if weld then
					weld:Destroy()
				end

				setDriven(monster, true) -- equivalent call inferred; original call site unknown
				TweenService:Create(monster.PrimaryPart, TweenInfo.new(1), {
					CFrame = monster.PrimaryPart.CFrame * CFrame.new(0, -100, 0)
				}):Play()
				DebrisModule:AddItem(monster, 3)
			end
		end
	end
end