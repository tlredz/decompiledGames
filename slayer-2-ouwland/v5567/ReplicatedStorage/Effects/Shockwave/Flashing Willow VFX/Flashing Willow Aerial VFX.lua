local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local flashingWillow = ReplicatedStorage.Skills.Shockwave["Flashing Willow"]
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local TokenKit = require(CAM.Client.Modules.Effects.Token.TokenKit)
local debree = workspace.Debree
local cframe = CFrame.new(0, 0, -2)
local v = CFrame.new(0.245, 0.394, -0.033) * CFrame.Angles(0, 1.5707963267948966, 0)
local v2 = {
	{
		Radius = 15,
		Count = 10,
		ScaleMult = 1,
		OffsetMargin = 6
	},
	{
		Radius = 20,
		Count = 9,
		ScaleMult = 1.05,
		OffsetMargin = 7
	}
}
local Config = require(flashingWillow.Config)
local v3 = math.max(
	2.2,
	Config.AERIAL_STARTUP_TIME + Config.AERIAL_LOOP_BEFORE_DROP + 0.1 + Config.AERIAL_RELEASE_RECOVERY + 0.4
)
local v4 = v3 + 0.3 + 2
local v5 = math.max(v4, Config.AERIAL_VFX_IMPACT_DELAY + v3 + 0.3 + 2)
local v6 = v3 + 2

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = debree:FindFirstChild((`{p.Name}-FlashingWillow`))

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-FlashingWillow`
	configuration.Parent = debree
	DebrisModule:AddItem(configuration, v5)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return (debree:FindFirstChild((`{instance.Name}-FlashingWillow`)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDustSettingsAtPosition(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)

	if raycastResult then
		return vfxUtility.GetDustColorSettings(raycastResult.Instance)
	end

	return nil
end

local function getOrCreateObjectValue(parent, name: string)
	local objectValue = parent:FindFirstChild(name)

	if objectValue and objectValue:IsA("ObjectValue") then
		return objectValue
	end

	local objectValue2 = Instance.new("ObjectValue")
	objectValue2.Name = name
	objectValue2.Parent = parent
	return objectValue2
end

return function(instance, p: string, p2, p3)
	if not instance then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if not humanoidRootPart or p ~= "Cancel" and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 250 then
		return
	end

	if p == "AerialStart" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-FlashingWillow`
		configuration.Parent = debree
		DebrisModule:AddItem(configuration, v5)
		configuration:SetAttribute("AerialActive", true)
		local dustSettingsAtPosition = getDustSettingsAtPosition(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
		local v7 = configuration:FindFirstChild("GrabEffect")

		if not (v7 and v7:IsA("ObjectValue")) then
			v7 = Instance.new("ObjectValue")
			v7.Name = "GrabEffect"
			v7.Parent = configuration
		end

		v7.Value = nil

		if configuration:GetAttribute("AerialActive") ~= true or configuration.Parent == nil then
			return
		end

		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		vfxUtility.PlaySound(script.Parent.Sounds, "PS2akazaSKILL4VAR2grab", humanoidRootPart, true)
		local asset = vfxUtility.cloneAsset(
			script.Parent.Assets,
			configuration,
			"Grab",
			humanoidRootPart.CFrame * cframe,
			v3
		)
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, dustSettingsAtPosition))
		v7.Value = asset
		task.wait(0.6666666666666666)

		if configuration:GetAttribute("AerialActive") ~= true or configuration.Parent == nil then
			return
		end

		local asset2 = vfxUtility.cloneAsset(
			script.Parent.Assets,
			configuration,
			"Last Spin",
			humanoidRootPart.CFrame * cframe,
			v3
		)
		vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance))
	elseif p == "AerialRelease" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		folder:SetAttribute("AerialActive", true)
		local v7 = folder:FindFirstChild("ReleaseEffect")

		if not (v7 and v7:IsA("ObjectValue")) then
			v7 = Instance.new("ObjectValue")
			v7.Name = "ReleaseEffect"
			v7.Parent = folder
		end

		if v7.Value then
			return
		end

		vfxUtility.PlaySound(script.Parent.Sounds, "PS2akazaSKILL4VAR2spindrop", humanoidRootPart, true)
		task.wait(0.5)

		if humanoidRootPart.Parent == nil then
			return
		end

		local cFrame = humanoidRootPart.CFrame

		if typeof(p2) == "CFrame" then
			cFrame = p2
		end

		local position = cFrame.Position

		if typeof(p3) == "Vector3" then
			position = p3
		elseif typeof(p3) == "CFrame" then
			position = p3.Position
		end

		local grabEffect = folder:FindFirstChild("GrabEffect")

		if grabEffect == nil then
			return
		end

		local value = grabEffect.Value
		local dustSettingsAtPosition = getDustSettingsAtPosition(cFrame.Position) -- equivalent call inferred; original call site unknown
		local asset = vfxUtility.cloneAsset(script.Parent.Assets, folder, "ReleaseVFX", cFrame * v, v3)
		vfxUtility.EnableAll(asset, true, vfxUtility.Owned(instance))
		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
		v7.Value = asset
		task.wait(0.31666666666666665)

		if folder:GetAttribute("AerialActive") ~= true or folder.Parent == nil then
			return
		end

		if value then
			vfxUtility.EmitAll(value, vfxUtility.Owned(instance, dustSettingsAtPosition))
		end

		task.wait(-0.13666666666666666)

		if folder:GetAttribute("AerialActive") ~= true or folder.Parent == nil then
			return
		end

		if asset:IsA("Model") and asset.PrimaryPart then
			TweenService:Create(asset.PrimaryPart, TweenInfo.new(0.2), {
				CFrame = CFrame.new(position)
			}):Play()
		end

		task.wait(0.2)

		if folder:GetAttribute("AerialActive") ~= true or folder.Parent == nil then
			return
		end

		vfxUtility.EnableAll(asset, false)
	elseif p == "AerialImpact" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if folder == nil then
			return
		end

		folder:SetAttribute("AerialActive", false)

		for _, child in folder:GetChildren() do
			child:Destroy()
		end

		local position = humanoidRootPart.Position

		if typeof(p2) == "CFrame" then
			position = p2.Position
		elseif typeof(p2) == "Vector3" then
			position = p2
		end

		local asset = vfxUtility.cloneAsset(script.Parent.Assets, folder, "Ending", CFrame.new(position), v6)
		vfxUtility.PlaySound(script.Parent.Sounds, "PS2akazaSKILL4VAR2slam", humanoidRootPart, true)
		local raycastResult = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(0, -20, 0),
			RaycastHelper.Crater
		)

		if raycastResult and (asset:IsA("Model") or asset:IsA("BasePart")) then
			asset:PivotTo(CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			) * CFrame.new(0, 0.025, 0))
		end

		local dustSettingsAtPosition = getDustSettingsAtPosition(position) -- equivalent call inferred; original call site unknown
		Ouwmit.Emit(asset, Ouwmit.Owned(instance, dustSettingsAtPosition))
		local pivot = asset:GetPivot()
		task.spawn(TokenKit.GroundRocks, {
			CF = pivot,
			InnerRadius = 10,
			OuterRadius = 30,
			Velocity = {
				Min = 10,
				Max = 50
			},
			Size = {
				Min = 1,
				Max = 3
			}
		})
		Cam_Shaker(pivot.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.4,
			SustainTime = 0.4,
			FadeOutTime = 0.6,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		for _, v7 in v2 do
			OuwCraters.Scales({
				Center = pivot,
				Radius = v7.Radius,
				Count = v7.Count,
				ScaleMult = v7.ScaleMult,
				OffsetMargin = v7.OffsetMargin
			})
			task.wait(0.15)
		end
	elseif p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	end
end