local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local assets = script.Assets
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local OuwCraters = require(CAM.Client.Modules.Effects.Craters.OuwCraters)
local v = CFrame.new(0, -3.112, 0) * CFrame.Angles(-2.627, -1.571, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function stepFolderName(p, p2: string)
	return (`{p.Name}-PiercingKickVFX-{p2}`)
end

local function bumpFolderLifetime(instance, p: number)
	local v2 = os.clock() + p + 0.4
	local lifetimeDeadline = instance:GetAttribute("LifetimeDeadline")

	if lifetimeDeadline and v2 <= lifetimeDeadline then
		return
	end

	instance:SetAttribute("LifetimeDeadline", v2)

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

			local v3 = lifetimeDeadline2 - os.clock()

			if v3 <= 0 then
				break
			else
				task.wait(v3)
			end
		end

		if instance.Parent then
			instance:Destroy()
		end
	end)
end

local function createStepFolder(instance, p: string, value: number?)
	local name = stepFolderName(instance, p) -- equivalent call inferred; original call site unknown
	local child = workspace.Debree:FindFirstChild(name)

	if child then
		child:Destroy()
	end

	local configuration = Instance.new("Configuration")
	configuration.Name = name
	configuration.Parent = workspace.Debree
	bumpFolderLifetime(configuration, value or 0)
	return configuration
end

local function findStepFolder(p, p2: string)
	return (workspace.Debree:FindFirstChild((`{p.Name}-PiercingKickVFX-{p2}`)))
end

local function addAsset(p, p2, p3: string, cframe: CFrame?, p4: number?)
	local asset = vfxUtility.cloneAsset(p2, p, p3, cframe, p4)

	if asset and p4 then
		bumpFolderLifetime(p, p4)
	end

	return asset
end

