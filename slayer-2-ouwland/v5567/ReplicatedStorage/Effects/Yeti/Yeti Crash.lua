local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local assets = script.Assets
local debree = workspace.Debree
local sounds = script:FindFirstChild("Sounds")

-- equivalent calls inferred from this helper; original call sites unknown
local function soundAnchor(asset)
	if asset == nil then
		return nil
	end

	if asset:IsA("BasePart") then
		return asset
	end

	if asset:IsA("Model") then
		return asset.PrimaryPart or asset:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function retireIcicles(folder)
	if folder.Parent == nil then
		return
	end

	Ouwmit.Enable(folder, false)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Transparency < 1 then
			TweenService:Create(descendant, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1,
				Position = descendant.Position - createVector(0, 4, 0)
			}):Play()
		elseif descendant:IsA("Decal") and descendant.Transparency < 1 then
			TweenService:Create(descendant, TweenInfo.new(1.2), {
				Transparency = 1
			}):Play()
		end
	end
end

return function(instance, p: string?, value: string?, cframe)
	local DISTANCE_THRESHOLD = 250

	if p == "Crash" then
		if typeof(cframe) ~= "CFrame" or (cframe.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		local raycastResult = workspace:Raycast(
			cframe.Position + createVector(0, 3, 0),
			createVector(0, -20, 0),
			RaycastHelper.Crater
		)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance)
		Cam_Shaker(cframe.Position, {
			FadeInTime = 0,
			Frequency = 0.22,
			Amplitude = 1.4,
			SustainTime = 0.12,
			FadeOutTime = 0.9,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(1, 1, 1)
		})
		local v2 = cframe * assets.Landing.Ground.CFrame:ToObjectSpace(assets.Landing:GetPivot())
		local asset = vfxUtility.cloneAsset(assets, debree, "Landing", v2, 10)
		asset.Name = `YetiCrash-{value or ""}`

		for _, model in asset:GetChildren() do
			if not (model:IsA("Model") and string.find(model.Name, "MeshPartMesh", 1, true) == 1) then
				continue
			end

			local objectSpace = cframe:ToObjectSpace(model:GetPivot())
			local position = (cframe * CFrame.new(objectSpace.X * 1.2, 0, objectSpace.Z * 1.2)).Position
			local raycastResult2 = workspace:Raycast(
				position + createVector(0, 12, 0),
				createVector(0, -80, 0),
				RaycastHelper.Crater
			)
			local v3

			if raycastResult2 then
				v3 = raycastResult2.Position.Y
			else
				v3 = position.Y
			end

			local v4 = v3 + objectSpace.Y
			model:PivotTo(CFrame.new(position.X, v4, position.Z) * objectSpace.Rotation)
		end

		if raycastResult ~= nil then
			OuwCraters.Scales({
				Center = CFrame.new(raycastResult.Position),
				Count = 7,
				Radius = 8
			})
		end

		Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
		local v3 = soundAnchor(asset) -- equivalent call inferred; original call site unknown

		if v3 then
			vfxUtility.PlaySound(sounds, "PS2yetiCRASHslam", v3, true)
		end

		task.delay(5, retireIcicles, asset)
	elseif p == "IcicleHit" then
		if typeof(cframe) ~= "Instance" or cframe.PrimaryPart == nil then
			return
		end

		local position = cframe.PrimaryPart.Position

		if (position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		local raycastResult = workspace:Raycast(
			position + createVector(0, 3, 0),
			createVector(0, -60, 0),
			RaycastHelper.Crater
		)
		local v

		if raycastResult then
			v = raycastResult.Position
		else
			v = position - createVector(0, 3, 0)
		end

		local v2 = CFrame.new(v) * CFrame.Angles(0, math.rad((math.random(0, 359))), 0) * assets.IcicleHit.BuddhaComeUp.Smash.CFrame:ToObjectSpace(assets.IcicleHit:GetPivot())
		local asset = vfxUtility.cloneAsset(assets, debree, "IcicleHit", v2, 6.7)
		Ouwmit.Emit(asset, Ouwmit.Owned(instance))
		local v3 = soundAnchor(asset) -- equivalent call inferred; original call site unknown

		if v3 then
			vfxUtility.PlaySound(sounds, "PS2yetiCRASHspike", v3, true)
		end

		task.delay(5, retireIcicles, asset)
	else
		if instance == nil then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= DISTANCE_THRESHOLD then
			return
		end

		if p == "Startup" or p == "Jump" then
			local raycastResult = workspace:Raycast(
				humanoidRootPart.Position,
				createVector(0, -60, 0),
				RaycastHelper.Crater
			)
			local cFrame

			if raycastResult then
				cFrame = CFrame.new(raycastResult.Position) * humanoidRootPart.CFrame.Rotation
			else
				cFrame = humanoidRootPart.CFrame
			end

			local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance)
			local v2 = p == "Startup"
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.25,
				Amplitude = 0.75,
				SustainTime = v2 and 0.25 or 0.1,
				FadeOutTime = v2 and 0.8 or 0.5,
				RotationInfluence = createVector(0.3, 0.3, 0.3),
				PositionInfluence = createVector(1, 1, 1)
			})

			if v2 then
				local v3 = cFrame * assets.Startup.Floor.CFrame:ToObjectSpace(assets.Startup:GetPivot())
				Ouwmit.Emit(vfxUtility.cloneAsset(assets, debree, "Startup", v3, 4), Ouwmit.Owned(instance, v))
			else
				local asset = vfxUtility.cloneAsset(assets, debree, "Jump", cFrame, 5)
				Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))

				if asset == nil then
					asset = nil
				elseif not asset:IsA("BasePart") then
					if asset:IsA("Model") then
						asset = asset.PrimaryPart or asset:FindFirstChildWhichIsA("BasePart", true)
					else
						asset = nil
					end
				end

				if asset then
					vfxUtility.PlaySound(sounds, "PS2yetiCRASHjump", asset, true)
				end
			end
		end
	end
end