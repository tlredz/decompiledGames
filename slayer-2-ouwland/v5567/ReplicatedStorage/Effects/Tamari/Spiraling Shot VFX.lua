local createVector = vector.create
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local TokenKit = require(CAM.Client.Modules.Effects.Token.TokenKit)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
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

local function destroyFolder(instance)
	local formatted = `{instance.Name}-SpiralingShotVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		child:SetAttribute("Cancelled", true)
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local holdBall = humanoidRootPart and humanoidRootPart:FindFirstChild("HoldBall")

	if holdBall then
		holdBall:Destroy()
	end
end

local function folderAlive(instance)
	return instance.Parent ~= nil and not instance:GetAttribute("Cancelled")
end

local function createFolder(p)
	destroyFolder(p)
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-SpiralingShotVFX`
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

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-SpiralingShotVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local projectiles = workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree

local function stopBallVFX(folder)
	local activeBall = folder:GetAttribute("ActiveBall")
	folder:SetAttribute("ActiveBall", nil)

	if activeBall == nil then
		return
	end

	local child = projectiles:FindFirstChild(activeBall)

	if child == nil then
		return
	end

	local ball = child:FindFirstChild("Ball")

	if ball then
		vfxUtility.EnableAll(ball, false)
	end
end

local function shake(vector2: Vector3, amplitude: number, value: number?)
	Cam_Shaker(vector2, {
		FadeInTime = 0,
		Frequency = 0.1,
		Amplitude = amplitude,
		SustainTime = value or 0.3,
		FadeOutTime = 0.2,
		RotationInfluence = createVector(1, 1, 1) * (amplitude >= 0.3 and 0.35 or 0.25),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	})
end

