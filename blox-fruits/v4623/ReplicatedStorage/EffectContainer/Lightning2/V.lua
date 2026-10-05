local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").V.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function areShiftedColorsEqual(player, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = player:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
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

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt1(player, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 25
	v.Frequency = 15
	v.AnimationSpeed = 10
	local maxThicknessMultiplier = math.random(2, 5)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 5
	v.PulseLength = 1000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.388235, 0.988235, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function ShafiBolt2(player, ...)
	local v = LightningBoltShafi.new(...)
	v.CurveSize0 = 0
	v.CurveSize1 = 0
	v.MinRadius = 0
	v.MaxRadius = 25
	v.Frequency = 25
	v.AnimationSpeed = 10
	local maxThicknessMultiplier = math.random(1, 3)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.419608, 0.952941, 1), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function ShafiBolt3(player, ...)
	local v = LightningBoltShafi.new(...)
	v.CurveSize0 = -150
	v.CurveSize1 = 250
	v.MinRadius = 0
	v.MaxRadius = 25
	v.Frequency = 25
	v.AnimationSpeed = 10
	local maxThicknessMultiplier = math.random(1, 3)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = 10
	v.PulseLength = 1000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.4, 1, 0.980392), player, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
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

local function TrailCurve(primaryPart, startCFrame, position, position2, cframe, cframe2, p)
	local magnitude = (position - position2).Magnitude
	local v = (position - position2) / 2
	local position3 = CFrame.new(CFrame.new(position) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position2) * (v / 1.5)).Position
	math.random(20, 30)
	local v2 = CFrame.new(position3, position3 + startCFrame.LookVector) * cframe.Position
	local v3 = CFrame.new(position4, position4 + startCFrame.LookVector) * cframe2.Position
	local lastTime = tick()
	local v4 = magnitude / p / 60
	local _ = (magnitude / p + p) / 60

	while tick() - lastTime < v4 do
		local v5 = (tick() - lastTime) / v4
		local v6 = cubicBezier(v5, position, v2, v3, position2)
		primaryPart.CFrame = CFrame.new(primaryPart.CFrame:Lerp(CFrame.new(v6, position2), v5).Position)
		RunService.Heartbeat:Wait()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyAfter(clone, duration)
	task.delay(duration, function()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RockCrater(p, parent, data, p2)
	task.spawn(function()
		local rockType = data.RockType
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local offset = data.Offset
		local v = AlignCFrame(CFrame.new(p.Position), p.Normal) + p.Normal * 0.01
		local v2 = {}

		for _ = 1, amount do
			local clone = rockType:Clone()
			clone.Parent = parent
			DestroyAfter(clone, 7) -- equivalent call inferred; original call site unknown
			table.insert(v2, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

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

			if math.random(1, 7) < 2 then
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(0, 0, offset)
			end

			v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
				0,
				math.random(-5, 5) / 3,
				math.random(-offset, offset * 2)
			)
			local ray = Ray.new(v4.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
			local part, v5 = workspace:FindPartOnRayWithIgnoreList(ray, p2.FilterDescendantsInstances)

			if part then
				local v6 = (v4.Position - p.Position).Magnitude / 150
				local v7 = size * math.random(15, 30) / 10
				local v8 = size * math.random(5, 20) / 10
				local v9 = size * math.random(30, 50) / 10
				v4.Size = Vector3.new(v7 * v6, v8 * v6, v9 * v6)
				v4.Position = v5 + Vector3.new(0, -v4.Size.Y * math.random(5, 6) / 15, 0)
				v4.CFrame = CFrame.new(v4.Position, p.Position) * CFrame.new(
					0,
					math.random(-5, 5) / 3,
					math.random(-offset / 2, offset / 2)
				)
				v4.CFrame = CFrame.new(
					v4.Position,
					v.Position + Vector3.new(0, math.random(-55, -45) / 100 + v4.Size.Y / 500, 0)
				) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v6 / 2), 0, 0) * CFrame.Angles(
					0,
					0,
					(math.rad((math.random(-5, 5))))
				)
				v4.Material = part.Material
				v4.Color = part.Color
			else
				v2[v4] = nil
				v4:Destroy()
			end

			TweenService:Create(v4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
				Position = v4.Position + Vector3.new(0, v4.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v6 = v4
			local v7 = v4
			task.spawn(function()
				wait(duration + math.random(10, 50) / 100)
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

				if v2 then
					v2[v6] = nil
				end
			end)
		end
	end)
end

local function TweenScale(instance, p: number, p2: number)
	local scale = instance:GetScale()
	local total = 0

	while total < p2 do
		total += RunService.Heartbeat:Wait()
		local v = math.clamp(total / p2, 0, 1)
		instance:ScaleTo(scale + (p - scale) * v)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nukeName(data)
	local player = data.Player
	local success, result = pcall(function()
		return player.Name
	end)
	return ((not success or type(result) ~= "string" or not result) and "NPC" or result) .. "_ThunderNuke"
end

return function(data)
	local SIZE_AND_HITBOX_MULTIPLIER = data.SIZE_AND_HITBOX_MULTIPLIER or 1
	local player = data.Player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local startCFrame = data.StartCFrame
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_V_ThunderBomb_ActivateHold_01", root)
		local v = 0.5 * SIZE_AND_HITBOX_MULTIPLIER
		local endCFrame = data.EndCFrame
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = endCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")

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

		local clone2 = assets.Phase0A.Aura:Clone()
		clone2.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
		clone2.Anchored = false
		clone2.Massless = true
		clone2.Weld.Part1 = root
		local v2 = Util.Sound:Play("BF_Thunder_V_ThunderBomb_Held_GroundLayer_01", root)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			local position = startCFrame.Position
			local raycastResult = workspace:Raycast(
				position + createVector(0, 1, 0),
				createVector(-0, -10, -0),
				raycastParams
			)

			if raycastResult then
				local clone3 = assets.Phase0A.FloorAura:Clone()
				clone3.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				Util.SetParentOverrideWithColor(clone3, clone2, player, "LightningFruitVFXColor")
			end
		end)
		local clone3 = assets.Phase0A.StartImpact0:Clone()
		clone3.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.wait(0.15)
		local clonesByClone = {}
		task.spawn(function()
			for _ = 1, 5 do
				task.spawn(function()
					local v3 = math.random(10, 50) / 100
					task.wait(v3)
					local clone4 = assets.Phase1.TrailModel:Clone()
					clone4:PivotTo(endCFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						25 + math.random(-25, 50),
						0
					))
					Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
					clonesByClone[clone4] = clone4
					clone4:ScaleTo(math.random(20, 25) * 2)
					local start = clone4.Start
					local trail = clone4.Trail
					local cframe = CFrame.new(0, 0, -math.random(150, 200) * 2)
					TweenService:Create(trail.Weld, TweenInfo.new(0.5), {
						C1 = cframe
					}):Play()
					trail.Trail1.Lifetime = math.random(150, 200) / 1000
					local angularVelocity = start.AngularVelocity
					start.Anchored = false
					start.AlignPosition.Position = start.Position
					angularVelocity.AngularVelocity = Vector3.new(math.random(-1, 1) / 5, 50, math.random(-1, 1) / 5)
					TweenService:Create(angularVelocity, TweenInfo.new(0.5), {
						AngularVelocity = Vector3.new(
							math.random(-1, 1) / 5,
							math.random(10, 20),
							math.random(-1, 1) / 5
						)
					}):Play()

					for _, effect in pairs(clone4:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
							continue
						end

						local v4 = effect
						task.spawn(function()
							v4.Enabled = false
							task.wait(math.random(5, 15) / 100)
							v4.Enabled = true
						end)
					end
				end)
			end
		end)
		local clonesByClone2 = {}
		task.spawn(function()
			local clone4 = assets.Phase1.SpinSlash:Clone()
			clone4:PivotTo(endCFrame * CFrame.new(0, 30 + math.random(-15, 15), 0))
			Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
			local model = clone4.Model

			for i = 5, 10 do
				local v3 = i * 2 + 30
				local clone5 = model:Clone()
				clone5:ScaleTo(v3)
				local primaryPart = clone5.PrimaryPart
				local v4 = clone4.PrimaryPart.CFrame * CFrame.new(0, v3, 0) * CFrame.Angles(
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
				angularVelocity.AngularVelocity = Vector3.new(0, math.random(5, 10), 0)
				clone5:PivotTo(v4)
				Util.SetParentOverrideWithColor(clone5, clone4, player, "LightningFruitVFXColor")
				clonesByClone2[clone5] = clone5
				clone5:GetScale()
				task.spawn(function()
					task.spawn(function()
						local Y = clone5.Slash.Position.Y
						TweenService:Create(
							angularVelocity,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity.AngularVelocity + Vector3.new(
									math.random(-5, 5) / 10,
									math.random(3, 5) / 5,
									math.random(-5, 5) / 10
								)
							}
						):Play()
					end)
				end)
			end

			model:Destroy()
			task.spawn(function()
				local scale = clone4:GetScale()
				local v3 = scale * 1.5

				for i = scale * 100, v3 * 100, 5 do
					clone4:ScaleTo(i / 100)
					task.wait(0.005)
				end
			end)
		end)
		local _ = tick() + 5
		local clone4 = assets.Phase1.CloudModel:Clone()
		clone4:PivotTo(CFrame.new(startCFrame.Position) * CFrame.new(0, 225, 0))
		Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
		clone4:ScaleTo(2)
		local v3 = { "rbxassetid://139968635569467", "rbxassetid://110931244887804", "rbxassetid://75567018777414" }
		local v4 = {}

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v5 = emitter
			task.spawn(function()
				v5:Emit(1)
				v5.Enabled = true
			end)
		end

		local clone5 = assets.Phase2.SphereModel:Clone()
		clone5:PivotTo(CFrame.new(endCFrame.Position) * CFrame.new(0, 0, 0))
		clone5.Name = nukeName(data)
		Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player, "LightningFruitVFXColor")
		local v5 = Util.Sound:Play("BF_Thunder_V_ThunderBomb_Held_SkyLayer_01", clone5.PrimaryPart)
		clone5:ScaleTo(v)
		clone5.SelectionSphere1.Visible = false
		clone5.SelectionSphere1.Visible = true

		for _, descendant in pairs(clone5:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("SelectionSphere") then
				if descendant.Name == "SelectionSphere1" then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0.1),
						{
							SurfaceTransparency = 1
						}
					):Play()
				end
			elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.ForceField then
				local angularVelocity = descendant.AngularVelocity
				descendant.Anchored = false
				descendant.WeldConstraint.Enabled = false
				descendant.AlignPosition.Position = descendant.Position
				angularVelocity.AngularVelocity = Vector3.new(
					math.random(-10, 10),
					math.random(-10, 10),
					math.random(-10, 10)
				)
			end
		end

		local tween = TweenService:Create(clone5.PrimaryPart, TweenInfo.new(0.2), {
			Size = clone5.PrimaryPart.Size
		})
		clone5.PrimaryPart.Size = createVector(100, 100, 100)
		tween:Play()
		local screenColorLV = assets.Phase1.ScreenColorLV
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "ScreenColorLV"
		Util.SetParentOverrideWithColor(colorCorrectionEffect, game.Lighting, player, "LightningFruitVFXColor")
		colorCorrectionEffect:SetAttribute("ON", false)
		local position = startCFrame.Position
		local raycastResult = workspace:Raycast(
			position + createVector(0, 1, 0),
			createVector(-0, -10, -0),
			raycastParams
		)
		local clone6 = assets.Phase0A.RockSpinner:Clone()
		clone6.CFrame = startCFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
		local angularVelocity = clone6.AngularVelocity
		clone6.Anchored = false
		clone6.AlignPosition.Responsiveness = 10
		clone6.AlignPosition.Position = clone6.Position + createVector(0, 0, 0)
		angularVelocity.AngularVelocity = createVector(0, -8, 0)
		clone6.AlignPosition.Enabled = true
		angularVelocity.Enabled = true
		local now = tick()
		tick()
		local now2 = tick()
		local now3 = tick()
		local v6 = false
		local v7 = false

		while true do
			local absorbed = data.Proxy:GetAttribute("Absorbed")
			local v8 = 0.5 + absorbed / 6 * 0.5

			if clone5:GetScale() ~= v8 and not v6 then
				v6 = true
				local v9 = v8
				task.spawn(function()
					TweenScale(clone5, v9, 0.15)
					v6 = false
				end)
			end

			if workspace.CurrentCamera.CFrame.LookVector.Y > 0.5 then
				if not colorCorrectionEffect:GetAttribute("ON") then
					colorCorrectionEffect:SetAttribute("ON", true)
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.35), {
						Brightness = screenColorLV.Brightness,
						Contrast = screenColorLV.Contrast,
						Saturation = screenColorLV.Saturation,
						TintColor = screenColorLV.TintColor
					}):Play()
				end
			elseif colorCorrectionEffect:GetAttribute("ON") then
				colorCorrectionEffect:SetAttribute("ON", false)
				TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"LightningFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
			end

			task.spawn(function()
				if now - tick() <= 0 then
					now = tick() + 0.15

					for _ = 1, math.random(1, 2) do
						task.spawn(function()
							local clone7 = FX:WaitForChild("Lightning2").V.Part:Clone()
							clone7.CFrame = clone5.PrimaryPart.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, clone5.PrimaryPart.Size.Z / 2)
							Util.SetParentOverrideWithColor(clone7, folder, player, "LightningFruitVFXColor")
							clone7.Attach1.Position = Vector3.new(0, 0, -clone5.PrimaryPart.Size.Z)
							local shafiBolt1 = ShafiBolt1(player, clone7.Attach0, clone7.Attach1, 15, 3, folder)
							local curveSize = -clone5.PrimaryPart.Size.Z / 1.5
							local curveSize2 = clone5.PrimaryPart.Size.Z / 1.5
							shafiBolt1.CurveSize0 = curveSize
							shafiBolt1.CurveSize1 = curveSize2
							task.wait(0.5 * math.random() + 0.35)
							shafiBolt1:Destroy()
						end)
					end
				end
			end)
			task.spawn(function()
				local magnitude = (clone5.PrimaryPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

				for _, child in pairs(clone5.PrimaryPart.Attachment:GetChildren()) do
					if child:GetAttribute("TOP") then
						child.ZOffset = magnitude / 2.5 + 1
					else
						child.ZOffset = magnitude / 2.5
					end
				end

				clone5.PrimaryPart.Attachment.WorldCFrame = CFrame.new(
					clone5.PrimaryPart.Position,
					workspace.CurrentCamera.CFrame.Position
				) * CFrame.Angles(1.5707963267948966, 0, 0)
			end)

			if now3 - tick() <= 0 then
				now3 = tick() + 0.1

				if raycastResult then
					local clone7 = assets.Phase0A.SpinRock:Clone()
					clone7.Position = raycastResult.Position + createVector(0, 0.5, 0)
					clone7.Material = raycastResult.Instance.Material
					clone7.Color = raycastResult.Instance.Color
					clone7.Size = Vector3.new(math.random(1, 5) * 2, math.random(1, 5) * 2, math.random(1, 5) * 2)
					Util.SetParentOverrideWithColor(clone7, folder, player, "LightningFruitVFXColor")
					clone7.Anchored = false
					clone7.Weld.Part1 = clone6
					clone7.Weld.C1 = CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
						0,
						0,
						-math.random(10, 40) * 3
					)
					TweenService:Create(clone7.Weld, TweenInfo.new(3), {
						C1 = CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
							0,
							300 + math.random(50, 150),
							-math.random(80, 100) * 3
						),
						C0 = CFrame.Angles(
							math.rad((math.random(-180, 180))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-180, 180))))
						)
					}):Play()
					task.delay(5, function()
						clone7:Destroy()
					end)
				end
			end

			if now2 - tick() <= 0 then
				now2 = tick() + 0.25
				local clone7 = assets.Phase0A.SpinSlash:Clone()
				clone7:PivotTo(CFrame.new(startCFrame.Position) * CFrame.new(0, 0, 0))
				Util.SetParentOverrideWithColor(clone7, folder, player, "LightningFruitVFXColor")
				local v9 = math.random(1, 3)

				for _, beam in pairs(clone7:GetDescendants()) do
					if beam:IsA("Beam") then
						beam.Texture = v3[v9]
					end
				end

				local v10 = 1 + absorbed / 6 * 1

				if not v7 then
					v7 = true
					local v11 = clone7
					local v12 = v10
					task.spawn(function()
						TweenScale(v11, v12, 0.15)
						v7 = false
					end)
				end

				local primaryPart = clone7.PrimaryPart
				local v11 = clone7.PrimaryPart.CFrame * CFrame.new(0, v10 / 2, 0) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				)
				local angularVelocity2 = primaryPart.AngularVelocity
				primaryPart.Anchored = false
				primaryPart.AlignPosition.Responsiveness = 10
				primaryPart.AlignPosition.Position = primaryPart.Position + createVector(0, 0, 0)
				angularVelocity2.AngularVelocity = Vector3.new(0, -math.random(10, 15) * 2, 0)
				clone7:PivotTo(v11)
				primaryPart.AlignPosition.Enabled = true
				angularVelocity2.Enabled = true
				clone7:GetScale()
				local folder2 = clone7
				task.spawn(function()
					task.spawn(function()
						TweenService:Create(
							angularVelocity2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								AngularVelocity = angularVelocity2.AngularVelocity + Vector3.new(
									math.random(-5, 5) / 2,
									-math.random(5, 15),
									math.random(-5, 5) / 2
								)
							}
						):Play()
					end)
					task.wait(0.035 * math.random() + 0.1)

					for i, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.5 / (i / 2.5)), {
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
					angularVelocity2.Enabled = false
				end)
				task.spawn(function()
					local scale = clone7:GetScale()
					local v14 = scale * 1.25

					for i = scale * 100, v14 * 100, 5 do
						clone7:ScaleTo(i / 100)
						task.wait(0.005)
					end
				end)
			end

			task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			Util.Debris:AddItem(folder, 15)
			Util.Debris:AddItem(clone5, 6)

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			if v5 then
				Util.Sound:FadeOut(v5, 0.2)
			end

			TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(255, 255, 255),
					player,
					"LightningFruitVFXColor"
				),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			task.delay(2, function()
				colorCorrectionEffect:Destroy()
			end)

			for _, folder2 in pairs(v4) do
				for _, beam in pairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					TweenService:Create(beam, TweenInfo.new(0.15), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					local v9 = beam
					task.delay(0.15, function()
						v9:Destroy()
					end)
				end

				local v9 = folder2
				task.delay(1, function()
					v9:Destroy()
				end)
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.15), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					local v9 = effect
					task.delay(0.15, function()
						v9:Destroy()
					end)
				end
			end

			task.spawn(function()
				task.wait(1.5)

				for _, folder2 in pairs(clonesByClone) do
					for _, descendant in pairs(folder2:GetDescendants()) do
						if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
							descendant.Enabled = false
						elseif descendant:IsA("AngularVelocity") then
							descendant.Enabled = false
						end
					end

					local v9 = folder2
					task.delay(5, function()
						v9:Destroy()
					end)
				end

				for _, folder2 in pairs(clonesByClone2) do
					for _, descendant in pairs(folder2:GetDescendants()) do
						if descendant:IsA("Beam") then
							TweenService:Create(descendant, TweenInfo.new(0.25 + math.random() * 0.15), {
								Width0 = 0,
								Width1 = 0
							}):Play()
							local v9 = descendant
							task.delay(1, function()
								v9:Destroy()
							end)
						elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
							descendant.Enabled = false
						elseif descendant:IsA("AngularVelocity") then
							local v9 = descendant
							task.delay(1, function()
								v9.Enabled = false
							end)
						end
					end

					task.delay(5, function() end)
				end

				for _, emitter in pairs(clone4:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v9 = emitter
					task.spawn(function()
						local v10 = v9.Lifetime.Min * 0.75
						v9.Lifetime = NumberRange.new(v10, v10)
						v9.Enabled = false
					end)
				end
			end)
			return
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 30)
		local duration = data.Duration
		local startCFrame = data.StartCFrame
		local _WorldOrigin2 = workspace._WorldOrigin
		local player2 = data.Player
		local success, result = pcall(function()
			return player2.Name
		end)
		local folder2 = _WorldOrigin2:FindFirstChild((success and type(result) == "string" and (result or "NPC") or "NPC") .. "_ThunderNuke")

		if not folder2 then
			local v = 400

			for _, model in ipairs(workspace._WorldOrigin:GetChildren()) do
				if not (model:IsA("Model") and string.sub(model.Name, -12) == "_ThunderNuke") then
					continue
				end

				local magnitude = (model:GetPivot().Position - startCFrame.Position).Magnitude

				if not (magnitude < v) then
					continue
				end

				folder2 = model
				v = magnitude
			end
		end

		if folder2 then
			local v = 0.5 * SIZE_AND_HITBOX_MULTIPLIER + data.Absorbed / 6 * 0.5 * SIZE_AND_HITBOX_MULTIPLIER
			folder2.Name = "Destroying"
			Util.SetParentOverrideWithColor(folder2, folder, player, "LightningFruitVFXColor")
			folder2:ScaleTo(v)
			Util.Sound:Play("BF_Thunder_V_ThunderBomb_Release_01", folder2.PrimaryPart)
			local _ = data.TargetPosition
			local v2 = {}
			task.spawn(function()
				for _ = 1, 10 do
					for _ = 1, math.random(1, 3) do
						task.spawn(function()
							if v2 == nil then
								return
							end

							local clone = FX:WaitForChild("Lightning2").V.Part:Clone()
							Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
							clone.Attach1.Position = Vector3.new(0, 0, -folder2.PrimaryPart.Size.Z)
							clone.Anchored = false
							clone.Weld.Part1 = folder2.PrimaryPart
							clone.Weld.C1 = CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, folder2.PrimaryPart.Size.Z / 2)
							local shafiBolt1 = ShafiBolt1(player, clone.Attach0, clone.Attach1, 15, 3, folder)
							local curveSize = -folder2.PrimaryPart.Size.Z / 1.5
							local curveSize2 = folder2.PrimaryPart.Size.Z / 1.5
							shafiBolt1.CurveSize0 = curveSize
							shafiBolt1.CurveSize1 = curveSize2
							v2[shafiBolt1] = shafiBolt1
							task.wait(0.35 * math.random() + 0.25)

							if v2 == nil then
								return
							end

							if v2[shafiBolt1] ~= nil then
								v2[shafiBolt1] = nil
								shafiBolt1:Destroy()
							end
						end)
					end

					task.wait(0.1)
				end
			end)
			folder2:PivotTo(startCFrame)
			local cFrame = folder2.PrimaryPart.CFrame
			local v3 = 1000
			local ray = Ray.new(
				cFrame.Position,
				CFrame.new(cFrame.Position, cFrame * CFrame.new(0, 0, -v3).Position).LookVector * v3
			)
			local _, v4 = workspace:FindPartOnRayWithIgnoreList(
				ray,
				{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
			)
			local _ = (cFrame.Position - v4).Magnitude - folder2.PrimaryPart.Size.Z / 2
			local endCFrame = data.EndCFrame
			local speed = data.Speed
			TweenService:Create(
				folder2.PrimaryPart,
				TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = endCFrame
				}
			):Play()

			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("DESTROY") then
					emitter:Destroy()
				end
			end

			for _, descendant in pairs(folder2:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Material == Enum.Material.ForceField then
					descendant.WeldConstraint.Enabled = true
					descendant.AlignPosition.Enabled = false
					descendant.AngularVelocity.Enabled = false
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end
			end

			task.spawn(function()
				local v5 = tick() + speed
				local primaryPart = folder2.PrimaryPart
				local now = tick()
				local v6 = {}

				repeat
					if now - tick() <= 0 then
						now = tick() + 0.1
						local v7 = primaryPart.Position + Vector3.new(math.random(-150, 150), 0, math.random(-150, 150))
						local raycastResult = workspace:Raycast(
							v7 + createVector(0, 1, 0),
							createVector(-0, -450, -0),
							raycastParams
						)

						if raycastResult then
							for _ = 1, math.random(1, 2) do
								local v8 = raycastResult
								task.spawn(function()
									local clone = FX:WaitForChild("Lightning2").V.Part:Clone()
									clone.CFrame = CFrame.new(primaryPart.Position, v8.Position)
									Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
									clone.Anchored = false
									clone.Weld.Part1 = primaryPart
									clone.Massless = true
									clone.Weld.C1 = CFrame.new(
										math.random(-250, 250),
										math.random(-250, 250),
										math.random(-250, 250)
									) * CFrame.Angles(0, math.rad((math.random(-180, 180))), -1.5707963267948966)
									clone.Attach1:SetAttribute(
										"Pos",
										v8.Position + Vector3.new(math.random(-150, 150), 0, math.random(-150, 150))
									)
									local shafiBolt2 = ShafiBolt2(
										player,
										clone.Attach0,
										clone.Attach1,
										math.random(8, 23),
										math.random(5, 10),
										folder
									)
									v6[clone.Attach1] = shafiBolt2
									local curveSize = -150 + math.random(-50, 50)
									local curveSize2 = 150 + math.random(-50, 50)
									shafiBolt2.CurveSize0 = curveSize
									shafiBolt2.CurveSize1 = curveSize2
									task.spawn(function()
										for i = 1, 10 do
											shafiBolt2.CurveSize0 *= 1.1
											shafiBolt2.CurveSize1 *= 1.1
											task.wait(0.025)
										end
									end)
									task.wait(0.15 * math.random() + 0.15)

									if v6[clone.Attach1] == nil then
										return
									end

									v6[clone.Attach1] = nil
									shafiBolt2:Destroy()
								end)
							end
						end
					end

					for k, _ in pairs(v6) do
						local pos = k:GetAttribute("Pos")

						if k:GetAttribute("Dontmove") == nil then
							k.WorldPosition = CFrame.new(pos, primaryPart.Position) * createVector(0, 0, -5)
						else
							k.WorldPosition = pos
						end
					end

					task.wait()
				until v5 - tick() <= 0
			end)
			task.wait(speed)
			local clone = assets.Phase4.ExplosionStartModel:Clone()
			local primaryPart = clone.PrimaryPart
			primaryPart.CFrame = endCFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
			clone:ScaleTo(folder2:GetScale())
			Util.Sound:Play("BF_Thunder_V_ThunderBomb_Explode_V2_01", primaryPart.Position)

			for _, emitter in pairs(primaryPart:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v5 = emitter
				task.spawn(function()
					if v5:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v5:GetAttribute("EmitDelay"))
					end

					v5:Emit(v5:GetAttribute("EmitCount"))
				end)
			end

			for k, v5 in pairs(v2) do
				v5:Destroy()
				v2[k] = nil
			end

			v2 = nil

			if (workspace.CurrentCamera.CFrame.p - v4).Magnitude < 450 then
				Util.CameraShaker:ShakeOnce(12, 8, 0.4, 0.9)
				local Effect = require(game.ReplicatedStorage.Effect)
				Effect.new("ColorCorrection"):replicate({
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(148, 232, 255),
						player,
						"LightningFruitVFXColor"
					),
					Brightness = 0.3,
					Saturation = 0.1,
					Contrast = 0.2,
					FadeIn = 1.5,
					FadeOut = 0.27999999999999997,
					Lifetime = 0.01
				})
			end

			for _, descendant in pairs(folder2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					if descendant.Parent == folder2.PrimaryPart.Attachment then
						descendant.Enabled = false
					end
				elseif descendant:IsA("SelectionSphere") then
					if descendant.Name == "SelectionSphere2" then
						TweenService:Create(
							descendant,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0),
							{
								SurfaceTransparency = 0,
								Transparency = 0
							}
						):Play()
					else
						TweenService:Create(
							descendant,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0),
							{
								SurfaceTransparency = 1,
								Transparency = 1
							}
						):Play()
					end
				elseif descendant:IsA("BasePart") then
					if descendant.Material == Enum.Material.ForceField then
						descendant.Transparency = 1
					end

					TweenService:Create(
						descendant,
						TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(
								descendant.Size.X * 1.5,
								descendant.Size.Y * 1.5,
								descendant.Size.Z * 1.5
							)
						}
					):Play()
					local v5 = descendant
					task.delay(1.5, function()
						TweenService:Create(v5, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = createVector(0, 0, 0)
						}):Play()
						task.wait(0.35)
						TweenService:Create(v5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = createVector(700, 700, 700),
							Transparency = 1
						}):Play()
					end)
				end
			end

			task.spawn(function()
				task.wait(1.5)
				task.wait(0.35)
				folder2.SelectionSphere.Visible = false
				folder2.SelectionSphere1.Visible = false
				folder2.SelectionSphere2.SurfaceTransparency = 0.25
				TweenService:Create(
					folder2.SelectionSphere2,
					TweenInfo.new(0.115, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut, 0, false, 0),
					{
						SurfaceTransparency = 1,
						Transparency = 1
					}
				):Play()
			end)
			local raycastResult = workspace:Raycast(
				endCFrame.Position + createVector(0, 1, 0),
				createVector(-0, -300, -0),
				raycastParams
			)
			task.spawn(function()
				local Z = folder2.PrimaryPart.Size.Z
				task.spawn(function()
					local clones = {}
					local v5

					if raycastResult then
						v5 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01

						for _ = 1, 23 do
							local clone2 = assets.CraterRock:Clone()
							clone2.Parent = folder
							DestroyAfter(clone2, 7) -- equivalent call inferred; original call site unknown
							table.insert(clones, clone2)
						end

						local v6 = 360 / #clones
						local total = 0

						for _, v7 in pairs(clones) do
							total += v6
							v7.CFrame = v5 * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 0, Z / 1.7)
							local ray2 = Ray.new(v7.Position + createVector(0, 1, 0), createVector(-0, -71.42857, -0))
							local part, _ = workspace:FindPartOnRayWithIgnoreList(
								ray2,
								raycastParams.FilterDescendantsInstances
							)

							if part then
								local v8 = (v7.Position - raycastResult.Position).Magnitude / 200
								local v9 = math.random(3, 5)
								local v10 = v9 * math.random(120, 150) / 10
								local v11 = v9 * math.random(1, 80) / 10
								local v12 = v9 * math.random(1, 50) / 10
								v7.Size = Vector3.new(v10 * v8, v11 * v8, v12 * v8)
								v7.CFrame = CFrame.new(v7.Position, raycastResult.Position) * CFrame.new(
									0,
									math.random(-5, 5) / 3,
									math.random(-12.5, 12.5)
								)
								v7.CFrame = CFrame.new(
									v7.Position,
									v5.Position + Vector3.new(0, math.random(-55, -45) / 100 + v7.Size.Y / 500, 0)
								) * CFrame.Angles(math.rad(-math.random(10, 15) / 2 - 45 * v8 / 2), 0, 0) * CFrame.Angles(
									0,
									0,
									(math.rad((math.random(-5, 5))))
								)
								v7.Material = raycastResult.Instance.Material
								v7.Color = raycastResult.Instance.Color
							else
								v7:Destroy()
							end
						end

						task.spawn(function()
							task.wait(duration * 2)

							for _, v7 in pairs(clones) do
								v7:Destroy()
							end

							clones = nil
						end)
					else
						v5 = nil
					end

					local v6 = tick() + 1.5
					local now = tick()
					local now2 = tick()
					local now3 = tick()
					local lastTime = tick()
					local v7 = {}

					while true do
						local Z2 = folder2.PrimaryPart.Size.Z

						if raycastResult then
							if now2 - tick() <= 0 then
								now2 = tick() + 0.01

								for _ = 1, 2 do
									local v8 = Z2
									task.spawn(function()
										local clone2 = assets.Phase3.Rock:Clone()
										clone2.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
											0,
											math.rad((math.random(-180, 180))),
											0
										)
										Util.SetParentOverrideWithColor(
											clone2,
											folder,
											player,
											"LightningFruitVFXColor"
										)
										clone2.CFrame = clone2.CFrame * CFrame.new(0, 0, -v8 / 1.7) * CFrame.Angles(
											math.rad(90 + math.random(-50, -0)),
											0,
											0
										)
										clone2.Size = Vector3.new(
											math.random(3, 8) * 3,
											math.random(1, 3) * 3,
											math.random(3, 8) * 3
										)
										clone2.Anchored = false
										clone2.Material = raycastResult.Instance.Material
										clone2.Color = raycastResult.Instance.Color
										rocks:ApplyCollision(clone2, nil, true)
										clone2.AngularVelocity.AngularVelocity = Vector3.new(
											math.random(-10, 10),
											math.random(-10, 10),
											math.random(-10, 10)
										)
										clone2.AngularVelocity.Enabled = true
										local bodyVelocity = Instance.new("BodyVelocity")
										bodyVelocity.MaxForce = createVector(7000000, 7000000, 7000000)
										bodyVelocity.P = 5000
										Util.SetParentOverrideWithColor(
											bodyVelocity,
											clone2,
											player,
											"LightningFruitVFXColor"
										)
										local v9 = math.random(150, 300)
										task.delay(math.random(5, 10) / 50, function()
											bodyVelocity:Destroy()
										end)
										bodyVelocity.Velocity = clone2.CFrame.LookVector * v9
										task.delay(0.5, function()
											clone2.CanCollide = true
										end)
										task.wait(math.random() * 0.5)
										clone2.AngularVelocity.Enabled = false
										task.wait(0.35 + math.random() * 0.5)
										TweenService:Create(clone2, TweenInfo.new(0.5 + math.random() * 0.25), {
											Size = createVector(0, 0, 0)
										}):Play()
									end)
								end
							end

							task.spawn(function()
								local v8 = 360 / #clones
								local total = 0

								for _, v9 in pairs(clones) do
									total += v8
									CFrame.Angles(0, math.rad(total), 0)
									local v10 = (v9.Position - raycastResult.Position).Magnitude + 0.45
									local v11 = CFrame.new(raycastResult.Position, v9.Position) * CFrame.new(0, 0, -v10).Position
									v9.CFrame = CFrame.new(v11, v11 + v9.CFrame.LookVector)
									local v12 = (v9.Position - raycastResult.Position).Magnitude / 350
									local X = v9.Size.X
									local Y = v9.Size.Y
									local Z3 = v9.Size.Z
									v9.Size = Vector3.new(X + v12 / 3, Y + v12 / 3, Z3 + v12 / 3)
									v9.CFrame = CFrame.new(v9.Position, raycastResult.Position)
									v9.CFrame = CFrame.new(
										v9.Position,
										v5.Position + Vector3.new(0, math.random(-55, -50) / 70 + v9.Size.Y / 500, 0)
									) * CFrame.Angles(math.rad(-10 - 45 * v12 / 1.5), 0, 0)
								end
							end)
						end

						if now - tick() <= 0 then
							now = tick() + 0.15
							task.spawn(function()
								local clone2 = folder2["MainSphere" .. math.random(1, 4)]:Clone()
								clone2.CFrame = folder2.PrimaryPart.CFrame
								Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

								if areShiftedColorsEqual(
									player,
									"LightningFruitVFXColor",
									Color3.fromRGB(0, 0, 0),
									Color3.fromRGB(8, 0, 255),
									Color3.fromRGB(30, 0, 255)
								) then
									clone2.Mesh.VertexColor = createVector(0, 0, 0)
								end

								clone2.Transparency = 0
								local v9 = clone2.Mesh.Scale.X + (tick() - lastTime) / 1.5 * 2
								TweenService:Create(
									clone2.Mesh,
									TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Scale = Vector3.new(v9 * 1.8, v9 * 1.8, v9 * 1.8)
									}
								):Play()
								TweenService:Create(
									clone2,
									TweenInfo.new(0.275, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end)
						end

						if now3 - tick() <= 0 then
							now3 = tick() + 0.075
							task.spawn(function()
								task.spawn(function()
									local clone2 = FX:WaitForChild("Lightning2").V.Part1:Clone()
									Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")

									if areShiftedColorsEqual(
										player,
										"LightningFruitVFXColor",
										Color3.fromRGB(0, 0, 0),
										Color3.fromRGB(8, 0, 255),
										Color3.fromRGB(30, 0, 255)
									) then
										for _, emitter in ipairs(clone2:GetDescendants()) do
											if not emitter:IsA("ParticleEmitter") then
												continue
											end

											emitter.Brightness = 0
											emitter.LightEmission = 0
											emitter.LightInfluence = 0
										end
									end

									clone2.Attach1.Position = Vector3.new(
										0,
										0,
										-folder2.PrimaryPart.Size.Z + math.random(-100, 200)
									)
									clone2.CFrame = CFrame.new(folder2.PrimaryPart.Position) * CFrame.Angles(
										0,
										math.rad((math.random(-180, 180))),
										-1.5707963267948966
									) * CFrame.new(
										math.random(-100, 100),
										math.random(-100, 100),
										math.random(-100, 100)
									)
									local shafiBolt3 = ShafiBolt3(
										player,
										clone2.Attach0,
										clone2.Attach1,
										math.random(10, 15),
										5,
										folder
									)
									local v9 = 0.35 * math.random() + 0.4

									if raycastResult then
										TweenService:Create(clone2.Attach1, TweenInfo.new(v9), {
											WorldPosition = raycastResult.Position + Vector3.new(
												math.random(-100, 100) * 3,
												0,
												math.random(-100, 100) * 3
											)
										}):Play()
									else
										clone2.CFrame *= CFrame.Angles(
											math.rad((math.random(-180, 180))),
											math.rad((math.random(-180, 180))),
											(math.rad((math.random(-180, 180))))
										)
										local curveSize = math.random(-50, 50)
										local curveSize2 = math.random(-50, 50)
										shafiBolt3.CurveSize0 = curveSize
										shafiBolt3.CurveSize1 = curveSize2
										shafiBolt3.Thickness = 10
										clone2.Attach1.Position = Vector3.new(
											0,
											0,
											-(folder2.PrimaryPart.Size.Z + math.random(-50, 50))
										)
										v9 *= 0.75
										TweenService:Create(clone2.Attach1, TweenInfo.new(v9), {
											Position = clone2.Attach1.Position + Vector3.new(
												math.random(-100, 100) / 2,
												math.random(-100, 100) / 2,
												math.random(-100, 100) / 2
											)
										}):Play()

										for _, emitter in pairs(clone2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end
									end

									v7[clone2] = shafiBolt3
									task.wait(v9)

									if v7 == nil then
										return
									end

									if v7[clone2] ~= nil then
										v7[clone2] = nil
										shafiBolt3:Destroy()

										for _, emitter in pairs(clone2:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end
									end
								end)
							end)
						end

						task.wait(0.005 + math.random() * 0.005)

						if not (v6 - tick() <= 0) then
							continue
						end

						for k, v8 in pairs(v7) do
							local folder3 = k
							task.spawn(function()
								for i, emitter in pairs(folder3:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							v8:Destroy()
							v7[k] = nil
						end

						if clones then
							task.delay(0.35, function()
								for _ = 1, 3 do
									task.spawn(function()
										local v8 = 360 / #clones
										local total = 0

										for _, v9 in pairs(clones) do
											total += v8
											CFrame.Angles(0, math.rad(total), 0)
											local v10 = (v9.Position - raycastResult.Position).Magnitude + 25
											local v11 = CFrame.new(raycastResult.Position, v9.Position) * CFrame.new(
												0,
												0,
												-v10
											).Position
											v9.CFrame = CFrame.new(v11, v11 + v9.CFrame.LookVector)
											local v12 = (v9.Position - raycastResult.Position).Magnitude / 350
											local X = v9.Size.X
											local Y = v9.Size.Y
											local Z3 = v9.Size.Z
											v9.Size = Vector3.new(X + v12 / 2, Y + v12 / 2, Z3 + v12 / 2)
											v9.CFrame = CFrame.new(v9.Position, raycastResult.Position)
											v9.CFrame = CFrame.new(
												v9.Position,
												v5.Position + Vector3.new(
													0,
													math.random(-55, -50) / 70 + v9.Size.Y / 500,
													0
												)
											) * CFrame.Angles(math.rad(-10 - 45 * v12 / 1.5), 0, 0)
										end
									end)
									task.wait(0.01)
								end

								for _, v8 in pairs(clones) do
									TweenService:Create(
										v8,
										TweenInfo.new(
											0.25 + math.random() * 0.75,
											Enum.EasingStyle.Quart,
											Enum.EasingDirection.InOut,
											0,
											false,
											1.5
										),
										{
											Size = createVector(0, 0, 0),
											CFrame = v8.CFrame * CFrame.new(0, -50, 0)
										}
									):Play()
								end
							end)
						end

						task.spawn(function()
							for _ = 1, 5 do
								local clone2 = assets.Phase3.SpinTrailModel:Clone()
								clone2:PivotTo(endCFrame * CFrame.Angles(
									math.rad((math.random(-180, 180))),
									math.rad((math.random(-180, 180))),
									(math.rad((math.random(-180, 180))))
								))
								Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
								local v8 = math.random(5, 7) * 10
								local v9 = math.random(200, 300)
								clone2.PrimaryPart.Attach0.Position = Vector3.new(-v8, 0, -v9)
								clone2.PrimaryPart.Attach1.Position = Vector3.new(v8, 0, -v9)
								TweenService:Create(clone2.PrimaryPart, TweenInfo.new(0.175), {
									CFrame = endCFrame * CFrame.Angles(
										math.rad((math.random(-180, 180))),
										math.rad((math.random(-180, 180))),
										(math.rad((math.random(-180, 180))))
									)
								}):Play()
								TweenService:Create(clone2.PrimaryPart.Attach0, TweenInfo.new(0.175), {
									Position = Vector3.new(-v8 / 2, 0, 0)
								}):Play()
								TweenService:Create(clone2.PrimaryPart.Attach1, TweenInfo.new(0.175), {
									Position = Vector3.new(v8 / 2, 0, 0)
								}):Play()
							end
						end)
						break
					end
				end)
				local clone2 = assets.Phase4.ExpandModel:Clone()
				clone2:PivotTo(CFrame.new(endCFrame.Position))
				Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
				clone2:ScaleTo(folder2:GetScale())

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						v5:Emit(v5:GetAttribute("EmitCount"))
						v5.Enabled = true
						task.wait(1.5)
						v5.Enabled = false
					end)
				end

				task.spawn(function()
					local scale = clone2:GetScale()
					local v5 = scale * 1.65

					for i = scale * 100, v5 * 100, 5 do
						clone2:ScaleTo(i / 100)
						task.wait(0.05)
					end
				end)
				task.wait(1.5)
				local clone3 = assets.Phase4.ExplosionSetModel:Clone()
				clone3:ScaleTo(folder2:GetScale() + 0.7)
				local explosionStar = clone3.ExplosionStar
				explosionStar.CFrame = CFrame.new(endCFrame.Position)
				Util.SetParentOverrideWithColor(explosionStar, folder, player, "LightningFruitVFXColor")

				for _, emitter in pairs(explosionStar:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						if v5:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v5:GetAttribute("EmitDelay"))
						end

						v5:Emit(v5:GetAttribute("EmitCount"))
					end)
				end

				task.wait(0.35)
				task.spawn(function()
					local clone4 = folder2["MainSphere" .. math.random(1, 4)]:Clone()
					clone4.CFrame = folder2.PrimaryPart.CFrame
					Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
					clone4.Transparency = 0
					local v6 = clone4.Mesh.Scale.X * 2
					clone4.Mesh.Scale = Vector3.new(v6, v6, v6)
					TweenService:Create(
						clone4.Mesh,
						TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Scale = createVector(0, 0, 0)
						}
					):Play()
					TweenService:Create(
						clone4,
						TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				local explosionImpact = clone3.ExplosionImpact
				explosionImpact.CFrame = CFrame.new(endCFrame.Position)
				Util.SetParentOverrideWithColor(explosionImpact, folder, player, "LightningFruitVFXColor")

				if (workspace.CurrentCamera.CFrame.p - v4).Magnitude < 500 then
					Util.CameraShaker:ShakeOnce(16, 12, 1.4, 0.9)
					local Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("ColorCorrection"):replicate({
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(153, 241, 255),
							player,
							"LightningFruitVFXColor"
						),
						Brightness = 1,
						Saturation = 0.1,
						Contrast = 1,
						FadeIn = 0,
						FadeOut = 0,
						Lifetime = 0.1
					})
					local Effect2 = require(game.ReplicatedStorage.Effect)
					Effect2.new("ColorCorrection"):replicate({
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(153, 241, 255),
							player,
							"LightningFruitVFXColor"
						),
						Brightness = -1,
						Saturation = -1,
						Contrast = 2,
						FadeIn = 0,
						FadeOut = 0,
						Lifetime = 0.1
					})
				end

				for _, emitter in pairs(explosionImpact:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						if v5:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v5:GetAttribute("EmitDelay"))
						end

						v5:Emit(v5:GetAttribute("EmitCount"))
					end)
				end

				if raycastResult then
					local _ = CFrame.new(raycastResult.Position) * CFrame.new(0, 50, 0)
					local cFrame2 = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
					local v6 = {
						Radius = Z / 1.25 * 1,
						Size = 10,
						Duration = 1,
						Amount = 15,
						RockType = assets.CraterRock,
						Offset = 25
					}
					task.spawn(function()
						RockCrater(raycastResult, folder, v6, raycastParams) -- equivalent call inferred; original call site unknown
					end)
					local groundCrack = clone3.GroundCrack
					groundCrack.CFrame = cFrame2
					Util.SetParentOverrideWithColor(groundCrack, folder, player, "LightningFruitVFXColor")

					for _, emitter in pairs(groundCrack:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end

				task.wait(0.1)
				local explosion = clone3.Explosion
				explosion.CFrame = CFrame.new(endCFrame.Position)
				Util.SetParentOverrideWithColor(explosion, folder, player, "LightningFruitVFXColor")

				for _, emitter in pairs(explosion:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v5 = emitter
					task.spawn(function()
						if v5:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v5:GetAttribute("EmitDelay"))
						end

						v5:Emit(v5:GetAttribute("EmitCount"))
					end)
				end

				task.spawn(function()
					for _ = 1, 15 do
						task.spawn(function()
							local clone4 = assets.Phase4.TrailModel:Clone()
							local primaryPart2 = clone4.PrimaryPart
							primaryPart2.CFrame = endCFrame
							Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
							primaryPart2.CFrame *= CFrame.new(
								math.random(-250, 250),
								math.random(-100, 250),
								math.random(-250, 250)
							)
							clone4:ScaleTo(math.random(15, 35) / 10)

							for _, effect in pairs(primaryPart2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = true
								end
							end

							TrailCurve(
								primaryPart2,
								startCFrame,
								primaryPart2.Position,
								endCFrame.Position + Vector3.new(
									math.random(-250, 250),
									math.random(-250, 250),
									math.random(-250, 250)
								),
								CFrame.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200)),
								CFrame.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200)),
								math.random(20, 30),
								true
							)

							for _, effect in pairs(primaryPart2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end)
					end
				end)
				task.wait(1)
				folder2:Destroy()
				task.wait(5)
				clone3:Destroy()
			end)
		else
			local player3 = data.Player
			local success2, result2 = pcall(function()
				return player3.Name
			end)
			warn(
				"Lightning2.V: no charged orb to release for",
				(success2 and type(result2) == "string" and (result2 or "NPC") or "NPC") .. "_ThunderNuke"
			)
		end
	end
end