local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local x_Attract_Held = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("X_Attract_Held")
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
local _ = workspace._WorldOrigin

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
	bodyVelocity.Velocity = unit * math.random(70, 100) + vector2 * 2.15
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
	local v7 = false
	local v8 = 1
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
			v8 = 2
		elseif clone:GetAttribute("Shrink") == true and v7 == false then
			v7 = true
			p *= 0.5
			v3 *= 0.7
			v8 = 0.75
		end

		v2 += v3 * dt

		if clone:GetAttribute("End") == true then
			heartbeatConnection:Disconnect()
			local clone2 = x_Attract_Held.Phase1.EndImpact:Clone()
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
			local v9 = position + v5 * 60 * dt
			local v10 = p * v8
			v4 += (v10 - v4) * math.clamp(dt * 6, 0, 1)
			local v11 = v9 + CFrame.fromAxisAngle(unit, v2):VectorToWorldSpace(unit2 * v4)
			folder.CFrame = CFrame.lookAt(v11, v9)
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

local function Explosion(cframe, folder, raycastParams, player)
	local function Scale(instance, p)
		local position = cframe.Position

		if instance.ClassName ~= "Model" then
			local model = Instance.new("Model")
			model.Parent = instance.Parent
			instance.Parent = model
			instance = model
		end

		instance:ScaleTo(p)
		local v2 = position + (instance:GetPivot().Position - position) * p
		instance:PivotTo(instance:GetPivot().Rotation + v2)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(clone, duration)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end

	local function cameraShakeAt(_, _, _, _, _, _) end

	local function RockCrater(p, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v2 = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
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
				v5.CFrame = CFrame.new(v5.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-150, 250) / 7
				)
				local ray = Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local part, v6 = workspace:FindPartOnRayWithIgnoreList(ray, raycastParams.FilterDescendantsInstances)

				if part then
					local v7 = (v5.Position - p.Position).Magnitude / 200
					local v8 = size * math.random(20, 40) / 10
					local v9 = size * math.random(10, 30) / 10
					local v10 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v8 * v7, v9 * v7, v10 * v7)
					v5.Position = v6 + Vector3.new(0, -v5.Size.Y * math.random(5, 6) / 15, 0)
					v5.CFrame = CFrame.new(v5.Position, p.Position) * CFrame.new(
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
		local clone = x_Attract_Held.Phase3.Rock:Clone()
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
		cframe.Position + createVector(0, 1, 0),
		createVector(-0, -75, -0),
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
		RockType = x_Attract_Held.Phase3.CraterRock
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
		local clone = x_Attract_Held.Phase2.GroundCrack:Clone()
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

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local folder = workspace._WorldOrigin:FindFirstChild(data.Player.Name .. "_MagnetXTransformed")

	if not folder then
		return
	end

	folder.Name = "DESTROYING"
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local root = data.Root
	local cFrame = root.CFrame
	local magnetModel = folder.MagnetModel
	magnetModel:PivotTo(cFrame * CFrame.new(0, 10, -4))
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
	local descendantsByDescendant = {}
	local descendantsByDescendant2 = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:GetAttribute("XOrbitCube") then
			descendantsByDescendant[descendant] = descendant
		elseif descendant:GetAttribute("XOrbitMini") then
			descendantsByDescendant2[descendant] = descendant
		end
	end

	local clone = x_Attract_Held.Phase1.Projectile:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local weld = Instance.new("Weld")
	weld.Part0 = magnetModel.PrimaryPart
	weld.Parent = magnetModel
	magnetModel.PrimaryPart.Anchored = false
	magnetModel.PrimaryPart.Massless = true
	weld.Part1 = clone

	for _, v2 in pairs(descendantsByDescendant2) do
		StartOrbit(v2, clone, math.random(12, 15) * 1.25, math.random(7, 9), player)
	end

	for _, v2 in pairs(descendantsByDescendant) do
		StartOrbit(v2, clone, math.random(12, 15) * 1.75, math.random(7, 9), player)
	end

	local clone2 = x_Attract_Held.Phase1.StartImpact:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -10)
	Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
	Util.Sound:Play("Magnet_Transformed_X_Held_Activation_Explosion_01", cFrame.Position)
	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount"))
		end)
	end

	local v2 = false
	task.spawn(function()
		local now = tick()
		tick()
		local v3 = tick() + 0.1
		local now2 = tick()

		repeat
			if now - tick() <= 0 then
				now = tick() + 0.1
				task.spawn(function()
					local clone3 = x_Attract_Held.Phase1.SpinSlash:Clone()
					clone3:PivotTo(clone.CFrame)
					Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
					local model2 = clone3.Model2
					local colorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(29, 52, 255))),
						ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(29, 52, 255)))
					})
					local numberSequence = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.825),
						NumberSequenceKeypoint.new(1, 0.825)
					})
					local v4 = -15

					for i = 1, 2 do
						local v5 = i * 1.15 + 7
						local v6 = 1
						local clone4 = model2:Clone()

						if i == 1 then
							v5 += 5
						elseif i == 2 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(189, 201, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(189, 201, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.855),
								NumberSequenceKeypoint.new(1, 0.855)
							})
							v5 += 7
							v6 = 1.15
							v4 = -50
						elseif i == 3 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(83, 100, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(83, 100, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.875),
								NumberSequenceKeypoint.new(1, 0.875)
							})
							v5 += 2
							v6 = 1.35
							v4 = -75
						elseif i == 4 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(140, 152, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(140, 152, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.9),
								NumberSequenceKeypoint.new(1, 0.9)
							})
							v6 = 1.45
							v4 = -100
						elseif i == 5 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(202, 203, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(202, 203, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.925),
								NumberSequenceKeypoint.new(1, 0.925)
							})
							v5 += -2
							v6 = 1.1
							v4 = -125
						end

						clone4:ScaleTo(v5 / v6)

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
						local v7 = clone3.PrimaryPart.CFrame * CFrame.new(0, 0, v4) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 100),
							math.rad(math.random(-180, 180) / 100),
							(math.rad((math.random(-180, 180))))
						)
						local angularVelocity = primaryPart.AngularVelocity
						primaryPart.Anchored = false
						primaryPart.AlignPosition.Position = primaryPart.CFrame * createVector(0, 0, -100)
						angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
						clone4:PivotTo(v7)
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
									local v9 = effect
									task.delay(1, function()
										v9:Destroy()
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
						local v5 = clone3:GetScale() * 0.5
						local v6 = v5 * 1.15

						for i = v5 * 100, v6 * 100, 10 do
							clone3:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end)
			end

			if v3 - tick() <= 0 then
				v3 = tick() + 0.1
				local clone3 = x_Attract_Held.Phase1.Sphere:Clone()
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
					local clone4 = x_Attract_Held.Phase1.Sphere1:Clone()
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

			if now2 - tick() <= 0 then
				now2 = tick() + 0.1

				for i = 1, math.random(1, 2) do
					local v4 = i
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
						local v7 = player
						local color = Color3.fromRGB(43, 64, 255)

						if typeof(v7) == "Instance" and v7.Parent then
							color = WrapColor3Constructor(color, v7, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v4 % 2 == 0 then
							local v8 = player
							local color2 = Color3.fromRGB(49, 42, 255)

							if typeof(v8) == "Instance" and v8.Parent then
								color2 = WrapColor3Constructor(color2, v8, "MagnetFruitVFXColor")
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

			task.wait(0.025)
		until v2 == true
	end)
	task.wait(0.25)
	local cframe = CFrame.new(clone.Position)
	v2 = true
	clone:SetAttribute("Spread", true)
	local clone3 = x_Attract_Held.Phase2.MagnetAuraModel:Clone()
	local primaryPart = clone3.PrimaryPart
	primaryPart.CFrame = cframe
	Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(primaryPart:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter.Rate *= 0.35
	end

	task.spawn(function()
		local lastTime = tick()
		local now = tick()
		local v3 = tick() + 0.1
		local now2 = tick()
		local now3 = tick()

		while tick() - lastTime < 1 do
			if now - tick() <= 0 then
				now = tick() + 0.05
				task.spawn(function()
					local clone4 = x_Attract_Held.Phase1.SpinSlash:Clone()
					clone4:PivotTo(clone.CFrame)
					Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
					local model2 = clone4.Model2
					local colorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(32, 36, 255))),
						ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(32, 36, 255)))
					})
					local numberSequence = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.825),
						NumberSequenceKeypoint.new(1, 0.825)
					})
					local v4 = -15

					for i = 1, 2 do
						local v5 = i * 1.15 + 10
						local v6 = 1
						local clone5 = model2:Clone()

						if i == 1 then
							v5 += 5
						elseif i == 2 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(205, 212, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(205, 212, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.855),
								NumberSequenceKeypoint.new(1, 0.855)
							})
							v5 += 7
							v6 = 1.15
							v4 = -50
						elseif i == 3 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(74, 86, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(74, 86, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.875),
								NumberSequenceKeypoint.new(1, 0.875)
							})
							v5 += 2
							v6 = 1.35
							v4 = -75
						elseif i == 4 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(135, 147, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(135, 147, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.9),
								NumberSequenceKeypoint.new(1, 0.9)
							})
							v6 = 1.45
							v4 = -100
						elseif i == 5 then
							colorSequence = ColorSequence.new({
								ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(197, 210, 255))),
								ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(197, 210, 255)))
							})
							numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0.925),
								NumberSequenceKeypoint.new(1, 0.925)
							})
							v5 += -2
							v6 = 1.1
							v4 = -125
						end

						clone5:ScaleTo(v5 / v6)

						for _, beam in pairs(clone5:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							if colorSequence ~= nil then
								beam.Color = colorSequence
								beam.Transparency = numberSequence
							end

							beam.Enabled = true
						end

						local primaryPart2 = clone5.PrimaryPart
						local v7 = clone4.PrimaryPart.CFrame * CFrame.new(0, 0, v4) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 1),
							math.rad(math.random(-180, 180) / 1),
							(math.rad((math.random(-180, 180))))
						)
						local angularVelocity = primaryPart2.AngularVelocity
						primaryPart2.Anchored = false
						primaryPart2.AlignPosition.Position = primaryPart2.CFrame * createVector(0, 0, -0.1)
						angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
						clone5:PivotTo(v7)
						Util.SetParentOverrideWithColor(clone5, clone4, player, "MagnetFruitVFXColor")
						clone5:GetScale()
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

							for i2, effect in pairs(clone5:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(0.1 * math.random() + 0.1), {
										Width0 = 0,
										Width1 = 0
									}):Play()
									local v9 = effect
									task.delay(1, function()
										v9:Destroy()
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
						local v5 = clone4:GetScale() * 0.5
						local v6 = v5 * 1.15

						for i = v5 * 100, v6 * 100, 10 do
							clone4:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end)
			end

			if v3 - tick() <= 0 then
				v3 = tick() + 0.135
				local clone4 = x_Attract_Held.Phase1.Sphere:Clone()
				clone4.Size *= 1.5
				clone4.CFrame = CFrame.new(clone.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
					math.random(-180, 180),
					math.random(-180, 180),
					math.random(-180, 180)
				)
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
				local folder2 = clone4
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

						decal.Transparency = math.random(50, 70) / 100
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
					local clone5 = x_Attract_Held.Phase1.Sphere1:Clone()
					clone5.Size *= 1.5
					clone5.CFrame = CFrame.new(clone.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
					Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
					task.spawn(function()
						TweenService:Create(
							clone5,
							TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = clone5.Size * 2.7
							}
						):Play()

						for _, decal in pairs(clone5:GetDescendants()) do
							if not decal:IsA("Decal") then
								continue
							end

							decal.Transparency = math.random(70, 90) / 100
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

			if now2 - tick() <= 0 then
				now2 = tick() + 0.075

				for i = 1, math.random(1, 2) do
					local v4 = i
					task.spawn(function()
						local clone4 = script.Part:Clone()
						local cFrame2 = CFrame.new(clone.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.rad((math.random(-180, 180))),
							math.random(-180, 180)
						) * CFrame.new(0, 0, -125)
						clone4.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						clone4.Anchored = false
						clone4.Weld.Part1 = clone
						clone4.Weld.C1 = CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						) * CFrame.new(0, 0, 62.5)
						clone4.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 250).Position
						local shafiBolt = ShafiBolt(clone4.Attach0, clone4.Attach1, math.random(8, 12), 0.7, folder)
						shafiBolt.CurveSize0 = -62.5
						shafiBolt.CurveSize1 = 62.5
						shafiBolt.Frequency = math.random(5, 10)
						shafiBolt.MaxRadius = 5
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v7 = player
						local color = Color3.fromRGB(53, 56, 255)

						if typeof(v7) == "Instance" and v7.Parent then
							color = WrapColor3Constructor(color, v7, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v4 % 2 == 0 then
							local v8 = player
							local color2 = Color3.fromRGB(60, 53, 255)

							if typeof(v8) == "Instance" and v8.Parent then
								color2 = WrapColor3Constructor(color2, v8, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
						end

						task.spawn(function()
							task.wait(0.05 + math.random() * 0.1)
							shafiBolt:Destroy()
						end)
					end)
				end
			end

			if now3 - tick() <= 0 then
				now3 = tick() + 0.025

				for i = 1, math.random(1, 2) do
					local v4 = i
					task.spawn(function()
						local v5 = math.random(70, 100)
						local clone4 = script.Part:Clone()
						local cFrame2 = CFrame.new(clone.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.rad((math.random(-180, 180))),
							math.random(-180, 180)
						) * CFrame.new(0, 0, -v5)
						clone4.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						clone4.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, -v5).Position
						local shafiBolt = ShafiBolt(clone4.Attach0, clone4.Attach1, math.random(8, 12), 1.25, folder)
						shafiBolt.CurveSize0 = math.random(-25, 25)
						shafiBolt.CurveSize1 = math.random(-25, 25)
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 10
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v8 = player
						local color = Color3.fromRGB(16, 21, 108)

						if typeof(v8) == "Instance" and v8.Parent then
							color = WrapColor3Constructor(color, v8, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v4 % 2 == 0 then
							local v9 = player
							local color2 = Color3.fromRGB(22, 11, 76)

							if typeof(v9) == "Instance" and v9.Parent then
								color2 = WrapColor3Constructor(color2, v9, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
						end

						task.spawn(function()
							task.wait(0.1 + math.random() * 0.125)
							shafiBolt:Destroy()
						end)
					end)
				end
			end

			task.wait()
		end
	end)
	task.spawn(function()
		local position = cframe.Position
		local v3 = tick() + 1
		tick()
		tick()
		local clone4 = x_Attract_Held.Phase2.Shockwave:Clone()
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
				local clone5 = x_Attract_Held.Phase2.SpinSlash:Clone()
				clone5:PivotTo(CFrame.new(position + createVector(0, -35, 0)))
				Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
				local model = clone5.Model
				local model2 = clone5.Model2

				for i = 1, 3 do
					local v4 = i * 1.05 + 10
					local v5 = 1
					local clone6

					if i == 1 then
						clone6 = model:Clone()
					else
						clone6 = model2:Clone()
						v5 = 1.5
					end

					clone6:ScaleTo(v4 / (v5 / 1.25))

					for _, beam in pairs(clone6:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Enabled = true
						end
					end

					local primaryPart2 = clone6.PrimaryPart
					local v6 = clone5.PrimaryPart.CFrame * CFrame.new(0, v4, 0) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)

					if i == 1 then
						v6 = clone5.PrimaryPart.CFrame * CFrame.new(0, v4, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
					end

					local angularVelocity = primaryPart2.AngularVelocity
					primaryPart2.Anchored = false
					primaryPart2.AlignPosition.Position = primaryPart2.Position + Vector3.new(
						math.random(-10, 10) / 10,
						0,
						math.random(-10, 10) / 10
					)
					angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
					clone6:PivotTo(v6)
					Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
					clone6:GetScale()
					task.spawn(function()
						task.spawn(function()
							local Y = clone6.Slash.Position.Y
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
						task.wait(0.1 * math.random() + 0.1 / v5)

						for i2, effect in pairs(clone6:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.15 / v5 + math.random() * 0.15 / v5), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v8 = effect
								task.delay(1, function()
									v8:Destroy()
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
					local v4 = clone5:GetScale() * 1.5
					local v5 = v4 * 2.25

					for i = v4 * 100, v5 * 100, 5 do
						clone5:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end)
			task.wait(0.125)
		until v3 - tick() <= 0
	end)
	task.wait(1)

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

	clone:SetAttribute("Shrink", true)
	local clone4 = x_Attract_Held.Phase2.MagnetAuraModel2:Clone()
	local primaryPart2 = clone4.PrimaryPart
	primaryPart2.CFrame = cframe * CFrame.new(0, 5, 0)
	Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(primaryPart2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter.Rate *= 1.5
		emitter:Emit(1)
	end

	local position = cframe.Position
	task.spawn(function()
		local clone5 = x_Attract_Held.Phase2.SpinSlash2:Clone()
		clone5:PivotTo(CFrame.new(position))
		Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
		local model = clone5.Model

		for i = 1, 5 do
			local v3 = math.random(70, 100) / 200
			local v4 = i * 0.35 + 10 + math.random(-10, 10) / 10
			local clone6 = model:Clone()
			clone6:ScaleTo(v4)
			local primaryPart3 = clone6.PrimaryPart
			local v5 = clone5.PrimaryPart.CFrame * CFrame.Angles(
				math.rad(math.random(-180, 180) / 1),
				math.rad((math.random(-180, 180))),
				(math.rad(math.random(-180, 180) / 1))
			)
			local angularVelocity = primaryPart3.AngularVelocity
			primaryPart3.Anchored = false
			primaryPart3.AlignPosition.Position = primaryPart3.Position + createVector(0, 5, 0)
			angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
			clone6:PivotTo(v5)
			Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
			primaryPart3.AlignPosition.Enabled = true
			angularVelocity.Enabled = true
			clone6:GetScale()
			local folder2 = clone6
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
					task.wait(v3 / 2)
					primaryPart3.AlignPosition.Position = position + createVector(0, 5, 0)
				end)
				task.wait(0.035 * math.random() + 0.1)

				for i2, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v9 = effect
						task.delay(1, function()
							v9:Destroy()
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
			local scale = clone5:GetScale()
			local v3 = scale * 0.01

			for i = scale * 100, v3 * 100, -25 do
				clone5:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)
	task.spawn(function()
		for _ = 1, 10 do
			task.spawn(function()
				local v3 = math.random(45, 50) / 100
				local clone5 = x_Attract_Held.Phase2.TrailModel:Clone()
				clone5.Start.CFrame = CFrame.new(position) * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				)
				Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
				clone5:ScaleTo(math.random(20, 25) / 7)
				local start = clone5.Start
				local trail = clone5.Trail
				local cframe2 = CFrame.new(0, 0, -math.random(100, 150) * 1.25)
				TweenService:Create(trail.Weld, TweenInfo.new(v3 / 5), {
					C1 = cframe2
				}):Play()
				TweenService:Create(start, TweenInfo.new(v3), {
					CFrame = CFrame.new(position) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
				}):Play()
				trail.Weld.C1 = CFrame.new(0, 0, 0)
				task.delay(v3 / 5, function()
					TweenService:Create(trail.Weld, TweenInfo.new(v3 / 2), {
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

				for _, effect in pairs(clone5:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = true
					local v4 = effect
					task.delay(v3 + v3 / 5, function()
						v4.Enabled = false
					end)
				end

				task.wait(v3)
				angularVelocity.Enabled = false
				task.wait(v3)
				clone5:Destroy()
			end)
		end
	end)
	task.wait(0.1)
	task.wait(0.1)
	local clone5 = x_Attract_Held.Phase3.ExStartImpact:Clone()
	clone5.CFrame = cframe
	Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
	DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.wait(0.15)
	magnetModel:Destroy()

	for _, emitter in pairs(primaryPart2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	clone:SetAttribute("End", true)
	local explosion = Explosion(cframe, folder, raycastParams, player)
	local clone6 = x_Attract_Held.Phase3.ExplosionFinalModel:Clone()
	clone6:ScaleTo(3)
	local primaryPart3 = clone6.PrimaryPart
	primaryPart3.CFrame = cframe
	Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")

	if (workspace.CurrentCamera.CFrame.p - cframe.Position).Magnitude < 180 then
		Util.CameraShaker:ShakeOnce(11, 8, 0.2, 0.6)
	end

	for _, emitter in pairs(primaryPart3:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = emitter
		task.spawn(function()
			if v4:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v4:GetAttribute("EmitDelay"))
			end

			local lifetime = v4.Lifetime
			v4.Lifetime = NumberRange.new(lifetime.Min * 2, lifetime.Max * 2)
			v4:Emit(v4:GetAttribute("EmitCount") * 1.25)
			task.wait(0.1)
			TweenService:Create(v4, TweenInfo.new(0.15), {
				TimeScale = 0.25
			}):Play()
			task.wait(0.15)
			TweenService:Create(v4, TweenInfo.new(0.1), {
				TimeScale = 1
			}):Play()
		end)
	end

	task.delay(0.1, function()
		DeleteImpactAfterDuration(primaryPart3) -- equivalent call inferred; original call site unknown
	end)
	local position2 = root.Position
	local v4 = Util.Sound:Play("Magnet_Transformed_X_Held_Looped_Zone_01", position2)
	TweenService:Create(v4, TweenInfo.new(1), {
		Volume = 1
	}):Play()
	task.spawn(function()
		for i = 1, 5 do
			local v5 = i
			task.spawn(function()
				local v6 = 13
				local clone7 = x_Attract_Held.Phase3.SpinSlash:Clone()
				clone7:PivotTo(cframe * CFrame.new(0, 10, 0))
				Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")

				if v5 == 2 then
					clone7:PivotTo(cframe * CFrame.new(0, 35, 0))
					v6 = 10
				elseif v5 == 3 then
					clone7:PivotTo(cframe * CFrame.new(0, 60, 0))
					v6 = 8
				elseif v5 == 4 then
					clone7:PivotTo(cframe * CFrame.new(0, -35, 0))
					v6 = 10
				elseif v5 == 5 then
					clone7:PivotTo(cframe * CFrame.new(0, -60, 0))
					v6 = 8
				end

				local model = clone7.Model

				for i2 = 1, 3 do
					local v7 = v6 + i2 * 1.05
					local clone8 = model:Clone()
					clone8:ScaleTo(v7 + 1.75)
					local primaryPart4 = clone8.PrimaryPart
					local v8 = clone7.PrimaryPart.CFrame * CFrame.new(0, v7, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					local angularVelocity = primaryPart4.AngularVelocity
					primaryPart4.Anchored = false
					primaryPart4.AlignPosition.Position = primaryPart4.Position + Vector3.new(
						math.random(-10, 10) / 10,
						0,
						math.random(-10, 10) / 10
					)
					angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15), 0)
					clone8:PivotTo(v8)
					Util.SetParentOverrideWithColor(clone8, clone7, player, "MagnetFruitVFXColor")
					clone8:GetScale()
					local folder2 = clone8
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
								local v10 = effect
								task.delay(1, function()
									v10:Destroy()
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
					local scale = clone7:GetScale()
					local v7 = scale * 1.5

					for i2 = scale * 100, v7 * 100, 7 do
						clone7:ScaleTo(i2 / 100)
						task.wait(0.005)
					end
				end)
			end)
		end
	end)
	task.spawn(function()
		local clone7 = x_Attract_Held.Phase1.Sphere:Clone()
		clone7.Size = createVector(62.5, 62.5, 62.5)
		clone7.CFrame = CFrame.new(cframe.Position + createVector(0, 15, 0), workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
			math.random(-180, 180),
			math.random(-180, 180),
			math.random(-180, 180)
		)
		Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
		task.spawn(function()
			TweenService:Create(clone7, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = clone7.Size * 3.7
			}):Play()

			for _, decal in pairs(clone7:GetDescendants()) do
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
			local clone8 = x_Attract_Held.Phase1.Sphere1:Clone()
			clone8.Size = createVector(62.5, 62.5, 62.5)
			clone8.CFrame = CFrame.new(
				cframe.Position + createVector(0, 15, 0),
				workspace.CurrentCamera.CFrame.Position
			) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			Util.SetParentOverrideWithColor(clone8, folder, player, "MagnetFruitVFXColor")
			task.spawn(function()
				TweenService:Create(clone8, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = clone8.Size * 3.7
				}):Play()

				for _, decal in pairs(clone8:GetDescendants()) do
					if not decal:IsA("Decal") then
						continue
					end

					decal.Transparency = 0.5
					TweenService:Create(decal, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Transparency = 1,
						StudsPerTileU = math.random(15, 20) * 2,
						StudsPerTileV = math.random(15, 20) * 2
					}):Play()
				end
			end)
		end)
		task.spawn(function()
			for i = 1, 10 do
				local v5 = i
				task.spawn(function()
					local clone8 = script.Part:Clone()
					local cFrame2 = CFrame.new(cframe.Position) * CFrame.new(0, math.random(0, 10), 0) * CFrame.Angles(
						math.rad(math.random(-180, 180) / 1),
						math.rad((math.random(-180, 180))),
						(math.rad(math.random(-180, 180) / 1))
					) * CFrame.new(0, 0, -105)
					clone8.CFrame = cFrame2
					Util.SetParentOverrideWithColor(clone8, folder, player, "MagnetFruitVFXColor")
					clone8.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 210).Position
					local shafiBolt = ShafiBolt(clone8.Attach0, clone8.Attach1, math.random(8, 12) * 1.25, 0.75, folder)
					shafiBolt.CurveSize0 = -90
					shafiBolt.CurveSize1 = 90
					shafiBolt.Frequency = math.random(5, 10) * 2
					shafiBolt.MaxRadius = 12
					shafiBolt.AnimationSpeed = math.random(20, 50) / 10
					local v8 = player
					local color = Color3.fromRGB(51, 71, 255)

					if typeof(v8) == "Instance" and v8.Parent then
						color = WrapColor3Constructor(color, v8, "MagnetFruitVFXColor")
					end

					shafiBolt.Color = color

					if v5 % 2 == 0 then
						local v9 = player
						local color2 = Color3.fromRGB(72, 66, 255)

						if typeof(v9) == "Instance" and v9.Parent then
							color2 = WrapColor3Constructor(color2, v9, "MagnetFruitVFXColor")
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
	task.spawn(function()
		for i = 3, 5 do
			local v5 = i
			task.spawn(function()
				local v6 = 15
				local clone7 = x_Attract_Held.Phase3.AirSpin:Clone()
				clone7:PivotTo(cframe * CFrame.new(0, 10, 0))
				Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")

				if v5 == 2 then
					clone7:PivotTo(cframe * CFrame.new(0, 25, 0))
					v6 = 13
				elseif v5 == 3 then
					clone7:PivotTo(cframe * CFrame.new(0, 50, 0))
					v6 = 12
				elseif v5 == 4 then
					clone7:PivotTo(cframe * CFrame.new(0, 75, 0))
					v6 = 8
				elseif v5 == 5 then
					clone7:PivotTo(cframe * CFrame.new(0, 100, 0))
					v6 = 7
				end

				local v7 = v6 / 1.5
				local model = clone7.Model

				for i2 = 1, 2 do
					local v8 = v7 + 3 + i2 * 1.05
					local clone8 = model:Clone()
					clone8:ScaleTo(v8)
					local primaryPart4 = clone8.PrimaryPart
					local v9 = clone7.PrimaryPart.CFrame * CFrame.new(0, v8, 0) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					)
					local angularVelocity = primaryPart4.AngularVelocity
					primaryPart4.Anchored = false
					primaryPart4.AlignPosition.Position = primaryPart4.Position + Vector3.new(
						math.random(-10, 10) / 10,
						0,
						math.random(-10, 10) / 10
					)
					angularVelocity.AngularVelocity = Vector3.new(
						math.random(-5, 5) / 5,
						math.random(10, 15) * 3,
						math.random(-5, 5) / 5
					)
					clone8:PivotTo(v9)
					Util.SetParentOverrideWithColor(clone8, clone7, player, "MagnetFruitVFXColor")
					clone8:GetScale()
					local folder2 = clone8
					task.spawn(function()
						task.spawn(function()
							local Y = folder2.Slash.Position.Y
							task.wait(0.1)
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = createVector(0, 5, 0)
								}
							):Play()
							task.wait(0.15)
							TweenService:Create(
								angularVelocity,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									AngularVelocity = Vector3.new(
										math.random(-5, 5) / 10,
										math.random(5, 15),
										math.random(-5, 5) / 10
									)
								}
							):Play()
						end)
						task.wait(0.1 * math.random() + 0.225)

						for i3, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.15 + math.random() * 0.15), {
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

				model:Destroy()
				task.spawn(function()
					local scale = clone7:GetScale()
					local v8 = scale * 1.75

					for i2 = scale * 100, v8 * 100, 5 do
						clone7:ScaleTo(i2 / 100)
						task.wait(0.005)
					end
				end)
			end)
		end
	end)
	task.spawn(function()
		local clone7 = x_Attract_Held.Phase1.SpinSlash:Clone()
		clone7:PivotTo(cframe * CFrame.Angles(1.5707963267948966, 0, 0))
		Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
		local model2 = clone7.Model2
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(28, 39, 255))),
			ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(28, 39, 255)))
		})
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.825),
			NumberSequenceKeypoint.new(1, 0.825)
		})
		local v5 = -10

		for i = 3, 5 do
			local v6 = i * 1.05 + 16.666666666666668
			local v7 = 1
			local clone8 = model2:Clone()

			if i == 1 then
				v6 += -1
			elseif i == 2 then
				v6 += 5
				v7 = 1
				v5 = -30
			elseif i == 3 then
				v6 += 2
				v7 = 1
				v5 = -75
			elseif i == 4 then
				v6 += -3
				v7 = 1
				v5 = -100
			elseif i == 5 then
				v6 += -7.5
				v7 = 1
				v5 = -150
			end

			clone8:ScaleTo(v6 / v7)

			for _, beam in pairs(clone8:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				if colorSequence ~= nil then
					beam.Color = colorSequence
					beam.Transparency = numberSequence
				end

				beam.Enabled = true
			end

			local primaryPart4 = clone8.PrimaryPart
			local v8 = clone7.PrimaryPart.CFrame * CFrame.new(0, 0, v5 / 2) * CFrame.Angles(
				math.rad(math.random(-180, 180) / 100),
				math.rad(math.random(-180, 180) / 100),
				(math.rad((math.random(-180, 180))))
			)
			local angularVelocity = primaryPart4.AngularVelocity
			primaryPart4.Anchored = false
			primaryPart4.AlignPosition.Position = primaryPart4.CFrame * createVector(0, 0, -25)
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
			clone8:PivotTo(v8)
			local v9 = i
			task.spawn(function()
				task.wait(v9 * 0.025)
				Util.SetParentOverrideWithColor(clone8, clone7, player, "MagnetFruitVFXColor")
			end)
			clone8:GetScale()
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
				task.wait(0.15 * math.random() + 0.2 / v7)

				for i2, effect in pairs(clone8:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.15 / v7 + math.random() * 0.15 / v7), {
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
			local v6 = clone7:GetScale() * 0.5
			local v7 = v6 * 1.15

			for i = v6 * 100, v7 * 100, 10 do
				clone7:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
	end)

	for _ = 1, 7 do
		task.spawn(function()
			local clone7 = children[math.random(1, #children)]:Clone()
			local v5 = cframe.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
			clone7.CFrame = CFrame.new(v5)
			clone7.Anchored = false
			clone7.CanCollide = false
			clone7.Size = clone7.Size * math.random(10, 25) / 10
			Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
			task.delay(0.15, function()
				clone7.CanCollide = true
			end)
			clone7.AssemblyLinearVelocity = (v5 - cframe.Position).Unit * math.random(120, 220) + Vector3.new(
				math.random(-25, 25),
				math.random(30, 80),
				math.random(-25, 25)
			)
			clone7.AssemblyAngularVelocity = Vector3.new(
				math.random(-20, 20),
				math.random(-20, 20),
				math.random(-20, 20)
			)
			task.delay(1 + math.random() * 0.5, function()
				TweenService:Create(clone7, TweenInfo.new(0.5), {
					Size = createVector(0, 0, 0)
				}):Play()
				task.wait(0.5)
				clone7:Destroy()
			end)
		end)
	end

	task.spawn(function()
		local clone7 = x_Attract_Held.Phase3.RingBeamModel:Clone()
		clone7:PivotTo(cframe * CFrame.Angles(0, 0, 0))
		Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(82, 91, 255))),
			ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(82, 91, 255)))
		})
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.09),
			NumberSequenceKeypoint.new(1, 0.09)
		})

		for i = 1, 1 do
			local v5 = i * 1.05 + 5
			local v6 = 1

			if i == 1 then
				v5 += -1
			elseif i == 2 then
				v5 += 5
				v6 = 1
			elseif i == 3 then
				v5 += 2
				v6 = 1
			elseif i == 4 then
				v5 += -3
				v6 = 1
			elseif i == 5 then
				v5 += -7.5
				v6 = 1
			end

			clone7:ScaleTo(v5 / v6)

			for _, beam in pairs(clone7:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				if colorSequence ~= nil then
					beam.Color = colorSequence
					beam.Transparency = numberSequence
				end

				beam.Enabled = true
			end

			local primaryPart4 = clone7.PrimaryPart
			local _ = clone7.PrimaryPart.CFrame
			local angularVelocity = primaryPart4.AngularVelocity
			primaryPart4.Anchored = false
			primaryPart4.AlignPosition.Position = primaryPart4.CFrame * createVector(0, 75, -0.25)
			angularVelocity.Enabled = false
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
			local v7 = i
			task.spawn(function()
				task.wait(v7 * 0.025)
			end)
			clone7:GetScale()
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

				for i2, beam in pairs(clone7:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.1), {
							Width0 = beam.Width0 * 5.5,
							Width1 = beam.Width1 * 5.5
						}):Play()
					end
				end

				task.wait(0.1)

				for i2, effect in pairs(clone7:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.05), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v9 = effect
						task.delay(1, function()
							v9:Destroy()
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
			local v5 = clone7:GetScale() * 1
			local v6 = v5 * 1.35

			for i = v5 * 100, v6 * 100, 55 do
				clone7:ScaleTo(i / 100)
				task.wait()
			end

			local scale = clone7:GetScale()
			local v7 = scale * 0.25

			for i = scale * 100, v7 * 100, -100 do
				clone7:ScaleTo(i / 100)
				task.wait()
			end
		end)
	end)
	local fieldDuration = data.FieldDuration
	local v5 = tick() + fieldDuration
	local clone7 = x_Attract_Held.Phase3.FieldAura:Clone()
	clone7:ScaleTo(3)
	clone7:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")

	for _, emitter in pairs(clone7:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v6 = emitter
		task.spawn(function()
			v6.Enabled = true
			v6:Emit(1)
			task.wait(fieldDuration)
			v6.Enabled = false
		end)
	end

	task.spawn(function()
		if explosion then
			local cFrame2 = AlignCFrame(CFrame.new(explosion.Position), explosion.Normal) + explosion.Normal * 0.01
			local clone8 = x_Attract_Held.Phase3.GroundRing:Clone()
			clone8.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone8, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone8:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v7 = emitter
				task.spawn(function()
					v7.Enabled = true
					v7:Emit(1)
					task.wait(fieldDuration)
					v7.Enabled = false
				end)
			end
		end
	end)
	task.spawn(function()
		local now = tick()

		while tick() < v5 do
			if now - tick() <= 0 then
				now = tick() + 0.07

				for i = 1, math.random(1, 3) do
					local v6 = i
					task.spawn(function()
						local v7 = math.random(70, 125)
						local clone8 = script.Part:Clone()
						local cFrame2 = CFrame.new(clone.Position) * CFrame.Angles(
							math.random(-180, 180),
							math.rad((math.random(-180, 180))),
							math.random(-180, 180)
						) * CFrame.new(0, 0, v7)
						clone8.CFrame = cFrame2
						Util.SetParentOverrideWithColor(clone8, folder, player, "MagnetFruitVFXColor")
						clone8.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, -v7).Position
						local shafiBolt = ShafiBolt(clone8.Attach0, clone8.Attach1, math.random(5, 10), 1, folder)
						shafiBolt.CurveSize0 = -v7 / 2
						shafiBolt.CurveSize1 = v7 / 2
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 10
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v10 = player
						local color = Color3.fromRGB(53, 63, 255)

						if typeof(v10) == "Instance" and v10.Parent then
							color = WrapColor3Constructor(color, v10, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v6 % 2 == 0 then
							local v11 = player
							local color2 = Color3.fromRGB(63, 49, 255)

							if typeof(v11) == "Instance" and v11.Parent then
								color2 = WrapColor3Constructor(color2, v11, "MagnetFruitVFXColor")
							end

							shafiBolt.Color = color2
						end

						task.spawn(function()
							task.wait(0.05 + math.random() * 0.1)
							shafiBolt:Destroy()
						end)
					end)
				end
			end

			task.wait(0.05)
		end
	end)
	local position3 = cframe.Position
	local clones = {}
	local v6 = true

	for i = 1, 15 do
		local v7 = i
		task.spawn(function()
			local clone8 = children[math.random(1, #children)]:Clone()
			clone8.Anchored = true
			clone8.CanCollide = false
			clone8.Size *= math.random(15, 25) / 10
			clone8.CFrame = CFrame.new(position3)
			Util.SetParentOverrideWithColor(clone8, folder, player, "MagnetFruitVFXColor")
			local attachment = Instance.new("Attachment")
			attachment.Name = "BeamAttachment"
			attachment.Position = createVector(0, 0, 0)
			attachment.Parent = clone8
			local v8 = math.rad((v7 - 1) * 21.428571428571427 + 30)
			local v9 = position3 + Vector3.new(math.cos(v8) * 125, 0, math.sin(v8) * 125)
			local tween = TweenService:Create(
				clone8,
				TweenInfo.new(0.215, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					CFrame = CFrame.new(v9)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			clones[v7] = clone8
			task.delay(math.random() * 0.5, function()
				CFrame.Angles(0, 0, 0)

				while v6 and clone8 and clone8.Parent do
					local cframe2 = CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					local v10 = v9 + Vector3.new(0, 12 * (math.random(0, 1) == 0 and 1 or -1), 0)
					local v11 = 0.5 * (math.random(8, 16) / 10)
					local tween2 = TweenService:Create(
						clone8,
						TweenInfo.new(v11, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							CFrame = CFrame.new(v10) * cframe2
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
				end
			end)
		end)
	end

	task.wait(0.265)
	local v7 = {}

	for i = 1, #clones do
		local v8 = clones[i]
		local v9 = clones[i % #clones + 1]

		if not (v8 and v9) then
			continue
		end

		local beamAttachment = v8:FindFirstChild("BeamAttachment")
		local beamAttachment2 = v9:FindFirstChild("BeamAttachment")

		if not (beamAttachment and beamAttachment2) then
			continue
		end

		local shafiBolt = ShafiBolt(beamAttachment, beamAttachment2, math.random(8, 12), 0.7, folder)
		shafiBolt.Frequency = math.random(5, 10) * 2
		shafiBolt.MaxRadius = 10
		shafiBolt.AnimationSpeed = math.random(20, 50) / 10
		local color

		if i % 2 == 0 then
			color = Color3.fromRGB(69, 32, 255)
		else
			color = Color3.fromRGB(33, 48, 255)
		end

		if typeof(player) == "Instance" and player.Parent then
			color = WrapColor3Constructor(color, player, "MagnetFruitVFXColor")
		end

		shafiBolt.Color = color
		table.insert(v7, shafiBolt)
	end

	local function getClosestScraps(position4, p)
		local v8 = {}

		for _, scrap in ipairs(clones) do
			if scrap and scrap.Parent then
				table.insert(v8, {
					scrap = scrap,
					dist = (scrap.Position - position4).Magnitude
				})
			end
		end

		table.sort(v8, function(a, b)
			return a.dist < b.dist
		end)
		local scraps2 = {}

		for i = 1, math.min(p, #v8) do
			table.insert(scraps2, v8[i].scrap)
		end

		return scraps2
	end

	local function playRigVisual(child)
		local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = createVector(0.1, 0.1, 0.1)
		part.CFrame = humanoidRootPart.CFrame
		part.Parent = folder
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		local closestScraps = getClosestScraps(humanoidRootPart.Position, 1)
		local v8 = {}

		for _, closestScrap in ipairs(closestScraps) do
			local beamAttachment = closestScrap:FindFirstChild("BeamAttachment")

			if not beamAttachment then
				continue
			end

			local shafiBolt = ShafiBolt(beamAttachment, attachment, math.random(5, 7) * 2, 1, folder)
			shafiBolt.Frequency = math.random(10, 20)
			shafiBolt.MaxRadius = math.random(8, 18)
			shafiBolt.AnimationSpeed = math.random(40, 80) / 30
			local v10 = player
			local color = Color3.fromRGB(108, 123, 255)
			local color2 = Color3.fromRGB(19, 19, 255)

			if typeof(v10) == "Instance" and v10.Parent then
				color = WrapColor3Constructor(color, v10, "MagnetFruitVFXColor")
			end

			shafiBolt.Color = ColorSequence.new(color, RecolorMagnetColor(v10, color2))
			table.insert(v7, shafiBolt)
			table.insert(v8, shafiBolt)
		end

		task.spawn(function()
			while v6 and humanoidRootPart and humanoidRootPart.Parent do
				part.CFrame = humanoidRootPart.CFrame
				task.wait()
			end

			for _, v9 in ipairs(v8) do
				local v10 = v9
				pcall(function()
					v10:Destroy()
				end)
			end

			task.wait()
			part:Destroy()
		end)
	end

	for _, childName in ipairs({ "Characters", "Enemies" }) do
		local child = workspace:FindFirstChild(childName)

		if not child then
			continue
		end

		for _, child2 in ipairs(child:GetChildren()) do
			if child2 == data.Player.Character then
				continue
			end

			local humanoidRootPart = child2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				continue
			end

			local magnitude = (humanoidRootPart.Position - position3).Magnitude

			if magnitude > 125 and magnitude <= 160 then
				playRigVisual(child2)
			end
		end
	end

	task.delay(fieldDuration, function()
		v6 = false

		for _, v8 in ipairs(v7) do
			v8:Destroy()
		end
	end)
	task.delay(fieldDuration - 0.215, function()
		v6 = false

		if v4 then
			Util.Sound:FadeOut(v4, 0.2)
			Util.Sound:Play("Magnet_Transformed_X_Held_Looped_Zone_Disappear_01", position2)
		end

		for _, v8 in ipairs(clones) do
			if not (v8 and v8.Parent) then
				continue
			end

			v8.Anchored = false
			v8.CanCollide = true
			local v9 = v8
			task.delay(0.5, function()
				task.wait(math.random() * 0.5)
				TweenService:Create(v9, TweenInfo.new(0.4), {
					Size = createVector(0, 0, 0)
				}):Play()
			end)
		end
	end)
end