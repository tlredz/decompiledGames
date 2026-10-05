local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function neofy(data, p)
	local v = Vector3.new(data.R, data.G, data.B) * (p and 1 + (p - 1) / 10 or 1)
	return Color3.new(math.min(100, v.X), math.min(100, v.Y), (math.min(100, v.Z)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function viewerIsClose(p, p2, fn)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			fn()
		end
	end
end

local function GetCursedDualKatanaColorOwner(p, model)
	local player = p.Player or p.player

	if typeof(player) == "Instance" and player.Parent then
		return player
	end

	if model and model:IsA("Model") then
		local playerFromCharacter = Players:GetPlayerFromCharacter(model)

		if playerFromCharacter and playerFromCharacter.Parent then
			return playerFromCharacter
		end
	end

	return nil
end

local function RecolorCursedDualKatanaColor(instance, color)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(color, instance, "CursedDualKatanaFruitVFXColor")
	end

	return color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetParentWithCursedDualKatanaColor(p, parent, p2)
	if p2 then
		Util.SetParentOverrideWithColor(p, parent, p2, "CursedDualKatanaFruitVFXColor")
	else
		p.Parent = parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teslaFeeler(p, p2, p3, p4, p5, p6)
	task.spawn(function()
		local ray, v, v2 = Util.Ray(
			p.Position,
			p.lookVector.Unit * p3,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			Util.Sound:Play("ZapSaberHit", v, nil, 1.5 + math.random(-40, 40) / 100, 0.2)
			local clone = script.StaticImpact:Clone()
			Util.Debris:AddItem(clone, 1)

			if p6 then
				for _, v3 in pairs({ clone.Diamond, clone.Sparks }) do
					v3.Color = Util.Misc.SwapColorInKeypoints(v3, Color3.new(1, 0, 0), p6)
				end
			end

			clone.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
			SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, p5) -- equivalent call inferred; original call site unknown
			clone.Diamond:Emit(2)
			clone.Sparks:Emit(math.random(6, 10))
			local attachment = Instance.new("Attachment")
			attachment.Parent = clone
			attachment.Orientation = createVector(0, 0, 0)
			clone.Parent = _WorldOrigin
			local new = Util.LightningBolt.new
			local v8 = math.random(10, 14)
			local color = p6

			if not color then
				local v9 = p5
				color = Color3.new(1, 0.376471, 0.376471)

				if typeof(v9) == "Instance" and v9.Parent then
					color = WrapColor3Constructor(color, v9, "CursedDualKatanaFruitVFXColor")
				end
			end

			local v9 = new(p2, attachment, 0, 0, v8, color)
			local color2 = p6

			if not color2 then
				local v10 = p5
				color2 = Color3.new(1, 0.376471, 0.376471)

				if typeof(v10) == "Instance" and v10.Parent then
					color2 = WrapColor3Constructor(color2, v10, "CursedDualKatanaFruitVFXColor")
				end
			end

			v9.Color = color2

			for _, part in pairs(v9.Parts) do
				part.Color = v9.Color
			end

			v9.MinThicknessMultiplier = 0.5
			v9.MaxThicknessMultiplier = 2.5
			v9.AnimationSpeed = 6
			v9.PulseSpeed = 15
			v9.MaxAngleOffset = 0.24434609527920614

			if v9 then
				local lastTime = tick()
				local v10 = 0.016666666666666666

				while tick() - lastTime < 0.4 do
					local v11 = math.min(1, (tick() - lastTime) / 0.4)

					if v11 >= 1 or not (v9 and clone and p2) then
						break
					end

					v9.MinThicknessMultiplier = 0.5 + -0.48 * (v11 * v10 * 60)
					v9.MaxThicknessMultiplier = 2.5 + -2.45 * (v11 * v10 * 60)
					local v13 = v11 * v10 * 60
					v9.CurveSize0 = 0 + (p4 - 0) * v13
					v9.AddTransparency = 0 + 1 * (v11 * v10 * 60)
					v10 = RunService.RenderStepped:Wait()
				end

				if v9 then
					v9:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end
		end
	end)
end

local function pixieDustParticle(value, p, p2, player, p3)
	local v = value or 3
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, v + 1)
	part.CanCollide = false
	part.Anchored = true
	part.Size = createVector(2, 2, 5)
	part.Color = Color3.fromRGB(188, 155, 93)
	part.Material = Enum.Material.Neon
	part.CFrame = p3.CFrame
	part.Transparency = 1
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = part
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local clone = script.PixieTrail:Clone()
	clone.Parent = attachment
	local color = p3.Color

	if color then
		clone.Color = Util.Misc.SwapColorInKeypoints(clone, Color3.new(1, 0, 0), color)
	end

	for k, v2 in pairs(p3) do
		part[k] = v2
	end

	SetParentWithCursedDualKatanaColor(part, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	local lastTime = tick()
	task.spawn(function()
		local v3 = 0.016666666666666666
		local v4 = 1

		while tick() - lastTime < v do
			local _ = (tick() - lastTime) / v
			part.CFrame = part.CFrame * CFrame.new(0, 0, -p2 * v3 * 60) * CFrame.Angles(
				math.rad(p * math.cos(v4 / 5 + math.random(-15, 15) / 10)) * v3 * 60,
				0,
				0
			)
			clone:Emit(math.random(2, 3))
			v4 += 1
			v3 = RunService.RenderStepped:Wait()
		end

		if part then
			task.wait(1)

			if part then
				part:Destroy()
			end
		end
	end)
end

local function screenOverlayX(p, player, color)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function frustum(camera)
		local v = camera.ViewportSize.X / camera.ViewportSize.Y
		local v2 = math.tan((math.rad(camera.FieldOfView / 2))) * 10
		return { v2, v2 / v }
	end

	local function getCross(camera, p2, p3, worldModel, color2, minThicknessMultiplier, maxThicknessMultiplier, worldModel2, p4)
		local clone = script.Cross:Clone()
		Util.Debris:AddItem(clone, p)
		local topLeft = clone.TopLeft
		local topRight = clone.TopRight
		local bottomLeft = clone.BottomLeft
		local bottomRight = clone.BottomRight
		local center = clone.Center
		SetParentWithCursedDualKatanaColor(clone, worldModel, player) -- equivalent call inferred; original call site unknown
		local lightningBolt = Util.LightningBolt.new(topLeft.Attachment, bottomRight.Attachment, 0, 0, 20, color2)
		local lightningBolt2 = Util.LightningBolt.new(topRight.Attachment, bottomLeft.Attachment, 0, 0, 20, color2)
		lightningBolt.AnimationSpeed = 10
		lightningBolt.PulseSpeed = 25
		lightningBolt.Color = color2
		lightningBolt.FadeLength = 0.5
		lightningBolt.MinThicknessMultiplier = minThicknessMultiplier
		lightningBolt.MaxThicknessMultiplier = maxThicknessMultiplier
		lightningBolt.MaxAngleOffset = math.rad(p4)
		lightningBolt2.AnimationSpeed = 8
		lightningBolt2.PulseSpeed = 15
		lightningBolt2.Color = color2
		lightningBolt2.FadeLength = 0.5
		lightningBolt2.MinThicknessMultiplier = minThicknessMultiplier
		lightningBolt2.MaxThicknessMultiplier = maxThicknessMultiplier
		lightningBolt2.MaxAngleOffset = math.rad(p4)

		for _, part in pairs(lightningBolt.Parts) do
			part.Color = lightningBolt.Color
			part.Parent = worldModel2
		end

		for _, part in pairs(lightningBolt2.Parts) do
			part.Color = lightningBolt2.Color
			part.Parent = worldModel2
		end

		local v2 = 0.016666666666666666
		local total = 0
		local lastTime = tick()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if p <= tick() - lastTime then
				for _, v5 in pairs({ lightningBolt, lightningBolt2, clone }) do
					if v5 then
						v5:Destroy()
					end
				end

				renderSteppedConnection:Disconnect()
			end

			local v4 = v2 * 60
			total += v4 * 10
			center.CFrame = camera.CFrame * CFrame.new(0, 0, p2) * CFrame.Angles(0, 0, (math.rad(total)))
			topLeft.CFrame = center.CFrame * CFrame.new(p3, p3, 0)
			topRight.CFrame = center.CFrame * CFrame.new(-p3, p3, 0)
			bottomLeft.CFrame = center.CFrame * CFrame.new(p3, -p3, 0)
			bottomRight.CFrame = center.CFrame * CFrame.new(-p3, -p3, 0)

			if tick() - lastTime > 0.4 then
				for _, v6 in pairs({ lightningBolt, lightningBolt2 }) do
					local minThicknessMultiplier2 = v6.MinThicknessMultiplier
					local v7 = v4 * 0.18
					v6.MinThicknessMultiplier = minThicknessMultiplier2 + (0.01 - minThicknessMultiplier2) * v7
					local maxThicknessMultiplier2 = v6.MaxThicknessMultiplier
					local v8 = v4 * 0.18
					v6.MaxThicknessMultiplier = maxThicknessMultiplier2 + (0.02 - maxThicknessMultiplier2) * v8
				end
			end

			v2 = RunService.RenderStepped:Wait()
		end)
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.IgnoreGuiInset = true
	Util.Debris:AddItem(screenGui, p + 5)
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Parent = screenGui
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Size = UDim2.new(1, 0, 1, 0)
	local camera = Instance.new("Camera")
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local v = frustum(camera) -- equivalent call inferred; original call site unknown
	local v2 = math.max(v[1], v[2])
	getCross(camera, -6, v2, worldModel, Color3.fromRGB(0, 0, 0), 1.5, 2.5, worldModel, 25)

	if not color then
		color = Color3.fromRGB(255, 0, 4)

		if typeof(player) == "Instance" and player.Parent then
			color = WrapColor3Constructor(color, player, "CursedDualKatanaFruitVFXColor")
		end
	end

	getCross(camera, -5, v2, worldModel, color, 1, 1.5, worldModel, 15)
	getCross(camera, -4, v2, worldModel, Color3.fromRGB(0, 0, 0), 0.4, 0.8, worldModel, 10)
end

local function dashDart(startCFrame, player, color)
	local cframe = CFrame.Angles(1.5707963267948966, 0, 0)
	local clone = script.PierceCone:Clone()
	Util.Debris:AddItem(clone, 2)

	if color then
		for _, decal in pairs(clone:GetDescendants()) do
			if not decal:IsA("Decal") then
				continue
			end

			local v = Vector3.new(color.R, color.G, color.B) * 100.9
			decal.Color3 = Color3.new(math.min(100, v.X), math.min(100, v.Y), (math.min(100, v.Z)))
		end
	end

	clone:SetPrimaryPartCFrame(startCFrame * cframe)
	SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player) -- equivalent call inferred; original call site unknown

	for _, child in pairs(clone:GetChildren()) do
		local tween = TweenService:Create(
			child,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = child.CFrame * CFrame.new(0, -45, 0)
			}
		)
		local v2 = child
		tween.Completed:Connect(function()
			if v2 then
				v2:Destroy()
			end
		end)
		tween:Play()

		for _, child2 in pairs(child:GetChildren()) do
			if child2.Name == "Mesh" then
				local tween2 = TweenService:Create(
					child2,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Scale = Vector3.new(child2.Scale.X - 0.25, 5, child2.Scale.Z - 0.25)
					}
				)
				local v3 = child
				tween2.Completed:Connect(function()
					if v3 then
						v3:Destroy()
					end
				end)
				tween2:Play()
			elseif child2.Name == "Decal" then
				local tween2 = TweenService:Create(
					child2,
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1
					}
				)
				local v3 = child
				tween2.Completed:Connect(function()
					if v3 then
						v3:Destroy()
					end
				end)
				tween2:Play()
			end
		end
	end
