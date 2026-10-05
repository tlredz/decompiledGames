local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local z_Attract_Held = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Z_Attract_Held")
local cannon = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Cannon")
local cannonArcsteel = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("CannonArcsteel")
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
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
local Effect = require(game.ReplicatedStorage.Effect)
local superhumanV2Travel = Effect.new("SuperhumanV2.Travel")
local _WorldOrigin = workspace._WorldOrigin

-- equivalent calls inferred from this helper; original call sites unknown
local function RecolorMagnetColor(p, p2)
	return WrapColor3Constructor(p2, p, "MagnetFruitVFXColor")
end

local function RecolorMagnetColorSequence(player, color)
	local recolorMagnetColor = RecolorMagnetColor(player, color) -- equivalent call inferred; original call site unknown
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, recolorMagnetColor),
		ColorSequenceKeypoint.new(1, recolorMagnetColor)
	})
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

local function GroundHit(p, p2, parent)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyAfter(clone, duration)
		task.delay(duration, function()
			clone:Destroy()
		end)
	end

	local function AlignCFrame(data, normal)
		local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
		local p3 = data.p
		local unit = data.LookVector:Cross(v2).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
		local unit3 = unit2:Cross(v2).Unit
		return CFrame.fromMatrix(p3, unit2, v2, unit3)
	end

	local function RockCrater(p3, parent2, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v2 = AlignCFrame(CFrame.new(p3.Position), p3.Normal) + p3.Normal * 0.01
			local v3 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent2
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
				v5.CFrame = CFrame.new(v5.Position, p3.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v5.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = p2.FilterDescendantsInstances
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(
					v5.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams
				)

				if raycastResult then
					local v6 = (v5.Position - p3.Position).Magnitude / 50
					print(v6)
					local v7 = size * math.random(20, 40) / 10
					local v8 = size * math.random(10, 30) / 10
					local v9 = size * math.random(30, 50) / 10
					v5.Size = Vector3.new(v7 / 2 + v7 * v6, v8 / 2 + v8 * v6, v9 / 2 + v9 * v6)
					v5.Position = raycastResult.Position + Vector3.new(0, -v5.Size.Y / 2, 0)
					v5.CFrame = CFrame.new(v5.Position, p3.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-25, 25) / 5
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

	local function FlyRock(cFrame, raycastResult, parent2)
		local clone = z_Attract_Held.Phase2.Rock:Clone()
		rocks:ApplyCollision(clone, nil, true)
		clone.CFrame = cFrame
		clone.Size += Vector3.new(0, math.random(0, 10) / 10, 0)
		clone.Size *= math.random(3, 5) / 5
		clone.Orientation = Vector3.new(math.random(-90, 90), math.random(-90, 90), math.random(-90, 90))
		clone.Material = raycastResult.Instance.Material
		clone.Color = raycastResult.Instance.Color
		clone.CanCollide = false
		clone.Parent = parent2
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(70000000000, 70000000000, 70000000000)
		bodyVelocity.P = 5000
		bodyVelocity.Parent = clone
		local vector2 = Vector3.new(math.random(-30, 30) * 1.5, 0, math.random(-30, 30) * 1.5)
		local vector3 = Vector3.new(0, math.random(150, 200) * 2, 0)
		local v2 = math.random(50, 150) * 0.75
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(1 * math.random() + 2.5, function()
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

	local v2 = p * CFrame.new(0, 0, -13.5)
	local raycastResult = workspace:Raycast(v2.Position + createVector(0, 1, 0), createVector(-0, -25, -0), p2)

	if raycastResult then
		local v3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v4 = {
			Radius = 25,
			Size = 2,
			Duration = 1,
			Amount = 5,
			RockType = z_Attract_Held.Phase2.CraterRock
		}
		task.spawn(function()
			local rockType = v4.RockType
			local radius = v4.Radius
			local size = v4.Size
			local duration = v4.Duration
			local amount = v4.Amount
			local v5 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			local v6 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v6, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v7 in pairs(v6) do
					v7:Destroy()
				end

				v6 = nil
			end)
			local v7 = 360 / #v6
			local total = 0

			for _, v8 in pairs(v6) do
				total += v7
				v8.CFrame = v5 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v8.CFrame = CFrame.new(v8.Position, raycastResult.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v8.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = p2.FilterDescendantsInstances
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult2 = workspace:Raycast(
					v8.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams
				)

				if raycastResult2 then
					local v9 = (v8.Position - raycastResult.Position).Magnitude / 50
					print(v9)
					local v10 = size * math.random(20, 40) / 10
					local v11 = size * math.random(10, 30) / 10
					local v12 = size * math.random(30, 50) / 10
					v8.Size = Vector3.new(v10 / 2 + v10 * v9, v11 / 2 + v11 * v9, v12 / 2 + v12 * v9)
					v8.Position = raycastResult2.Position + Vector3.new(0, -v8.Size.Y / 2, 0)
					v8.CFrame = CFrame.new(v8.Position, raycastResult.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-25, 25) / 5
					)
					v8.CFrame = CFrame.new(v8.Position, v5.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v9)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v8.Material = raycastResult2.Instance.Material
					v8.Color = raycastResult2.Instance.Color
				else
					v8:Destroy()
					v6[v8] = nil
				end

				TweenService:Create(v8, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v8.Position + Vector3.new(0, v8.Size.Y / 1.75, 0)
				}):Play()
				local v9 = v8
				local v10 = v8
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
					v6[v9] = nil
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 5 do
				task.spawn(function()
					FlyRock(
						v3 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							0,
							0,
							-math.random(125, 150) / 7
						),
						raycastResult,
						parent
					)
				end)

				if i % 2 == 0 then
					task.wait(0.001 * math.random())
				end
			end
		end)
		task.spawn(function() end)
	end
