local createVector = vector.create
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local TokenKit = require(CAM.Client.Modules.Effects.Token.TokenKit)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local assets = script.Assets

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local formatted = `{p.Name}-DunkVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

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

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-DunkVFX`
	configuration.Parent = workspace.Debree
	bumpFolderLifetime(configuration, 0)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	local formatted = `{instance.Name}-DunkVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local function addAsset(p, p2, p3: string, cframe: CFrame?, p4: number?)
	local asset = vfxUtility.cloneAsset(p2, p, p3, cframe, p4)

	if asset and p4 then
		bumpFolderLifetime(p, p4)
	end

	return asset
end

return function(instance, p: string, position2, part, childName)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Start" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-DunkVFX`
			configuration.Parent = workspace.Debree
			bumpFolderLifetime(configuration, 0)
			local clone = assets.Part.SummonPurp:Clone()
			clone.Parent = humanoidRootPart
			DebrisModule:AddItem(clone, 10)
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			vfxUtility.EmitAll(
				clone,
				vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
			)
			local rightHand = instance:FindFirstChild("RightHand", true)

			if rightHand == nil then
				return
			end

			local clone2 = assets.Part.HandAttach:Clone()
			clone2.Parent = rightHand
			DebrisModule:AddItem(clone2, 10)
			local assets2 = script.Parent["Spinning Throw VFX"].Assets
			local asset = vfxUtility.cloneAsset(assets2, configuration, "Ball", nil, 6)

			if asset then
				bumpFolderLifetime(configuration, 6)
			end

			asset.rigid.RigidConstraint.Attachment0 = clone2
			local raycastResult2 = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance))
			)
			vfxUtility.PlaySound(script.Parent["Spinning Throw VFX"].Sounds, "PS2tamariSUMMON", humanoidRootPart, true)
		elseif p == "Updraft" then
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			local summonPurp = humanoidRootPart:FindFirstChild("SummonPurp")

			if summonPurp then
				vfxUtility.EnableAll(summonPurp, false)
				DebrisModule:AddItem(summonPurp, 2)
			end

			local asset = vfxUtility.cloneAsset(assets, folder, "JumpEff", nil, 5)

			if asset then
				bumpFolderLifetime(folder, 5)
			end

			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)

			if raycastResult then
				asset:PivotTo(CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				))
				vfxUtility.EmitAll(
					asset,
					vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
				)
			else
				asset:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3.14, 0))
				vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
			end

			vfxUtility.PlaySound(script.Sounds, "PS2tamariDUNKjump", humanoidRootPart, true)
		elseif p == "Slam" then
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			local ball = folder:FindFirstChild("Ball")

			if ball then
				ball:Destroy()
			end

			vfxUtility.PlaySound(script.Sounds, "PS2tamariDUNKthrow", humanoidRootPart, true)

			if typeof(part) ~= "Instance" then
				part = nil
			end

			if not (part and part:IsA("BasePart")) and childName then
				part = (workspace.Debree:FindFirstChild("Projectiles") or workspace.Debree):WaitForChild(childName, 2)
			end

			local v = humanoidRootPart.CFrame * CFrame.new(0.302, -1.158, -4.283)
			local assets2 = script.Parent["Spinning Throw VFX"].Assets
			local asset = vfxUtility.cloneAsset(assets2, folder, "Ball", v, 3)

			if asset then
				bumpFolderLifetime(folder, 3)
			end

			if part and part:IsA("BasePart") then
				asset.Anchored = false
				asset.CFrame = part.CFrame
				vfxUtility.WeldConstraint(part, asset)
			else
				asset.Anchored = true
				local v2 = (position2 - v.Position).Magnitude / 120
				TweenService:Create(asset, TweenInfo.new(v2), {
					Position = position2
				}):Play()
				task.delay(v2 + 0.2, function()
					vfxUtility.EnableAll(asset, false)
				end)
			end

			if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
				local vector2 = Vector3.new(position2.X, humanoidRootPart.Position.Y, position2.Z)
				local cframe

				if (vector2 - humanoidRootPart.Position).Magnitude > 0.01 then
					cframe = CFrame.lookAt(humanoidRootPart.Position, vector2)
				else
					cframe = humanoidRootPart.CFrame
				end

				local asset2 = vfxUtility.cloneAsset(assets, folder, "Throw", nil, 5)

				if asset2 then
					bumpFolderLifetime(folder, 5)
				end

				asset2:PivotTo(cframe)
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)
				Ouwmit.Emit(
					asset2,
					Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
				)
			end

			task.wait(0.15)
		elseif p == "Impact" then
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			local raycastResult = workspace:Raycast(
				position2 + createVector(0, 5, 0),
				createVector(-0, -20, -0),
				RaycastHelper.Crater
			)
			local position

			if raycastResult then
				position = raycastResult.Position or position2
			else
				position = position2
			end

			local v = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal or createVector(0, 1, 0)
			local cframe = CFrame.new(position, position + v)
			local ball = folder:FindFirstChild("Ball")

			if ball and ball:IsA("BasePart") then
				if ball.Parent ~= folder then
					ball.Parent = folder
				end

				ball.Name = "--"
				ball.Anchored = true
				ball.CFrame = CFrame.new(position)
				DebrisModule:AddItem(ball, 1)
			end

			local asset = vfxUtility.cloneAsset(assets, folder, "Final", cframe, 6)

			if asset then
				bumpFolderLifetime(folder, 6)
			end

			vfxUtility.EmitAll(
				asset,
				vfxUtility.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance))
			)
			vfxUtility.PlaySound(script.Sounds, "PS2tamariDUNKexplosion1", asset, true)
			task.spawn(TokenKit.GroundRocks, {
				CF = cframe,
				InnerRadius = 5,
				OuterRadius = 10,
				Velocity = {
					Min = 5,
					Max = 20
				},
				Amount = 20,
				Size = {
					Min = 0.5,
					Max = 2
				}
			})
			OuwCraters.Scales({
				Center = asset,
				Radius = 10,
				Count = 15,
				ScaleMult = 0.8,
				OffsetMargin = 4
			})
			Cam_Shaker(position2, {
				FadeInTime = 0,
				Frequency = 0.3,
				Amplitude = 0.3,
				SustainTime = 0.2,
				FadeOutTime = 0.1,
				RotationInfluence = createVector(0.3, 0.3, 0.3),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
			task.wait(1)

			if not findFolder(instance) then
				return
			end

			vfxUtility.PlaySound(script.Sounds, "PS2tamariDUNKexplosion2", asset, true)
			local clone = assets.ColorCorrection1:Clone()
			clone.Parent = Lighting
			task.wait(0.03333333333333333)
			clone:Destroy()
			local clone2 = assets.ColorCorrection2:Clone()
			clone2.Parent = Lighting
			task.wait(0.03333333333333333)
			clone2:Destroy()
			task.spawn(TokenKit.GroundRocks, {
				CF = cframe,
				InnerRadius = 5,
				OuterRadius = 20,
				Velocity = {
					Min = 5,
					Max = 30
				},
				Amount = 20,
				Size = {
					Min = 0.5,
					Max = 2
				}
			})
			OuwCraters.Scales({
				Center = asset,
				Radius = 10,
				Count = 15,
				ScaleMult = 1,
				OffsetMargin = 4
			})
			OuwCraters.Scales({
				Center = asset,
				Radius = 19,
				Count = 15,
				ScaleMult = 0.9,
				OffsetMargin = 4
			})
			Cam_Shaker(position2, {
				FadeInTime = 0,
				Frequency = 0.3,
				Amplitude = 0.3,
				SustainTime = 0.2,
				FadeOutTime = 0.1,
				RotationInfluence = createVector(0.2, 0.2, 0.2),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end
	end
end