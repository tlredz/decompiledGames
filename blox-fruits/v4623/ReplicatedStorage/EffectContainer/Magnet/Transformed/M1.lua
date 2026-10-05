local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("M1")
FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local _WorldOrigin = workspace._WorldOrigin

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local lightningBoltShafi = Util.LightningBoltShafi

local function ShafiBolt(...)
	local v = lightningBoltShafi.new(...)
	local curveSize = -math.random(5, 25)
	local curveSize2 = math.random(5, 25)
	v.CurveSize0 = curveSize
	v.CurveSize1 = curveSize2
	v.MinRadius = 3
	v.MaxRadius = 13
	v.Frequency = 0.5
	v.AnimationSpeed = 8
	local maxThicknessMultiplier = math.random(3, 4)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Color3.new(1, 0.380392, 0.380392)
	v.ColorOffsetSpeed = 3
	return v
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function UseAttack(p, animation)
	local track = p.AnimationController.Animator:LoadAnimation(animation)
	track:Play()

	repeat
		task.wait()
	until track.IsPlaying == false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClawSlash(cFrame, p, p2, instance, p3)
	task.spawn(function()
		local clone = M1.Phase2.SlashModel:Clone()
		clone.PrimaryPart.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, p, p3, "MagnetFruitVFXColor")
		task.spawn(function()
			task.spawn(function()
				for i = 100 * p2, 150 * p2, 5 * p2 do
					clone:ScaleTo(i / 100)
					task.wait()
				end
			end)
			task.wait(0.05)

			for _, beam in pairs(clone:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local v = beam:GetAttribute("EndDelay") / 3
				local tween = TweenService:Create(
					beam,
					TweenInfo.new(v, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				local v3 = beam
				task.spawn(function()
					tween.Completed:Wait()
					v3:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local v = 0.1 * math.random() + 0.1

			if instance then
				clone.PrimaryPart.Anchored = true
				local cFrameValue = Instance.new("CFrameValue")
				cFrameValue.Value = instance.CFrame:ToObjectSpace(clone.PrimaryPart.CFrame)
				cFrameValue.Parent = clone.PrimaryPart
				local renderSteppedConnection = nil
				renderSteppedConnection = RunService.RenderStepped:Connect(function()
					if clone.PrimaryPart and clone.PrimaryPart.Parent and instance and instance.Parent then
						clone.PrimaryPart.CFrame = instance.CFrame * cFrameValue.Value
					else
						renderSteppedConnection:Disconnect()
					end
				end)

				for _ = 1, 3 do
					local tween = TweenService:Create(
						cFrameValue,
						TweenInfo.new(v / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Value = cFrameValue.Value * CFrame.Angles(-1.3089969389957472, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					cFrameValue,
					TweenInfo.new(v * 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Value = cFrameValue.Value * CFrame.Angles(-0.6544984694978736, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			else
				for _ = 1, 3 do
					local tween = TweenService:Create(
						clone.PrimaryPart,
						TweenInfo.new(v / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end

				local tween = TweenService:Create(
					clone.PrimaryPart,
					TweenInfo.new(v * 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(-0.6544984694978736, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end
		end)
	end)
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
			local v = AlignCFrame(CFrame.new(p2.Position), p2.Normal) + p2.Normal * 0.01
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
				v4.CFrame = CFrame.new(v4.Position, p2.Position + createVector(0, 5, 0)) * CFrame.new(
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
					local v5 = (v4.Position - p2.Position).Magnitude / 50
					local v6 = size * math.random(30, 50) / 10
					local v7 = size * math.random(10, 30) / 10
					local v8 = size * math.random(30, 50) / 10
					v4.Size = Vector3.new(v6 / 2 + v6 * v5, v7 / 2 + v7 * v5, v8 / 2 + v8 * v5)
					v4.Position = raycastResult.Position + Vector3.new(0, -v4.Size.Y / 2, 0)
					v4.CFrame = CFrame.new(v4.Position, p2.Position) * CFrame.new(
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
		local clone = M1.Phase3.Rock:Clone()
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
		p.Position + createVector(0, 1, 0),
		createVector(-0, -25, -0),
		raycastParams
	)

	if raycastResult then
		local v = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
		local v2 = {
			Radius = 42,
			Size = 2.35,
			Duration = 0.75,
			Amount = 25,
			RockType = M1.Phase3.CraterRock
		}
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
	end
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
	local primaryPart = data.Rig.PrimaryPart
	local _ = primaryPart.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local cFrame = primaryPart.CFrame

	if stage == 1 then
		Util.Sound:Play("Magnet_Transformed_M1_FirstPunch_01", data.Root)
		task.spawn(function()
			task.wait(0.235)
			local v = primaryPart.CFrame * CFrame.new(-12, 15, 0) * CFrame.Angles(0, 0, -0.9599310885968813) * CFrame.Angles(
				0,
				0,
				0
			)
			ClawSlash(
				v * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0),
				folder,
				5,
				primaryPart,
				player
			) -- equivalent call inferred; original call site unknown
			local clone = M1.Phase2.HitImpactModel:Clone()
			clone:PivotTo(v * CFrame.new(0, 0, -60))
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			clone:ScaleTo(5)
			local objectSpace = primaryPart.CFrame:ToObjectSpace(clone:GetPivot())
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if clone.Parent and primaryPart and primaryPart.Parent then
					clone:PivotTo(primaryPart.CFrame * objectSpace)
				else
					renderSteppedConnection:Disconnect()
				end
			end)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v7 = emitter
				task.spawn(function()
					if v7:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v7:GetAttribute("EmitDelay"))
					end

					v7:Emit(v7:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
	elseif stage == 2 then
		Util.Sound:Play("Magnet_Transformed_M1_SecondPunch_05", data.Root)
		task.spawn(function()
			task.wait(0.235)
			local v = primaryPart.CFrame * CFrame.new(5, 30, 0) * CFrame.Angles(0, 0, 2.2689280275926285) * CFrame.Angles(
				0,
				0,
				0
			)
			ClawSlash(
				v * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(1.7453292519943295, 0, 0),
				folder,
				5,
				primaryPart,
				player
			) -- equivalent call inferred; original call site unknown
			local clone = M1.Phase2.HitImpactModel:Clone()
			clone:PivotTo(v * CFrame.new(0, 0, -60))
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			clone:ScaleTo(5)
			local objectSpace = primaryPart.CFrame:ToObjectSpace(clone:GetPivot())
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if clone.Parent and primaryPart and primaryPart.Parent then
					clone:PivotTo(primaryPart.CFrame * objectSpace)
				else
					renderSteppedConnection:Disconnect()
				end
			end)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v7 = emitter
				task.spawn(function()
					if v7:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v7:GetAttribute("EmitDelay"))
					end

					v7:Emit(v7:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end)
	elseif stage == 3 then
		local ray = Util.Ray
		local position = primaryPart.Position
		local v = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local v2, v3 = ray(position, createVector(-0, -13, -0), v)

		if v2 then
			Util.Sound:Play("Magnet_Transformed_M1_ThirdSlam_Ground_04", v3)
		else
			Util.Sound:Play("Magnet_Transformed_M1_ThirdSlam_Air_01", v3)
		end

		task.spawn(function()
			task.wait(0.3)
			local cFrame2 = primaryPart.CFrame * CFrame.new(0, 0, -10)
			local raycastResult = workspace:Raycast(
				cFrame2.Position + createVector(0, 3, 0),
				createVector(-0, -10, -0),
				raycastParams
			)

			if raycastResult then
				cFrame2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
				Explosion(cFrame2, folder, raycastParams)
				task.spawn(function()
					local clone = M1.Phase3.SpinSlash:Clone()
					clone:PivotTo(cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0))
					Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
					local model2 = clone.Model2

					for i = 1, 7 do
						local v6 = 1
						local clone2 = model2:Clone()
						local v7 = 0.35

						if i ~= 1 then
							if i == 2 then
								v6 = 0.95
								v7 = 0.25
							elseif i == 3 then
								v6 = 0.9
								v7 = 0.15
							elseif i == 4 then
								v6 = 0.85
								v7 = 0.35
							elseif i == 5 then
								v6 = 0.8
								v7 = 0.25
							end
						end

						clone2:ScaleTo((i * 0.7 + 5.75) / v6)

						for _, beam in pairs(clone2:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							beam.Width0 *= 0.15
							beam.Width1 *= 0.15
						end

						local primaryPart2 = clone2.PrimaryPart
						local v8 = clone.PrimaryPart.CFrame * CFrame.Angles(
							math.rad(math.random(-180, 180) / 15),
							math.rad(math.random(-180, 180) / 15),
							(math.rad(math.random(-180, 180) / 1))
						)

						if i > 5 then
							v8 = clone.PrimaryPart.CFrame * CFrame.Angles(
								math.rad(math.random(-180, 180) / 1),
								math.rad(math.random(-180, 180) / 1),
								(math.rad(math.random(-180, 180) / 1))
							)
							v7 = 0.25
						end

						local angularVelocity = primaryPart2.AngularVelocity
						primaryPart2.Anchored = false
						primaryPart2.AlignPosition.Position = primaryPart2.Position
						angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 15)
						clone2:PivotTo(v8)
						Util.SetParentOverrideWithColor(clone2, clone, player, "MagnetFruitVFXColor")
						clone2:GetScale()
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
							task.wait(0.05 * math.random() + v7 * 0.35)

							for i2, effect in pairs(clone2:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(1 / v6 + math.random() * 0.075 / v6), {
										Width0 = effect.Width0 * 2,
										Width1 = effect.Width1 * 2
									}):Play()
									local v10 = effect
									task.delay(1, function()
										v10:Destroy()
									end)
									local v11 = effect
									task.spawn(function()
										for i3 = 90, 100 do
											v11.Transparency = NumberSequence.new(i3 / 100, i3 / 100)
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
						local v5 = clone:GetScale() * 0.425
						local v6 = v5 * 1.75

						for i = v5 * 100, v6 * 100, 3.5 do
							clone:ScaleTo(i / 100)
							task.wait(0.005)
						end

						local v7 = clone:GetScale() * 1
						local v8 = v7 * 1.25

						for i = v7 * 100, v8 * 100 do
							clone:ScaleTo(i / 100)
							task.wait(0.01)
						end
					end)
				end)
			end

			local clone = M1.Phase3.LandImpact:Clone()
			clone.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
	elseif stage == 4 then
		local cFrame2 = cFrame * CFrame.new(0, 30, 0)
		Util.Sound:Play("Magnet_Transformed_M1_FourthFinisher_04", data.Root)
		task.spawn(function()
			task.wait(0.5)
			local clone = M1.Phase4.ExplosionStartImpact:Clone()
			clone:ScaleTo(1.5)
			local primaryPart2 = clone.PrimaryPart
			primaryPart2.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

			if (workspace.CurrentCamera.CFrame.p - cFrame2.Position).Magnitude < 170 then
				Util.CameraShaker:ShakeOnce(10, 8, 0.12, 0.4)
			end

			DeleteImpactAfterDuration(primaryPart2) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(primaryPart2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					local lifetime = v2.Lifetime
					v2.Lifetime = NumberRange.new(lifetime.Min * 1.15, lifetime.Max * 1.15)
					v2:Emit(v2:GetAttribute("EmitCount") * 1)
				end)
			end

			local clone2 = M1.Phase4.PullAura:Clone()
			clone2:ScaleTo(1.5)
			clone2:PivotTo(cFrame2)
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					v2:Emit(1)
					v2.Enabled = true
					task.wait(0.25)
					v2.Enabled = false
				end)
			end
		end)
		task.spawn(function()
			task.wait(0.85)
			local clone = M1.Phase4.Sphere:Clone()
			clone.Size = createVector(32.5, 32.5, 32.5)
			clone.CFrame = CFrame.new(cFrame2.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
				math.random(-180, 180),
				math.random(-180, 180),
				math.random(-180, 180)
			)
			Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
			task.spawn(function()
				TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = clone.Size * 3.7
				}):Play()

				for _, decal in pairs(clone:GetDescendants()) do
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
				local clone2 = M1.Phase4.Sphere1:Clone()
				clone2.Size = createVector(32.5, 32.5, 32.5)
				clone2.CFrame = CFrame.new(cFrame2.Position, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
					math.random(-180, 180),
					math.random(-180, 180),
					math.random(-180, 180)
				)
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
				task.spawn(function()
					TweenService:Create(clone2, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = clone2.Size * 3.7
					}):Play()

					for _, decal in pairs(clone2:GetDescendants()) do
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
					local v2 = i
					task.spawn(function()
						local clone2 = script.Part:Clone()
						local cFrame3 = CFrame.new(cFrame2.Position) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 10),
							math.rad((math.random(-180, 180))),
							(math.rad(math.random(-180, 180) / 10))
						) * CFrame.new(0, 0, -62.5)
						clone2.CFrame = cFrame3
						Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
						clone2.Attach1.WorldPosition = cFrame3 * CFrame.new(0, 0, 125).Position
						local shafiBolt = ShafiBolt(
							clone2.Attach0,
							clone2.Attach1,
							math.random(8, 12) * 1.25,
							0.5,
							folder
						)
						shafiBolt.CurveSize0 = -90
						shafiBolt.CurveSize1 = 90
						shafiBolt.Frequency = math.random(5, 10) * 2
						shafiBolt.MaxRadius = 12
						shafiBolt.AnimationSpeed = math.random(20, 50) / 10
						local v5 = player
						local color = Color3.fromRGB(51, 54, 255)

						if typeof(v5) == "Instance" and v5.Parent then
							color = WrapColor3Constructor(color, v5, "MagnetFruitVFXColor")
						end

						shafiBolt.Color = color

						if v2 % 2 == 0 then
							local v6 = player
							local color2 = Color3.fromRGB(71, 80, 255)

							if typeof(v6) == "Instance" and v6.Parent then
								color2 = WrapColor3Constructor(color2, v6, "MagnetFruitVFXColor")
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
			local clone2 = M1.Phase4.ExplosionFinalModel:Clone()
			clone2:ScaleTo(1.5)
			local primaryPart2 = clone2.PrimaryPart
			primaryPart2.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
			DeleteImpactAfterDuration(primaryPart2) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(primaryPart2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					local lifetime = v2.Lifetime
					v2.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
					v2:Emit(v2:GetAttribute("EmitCount") * 1.25)
				end)
			end
		end)
	end
end