local function destroyAllStepFolders(instance)
	local formatted = `{instance.Name}-PiercingKickVFX`

	for _, configuration in workspace.Debree:GetChildren() do
		if not (configuration:IsA("Configuration") and configuration.Name:sub(1, #formatted) == formatted) then
			continue
		end

		vfxUtility.EnableAll(configuration, false)
		configuration.Name = "--"
		DebrisModule:AddItem(configuration, 1.3)
	end
end

return function(instance, p: string, instance2, value, part, cFrame)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyAllStepFolders(instance)
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	if p == "kick" then
		local stepFolder = createStepFolder(instance, "jumpfx")
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult then
			local v3 = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			local asset = vfxUtility.cloneAsset(assets, stepFolder, "JumpEff", v3, 5)

			if asset then
				bumpFolderLifetime(stepFolder, 5)
			end

			if asset then
				vfxUtility.EmitAll(
					asset,
					vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
				)
			end
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		vfxUtility.PlaySound(script.Sounds, "PS2tamariPIERCINGKICKjump", humanoidRootPart, true)
	elseif p == "Kick" then
		local stepFolder = createStepFolder(instance, "kickfx")

		if typeof(part) ~= "Instance" then
			part = nil
		end

		local v2 = part and part:IsA("BasePart") and vfxUtility.GetDustColorSettings(part) or nil
		local asset = vfxUtility.cloneAsset(assets, stepFolder, "HeavySlashFX", nil, 5)

		if asset then
			bumpFolderLifetime(stepFolder, 5)
		end

		if typeof(cFrame) ~= "CFrame" then
			cFrame = humanoidRootPart.CFrame
		end

		asset:PivotTo(cFrame)

		if v2 then
			Ouwmit.Emit(asset, Ouwmit.Owned(instance, v2))
		else
			Ouwmit.Emit(asset.HeavySlashFX, Ouwmit.Owned(instance, v2))
		end
	elseif p == "Slam" then
		local stepFolder = createStepFolder(instance, "slam")

		if typeof(instance2) ~= "Vector3" then
			instance2 = nil
		end

		local v2 = typeof(value) == "Vector3" and value or createVector(0, 1, 0)

		if typeof(part) ~= "Instance" then
			part = nil
		end

		local v3 = part and part:IsA("BasePart") and vfxUtility.GetDustColorSettings(part) or nil

		if typeof(cFrame) ~= "CFrame" then
			cFrame = humanoidRootPart.CFrame
		end

		local v5 = cFrame * v
		local asset = vfxUtility.cloneAsset(assets, stepFolder, "ThrowDown", v5, 5)

		if asset then
			bumpFolderLifetime(stepFolder, 5)
		end

		vfxUtility.EmitAll(asset, vfxUtility.Owned(instance, v3))
		Cam_Shaker(cFrame.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})

		if instance2 then
			local cframe = CFrame.lookAt(instance2, instance2 + v2)

			for _, v6 in { "Final", "MaceHit" } do
				local asset2 = vfxUtility.cloneAsset(assets, stepFolder, v6, cframe, 5)

				if asset2 then
					bumpFolderLifetime(stepFolder, 5)
				end

				if asset2 then
					vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance, v3))
				end
			end

			OuwCraters.Scales({
				Center = instance2,
				Radius = 10,
				Count = 10,
				ScaleMult = 0.7,
				OffsetMargin = 4
			})
			Cam_Shaker(instance2, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.3,
				SustainTime = 0.3,
				FadeOutTime = 0.2,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(3.5, 3.5, 3.5)
			})
		end

		vfxUtility.PlaySound(script.Sounds, "PS2tamariPIERCINGKICKslamkick", humanoidRootPart, true)
	elseif p == "Throw" then
		local stepFolder = createStepFolder(instance, "throw")
		local humanoidRootPart2 = instance2 and instance2:FindFirstChild("HumanoidRootPart")
		local middle001R = instance:FindFirstChild("Middle.001.R", true) or instance:FindFirstChild("RightHand", true)

		if middle001R then
			local asset = vfxUtility.cloneAsset(assets.Part, middle001R, "rigidattach", nil, 0.5)
			local asset2 = vfxUtility.cloneAsset(assets, stepFolder, "Ball1", nil, 0.5)

			if asset2 then
				bumpFolderLifetime(stepFolder, 0.5)
			end

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

		vfxUtility.PlaySound(script.Sounds, "PS2tamariPIERCINGKICKslam", humanoidRootPart, true)
		task.wait(0.4166666666666667)

		if stepFolder.Parent == nil then
			return
		end

		local position = humanoidRootPart2 and humanoidRootPart2.Position or humanoidRootPart.Position
		local v3 = CFrame.new(position + createVector(0, 75, 0)) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local asset = vfxUtility.cloneAsset(assets, stepFolder, "RapidBall", v3, 8)

		if asset then
			bumpFolderLifetime(stepFolder, 8)
		end

		if asset then
			asset.Name = "VictimBall"

			if asset.PrimaryPart then
				vfxUtility.EnableAll(asset, true, vfxUtility.Owned(instance))
				local primaryPart = asset.PrimaryPart
				local Y = primaryPart.Position.Y
				local postSimulationConnection = nil
				postSimulationConnection = RunService.PostSimulation:Connect(function()
					if primaryPart.Parent == nil or stepFolder.Parent == nil then
						if postSimulationConnection then
							postSimulationConnection:Disconnect()
						end
					else
						if asset:GetAttribute("Busy") == true then
							return
						end

						local humanoidRootPart3 = instance2 and instance2.Parent and instance2:FindFirstChild("HumanoidRootPart")
						local position2

						if humanoidRootPart3 then
							position2 = humanoidRootPart3.Position
						else
							position2 = position
						end

						primaryPart.Position = Vector3.new(position2.X, Y, position2.Z)
					end
				end)
			end
		end

		task.wait(0.08333333333333333)

		if stepFolder.Parent == nil then
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
		local v5 = humanoidRootPart.CFrame * CFrame.new(0, 1, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
		local asset2 = vfxUtility.cloneAsset(assets, stepFolder, "RapidBall", v5, 1)

		if asset2 then
			bumpFolderLifetime(stepFolder, 1)
		end

		if asset2 and asset2.PrimaryPart then
			TweenService:Create(asset2.PrimaryPart, TweenInfo.new(0.2), {
				Position = asset2.PrimaryPart.Position + createVector(0, -3.5, 0)
			}):Play()
		end

		task.wait(0.08333333333333333)

		if stepFolder.Parent == nil then
			return
		end

		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local asset3 = vfxUtility.cloneAsset(assets, stepFolder, "ballfx", nil, 5)

		if asset3 then
			bumpFolderLifetime(stepFolder, 5)
		end

		if asset3 then
			if raycastResult then
				asset3:PivotTo(CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				))
				vfxUtility.EmitAll(
					asset3,
					vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
				)
			else
				asset3:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2.5, -3))
				vfxUtility.EmitAll(asset3, vfxUtility.Owned(instance))
			end
		end

		task.wait(0.16666666666666666)

		if stepFolder.Parent == nil then
			return
		end

		if asset2 then
			vfxUtility.EnableAll(asset2, true, vfxUtility.Owned(instance))

			if asset2.PrimaryPart then
				TweenService:Create(asset2.PrimaryPart, TweenInfo.new(1), {
					Position = asset2.PrimaryPart.Position + createVector(0, 200, 0)
				}):Play()
			end
		end
	elseif p == "Hit" then
		local stepFolder = createStepFolder(instance, "switchhit-" .. tostring(math.random(1, 1000000000)))
		local v2 = typeof(value) ~= "number" and 0.15 or value
		local humanoidRootPart2 = instance2 and instance2:FindFirstChild("HumanoidRootPart")

		if not (instance2 and humanoidRootPart2) then
			return
		end

		local position = humanoidRootPart2.Position
		local v3 = 50
		local v4 = 50
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-PiercingKickVFX-throw`))
		local victimBall = child and child:FindFirstChild("VictimBall")
		local flag = false

		if victimBall and victimBall:IsA("Model") and victimBall.PrimaryPart then
			victimBall:SetAttribute("Busy", true)
			v3 = victimBall.PrimaryPart.Position.Y - position.Y
			v4 = v3
		else
			local assets2 = script.Parent["Spinning Throw VFX"].Assets
			local cframe = CFrame.new(position + Vector3.new(0, v3, 0))
			victimBall = vfxUtility.cloneAsset(assets2, stepFolder, "Ball1", cframe, 2)

			if victimBall then
				bumpFolderLifetime(stepFolder, 2)
			end

			flag = true

			if victimBall then
				vfxUtility.EnableAll(victimBall, true, vfxUtility.Owned(instance))
			end
		end

		if victimBall == nil then
			return
		end

		local v5 = position + Vector3.new(0, v3, 0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setBallPos(position2: Vector3)
			if victimBall:IsA("Model") and victimBall.PrimaryPart then
				victimBall.PrimaryPart.Position = position2
			elseif victimBall:IsA("BasePart") then
				victimBall.Position = position2
			end
		end

		local lastTime = os.clock()
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			local v6 = os.clock() - lastTime
			local humanoidRootPart3 = instance2 and instance2.Parent and instance2:FindFirstChild("HumanoidRootPart")

			if v2 <= v6 or not victimBall or not victimBall.Parent or not humanoidRootPart3 or stepFolder.Parent == nil then
				if postSimulationConnection then
					postSimulationConnection:Disconnect()
				end
			else
				local v7 = v6 / v2
				local raycastResult = workspace:Raycast(
					humanoidRootPart3.Position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)
				local position2 = raycastResult and raycastResult.Position or humanoidRootPart3.Position + createVector(
					0,
					-2.5,
					0
				)
				setBallPos(v5:Lerp(position2, v7)) -- equivalent call inferred; original call site unknown
			end
		end)
		task.wait(v2)

		if stepFolder.Parent == nil then
			return
		end

		local humanoidRootPart3 = instance2 and instance2.Parent and instance2:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart3 then
			position = humanoidRootPart3.Position or position
		end

		local raycastResult = workspace:Raycast(
			position + createVector(0, 5, 0),
			createVector(-0, -10, -0),
			RaycastHelper.Crater
		)
		local position2 = raycastResult and raycastResult.Position or position + createVector(0, -2.5, 0)
		local asset = vfxUtility.cloneAsset(assets, stepFolder, "MaceHit", nil, 5)

		if asset then
			bumpFolderLifetime(stepFolder, 5)
		end

		vfxUtility.PlaySound(script.Sounds, "PS2tamariPIERCINGKICKandMETEORbounceslam", asset, true)

		if asset then
			if raycastResult then
				asset:PivotTo(CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal))
				vfxUtility.EmitAll(
					asset,
					vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
				)
			else
				asset:PivotTo(CFrame.new(position2))
				vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
			end
		end

		Cam_Shaker(position2, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		local lastTime2 = os.clock()
		local postSimulationConnection2 = nil
		postSimulationConnection2 = RunService.PostSimulation:Connect(function()
			local v7 = os.clock() - lastTime2

			if v7 >= 0.3 or not victimBall or not victimBall.Parent or stepFolder.Parent == nil then
				if postSimulationConnection2 then
					postSimulationConnection2:Disconnect()
				end

				if flag then
					if victimBall and victimBall.Parent then
						vfxUtility.EnableAll(victimBall, false)
						DebrisModule:AddItem(victimBall, 0.25)
					end
				elseif victimBall then
					victimBall:SetAttribute("Busy", nil)
				end
			else
				local v8 = v7 / 0.3
				local humanoidRootPart4 = instance2 and instance2.Parent and instance2:FindFirstChild("HumanoidRootPart")
				local position3 = humanoidRootPart4 and humanoidRootPart4.Position or position
				setBallPos(Vector3.new(position3.X, position.Y + v4 * v8, position3.Z)) -- equivalent call inferred; original call site unknown
			end
		end)
	elseif p == "FinalDrop" then
		local stepFolder = createStepFolder(instance, "finaldrop")
		local v2 = typeof(value) ~= "number" and 1 or value
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-PiercingKickVFX-throw`))
		local victimBall = child and child:FindFirstChild("VictimBall")
		local primaryPart = victimBall and victimBall:IsA("Model") and victimBall.PrimaryPart

		if victimBall then
			victimBall:SetAttribute("Busy", true)
		end

		local position = primaryPart and primaryPart.Position
		local lastTime = os.clock()
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			local v3 = os.clock() - lastTime
			local humanoidRootPart2 = instance2 and instance2.Parent and instance2:FindFirstChild("HumanoidRootPart")

			if v3 >= 0.3 or not victimBall or not victimBall.Parent or not primaryPart or not humanoidRootPart2 or stepFolder.Parent == nil then
				if postSimulationConnection then
					postSimulationConnection:Disconnect()
				end
			else
				local v4 = v3 / 0.3
				local raycastResult = workspace:Raycast(
					humanoidRootPart2.Position + createVector(0, 5, 0),
					createVector(-0, -20, -0),
					RaycastHelper.Crater
				)
				local position2 = raycastResult and raycastResult.Position or humanoidRootPart2.Position + createVector(
					0,
					-2.5,
					0
				)
				primaryPart.Position = (position or position2):Lerp(position2, v4)
			end
		end)
		task.wait(0.3)

		if stepFolder.Parent == nil then
			return
		end

		local humanoidRootPart2 = instance2 and instance2.Parent and instance2:FindFirstChild("HumanoidRootPart")
		local position2 = humanoidRootPart2 and humanoidRootPart2.Position or primaryPart and primaryPart.Position or humanoidRootPart.Position
		local raycastResult = workspace:Raycast(
			position2 + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local position3 = raycastResult and raycastResult.Position or position2 + createVector(0, -2.5, 0)
		local asset = vfxUtility.cloneAsset(assets, stepFolder, "MaceHit", nil, 5)

		if asset then
			bumpFolderLifetime(stepFolder, 5)
		end

		vfxUtility.PlaySound(script.Sounds, "PS2tamariPIERCINGKICKandMETEORbounceslam", asset, true)

		if asset then
			if raycastResult then
				asset:PivotTo(CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal))
				vfxUtility.EmitAll(
					asset,
					vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult.Instance))
				)
			else
				asset:PivotTo(CFrame.new(position3))
				vfxUtility.EmitAll(asset, vfxUtility.Owned(instance))
			end
		end

		Cam_Shaker(position3, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
		task.wait(v2)

		if stepFolder.Parent == nil then
			return
		end

		if victimBall then
			vfxUtility.EnableAll(victimBall, false)
			DebrisModule:AddItem(victimBall, 0.5)
		end

		local position4 = primaryPart and primaryPart.Position or position2
		local raycastResult2 = workspace:Raycast(
			position4 + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)

		if raycastResult2 then
			position4 = raycastResult2.Position or position4
		end

		local cframe = CFrame.new(position4)
		local asset2 = vfxUtility.cloneAsset(assets, stepFolder, "lastexplo", cframe, 5)

		if asset2 then
			bumpFolderLifetime(stepFolder, 5)
		end

		if asset2 then
			if raycastResult2 then
				asset2:PivotTo(CFrame.new(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				))
				vfxUtility.EmitAll(
					asset2,
					vfxUtility.Owned(instance, vfxUtility.GetDustColorSettings(raycastResult2.Instance))
				)
			else
				vfxUtility.EmitAll(asset2, vfxUtility.Owned(instance))
			end
		end

		local cframe2 = CFrame.new(position4)
		local asset3 = vfxUtility.cloneAsset(assets, stepFolder, "Impact2", cframe2, 4)

		if asset3 then
			bumpFolderLifetime(stepFolder, 4)
		end

		vfxUtility.PlaySound(script.Sounds, "PS2tamariPIERCINGKICKexpl", asset3, true)

		if asset3 then
			vfxUtility.EmitAll(
				asset3,
				vfxUtility.Owned(instance, raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance))
			)
		end

		OuwCraters.Scales({
			Center = position4,
			Radius = 10,
			Count = 8,
			OffsetMargin = 4
		})
		Cam_Shaker(position4, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.3,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.35, 0.35, 0.35),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	end
end