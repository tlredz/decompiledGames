local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local assets = script:WaitForChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local debree = workspace.Debree
local cframe = CFrame.new(0, 1, -3)
local cframe2 = CFrame.new(0, 2, 3)

-- equivalent calls inferred from this helper; original call sites unknown
local function chargeGroupName(name: string)
	return (`FireballCharge-{name}`)
end

local v = {
	FadeInTime = 0,
	Frequency = 0.18,
	Amplitude = 0.45,
	SustainTime = 0.1,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(1, 1, 1)
}
local v2 = {
	FadeInTime = 0,
	Frequency = 0.24,
	Amplitude = 0.7,
	SustainTime = 0.1,
	FadeOutTime = 0.6,
	RotationInfluence = createVector(0.3, 0.3, 0.3),
	PositionInfluence = createVector(1, 1, 1)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function groundCFrame(vector2: Vector3)
	local raycastResult = workspace:Raycast(
		vector2 + createVector(0, 4, 0),
		createVector(0, -14, 0),
		RaycastHelper.Crater
	)

	if raycastResult == nil then
		return nil, nil
	end

	return
		CFrame.new(raycastResult.Position + createVector(0, 0.5, 0)),
		vfxUtility.GetDustColorSettings(raycastResult.Instance)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createGroup(name: string, p: number)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = debree
	DebrisModule:AddItem(folder, p)
	return folder
end

local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function fadeLights(folder)
	for _, light in folder:GetDescendants() do
		if not (light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight")) then
			continue
		end

		TweenService:Create(light, tweenInfo, {
			Brightness = 0,
			Range = 0
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function burst(childName: string, cframe3: CFrame, p, debree2, instance)
	if assets:FindFirstChild(childName) == nil then
		return nil
	end

	local asset = vfxUtility.cloneAsset(assets, debree2 or debree, childName, cframe3, 5)
	Ouwmit.Emit(asset, Ouwmit.Owned(instance, p))
	return asset
end

local function soundAnchor(instance)
	if instance == nil then
		return nil
	end

	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") and instance.PrimaryPart ~= nil then
		return instance.PrimaryPart
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

return function(instance, p: string?, childName)
	if p == "Explode" then
		if typeof(childName) ~= "CFrame" or (childName.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		local position = childName.Position
		local raycastResult = workspace:Raycast(
			position + createVector(0, 4, 0),
			createVector(0, -14, 0),
			RaycastHelper.Crater
		)
		local cframe3, v3

		if raycastResult ~= nil then
			cframe3 = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))
			v3 = vfxUtility.GetDustColorSettings(raycastResult.Instance)
		end

		Cam_Shaker(childName.Position, v2)

		if cframe3 then
			OuwCraters.Scales({
				Center = cframe3,
				Count = 3,
				Radius = 4,
				ScaleMult = 1.2
			})
		end

		local primaryPart = burst("FireExplosion", cframe3 or childName, v3, workspace.Debree, instance) -- equivalent call inferred; original call site unknown
		local playSound = vfxUtility.PlaySound

		if primaryPart == nil then
			primaryPart = nil
		elseif not primaryPart:IsA("BasePart") then
			if primaryPart:IsA("Model") and primaryPart.PrimaryPart ~= nil then
				primaryPart = primaryPart.PrimaryPart
			else
				primaryPart = primaryPart:FindFirstChildWhichIsA("BasePart", true)
			end
		end

		playSound(sounds, "PS2flameprojectileIMP", primaryPart, true)
	else
		if instance == nil then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
			return
		end

		if p == "Charge" then
			Cam_Shaker(humanoidRootPart.Position, "activate_shake")
			vfxUtility.PlaySound(sounds, "PS2flameprojectileCHARGE", humanoidRootPart, true)
			local chargeEffects = assets:FindFirstChild("ChargeEffects")

			if chargeEffects == nil then
				return
			end

			local name = chargeGroupName(instance.Name) -- equivalent call inferred; original call site unknown
			local group = createGroup(name, 2.5) -- equivalent call inferred; original call site unknown
			local charge = chargeEffects:FindFirstChild("Charge")

			if charge then
				local head = instance:FindFirstChild("Head") or humanoidRootPart
				local clone = charge:Clone()
				clone:PivotTo(head.CFrame * cframe)
				clone.Parent = group

				if clone:IsA("BasePart") then
					vfxUtility.WeldConstraint(head, clone)
				else
					for _, part in clone:GetDescendants() do
						if part:IsA("BasePart") then
							vfxUtility.WeldConstraint(head, part)
						end
					end
				end

				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			end

			local ground = chargeEffects:FindFirstChild("Ground")

			if ground then
				local position = humanoidRootPart.Position
				local raycastResult = workspace:Raycast(
					position + createVector(0, 4, 0),
					createVector(0, -14, 0),
					RaycastHelper.Crater
				)
				local cframe3, v4

				if raycastResult ~= nil then
					cframe3 = CFrame.new(raycastResult.Position + createVector(0, 0.5, 0))
					v4 = vfxUtility.GetDustColorSettings(raycastResult.Instance)
				end

				local clone = ground:Clone()
				clone:PivotTo(cframe3 or CFrame.new(humanoidRootPart.Position - createVector(0, 3, 0)))
				clone.Parent = group
				Ouwmit.Emit(clone, Ouwmit.Owned(instance, v4))
			end
		elseif p == "Fire" then
			local v3 = groundDust(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
			local child = debree:FindFirstChild((`FireballCharge-{instance.Name}`))

			if child then
				child.Name = "--"
				vfxUtility.EnableAll(child, false)
				DebrisModule:AddItem(child, 1.5)
			end

			local group = createGroup(`FireballFire-{instance.Name}-{math.random(1, 9999)}`, 8) -- equivalent call inferred; original call site unknown
			Cam_Shaker(humanoidRootPart.Position, v)
			vfxUtility.PlaySound(sounds, "PS2flameprojectileSHOOT", humanoidRootPart, true)
			local v4 = (instance:FindFirstChild("Head") or humanoidRootPart).CFrame * cframe

			if assets:FindFirstChild("Release") ~= nil then
				local asset = vfxUtility.cloneAsset(assets, group or debree, "Release", v4, 5)
				Ouwmit.Emit(asset, Ouwmit.Owned(instance, v3))
			end

			local eff = assets:FindFirstChild("Eff")

			if eff then
				local clone = eff:Clone()
				clone:PivotTo(humanoidRootPart.CFrame * cframe2)
				clone.Parent = group
				Ouwmit.Emit(clone, Ouwmit.Owned(instance, v3))
				DebrisModule:AddItem(clone, 5)
			end

			if not childName then
				return
			end

			local part = (debree:FindFirstChild("Projectiles") or debree):WaitForChild(childName, 1)

			if not (part and part:IsA("BasePart")) then
				return
			end

			local fireProjectile = assets:FindFirstChild("FireProjectile")

			if fireProjectile == nil then
				return
			end

			local clone = fireProjectile:Clone()
			clone.Parent = group
			clone:PivotTo(part.CFrame)
			DebrisModule:AddItem(clone, 8)
			local primaryPart = clone.PrimaryPart

			if primaryPart == nil and clone:IsA("BasePart") then
				primaryPart = clone
			end

			if primaryPart == nil then
				for _, part2 in clone:GetDescendants() do
					if not part2:IsA("BasePart") then
						continue
					end

					primaryPart = part2
					break
				end
			end

			if primaryPart then
				primaryPart.Anchored = false
				primaryPart.CFrame = part.CFrame * CFrame.new(0, part.Size.Y / 4, 0)
				vfxUtility.WeldConstraint(part, primaryPart)
			end

			Ouwmit.Enable(clone, true, Ouwmit.Owned(instance, v3))
			part.Destroying:Once(function()
				if clone.Parent ~= nil then
					Ouwmit.Enable(clone, false)
					fadeLights(clone)
					DebrisModule:AddItem(clone, 1.5)
				end
			end)
		end
	end
end