end

local function slashBlast(userCF, player, color)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 2)
	part.Position = userCF.Position
	part.Transparency = 1
	part.Size = Vector3.new()
	part.CanCollide = false
	part.Anchored = true
	local clone = script.SlayerHit.Attachment.FlashStar:Clone()
	clone.Parent = part
	clone.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, RecolorCursedDualKatanaColor(player, Color3.new(1, 0.109804, 0.121569))),
		ColorSequenceKeypoint.new(0.5, RecolorCursedDualKatanaColor(player, Color3.new(1, 0.435294, 0.443137))),
		ColorSequenceKeypoint.new(1, RecolorCursedDualKatanaColor(player, Color3.new(0.564706, 0.0823529, 0.0901961)))
	})
	clone.ZOffset = -3
	clone.RotSpeed = NumberRange.new(1000, 1500)
	clone.Lifetime = NumberRange.new(0.3, 0.4)
	clone.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 40),
		NumberSequenceKeypoint.new(1, 0)
	})

	if color then
		clone.Color = Util.Misc.SwapColorInKeypoints(clone, Color3.new(1, 0, 0), color)
	end

	SetParentWithCursedDualKatanaColor(part, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	clone:Emit(5)
	local v2 = { "+", "-" }
	local clones = {}

	for i = 1, 75, 15 do
		local clone2 = script.Wind:Clone()
		Util.Debris:AddItem(clone2, 2)
		clone2.Name = v2[math.random(1, 2)]
		clone2.CFrame = userCF * CFrame.new(0, 0, -i) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			math.rad(0, 360),
			0
		)
		table.insert(clones, clone2)
		SetParentWithCursedDualKatanaColor(clone2, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	end

	task.spawn(function()
		local lastTime = tick()
		local clone2 = script.ImpactBurst:Clone()
		Util.Debris:AddItem(clone2, 1.3)

		if color then
			clone2.Color = color
		end

		clone2.CFrame = userCF
		SetParentWithCursedDualKatanaColor(clone2, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
		local clone3 = script.ImpactBurst:Clone()
		Util.Debris:AddItem(clone3, 1.3)

		if color then
			clone3.Color = color
		end

		clone3.Size = createVector(65, 65, 6)
		clone3.Transparency = 0.3
		clone3.CFrame = userCF
		SetParentWithCursedDualKatanaColor(clone3, _WorldOrigin, player) -- equivalent call inferred; original call site unknown

		while true do
			local v7 = tick() - lastTime

			if v7 >= 0.3 then
				break
			end

			local v8 = math.min(1, v7 / 0.3)
			local v9 = 15 + -14.9 * v8
			local quad = Util.Tween.ease.out.quad(0.3, 4.6, 130.4, v7)
			clone2.Size = Vector3.new(v9, v9, quad)
			clone2.CFrame = userCF * CFrame.new(0, 0, -clone2.Size.Z / 2)
			clone3.Size = Vector3.new(65 + -64.9 * v8, 65 + -64.9 * v8, quad + 25)
			clone3.CFrame = userCF * CFrame.new(0, 0, -clone2.Size.Z / 2)
			clone3.Transparency = 0.3 + 0.7 * v8
			RunService.RenderStepped:Wait()
		end

		if clone2 then
			clone2:Destroy()
		end

		if clone3 then
			clone3:Destroy()
		end
	end)
	task.spawn(function()
		local v3 = 25
		local v4 = 0.016666666666666666

		while #clones > 0 do
			for k, v5 in pairs(clones) do
				local _ = k * 5
				local v6 = 140 / k
				v5.CFrame = v5.CFrame * CFrame.new(0, -v3 / 10, 0) * CFrame.Angles(
					0,
					math.rad((v5.Name == "+" and 1 or -1) * v3 * (k * 0.5) * v4 * 60),
					0
				)
				local size = v5.Size
				local vector2 = Vector3.new(25 + v6, 4 + v6 / 2, 25 + v6)
				local v7 = v4 * 0.1 * 60
				v5.Size = size + (vector2 - size) * v7
				local transparency = v5.Transparency
				local v8 = v4 * 0.1 * 60
				v5.Transparency = transparency + (1 - transparency) * v8

				if not (v5.Transparency >= 0.999) then
					continue
				end

				table.remove(clones, k)
				v5:Destroy()
			end

			v3 *= 0.95
			v4 = RunService.RenderStepped:Wait()
		end

		clones = {}
	end)
end

local function electroSmoke(position, player, color)
	local clone = script.ElectroSmog:Clone()
	Util.Debris:AddItem(clone, 8)
	clone.Position = position
	SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	local attachment = clone.Attachment

	if color then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = Util.Misc.SwapColorInKeypoints(emitter, Color3.new(1, 0, 0), color)
			end
		end
	end

	task.spawn(function()
		attachment.AirWaves:Emit(math.random(4, 6))
		attachment.Smoke:Emit(math.random(8, 12))

		for _ = 1, 5 do
			attachment.Sparks:Emit(math.random(2, 5))
			task.wait(0.05)
		end

		for _ = 1, 5 do
			clone.Shocks:Emit(math.random(1, 3))
			task.wait(0.1)
		end

		task.wait(5)

		if clone then
			clone:Destroy()
		end
	end)
end

local function deriveColorFromBuso(value)
	local v = nil

	if typeof(value) == "Instance" then
		return value.Color
	end

	if typeof(value) == "Color3" then
		return value
	end

	return v
end

return function(player)
	local actionID = player.ActionID or 1
	local buso = player.Buso

	if actionID == 1 then
		local root = player.Root
		local humanoid = player.Humanoid
		local character = player.Character
		local holdValue = player.HoldValue

		if not (humanoid and root) or (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		local v = Util.Sound:Play("ElectricBuzz", root, nil, 0.8, 1)
		local tween = TweenService:Create(
			v,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				PlaybackSpeed = 0.5
			}
		)
		tween.Completed:Connect(function()
			if v then
				v:Destroy()
			end
		end)
		tween:Play()
		local v2 = Util.Sound:Play("AuraSound", root, nil, 0.8, 1)
		v2.Looped = true
		local clone = script.SlayerCharge:Clone()
		Util.Debris:AddItem(clone, 60)
		local color = nil

		if typeof(buso) == "Instance" then
			color = buso.Color
		elseif typeof(buso) == "Color3" then
			color = buso
		end

		local player2 = player.Player or player.player

		if typeof(player2) ~= "Instance" or not player2.Parent then
			if character and character:IsA("Model") then
				player2 = Players:GetPlayerFromCharacter(character)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		if color then
			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Color = Util.Misc.SwapColorInKeypoints(emitter, Color3.new(1, 0, 0), color)
				end
			end
		end

		clone.CFrame = root.CFrame
		SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown
		local attachment = clone.Attachment
		local diedConnection = nil

		if humanoid then
			diedConnection = humanoid.Died:Connect(function()
				diedConnection:Disconnect()
			end)
		end

		local lastTime = tick()

		local function running()
			return tick() - lastTime < 0.65 and diedConnection and player.HoldValue and player.HoldValue.Value == true
		end

		local lastTime2 = tick()
		local lastTime3 = tick()
		local lastTime4 = tick()
		local lastTime5 = tick()
		local lastTime6 = tick()

		while true do
			local v4

			if tick() - lastTime < 0.65 then
				v4 = diedConnection and player.HoldValue and player.HoldValue.Value == true
			else
				v4 = false
			end

			if v4 and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid then
				if clone then
					clone.CFrame = root.CFrame
				end

				if tick() - lastTime2 > 0.6 then
					attachment.ChargeRing:Emit(1)
					lastTime2 = tick()
				elseif tick() - lastTime3 > 0.05 then
					attachment.Embers:Emit(2)
					lastTime3 = tick()
				elseif tick() - lastTime4 > 0.02 then
					attachment.Rays:Emit(3)
					lastTime4 = tick()
				elseif tick() - lastTime5 > 0.1 then
					attachment.Blobs:Emit(2)
					lastTime5 = tick()
				elseif tick() - lastTime6 > 0.05 then
					attachment.Back:Emit(1)
					lastTime6 = tick()
				end

				RunService.RenderStepped:Wait()
			else
				if clone then
					task.spawn(function()
						task.wait(2)

						if clone then
							clone:Destroy()
						end
					end)
				end

				if v2 then
					v2:Destroy()
				end

				if diedConnection then
					diedConnection:Disconnect()
				end

				return
			end
		end
	elseif actionID == 2 then
		local startCFrame = player.StartCFrame

		if (startCFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local userRoot = player.UserRoot
		local color = nil

		if typeof(buso) == "Instance" then
			color = buso.Color
		elseif typeof(buso) == "Color3" then
			color = buso
		end

		local parent = userRoot and userRoot.Parent
		local player2 = player.Player or player.player

		if typeof(player2) ~= "Instance" or not player2.Parent then
			if parent and parent:IsA("Model") then
				player2 = Players:GetPlayerFromCharacter(parent)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		dashDart(startCFrame, player2, color)

		if userRoot then
			local lifetime = player.Lifetime
			local distance = player.Distance
			local timestamp = player.Timestamp
			local v = masterClock:GetTime() - timestamp
			local tween = TweenService:Create(
				userRoot,
				TweenInfo.new(lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = startCFrame * CFrame.new(0, 0, -distance)
				}
			)
			tween.Completed:Connect(function()
				if v < 0.15 and game.Players.LocalPlayer.Character and userRoot == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					Util.BodyMover.new(userRoot.Parent):Create("BodyGyro", {
						Duration = 0.15 - v,
						CFrame = startCFrame
					})
					Util.BodyMover.new(userRoot.Parent):Create("BodyVelocity", {
						Duration = 0.15 - v,
						Velocity = createVector(0, 0.01, 0)
					})
				end
			end)
			tween:Play()
			Util.Sound:Play("FlybySwoosh", userRoot, nil, 6, 1)
			Util.Sound:Play("Gear2", userRoot, nil, 1.5, 1)
			local attachment = Instance.new("Attachment")
			Util.Debris:AddItem(attachment, lifetime + 1)
			attachment.Position = createVector(0, 0, -5)
			attachment.Parent = userRoot
			local clone = script.Shunted:Clone()
			SetParentWithCursedDualKatanaColor(clone, attachment, player2) -- equivalent call inferred; original call site unknown
			local clone2 = script.Vortex:Clone()
			SetParentWithCursedDualKatanaColor(clone2, attachment, player2) -- equivalent call inferred; original call site unknown
			task.spawn(function()
				local lastTime = tick()
				local lastTime2 = tick()

				while tick() - lastTime < lifetime do
					if tick() - lastTime2 < 0.1 then
						clone:Emit(math.random(2, 3))
						clone2:Emit(1)
						lastTime2 = tick()
					end

					RunService.RenderStepped:Wait()
				end
			end)
			local clone3 = script.XDash:Clone()
			Util.Debris:AddItem(clone3, 2)
			clone3.CFrame = startCFrame
			SetParentWithCursedDualKatanaColor(clone3, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown
			local v3 = {
				DarkSlashLine = 1,
				MiniSlashLine = 14,
				MiniSlashRotated = 8,
				SlashLine = 1
			}

			if color then
				local children = clone3.Attachment:GetChildren()
				table.insert(children, clone)
				table.insert(children, clone2)

				for _, v4 in pairs(children) do
					v4.Color = Util.Misc.SwapColorInKeypoints(v4, Color3.new(1, 0, 0), color)
				end
			end

			for _, child in pairs(clone3.Attachment:GetChildren()) do
				if v3[child.Name] then
					child:Emit(v3[child.Name])
				end
			end
		end
	elseif actionID == 3 then
		local userCF = player.UserCF

		if (userCF.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local user = player.User
		local victim = player.Victim
		local _ = player.VictimCF
		local timestamp = player.Timestamp
		local stunDuration = player.StunDuration
		local humanoidRootPart = victim:FindFirstChild("HumanoidRootPart")
		local v = masterClock:GetTime() - timestamp
		local humanoidRootPart2 = user:FindFirstChild("HumanoidRootPart")
		math.max(0.6 - v, 0.1)
		local color = nil

		if typeof(buso) == "Instance" then
			color = buso.Color
		elseif typeof(buso) == "Color3" then
			color = buso
		end

		local player2 = player.Player or player.player

		if typeof(player2) ~= "Instance" or not player2.Parent then
			if user and user:IsA("Model") then
				player2 = Players:GetPlayerFromCharacter(user)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		if user and humanoidRootPart2 and humanoidRootPart then
			Util.Sound:Play("ImbuedSwordSing", humanoidRootPart2, nil, 1.5, 4)
			Util.Sound:Play("SmallBladeStab", humanoidRootPart2, nil, 0.5, 3)

			local function fn()
				Util.CameraShaker:ShakeOnce(10, 15, 0.25, 1)
				local clone = script.CDKSlayerTint:Clone()
				Util.Debris:AddItem(clone, 2)
				clone.Parent = Lighting
				task.delay(0.2, function()
					if clone then
						clone:Destroy()
					end
				end)
			end

			viewerIsClose(userCF.p, 100, fn) -- equivalent call inferred; original call site unknown
			local clone = script.XSlash:Clone()
			Util.Debris:AddItem(clone, 2)
			clone.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position)
			SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown
			local v3 = {
				DarkSlashLine = 1,
				MiniSlashLine = 8,
				SlashLine = 1
			}

			if color then
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Color = Util.Misc.SwapColorInKeypoints(emitter, Color3.new(1, 0, 0), color)
					end
				end
			end

			for _, child in pairs(clone.Right:GetChildren()) do
				if v3[child.Name] then
					child:Emit(v3[child.Name])
				end
			end

			for _, child in pairs(clone.Left:GetChildren()) do
				if v3[child.Name] then
					child:Emit(v3[child.Name])
				end
			end

			task.spawn(function()
				for _ = 1, 12 do
					clone.Shocks:Emit(2)
					task.wait(0.1)
				end
			end)
			task.spawn(function()
				task.spawn(function()
					local clone2 = script.SlayerHit:Clone()
					Util.Debris:AddItem(clone2, 2)

					if color then
						for _, child in pairs(clone2.Attachment:GetChildren()) do
							child.Color = Util.Misc.SwapColorInKeypoints(child, Color3.new(1, 0, 0), color)
						end
					end

					clone2.CFrame = CFrame.new(humanoidRootPart.Position)
					SetParentWithCursedDualKatanaColor(clone2, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown
					local attachment = clone2.Attachment
					attachment.FlashStar:Emit(2)
					attachment.FlashStarRays:Emit(1)
					task.wait(0.3)
					attachment.RedShine:Emit(1)
					attachment.BlackShine:Emit(1)
					attachment.Fog:Emit(2)
					attachment.NeonEmbers:Emit(math.random(40, 55))
				end)
				task.wait((math.max(0.01, stunDuration - v)))
				task.spawn(function()
					for _ = 1, 10 do
						pixieDustParticle(
							math.random(8, 10) / 10,
							math.random(4, 7),
							math.random(15, 28) / 10,
							player2,
							{
								CFrame = userCF * CFrame.Angles(
									math.rad((math.random(-10, 10))),
									math.rad((math.random(-10, 10))),
									(math.rad((math.random(-180, 180))))
								),
								Color = color
							}
						)
					end

					local v4 = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)

					for _ = 1, 12 do
						local v5 = { math.random(-55, -25), math.random(25, 55) }
						local v6 = { math.random(-55, -25), math.random(25, 55) }
						local v7 = { math.random(-55, -25), math.random(25, 55) }
						pixieDustParticle(
							math.random(7, 8) / 10,
							math.random(15, 20),
							math.random(9, 14) / 10,
							player2,
							{
								CFrame = v4 * CFrame.Angles(
									math.rad(v5[math.random(1, #v5)]),
									math.rad(v6[math.random(1, #v6)]),
									(math.rad(v7[math.random(1, #v7)]))
								),
								Color = color
							}
						)
						task.wait(0.02)
					end
				end)

				local function fn2()
					Util.CameraShaker:ShakeOnce(15, 25, 0.55, 1.5)
					local clone2 = script.CDKSlayerTint:Clone()
					Util.Debris:AddItem(clone2, 2)
					local clone3 = script.CDKSlayerBloom:Clone()
					Util.Debris:AddItem(clone3, 2)
					clone2.Contrast = 0
					clone2.Saturation = 0
					clone2.Brightness = 0
					clone3.Intensity = 2
					clone2.Parent = Lighting
					clone3.Parent = Lighting
					local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0)
					local tween = TweenService:Create(clone2, tweenInfo, {
						Brightness = -0.3,
						Contrast = 0.6,
						Saturation = -0.6
					})
					tween.Completed:Connect(function()
						if clone2 then
							clone2:Destroy()
						end
					end)
					local tween2 = TweenService:Create(clone3, tweenInfo, {
						Intensity = 0,
						Size = 0,
						Threshold = 0
					})
					tween2.Completed:Connect(function()
						if clone3 then
							clone3:Destroy()
						end
					end)
					tween:Play()
					tween2:Play()
				end

				viewerIsClose(userCF.p, 110, fn2) -- equivalent call inferred; original call site unknown
				electroSmoke(userCF.Position + createVector(0, 5, 0), player2, color)
				local parent = Util.Sound:Play("Buddha_slam", humanoidRootPart, nil, 1, 1)
				parent.RollOffMaxDistance = 5000
				local chorusSoundEffect = Instance.new("ChorusSoundEffect")
				chorusSoundEffect.Parent = parent
				slashBlast(userCF, player2, color)
			end)

			if humanoidRootPart then
				local attachment = Instance.new("Attachment")
				Util.Debris:AddItem(attachment, 3)
				attachment.Parent = humanoidRootPart
				task.spawn(function()
					for _ = 1, 6 do
						teslaFeeler(
							CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
								math.rad((math.random(-30, 30))),
								math.rad((math.random(-70, -20))),
								(math.rad((math.random(-30, 30))))
							),
							attachment,
							math.random(65, 85),
							math.random(25, 85),
							player2,
							color
						) -- equivalent call inferred; original call site unknown
						task.wait(0.2)
					end
				end)
			end

			local character = game.Players.LocalPlayer.Character

			if character then
				local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart3 and humanoidRootPart3 == humanoidRootPart then
					Util.Sound:Play("SwordCrossCrackle", workspace, nil, 0.75, 0.4)
					task.spawn(function()
						screenOverlayX(0.6, player2, color)
					end)
				end
			end
		end
	elseif actionID == 4 then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local color = nil

		if typeof(buso) == "Instance" then
			color = buso.Color
		elseif typeof(buso) == "Color3" then
			color = buso
		end

		local player2 = player.Player or player.player

		if typeof(player2) ~= "Instance" or not player2.Parent then
			if character and character:IsA("Model") then
				player2 = Players:GetPlayerFromCharacter(character)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			Util.Sound:Play("PrimeChime", humanoidRootPart.Position, nil, 1.3, 1.5)
			local clone = script.Sparkle:Clone()
			Util.Debris:AddItem(clone, 1)

			if color then
				clone.Color = Util.Misc.SwapColorInKeypoints(clone, Color3.new(1, 0, 0), color)
			end

			SetParentWithCursedDualKatanaColor(clone, humanoidRootPart, player2) -- equivalent call inferred; original call site unknown
			clone:Emit(1)
		end
	end
end