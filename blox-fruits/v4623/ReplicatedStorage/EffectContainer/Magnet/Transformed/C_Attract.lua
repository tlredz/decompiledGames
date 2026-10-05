local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local C = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("C")
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local ScrapParams = require(script:WaitForChild("ScrapParams"))
local HeldMotion = require(script:WaitForChild("HeldMotion"))
local PeakAura = require(script:WaitForChild("PeakAura"))
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

local function RecolorMagnetColor(p, p2)
	return WrapColor3Constructor(p2, p, "MagnetFruitVFXColor")
end

local function RecolorMagnetColorSequence(p, p2, p3)
	return ColorSequence.new(WrapColor3Constructor(p2, p, "MagnetFruitVFXColor"), RecolorMagnetColor(p, p3))
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

-- equivalent calls inferred from this helper; original call sites unknown
local function QuadBezier(p, p2, p3, p4)
	return p:Lerp(p2, p4):Lerp(p2:Lerp(p3, p4), p4)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = p4 + (p5 - p4) * p
	local v5 = v2 + (v3 - v2) * p
	return v5 + (v3 + (v4 - v3) * p - v5) * p
end

local function TrailCurve(clone, cFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v2 = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v2 / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v2 / 1.5)).Position
	math.random(20, 30)
	local v3 = CFrame.new(position3, position3 + cFrame.LookVector) * cframe.Position
	local v4 = CFrame.new(position4, position4 + cFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v5 = magnitude / p / 60

	while tick() - lastTime < v5 do
		local v6 = (tick() - lastTime) / v5
		local v7 = cubicBezier(v6, position, v3, v4, position2)
		clone.CFrame = CFrame.new(clone.CFrame:Lerp(CFrame.new(v7, position2), v6).Position)
		RunService.Heartbeat:Wait()
	end
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

local function AlignCFrame(data, normal)
	local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local unit = data.LookVector:Cross(v2).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v2).Unit
	return CFrame.fromMatrix(data.Position, unit2, v2, unit3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClawSlash(cFrame, p, p2, p3)
	task.spawn(function()
		local clone = C.Phase3B.SlashModel:Clone()
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

				local v2 = beam:GetAttribute("EndDelay") / 3
				local tween = TweenService:Create(
					beam,
					TweenInfo.new(v2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				local v4 = beam
				task.spawn(function()
					tween.Completed:Wait()
					v4:Destroy()
				end)
			end
		end)
		task.spawn(function()
			local v2 = 0.1 * math.random() + 0.1

			for _ = 1, 3 do
				local tween = TweenService:Create(
					clone.PrimaryPart,
					TweenInfo.new(v2 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(-0.8726646259971648, 0, 0)
					}
				)
				tween:Play()
				tween.Completed:Wait()
			end

			local tween = TweenService:Create(
				clone.PrimaryPart,
				TweenInfo.new(v2 * 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(-0.4363323129985824, 0, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
		end)
	end)
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
		local clone = C.Phase3B.Rock:Clone()
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
		createVector(-0, -100, -0),
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
		RockType = C.Phase3B.CraterRock
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
		local clone = C.Phase3B.GroundCrack:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local lifetime = emitter.Lifetime
			emitter.Lifetime = NumberRange.new(lifetime.Min * 1.75, lifetime.Max * 1.75)
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	end)
	task.spawn(function()
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Parent = game.Lighting
		bloomEffect.Size += 10
		local v4 = TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
			Size = 54
		}):Play()
		task.delay(0.1, function()
			v4 = TweenService:Create(bloomEffect, TweenInfo.new(0.1), {
				Size = 0
			}):Play()
			task.wait(0.1)
			bloomEffect:Destroy()
		end)
		local clone = C.Phase3.ScreenColor:Clone()
		clone.Parent = game.Lighting
		local tween = TweenService:Create(clone, TweenInfo.new(0.025), {
			Brightness = clone.Brightness,
			Contrast = clone.Contrast,
			Saturation = clone.Saturation,
			TintColor = clone.TintColor
		})
		clone.Brightness = 0
		clone.Contrast = 0
		clone.Saturation = 0
		clone.TintColor = Color3.fromRGB(255, 255, 255)
		tween:Play()
		task.wait(0.075)
		local tween2 = TweenService:Create(clone, TweenInfo.new(0.0125), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
		tween2:Play()
		tween2.Completed:Wait()
		clone:Destroy()
	end)
	task.spawn(function()
		local clone = C.Phase3B.RingBeamModel:Clone()
		clone:PivotTo(cFrame2 * CFrame.Angles(0, 0, 0))
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, RecolorMagnetColor(player, Color3.fromRGB(32, 65, 255))),
			ColorSequenceKeypoint.new(1, RecolorMagnetColor(player, Color3.fromRGB(32, 65, 255)))
		})
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.0825),
			NumberSequenceKeypoint.new(1, 0.0825)
		})

		for i = 1, 1 do
			local v4 = i * 1.05 + 7
			local v5 = 1

			if i == 1 then
				v4 += -1
			elseif i == 2 then
				v4 += 5
				v5 = 1
			elseif i == 3 then
				v4 += 2
				v5 = 1
			elseif i == 4 then
				v4 += -3
				v5 = 1
			elseif i == 5 then
				v4 += -7.5
				v5 = 1
			end

			clone:ScaleTo(v4 / v5)

			for _, beam in pairs(clone:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				if colorSequence ~= nil then
					beam.Color = colorSequence
					beam.Transparency = numberSequence
				end

				beam.Enabled = true
			end

			local primaryPart = clone.PrimaryPart
			local _ = clone.PrimaryPart.CFrame
			local angularVelocity = primaryPart.AngularVelocity
			primaryPart.Anchored = false
			primaryPart.AlignPosition.Position = primaryPart.CFrame * createVector(0, 135, -0.25)
			angularVelocity.Enabled = false
			angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
			local v6 = i
			task.spawn(function()
				task.wait(v6 * 0.025)
			end)
			clone:GetScale()
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

				for i2, beam in pairs(clone:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.125), {
							Width0 = beam.Width0 * 5.5,
							Width1 = beam.Width1 * 5.5
						}):Play()
					end
				end

				task.wait(0.075)

				for i2, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.05), {
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

		task.spawn(function()
			local v4 = clone:GetScale() * 1
			local v5 = v4 * 1.35

			for i = v4 * 100, v5 * 100, 55 do
				clone:ScaleTo(i / 100)
				task.wait()
			end

			local scale = clone:GetScale()
			local v6 = scale * 0.25

			for i = scale * 100, v6 * 100, -100 do
				clone:ScaleTo(i / 100)
				task.wait()
			end
		end)
	end)
	return raycastResult
end

