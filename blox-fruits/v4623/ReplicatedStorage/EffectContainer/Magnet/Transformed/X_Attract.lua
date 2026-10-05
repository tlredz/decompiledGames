local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local x_Attract = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("X_Attract")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local v = {
	ScrapModelA = "ArcsteelScrapModelA",
	ScrapModelA2 = "ArcsteelScrapModelB"
}

local function hasCrimsonGoldSkin(player)
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
local rocks = CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(player, color)
	if typeof(player) == "Instance" and player.Parent then
		return WrapColor3Constructor(color, player, "MagnetFruitVFXColor")
	end

	return color
end

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

local function QuadBezier(p, p2, p3, p4)
	return p:Lerp(p2, p4):Lerp(p2:Lerp(p3, p4), p4)
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

local function EndOrbit(folder, position)
	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end

	folder.Anchored = false
	folder.CanCollide = true
	local unit = (folder.Position - position).Unit
	local vector2 = Vector3.new(math.random(-30, 30), math.random(15, 40), math.random(-30, 30))
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Velocity = unit * math.random(70, 100) + vector2 * 1.5
	bodyVelocity.Parent = folder
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = createVector(100000, 100000, 100000)
	bodyAngularVelocity.AngularVelocity = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
	bodyAngularVelocity.Parent = folder
	task.delay(0.25, function()
		if bodyVelocity then
			bodyVelocity:Destroy()
		end

		if bodyAngularVelocity then
			bodyAngularVelocity:Destroy()
		end

		if folder:FindFirstChild("Highlight") then
			folder.Highlight.Enabled = false
		end

		task.wait(1 + math.random() * 0.5)
		TweenService:Create(folder, TweenInfo.new(0.25), {
			Size = createVector(0, 0, 0)
		}):Play()
		task.delay(0.25, function()
			folder:Destroy()
		end)
	end)
end

local function StartOrbit(folder, clone, p, p2, player, p3)
	for _, effect in pairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local unit = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)).Unit
	local v2 = math.random() * 3.141592653589793 * 2
	local v3 = p2 * (math.random(80, 140) / 100)

	if math.random() < 0.5 then
		v3 = -v3
	end

	local cross = unit:Cross(createVector(0, 1, 0))

	if cross.Magnitude < 0.1 then
		cross = unit:Cross(createVector(1, 0, 0))
	end

	local unit2 = cross.Unit
	local v4 = p
	local v5 = not (p3 and p3.Model) and createVector(0, 0, -1) or p3.Model.PrimaryPart.CFrame.LookVector
	local v6 = false
	local v7 = 1
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local position = clone.Position

		if not (folder and folder.Parent) then
			heartbeatConnection:Disconnect()
			return
		end

		if clone:GetAttribute("Spread") == true and v6 == false then
			v6 = true
			p *= 2
			v3 *= 0.85
			v7 = 2
		end

		v2 += v3 * dt

		if clone:GetAttribute("End") == true then
			heartbeatConnection:Disconnect()
			local clone2 = x_Attract.Phase1.EndImpact:Clone()
			clone2.CFrame = CFrame.new(folder.Position, position)
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			EndOrbit(folder, position)
		else
			local v8 = position + v5 * 60 * dt
			local v9 = p * v7
			v4 += (v9 - v4) * math.clamp(dt * 6, 0, 1)
			local v10 = v8 + CFrame.fromAxisAngle(unit, v2):VectorToWorldSpace(unit2 * v4)
			folder.CFrame = CFrame.lookAt(v10, v8)
		end
	end)
end

local function AlignCFrame(data, normal)
	local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p, unit2, v2, unit3)
end