return function(instance, p: string, value, part)
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
		configuration.Name = `{instance.Name}-SpiralingShotVFX`
		configuration.Parent = workspace.Debree
		bumpFolderLifetime(configuration, 0)
		task.wait(0)
		local v

		if configuration.Parent == nil then
			v = false
		else
			v = not configuration:GetAttribute("Cancelled")
		end

		if not v then
			return
		end

		local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		local asset = vfxUtility.cloneAsset(assets, configuration, "balllspawnnspin", cFrame2, 3)

		if asset then
			bumpFolderLifetime(configuration, 3)
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		Ouwmit.Emit(
			asset.SummonPurp,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
		)
		vfxUtility.PlaySound(script.Sounds, "PS2tamariSPIRALINGSHOTinitcombined", asset, true)
		local clone = assets.Ball:Clone()
		clone.CFrame = cFrame2
		clone.Parent = humanoidRootPart
		clone.Name = "HoldBall"
		DebrisModule:AddItem(clone, 4)
		vfxUtility.WeldConstraint(humanoidRootPart, clone)
		task.delay(0.5, function()
			vfxUtility.EnableAll(clone.enablefirst, true, vfxUtility.Owned(instance))
		end)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.05,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(0.6666666666666666)
		local v4

		if configuration.Parent == nil then
			v4 = false
		else
			v4 = not configuration:GetAttribute("Cancelled")
		end

		if not v4 then
			return
		end

		local raycastResult2 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		vfxUtility.EmitAll(
			asset.wind,
			vfxUtility.Owned(instance, raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance))
		)
		local v6 = humanoidRootPart.CFrame * CFrame.new(0, -2.5, -2)
		local asset2 = vfxUtility.cloneAsset(assets, configuration, "ViolentBurst", v6, 1)

		if asset2 then
			bumpFolderLifetime(configuration, 1)
		end

		local raycastResult3 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		vfxUtility.EmitAll(
			asset2,
			vfxUtility.Owned(instance, raycastResult3 and vfxUtility.GetDustColorSettings(raycastResult3.Instance))
		)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local raycastResult4 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 3, 0),
			createVector(0, -15, 0),
			RaycastHelper.Crater
		)
		local instance2

		if not (raycastResult4 == nil or raycastResult4.Instance == nil) then
			instance2 = raycastResult4.Instance
		end

		local v7 = instance2 and instance2:IsA("BasePart") and vfxUtility.GetDustColorSettings(instance2) or nil
		local asset3 = vfxUtility.cloneAsset(assets, configuration, "Startup", nil, 5)

		if asset3 then
			bumpFolderLifetime(configuration, 5)
		end

		asset3:PivotTo(humanoidRootPart.CFrame)

		if v7 then
		end

		Ouwmit.Emit(asset3, Ouwmit.Owned(instance, v7))
		task.wait(0.9166666666666666)
		local v9

		if configuration.Parent == nil then
			v9 = false
		else
			v9 = not configuration:GetAttribute("Cancelled")
		end

		if not v9 then
			return
		end

		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		task.wait(0.08333333333333333)
		local v10

		if configuration.Parent == nil then
			v10 = false
		else
			v10 = not configuration:GetAttribute("Cancelled")
		end

		if not v10 then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local raycastResult5 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 3, 0),
			createVector(0, -15, 0),
			RaycastHelper.Crater
		)
		local instance3

		if not (raycastResult5 == nil or raycastResult5.Instance == nil) then
			instance3 = raycastResult5.Instance
		end

		local v11 = instance3 and instance3:IsA("BasePart") and vfxUtility.GetDustColorSettings(instance3) or nil
		local asset4 = vfxUtility.cloneAsset(assets, configuration, "betterkick", nil, 5)

		if asset4 then
			bumpFolderLifetime(configuration, 5)
		end

		asset4:PivotTo(humanoidRootPart.CFrame)

		if v11 then
			Ouwmit.Emit(asset4, Ouwmit.Owned(instance, v11))
		else
			Ouwmit.Emit(asset4.HeavySlashFX, Ouwmit.Owned(instance, v11))
		end

		local cFrame = humanoidRootPart.CFrame
		local asset5 = vfxUtility.cloneAsset(assets, configuration, "ThrowBall", cFrame, 3)

		if asset5 then
			bumpFolderLifetime(configuration, 3)
		end

		local raycastResult6 = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		Ouwmit.Emit(
			asset5,
			Ouwmit.Owned(instance, raycastResult6 and vfxUtility.GetDustColorSettings(raycastResult6.Instance))
		)
	elseif p == "Projectile" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local holdBall = humanoidRootPart:FindFirstChild("HoldBall")

		if holdBall then
			holdBall:Destroy()
		end

		local v = value or ""
		folder:SetAttribute("ActiveBall", v)

		if typeof(part) ~= "Instance" then
			part = nil
		end

		if not (part and part:IsA("BasePart")) then
			part = projectiles:WaitForChild(v, 1)
		end

		if part == nil or not part:IsA("BasePart") then
			return
		end

		local clone = assets.Ball:Clone()

		for _, part2 in ipairs({ clone, table.unpack(clone:GetDescendants()) }) do
			if not part2:IsA("BasePart") then
				continue
			end

			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.Massless = true
		end

		clone.CFrame = part.CFrame
		clone.Parent = part
		vfxUtility.WeldConstraint(part, clone)
		vfxUtility.PlaySound(script.Sounds, "PS2tamariSPIRALINGSHOTkick", clone, true)
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		local clone2 = script.Sounds.PS2tamariSPIRALINGSHOTtravelloop:Clone()
		clone2.Parent = part
		clone2:Play()
		task.spawn(function()
			local v2 = {
				CF = part.CFrame,
				InnerRadius = 3,
				OuterRadius = 7,
				Velocity = {
					Min = 4,
					Max = 10
				},
				Size = {
					Min = 0.5,
					Max = 2
				},
				Lifetime = 0.3
			}

			while folder:GetAttribute("ActiveBall") == v and part.Parent do
				v2.CF = part.CFrame
				task.spawn(TokenKit.GroundRocks, v2)
				task.wait(0.1)
			end

			clone2:Stop()
			clone2:Destroy()
		end)
	elseif p == "BallFXStop" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder then
			stopBallVFX(folder)
		end
	elseif p == "Arc" then
		local part2 = projectiles:FindFirstChild(value or "")
		local part3 = Instance.new("Part")
		part3.Name = "SpiralingShotArcSound"
		part3.Size = createVector(0.1, 0.1, 0.1)
		part3.Transparency = 1
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CanTouch = false
		part3.Massless = true
		part3.Anchored = false

		if part2 and part2:IsA("BasePart") then
			part3.CFrame = part2.CFrame
			part3.Parent = workspace.Debree
			vfxUtility.WeldConstraint(part2, part3)
			part2.Destroying:Once(function()
				if part3.Parent then
					part3.Anchored = true
				end
			end)
		else
			part3.Anchored = true
			part3.CFrame = humanoidRootPart.CFrame
			part3.Parent = workspace.Debree
		end

		local v = vfxUtility.PlaySound(script.Sounds, "PS2tamariSPIRALINGSHOTexploFIXED", part3, true)
		DebrisModule:AddItem(part3, (v and v.TimeLength or 3) + 0.2)
	elseif p == "Hit" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local v = value or instance:GetPivot()
		local v3 = v * CFrame.Angles(-1.5707963267948966, -1.5707963267948966, 0)
		local asset = vfxUtility.cloneAsset(assets, folder, "kick", v3, 3)

		if asset then
			bumpFolderLifetime(folder, 3)
		end

		local raycastResult = workspace:Raycast(
			v.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		vfxUtility.EmitAll(
			asset,
			vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
		)
	elseif p == "Explode" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		local v = value or instance:GetPivot()
		local position = v.Position
		local asset = vfxUtility.cloneAsset(assets, folder, "lastexplo", v, 3)

		if asset then
			bumpFolderLifetime(folder, 3)
		end

		local raycastResult = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		vfxUtility.EmitAll(
			asset,
			vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
		)
		vfxUtility.EnableAll(folder, false)
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

		local colorCorrectionEffect = Lighting:FindFirstChildWhichIsA("ColorCorrectionEffect")

		if colorCorrectionEffect then
			local enabled = colorCorrectionEffect.Enabled
			colorCorrectionEffect.Enabled = not enabled
			task.delay(0.03333333333333333, function()
				colorCorrectionEffect.Enabled = enabled
			end)
		end

		Cam_Shaker(position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.4,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end