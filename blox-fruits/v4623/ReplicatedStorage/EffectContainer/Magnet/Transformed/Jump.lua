local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local jump = FX:WaitForChild("Magnet"):WaitForChild("Jump")
FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function QuadBezier(p, p2, p3, p4)
	return (1 - p4) ^ 2 * p + 2 * (1 - p4) * p4 * p2 + p4 ^ 2 * p3
end

local function TrailCurve(clone, startCFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + startCFrame.LookVector) * cframe.Position
	local v3 = CFrame.new(position4, position4 + startCFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v4 = magnitude / p / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAfter(clone, duration)
	task.delay(duration, function()
		clone:Destroy()
	end)
end

local function Explosion(startCFrame, folder, raycastParams)
	local function RockCrater(p, parent, data)
		task.spawn(function()
			local rockType = data.RockType
			local radius = data.Radius
			local size = data.Size
			local duration = data.Duration
			local amount = data.Amount
			local v = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
			local v2 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = parent
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v2, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v3 in pairs(v2) do
					v3:Destroy()
				end

				v2 = nil
			end)
			local v3 = 360 / #v2
			local total = 0

			for _, v4 in pairs(v2) do
				total += v3
				v4.CFrame = v * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v4.CFrame = CFrame.new(v4.Position, p.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(
					v4.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams2
				)

				if raycastResult then
					local v5 = (v4.Position - p.Position).Magnitude / 50
					local v6 = size * math.random(30, 50) / 10
					local v7 = size * math.random(10, 30) / 10
					local v8 = size * math.random(30, 50) / 10
					v4.Size = Vector3.new(v6 / 2 + v6 * v5, v7 / 2 + v7 * v5, v8 / 2 + v8 * v5)
					v4.Position = raycastResult.Position + Vector3.new(0, -v4.Size.Y / 2, 0)
					v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-35, 35) / 5
					)
					v4.CFrame = CFrame.new(v4.Position, v.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v5)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v4.Material = raycastResult.Instance.Material
					v4.Color = raycastResult.Instance.Color
				else
					v4:Destroy()
					v2[v4] = nil
				end

				TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v4.Position + Vector3.new(0, v4.Size.Y / 1.75, 0)
				}):Play()
				local v5 = v4
				local v6 = v4
				task.spawn(function()
					task.wait(duration + math.random(10, 35) / 100)
					local tween = TweenService:Create(
						v5,
						TweenInfo.new(
							0.5,
							Enum.EasingStyle.Back,
							Enum.EasingDirection.In,
							0,
							false,
							math.random(10, 35) / 100
						),
						{
							Position = v5.Position + Vector3.new(
								math.random(-1, 1),
								-v5.Size.Y * math.random(20, 25) / 10,
								math.random(-1, 1)
							)
						}
					)
					tween:Play()
					tween.Completed:Wait()
					v5:Destroy()
					v2[v5] = nil
				end)
			end
		end)
	end

	local function FlyRock(cFrame, raycastResult, parent)
		local clone = jump.Phase1.Rock:Clone()
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
		local v = math.random(150, 250) * 0.65
		bodyVelocity.Velocity = CFrame.new(clone.Position, clone.Position + vector2 + vector3).LookVector * v
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
		startCFrame.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if raycastResult then
		local v = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v2 = {
			Radius = 46.2,
			Size = 2.5850000000000004,
			Duration = 0.75,
			Amount = 25,
			RockType = jump.Phase1.CraterRock
		}
		v2.Radius += 8
		task.spawn(function()
			local rockType = v2.RockType
			local radius = v2.Radius
			local size = v2.Size
			local duration = v2.Duration
			local amount = v2.Amount
			local v3 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			local v4 = {}

			for _ = 1, amount do
				local clone = rockType:Clone()
				rocks:ApplyCollision(clone, nil, true)
				clone.Parent = folder
				DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
				table.insert(v4, clone)
			end

			task.spawn(function()
				task.wait(duration * 3)

				for _, v5 in pairs(v4) do
					v5:Destroy()
				end

				v4 = nil
			end)
			local v5 = 360 / #v4
			local total = 0

			for _, v6 in pairs(v4) do
				total += v5
				v6.CFrame = v3 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, radius)
				v6.CFrame = CFrame.new(v6.Position, raycastResult.Position + createVector(0, 5, 0)) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-350, 450) / 100
				)
				Ray.new(v6.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = raycastParams.FilterDescendantsInstances
				raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult2 = workspace:Raycast(
					v6.Position + createVector(0, 1, 0),
					createVector(-0, -71.42857, -0),
					raycastParams2
				)

				if raycastResult2 then
					local v7 = (v6.Position - raycastResult.Position).Magnitude / 50
					local v8 = size * math.random(30, 50) / 10
					local v9 = size * math.random(10, 30) / 10
					local v10 = size * math.random(30, 50) / 10
					v6.Size = Vector3.new(v8 / 2 + v8 * v7, v9 / 2 + v9 * v7, v10 / 2 + v10 * v7)
					v6.Position = raycastResult2.Position + Vector3.new(0, -v6.Size.Y / 2, 0)
					v6.CFrame = CFrame.new(v6.Position, raycastResult.Position) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						math.random(-35, 35) / 5
					)
					v6.CFrame = CFrame.new(v6.Position, v3.Position) * CFrame.Angles(
						math.rad(-math.random(10, 15) / 1 - (15 + 15 * v7)),
						0,
						0
					) * CFrame.Angles(0, 0, (math.rad((math.random(-25, 25)))))
					v6.Material = raycastResult2.Instance.Material
					v6.Color = raycastResult2.Instance.Color
				else
					v6:Destroy()
					v4[v6] = nil
				end

				TweenService:Create(v6, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = v6.Position + Vector3.new(0, v6.Size.Y / 1.75, 0)
				}):Play()
				local v7 = v6
				local v8 = v6
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
					v4[v7] = nil
				end)
			end
		end)
		task.spawn(function()
			for i = 1, 10 do
				task.spawn(function()
					FlyRock(
						v * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
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
		task.spawn(function() end)
	end
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

return function(data)
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local stage = data.Stage
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 10)

	if stage == 1 then
		if player == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(3, 6, 0.1, 0.6, createVector(2, 3, 2), createVector(3, 2, 3))
		end

		local startCFrame = data.StartCFrame
		local clone = jump.Phase1.JumpImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Util.Sound:Play("Magnet_Transformed_Misc_Jump_0" .. tostring(math.random(1, 3)), startCFrame.Position)
		task.spawn(function()
			local clone2 = jump.Phase1.SpinSlash:Clone()
			clone2:PivotTo(startCFrame * CFrame.Angles(1.5707963267948966, 0, 0))
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			local model2 = clone2.Model2

			for i = 1, 7 do
				local v2 = 1
				local clone3 = model2:Clone()
				local v3 = 0.35

				if i ~= 1 then
					if i == 2 then
						v2 = 0.95
						v3 = 0.25
					elseif i == 3 then
						v2 = 0.9
						v3 = 0.15
					elseif i == 4 then
						v2 = 0.85
						v3 = 0.35
					elseif i == 5 then
						v2 = 0.8
						v3 = 0.25
					end
				end

				clone3:ScaleTo((i * 0.7 + 5) / v2)

				for _, beam in pairs(clone3:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					beam.Width0 *= 0.15
					beam.Width1 *= 0.15
				end

				local primaryPart = clone3.PrimaryPart
				local v4 = clone2.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-180, 180) / 15),
					math.rad(math.random(-180, 180) / 15),
					(math.rad(math.random(-180, 180) / 1))
				)

				if i > 5 then
					v4 = clone2.PrimaryPart.CFrame * CFrame.Angles(
						math.rad(math.random(-180, 180) / 1),
						math.rad(math.random(-180, 180) / 1),
						(math.rad(math.random(-180, 180) / 1))
					)
					v3 = 0.25
				end

				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 15)
				clone3:PivotTo(v4)
				Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
				clone3:GetScale()
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
					task.wait(0.05 * math.random() + v3 * 0.35)

					for i2, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(1 / v2 + math.random() * 0.075 / v2), {
								Width0 = effect.Width0 * 2,
								Width1 = effect.Width1 * 2
							}):Play()
							local v6 = effect
							task.delay(1, function()
								v6:Destroy()
							end)
							local v7 = effect
							task.spawn(function()
								for i3 = 90, 100 do
									v7.Transparency = NumberSequence.new(i3 / 100, i3 / 100)
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
				local v = clone2:GetScale() * 0.425
				local v2 = v * 1.75

				for i = v * 100, v2 * 100, 3.5 do
					clone2:ScaleTo(i / 100)
					task.wait(0.005)
				end

				local v3 = clone2:GetScale() * 1
				local v4 = v3 * 1.25

				for i = v3 * 100, v4 * 100 do
					clone2:ScaleTo(i / 100)
					task.wait(0.01)
				end
			end)
		end)

		for _ = 1, 10 do
			task.spawn(function()
				local clone2 = jump.Phase1.Trail:Clone()
				clone2.CFrame = startCFrame
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
				clone2.CFrame = clone2.CFrame * CFrame.Angles(
					math.rad((math.random(-180, 180))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-180, 180))))
				) * CFrame.new(0, 0, math.random(20, 35))

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				TrailCurve(
					clone2,
					startCFrame,
					clone2.Position,
					startCFrame * CFrame.new(0, 50, 0).Position + Vector3.new(
						math.random(-25, 25),
						math.random(-15, 15),
						math.random(-25, 25)
					),
					CFrame.new(math.random(-50, 50) / 3, math.random(-50, 50) / 3, math.random(-50, 50) / 3),
					CFrame.new(math.random(-50, 50) / 3, math.random(-50, 50) / 3, math.random(-50, 50) / 3),
					math.random(25, 30) / 5
				)

				for _, effect in pairs(clone2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end
	else
		local startCFrame = data.StartCFrame
		local clone = jump.Phase1.LandImpact:Clone()
		Util.ResizeModel(clone, 1.6)
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		if player == game.Players.LocalPlayer or (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 90 then
			Util.CameraShaker:ShakeOnce(8, 9, 0.1, 0.8, createVector(4, 4, 4), createVector(3, 2, 3))
		end

		Util.Sound:Play("Magnet_Transformed_Misc_Land_01", startCFrame.Position)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		Explosion(startCFrame, folder, raycastParams)
		task.spawn(function()
			local clone2 = jump.Phase1.SpinSlash:Clone()
			clone2:PivotTo(startCFrame * CFrame.Angles(1.5707963267948966, 0, 0))
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			local model2 = clone2.Model2

			for i = 1, 7 do
				local v2 = 1
				local clone3 = model2:Clone()
				local v3 = 0.35

				if i ~= 1 then
					if i == 2 then
						v2 = 0.95
						v3 = 0.25
					elseif i == 3 then
						v2 = 0.9
						v3 = 0.15
					elseif i == 4 then
						v2 = 0.85
						v3 = 0.35
					elseif i == 5 then
						v2 = 0.8
						v3 = 0.25
					end
				end

				clone3:ScaleTo((i * 0.7 + 6.5) / v2)

				for _, beam in pairs(clone3:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					beam.Width0 *= 0.15
					beam.Width1 *= 0.15
				end

				local primaryPart = clone3.PrimaryPart
				local v4 = clone2.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-180, 180) / 15),
					math.rad(math.random(-180, 180) / 15),
					(math.rad(math.random(-180, 180) / 1))
				)

				if i > 5 then
					v4 = clone2.PrimaryPart.CFrame * CFrame.Angles(
						math.rad(math.random(-180, 180) / 1),
						math.rad(math.random(-180, 180) / 1),
						(math.rad(math.random(-180, 180) / 1))
					)
					v3 = 0.25
				end

				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position
				angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 15)
				clone3:PivotTo(v4)
				Util.SetParentOverrideWithColor(clone3, clone2, player, "MagnetFruitVFXColor")
				clone3:GetScale()
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
					task.wait(0.05 * math.random() + v3 * 0.35)

					for i2, effect in pairs(clone3:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(1 / v2 + math.random() * 0.075 / v2), {
								Width0 = effect.Width0 * 2,
								Width1 = effect.Width1 * 2
							}):Play()
							local v6 = effect
							task.delay(1, function()
								v6:Destroy()
							end)
							local v7 = effect
							task.spawn(function()
								for i3 = 90, 100 do
									v7.Transparency = NumberSequence.new(i3 / 100, i3 / 100)
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
				local v = clone2:GetScale() * 0.425
				local v2 = v * 1.75

				for i = v * 100, v2 * 100, 3.5 do
					clone2:ScaleTo(i / 100)
					task.wait(0.005)
				end

				local v3 = clone2:GetScale() * 1
				local v4 = v3 * 1.25

				for i = v3 * 100, v4 * 100 do
					clone2:ScaleTo(i / 100)
					task.wait(0.01)
				end
			end)
		end)
	end
end