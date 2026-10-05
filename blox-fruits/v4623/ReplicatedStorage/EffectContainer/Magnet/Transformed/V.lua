local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local V = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("V")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function hasCrimsonGoldSkin(player, rig)
	if typeof(rig) == "Instance" and rig:GetAttribute("Arcsteel") then
		return true
	end

	if typeof(player) ~= "Instance" then
		return false
	end

	local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

	if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
		return true
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
		return true
	end

	return false
end

local function resolveScrap(childName: string, flag: boolean)
	if not flag then
		return scraps:FindFirstChild(childName)
	end

	local v2 = v[childName]
	local child = v2 and scraps:FindFirstChild(v2)

	if child then
		return child
	end

	return scraps:FindFirstChild(childName)
end

local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

local function RecolorMagnetColorSequence(instance, p, p2)
	if typeof(instance) == "Instance" and instance.Parent then
		p = WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return ColorSequence.new(p, RecolorMagnetColor(instance, p2))
end

local CustomCollisions2 = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions2.new("Rocks")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v2 = math.max(v2, emitter.Lifetime.Max)
			end
		end

		task.wait(v2)
		folder:Destroy()
	end)
end

local function makeProxyPartAtBone(attachment, rig, _, cframe: CFrame?)
	local cFrame = cframe or CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. attachment.Name
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = cFrame
	attachment2.Parent = part
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = attachment
	rigidConstraint.Attachment1 = attachment2
	rigidConstraint.Parent = part
	part.Transparency = 1
	part.Parent = rig
	return part
end

local function QuadBezier(p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
end

local function AlignCFrame(data, normal)
	local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p, unit2, v2, unit3)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v2 = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize2
	v2.MinRadius = 3
	v2.MaxRadius = 13
	v2.Frequency = 0.5
	v2.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v2.MinThicknessMultiplier = 0.2
	v2.MaxThicknessMultiplier = maxThicknessMultiplier
	v2.MinTransparency = 0
	v2.MaxTransparency = 1
	v2.PulseSpeed = 10
	v2.PulseLength = 1000000
	v2.FadeLength = 0.2
	v2.ContractFrom = 0.5
	v2.Color = Color3.new(1, 0.380392, 0.380392)
	v2.ColorOffsetSpeed = 3
	return v2
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, position, p2, p3, position2)
	local v2 = position + (p2 - position) * p
	local v3 = p2 + (p3 - p2) * p
	local v4 = p3 + (position2 - p3) * p
	local v5 = v2 + (v3 - v2) * p
	return v5 + (v3 + (v4 - v3) * p - v5) * p
end

