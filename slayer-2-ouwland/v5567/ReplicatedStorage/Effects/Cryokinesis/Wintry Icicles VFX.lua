local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local cframe = CFrame.Angles(0, 0, -3.141592653589793)
local cframe2 = CFrame.Angles(-1.5707963267948966, 0, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local formatted = `{p.Name}-WintryIciclesVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child and child.Parent then
		vfxUtility.EnableAll(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-WintryIciclesVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 11)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(p)
	local formatted = `{p.Name}-WintryIciclesVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local function tweenToCFrame(asset, cframe3: CFrame, duration: number, p)
	local tweenInfo = TweenInfo.new(duration, p or Enum.EasingStyle.Linear)

	if asset:IsA("BasePart") then
		TweenService:Create(asset, tweenInfo, {
			CFrame = cframe3
		}):Play()
	elseif asset:IsA("Model") and asset.PrimaryPart then
		local objectSpace = asset:GetPivot():ToObjectSpace(asset.PrimaryPart.CFrame)
		TweenService:Create(asset.PrimaryPart, tweenInfo, {
			CFrame = cframe3 * objectSpace
		}):Play()
	end
end

local function setIcebergMaterial(asset)
	for _, v in asset:QueryDescendants("BasePart") do
		if v.Name == "Iceberg" then
			v.Material = Enum.Material.Ice
		end
	end
end

return function(p, p2: string, cframe3: CFrame?)
	if p == nil then
		return
	end

	if p2 == "Cancel" then
		destroyFolder(p) -- equivalent call inferred; original call site unknown
	else
		if not cframe3 then
			return
		end

		local v

		if p2 == "Start" then
			destroyFolder(p) -- equivalent call inferred; original call site unknown
			v = Instance.new("Configuration")
			v.Name = `{p.Name}-WintryIciclesVFX`
			v.Parent = workspace.Debree
			DebrisModule:AddItem(v, 11)
		else
			v = findFolder(p)
		end

		if v == nil then
			return
		end

		if p2 == "Start" then
			local asset = vfxUtility.cloneAsset(assets, v, "DetectorAura", cframe3 * CFrame.new(0, 0, -0.5), 6)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(p))
			asset.enableunder.enablethis.Size = NumberSequence.new(24)
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL1var2", asset, true)
			task.wait(0.2)

			if asset.Parent then
				vfxUtility.ToggleWithColor(asset, true, nil, nil, p)
			end

			task.wait(4.8)

			if asset.Parent then
				vfxUtility.ToggleWithColor(asset, false)
			end
		elseif p2 == "Drop" then
			local asset = vfxUtility.cloneAsset(assets, v, "Icicle", cframe3 * CFrame.new(0, 0, -60) * cframe, 0.35)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(p))
			tweenToCFrame(asset, cframe3 * cframe2, 0.3)
			local asset2 = vfxUtility.cloneAsset(assets, v, "icicleImpact", cframe3, 5)
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL1drop" .. math.random(1, 2), asset2, true)
			task.wait(0.3)

			if asset.Parent then
				vfxUtility.ToggleWithColor(asset, false)
			end

			Cam_Shaker(cframe3.Position, {
				FadeInTime = 0,
				Frequency = 0.125,
				Amplitude = 0.3,
				SustainTime = 0.1,
				FadeOutTime = 0.25,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(0.75, 0.75, 0.75)
			})
			vfxUtility.EmitAll(asset2, vfxUtility.Owned(p))
			local asset3 = vfxUtility.cloneAsset(assets, v, "IceImpact", cframe3 * CFrame.new(0, 0, -0.2), 10)
			vfxUtility.EmitAll(asset3, vfxUtility.Owned(p))
		elseif p2 == "Finish" then
			local asset = vfxUtility.cloneAsset(assets, v, "IceImpactup", cframe3, 4)
			vfxUtility.EmitAll(asset, vfxUtility.Owned(p))
			task.wait(0.1)
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL1explode1", asset, true)
			local v2 = cframe3 * CFrame.new(-2.662, 2.293, 0)
			local asset2 = vfxUtility.cloneAsset(assets, v, "Iceberg1", v2 * CFrame.new(0, 0, 23.003), 5)
			vfxUtility.EmitAll(asset2, vfxUtility.Owned(p))
			tweenToCFrame(asset2, asset2:GetPivot() * CFrame.new(0, 0, -23), 0.3, Enum.EasingStyle.Sine)
			Cam_Shaker(v2.Position, {
				FadeInTime = 0,
				Frequency = 0.135,
				Amplitude = 1,
				SustainTime = 0.1,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1.3, 1.3, 1.3)
			})
			task.wait(0.15)
			setIcebergMaterial(asset2)
			task.wait(0.05)
			local asset3 = vfxUtility.cloneAsset(assets, v, "Iceberg2", v2 * CFrame.new(0, 0, 28.215), 5)
			vfxUtility.EmitAll(asset3, vfxUtility.Owned(p))
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL1explode2", asset, true)
			tweenToCFrame(asset3, asset3:GetPivot() * CFrame.new(0, 0, -28.02), 0.3, Enum.EasingStyle.Sine)
			Cam_Shaker(v2.Position, {
				FadeInTime = 0,
				Frequency = 0.135,
				Amplitude = 2.5,
				SustainTime = 0.1,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1.3, 1.3, 1.3)
			})
			task.wait(0.65)
			local asset4 = vfxUtility.cloneAsset(assets, v, "IceImpactBig", cframe3 * CFrame.new(0, 0, -0.3), 8)
			Ouwmit.Emit(asset4, Ouwmit.Owned(p))
			vfxUtility.PlaySound(script.Sounds, "PS2cryokenesisSKILL1explode2", asset4, true)
			OuwCraters.Scales({
				Center = cframe3 * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 1, 0),
				Radius = 25,
				OffsetMargin = 10,
				ScaleMult = 1
			})
			Cam_Shaker(cframe3.Position, {
				FadeInTime = 0,
				Frequency = 0.135,
				Amplitude = 0.45,
				SustainTime = 0.1,
				FadeOutTime = 0.4,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1.3, 1.3, 1.3)
			})
			task.wait(0.15)

			if asset2.Parent then
				asset2:Destroy()
			end

			if asset3.Parent then
				asset3:Destroy()
			end
		end
	end
end