local function makeProxyPartAtBone(core, _, cframe: CFrame?)
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
	part.Name = "ProxyPart_" .. core.Name
	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	attachment.Parent = part
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = core
	rigidConstraint.Attachment1 = attachment
	rigidConstraint.Parent = part
	part.Transparency = 1
	return part
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
	local startCFrame = data.StartCFrame or root.CFrame
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = player.Name .. "_CTransformed"
		folder.Parent = workspace._WorldOrigin
		local cFrame = root.CFrame * CFrame.new(0, 50, 0)
		local clone = C.Phase1.MagnetModel:Clone()
		clone:PivotTo(cFrame)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		local v3 = Util.Anims:Get(clone, "Magnet Mech MagnetModel Start")
		v3.Priority = Enum.AnimationPriority.Action2
		v3.Looped = false
		v3:Play()
		v3:AdjustSpeed(1.8)
		local v4 = Util.Anims:Get(clone, "Magnet Mech MagnetModel Loop")
		v4.Looped = true
		v4:Play()
		Util.Sound:Play("Magnet_Transformed_C_Tap_Activate_01", root)
		local v5 = tick() + 0.15
		local v6 = tick() + 0.15
		local v7 = tick() + 0.15
		local v8 = tick() + 0.5
		local _ = tick() + 1
		local v9 = Util.Sound:Play("Magnet_Transformed_C_Tap_Aura_Loop_01", cFrame.Position)
		task.delay(0.2, function()
			if v9 then
				TweenService:Create(v9, TweenInfo.new(0.8), {
					Volume = 1
				}):Play()
			end
		end)
		local clone2 = nil

		while true do
			if v7 - tick() <= 0 and clone2 == nil then
				clone2 = C.Phase1.HeldAura:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter:Emit(1)
					emitter.Enabled = true
				end
			end

			if not (root and root:FindFirstChild("MagnetCHeldTrigger")) then
				if v5 - tick() <= 0 then
					v5 = tick() + 0.025

					for _ = 1, math.random(1, 2) do
						task.spawn(function()
							local clone3 = script.Part:Clone()
							local cFrame2 = CFrame.new(cFrame.Position) * CFrame.Angles(
								math.random(-180, 180),
								math.rad((math.random(-180, 180))),
								math.random(-180, 180)
							) * CFrame.new(0, 0, 75)
							clone3.CFrame = cFrame2
							Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
							clone3.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, -150).Position
							local shafiBolt = ShafiBolt(
								clone3.Attach0,
								clone3.Attach1,
								math.random(8, 12) * 1.5,
								1,
								folder
							)
							shafiBolt.CurveSize0 = -50
							shafiBolt.CurveSize1 = 50
							shafiBolt.Frequency = math.random(5, 10) * 2
							shafiBolt.MaxRadius = 15
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(20, 40, 217),
								player,
								"MagnetFruitVFXColor"
							)
							task.spawn(function()
								task.wait(0.07 * math.random() + 0.05)
								shafiBolt:Destroy()
							end)
						end)
					end
				end

				if v6 - tick() <= 0 then
					v6 = tick() + 0.025

					for _ = 1, math.random(1, 2) do
						task.spawn(function()
							local clone3 = script.Part:Clone()
							local cFrame2 = CFrame.new(cFrame.Position) * CFrame.Angles(
								math.random(-180, 180),
								math.rad((math.random(-180, 180))),
								math.random(-180, 180)
							) * CFrame.new(0, 0, 52)
							clone3.CFrame = cFrame2
							Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
							clone3.Attach1.WorldPosition = cFrame2 * CFrame.new(0, 0, 65).Position
							local shafiBolt = ShafiBolt(
								clone3.Attach0,
								clone3.Attach1,
								math.random(8, 12) * 0.7,
								0.85,
								folder
							)
							shafiBolt.Frequency = math.random(5, 10) * 2
							shafiBolt.MaxRadius = 15
							shafiBolt.AnimationSpeed = math.random(20, 50) / 10
							shafiBolt.Color = WrapColor3Constructor(
								Color3.fromRGB(20, 40, 217),
								player,
								"MagnetFruitVFXColor"
							)
							task.spawn(function()
								task.wait(0.07 * math.random() + 0.075)
								shafiBolt:Destroy()
							end)
						end)
					end
				end

				task.wait(0.01)

				if holding:IsDescendantOf(workspace) and (holding.Value ~= false or not (v8 - tick() <= 0)) then
					continue
				end
			end

			Util.Debris:AddItem(folder, 7)

			if v9 then
				Util.Sound:FadeOut(v9, 0.2)
			end

			if clone2 == nil then
				break
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(1)
				emitter.Enabled = false
			end

			break
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 7)
		local child = workspace._WorldOrigin:FindFirstChild(player.Name .. "_CTransformed")

		if child then
			child.Name = "DESTROYING"
		end

		local magnetModel = child and child:FindFirstChild("MagnetModel")
		local clone = C.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Transformed_C_Tap_PullIn_And_Explode_04", startCFrame.Position)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
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

		local clone2 = C.Phase1.StartImpact2:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
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

		local position = startCFrame.Position
		task.spawn(function()
			local clone3 = C.Phase1.SpinSlash:Clone()
			clone3:PivotTo(CFrame.new(position))
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
			local model = clone3.Model

			for i = 1, 3 do
				local v2 = math.random(70, 100) / 200
				local v3 = i * 0.35 + 7 + math.random(-10, 10) / 10
				local clone4 = model:Clone()
				clone4:ScaleTo(v3)
				local primaryPart = clone4.PrimaryPart
				local v4 = clone3.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-180, 180) / 1),
					math.rad((math.random(-180, 180))),
					(math.rad(math.random(-180, 180) / 1))
				)
				local angularVelocity = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 5, 0)
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(10, 15) * 2, 0)
				clone4:PivotTo(v4)
				Util.SetParentOverrideWithColor(clone4, clone3, player, "MagnetFruitVFXColor")
				primaryPart.AlignPosition.Enabled = true
				angularVelocity.Enabled = true
				clone4:GetScale()
				local folder2 = clone4
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
						task.wait(v2 / 2)
						primaryPart.AlignPosition.Position = position + createVector(0, 5, 0)
					end)
					task.wait(0.035 * math.random() + 0.1)

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.35 + math.random() * 0.125), {
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
					task.wait(3)
					angularVelocity:Destroy()
				end)
			end

			model:Destroy()
			task.spawn(function()
				local scale = clone3:GetScale()
				local v2 = scale * 0.01

				for i = scale * 100, v2 * 100, -25 do
					clone3:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		task.spawn(function()
			for _ = 1, 10 do
				task.spawn(function()
					local v2 = math.random(45, 50) / 100
					local clone3 = C.Phase1.TrailModel:Clone()
					clone3.Start.CFrame = CFrame.new(position) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
					clone3:ScaleTo(math.random(20, 25) / 7)
					local start = clone3.Start
					local trail = clone3.Trail
					local cframe = CFrame.new(0, 0, -math.random(100, 150) * 1)
					TweenService:Create(trail.Weld, TweenInfo.new(v2 / 5), {
						C1 = cframe
					}):Play()
					TweenService:Create(start, TweenInfo.new(v2), {
						CFrame = CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
					}):Play()
					trail.Weld.C1 = CFrame.new(0, 0, 0)
					task.delay(v2 / 5, function()
						TweenService:Create(trail.Weld, TweenInfo.new(v2 / 2), {
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

					for _, effect in pairs(clone3:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
						local v3 = effect
						task.delay(v2 + v2 / 5, function()
							v3.Enabled = false
						end)
					end

					task.wait(v2)
					angularVelocity.Enabled = false
					task.wait(v2)
					clone3:Destroy()
				end)
				task.wait()
			end
		end)
		task.spawn(function()
			local position2 = startCFrame.Position
			local scrapModelA2

			if hasCrimsonGoldSkin(data.Player) then
				local scrapModelA22 = v.ScrapModelA2
				scrapModelA2 = scrapModelA22 and scraps:FindFirstChild(scrapModelA22)

				if not scrapModelA2 then
					scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
				end
			else
				scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
			end

			local scrapModelA3 = scraps.ScrapModelA3
			scrapModelA2:ScaleTo(8.725)
			scrapModelA3:ScaleTo(1.25)
			local clones = {}

			local function CreateScrapPrisonSphere(cframe, folder2)
				for i = 1, 40 do
					local v3 = i
					local v4 = 0.2025 + math.random() * 0.025
					task.spawn(function()
						local v5

						if v3 % 10 == 0 then
							v5 = scrapModelA3
						else
							v5 = scrapModelA2

							if math.random(1, 7) == 1 then
								v5 = scrapModelA3
							end
						end

						local children = v5:GetChildren()

						if #children == 0 then
							return
						end

						local clone3 = children[math.random(1, #children)]:Clone()
						Util.SetParentOverrideWithColor(clone3, folder2, player, "MagnetFruitVFXColor")
						local clone4 = C.Phase1.Highlight:Clone()
						Util.SetParentOverrideWithColor(clone4, clone3, player, "MagnetFruitVFXColor")
						clone4.Enabled = true
						local clone5 = C.Phase1.AuraModel:Clone()
						clone5.PrimaryPart.Anchored = false
						clone5.PrimaryPart.Weld.Part1 = clone3
						Util.SetParentOverrideWithColor(clone5, clone3, player, "MagnetFruitVFXColor")

						for i2, effect in pairs(clone5:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						clone3:SetAttribute("ScrapIndex", v3)
						table.insert(clones, clone3)
						local v6 = 1 - v3 / 39 * 2
						local v7 = math.sqrt(1 - v6 * v6)
						local v8 = 2.399963229728653 * v3
						local v9 = Vector3.new(math.cos(v8) * v7, v6, math.sin(v8) * v7) * 30
						local v10 = cframe.Position + v9
						local cframe2 = CFrame.lookAt(v10, cframe.Position)
						clone3:SetAttribute("BaseCF", cframe2)
						local v11 = cframe.Position + Vector3.new(
							math.random(-60, 60) * 3,
							math.random(-60, 60),
							math.random(-60, 60) * 3
						)
						clone3:PivotTo(CFrame.new(v11, cframe.Position))
						local unit = (cframe.Position - v11).Unit
						clone3:PivotTo(CFrame.lookAt(v11, v11 + unit))
						TweenService:Create(
							clone3,
							TweenInfo.new(v4, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								CFrame = CFrame.lookAt(v10, v11 + unit)
							}
						):Play()
						task.spawn(function()
							task.wait(v4)

							for i2, effect in pairs(clone5:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end

							TweenService:Create(
								clone3,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									CFrame = cframe2
								}
							):Play()
						end)
					end)
				end
			end

			task.spawn(function()
				CreateScrapPrisonSphere(CFrame.new(position2 + createVector(0, 10, 0)), folder)
			end)
			task.spawn(function()
				task.wait(0.19125)
				local v2 = tick() + 0.5

				for i = 1, 10 do
					local v3 = i
					task.spawn(function()
						task.wait(math.random() * 0.25)
						local clone3 = C.Phase2.RaySmall:Clone()
						clone3:ScaleTo(math.random(70, 100) / 10)
						local crackBeam = clone3.CrackBeam
						local v4 = 1 - v3 / 9 * 2
						local v5 = math.sqrt(1 - v4 * v4)
						local v6 = 2.399963229728653 * v3
						local v7 = position2 + Vector3.new(math.cos(v6) * v5, v4, math.sin(v6) * v5).Unit * 15
						crackBeam.CFrame = CFrame.lookAt(v7, position2) * CFrame.new(0, 0, -math.random(15, 25))
						Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
						local v8 = math.random(45, 75) * 1.5
						local attach1 = crackBeam.Attach1
						local v9 = math.random(10, 25) / 100
						attach1.Position = createVector(0, 0, 0)
						TweenService:Create(
							attach1,
							TweenInfo.new(v9, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Position = Vector3.new(0, 0, -v8)
							}
						):Play()
						task.delay(v2 - tick(), function()
							clone3:Destroy()
						end)
					end)
				end
			end)
			task.spawn(function()
				task.wait(0.19125)
				local v2 = tick() + 0.5

				for i = 1, 10 do
					local v3 = i
					task.spawn(function()
						task.wait(math.random() * 0.25)
						local clone3 = C.Phase2.Ray:Clone()
						clone3:ScaleTo(math.random(70, 100) / 10)
						local crackBeam = clone3.CrackBeam
						local v4 = 1 - v3 / 9 * 2
						local v5 = math.sqrt(1 - v4 * v4)
						local v6 = 2.399963229728653 * v3
						local v7 = position2 + Vector3.new(math.cos(v6) * v5, v4, math.sin(v6) * v5).Unit * 15
						crackBeam.CFrame = CFrame.lookAt(v7, position2) * CFrame.new(0, 0, -math.random(15, 25))
						Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
						local v8 = math.random(45, 75) * 1.5
						local attach1 = crackBeam.Attach1
						local v9 = math.random(30, 50) / 100
						attach1.Position = createVector(0, 0, 0)
						TweenService:Create(
							attach1,
							TweenInfo.new(v9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Position = Vector3.new(0, 0, -v8)
							}
						):Play()
						task.delay(v2 - tick(), function()
							clone3:Destroy()
						end)
					end)
				end
			end)
			task.wait(0.225)
			task.spawn(function()
				local now = tick()
				local v2 = tick() + 0.5
				local now2 = tick()

				repeat
					if now - tick() <= 0 then
						now = tick() + 0.015

						for i = 1, math.random(1, 2) do
							local v3 = i
							task.spawn(function()
								local clone3 = script.Part:Clone()
								local cFrame = CFrame.new(startCFrame.Position) * CFrame.Angles(
									math.random(-180, 180),
									math.rad((math.random(-180, 180))),
									math.random(-180, 180)
								) * CFrame.new(0, 0, 50)
								clone3.CFrame = cFrame
								Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
								clone3.Attach1.WorldPosition = cFrame * CFrame.new(0, 0, -100).Position
								local shafiBolt = ShafiBolt(
									clone3.Attach0,
									clone3.Attach1,
									math.random(8, 12),
									0.75,
									folder
								)
								shafiBolt.CurveSize0 = -33.333333333333336
								shafiBolt.CurveSize1 = 33.333333333333336
								shafiBolt.Frequency = math.random(5, 10)
								shafiBolt.MaxRadius = 5
								shafiBolt.AnimationSpeed = math.random(20, 50) / 10
								shafiBolt.Color = WrapColor3Constructor(
									Color3.fromRGB(34, 45, 255),
									player,
									"MagnetFruitVFXColor"
								)

								if v3 % 2 == 0 then
									shafiBolt.Color = WrapColor3Constructor(
										Color3.fromRGB(57, 67, 255),
										player,
										"MagnetFruitVFXColor"
									)
								end

								task.spawn(function()
									task.wait(0.07 + math.random() * 0.1)
									shafiBolt:Destroy()
								end)
							end)
						end
					end

					if now2 - tick() <= 0 then
						now2 = tick() + 0.05

						for _, v3 in pairs(clones) do
							local cFrame = v3:GetAttribute("BaseCF") * CFrame.new(
								math.random(-10, 10) / 10,
								math.random(-10, 10) / 10,
								math.random(-10, 10) / 10
							) * CFrame.Angles(
								math.rad((math.random(-5, 5))),
								math.rad((math.random(-5, 5))),
								(math.rad((math.random(-5, 5))))
							)
							TweenService:Create(
								v3,
								TweenInfo.new(0.06, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
								{
									CFrame = cFrame
								}
							):Play()
						end
					end

					for _, v3 in pairs(clones) do
						local baseCF = v3:GetAttribute("BaseCF")
						v3:SetAttribute(
							"BaseCF",
							CFrame.lookAt(baseCF.Position, startCFrame.Position) * CFrame.new(0, 0, 0.5)
						)
					end

					task.wait(0.01)
				until v2 - tick() <= 0
			end)
			local clone3 = C.Phase2.SphereAura:Clone()
			clone3.CFrame = startCFrame
			Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone3:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					v2:Emit(1)
					v2.Enabled = true
					task.wait(0.5)
					v2.Enabled = false
				end)
			end

			task.delay(0.4675, function()
				local clone4 = C.Phase2.ExStartImpact:Clone()
				clone4.CFrame = startCFrame
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown
			end)
			task.wait(0.5)
			task.spawn(function()
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Parent = game.Lighting
				bloomEffect.Size += 10
				local v2 = TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
					Size = 54
				}):Play()
				task.delay(0.05, function()
					v2 = TweenService:Create(bloomEffect, TweenInfo.new(0.05), {
						Size = 0
					}):Play()
					task.wait(0.05)
					bloomEffect:Destroy()
				end)
				local clone4 = C.Phase3.ScreenColor:Clone()
				clone4.Parent = game.Lighting
				local tween = TweenService:Create(clone4, TweenInfo.new(0.025), {
					Brightness = clone4.Brightness,
					Contrast = clone4.Contrast,
					Saturation = clone4.Saturation,
					TintColor = clone4.TintColor
				})
				clone4.Brightness = 0
				clone4.Contrast = 0
				clone4.Saturation = 0
				clone4.TintColor = Color3.fromRGB(255, 255, 255)
				tween:Play()
				task.wait(0.05)
				local tween2 = TweenService:Create(clone4, TweenInfo.new(0.0225), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				})
				tween2:Play()
				tween2.Completed:Wait()
				clone4:Destroy()
			end)
			task.spawn(function()
				local v2 = startCFrame
				local clone4 = C.Phase2.Sphere:Clone()
				clone4.Size = createVector(50, 50, 50)
				clone4.CFrame = CFrame.new(
					v2.Position + createVector(0, 15, 0),
					workspace.CurrentCamera.CFrame.Position
				) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
				task.spawn(function()
					TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = clone4.Size * 3.7
					}):Play()

					for _, decal in pairs(clone4:GetDescendants()) do
						if not decal:IsA("Decal") then
							continue
						end

						decal.Transparency = 0.5
						TweenService:Create(
							decal,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end
				end)
				task.spawn(function()
					local clone5 = C.Phase2.Sphere1:Clone()
					clone5.Size = createVector(62.5, 62.5, 62.5)
					clone5.CFrame = CFrame.new(
						v2.Position + createVector(0, 15, 0),
						workspace.CurrentCamera.CFrame.Position
					) * CFrame.Angles(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
					Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
					task.spawn(function()
						TweenService:Create(
							clone5,
							TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = clone5.Size * 3.7
							}
						):Play()

						for _, decal in pairs(clone5:GetDescendants()) do
							if not decal:IsA("Decal") then
								continue
							end

							decal.Transparency = 0.5
							TweenService:Create(
								decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
								{
									Transparency = 1,
									StudsPerTileU = math.random(15, 20) * 2,
									StudsPerTileV = math.random(15, 20) * 2
								}
							):Play()
						end
					end)
				end)
			end)
			local clone4 = C.Phase3.ExplosionFinal:Clone()
			clone4.CFrame = startCFrame
			Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

			if (workspace.CurrentCamera.CFrame.p - startCFrame.Position).Magnitude < 210 then
				Util.CameraShaker:ShakeOnce(12, 8, 0.2, 0.6)
			end

			for _, emitter in pairs(clone4:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

			if magnetModel then
				magnetModel:Destroy()
			end

			task.spawn(function()
				local clone5 = C.Phase3.SpinSlash:Clone()
				clone5:PivotTo(startCFrame)
				Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
				local model2 = clone5.Model2

				for i = 1, 5 do
					local v3 = 1
					local clone6 = model2:Clone()

					if i ~= 1 then
						if i == 2 then
							v3 = 0.95
						elseif i == 3 then
							v3 = 0.9
						elseif i == 4 then
							v3 = 0.85
						elseif i == 5 then
							v3 = 0.8
						else
							v3 = v3
						end
					end

					clone6:ScaleTo((i * 1.075 + 22.5) / v3)

					for _, beam in pairs(clone6:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Enabled = true
						end
					end

					local primaryPart = clone6.PrimaryPart
					local v4 = clone5.PrimaryPart.CFrame * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					local angularVelocity = primaryPart.AngularVelocity
					primaryPart.Anchored = false
					primaryPart.AlignPosition.Position = primaryPart.Position
					angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
					clone6:PivotTo(v4)
					Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
					clone6:GetScale()
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
						task.wait(0.05 * math.random() + 0.125 / v3)

						for i2, effect in pairs(clone6:GetDescendants()) do
							if effect:IsA("Beam") then
								TweenService:Create(effect, TweenInfo.new(0.1 / v3 + math.random() * 0.1 / v3), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								local v6 = effect
								task.delay(1, function()
									v6:Destroy()
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
					local v2 = clone5:GetScale() * 0.75
					local v3 = v2 * 1.15

					for i = v2 * 100, v3 * 100, 10 do
						clone5:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end)
			local position3 = CFrame.new(position2 + createVector(0, 1, 0)).Position

			for _, v2 in ipairs(clones) do
				if not (v2 and v2.Parent) then
					continue
				end

				v2.Anchored = true
				v2.CanCollide = false
				local scrapIndex = v2:GetAttribute("ScrapIndex")

				if not scrapIndex then
					continue
				end

				local v3 = ScrapParams.get(data.Seed, position2, scrapIndex)
				local targetPos = v3.targetPos
				local v4 = true
				local tweenTime = v3.tweenTime
				task.delay(tweenTime * 0.9, function()
					v4 = false
				end)
				v2.CFrame = CFrame.lookAt(v2.Position, targetPos)
				TweenService:Create(v2, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = CFrame.lookAt(targetPos, targetPos + (targetPos - v2.Position).Unit)
				}):Play()
				local folder2 = v2
				task.spawn(function()
					local position4 = folder2.Position
					local v6 = false

					while v4 == true do
						local position5 = folder2.Position
						local v7 = (position5 - position4).Magnitude > 0.01
						local raycastResult = workspace:Raycast(
							position5,
							(targetPos - position5).Unit * 12,
							raycastParams
						)

						if raycastResult then
							folder2.CFrame = CFrame.new(raycastResult.Position) * (folder2.CFrame - folder2.CFrame.Position)
							folder2.Anchored = false
							local weldConstraint = Instance.new("WeldConstraint")
							weldConstraint.Part0 = folder2
							weldConstraint.Part1 = raycastResult.Instance
							weldConstraint.Parent = folder2
							folder2:SetAttribute("HIT", true)
							task.spawn(function()
								task.wait(0.1)
							end)
							local cFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
							local clone5 = C.Phase3.GroundCrack:Clone()
							clone5.CFrame = cFrame
							Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
							v6 = true

							for i, emitter in pairs(clone5:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local lifetime = emitter.Lifetime
								emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
								emitter:Emit(emitter:GetAttribute("EmitCount") / 1.5)
							end

							DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown
							local clone6 = C.Phase3.ScrapAura:Clone()
							clone6.CFrame = cFrame * CFrame.Angles(0, 0, -1.5707963267948966)
							Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")

							for i, emitter in pairs(clone6:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								emitter:Emit(1)
								emitter.Enabled = true
								local v9 = emitter
								task.delay(1, function()
									v9.Enabled = false
								end)
							end

							task.delay(1.5 + math.random(), function()
								if not (folder2 and folder2.Parent) then
									return
								end

								TweenService:Create(folder2, TweenInfo.new(0.25), {
									Size = createVector(0, 0, 0)
								}):Play()

								if folder2:GetAttribute("ROD") then
									for i, child2 in pairs(folder2:GetChildren()) do
										if child2:IsA("WeldConstraint") or child2:IsA("Model") or not child2:IsA("BasePart") then
											continue
										end

										TweenService:Create(child2, TweenInfo.new(0.25), {
											Size = createVector(0, 0, 0)
										}):Play()
									end
								end

								task.wait(0.25)
								folder2:Destroy()
							end)
							task.spawn(function()
								local clone7 = C.Phase3.SpinSlash:Clone()
								clone7:PivotTo(cFrame)
								Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
								local model2 = clone7.Model2

								for i = 1, 3 do
									local v11 = 1
									local clone8 = model2:Clone()

									if i ~= 1 then
										v11 = i == 2 and 0.95 or i == 3 and 0.9 or v11
									end

									clone8:ScaleTo((i * 1.075 + 7) / v11)

									for i2, beam in pairs(clone8:GetDescendants()) do
										if beam:IsA("Beam") then
											beam.Enabled = true
										end
									end

									local primaryPart = clone8.PrimaryPart
									local v12 = clone7.PrimaryPart.CFrame * CFrame.Angles(
										math.rad((math.random(-180, 180))),
										math.rad((math.random(-180, 180))),
										(math.rad((math.random(-180, 180))))
									)
									local angularVelocity = primaryPart.AngularVelocity
									primaryPart.Anchored = false
									primaryPart.AlignPosition.Position = primaryPart.Position
									angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
									clone8:PivotTo(v12)
									Util.SetParentOverrideWithColor(clone8, clone7, player, "MagnetFruitVFXColor")
									clone8:GetScale()
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
										task.wait(0.05 * math.random() + 0.075 / v11)

										for i2, effect in pairs(clone8:GetDescendants()) do
											if effect:IsA("Beam") then
												TweenService:Create(
													effect,
													TweenInfo.new(0.1 / v11 + math.random() * 0.1 / v11),
													{
														Width0 = 0,
														Width1 = 0
													}
												):Play()
												local v14 = effect
												task.delay(1, function()
													v14:Destroy()
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
									local v10 = clone7:GetScale() * 0.75
									local v11 = v10 * 1.15

									for i = v10 * 100, v11 * 100, 10 do
										clone7:ScaleTo(i / 100)
										task.wait(0.005)
									end
								end)
							end)
							break
						else
							task.wait(0.015)
							position4 = position5
						end
					end

					for i, descendant in pairs(folder2:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
							descendant.Enabled = false
						elseif descendant:IsA("Highlight") then
							if folder2:GetAttribute("HIT") == true then
								local v7 = descendant
								task.delay(1, function()
									v7:Destroy()
								end)
							else
								descendant:Destroy()
							end
						end
					end

					if not v6 and folder2 and folder2.Parent then
						folder2.Anchored = false
						folder2.CanCollide = true
						folder2.AssemblyLinearVelocity = (position3 - folder2.Position).Unit * -(math.random(120, 200) / 1.5)
						folder2.AssemblyAngularVelocity = Vector3.new(
							math.random(-15, 15) / 5,
							math.random(-15, 15) / 5,
							math.random(-15, 15) / 5
						)
						task.delay(1 + math.random(), function()
							if not (folder2 and folder2.Parent) then
								return
							end

							TweenService:Create(folder2, TweenInfo.new(0.25), {
								Size = createVector(0, 0, 0)
							}):Play()

							if folder2:GetAttribute("ROD") then
								for i, child2 in pairs(folder2:GetChildren()) do
									if child2:IsA("WeldConstraint") or child2:IsA("Model") or not child2:IsA("BasePart") then
										continue
									end

									TweenService:Create(child2, TweenInfo.new(0.25), {
										Size = createVector(0, 0, 0)
									}):Play()
								end
							end

							task.wait(0.25)
							folder2:Destroy()
						end)
					end
				end)
			end
		end)
	elseif stage == 3 then
		local holding = data.Holding
		local rig = data.Rig

		if not rig then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 7)
		local child = workspace._WorldOrigin:FindFirstChild(player.Name .. "_CTransformed")

		if child then
			child.Name = "DESTROYING"
			local magnetModel = child:FindFirstChild("MagnetModel")

			if magnetModel then
				magnetModel:Destroy()
			end
		end

		local mousePos = data.MousePos
		local primaryPart = rig.PrimaryPart
		local v2

		if hasCrimsonGoldSkin(player) then
			v2 = C.Phase2B.HammerArcsteel
		else
			v2 = C.Phase2B.Hammer
		end

		local clone = v2:Clone()
		clone:PivotTo(primaryPart.CFrame)
		Util.SetParentOverrideWithColor(clone, folder, player, "MagnetFruitVFXColor")
		Util.Sound:Play("Magnet_Transformed_C_Held_Hammer_Summon_01", clone.PrimaryPart.Position)
		local v3 = hasCrimsonGoldSkin(player) and "Arcsteel " or ""
		local v4 = Util.Anims:Get(rig, v3 .. "Magnet Mech C Hold Start")
		local v5 = Util.Anims:Get(rig, v3 .. "Magnet Mech C Hold Loop")
		local v6 = Util.Anims:Get(rig, v3 .. "Magnet Mech C Hold Jump")
		local v7 = Util.Anims:Get(rig, v3 .. "Magnet Mech C Hold Hammer Jump Loop")
		local v8 = Util.Anims:Get(rig, v3 .. "Magnet Mech C Hold Jump End")
		local v9 = Util.Anims:Get(clone, "Magnet Mech Hammer C Hold Start")
		local v10 = Util.Anims:Get(clone, "Magnet Mech Hammer C Hold Loop")
		local v11 = Util.Anims:Get(clone, "Magnet Mech Hammer C Hold Jump Start")
		local v12 = Util.Anims:Get(clone, "Magnet Mech Hammer C Hold Jump Loop")
		local v13 = Util.Anims:Get(clone, "Magnet Mech Hammer C Hold Jump End")
		local weld = Instance.new("Weld")
		weld.Parent = clone
		weld.Part0 = clone.PrimaryPart
		clone.PrimaryPart.Anchored = false
		weld.Part1 = rig.PrimaryPart
		weld.C1 = CFrame.new(1, 78.527, 2.568)
		task.spawn(function()
			local position = clone.PrimaryPart.Position
			local scrapModelA2

			if hasCrimsonGoldSkin(data.Player) then
				local scrapModelA22 = v.ScrapModelA2
				scrapModelA2 = scrapModelA22 and scraps:FindFirstChild(scrapModelA22)

				if not scrapModelA2 then
					scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
				end
			else
				scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
			end

			local scrapModelA3 = scraps.ScrapModelA3
			scrapModelA2:ScaleTo(8.725)
			scrapModelA3:ScaleTo(1.25)
			local clones = {}

			local function CreateScrapPrisonSphere(cframe, folder2)
				for i = 1, 20 do
					local v15 = i
					local v16 = 0.135 + math.random() * 0.025
					task.spawn(function()
						local v17

						if v15 % 10 == 0 then
							v17 = scrapModelA3
						else
							v17 = scrapModelA2

							if math.random(1, 7) == 1 then
								v17 = scrapModelA3
							end
						end

						local children = v17:GetChildren()

						if #children == 0 then
							return
						end

						local clone2 = children[math.random(1, #children)]:Clone()
						clone2.Size *= 0.5
						Util.SetParentOverrideWithColor(clone2, folder2, player, "MagnetFruitVFXColor")
						table.insert(clones, clone2)
						local v18 = 1 - v15 / 19 * 2
						local v19 = math.sqrt(1 - v18 * v18)
						local v20 = 2.399963229728653 * v15
						local v21 = Vector3.new(math.cos(v20) * v19, v18, math.sin(v20) * v19) * 25
						local v22 = cframe.Position + v21
						local cframe2 = CFrame.lookAt(v22, cframe.Position)
						clone2:SetAttribute("BaseCF", cframe2)
						local v23 = cframe.Position + Vector3.new(
							math.random(-60, 60) * 3,
							math.random(-60, 60),
							math.random(-60, 60) * 3
						)
						clone2:PivotTo(CFrame.new(v23, cframe.Position))
						local unit = (cframe.Position - v23).Unit
						clone2:PivotTo(CFrame.lookAt(v23, v23 + unit))
						TweenService:Create(
							clone2,
							TweenInfo.new(v16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								CFrame = CFrame.lookAt(v22, v23 + unit)
							}
						):Play()
						task.spawn(function()
							task.wait(v16)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									CFrame = cframe2
								}
							):Play()
						end)
					end)
				end
			end

			task.spawn(function()
				CreateScrapPrisonSphere(CFrame.new(position + createVector(0, 10, 0)), folder)
			end)
			task.wait(0.25)

			for _, v14 in pairs(clones) do
				local v15 = v14
				task.spawn(function()
					v15.Anchored = false
					v15.CanCollide = true
					v15.AssemblyLinearVelocity = (v15.Position - position).Unit * (math.random(200, 300) / 5) + Vector3.new(
						math.random(-25, 25),
						math.random(30, 80),
						math.random(-25, 25)
					)
					v15.AssemblyAngularVelocity = Vector3.new(
						math.random(-20, 20),
						math.random(-20, 20),
						math.random(-20, 20)
					)
					task.delay(1 + math.random() * 0.5, function()
						TweenService:Create(v15, TweenInfo.new(0.5), {
							Size = createVector(0, 0, 0)
						}):Play()
						task.wait(0.5)
						v15:Destroy()
					end)
				end)
			end

			local clone2 = C.Phase3.ExplosionFinal:Clone()
			clone2.CFrame = startCFrame * CFrame.new(0, 25, 0)
			Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local lifetime = emitter.Lifetime
				emitter.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		end)
		v4.Priority = Enum.AnimationPriority.Action2
		v4:Play()
		v9.Priority = Enum.AnimationPriority.Action2
		v9:Play()
		v5:Play()
		v5.Looped = true
		v10.Looped = true
		v10:Play()
		task.wait(0.25)
		local clone2 = C.Phase3B.SpinAura:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "MagnetFruitVFXColor")
		clone2.Massless = true
		clone2.Anchored = false
		clone2.Weld.Part1 = primaryPart
		clone2.Weld.C1 = CFrame.new(0, 25, 0)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(1)
			emitter.Enabled = true
		end

		local v14 = Util.Sound:Play("Magnet_Transformed_C_Held_Spin_Attack_01", root)
		TweenService:Create(v14, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		local _ = tick() + 0.25
		local _ = tick() + 1
		local now = tick()
		local now2 = os.clock()
		local total = 0

		while true do
			startCFrame = primaryPart.CFrame * CFrame.new(0, 50, 0)

			if now - tick() <= 0 then
				now = tick() + 0.135
				task.spawn(function()
					local v15 = startCFrame * CFrame.new(0, -25, 0) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
						math.rad(total),
						0,
						0
					)
					total += 70
					local cFrame = v15 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(
						1.7453292519943295,
						0,
						0
					)
					task.spawn(function()
						local clone3 = C.Phase3B.SpinTrail:Clone()
						clone3.CFrame = cFrame
						Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
						local v17 = 0.1 * math.random() + 0.075

						for _ = 1, 3 do
							local tween = TweenService:Create(
								clone3,
								TweenInfo.new(v17 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone3.CFrame * CFrame.Angles(-1.2217304763960306, 0, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end

						local tween = TweenService:Create(
							clone3,
							TweenInfo.new(v17 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone3.CFrame * CFrame.Angles(-0.4072434921320102, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end)
					ClawSlash(cFrame, folder, 6.5, player) -- equivalent call inferred; original call site unknown
					local clone3 = C.Phase3B.HitImpactModel:Clone()
					clone3:PivotTo(v15 * CFrame.new(0, 0, -78))
					Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
					clone3:ScaleTo(6.5)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v21 = emitter
						task.spawn(function()
							if v21:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v21:GetAttribute("EmitDelay"))
							end

							v21:Emit(v21:GetAttribute("EmitCount"))
						end)
					end

					DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
				end)
			end

			task.wait()
			local now3 = os.clock()
			root.CFrame = HeldMotion.getSpinCFrame(root.CFrame, mousePos.Value, now3 - now2)

			if holding and holding.Value ~= false then
				now2 = now3
			else
				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter:Emit(1)
					emitter.Enabled = false
				end

				if v14 then
					Util.Sound:FadeOut(v14, 0.2)
				end

				task.spawn(function()
					task.wait(0.05)
					local v15 = primaryPart.CFrame * CFrame.new(-5, 50, -5) * CFrame.Angles(
						0,
						0.4363323129985824,
						0.7853981633974483
					) * CFrame.Angles(2.6179938779914944, 0, 0)
					local cFrame = v15 * CFrame.Angles(1.0471975511965976, 0, 0) * CFrame.Angles(
						1.7453292519943295,
						0,
						0
					)
					task.spawn(function()
						local clone3 = C.Phase3B.SpinTrail:Clone()
						clone3.CFrame = cFrame
						Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
						local v17 = 0.1 * math.random() + 0.075

						for _ = 1, 3 do
							local tween = TweenService:Create(
								clone3,
								TweenInfo.new(v17 / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = clone3.CFrame * CFrame.Angles(-1.2217304763960306, 0, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end

						local tween = TweenService:Create(
							clone3,
							TweenInfo.new(v17 / 3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = clone3.CFrame * CFrame.Angles(-0.4072434921320102, 0, 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
					end)
					ClawSlash(cFrame, folder, 5, player) -- equivalent call inferred; original call site unknown
					local clone3 = C.Phase3B.HitImpactModel:Clone()
					clone3:PivotTo(v15 * CFrame.new(0, 0, -60))
					Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")
					clone3:ScaleTo(5)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v21 = emitter
						task.spawn(function()
							if v21:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v21:GetAttribute("EmitDelay"))
							end

							v21:Emit(v21:GetAttribute("EmitCount"))
						end)
					end

					DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown
				end)
				v5:Stop()
				v10:Stop()
				v6:Play()
				v11:Play()
				Util.Sound:Play("Magnet_Transformed_C_Held_Jump_01", root)
				local v15 = {
					[v6] = v6,
					[v11] = v11
				}
				task.wait(0.05)
				local clone3 = C.Phase3B.JumpImpact:Clone()
				clone3.CFrame = primaryPart.CFrame
				Util.SetParentOverrideWithColor(clone3, folder, player, "MagnetFruitVFXColor")

				if (workspace.CurrentCamera.CFrame.p - clone3.Position).Magnitude < 200 then
					Util.CameraShaker:ShakeOnce(8, 6, 0.1, 0.45)
				end

				DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				task.spawn(function()
					local cFrame = clone3.CFrame
					task.spawn(function()
						local clone4 = C.Phase3.SpinSlash:Clone()
						clone4:PivotTo(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
						Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
						local model2 = clone4.Model2

						for i = 1, 7 do
							local v18 = 1
							local clone5 = model2:Clone()
							local v19 = 0.35

							if i ~= 1 then
								if i == 2 then
									v18 = 0.95
									v19 = 0.25
								elseif i == 3 then
									v18 = 0.9
									v19 = 0.15
								elseif i == 4 then
									v18 = 0.85
									v19 = 0.35
								elseif i == 5 then
									v18 = 0.8
									v19 = 0.25
								end
							end

							clone5:ScaleTo((i * 0.7 + 7) / v18)

							for i2, beam in pairs(clone5:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								beam.Enabled = true
								beam.Width0 *= 0.15
								beam.Width1 *= 0.15
							end

							local primaryPart2 = clone5.PrimaryPart
							local v20 = clone4.PrimaryPart.CFrame * CFrame.Angles(
								math.rad(math.random(-180, 180) / 15),
								math.rad(math.random(-180, 180) / 15),
								(math.rad(math.random(-180, 180) / 1))
							)

							if i > 5 then
								v20 = clone4.PrimaryPart.CFrame * CFrame.Angles(
									math.rad(math.random(-180, 180) / 1),
									math.rad(math.random(-180, 180) / 1),
									(math.rad(math.random(-180, 180) / 1))
								)
								v19 = 0.25
							end

							local angularVelocity = primaryPart2.AngularVelocity
							primaryPart2.Anchored = false
							primaryPart2.AlignPosition.Position = primaryPart2.Position
							angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 15)
							clone5:PivotTo(v20)
							Util.SetParentOverrideWithColor(clone5, clone4, player, "MagnetFruitVFXColor")
							clone5:GetScale()
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
								task.wait(0.05 * math.random() + v19 * 0.35)

								for i2, effect in pairs(clone5:GetDescendants()) do
									if effect:IsA("Beam") then
										TweenService:Create(
											effect,
											TweenInfo.new(1 / v18 + math.random() * 0.075 / v18),
											{
												Width0 = effect.Width0 * 2,
												Width1 = effect.Width1 * 2
											}
										):Play()
										local v22 = effect
										task.delay(1, function()
											v22:Destroy()
										end)
										local v23 = effect
										task.spawn(function()
											for i3 = 90, 100 do
												v23.Transparency = NumberSequence.new(i3 / 100, i3 / 100)
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
							local v17 = clone4:GetScale() * 0.425
							local v18 = v17 * 1.75

							for i = v17 * 100, v18 * 100, 3.5 do
								clone4:ScaleTo(i / 100)
								task.wait(0.005)
							end

							local v19 = clone4:GetScale() * 1
							local v20 = v19 * 1.25

							for i = v19 * 100, v20 * 100 do
								clone4:ScaleTo(i / 100)
								task.wait(0.01)
							end
						end)
					end)

					for i = 1, 10 do
						task.spawn(function()
							local clone4 = C.Phase3B.Trail:Clone()
							clone4.CFrame = cFrame
							Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")
							clone4.CFrame = clone4.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, math.random(20, 35) * 2)

							for i2, effect in pairs(clone4:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end

							TrailCurve(
								clone4,
								cFrame,
								clone4.Position,
								cFrame * CFrame.new(0, 50, 0).Position + Vector3.new(
									math.random(-25, 25),
									math.random(-15, 15),
									math.random(-25, 25)
								),
								CFrame.new(math.random(-50, 50) / 3, math.random(-50, 50) / 3, math.random(-50, 50) / 3),
								CFrame.new(math.random(-50, 50) / 3, math.random(-50, 50) / 3, math.random(-50, 50) / 3),
								math.random(25, 30) / 5
							)

							for i2, effect in pairs(clone4:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end
				end)
				v7:Play()
				v12:Play()
				v15[v7] = v7
				v15[v12] = v12
				local clone4 = C.Phase3B.DashAura:Clone()
				clone4.CFrame = primaryPart.CFrame
				Util.SetParentOverrideWithColor(clone4, folder, player, "MagnetFruitVFXColor")

				for _, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				local position = root.Position
				local flatDirection = HeldMotion.getFlatDirection(root.CFrame, root.Position)
				local raycastResult = workspace:Raycast(position, flatDirection * 150, raycastParams)
				local magnitude = ((raycastResult and raycastResult.Position or position + flatDirection * 150) - position).Magnitude
				local value = mousePos.Value
				local vector2 = Vector3.new(value.X, position.Y, value.Z)
				local magnitude2 = (vector2 - position).Magnitude
				local _ = value.Y < position.Y - 5
				local v17 = position + HeldMotion.getFlatDirection(root.CFrame, vector2) * math.min(
					magnitude2,
					magnitude
				)
				local flatDirection2 = HeldMotion.getFlatDirection(root.CFrame, v17)
				local v18 = root.Size.Y * 0.5 + root.Parent.Humanoid.HipHeight
				local raycastResult2 = workspace:Raycast(
					v17 + createVector(0, 10, 0),
					createVector(0, -600, 0),
					raycastParams
				)
				local position2 = raycastResult2 and raycastResult2.Position or v17 + createVector(0, -590, 0)
				local landingPosition = HeldMotion.getLandingPosition(position2, v18)
				local now4 = tick()
				local v19 = tick() + 0.25
				local position3 = root.Position

				local function leapEase(p: number)
					-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
					local function smoothstep(p2: number)
						return p2 * p2 * (3 - p2 * 2)
					end

					if p < 0.35 then
						return smoothstep(p / 0.35) * 0.35 * 1.05
					end

					if p <= 0.65 then
						return smoothstep((p - 0.35) / 0.30000000000000004) * 0.05 + 0.3675
					end

					local v20 = (p - 0.65) / 0.35
					return v20 * v20 * v20 * 0.5825 + 0.4175
				end

				local function onPeakReached(_)
					task.spawn(function()
						local v20 = tick() + 0.5
						local v21 = root

						repeat
							local clone5 = C.Phase2B.SmallTrail:Clone()
							clone5.CFrame = v21.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, -math.random(50, 100))
							Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
							local position4 = v21.Position
							local position5 = clone5.Position
							local v22 = (position5 + position4) / 2 + Vector3.new(
								math.random(-15, 15),
								math.random(10, 25),
								math.random(-15, 15)
							)
							local v23 = math.random(30, 45) / 100
							local heartbeatConnection = nil
							local v24 = tick()
							local unit = Vector3.new(
								math.random(-100, 100) / 100,
								math.random(-100, 100) / 100,
								math.random(-100, 100) / 100
							).Unit
							heartbeatConnection = RunService.Heartbeat:Connect(function()
								local v31 = (tick() - v24) / v23

								if v31 >= 1 then
									clone5.Position = position4
									heartbeatConnection:Disconnect()
								else
									local quadBezier = QuadBezier(position5, v22, position4, v31) -- equivalent call inferred; original call site unknown
									local v35 = (tick() - v24) * 15
									local v36 = 50 * (1 - v31)
									local v37 = quadBezier + CFrame.fromAxisAngle(unit, v35):VectorToWorldSpace((Vector3.new(
										v36,
										0,
										0
									)))
									clone5.CFrame = CFrame.lookAt(v37, position4)
								end
							end)
							task.wait(0.025)
						until v20 - tick() <= 0
					end)
					task.spawn(PeakAura, root, C.Phase2B, folder, player)
				end

				local flag = true
				local v20 = 250
				local v21 = false

				while flag do
					local v22 = (tick() - now4) / 0.5
					local v23 = v22 >= 1 and 1 or v22
					local v24 = leapEase(v23)
					local quadBezier = QuadBezier(
						position,
						(position + landingPosition) / 2 + Vector3.new(0, v20, 0),
						landingPosition,
						v24
					) -- equivalent call inferred; original call site unknown
					root.CFrame = CFrame.new(quadBezier, quadBezier + flatDirection2)
					local v27 = quadBezier - position3
					local v28 = quadBezier + createVector(0, 30, 0)

					if v27.Magnitude > 0.001 then
						clone4.CFrame = CFrame.new(v28, v28 + v27.Unit)
					else
						clone4.CFrame = CFrame.new(v28, v28 + flatDirection2)
					end

					clone4.CFrame *= CFrame.new(0, 0, -10)

					if v21 or not (v23 >= 0.5) then
						position3 = quadBezier
					else
						task.spawn(function()
							local v29 = tick() + 0.5
							local v30 = root

							repeat
								local clone5 = C.Phase2B.SmallTrail:Clone()
								clone5.CFrame = v30.CFrame * CFrame.Angles(
									math.rad((math.random(-180, 180))),
									math.rad((math.random(-180, 180))),
									(math.rad((math.random(-180, 180))))
								) * CFrame.new(0, 0, -math.random(50, 100))
								Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
								local position4 = v30.Position
								local position5 = clone5.Position
								local v31 = (position5 + position4) / 2 + Vector3.new(
									math.random(-15, 15),
									math.random(10, 25),
									math.random(-15, 15)
								)
								local v32 = math.random(30, 45) / 100
								local heartbeatConnection = nil
								local v33 = tick()
								local unit = Vector3.new(
									math.random(-100, 100) / 100,
									math.random(-100, 100) / 100,
									math.random(-100, 100) / 100
								).Unit
								heartbeatConnection = RunService.Heartbeat:Connect(function()
									local v40 = (tick() - v33) / v32

									if v40 >= 1 then
										clone5.Position = position4
										heartbeatConnection:Disconnect()
									else
										local quadBezier2 = QuadBezier(position5, v31, position4, v40) -- equivalent call inferred; original call site unknown
										local v44 = (tick() - v33) * 15
										local v45 = 50 * (1 - v40)
										local v46 = quadBezier2 + CFrame.fromAxisAngle(unit, v44):VectorToWorldSpace((Vector3.new(
											v45,
											0,
											0
										)))
										clone5.CFrame = CFrame.lookAt(v46, position4)
									end
								end)
								task.wait(0.025)
							until v29 - tick() <= 0
						end)
						task.spawn(PeakAura, root, C.Phase2B, folder, player)
						local lastTime = tick()
						local cframe = CFrame.new(quadBezier, quadBezier + flatDirection2)
						position3 = quadBezier
						v21 = true

						while tick() - lastTime < 0.5 do
							root.CFrame = cframe
							task.wait()
						end

						now4 += tick() - lastTime
					end

					if v19 - tick() <= 0 then
						local raycastResult3 = workspace:Raycast(quadBezier, createVector(0, -5, 0), raycastParams)

						if raycastResult3 or v24 >= 1 then
							flag = false

							if raycastResult3 then
								local landingPosition2 = HeldMotion.getLandingPosition(raycastResult3.Position, v18)
								root.CFrame = CFrame.lookAt(landingPosition2, landingPosition2 + flatDirection2)
							end
						end
					end

					task.wait()
				end

				for _, v22 in pairs(v15) do
					v22:Stop()
				end

				for _, effect in pairs(clone4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				v8:Play()
				v13:Play()
				startCFrame = root.CFrame * CFrame.new(0, 50, 0)
				local v22 = startCFrame * CFrame.new(0, 0, -50)
				local raycastResult3 = workspace:Raycast(
					v22.Position + createVector(0, -40, 0),
					createVector(0, -600, 0),
					raycastParams
				)
				local position4 = raycastResult3 and raycastResult3.Position or v22.Position + createVector(0, -640, 0)
				local landingPosition2 = HeldMotion.getLandingPosition(position4, 0)
				local v23 = v22 - v22.Position + (landingPosition2 + createVector(0, 50, 0))
				Util.Sound:Play("Magnet_Transformed_C_Held_Explosion_01", v23.Position)

				if (workspace.CurrentCamera.CFrame.p - v23.Position).Magnitude < 210 then
					Util.CameraShaker:ShakeOnce(12, 8, 0.2, 0.6)
				end

				task.spawn(function()
					local clone5 = C.Phase3.SpinSlash:Clone()
					clone5:PivotTo(v23 * CFrame.Angles(1.5707963267948966, 0, 0))
					Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
					local model2 = clone5.Model2

					for i = 1, 5 do
						local v25 = 1
						local clone6 = model2:Clone()
						local v26 = 1

						if i ~= 1 then
							if i == 2 then
								v25 = 0.95
								v26 = 0.75
							elseif i == 3 then
								v25 = 0.9
								v26 = 0.55
							elseif i == 4 then
								v25 = 0.85
								v26 = 0.35
							elseif i == 5 then
								v25 = 0.8
								v26 = 0.25
							end
						end

						clone6:ScaleTo((i * 1.075 + 20) / v25)

						for _, beam in pairs(clone6:GetDescendants()) do
							if not beam:IsA("Beam") then
								continue
							end

							beam.Enabled = true
							beam.Width0 *= 0.35
							beam.Width1 *= 0.35
						end

						local primaryPart2 = clone6.PrimaryPart
						local v27 = clone5.PrimaryPart.CFrame * CFrame.Angles(
							math.rad(math.random(-180, 180) / 15),
							math.rad(math.random(-180, 180) / 15),
							(math.rad(math.random(-180, 180) / 1))
						)

						if i > 5 then
							v27 = clone5.PrimaryPart.CFrame * CFrame.Angles(
								math.rad(math.random(-180, 180) / 1),
								math.rad(math.random(-180, 180) / 1),
								(math.rad(math.random(-180, 180) / 1))
							)
							v26 = 0.25
						end

						local angularVelocity = primaryPart2.AngularVelocity
						primaryPart2.Anchored = false
						primaryPart2.AlignPosition.Position = primaryPart2.Position
						angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20) / 15)
						clone6:PivotTo(v27)
						Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
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
							task.wait(0.05 * math.random() + v26 * 0.35)

							for i2, effect in pairs(clone6:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(effect, TweenInfo.new(1 / v25 + math.random() * 0.075 / v25), {
										Width0 = effect.Width0 * 2,
										Width1 = effect.Width1 * 2
									}):Play()
									local v29 = effect
									task.delay(1, function()
										v29:Destroy()
									end)
									local v30 = effect
									task.spawn(function()
										for i3 = 90, 100 do
											v30.Transparency = NumberSequence.new(i3 / 100, i3 / 100)
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
						local v24 = clone5:GetScale() * 0.425
						local v25 = v24 * 1.75

						for i = v24 * 100, v25 * 100, 3.5 do
							clone5:ScaleTo(i / 100)
							task.wait(0.005)
						end

						local v26 = clone5:GetScale() * 1
						local v27 = v26 * 1.25

						for i = v26 * 100, v27 * 100 do
							clone5:ScaleTo(i / 100)
							task.wait(0.01)
						end
					end)
				end)
				task.spawn(function()
					local clone5 = C.Phase3B.SpinSlash2:Clone()
					clone5:PivotTo(v23 * CFrame.Angles(1.5707963267948966, 0, 0))
					Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")
					local model = clone5.Model

					for i = 3, 5 do
						local v25 = 1
						local clone6 = model:Clone()

						if i ~= 1 then
							if i == 2 then
								v25 = 0.95
							elseif i == 3 then
								v25 = 0.9
							elseif i == 4 then
								v25 = 0.85
							elseif i == 5 then
								v25 = 0.8
							else
								v25 = v25
							end
						end

						clone6:ScaleTo((i * 1.075 + 15) / v25)

						for _, beam in pairs(clone6:GetDescendants()) do
							if beam:IsA("Beam") then
								beam.Enabled = true
							end
						end

						local primaryPart2 = clone6.PrimaryPart
						local v26 = clone5.PrimaryPart.CFrame * CFrame.new(0, i * 3, 0) * CFrame.Angles(
							math.rad(math.random(-180, 180) / 10),
							math.rad(math.random(-180, 180) / 10),
							(math.rad(math.random(-180, 180) / 1))
						)
						local angularVelocity = primaryPart2.AngularVelocity
						primaryPart2.Anchored = false
						primaryPart2.AlignPosition.Position = primaryPart2.Position + Vector3.new(
							math.random(-10, 10) / 10,
							i * 7 + 15,
							math.random(-10, 10) / 10
						)
						angularVelocity.AngularVelocity = Vector3.new(0, 0, math.random(10, 20))
						clone6:PivotTo(v26)
						Util.SetParentOverrideWithColor(clone6, clone5, player, "MagnetFruitVFXColor")
						clone6:GetScale()
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
							task.wait(0.05 * math.random() + 0.135 / v25)

							for i2, effect in pairs(clone6:GetDescendants()) do
								if effect:IsA("Beam") then
									TweenService:Create(
										effect,
										TweenInfo.new(0.15 / v25 + math.random() * 0.15 / v25),
										{
											Width0 = 0,
											Width1 = 0
										}
									):Play()
									local v28 = effect
									task.delay(1, function()
										v28:Destroy()
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
						local v24 = clone5:GetScale() * 0.75
						local v25 = v24 * 1.15

						for i = v24 * 100, v25 * 100, 10 do
							clone5:ScaleTo(i / 100)
							task.wait(0.005)
						end
					end)
				end)
				Explosion(v23, folder, raycastParams, player)
				local clone5 = C.Phase3B.ExplosionImpact:Clone()
				clone5.CFrame = v23 * CFrame.new(0, -50, 0)
				Util.SetParentOverrideWithColor(clone5, folder, player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone5:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 0.75, lifetime.Max * 0.75)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown
				task.wait(0.5)
				local proxyPartAtBone = makeProxyPartAtBone(clone.PrimaryPart.Handle.Core)
				proxyPartAtBone.Parent = clone
				local clone6 = C.Phase3B.HammerEndImpact:Clone()
				clone6.CFrame = proxyPartAtBone.CFrame
				Util.SetParentOverrideWithColor(clone6, folder, player, "MagnetFruitVFXColor")

				for _, emitter in pairs(clone6:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local lifetime = emitter.Lifetime
					emitter.Lifetime = NumberRange.new(lifetime.Min * 1.5, lifetime.Max * 1.5)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown
				local scrapModelA2

				if hasCrimsonGoldSkin(data.Player) then
					local scrapModelA22 = v.ScrapModelA2
					scrapModelA2 = scrapModelA22 and scraps:FindFirstChild(scrapModelA22)

					if not scrapModelA2 then
						scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
					end
				else
					scrapModelA2 = scraps:FindFirstChild("ScrapModelA2")
				end

				scrapModelA2:ScaleTo(8.725)
				local v25 = scrapModelA2:GetChildren()
				task.spawn(function()
					local position5 = proxyPartAtBone.Position

					for i = 1, 10 do
						task.spawn(function()
							local clone7 = v25[math.random(1, #v25)]:Clone()
							local v26 = position5 + Vector3.new(
								math.random(-5, 5),
								math.random(-5, 5),
								math.random(-5, 5)
							)
							clone7.CFrame = CFrame.new(v26)
							clone7.Anchored = false
							clone7.CanCollide = false
							clone7.Size = clone7.Size * math.random(10, 15) / 25
							Util.SetParentOverrideWithColor(clone7, folder, player, "MagnetFruitVFXColor")
							task.delay(0.15, function()
								clone7.CanCollide = true
							end)
							clone7.AssemblyLinearVelocity = (v26 - position5).Unit * (math.random(200, 300) / 5) + Vector3.new(
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
				end)
				clone:Destroy()
				task.wait(1)
				break
			end
		end
	end
end