local function TrailSpin(part, parent, instance)
	local spinTrails = V.Phase1.SpinTrails
	local v2 = {}

	for i = 1, 5 do
		local clone = spinTrails["Trail" .. tostring((math.random(1, #spinTrails:GetChildren())))]:Clone()
		clone.CFrame = part.CFrame * CFrame.new(0, 25, 0)
		clone.Parent = parent
		clone.Anchored = false
		clone.Weld.Part1 = part

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		clone.SpinTrail2.WeldConstraint.Enabled = false
		clone.SpinTrail2.CFrame = clone.CFrame * CFrame.new(
			math.random(-40, -20) * 1.5,
			math.random(25, 50),
			math.random(10, 25)
		)
		clone.SpinTrail2.WeldConstraint.Enabled = true
		clone.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		local v3

		if i > 3 then
			v3 = math.random(1, 3)
		else
			v3 = i
		end

		if v3 == 1 then
			local trail = clone.Trail
			local color = Color3.fromRGB(60, 22, 248)
			local color2 = Color3.fromRGB(29, 59, 255)

			if typeof(instance) == "Instance" and instance.Parent then
				color = WrapColor3Constructor(color, instance, "MagnetFruitVFXColor")
			end

			trail.Color = ColorSequence.new(color, RecolorMagnetColor(instance, color2))
		elseif v3 == 2 then
			local trail = clone.Trail
			local color = Color3.fromRGB(255, 34, 170)
			local color2 = Color3.fromRGB(232, 29, 110)

			if typeof(instance) == "Instance" and instance.Parent then
				color = WrapColor3Constructor(color, instance, "MagnetFruitVFXColor")
			end

			trail.Color = ColorSequence.new(color, RecolorMagnetColor(instance, color2))
		elseif v3 == 3 then
			local trail = clone.Trail
			local color = Color3.fromRGB(255, 25, 129)
			local color2 = Color3.fromRGB(69, 23, 255)

			if typeof(instance) == "Instance" and instance.Parent then
				color = WrapColor3Constructor(color, instance, "MagnetFruitVFXColor")
			end

			trail.Color = ColorSequence.new(color, RecolorMagnetColor(instance, color2))
		end

		local v4 = math.random(6, 10)
		clone.SpinTrail2.Attach0.Position = Vector3.new(v4, 0, 0)
		clone.SpinTrail2.Attach1.Position = Vector3.new(-v4, 0, 0)
		clone.Trail.Lifetime = math.random(15, 25) / 100
		v2[clone] = math.random(12, 25)
	end

	local v3 = 1 + tick()

	while true do
		for k, v4 in pairs(v2) do
			k.Weld.C0 = k.Weld.C0 * CFrame.new(0, 0.1, 0) * CFrame.Angles(0, math.rad(v4), 0)
		end

		task.wait(0.001)

		if not (v3 - tick() <= 0) then
			continue
		end

		for folder, _ in pairs(v2) do
			for _, effect in pairs(folder:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end

		break
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAfter(clone, duration)
	task.delay(duration, function()
		clone:Destroy()
	end)
end

local function Explosion(p, folder, raycastParams)
	local function RockCrater(p2, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v2 = AlignCFrame(CFrame.new(p2.Position), p2.Normal) + p2.Normal * 0.01
			local v3 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v3, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v4 in pairs(v3) do
					v4:Destroy()
				end

				v3 = nil
			end)
			local v4 = 360 / #v3
			local total = 0

			for _, v5 in pairs(v3) do
				total += v4
				v5.CFrame = v2 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v5.CFrame = CFrame.new(v5.Position, p2.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(
					v5.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams2
				)

				if raycastResult then
					local v6 = (v5.Position - p2.Position).Magnitude / 50
					local v7 = size * math.random(30, 50) / 10
					local v8 = size * math.random(10, 30) / 10
					local v9 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v7 / 2 + v7 * v6, v8 / 2 + v8 * v6, v9 / 2 + v9 * v6)
					v5.Position = raycastResult.Position + Vector3.new(0, -v5.Size.Y / 2, 0)
					v5.CFrame = CFrame.new(v5.Position, p2.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-35, 35) / 5
					)
					v5.CFrame = CFrame.new(v5.Position, v2.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v6)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v5.Material = raycastResult.Instance.Material
					v5.Color = raycastResult.Instance.Color
				else
					v5:Destroy()
					v3[v5] = nil
				end

				TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v5.Position + Vector3.new(0, v5.Size.Y / 1.75, 0)
				}):Play()
				local v6 = v5
				local v7 = v5
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v6,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v6.Position + Vector3.new(
								math.random(-1, 1),
								-v6.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v6:Destroy()
					v3[v6] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local clone = V.Phase2.Rock:Clone()
		rocks:ApplyCollision(clone, nil, true)
		clone.CFrame = cFrame
		clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		clone.Size *= math.random(3, 6) / 5
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = raycastResult.Instance.Material
		clone.Color = raycastResult.Instance.Color
		clone.Anchored = false
		clone.CanCollide = false
		clone.Parent = parent
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 5000
		bodyVelocity.Parent = clone
		local vector2 = Vector3.new(math.random(-30, 30) * 1.5, 0, math.random(-30, 30) * 1.5)
		local vector3 = Vector3.new(0, math.random(150, 200) / 7, 0)
		local v2 = math.random(150, 250) * 0.65
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(0.5 * math.random() + 0.75, function()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.delay(0.025 * math.random() + 0.025, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			clone.CanCollide = true
		end)
	end

	local raycastResult = workspace:Raycast(
		p.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if raycastResult then
		local v2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v3 = {
			Radius = 42,
			Size = 2.35,
			Duration = 0.75,
			Amount = 25,
			RockType = V.Phase2.CraterRock
		}
		task.spawn(function()
			local rockType = v3.RockType
			local radius = v3.Radius
			local size = v3.Size
			local duration = v3.Duration
			local amount = v3.Amount
			local v4 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			local v5 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = folder
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v5, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v6 in pairs(v5) do
					v6:Destroy()
				end

				v5 = nil
			end)
			local v6 = 360 / #v5
			local total = 0

			for _, v7 in pairs(v5) do
				total += v6
				v7.CFrame = v4 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v7.CFrame = CFrame.new(v7.Position, raycastResult.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult2 = workspace:Raycast(
					v7.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams2
				)

				if raycastResult2 then
					local v8 = (v7.Position - raycastResult.Position).Magnitude / 50
					local v9 = size * math.random(30, 50) / 10
					local v10 = size * math.random(10, 30) / 10
					local v11 = size * math.random(30, 50) / 10
					v7.Size = Vector3.new(v9 / 2 + v9 * v8, v10 / 2 + v10 * v8, v11 / 2 + v11 * v8)
					v7.Position = raycastResult2.Position + Vector3.new(0, -v7.Size.Y / 2, 0)
					v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-35, 35) / 5
					)
					v7.CFrame = CFrame.new(v7.Position, v4.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v8)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v7.Material = raycastResult2.Instance.Material
					v7.Color = raycastResult2.Instance.Color
				else
					v7:Destroy()
					v5[v7] = nil
				end

				TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v7.Position + Vector3.new(0, v7.Size.Y / 1.75, 0)
				}):Play()
				local v8 = v7
				local v9 = v7
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v8,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v8.Position + Vector3.new(
								math.random(-1, 1),
								-v8.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v8:Destroy()
					v5[v8] = nil
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 10 do
				task.spawn(function()
					FlyRock(
						v2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							0,
							0,
							-math.random(125, 150) / 7
						),
						raycastResult,
						folder
					)
				end)

				if i % 2 == 0 then
					task.wait(0.001 * math.random())
				end
			end
		end)
	end
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	task.spawn(function()
		local now = tick()
		local player = data.Player
		local rig = data.Rig
		local fakeRig = data.FakeRig
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 10)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local root = data.Root
		local parent = root.Parent
		local v2

		if parent and parent:FindFirstChild("MagnetFruitVFXColor") then
			v2 = parent
		else
			v2 = player
		end

		local _ = root.Position
		local _, v3 = root.CFrame.Rotation:ToOrientation()
		local cFrame = CFrame.new(root.Position) * CFrame.fromOrientation(0, v3, 0)

		if player == game.Players.LocalPlayer then
			local humanoid = parent:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.AutomaticScalingEnabled then
				local Y = root.Size.Y
				local sizeChangedConnection = nil
				sizeChangedConnection = root:GetPropertyChangedSignal("Size"):Connect(function()
					sizeChangedConnection:Disconnect()
					local v5 = (root.Size.Y - Y) / 2

					if math.abs(v5) > 0.001 then
						local cameraOffset = humanoid.CameraOffset
						humanoid.CameraOffset = cameraOffset - Vector3.new(0, v5, 0)
						TweenService:Create(
							humanoid,
							TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CameraOffset = cameraOffset
							}
						):Play()
					end
				end)
				task.delay(6, function()
					if sizeChangedConnection.Connected then
						sizeChangedConnection:Disconnect()
					end
				end)
			end
		end

		local upDist = data.UpDist or 100
		local downDist = data.DownDist
		local cFrame2 = cFrame * CFrame.new(0, upDist, 0)
		root.Anchored = true
		Util.Sound:Play("Magnet_Transformation_Jump_Assemble_Robot_02", root)
		TweenService:Create(root, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = cFrame2
		}):Play()
		local clone = V.Phase2.JumpImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, v2, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.2)
		fakeRig:PivotTo(cFrame2 * CFrame.new(0, -35.9, 0))
		fakeRig.Parent = folder
		fakeRig.PrimaryPart.Anchored = true
		fakeRig.PrimaryPart.Massless = true
		local player2 = data.Player
		local v6

		if typeof(player2) == "Instance" then
			local magnetFruitVFXColor = player2:FindFirstChild("MagnetFruitVFXColor")

			if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
				v6 = true
			else
				local character = player2.Character
				local primaryPart = character and character.PrimaryPart
				v6 = primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" and true or false
			end
		else
			v6 = false
		end

		local v7 = v6 and Util.Anims:Get(fakeRig, "Transformed Arcsteel Transformation") or Util.Anims:Get(
			fakeRig,
			"Magnet Mech Transformation"
		)
		v7.Priority = Enum.AnimationPriority.Action4
		v7:Play()

		if not data.IsNpc then
			local player3 = data.Player
			local v8

			if typeof(player3) == "Instance" then
				local magnetFruitVFXColor = player3:FindFirstChild("MagnetFruitVFXColor")

				if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
					v8 = true
				else
					local character = player3.Character
					local primaryPart = character and character.PrimaryPart
					v8 = primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" and true or false
				end
			else
				v8 = false
			end

			local v9 = v8 and Util.Anims:Get(rig, "Transformed Arcsteel Transformation") or Util.Anims:Get(
				rig,
				"Magnet Mech Transformation"
			)
			v9.Priority = Enum.AnimationPriority.Action4
			v9:Play()
		end

		local player3 = data.Player
		local v8

		if typeof(player3) == "Instance" then
			local magnetFruitVFXColor = player3:FindFirstChild("MagnetFruitVFXColor")

			if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
				v8 = true
			else
				local character = player3.Character
				local primaryPart = character and character.PrimaryPart
				v8 = primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" and true or false
			end
		else
			v8 = false
		end

		local v9 = v8 and Util.Anims:Get(fakeRig, "Transformed Arcsteel Transformation Loop Fall") or Util.Anims:Get(
			fakeRig,
			"Magnet Mech Transformation Loop Fall"
		)
		v9.Looped = true
		v9.Priority = Enum.AnimationPriority.Action3
		v9:Play()
		local v10

		if not data.IsNpc then
			local player4 = data.Player
			local v11

			if typeof(player4) == "Instance" then
				local magnetFruitVFXColor = player4:FindFirstChild("MagnetFruitVFXColor")

				if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
					v11 = true
				else
					local character = player4.Character
					local primaryPart = character and character.PrimaryPart
					v11 = primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" and true or false
				end
			else
				v11 = false
			end

			v10 = v11 and Util.Anims:Get(rig, "Transformed Arcsteel Transformation Loop Fall") or Util.Anims:Get(
				rig,
				"Magnet Mech Transformation Loop Fall"
			)
			v10.Looped = true
			v10.Priority = Enum.AnimationPriority.Action3
			v10:Play()
		end

		local clone2 = V.Phase1.StartImpact:Clone()
		clone2.CFrame = cFrame2 * CFrame.new(0, 20, 0)
		Util.SetParentOverrideWithColor(clone2, folder, v2, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			local clone3 = V.Phase1.Start:Clone()
			clone3.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
			local emittersByEmitter = {}

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter
			end

			local v11 = 2.3 + tick()

			while true do
				for _, v12 in pairs(emittersByEmitter) do
					v12:Emit(1)
				end

				task.wait(0.085)

				if not (v11 - tick() <= 0) then
					continue
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0
		highlight.FillColor = Color3.new(0, 0, 0)
		highlight.OutlineTransparency = 1
		highlight.Adornee = parent
		highlight.Parent = parent
		highlight.FillTransparency = 1
		TweenService:Create(highlight, TweenInfo.new(0.4), {
			FillTransparency = 0
		}):Play()
		task.wait(1.5)
		local trails = V.Phase1.Trails
		task.spawn(function()
			local count = #trails:GetChildren()

			for _ = 1, 15 do
				task.spawn(function()
					task.wait(math.random() * 0.15)
					local cFrame3 = cFrame2 * CFrame.new(
						math.random(-25, 25) * 2.5,
						math.random(-15, 25) * 2.5,
						math.random(-25, 25) * 2.5
					)
					local position = cFrame2.Position
					local v12 = math.random(50, 70) / 15
					local v13 = math.random(1, count)
					local clone3 = trails["Trail" .. tostring(v13)]:Clone()
					clone3.CFrame = cFrame3
					Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
					local position2 = clone3.Position
					local magnitude = (position2 - position).Magnitude
					clone3.CFrame = CFrame.new(position2, position)
					local v14 = (position2 - position) / 2
					local position3 = CFrame.new(CFrame.new(position2) * (v14 / -1.5)).Position
					local position4 = CFrame.new(CFrame.new(position) * (v14 / 1.5)).Position
					local v15 = magnitude / 0.5
					local v16 = position3 + Vector3.new(
						math.random(-v15, v15),
						math.random(-v15 / 2, v15),
						math.random(-v15, v15)
					)
					local v17 = position4 + Vector3.new(
						math.random(-v15, v15),
						math.random(-v15 / 2, v15),
						math.random(-v15, v15)
					)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local lastTime = tick()
					local v18 = magnitude / v12 / 60

					while tick() - lastTime < v18 do
						local v19 = (tick() - lastTime) / v18
						local v20 = cubicBezier(v19, position2, v16, v17, position)
						clone3.CFrame = clone3.CFrame:Lerp(CFrame.new(v20, position), v19)
						RunService.Heartbeat:Wait()
					end

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				task.wait(0.035)
			end
		end)
		local crimsonGoldSkin = hasCrimsonGoldSkin(data.Player, data.Rig)
		local arcsteelScrapModelScene = data.Scene and crimsonGoldSkin and scraps:FindFirstChild("ArcsteelScrapModelScene")

		if not arcsteelScrapModelScene then
			if crimsonGoldSkin then
				local scrapModelA = v.ScrapModelA
				arcsteelScrapModelScene = scrapModelA and scraps:FindFirstChild(scrapModelA)

				if not arcsteelScrapModelScene then
					arcsteelScrapModelScene = scraps:FindFirstChild("ScrapModelA")
				end
			else
				arcsteelScrapModelScene = scraps:FindFirstChild("ScrapModelA")
			end
		end

		arcsteelScrapModelScene:ScaleTo(3.125)
		local children = arcsteelScrapModelScene:GetChildren()
		task.spawn(function()
			local v11 = cFrame2
			local numberValue = Instance.new("NumberValue", folder)
			numberValue.Value = 100
			local v12 = 0.8 + math.random(-30, 5) / 100
			TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				Value = 60
			}):Play()
			task.delay(0.7, function()
				TweenService:Create(
					numberValue,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
					{
						Value = 40
					}
				):Play()
			end)
			local v13 = {}
			task.spawn(function()
				for i = 1, 10 do
					local clone3 = children[math.random(1, #children)]:Clone()
					clone3.Anchored = true
					clone3.CanCollide = false
					clone3.Size *= math.random(10, 15) / 7
					Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
					local baseAngle = i / 10 * 3.141592653589793 * 2
					table.insert(v13, {
						part = clone3,
						baseAngle = baseAngle,
						spawnTime = tick(),
						rising = true,
						yOffset = math.random(-25, 25)
					})
					task.wait(0.035)
				end
			end)
			local lastTime = tick()
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v14 = tick() - lastTime

				if v12 < v14 then
					heartbeatConnection:Disconnect()

					for _, v15 in ipairs(v13) do
						local part = v15.part
						TweenService:Create(part, TweenInfo.new(0.25), {
							Size = createVector(0, 0, 0)
						}):Play()
						task.delay(0.25, function()
							if part then
								part:Destroy()
							end
						end)
					end
				else
					for _, v15 in ipairs(v13) do
						local part = v15.part

						if v15.rising then
							local v16 = tick() - v15.spawnTime
							local v17 = math.clamp(v16 / 0.375, 0, 1)
							local v18 = v15.baseAngle + v16 * 10
							local _ = math.cos(v18) * numberValue.Value
							local _ = math.sin(v18) * numberValue.Value
							local _ = 1 + v15.yOffset + (1 - v17) * -25
							local v19 = math.sin(v14 * 4 + v15.baseAngle * 3) * 7
							local v20 = v11.Position + Vector3.new(
								math.cos(v18) * numberValue.Value,
								1 + v15.yOffset + v19,
								math.sin(v18) * numberValue.Value
							)
							part.CFrame = CFrame.lookAt(v20, v11.Position) * CFrame.Angles(
								math.rad(v16 * 300),
								math.rad(v16 * 200),
								(math.rad(v16 * 100))
							)

							if v17 >= 1 then
								v15.rising = false
							end
						else
							local v16 = v15.baseAngle + v14 * 10
							local v17 = math.sin(v14 * 4 + v15.baseAngle * 3) * 7
							local v18 = v11.Position + Vector3.new(
								math.cos(v16) * numberValue.Value,
								1 + v15.yOffset + v17,
								math.sin(v16) * numberValue.Value
							)
							part.CFrame = CFrame.lookAt(v18, v11.Position) * CFrame.Angles(
								math.rad(v14 * 300),
								math.rad(v14 * 200),
								(math.rad(v14 * 100))
							)
						end
					end
				end
			end)
		end)
		task.spawn(function()
			task.wait(0.785)
			TweenService:Create(highlight, TweenInfo.new(0.25), {
				FillTransparency = 1
			}):Play()
		end)
		local lastTime = tick()
		local now2 = tick()
		local now3 = tick()
		local v11 = tick() + 0.95
		local clonesByClone = {}

		while tick() - lastTime < 0.75 do
			if now2 - tick() <= 0 then
				now2 = tick() + 0.075
				task.spawn(function()
					for _ = 1, 2 do
						local clone3 = V.Phase1.SpinTrail:Clone()
						clone3.CFrame = cFrame2 * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
						Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
						local clone4 = children[math.random(1, #children)]:Clone()
						clone4.Massless = true
						clone4.Anchored = false
						clone4.CFrame = clone3.CFrame
						clone4.Size = clone4.Size * math.random(8, 15) / 10
						Util.SetParentOverrideWithColor(clone4, clone3, v2, "MagnetFruitVFXColor")
						clone3.SpinTrail2.Weld.Part0 = clone4
						task.delay(0.15, function()
							TweenService:Create(clone4, TweenInfo.new(0.15), {
								Size = createVector(0, 0, 0)
							}):Play()
							task.wait(0.15)
							clone4:Destroy()
						end)

						for _, trail in pairs(clone3:GetDescendants()) do
							if not trail:IsA("Trail") then
								continue
							end

							trail.Enabled = true
							trail.Lifetime = math.random(1, 3) / 30
						end

						clone3.Motor6D.C0 = CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(70, 100))
						local v13 = math.random(1, 3)

						if v13 == 1 then
							local trail = clone3.Trail
							local v14 = v2
							local color = Color3.fromRGB(58, 19, 248)
							local color2 = Color3.fromRGB(35, 57, 255)

							if typeof(v14) == "Instance" and v14.Parent then
								color = WrapColor3Constructor(color, v14, "MagnetFruitVFXColor")
							end

							trail.Color = ColorSequence.new(color, RecolorMagnetColor(v14, color2))
						elseif v13 == 2 then
							local trail = clone3.Trail
							local v14 = v2
							local color = Color3.fromRGB(42, 42, 230)
							local color2 = Color3.fromRGB(67, 29, 255)

							if typeof(v14) == "Instance" and v14.Parent then
								color = WrapColor3Constructor(color, v14, "MagnetFruitVFXColor")
							end

							trail.Color = ColorSequence.new(color, RecolorMagnetColor(v14, color2))
						elseif v13 == 3 then
							local trail = clone3.Trail
							local v14 = v2
							local color = Color3.fromRGB(58, 58, 244)
							local color2 = Color3.fromRGB(25, 36, 255)

							if typeof(v14) == "Instance" and v14.Parent then
								color = WrapColor3Constructor(color, v14, "MagnetFruitVFXColor")
							end

							trail.Color = ColorSequence.new(color, RecolorMagnetColor(v14, color2))
						end

						local v14 = math.random(7, 15) / 7
						clone3.SpinTrail2.Attach0.Position = Vector3.new(v14, 0, 0)
						clone3.SpinTrail2.Attach1.Position = Vector3.new(-v14, 0, 0)
						task.spawn(function()
							TweenService:Create(
								clone3.Motor6D,
								TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									C0 = CFrame.new(0, 0, 0)
								}
							):Play()

							for i = 1, 3 do
								TweenService:Create(
									clone3,
									TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										CFrame = clone3.CFrame * CFrame.Angles(0, 0.8726646259971648, 0)
									}
								):Play()
								task.wait(0.05)
							end
						end)
					end
				end)
				task.spawn(function()
					for _ = 1, math.random(2, 3) do
						local clone3 = children[math.random(1, #children)]:Clone()
						local v12 = cFrame2.Position + Vector3.new(
							math.random(-50, 50),
							math.random(-15, 50),
							math.random(-50, 50)
						)
						clone3.CFrame = CFrame.new(v12)
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Size = clone3.Size * math.random(150, 200) / 100
						Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
						clonesByClone[clone3] = clone3
						local clone4 = V.Phase1.AuraModel:Clone()
						clone4.PrimaryPart.Anchored = false
						clone4.PrimaryPart.Weld.Part1 = clone3
						Util.SetParentOverrideWithColor(clone4, clone3, v2, "MagnetFruitVFXColor")
						local position = cFrame2.Position
						local v13 = (v12 + position) / 2 + Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)
						local v14 = math.random(15, 30) / 100
						local heartbeatConnection = nil
						local folder2 = clone3
						local v15 = tick()
						heartbeatConnection = RunService.Heartbeat:Connect(function()
							if not (folder2 and folder2.Parent) then
								heartbeatConnection:Disconnect()
								return
							end

							local v20 = (tick() - v15) / v14

							if v20 >= 1 then
								for i, effect in pairs(folder2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end

								heartbeatConnection:Disconnect()
								local part = root

								if part then
									folder2.CFrame = part.CFrame * CFrame.new(
										math.random(-15, 15),
										math.random(-10, 10),
										math.random(-15, 15)
									) * CFrame.Angles(
										math.rad((math.random(-180, 180))),
										math.rad((math.random(-180, 180))),
										(math.rad((math.random(-180, 180))))
									)
									folder2.Anchored = false
									local weldConstraint = Instance.new("WeldConstraint")
									weldConstraint.Part0 = folder2
									weldConstraint.Part1 = part
									weldConstraint.Parent = folder2
									task.delay(v11 - tick(), function()
										if not (folder2 and folder2.Parent) then
											return
										end

										weldConstraint:Destroy()
										folder2.AssemblyLinearVelocity = (folder2.Position - part.Position).Unit * math.random(
											80,
											160
										) + Vector3.new(math.random(-30, 30), math.random(20, 60), math.random(-30, 30))
										folder2.AssemblyAngularVelocity = Vector3.new(
											math.random(-25, 25),
											math.random(-25, 25),
											math.random(-25, 25)
										)
										task.delay(0.5 + math.random() * 0.5, function()
											if folder2 and folder2.Parent then
												TweenService:Create(folder2, TweenInfo.new(0.15), {
													Size = createVector(0, 0, 0)
												}):Play()
												task.delay(0.25, function()
													folder2:Destroy()
												end)
											end
										end)
									end)
								end
							else
								local v21 = v20 ^ 1.5
								local v25 = (1 - v21) ^ 2 * v12 + 2 * (1 - v21) * v21 * v13 + v21 ^ 2 * position
								folder2.CFrame = CFrame.lookAt(v25, position) * CFrame.Angles(
									math.rad(v20 * 720),
									math.rad(v20 * 540),
									(math.rad(v20 * 360))
								)
								local v26 = 1 - v20
								folder2.Size *= 0.99
							end
						end)
					end
				end)
			end

			if now3 - tick() <= 0 then
				now3 = tick() + 0.1
				task.spawn(function()
					for i = 1, 5 do
						local v12 = i
						task.spawn(function()
							local clone3 = script.Part:Clone()
							local cFrame3 = CFrame.new(cFrame2.Position) * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							clone3.CFrame = cFrame3
							Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
							clone3.Attach1.WorldPosition = cFrame3 * CFrame.new(0, 0, 40 * math.random(12, 20) / 10).Position
							local shafiBolt = ShafiBolt(
								clone3.Attach0,
								clone3.Attach1,
								math.random(8, 12) * 1,
								0.5,
								folder
							)
							shafiBolt.Frequency = math.random(5, 10) * 2
							shafiBolt.MaxRadius = 12
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							local v15 = v2
							local color = Color3.fromRGB(28, 28, 255)

							if typeof(v15) == "Instance" and v15.Parent then
								color = WrapColor3Constructor(color, v15, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color

							if v12 % 2 == 0 then
								local v16 = v2
								local color2 = Color3.fromRGB(83, 48, 255)

								if typeof(v16) == "Instance" and v16.Parent then
									color2 = WrapColor3Constructor(color2, v16, "MagnetFruitVFXColor")
								end

								shafiBolt.Color = color2
							end

							task.spawn(function()
								task.wait(0.05 + math.random() * 0.115)
								shafiBolt:Destroy()
							end)
						end)
					end
				end)
			end

			task.wait()
		end

		task.wait(0.1)
		task.spawn(function()
			local clone3 = V.Phase3.Sphere:Clone()
			clone3.Size = createVector(32.5, 32.5, 32.5)
			clone3.CFrame = CFrame.new(
				cFrame2.Position + createVector(0, 15, 0),
				workspace.CurrentCamera.CFrame.Position
			) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
			task.spawn(function()
				TweenService:Create(clone3, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = clone3.Size * 3.7
				}):Play()

				for _, decal in pairs(clone3:GetDescendants()) do
					if not decal:IsA("Decal") then
						continue
					end

					decal.Transparency = 0.5
					TweenService:Create(decal, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Transparency = 1
					}):Play()
				end
			end)
			task.spawn(function()
				local clone4 = V.Phase3.Sphere1:Clone()
				clone4.Size = createVector(32.5, 32.5, 32.5)
				clone4.CFrame = CFrame.new(
					cFrame2.Position + createVector(0, 15, 0),
					workspace.CurrentCamera.CFrame.Position
				) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
				Util.SetParentOverrideWithColor(clone4, folder, v2, "MagnetFruitVFXColor")
				task.spawn(function()
					TweenService:Create(clone4, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = clone4.Size * 3.7
					}):Play()

					for _, decal in pairs(clone4:GetDescendants()) do
						if not decal:IsA("Decal") then
							continue
						end

						decal.Transparency = 0.5
						TweenService:Create(
							decal,
							TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								Transparency = 1,
								StudsPerTileU = math.random(15, 20) * 2,
								StudsPerTileV = math.random(15, 20) * 2
							}
						):Play()
					end
				end)
			end)
			task.spawn(function()
				for i = 1, 10 do
					local v12 = i
					task.spawn(function()
						local clone4 = script.Part:Clone()
						local cFrame3 = CFrame.new(cFrame2.Position) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 10),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 10))
						) * CFrame.new(0, 0, -62.5)
						clone4.CFrame = cFrame3
						Util.SetParentOverrideWithColor(clone4, folder, v2, "MagnetFruitVFXColor")
						clone4.Attach1.WorldPosition = cFrame3 * CFrame.new(0, 0, 125).Position
						local shafiBolt = ShafiBolt(
							clone4.Attach0,
							clone4.Attach1,
							math.random(8, 12) * 1.25,
							0.5,
							folder
						)
						shafiBolt.CurveSize0 = -90
						shafiBolt.CurveSize1 = 90
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v15 = v2
						local color = Color3.fromRGB(51, 54, 255)

						if typeof(v15) == "Instance" and v15.Parent then
							color = WrapColor3Constructor(color, v15, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v12 % 2 == 0 then
							local v16 = v2
							local color2 = Color3.fromRGB(71, 80, 255)

							if typeof(v16) == "Instance" and v16.Parent then
								color2 = WrapColor3Constructor(color2, v16, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
							shafiBolt.Thickness = 1
						end

						task.spawn(function()
							task.wait(0.15 + math.random() * 0.1)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
		end)
		local clone3 = V.Phase3.ExplosionFinalModel:Clone()
		clone3:ScaleTo(1.5)
		local primaryPart = clone3.PrimaryPart
		primaryPart.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone3, folder, v2, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(primaryPart) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v12 = emitter
			task.spawn(function()
				if v12:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v12:GetAttribute("EmitDelay"))
				end

				local lifetime = v12.Lifetime
				v12.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				v12:Emit(v12:GetAttribute("EmitCount") * 1.25)
			end)
		end

		task.spawn(function()
			for _, part in pairs(rig:GetChildren()) do
				if not (part ~= rig.PrimaryPart and part:IsA("BasePart")) then
					continue
				end

				part:SetAttribute("TrueTransparency", 1)
				part.Transparency = 0
			end

			fakeRig:Destroy()
		end)
		local v12 = now + 3.3333333333333335

		if tick() < v12 then
			task.wait(v12 - tick())
		end

		local humanoid = parent:FindFirstChildOfClass("Humanoid")
		local v13 = root.Size.Y * 0.5 + (humanoid and humanoid.HipHeight or 0)
		local v14 = (downDist or upDist) - v13
		local v15 = math.max(v14 / 350, 0.1)
		local cFrame4 = cFrame2 * CFrame.new(0, -v14, 0)
		local tween = TweenService:Create(root, TweenInfo.new(v15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = cFrame4
		})
		tween:Play()
		tween.Completed:Wait()

		if v10 then
			v10:Stop()
		end

		if v9 then
			v9:Stop()
		end

		if not data.IsNpc then
			local player4 = data.Player
			local v17

			if typeof(player4) == "Instance" then
				local magnetFruitVFXColor = player4:FindFirstChild("MagnetFruitVFXColor")

				if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
					v17 = true
				else
					local character = player4.Character
					local primaryPart2 = character and character.PrimaryPart
					v17 = primaryPart2 and primaryPart2:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" and true or false
				end
			else
				v17 = false
			end

			local v18 = v17 and Util.Anims:Get(rig, "Transformed Arcsteel Transformation Landing") or Util.Anims:Get(
				rig,
				"Magnet Mech Transformation Landing"
			)
			v18.Looped = false
			v18:Play()
		end

		local raycastResult = workspace:Raycast(cFrame4.Position, Vector3.new(0, -(v13 + 10), 0), raycastParams)
		local cFrame5 = raycastResult and AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01 or CFrame.new(cFrame4.Position - Vector3.new(
			0,
			v13,
			0
		))
		local clone4 = V.Phase2.LandImpact:Clone()
		clone4.CFrame = cFrame5
		Util.SetParentOverrideWithColor(clone4, folder, v2, "MagnetFruitVFXColor")

		if (workspace.CurrentCamera.CFrame.p - cFrame5.Position).Magnitude < 150 then
			Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
		end

		Util.Sound:Play("Magnet_Transformation_Explode_Ground_Land_02", clone4.Position)

		if player == game.Players.LocalPlayer or (workspace.CurrentCamera.CFrame.Position - clone4.Position).Magnitude < 175 then
			Util.CameraShaker:ShakeOnce(3, 6, 0.1, 0.6, createVector(2, 3, 2), createVector(3, 2, 3))
		end

		DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Explosion(cFrame5, folder, raycastParams)
		task.spawn(function()
			local clone5 = V.Phase2.SpinSlash:Clone()
			clone5:PivotTo(cFrame5 * CFrame.Angles(1.5707963267948966, 0, 0))
			Util.SetParentOverrideWithColor(clone5, folder, v2, "MagnetFruitVFXColor")
			local model2 = clone5.Model2

			for i = 1, 7 do
				local v19 = 1
				local clone6 = model2:Clone()
				local v20 = 0.35

				if i ~= 1 then
					if i == 2 then
						v19 = 0.95
						v20 = 0.25
					elseif i == 3 then
						v19 = 0.9
						v20 = 0.15
					elseif i == 4 then
						v19 = 0.85
						v20 = 0.35
					elseif i == 5 then
						v19 = 0.8
						v20 = 0.25
					end
				end

				clone6:ScaleTo((i * 0.7 + 5.75) / v19)

				for _, beam in pairs(clone6:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					beam.Width0 *= 0.15
					beam.Width1 *= 0.15
				end

				local primaryPart2 = clone6.PrimaryPart
				local v21 = clone5.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-180, 180) / 15),
					math.rad(math.random(-180, 180) / 15),
					(math.rad(math.random(-180, 180) / 1))
				)

				if i > 5 then
					v21 = clone5.PrimaryPart.CFrame * CFrame.Angles(
						math.rad(math.random(-180, 180) / 1),
						math.rad(math.random(-180, 180) / 1),
						(math.rad(math.random(-180, 180) / 1))
					)
					v20 = 0.25
				end

				local angularVelocity = primaryPart2.AngularVelocity
				primaryPart2.Anchored = false
				primaryPart2.AlignPosition.Position = primaryPart2.Position
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 15)
				clone6:PivotTo(v21)
				Util.SetParentOverrideWithColor(clone6, clone5, v2, "MagnetFruitVFXColor")
				clone6:GetScale()
				task.spawn(function()
					TweenService:Create(
						angularVelocity,
						TweenInfo.new(2.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
								math.random(-5, 5) / 5,
								math.random(-5, 5) / 5,
								math.random(5, 10)
							)
						}
					):Play()
					task.wait(0.05 * math.random() + v20 * 0.35)

					for i2, effect in pairs(clone6:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(1 / v19 + math.random() * 0.075 / v19), {
								Width0 = effect.Width0 * 2,
								Width1 = effect.Width1 * 2
							}):Play()
							local v23 = effect
							task.delay(1, function()
								v23:Destroy()
							end)
							local v24 = effect
							task.spawn(function()
								for i3 = 90, 100 do
									v24.Transparency = NumberSequence.new(i3 / 100, i3 / 100)
									task.wait(0.025)
								end
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
				end)
			end

			task.spawn(function()
				local v18 = clone5:GetScale() * 0.425
				local v19 = v18 * 1.75

				for i = v18 * 100, v19 * 100, 3.5 do
					clone5:ScaleTo(i / 100)
					task.wait(0.005)
				end

				local v20 = clone5:GetScale() * 1
				local v21 = v20 * 1.25

				for i = v20 * 100, v21 * 100 do
					clone5:ScaleTo(i / 100)
					task.wait(0.01)
				end
			end)
		end)
		root.Anchored = false
		local phase0 = V.Phase0
		local primaryPart2 = rig.PrimaryPart

		for i = 1, 2 do
			for i2 = 1, 3 do
				local v18 = i2
				local v19 = i
				task.spawn(function()
					local part = nil
					local cframe = CFrame.new(0, 10, 0)

					if v18 == 1 then
						cframe = CFrame.new(0, 10, 0)

						if v19 == 1 then
							local v22

							if hasCrimsonGoldSkin(player, rig) then
								v22 = primaryPart2:FindFirstChild("ArcAPipeR", true)
							else
								v22 = primaryPart2["APipe4.R"]
							end

							part = makeProxyPartAtBone(v22, rig)
						else
							local v22

							if hasCrimsonGoldSkin(player, rig) then
								v22 = primaryPart2:FindFirstChild("ArcAPipeL", true)
							else
								v22 = primaryPart2["APipe4.L"]
							end

							part = makeProxyPartAtBone(v22, rig)
						end
					elseif v18 == 2 then
						cframe = CFrame.new(0, 4.25, 0)

						if v19 == 1 then
							local v22

							if hasCrimsonGoldSkin(player, rig) then
								v22 = primaryPart2:FindFirstChild("ArcBPipeR", true)
							else
								v22 = primaryPart2["BPipe3.R"]
							end

							part = makeProxyPartAtBone(v22, rig)
						else
							local v22

							if hasCrimsonGoldSkin(player, rig) then
								v22 = primaryPart2:FindFirstChild("ArcBPipeL", true)
							else
								v22 = primaryPart2["BPipe3.L"]
							end

							part = makeProxyPartAtBone(v22, rig)
						end
					elseif v18 == 3 then
						cframe = CFrame.new(0, 3.5, 0)

						if v19 == 1 then
							local v22

							if hasCrimsonGoldSkin(player, rig) then
								v22 = primaryPart2:FindFirstChild("ArcCPipeR", true)
							else
								v22 = primaryPart2["CPipe3.R"]
							end

							part = makeProxyPartAtBone(v22, rig)
						else
							local v22

							if hasCrimsonGoldSkin(player, rig) then
								v22 = primaryPart2:FindFirstChild("ArcCPipeL", true)
							else
								v22 = primaryPart2["CPipe3.L"]
							end

							part = makeProxyPartAtBone(v22, rig)
						end
					end

					if hasCrimsonGoldSkin(player, rig) then
						cframe = CFrame.new(0, 0, 0)
					end

					local clone5 = phase0.PipeAura:Clone()
					clone5.CFrame = part.CFrame
					Util.SetParentOverrideWithColor(clone5, rig, v2, "MagnetFruitVFXColor")
					clone5.Anchored = false
					clone5.Massless = true
					clone5.Weld.Part0 = part
					clone5.Weld.C1 = cframe

					for i3, emitter in pairs(clone5:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end)
			end
		end

		task.spawn(function()
			local proxyPartAtBone = makeProxyPartAtBone(primaryPart2:FindFirstChild("BackCog", true), rig)
			local cframe = CFrame.new(0, 0, 0)
			local clone5 = phase0.CogSpark:Clone()
			clone5.CFrame = proxyPartAtBone.CFrame
			Util.SetParentOverrideWithColor(clone5, rig, v2, "MagnetFruitVFXColor")
			clone5.Anchored = false
			clone5.Massless = true
			clone5.Weld.Part0 = proxyPartAtBone
			clone5.Weld.C1 = cframe

			for _, emitter in pairs(clone5:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end)

		for i = 1, 2 do
			local v18 = i
			task.spawn(function()
				if hasCrimsonGoldSkin(player, rig) then
				end

				local cframe = CFrame.new(0, 0, 3)
				local part

				if v18 == 1 then
					part = makeProxyPartAtBone(primaryPart2:FindFirstChild("LowerArm3.R", true), rig)
				else
					part = makeProxyPartAtBone(primaryPart2:FindFirstChild("LowerArm3.L", true), rig)
				end

				local clone5 = phase0.ArmAura:Clone()
				clone5.CFrame = part.CFrame
				Util.SetParentOverrideWithColor(clone5, rig, v2, "MagnetFruitVFXColor")
				clone5.Anchored = false
				clone5.Massless = true
				clone5.Weld.Part0 = part
				clone5.Weld.C1 = cframe

				for i2, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end)
		end
	end)
end