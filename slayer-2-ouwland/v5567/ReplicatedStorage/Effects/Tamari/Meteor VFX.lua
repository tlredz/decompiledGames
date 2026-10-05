local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)

local function createFolder(instance)
	local formatted = `{instance.Name}-MeteorVFX`
	local child = workspace.Debree:FindFirstChild(formatted)

	if child then
		child:Destroy()
	end

	local configuration = Instance.new("Configuration")
	configuration.Name = formatted
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 30)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(p)
	local formatted = `{p.Name}-MeteorVFX`
	return (workspace.Debree:FindFirstChild(formatted))
end

local function folderAlive(instance)
	return instance.Parent ~= nil and not instance:GetAttribute("Cancelled")
end

local function destroyMainFolder(instance)
	local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

	if folder and folder.Parent then
		folder:SetAttribute("Cancelled", true)
		vfxUtility.EnableAll(folder, false)
		folder.Name = "--"
		DebrisModule:AddItem(folder, 1.3)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shake(position: Vector3, amplitude: number)
	Cam_Shaker(position, {
		FadeInTime = 0,
		Frequency = 0.3,
		Amplitude = amplitude,
		SustainTime = 0.2,
		FadeOutTime = 0.1,
		RotationInfluence = createVector(0.2, 0.2, 0.2),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	})
end

return function(instance, childName: string, p)
	if instance == nil then
		return
	end

	if childName == "Cancel" then
		destroyMainFolder(instance)
		return
	elseif childName == "Start" then
		createFolder(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if childName == "RightHand" or childName == "LeftHand" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

		if not folder then
			return
		end

		local v = childName == "RightHand" and 3 or -3
		local child = instance:FindFirstChild(childName, true)

		if child then
			local asset = vfxUtility.cloneAsset(assets, child, "HandAttach", nil, 0.25)
			local asset2 = vfxUtility.cloneAsset(assets, folder, "Ball1", nil, 0.25)

			if asset2 and asset then
				local rigid = asset2:FindFirstChild("rigid")
				local rigidConstraint = rigid and rigid:FindFirstChildWhichIsA("RigidConstraint")

				if rigidConstraint then
					rigidConstraint.Attachment0 = asset
				end

				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)
				vfxUtility.EmitAll(
					asset2,
					vfxUtility.Owned(
						instance,
						raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance)
					)
				)
			end
		end

		task.wait(0.25)
		local v2

		if folder.Parent == nil then
			v2 = false
		else
			v2 = not folder:GetAttribute("Cancelled")
		end

		if not v2 then
			return
		end

		local asset = vfxUtility.cloneAsset(
			assets,
			folder,
			"RapidBall",
			humanoidRootPart.CFrame * CFrame.new(v, 1, 0) * CFrame.Angles(1.5707963267948966, 0, 0),
			1
		)

		if asset and asset.PrimaryPart then
			vfxUtility.PlaySound(script.Sounds, "bounce", asset.Ball, true)
			TweenService:Create(asset.PrimaryPart, TweenInfo.new(0.2), {
				Position = asset.PrimaryPart.Position + createVector(0, -3.5, 0)
			}):Play()
			local asset2 = vfxUtility.cloneAsset(
				assets,
				folder,
				"ballfx",
				humanoidRootPart.CFrame * CFrame.new(v, -2.5, 0),
				5
			)

			if asset2 then
				local raycastResult = workspace:Raycast(
					asset2.Position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)

				if raycastResult then
					asset2:PivotTo(CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					))
					vfxUtility.EmitAll(
						asset2,
						vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
					)
				else
					vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance))
				end
			end
		end

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

		if asset and asset.PrimaryPart then
			vfxUtility.EnableAll(asset, true, vfxUtility.Owned(instance))
			TweenService:Create(asset.PrimaryPart, TweenInfo.new(0.7), {
				Position = asset.PrimaryPart.Position + createVector(0, 200, 0)
			}):Play()
		end
	elseif childName == "Descend" then
		local position = p or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 20
		local raycastResult = workspace:Raycast(
			position + createVector(0, 3, 0),
			createVector(-0, -13, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			position = raycastResult.Position or position
		end

		local asset = vfxUtility.cloneAsset(
			assets,
			workspace.Debree,
			"RapidBall",
			CFrame.new(position + createVector(0, 200, 0)),
			3
		)

		if asset == nil or asset.PrimaryPart == nil then
			return
		end

		vfxUtility.EnableAll(asset, true, vfxUtility.Owned(instance))
		asset.PrimaryPart.CFrame = CFrame.new(asset.PrimaryPart.Position, position)
		local tween = TweenService:Create(asset.PrimaryPart, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Position = position
		})
		tween:Play()
		tween.Completed:Once(function()
			asset:Destroy()
			local asset2 = vfxUtility.cloneAsset(assets, workspace.Debree, "BallImpact", nil, 2.75)

			if asset2 then
				vfxUtility.PlaySound(script.Sounds, "PS2tamariMETEORslam", asset2.PrimaryPart, true)
				local raycastResult2 = workspace:Raycast(
					position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)

				if raycastResult2 then
					asset2:PivotTo((CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal)))
					Ouwmit.Emit(
						asset2,
						Ouwmit.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance))
					)
					OuwCraters.Scales({
						Center = asset2.PrimaryPart.CFrame,
						Duration = 1,
						Radius = 10,
						Count = 4,
						ScaleMult = 0.7
					})
					task.spawn(function()
						TokenKit.GroundRocks({
							CF = asset2.PrimaryPart.CFrame,
							InnerRadius = 5,
							OuterRadius = 10,
							Velocity = {
								Min = 10,
								Max = 35
							},
							Amount = 5,
							Size = {
								Min = 0.5,
								Max = 2
							}
						})
					end)
				else
					asset2:PivotTo(CFrame.new(position))
					Ouwmit.Emit(asset2, Ouwmit.Owned(instance))
				end
			end

			shake(position, 0.45) -- equivalent call inferred; original call site unknown
		end)
	end
end