end

local function AlignCFrame(data, normal)
	local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(p, unit2, v2, unit3)
end

local function Explosion(cframe2, folder, raycastParams)
	local function Scale(instance, p)
		local position = cframe2.Position

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
		local clone = z_Attract_Held.Phase3.Rock:Clone()
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
		local vector2 = Vector3.new(math.random(-30, 30) * 2, 0, math.random(-30, 30) * 2)
		local vector3 = Vector3.new(0, math.random(500, 1000) / 1, 0)
		local v2 = math.random(50, 150) * 1.75
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v2
		task.delay(1 * math.random() + 1.5, function()
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

	task.spawn(function() end)
	local raycastResult = workspace:Raycast(
		cframe2.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if not raycastResult then
		return
	end

	local v2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
	local v3 = {
		Radius = 93.75,
		Size = 15,
		Duration = 0.75,
		Amount = 35,
		RockType = z_Attract_Held.Phase3.CraterRock
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
					v2 * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
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
	return raycastResult
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local v2 = hasCrimsonGoldSkin(player) and "Arcsteel " or ""

	if data.Stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin

		repeat
			task.wait()
		until not holding or not holding.Value or root:FindFirstChild("MagnetZHeldTransition")

		Util.Debris:AddItem(folder, 2)
	else
		local rig = data.Rig

		if not rig then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 10)
		local child = workspace._WorldOrigin:FindFirstChild(player.Name .. "_MagnetRocket")

		if child then
			child.Name = "DESTROYING"
			child:SetAttribute("Destroy", true)
			Util.Debris:AddItem(child, 2)
		end

		local _ = data.Root
		local startCFrame = data.StartCFrame
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local phase1 = z_Attract_Held.Phase1
		local crimsonGoldSkin = hasCrimsonGoldSkin(data.Player)
		local v3

		if crimsonGoldSkin then
			v3 = cannonArcsteel
		else
			v3 = cannon
		end

		local clone = v3:Clone()
		local v4

		if crimsonGoldSkin then
			v4 = rig.PrimaryPart.CFrame * cframe
		else
			v4 = rig.PrimaryPart.CFrame
		end

		clone:PivotTo(v4)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Transformed_Z_Held_LaserGun_Assemble_01", clone.PrimaryPart)
		local cannon1 = clone:FindFirstChild("Cannon1", true)
		local v5 = Util.Anims:Get(clone, v2 .. "Magnet Cannon Z+V Hold Start")
		v5.Priority = Enum.AnimationPriority.Action2
		v5.Looped = false
		v5:Play()
		local v6 = Util.Anims:Get(clone, v2 .. "Magnet Cannon Z+V Hold Loop")
		v6.Looped = true
		v6:Play()
		local v7 = false
		task.spawn(function()
			while not v7 and rig and clone do
				local v9

				if crimsonGoldSkin then
					v9 = rig.PrimaryPart.CFrame * cframe
				else
					v9 = rig.PrimaryPart.CFrame
				end

				clone:PivotTo(v9)
				task.wait()
			end
		end)
		task.wait(0.5)

		local function triggerExplosionAt(position: Vector3, _: Vector3?)
			local clone2 = phase1.FloorExplosion:Clone()
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			clone2.CFrame = CFrame.new(position)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v8 = emitter
				task.spawn(function()
					local emitDelay = v8:GetAttribute("EmitDelay") or 0

					if emitDelay ~= 0 then
						task.wait(emitDelay)
					end

					v8:Emit((v8:GetAttribute("EmitCount")))
				end)
			end
		end

		local clone2 = z_Attract_Held.Phase1.GroundFlameTrail:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
		local v8 = false
		local v9 = false

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local v10 = false

		local function GroundBurn(position, p, _)
			local random = Random.new()
			local raycastResult = workspace:Raycast(
				position + createVector(0, 1, 0),
				createVector(-0, -25, -0),
				raycastParams
			)

			if raycastResult then
				local v11 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
				clone2.CFrame = v11 * CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0)

				if v8 == false then
					v8 = true

					for _, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					if v10 == false then
						v10 = true
						local clone3 = phase1.GroundBurn:Clone()
						clone3.CFrame = v11 * CFrame.Angles(0, random:NextNumber(-1, 1) * 3.141592653589793, 0)
						Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

						for _, emitter in pairs(clone3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v12 = emitter
							task.spawn(function()
								v12:Emit(1)
								v12.Enabled = true
								task.wait(0.115)
								v12.Enabled = false
							end)
						end
					end
				end

				for i = 1, 12 do
					local _ = i * 30

					if p then
						local _ = math.random(1, 100) <= 50
					end
				end
			end
		end

		local mousePos = data.MousePos
		local clone3 = z_Attract_Held.Phase1.Arm:Clone()
		Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
		clone3.CFrame = CFrame.lookAt(cannon1.WorldPosition, mousePos.Value)
		local cFrame = clone3.CFrame
		local clone4 = phase1.StartImpact:Clone()
		clone4.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v11 = emitter
			task.spawn(function()
				if v11:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v11:GetAttribute("EmitDelay"))
				end

				v11:Emit(v11:GetAttribute("EmitCount"))
			end)
		end

		Util.Sound:Play("Magnet_Transformed_Z_Held_BeamFireActivate_02", clone.PrimaryPart)
		task.wait(0.16666666666666666)

		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function easeOutQuad(p)
			return 1 - (1 - p) * (1 - p)
		end

		local clone5 = phase1.Beam:Clone()
		clone5.CFrame = cFrame
		clone5.Part2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
		local v11 = data.Player == game.Players.LocalPlayer and 20 or nil
		local v12 = Util.Sound:Play("Magnet_Transformed_Z_Held_Looped_BeamFire_01", clone.PrimaryPart, v11)
		TweenService:Create(v12, TweenInfo.new(0.7), {
			Volume = 1.66
		}):Play()
		local v13 = {}

		for _, emitter in pairs(clone5:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			local cframe2 = CFrame.lookAt(clone3.Position, mousePos.Value)
			local v14 = 1 - math.exp(-20 * dt)
			cFrame = cFrame:Lerp(cframe2, v14)
			clone5.Attachment.WorldCFrame = clone5.Attachment.CFrame.Rotation + cframe2.Position

			for i = #v13, 1, -1 do
				local v15 = v13[i]
				v15.age += dt
				local v17 = easeOutQuad(math.clamp(v15.age / v15.life, 0, 1))
				local v18 = 90 * v17
				local v19 = 150 * v17
				v15.p.CFrame = cFrame * CFrame.Angles(1.5707963267948966, v15.yaw, 3.141592653589793) * CFrame.new(
					0,
					v18,
					0
				)
				v15.mesh.Scale = Vector3.new(0, v19, 0)

				if not (v15.age >= v15.life) then
					continue
				end

				v15.p:Destroy()
				table.remove(v13, i)
			end
		end)
		local clone6 = phase1.StartAura:Clone()
		clone6.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone6:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local part2 = clone5.Part2
		part2.CFrame = clone5.CFrame
		local clone7 = phase1.BeamParticles:Clone()
		clone7.CFrame = clone5.CFrame
		clone7.Size *= createVector(3, 3, 0)
		Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone8 = phase1.End:Clone()
		clone8.CFrame = part2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		Util.SetParentOverrideWithColor(clone8, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone8:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone9 = phase1.EndTip:Clone()
		clone9.CFrame = part2.CFrame
		Util.SetParentOverrideWithColor(clone9, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone9:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			emitter.Rate *= 1.25
			emitter.Enabled = true
		end

		local v14 = tick() + 1.5
		local v15 = false
		local v16 = false
		local now = tick()
		local now2 = tick()
		local now3 = tick()
		local renderSteppedConnection2 = nil
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			clone3.CFrame = CFrame.lookAt(cannon1.WorldPosition, mousePos.Value)
			cFrame = clone3.CFrame
			local _ = (v14 - tick()) / 1.5

			if v14 < tick() then
				task.spawn(function()
					if not v9 then
						v9 = true
						local position = cFrame.Position + cFrame.LookVector * 225
						part2.Position = position
						task.spawn(function()
							triggerExplosionAt(position, nil)
							print("triggering")
							task.spawn(function() end)
						end)
					end
				end)
				renderSteppedConnection2:Disconnect()
				v15 = true
			else
				local raycastResult = workspace:Raycast(cFrame.Position, cFrame.LookVector * 225, raycastParams)
				local v17 = nil
				local position = nil
				local normal = nil

				if raycastResult then
					v17 = true
					position = raycastResult.Position
					normal = raycastResult.Normal

					if now3 - tick() <= 0 then
						now3 = tick() + 0.05
						GroundBurn(position, true, normal)
					end
				elseif v8 == true then
					v8 = false

					for _, effect in pairs(clone2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end

				local v18 = v17 and position or cFrame.Position + cFrame.LookVector * 225

				if v17 and not v9 then
					v9 = true
					part2.Position = position
					task.spawn(function()
						triggerExplosionAt(position, normal)
					end)
				end

				part2.Position = part2.Position:Lerp(v18, dt * 24)

				if v17 and normal then
					clone9.CFrame = CFrame.new(part2.Position)
					clone8.CFrame = CFrame.lookAt(part2.Position, part2.Position - cFrame.LookVector)
				else
					clone8.CFrame = CFrame.lookAt(part2.Position, part2.Position - cFrame.LookVector)
					clone9.CFrame = CFrame.new(0, -10000, 0)
				end

				local magnitude = (part2.Position - cFrame.Position).Magnitude
				clone7.CFrame = CFrame.lookAt(cFrame.Position, part2.Position) * CFrame.new(0, 0, -magnitude / 2)
				clone7.Size = Vector3.new(clone7.Size.X, clone7.Size.Y, magnitude)
				clone6.CFrame = cFrame

				if not v16 then
					v16 = true

					for _, emitter in pairs(clone5:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end

				if now - tick() <= 0 then
					now = tick() + 0.15
					task.spawn(function()
						local clone10 = z_Attract_Held.Phase1.AirSpin:Clone()
						clone10:PivotTo(CFrame.new(v18))
						Util.SetParentOverrideWithColor(clone10, folder, player, "MagnetFruitVFXColor")
						local model2 = clone10.Model2

						for i = 1, 3 do
							local v20 = 1
							local clone11 = model2:Clone()

							if i ~= 1 then
								v20 = i == 2 and 0.95 or i == 3 and 0.9 or v20
							end

							clone11:ScaleTo((i * 1.075 + 7) / v20)

							for _, beam in pairs(clone11:GetDescendants()) do
								if beam:IsA("Beam") then
									beam.Enabled = true
								end
							end

							local primaryPart = clone11.PrimaryPart
							local v21 = clone10.PrimaryPart.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							)
							local angularVelocity = primaryPart.AngularVelocity
							primaryPart.Anchored = false
							primaryPart.AlignPosition.Position = primaryPart.Position
							angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
							clone11:PivotTo(v21)
							Util.SetParentOverrideWithColor(clone11, clone10, player, "MagnetFruitVFXColor")
							clone11:GetScale()
							task.spawn(function()
								TweenService:Create(
									angularVelocity,
									TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
											math.random(-5, 5) / 5,
											math.random(-5, 5) / 5,
											math.random(5, 10)
										)
									}
								):Play()
								task.wait(0.05 * math.random() + 0.075 / v20)

								for i2, effect in pairs(clone11:GetDescendants()) do
									if effect:IsA("Beam") then
										TweenService:Create(
											effect,
											TweenInfo.new(0.1 / v20 + math.random() * 0.1 / v20),
											{
												Width0 = 0,
												Width1 = 0
											}
										):Play()
										local v23 = effect
										task.delay(1, function()
											v23:Destroy()
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
							local v19 = clone10:GetScale() * 0.75
							local v20 = v19 * 1.15

							for i = v19 * 100, v20 * 100, 10 do
								clone10:ScaleTo(i / 100)
								task.wait(0.005)
							end
						end)
					end)
				end

				if now2 - tick() <= 0 then
					now2 = tick() + 0.15
					task.spawn(function()
						local clone10 = z_Attract_Held.Phase1.SpinSlash:Clone()
						clone10:PivotTo(cFrame)
						Util.SetParentOverrideWithColor(clone10, folder, player, "MagnetFruitVFXColor")
						local model2 = clone10.Model2
						local color = RecolorMagnetColorSequence(player, Color3.fromRGB(37, 30, 255))
						local numberSequence = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.825),
							NumberSequenceKeypoint.new(1, 0.825)
						})
						local v20 = -15

						for i = 1, 5 do
							local v21 = i * 1.05 + 7
							local v22 = 1
							local clone11 = model2:Clone()

							if i == 1 then
								v21 += -1
							elseif i == 2 then
								color = RecolorMagnetColorSequence(player, Color3.fromRGB(60, 80, 255))
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.855),
									NumberSequenceKeypoint.new(1, 0.855)
								})
								v21 += 5
								v20 = -50
								v22 = 1.25
							elseif i == 3 then
								color = RecolorMagnetColorSequence(player, Color3.fromRGB(85, 93, 255))
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.875),
									NumberSequenceKeypoint.new(1, 0.875)
								})
								v21 += 2
								v20 = -75
								v22 = 1.35
							elseif i == 4 then
								color = RecolorMagnetColorSequence(player, Color3.fromRGB(138, 159, 255))
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.9),
									NumberSequenceKeypoint.new(1, 0.9)
								})
								v20 = -100
								v22 = 1.45
							elseif i == 5 then
								color = RecolorMagnetColorSequence(player, Color3.fromRGB(199, 209, 255))
								numberSequence = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.925),
									NumberSequenceKeypoint.new(1, 0.925)
								})
								v21 += -2
								v20 = -125
								v22 = 1.1
							end

							if magnitude < math.abs(v20) then
								return
							end

							clone11:ScaleTo(v21 / v22)

							for _, beam in pairs(clone11:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								if color ~= nil then
									beam.Color = color
									beam.Transparency = numberSequence
								end

								beam.Enabled = true
							end

							local primaryPart = clone11.PrimaryPart
							local v24 = clone10.PrimaryPart.CFrame * CFrame.new(0, 0, v20) * CFrame.Angles(
								math.rad(math.random(-180, 180) / 100),
								math.rad(math.random(-180, 180) / 100),
								(math.rad((math.random(-180, 180))))
							)
							local angularVelocity = primaryPart.AngularVelocity
							primaryPart.Anchored = false
							primaryPart.AlignPosition.Position = primaryPart.CFrame * createVector(0, 0, -100)
							angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
							clone11:PivotTo(v24)
							local v25 = i
							task.spawn(function()
								task.wait(v25 * 0.025)
								Util.SetParentOverrideWithColor(clone11, clone10, player, "MagnetFruitVFXColor")
							end)
							clone11:GetScale()
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
								task.wait(0.15 * math.random() + 0.15 / v22)

								for i2, effect in pairs(clone11:GetDescendants()) do
									if effect:IsA("Beam") then
										TweenService:Create(
											effect,
											TweenInfo.new(0.15 / v22 + math.random() * 0.15 / v22),
											{
												Width0 = 0,
												Width1 = 0
											}
										):Play()
										local v27 = effect
										task.delay(1, function()
											v27:Destroy()
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
							local v21 = clone10:GetScale() * 0.5
							local v22 = v21 * 1.15

							for i = v21 * 100, v22 * 100, 10 do
								clone10:ScaleTo(i / 100)
								task.wait(0.005)
							end
						end)
					end)
				end
			end
		end)
		superhumanV2Travel:replicate({
			Root = part2,
			Scale = 8,
			Duration = 1.5,
			IgnoreParticles = true,
			isBlue = nil,
			IgnoreTrail = true
		})

		repeat
			task.wait()
		until v15 == true

		if v8 == true then
			v8 = false

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local clone10 = phase1.GroundBurn:Clone()
			clone10.CFrame = clone2.CFrame
			Util.SetParentOverrideWithColor(clone10, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone10:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v17 = emitter
				task.spawn(function()
					v17:Emit(1)
					v17.Enabled = true
					task.wait(0.115)
					v17.Enabled = false
				end)
			end
		end

		for _, emitter in pairs(clone6:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone7:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone8:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone9:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.spawn(function()
			local lastTime = tick()

			while tick() - lastTime < 0.15 do
				local v17 = (tick() - lastTime) / 0.15

				for _, beam in pairs(clone5:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Width0 = 20 * (1 - v17)
					beam.Width1 = 20 * (1 - v17)
				end

				task.wait()
			end
		end)
		task.wait(0.1)
		clone5:Destroy()
		local clone10 = phase1.Disappear:Clone()
		clone10.Size = Vector3.new(clone7.Size.X * 0.5, clone7.Size.Y * 0.5, clone7.Size.Z)
		clone10.CFrame = clone7.CFrame
		Util.SetParentOverrideWithColor(clone10, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone10:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		renderSteppedConnection:Disconnect()
		clone3:Destroy()

		if v12 then
			Util.Sound:FadeOut(v12, 0.2)
		end

		local cframe2 = CFrame.new(part2.CFrame.Position)
		local clone11 = z_Attract_Held.Phase2.ExStartImpact:Clone()
		clone11.CFrame = cframe2 * CFrame.new(0, 1, 0)
		Util.SetParentOverrideWithColor(clone11, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone11) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone11:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local ray = Util.Ray
		local v17 = cframe2.Position + createVector(0, 1, 0)
		local v18 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local v19 = ray(v17, createVector(-0, -26, -0), v18)
		local v20 = data.Player == game.Players.LocalPlayer and 35 or nil
		Util.Sound:Play(
			v19 and "Magnet_Transformed_Z_Held_Ground_Explode_01" or "Magnet_Transformed_Z_Held_Air_Explode_01",
			cframe2.Position,
			v20
		)
		task.wait(0.15)
		local v21 = Util.Anims:Get(clone, v2 .. "Magnet Cannon Z+V Hold Release")
		v21.Priority = Enum.AnimationPriority.Action2
		v21.Looped = false
		v21:Play()

		if v6 then
			v6:Stop()
		end

		task.delay(0.15, function()
			local clone12 = phase1.StartImpact:Clone()
			local cylinder = clone:FindFirstChild("Cylinder", true)
			clone12.CFrame = CFrame.new(cylinder.WorldPosition)
			Util.SetParentOverrideWithColor(clone12, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone12:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v22 = emitter
				task.spawn(function()
					if v22:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v22:GetAttribute("EmitDelay"))
					end

					v22:Emit(v22:GetAttribute("EmitCount"))
				end)
			end

			Util.Sound:Play("Magnet_Transformed_Z_Held_Cannon_Vanish_02", clone.PrimaryPart.Position)
			v7 = true
			clone:Destroy()
		end)
		task.spawn(function()
			local bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Parent = game.Lighting
			bloomEffect.Size += 10
			local v22 = TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
				Size = 54
			}):Play()
			task.delay(0.1, function()
				v22 = TweenService:Create(bloomEffect, TweenInfo.new(0.1), {
					Size = 0
				}):Play()
				task.wait(0.1)
				bloomEffect:Destroy()
			end)
			local clone12 = z_Attract_Held.Phase2.ScreenColor:Clone()
			clone12.Parent = game.Lighting
			local tween = TweenService:Create(clone12, TweenInfo.new(0.025), {
				Brightness = clone12.Brightness,
				Contrast = clone12.Contrast,
				Saturation = clone12.Saturation,
				TintColor = clone12.TintColor
			})
			clone12.Brightness = 0
			clone12.Contrast = 0
			clone12.Saturation = 0
			clone12.TintColor = Color3.fromRGB(255, 255, 255)
			tween:Play()
			task.wait(0.075)
			local tween2 = TweenService:Create(clone12, TweenInfo.new(0.0125), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			})
			tween2:Play()
			tween2.Completed:Wait()
			clone12:Destroy()
		end)
		local clone12 = z_Attract_Held.Phase2.MainExplosion:Clone()
		clone12.CFrame = cframe2
		Util.SetParentOverrideWithColor(clone12, folder, player, "MagnetFruitVFXColor")

		if (workspace.CurrentCamera.CFrame.p - cframe2.Position).Magnitude < 210 then
			Util.CameraShaker:ShakeOnce(11, 8, 0.2, 0.6)
		end

		for _, emitter in pairs(clone12:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 2.35, lifetime.Max * 2.35)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		DeleteImpactAfterDuration(clone12) -- equivalent call inferred; original call site unknown
		local raycastResult = workspace:Raycast(
			cframe2.Position + createVector(0, 1, 0),
			createVector(-0, -25, -0),
			raycastParams
		)
		local clone13 = z_Attract_Held.Phase2.GroundCrack:Clone()
		clone13.CFrame = cframe2
		Util.SetParentOverrideWithColor(clone13, folder, player, "MagnetFruitVFXColor")

		if raycastResult == nil then
			clone13.Attachment6:Destroy()
		end

		for _, emitter in pairs(clone13:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 2.25, lifetime.Max * 2.25)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		DeleteImpactAfterDuration(clone13) -- equivalent call inferred; original call site unknown
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

		scrapModelA:ScaleTo(3.5)
		local children = scrapModelA:GetChildren()
		Explosion(cframe2, folder, raycastParams)
		task.spawn(function()
			for i = 1, 5 do
				local v22 = i
				task.spawn(function()
					local v23 = 15
					local clone14 = z_Attract_Held.Phase3.AirSpin:Clone()
					clone14:PivotTo(cframe2 * CFrame.new(0, 10, 0))
					Util.SetParentOverrideWithColor(clone14, folder, player, "MagnetFruitVFXColor")

					if v22 == 2 then
						clone14:PivotTo(cframe2 * CFrame.new(0, 25, 0))
						v23 = 13
					elseif v22 == 3 then
						clone14:PivotTo(cframe2 * CFrame.new(0, 75, 0))
						v23 = 12
					elseif v22 == 4 then
						clone14:PivotTo(cframe2 * CFrame.new(0, 100, 0))
						v23 = 8
					elseif v22 == 5 then
						clone14:PivotTo(cframe2 * CFrame.new(0, 150, 0))
						v23 = 7
					end

					local model = clone14.Model

					for i2 = 1, 2 do
						local v24 = v23 + 3 + i2 * 1.05
						local clone15 = model:Clone()
						clone15:ScaleTo(v24)
						local primaryPart = clone15.PrimaryPart
						local v25 = clone14.PrimaryPart.CFrame * CFrame.new(0, v24, 0) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						)
						local angularVelocity = primaryPart.AngularVelocity
						primaryPart.Anchored = false
						primaryPart.AlignPosition.Position = primaryPart.Position + Vector3.new(
							math.random(-10, 10) / 10,
							0,
							math.random(-10, 10) / 10
						)
						angularVelocity.AngularVelocity = Vector3.new(
							math.random(-5, 5) / 5,
							math.random(10, 15) * 3,
							math.random(-5, 5) / 5
						)
						clone15:PivotTo(v25)
						Util.SetParentOverrideWithColor(clone15, clone14, player, "MagnetFruitVFXColor")
						clone15:GetScale()
						local folder2 = clone15
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
									local v27 = effect
									task.delay(1, function()
										v27:Destroy()
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
						local scale = clone14:GetScale()
						local v24 = scale * 1.75

						for i2 = scale * 100, v24 * 100, 5 do
							clone14:ScaleTo(i2 / 100)
							task.wait(0.005)
						end
					end)
				end)
			end
		end)
		task.spawn(function()
			local clone14 = z_Attract_Held.Phase1.SpinSlash:Clone()
			clone14:PivotTo(cframe2 * CFrame.Angles(1.5707963267948966, 0, 0))
			Util.SetParentOverrideWithColor(clone14, folder, player, "MagnetFruitVFXColor")
			local model2 = clone14.Model2
			local color = RecolorMagnetColorSequence(player, Color3.fromRGB(33, 55, 255))
			local numberSequence = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.825),
				NumberSequenceKeypoint.new(1, 0.825)
			})
			local v23 = -10

			for i = 1, 5 do
				local v24 = i * 1.05 + 25
				local v25 = 1
				local clone15 = model2:Clone()

				if i == 1 then
					v24 += -1
				elseif i == 2 then
					v24 += 5
					v25 = 1
					v23 = -30
				elseif i == 3 then
					v24 += 2
					v25 = 1
					v23 = -75
				elseif i == 4 then
					v24 += -3
					v25 = 1
					v23 = -100
				elseif i == 5 then
					v24 += -7.5
					v25 = 1
					v23 = -150
				end

				clone15:ScaleTo(v24 / v25)

				for _, beam in pairs(clone15:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					if color ~= nil then
						beam.Color = color
						beam.Transparency = numberSequence
					end

					beam.Enabled = true
				end

				local primaryPart = clone15.PrimaryPart
				local v26 = clone14.PrimaryPart.CFrame * CFrame.new(0, 0, v23) * CFrame.Angles(
					math.rad(math.random(-180, 180) / 100),
					math.rad(math.random(-180, 180) / 100),
					(math.rad((math.random(-180, 180))))
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.CFrame * createVector(0, 0, -25)
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
				clone15:PivotTo(v26)
				local v27 = i
				task.spawn(function()
					task.wait(v27 * 0.025)
					Util.SetParentOverrideWithColor(clone15, clone14, player, "MagnetFruitVFXColor")
				end)
				clone15:GetScale()
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
					task.wait(0.15 * math.random() + 0.2 / v25)

					for i2, effect in pairs(clone15:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.15 / v25 + math.random() * 0.15 / v25), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v29 = effect
							task.delay(1, function()
								v29:Destroy()
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
				local v24 = clone14:GetScale() * 0.5
				local v25 = v24 * 1.15

				for i = v24 * 100, v25 * 100, 10 do
					clone14:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)

		for _ = 1, 15 do
			task.spawn(function()
				local clone14 = children[math.random(1, #children)]:Clone()
				local v22 = cframe2.Position + Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				clone14.CFrame = CFrame.new(v22)
				clone14.Anchored = false
				clone14.CanCollide = false
				clone14.Size = clone14.Size * math.random(10, 25) / 10
				Util.SetParentOverrideWithColor(clone14, folder, player, "MagnetFruitVFXColor")
				task.delay(0.15, function()
					clone14.CanCollide = true
				end)
				clone14.AssemblyLinearVelocity = (v22 - cframe2.Position).Unit * math.random(120, 220) + Vector3.new(
					math.random(-25, 25),
					math.random(30, 80),
					math.random(-25, 25)
				)
				clone14.AssemblyAngularVelocity = Vector3.new(
					math.random(-20, 20),
					math.random(-20, 20),
					math.random(-20, 20)
				)
				task.delay(1 + math.random() * 0.5, function()
					TweenService:Create(clone14, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 0)
					}):Play()
					task.wait(0.5)
					clone14:Destroy()
				end)
			end)
		end

		task.spawn(function()
			local clone14 = z_Attract_Held.Phase3.RingBeamModel:Clone()
			clone14:PivotTo(cframe2 * CFrame.Angles(0, 0, 0))
			Util.SetParentOverrideWithColor(clone14, folder, player, "MagnetFruitVFXColor")
			local color = RecolorMagnetColorSequence(player, Color3.fromRGB(33, 55, 255))
			local numberSequence = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.0825),
				NumberSequenceKeypoint.new(1, 0.0825)
			})

			for i = 1, 1 do
				local v23 = i * 1.05 + 6.25
				local v24 = 1

				if i == 1 then
					v23 += -1
				elseif i == 2 then
					v23 += 5
					v24 = 1
				elseif i == 3 then
					v23 += 2
					v24 = 1
				elseif i == 4 then
					v23 += -3
					v24 = 1
				elseif i == 5 then
					v23 += -7.5
					v24 = 1
				end

				clone14:ScaleTo(v23 / v24)

				for _, beam in pairs(clone14:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					if color ~= nil then
						beam.Color = color
						beam.Transparency = numberSequence
					end

					beam.Enabled = true
				end

				local primaryPart = clone14.PrimaryPart
				local _ = clone14.PrimaryPart.CFrame
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.CFrame * createVector(0, 135, -0.25)
				angularVelocity.Enabled = false
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
				local v25 = i
				task.spawn(function()
					task.wait(v25 * 0.025)
				end)
				clone14:GetScale()
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

					for i2, beam in pairs(clone14:GetDescendants()) do
						if beam:IsA("Beam") then
							TweenService:Create(beam, TweenInfo.new(0.125), {
								Width0 = beam.Width0 * 5.5,
								Width1 = beam.Width1 * 5.5
							}):Play()
						end
					end

					task.wait(0.125)

					for i2, effect in pairs(clone14:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.075), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v27 = effect
							task.delay(1, function()
								v27:Destroy()
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
				local v23 = clone14:GetScale() * 1
				local v24 = v23 * 1.35

				for i = v23 * 100, v24 * 100, 55 do
					clone14:ScaleTo(i / 100)
					task.wait()
				end

				local scale = clone14:GetScale()
				local v25 = scale * 0.25

				for i = scale * 100, v25 * 100, -100 do
					clone14:ScaleTo(i / 100)
					task.wait()
				end
			end)
		end)
	end
end