local function Explosion(p, folder, raycastParams, player)
	local function Scale(instance, p2)
		local position = p.Position

		if instance.ClassName ~= "Model" then
			local model = Instance.new("Model")
			model.Parent = instance.Parent
			instance.Parent = model
			instance = model
		end

		instance:ScaleTo(p2)
		local v2 = position + (instance:GetPivot().Position - position) * p2
		instance:PivotTo(instance:GetPivot().Rotation + v2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(clone, duration)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end

	local function cameraShakeAt(_, _, _, _, _, _) end

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
				v5.CFrame = CFrame.new(v5.Position, p2.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-150, 250) / 7
				)
				local ray = Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local part, v6 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

				if part then
					local v7 = (v5.Position - p2.Position).Magnitude / 200
					local v8 = size * math.random(20, 40) / 10
					local v9 = size * math.random(10, 30) / 10
					local v10 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v8 * v7, v9 * v7, v10 * v7)
					v5.Position = v6 + Vector3.new(0, -v5.Size.Y * math.random(5, 6) / 15, 0)
					v5.CFrame = CFrame.new(v5.Position, p2.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 3,
						math.random(-25, 25) / 2
					)
					v5.CFrame = CFrame.new(
						v5.Position,
						v2.Position + Vector3.new(0, math.random(-55, -45) / 100 + v5.Size.Y / 200, 0)
					) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v7), 0, 0) * CFrame.Angles(
						0,
						0,
						(math.rad((math.random(-5, 5))))
					)
					v5.Material = part.Material
					v5.Color = part.Color
				else
					v5:Destroy()
					v3[v5] = nil
				end

				TweenService:Create(v5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v5.Position + Vector3.new(0, v5.Size.Y * math.random(3, 5) / 10, 0)
				}):Play()
				local v7 = v5
				local v8 = v5
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v7,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v7.Position + Vector3.new(
								math.random(-1, 1),
								-v7.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v7:Destroy()
					v3[v7] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local clone = x_Attract.Phase3.Rock:Clone()
		rocks:ApplyCollision(clone, nil, true)
		clone.CFrame = cFrame
		clone.Size *= 2.25
		clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		clone.Size *= math.random(3, 5) / 3
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = raycastResult.Instance.Material
		clone.Color = raycastResult.Instance.Color
		clone.CanCollide = false
		clone.Parent = parent
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 50000
		bodyVelocity.Parent = clone
		local vector2 = Vector3.new(math.random(-30, 30) * 20, 0, math.random(-30, 30) * 20)
		local vector3 = Vector3.new(0, math.random(700, 1000) * 1.5, 0)
		local v2 = math.random(70, 100) * 1.25
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(1 * math.random() + 1.5, function()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Size = createVector(0, 0, 0)
			}):Play()
		end)
		task.delay(0.015 * math.random() + 0.015, function()
			bodyVelocity:Destroy()
			task.wait(0.1)
			clone.CanCollide = true
		end)
	end

	task.spawn(function() end)
	local raycastResult = workspace:Raycast(
		p.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if not raycastResult then
		return
	end

	local cFrame2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
	local v3 = {
		Radius = 93.75,
		Size = 15,
		Duration = 0.75,
		Amount = 35,
		RockType = x_Attract.Phase3.CraterRock
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
			v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-150, 250) / 7
			)
			local ray = Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v8 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

			if part then
				local v9 = (v7.Position - raycastResult.Position).Magnitude / 200
				local v10 = size * math.random(20, 40) / 10
				local v11 = size * math.random(10, 30) / 10
				local v12 = size * math.random(30, 50) / 10
				v7.Size = Vector3.new(v10 * v9, v11 * v9, v12 * v9)
				v7.Position = v8 + Vector3.new(0, -v7.Size.Y * math.random(5, 6) / 15, 0)
				v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-25, 25) / 2
				)
				v7.CFrame = CFrame.new(
					v7.Position,
					v4.Position + Vector3.new(0, math.random(-55, -45) / 100 + v7.Size.Y / 200, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 1 - 60 * v9), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v7.Material = part.Material
				v7.Color = part.Color
			else
				v7:Destroy()
				v5[v7] = nil
			end

			TweenService:Create(v7, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = v7.Position + Vector3.new(0, v7.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v9 = v7
			local v10 = v7
			task.spawn(function()
				task.wait(duration + math.random(10, 35) / 100)
				local tween = TweenService:Create(
					v9,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v9.Position + Vector3.new(
							math.random(-1, 1),
							-v9.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v9:Destroy()
				v5[v9] = nil
			end)
		end
	end)
	task.spawn(function()
		for i = 1, 20 do
			task.spawn(function()
				FlyRock(
					cFrame2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						0,
						-math.random(125, 150) / 1.5
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
	task.spawn(function()
		local clone = x_Attract.Phase2.GroundCrack:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.spawn(function()
				if v4:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v4:GetAttribute("EmitDelay"))
				end

				v4:Emit(v4:GetAttribute("EmitCount"))
			end)
		end
	end)
	return raycastResult
end

local function dissolveOrphanedVisuals(folder)
	local v2 = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Highlight") then
			descendant.Enabled = false
		elseif descendant:IsA("BasePart") then
			if descendant:GetAttribute("XOrbitCube") or descendant:GetAttribute("XOrbitMini") then
				descendant.Anchored = false
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
				descendant.AssemblyLinearVelocity = Vector3.new(
					math.random(-30, 30) / 5,
					math.random(0, 15) / 5,
					math.random(-30, 30) / 5
				)
				table.insert(v2, {
					Part = descendant,
					Size = descendant.Size
				})
			else
				TweenService:Create(descendant, TweenInfo.new(1), {
					Transparency = 1
				}):Play()
			end
		end
	end

	task.spawn(function()
		local lastTime = tick()

		while tick() - lastTime < 1 do
			local v3 = math.max(1 - math.clamp((tick() - lastTime) / 1, 0, 1), 0.05)

			for _, v4 in v2 do
				if v4.Part.Parent then
					v4.Part.Size = v4.Size * v3
				end
			end

			task.wait()
		end

		if folder.Parent then
			folder:Destroy()
		end
	end)
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local stage = data.Stage
	local root = data.Root
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

	if stage == 1 then
		local holding = data.Holding
		local name = data.Player.Name .. "_MagnetXTransformed"
		local child = _WorldOrigin:FindFirstChild(name)

		if child then
			child:Destroy()
		end

		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 15)
		local cframe = CFrame.new(0, 0, -12)
		local cframe2 = root.CFrame * cframe
		local v3 = {}
		local v4 = tick() + data.Windup
		local clone = x_Attract.Phase1.MagnetModel:Clone()
		clone.Cube1.Transparency = 1
		clone.Cube2.Transparency = 1
		clone.Cube3.Transparency = 1
		clone:PivotTo(cframe2)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Transformed_X_Tap_Suction_In_01", root)
		local v5 = Util.Sound:Play("Magnet_Transformed_X_Tap_Suction_Loop_01", root)
		TweenService:Create(v5, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		task.spawn(function()
			local v6 = clone

			local function makeProxyPartAtBone(attachment, _, cframe3: CFrame?)
				local cFrame = cframe3 or CFrame.new()
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
				part.Parent = v6.RootPart
				return part
			end

			for _, child2 in pairs(clone.RootPart.AbsoluteController:GetChildren()) do
				local v7 = clone.RootPart.AbsoluteController[child2.Name]

				for _, child3 in pairs(child2:GetChildren()) do
					local proxyPartAtBone = makeProxyPartAtBone(v7[child3.Name])
					local clone2 = x_Attract.Phase1.AuraModel:Clone()
					clone2.PrimaryPart.Anchored = false
					clone2.PrimaryPart.Weld.Part0 = proxyPartAtBone
					clone2.PrimaryPart.Weld.Part1 = clone2.PrimaryPart
					clone2:ScaleTo(2)
					Util.SetParentOverrideWithColor(clone2, clone.Cube1, player, "MagnetFruitVFXColor")

					for _, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("Trail") then
							effect.Enabled = true
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end
			end
		end)
		local v6 = Util.Anims:Get(clone, "Transformed Magnet Mech X Tap Metal Start")
		v6.Priority = Enum.AnimationPriority.Action4
		v6:Play()
		local scrapModelA

		if hasCrimsonGoldSkin(data.Player) then
			local scrapModelA2 = v.ScrapModelA
			scrapModelA = scrapModelA2 and scraps:FindFirstChild(scrapModelA2)

			if not scrapModelA then
				scrapModelA = scraps:FindFirstChild("ScrapModelA")
			end
		else
			scrapModelA = scraps:FindFirstChild("ScrapModelA")
		end

		scrapModelA:ScaleTo(3.25)
		local children = scrapModelA:GetChildren()
		local primaryPartsByPrimaryPart = {}
		local clonesByClone = {}

		for _ = 1, 10 do
			task.spawn(function()
				local clone2 = x_Attract.Phase1.Cube:Clone()
				clone2:ScaleTo(1 + math.random(10, 15) / 10)
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
				primaryPartsByPrimaryPart[clone2.PrimaryPart] = clone2.PrimaryPart
				clone2.PrimaryPart:SetAttribute("XOrbitCube", true)
				local primaryPart = clone2.PrimaryPart
				local clone3 = x_Attract.Phase1.Highlight:Clone()
				Util.SetParentOverrideWithColor(clone3, primaryPart, player, "MagnetFruitVFXColor")
				clone3.Enabled = true
				local clone4 = x_Attract.Phase1.BigAuraModel:Clone()
				clone4.PrimaryPart.Anchored = false
				clone4.PrimaryPart.Weld.Part1 = primaryPart
				clone4:ScaleTo(clone2:GetScale() / 1.5)
				Util.SetParentOverrideWithColor(clone4, primaryPart, player, "MagnetFruitVFXColor")

				for _, effect in pairs(clone4:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true

					if effect:IsA("ParticleEmitter") then
						effect.Rate *= 0.5
					end
				end

				local clone5 = children[math.random(1, #children)]:Clone()
				clone5.Size *= 0.7
				Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
				clonesByClone[clone5] = clone5
				clone5:SetAttribute("XOrbitMini", true)
				local clone6 = x_Attract.Phase1.Highlight:Clone()
				Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
				clone6.Enabled = true

				for i = 1, 2 do
					local v7 = i
					task.spawn(function()
						local v8 = cframe2
						local primaryPart2 = clone2.PrimaryPart

						if v7 == 2 then
							primaryPart2 = clone5
						end

						local v9 = math.rad((math.random(-45, 45)))
						local v10 = math.rad((math.random(-22.5, 22.5)))
						local lookVector = (v8 * CFrame.Angles(v10, v9, 0)).LookVector
						local v11 = v8.Position + lookVector * 100
						local vector2 = Vector3.new(
							math.random(-15, 15) * 2,
							math.random(-10, 25) * 2,
							math.random(-15, 15) * 2
						)
						local v12 = cframe2.Position + cframe2.LookVector * 10
						local v13 = (v11 + v12) / 2 + vector2
						primaryPart2.CFrame = CFrame.new(v11)
						local lastTime = tick()
						local v14 = false
						local heartbeatConnection = nil
						local RunService2 = game:GetService("RunService")
						heartbeatConnection = RunService2.Heartbeat:Connect(function()
							local v15 = (tick() - lastTime) / 0.25
							v12 = cframe2.Position + cframe2.LookVector * 10
							v13 = (v11 + v12) / 2 + vector2

							if v15 >= 1 then
								clone6:Destroy()
								v3[primaryPart2] = cframe2:Inverse() * primaryPart2.CFrame
								heartbeatConnection:Disconnect()
							else
								if v15 > 0.925 and v14 == false then
									v14 = true

									for i2, effect in pairs(primaryPart2:GetDescendants()) do
										if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
											effect.Enabled = false
										end
									end
								end

								local v16 = (1 - v15) ^ 2 * v11 + 2 * (1 - v15) * v15 * v13 + v15 ^ 2 * v12
								local v17 = math.clamp(v15 + 0.02, 0, 1)
								local unit = ((1 - v17) ^ 2 * v11 + (1 - v17) * 2 * v17 * v13 + v17 ^ 2 * v12 - v16).Unit
								primaryPart2.CFrame = CFrame.lookAt(v16, v16 + unit)
							end
						end)
					end)
				end
			end)
		end

		task.spawn(function()
			local v7 = 25

			for i = 1, 10 do
				local v8 = i
				task.spawn(function()
					v7 = math.random(-50, 50)
					local clone2 = children[math.random(1, #children)]:Clone()
					clone2.Size *= 0.7
					Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
					clonesByClone[clone2] = clone2
					clone2:SetAttribute("XOrbitMini", true)
					local clone3 = x_Attract.Phase1.Highlight:Clone()
					Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
					clone3.Enabled = true
					local clone4 = x_Attract.Phase1.AuraModel:Clone()
					clone4.PrimaryPart.Anchored = false
					clone4.PrimaryPart.Weld.Part1 = clone2
					clone4:ScaleTo(2)
					Util.SetParentOverrideWithColor(clone4, clone2, player, "MagnetFruitVFXColor")

					for i2, effect in pairs(clone4:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					local v9 = cframe2
					local v10 = (v8 - 1) / 9 * 2 - 1
					local v11 = math.rad(v10 * 65)
					local v12 = math.rad((math.random(-16.25, 16.25)))
					local lookVector = (v9 * CFrame.Angles(v12, v11, 0)).LookVector
					local v13 = v9.Position + lookVector * 100
					local v14 = -v10 * 25
					local vector2 = Vector3.new(math.random(-15, 15), math.random(-15, 15), 0)
					local v15 = cframe2.Position + cframe2.LookVector * 1.5 + cframe2.RightVector * (v10 * 5)
					local v17 = (v13 + v15) / 2 + cframe2.LookVector * 30 + cframe2.RightVector * v14 + vector2
					clone2.CFrame = CFrame.new(v13)
					local lastTime = tick()
					local v18 = false
					local heartbeatConnection = nil
					local RunService2 = game:GetService("RunService")
					heartbeatConnection = RunService2.Heartbeat:Connect(function()
						local v19 = (tick() - lastTime) / 0.26
						v15 = cframe2.Position + cframe2.LookVector * 1.5 + cframe2.RightVector * (v10 * 5)
						v17 = (v13 + v15) / 2 + cframe2.LookVector * 30 + cframe2.RightVector * v14 + vector2

						if v19 >= 1 then
							clone3:Destroy()
							v3[clone2] = cframe2:Inverse() * clone2.CFrame
							heartbeatConnection:Disconnect()
						else
							if v19 > 0.95 and not v18 then
								v18 = true

								for i2, effect in pairs(clone2:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end
							end

							local v20 = (1 - v19) ^ 2 * v13 + 2 * (1 - v19) * v19 * v17 + v19 ^ 2 * v15 + Vector3.new(
								0,
								-0 * v19 ^ 2,
								0
							)
							local v21 = math.clamp(v19 + 0.02, 0, 1)
							local unit = ((1 - v21) ^ 2 * v13 + (1 - v21) * 2 * v21 * v17 + v21 ^ 2 * v15 + Vector3.new(
								0,
								v21 ^ 2 * -0,
								0
							) - v20).Unit
							clone2.CFrame = CFrame.lookAt(v20, v20 + unit)
						end
					end)
				end)
			end
		end)
		Util.Anims:Get(clone, "Transformed Magnet Mech X Tap Metal Loop"):Play()

		while not root:FindFirstChild("MagnetXTransformedTrigger") and (holding and holding.Value or not (v4 < tick())) do
			cframe2 = root.CFrame * cframe

			if clone and clone.Parent then
				clone:PivotTo(cframe2)
			end

			for k, v7 in pairs(v3) do
				if k and k.Parent then
					k.CFrame = cframe2 * v7
				else
					v3[k] = nil
				end
			end

			task.wait()
		end

		if v5 then
			Util.Sound:FadeOut(v5, 0.2)
		end

		task.delay(1.5, function()
			if folder.Parent and folder.Name == name then
				dissolveOrphanedVisuals(folder)
			end
		end)

		if v6 then
			v6:Stop()
		end
	elseif stage == 2 then
		local folder = workspace._WorldOrigin:FindFirstChild(data.Player.Name .. "_MagnetXTransformed")

		if not folder then
			return
		end

		folder.Name = "DESTROYING"
		local startCFrame = data.StartCFrame
		local magnetModel = folder.MagnetModel
		local clone = x_Attract.Phase1.Projectile:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		magnetModel.Cube1:Destroy()
		magnetModel.Cube2:Destroy()
		magnetModel.Cube3:Destroy()
		local weld = Instance.new("Weld")
		weld.Part0 = magnetModel.PrimaryPart
		weld.Parent = magnetModel
		magnetModel.PrimaryPart.Anchored = false
		magnetModel.PrimaryPart.Massless = true
		weld.Part1 = clone
		local descendantsByDescendant = {}
		local descendantsByDescendant2 = {}

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:GetAttribute("XOrbitCube") then
				descendantsByDescendant[descendant] = descendant
			elseif descendant:GetAttribute("XOrbitMini") then
				descendantsByDescendant2[descendant] = descendant
			end
		end

		for _, v2 in pairs(descendantsByDescendant2) do
			StartOrbit(v2, clone, math.random(12, 15) * 1.25, math.random(7, 9), player)
		end

		for _, v2 in pairs(descendantsByDescendant) do
			StartOrbit(v2, clone, math.random(12, 15) * 1.75, math.random(7, 9), player)
		end

		local travelTime = data.TravelTime
		local magnitude = (data.TargetPosition - startCFrame.Position).Magnitude
		local cFrame = startCFrame * CFrame.new(0, 0, -magnitude)
		local clone2 = x_Attract.Phase1.StartImpact:Clone()
		clone2.CFrame = startCFrame * CFrame.new(0, 0, -10)
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Transformed_X_Tap_Release_PunchLaunch_01", startCFrame.Position)
		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		TweenService:Create(clone, TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame
		}):Play()
		local v3 = false
		task.spawn(function()
			local now = tick()
			local now2 = tick()
			local v4 = tick() + 0.1
			local now3 = tick()
			local v5 = {}

			repeat
				if now - tick() <= 0 then
					now = tick() + 0.05
					task.spawn(function()
						local clone3 = x_Attract.Phase1.SpinSlash:Clone()
						clone3:PivotTo(clone.CFrame)
						Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
						local model2 = clone3.Model2
						local colorSequence = ColorSequence.new({
							ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(35, 50, 255))),
							ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(35, 50, 255)))
						})
						local numberSequence = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.825),
							NumberSequenceKeypoint.new(1, 0.825)
						})
						local v6 = -15

						for i = 1, 2 do
							local v7 = i * 1.15 + 7
							local v8 = 1
							local clone4 = model2:Clone()

							if i == 1 then
								v7 += 5
							elseif i == 2 then
								colorSequence = ColorSequence.new({
									ColorSequenceKeypoint.new(
										0,
										RecolorMagnetColor(player, Color3.fromRGB(197, 203, 255))
									),
									ColorSequenceKeypoint.new(
										1,
										RecolorMagnetColor(player, Color3.fromRGB(197, 203, 255))
									)
								})
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.855),
									NumberSequenceKeypoint.new(1, 0.855)
								})
								v7 += 7
								v8 = 1.15
								v6 = -50
							elseif i == 3 then
								colorSequence = ColorSequence.new({
									ColorSequenceKeypoint.new(
										0,
										RecolorMagnetColor(player, Color3.fromRGB(255, 84, 181))
									),
									ColorSequenceKeypoint.new(
										1,
										RecolorMagnetColor(player, Color3.fromRGB(255, 84, 181))
									)
								})
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.875),
									NumberSequenceKeypoint.new(1, 0.875)
								})
								v7 += 2
								v8 = 1.35
								v6 = -75
							elseif i == 4 then
								colorSequence = ColorSequence.new({
									ColorSequenceKeypoint.new(
										0,
										RecolorMagnetColor(player, Color3.fromRGB(255, 140, 205))
									),
									ColorSequenceKeypoint.new(
										1,
										RecolorMagnetColor(player, Color3.fromRGB(255, 140, 205))
									)
								})
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.9),
									NumberSequenceKeypoint.new(1, 0.9)
								})
								v8 = 1.45
								v6 = -100
							elseif i == 5 then
								colorSequence = ColorSequence.new({
									ColorSequenceKeypoint.new(
										0,
										RecolorMagnetColor(player, Color3.fromRGB(255, 207, 234))
									),
									ColorSequenceKeypoint.new(
										1,
										RecolorMagnetColor(player, Color3.fromRGB(255, 207, 234))
									)
								})
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.925),
									NumberSequenceKeypoint.new(1, 0.925)
								})
								v7 += -2
								v8 = 1.1
								v6 = -125
							end

							clone4:ScaleTo(v7 / v8)

							for _, beam in pairs(clone4:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								if colorSequence ~= nil then
									beam.Color = colorSequence
									beam.Transparency = numberSequence
								end

								beam.Enabled = true
							end

							local primaryPart = clone4.PrimaryPart
							local v9 = clone3.PrimaryPart.CFrame * CFrame.new(0, 0, v6) * CFrame.Angles(
								math.rad(math.random(-180, 180) / 100),
								math.rad(math.random(-180, 180) / 100),
								(math.rad((math.random(-180, 180))))
							)
							local angularVelocity = primaryPart.AngularVelocity
							primaryPart.Anchored = false
							primaryPart.AlignPosition.Position = primaryPart.CFrame * createVector(0, 0, -100)
							angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
							clone4:PivotTo(v9)
							Util.SetParentOverrideWithColor(clone4, clone3, player, "MagnetFruitVFXColor")
							clone4:GetScale()
							task.spawn(function()
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-5, 5) / 5,
											math.random(-5, 5) / 5,
											math.random(5, 10)
										)
									}
								):Play()
								task.wait(0.1 * math.random() + 0.1)

								for i2, effect in pairs(clone4:GetDescendants()) do
									if effect:IsA("Beam") then
										TweenService:Create(effect, TweenInfo.new(0.1 * math.random() + 0.1), {
											Width0 = 0,
											Width1 = 0
										}):Play()
										local v11 = effect
										task.delay(1, function()
											v11:Destroy()
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
							local v7 = clone3:GetScale() * 0.5
							local v8 = v7 * 1.15

							for i = v7 * 100, v8 * 100, 10 do
								clone3:ScaleTo(i / 100)
								task.wait(0.005)
							end
						end)
					end)
				end

				if now2 - tick() <= 0 then
					now2 = tick() + 0.1

					for i = 1, 3 do
						local v6 = i
						task.spawn(function()
							if v6 == 1 then
								local v7 = clone.Position + Vector3.new(math.random(-25, 25), 0, math.random(-25, 25))
								local raycastResult = workspace:Raycast(
									v7 + createVector(0, 1, 0),
									createVector(-0, -50, -0),
									raycastParams
								)

								if raycastResult then
									for i2 = 1, math.random(1, 2) do
										task.spawn(function()
											local clone3 = script.Part:Clone()
											clone3.CFrame = CFrame.new(clone.Position, raycastResult.Position)
											Util.SetParentOverrideWithColor(
												clone3,
												folder,
												player,
												"MagnetFruitVFXColor"
											)
											clone3.Anchored = false
											clone3.Weld.Part1 = clone
											clone3.Massless = true
											clone3.Weld.C0 = CFrame.new(
												math.random(-5, 5),
												math.random(-5, 5) / 3,
												math.random(-5, 5) / 5
											)
											clone3.Attach1:SetAttribute("Pos", raycastResult.Position)
											local shafiBolt = ShafiBolt(
												clone3.Attach0,
												clone3.Attach1,
												math.random(8, 12) * 1.25,
												0.75,
												folder
											)
											local v9 = player
											local color = Color3.fromRGB(28, 28, 255)

											if typeof(v9) == "Instance" and v9.Parent then
												color = WrapColor3Constructor(color, v9, "MagnetFruitVFXColor")
											end

											shafiBolt.Color = color
											shafiBolt.CurveSize0 = math.random(-25, 25)
											shafiBolt.CurveSize0 = math.random(-25, 25)
											v5[clone3.Attach1] = shafiBolt
											task.wait(0.05 * math.random() + 0.1)

											if v5[clone3.Attach1] == nil then
												return
											end

											v5[clone3.Attach1] = nil
											shafiBolt:Destroy()
										end)
									end
								end
							else
								local v7 = clone.Position + Vector3.new(
									math.random(-25, 25) * 2,
									math.random(-50, -25) / 2,
									math.random(-25, 25)
								)

								for i2 = 1, math.random(1, 2) do
									task.spawn(function()
										local clone3 = script.Part:Clone()
										clone3.CFrame = CFrame.new(clone.Position, v7)
										Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
										clone3.Anchored = false
										clone3.Weld.Part1 = clone
										clone3.Massless = true
										clone3.Weld.C0 = CFrame.new(
											math.random(-5, 5),
											math.random(-5, 5) / 3,
											math.random(-5, 5) / 5
										)
										clone3.Attach1:SetAttribute("Pos", v7)
										local shafiBolt = ShafiBolt(
											clone3.Attach0,
											clone3.Attach1,
											math.random(8, 12) * 1.25,
											0.75,
											folder
										)
										local v9 = player
										local color = Color3.fromRGB(28, 28, 255)

										if typeof(v9) == "Instance" and v9.Parent then
											color = WrapColor3Constructor(color, v9, "MagnetFruitVFXColor")
										end

										shafiBolt.Color = color
										shafiBolt.CurveSize0 = math.random(-25, 25)
										shafiBolt.CurveSize0 = math.random(-25, 25)
										v5[clone3.Attach1] = shafiBolt
										task.wait(0.1 * math.random() + 0.1)

										if v5[clone3.Attach1] == nil then
											return
										end

										v5[clone3.Attach1] = nil
										shafiBolt:Destroy()
									end)
								end
							end
						end)
					end
				end

				if v4 - tick() <= 0 then
					v4 = tick() + 0.1
					local clone3 = x_Attract.Phase1.Sphere:Clone()
					clone3.Size *= 1.5
					clone3.CFrame = CFrame.new(clone.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
					Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
					local folder2 = clone3
					task.spawn(function()
						TweenService:Create(
							folder2,
							TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = folder2.Size * 2.7
							}
						):Play()

						for i, decal in pairs(folder2:GetDescendants()) do
							if not decal:IsA("Decal") then
								continue
							end

							decal.Transparency = math.random(0, 30) / 100
							TweenService:Create(
								decal,
								TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
								{
									Transparency = 1
								}
							):Play()
						end
					end)
					task.spawn(function()
						local clone4 = x_Attract.Phase1.Sphere1:Clone()
						clone4.Size *= 1.5
						clone4.CFrame = CFrame.new(clone.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						task.spawn(function()
							TweenService:Create(
								clone4,
								TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
								{
									Size = clone4.Size * 2.7
								}
							):Play()

							for _, decal in pairs(clone4:GetDescendants()) do
								if not decal:IsA("Decal") then
									continue
								end

								decal.Transparency = math.random(50, 80) / 100
								TweenService:Create(
									decal,
									TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
									{
										Transparency = 1,
										StudsPerTileU = math.random(15, 20) * 2,
										StudsPerTileV = math.random(15, 20) * 2
									}
								):Play()
							end
						end)
					end)
				end

				if now3 - tick() <= 0 then
					now3 = tick() + 0.025

					for i = 1, math.random(1, 2) do
						local v6 = i
						task.spawn(function()
							local clone3 = script.Part:Clone()
							local cFrame2 = CFrame.new(clone.Position) * CFrame.Angles(
								math.random(-180, 180),
								math.rad((math.random(-180, 180))),
								math.random(-180, 180)
							) * CFrame.new(0, 0, -75)
							clone3.CFrame = cFrame2
							Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
							clone3.Anchored = false
							clone3.Weld.Part1 = clone
							clone3.Weld.C1 = CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, 37.5)
							clone3.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 150).Position
							local shafiBolt = ShafiBolt(clone3.Attach0, clone3.Attach1, math.random(8, 12), 0.7, folder)
							shafiBolt.CurveSize0 = -37.5
							shafiBolt.CurveSize1 = 37.5
							shafiBolt.Frequency = math.random(5, 10)
							shafiBolt.MaxRadius = 5
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							local v9 = player
							local color = Color3.fromRGB(28, 28, 255)

							if typeof(v9) == "Instance" and v9.Parent then
								color = WrapColor3Constructor(color, v9, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color

							if v6 % 2 == 0 then
								local v10 = player
								local color2 = Color3.fromRGB(45, 30, 255)

								if typeof(v10) == "Instance" and v10.Parent then
									color2 = WrapColor3Constructor(color2, v10, "MagnetFruitVFXColor")
								end

								shafiBolt.Color = color2
							end

							task.spawn(function()
								task.wait(0.07 + math.random() * 0.1)
								shafiBolt:Destroy()
							end)
						end)
					end
				end

				for k, _ in pairs(v5) do
					local pos = k:GetAttribute("Pos")

					if k:GetAttribute("Dontmove") == nil then
						k.WorldPosition = CFrame.new(pos, clone.Position) * createVector(0, 0, -5)
					else
						k.WorldPosition = pos
					end
				end

				task.wait(0.025)
			until v3 == true
		end)
		task.wait(travelTime)
		v3 = true
		clone:SetAttribute("Spread", true)
		task.delay(data.ExplosionWindup, function()
			clone:SetAttribute("End", true)
		end)
		local clone3 = x_Attract.Phase2.MagnetAuraModel:Clone()
		local primaryPart = clone3.PrimaryPart
		primaryPart.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
		local ray = Util.Ray
		local v4 = cFrame.Position + createVector(0, 1, 0)
		local v5 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

		if ray(v4, createVector(-0, -50, -0), v5) then
			Util.Sound:Play("Magnet_Transformed_X_Tap_Windup_And_Explosion_Ground_04", cFrame.Position)
		else
			Util.Sound:Play("Magnet_Transformed_X_Tap_Windup_And_Explosion_Air_01", cFrame.Position)
		end

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter.Rate *= 0.5
		end

		local v6 = data.ExplosionWindup - 0.1
		task.spawn(function()
			local v7 = v6
			local lastTime = tick()
			tick()
			tick()

			while tick() - lastTime < v7 do
				task.wait()
			end
		end)
		task.spawn(function()
			local position = cFrame.Position
			local v7 = tick() + v6
			tick()
			tick()
			local clone4 = x_Attract.Phase2.Shockwave:Clone()
			clone4.CFrame = CFrame.new(position + createVector(0, 1, 0))
			Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
			local emittersByEmitter = {}

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emittersByEmitter[emitter] = emitter
				end
			end

			repeat
				for _, emitter in pairs(emittersByEmitter) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") * 1.5)
					end
				end

				task.spawn(function()
					for i = 1, 10 do
						local v8 = i
						task.spawn(function()
							local clone5 = script.Part:Clone()
							local cFrame2 = CFrame.new(position) * CFrame.new(0, 15 + math.random(0, 10), 0) * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							clone5.CFrame = cFrame2
							Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
							clone5.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 70 * math.random(12, 20) / 10).Position
							local shafiBolt = ShafiBolt(
								clone5.Attach0,
								clone5.Attach1,
								math.random(8, 12) * 1.25,
								0.75,
								folder
							)
							shafiBolt.Frequency = math.random(5, 10) * 2
							shafiBolt.MaxRadius = 12
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							local v11 = player
							local color = Color3.fromRGB(28, 28, 255)

							if typeof(v11) == "Instance" and v11.Parent then
								color = WrapColor3Constructor(color, v11, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color

							if v8 % 2 == 0 then
								local v12 = player
								local color2 = Color3.fromRGB(45, 30, 255)

								if typeof(v12) == "Instance" and v12.Parent then
									color2 = WrapColor3Constructor(color2, v12, "MagnetFruitVFXColor")
								end

								shafiBolt.Color = color2
								shafiBolt.Thickness = 1
							end

							task.spawn(function()
								task.wait(0.05 + math.random() * 0.115)
								shafiBolt:Destroy()
							end)
						end)
					end
				end)
				task.wait(0.125)
			until v7 - tick() <= 0
		end)
		task.wait(v6 * 1)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(primaryPart:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local clone4 = x_Attract.Phase3.ExStartImpact:Clone()
		clone4.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.1)
		magnetModel:Destroy()
		task.spawn(function()
			Explosion(cFrame, folder, raycastParams, player)
		end)
		local clone5 = x_Attract.Phase3.ExplosionFinalModel:Clone()
		clone5:ScaleTo(2.75)
		local primaryPart2 = clone5.PrimaryPart
		primaryPart2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")

		if (workspace.CurrentCamera.CFrame.p - cFrame.Position).Magnitude < 150 then
			Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.6)
		end

		DeleteImpactAfterDuration(primaryPart2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(primaryPart2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				local lifetime = v7.Lifetime
				v7.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				v7:Emit(v7:GetAttribute("EmitCount") * 1.25)
			end)
		end

		task.spawn(function()
			for i = 1, 5 do
				local v7 = i
				task.spawn(function()
					local v8 = 13
					local clone6 = x_Attract.Phase3.SpinSlash:Clone()
					clone6:PivotTo(cFrame * CFrame.new(0, 10, 0))
					Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")

					if v7 == 2 then
						clone6:PivotTo(cFrame * CFrame.new(0, 35, 0))
						v8 = 10
					elseif v7 == 3 then
						clone6:PivotTo(cFrame * CFrame.new(0, 60, 0))
						v8 = 8
					elseif v7 == 4 then
						clone6:PivotTo(cFrame * CFrame.new(0, -35, 0))
						v8 = 10
					elseif v7 == 5 then
						clone6:PivotTo(cFrame * CFrame.new(0, -60, 0))
						v8 = 8
					end

					local model = clone6.Model

					for i2 = 1, 3 do
						local v9 = v8 + i2 * 1.05
						local clone7 = model:Clone()
						clone7:ScaleTo(v9 + 1.75)
						local primaryPart3 = clone7.PrimaryPart
						local v10 = clone6.PrimaryPart.CFrame * CFrame.new(0, v9, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
						local angularVelocity = primaryPart3.AngularVelocity
						primaryPart3.Anchored = false
						primaryPart3.AlignPosition.Position = primaryPart3.Position + Vector3.new(
							math.random(-10, 10) / 10,
							0,
							math.random(-10, 10) / 10
						)
						angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
						clone7:PivotTo(v10)
						Util.SetParentOverrideWithColor(clone7, clone6, player, "MagnetFruitVFXColor")
						clone7:GetScale()
						local folder2 = clone7
						task.spawn(function()
							task.spawn(function()
								local Y = folder2.Slash.Position.Y
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-5, 5) / 2,
											math.random(5, 15),
											math.random(-5, 5) / 2
										)
									}
								):Play()
							end)
							task.wait(0.1 * math.random() + 0.135)

							for i3, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.15 + math.random() * 0.15), {
										Width0 = 0,
										Width1 = 0
									}):Play()
									local v12 = effect
									task.delay(1, function()
										v12:Destroy()
									end)
								elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end

							task.wait(1)
							angularVelocity.Enabled = false
						end)
					end

					model:Destroy()
					task.spawn(function()
						local scale = clone6:GetScale()
						local v9 = scale * 1.5

						for i2 = scale * 100, v9 * 100, 7 do
							clone6:ScaleTo(i2 / 100)
							task.wait(0.005)
						end
					end)
				end)
			end
		end)
		task.spawn(function()
			task.spawn(function()
				for i = 1, 10 do
					local v7 = i
					task.spawn(function()
						local clone6 = script.Part:Clone()
						local cFrame2 = CFrame.new(cFrame.Position) * CFrame.new(0, math.random(0, 10), 0) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 1),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 1))
						) * CFrame.new(0, 0, -105)
						clone6.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")
						clone6.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 210).Position
						local shafiBolt = ShafiBolt(
							clone6.Attach0,
							clone6.Attach1,
							math.random(8, 12) * 1.25,
							0.75,
							folder
						)
						shafiBolt.CurveSize0 = -90
						shafiBolt.CurveSize1 = 90
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v10 = player
						local color = Color3.fromRGB(28, 28, 255)

						if typeof(v10) == "Instance" and v10.Parent then
							color = WrapColor3Constructor(color, v10, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v7 % 2 == 0 then
							local v11 = player
							local color2 = Color3.fromRGB(45, 30, 255)

							if typeof(v11) == "Instance" and v11.Parent then
								color2 = WrapColor3Constructor(color2, v11, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
							shafiBolt.Thickness = 1
						end

						task.spawn(function()
							task.wait(0.2 + math.random() * 0.2)
							shafiBolt:Destroy()
						end)
					end)
				end
			end)
		end)
		local position = cFrame.Position
		task.spawn(function()
			local clone6 = x_Attract.Phase3.SpinSlash2:Clone()
			clone6:PivotTo(CFrame.new(position))
			Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")
			local model = clone6.Model

			for i = 1, 5 do
				local v7 = math.random(70, 100) / 100
				local clone7 = model:Clone()
				clone7:ScaleTo(i * 0.35 + 10)
				local primaryPart3 = clone7.PrimaryPart
				local v9 = clone6.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-180, 180) / 1),
					math.rad((math.random(-180, 180))),
					(math.rad(math.random(-180, 180) / 1))
				)
				local angularVelocity = primaryPart3.AngularVelocity
				primaryPart3.Anchored = false
				primaryPart3.AlignPosition.Position = primaryPart3.Position + createVector(0, 5, 0)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone7:PivotTo(v9)
				Util.SetParentOverrideWithColor(clone7, clone6, player, "MagnetFruitVFXColor")
				primaryPart3.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone7:GetScale()
				local folder2 = clone7
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-15, 15) / 10,
									math.random(5, 15),
									math.random(-15, 15) / 10
								)
							}
						):Play()
						task.wait(v7 / 2)
						primaryPart3.AlignPosition.Position = position + createVector(0, 5, 0)
					end)
					task.wait(0.035 * math.random() + 0.2)

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v13 = effect
							task.delay(1, function()
								v13:Destroy()
							end)
						elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					task.wait(1)
					angularVelocity.Enabled = false
					task.wait(3)
					angularVelocity:Destroy()
				end)
			end

			model:Destroy()
			task.spawn(function()
				local scale = clone6:GetScale()
				local v7 = scale * 0.01

				for i = scale * 100, v7 * 100, -13 do
					clone6:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		task.spawn(function()
			for _ = 1, 10 do
				task.spawn(function()
					local v7 = math.random(45, 50) / 125
					local clone6 = x_Attract.Phase3.TrailModel:Clone()
					clone6.Start.CFrame = CFrame.new(position) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")
					clone6:ScaleTo(math.random(20, 25) / 10)
					local start = clone6.Start
					local trail = clone6.Trail
					local cframe = CFrame.new(0, 0, -math.random(100, 150) * 1.5)
					TweenService:Create(trail.Weld, TweenInfo.new(v7 / 5), {
						C1 = cframe
					}):Play()
					TweenService:Create(start, TweenInfo.new(v7), {
						CFrame = CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
					}):Play()
					trail.Weld.C1 = CFrame.new(0, 0, 0)
					task.delay(v7 / 2, function()
						TweenService:Create(trail.Weld, TweenInfo.new(v7), {
							C1 = CFrame.new(0, 0, 0)
						}):Play()
						start.AlignPosition.Position = position
					end)
					trail.Trail1.Lifetime = math.random(50, 200) / 1500
					local angularVelocity = start.AngularVelocity
					start.Anchored = false
					start.AlignPosition.Position = start.Position
					TweenService:Create(angularVelocity, TweenInfo.new(0.125), {
						AngularVelocity = Vector3.new(
							math.random(-10, 15) * 2,
							math.random(-10, 15) * 2,
							math.random(-10, 15) * 2
						)
					}):Play()

					for _, effect in pairs(clone6:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
						local v8 = effect
						task.delay(v7 + v7 / 5, function()
							v8.Enabled = false
						end)
					end

					task.wait(v7)
					angularVelocity.Enabled = false
					task.wait(v7)
					clone6:Destroy()
				end)
			end
		end)
	end
end