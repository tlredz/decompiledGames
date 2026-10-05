local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
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

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function spinAnimation(items, p)
	local v = {}
	local total = 0
	return (RunService.Stepped:connect(function()
		for _, item in pairs(items) do
			if not (item ~= nil and item.Parent ~= nil) then
				continue
			end

			v[item] = cflerp(
				not v[item] and item.Transform or v[item],
				CFrame.new(0, -0.5, 0) * CFrame.Angles(0, math.rad(-total), -0.2617993877991494),
				p
			)
			item.Transform = v[item]
		end

		total += 35

		if total >= 359 then
			total = 0
		end
	end))
end

local function getSpinJoints(folder, humanoidRootPart)
	local descendants = {}

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("Motor6D") then
			if descendant.Name == "Root" or descendant.Name == "RootJoint" or descendant.Part0 == humanoidRootPart or descendant.Part1 == humanoidRootPart then
				table.insert(descendants, descendant)
			end
		elseif descendant:IsA("AnimationConstraint") then
			local attachment0 = descendant.Attachment0
			local attachment1 = descendant.Attachment1

			if descendant.Name == "Root" or descendant.Name == "RootJoint" or attachment0 and attachment0.Parent == humanoidRootPart or attachment1 and attachment1.Parent == humanoidRootPart then
				table.insert(descendants, descendant)
			end
		end
	end

	return descendants
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

local function RecolorCursedDualKatanaColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "CursedDualKatanaFruitVFXColor")
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetParentWithCursedDualKatanaColor(clone, parent, p)
	if p then
		Util.SetParentOverrideWithColor(clone, parent, p, "CursedDualKatanaFruitVFXColor")
	else
		clone.Parent = parent
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teslaFeeler(p, attachment, p2, p3, instance, p4)
	task.spawn(function()
		local ray, v, v2 = Util.Ray(
			p.Position,
			p.lookVector.Unit * p2,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			Util.Sound:Play("ZapSaberHit", v, nil, 1.5 + math.random(-40, 40) / 100, 0.2)
			local clone = script.StaticImpact:Clone()
			Util.Debris:AddItem(clone, 1)

			if p4 then
				for _, v3 in pairs({ clone.Diamond, clone.Sparks }) do
					v3.Color = Util.Misc.SwapColorInKeypoints(v3, Color3.new(1, 0, 0), p4, 1)
				end
			end

			clone.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
			SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, instance) -- equivalent call inferred; original call site unknown
			clone.Diamond:Emit(2)
			clone.Sparks:Emit(math.random(6, 10))
			local attachment2 = Instance.new("Attachment")
			attachment2.Parent = clone
			attachment2.Orientation = createVector(0, 0, 0)
			clone.Parent = _WorldOrigin
			local new = Util.LightningBolt.new
			local v8 = math.random(10, 14)
			local color = p4

			if not color then
				local v9 = instance
				color = Color3.new(1, 0.376471, 0.376471)

				if typeof(v9) == "Instance" and v9.Parent then
					color = WrapColor3Constructor(color, v9, "CursedDualKatanaFruitVFXColor")
				end
			end

			local v9 = new(attachment, attachment2, 0, 0, v8, color)
			local color2 = p4

			if not color2 then
				local v10 = instance
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

					if v11 >= 1 or not (v9 and clone and attachment) then
						break
					end

					v9.MinThicknessMultiplier = 0.5 + -0.48 * (v11 * v10 * 60)
					v9.MaxThicknessMultiplier = 2.5 + -2.45 * (v11 * v10 * 60)
					local v13 = v11 * v10 * 60
					v9.CurveSize0 = 0 + (p3 - 0) * v13
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

local function tornadoExplosion(position, instance, p)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 120 then
			Util.CameraShaker:ShakeOnce(12, 20, 0.25, 1.8)
		end
	end

	Util.Sound:Play("FutureWeaponExplosion", position, nil, 1.2 + math.random(-20, 20) / 100, 1.5)
	local clone = script.TornadoExplosion:Clone()
	Util.Debris:AddItem(clone, 8)

	if p then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = Util.Misc.SwapColorInKeypoints(emitter, Color3.new(1, 0, 0), p, 1)
			end
		end
	end

	clone.Position = position
	SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, instance) -- equivalent call inferred; original call site unknown
	local attachment = clone.Attachment
	task.spawn(function()
		for _ = 1, 15 do
			attachment.InRays:Emit(math.random(3, 5))
			attachment.Lightning_Squash:Emit(math.random(1, 2))
			task.wait(0.01)
		end

		task.wait(0.1)
		attachment.AirWaves:Emit(math.random(4, 6))
		attachment.Burst:Emit(2)
		attachment.HalfRing:Emit(1)
		attachment.Smoke:Emit(math.random(8, 12))
		attachment.Lightning_Squash:Emit(math.random(2, 3))

		for _ = 1, 5 do
			attachment.Sparks:Emit(math.random(2, 5))
			task.wait(0.05)
		end

		for _ = 1, 10 do
			clone.Shocks:Emit(math.random(1, 3))
			task.wait(0.1)
		end

		task.wait(2)

		if clone then
			clone:Destroy()
		end
	end)
end

local function tornadoProjectile(projectileCFrame, positionObject, timestamp, life, distance, player, color)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, life + 5)
	part.Anchored = true
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Position = projectileCFrame.Position
	part.Parent = _WorldOrigin
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	attachment.Orientation = createVector(0, 0, 90)
	Util.Sound:Play("SparkExplosion", part, nil, 0.8, 3)
	local v = Util.Sound:Play("ZapWeaponBuzz", part, nil, 0.8, 1)
	local clone = script.ParticleBox:Clone()
	Util.Debris:AddItem(clone, life + 5)

	if color then
		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Color = Util.Misc.SwapColorInKeypoints(effect, Color3.new(1, 0, 0), color, 1)
			end
		end
	end

	clone.CFrame = CFrame.new(part.Position + createVector(0, 12.1, 0))
	SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	local pointLight = Instance.new("PointLight")
	local color2

	if color then
		color2 = color
	else
		color2 = Color3.fromRGB(255, 0, 4)

		if typeof(player) == "Instance" and player.Parent then
			color2 = WrapColor3Constructor(color2, player, "CursedDualKatanaFruitVFXColor")
		end
	end

	pointLight.Color = color2
	pointLight.Range = 48
	pointLight.Shadows = true
	pointLight.Parent = clone
	local clone2 = script.FaintWind:Clone()
	Util.Debris:AddItem(clone2, life + 5)
	clone2.CFrame = CFrame.new(clone.Position)
	SetParentWithCursedDualKatanaColor(clone2, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	local v4 = masterClock:GetTime() - timestamp
	local _ = projectileCFrame.lookVector
	local value = false
	local changedConnection = positionObject.Changed:Connect(function()
		value = positionObject.Value or nil
	end)
	local v5 = {
		rotatables = {},
		t = tick(),
		particles = {
			Updraft = { tick() - 1, 0.05, 6 },
			VerticalLightning = { tick() - 1, 0.03, 1 },
			RedWind = { tick() - 1, 0.1, 1 },
			GroundAura = { tick() - 1, 0.03, 1 },
			Crescents = { tick() - 1, 0.05, 1 },
			BlackWind = { tick() - 1, 0.1, 1 },
			Back = { tick() - 1, 0.05, 1 }
		},
		lastShockParticle = tick() - 1,
		lastTesla = tick() - 1,
		lastWind = tick() - 1,
		life = life,
		currentCFrame = projectileCFrame,
		lastCF = projectileCFrame,
		lastDist = 1,
		dt = 0.016666666666666666,
		hit = nil,
		pos = nil,
		norm = nil
	}

	while tick() - v5.t + v4 < v5.life do
		local _ = (tick() - v5.t + v4) / v5.life
		local v6 = (tick() - v5.t + v4) / 100 / (v5.life / 100)
		v5.lastCF = v5.currentCFrame
		v5.currentCFrame = projectileCFrame:Lerp(projectileCFrame * CFrame.new(0, 0, -distance), v6)
		part.Position = v5.currentCFrame.Position
		clone.CFrame = CFrame.new(part.Position + createVector(0, 12.1, 0))
		clone2.CFrame = CFrame.new(part.Position + createVector(0, 12.1, 0)) * (clone2.CFrame - clone2.Position) * CFrame.Angles(
			0,
			math.rad(20 * v5.dt * 60),
			0
		)

		if tick() - v5.lastWind > 0.2 then
			local clone3 = script.Wind:Clone()
			Util.Debris:AddItem(clone3, 2)
			clone3.CFrame = CFrame.new(part.Position + createVector(0, 2, 0)) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				0
			)
			SetParentWithCursedDualKatanaColor(clone3, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
			local color3

			if color then
				color3 = color
			else
				color3 = Color3.fromRGB(255, 89, 89)

				if typeof(player) == "Instance" and player.Parent then
					color3 = WrapColor3Constructor(color3, player, "CursedDualKatanaFruitVFXColor")
				end
			end

			clone3.Color = color3
			local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
			local color4

			if color then
				color4 = color
			else
				color4 = Color3.fromRGB(255, 82, 82)

				if typeof(player) == "Instance" and player.Parent then
					color4 = WrapColor3Constructor(color4, player, "CursedDualKatanaFruitVFXColor")
				end
			end

			local v10 = TweenService:Create(clone3, tweenInfo, {
				Transparency = 1,
				Size = createVector(95, 10, 95),
				Color = color4
			})
			v10.Completed:Connect(function()
				if clone3 then
					clone3:Destroy()
				end
			end)
			v10:Play()
			table.insert(v5.rotatables, { clone3, "RedWind", 0 })
			local clone4 = script.LongSwirl:Clone()
			Util.Debris:AddItem(clone4, 2)
			clone4.CFrame = CFrame.new(part.Position + createVector(0, 2, 0)) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				0
			)
			clone4.Parent = _WorldOrigin
			clone4.Transparency = 0.2
			clone4.Color = Color3.fromRGB(0, 0, 0)
			local tween = TweenService:Create(
				clone4,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(50, 25, 50)
				}
			)
			tween.Completed:Connect(function()
				if clone4 then
					clone4:Destroy()
				end
			end)
			tween:Play()
			table.insert(v5.rotatables, { clone4, "BlackWind", 0 })
			local position = part.Position
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 100 then
					Util.CameraShaker:ShakeOnce(2, 10, 0.25, 0.35)
				end
			end

			v5.lastWind = tick()
		end

		if tick() - v5.lastTesla > 0.1 then
			teslaFeeler(
				CFrame.new(part.Position) * CFrame.Angles(
					math.rad((math.random(-30, 30))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(-30, 30))))
				),
				attachment,
				math.random(65, 85),
				math.random(25, 85),
				player,
				color
			) -- equivalent call inferred; original call site unknown
			v5.lastTesla = tick()
		end

		for _, child in pairs(clone.BottomAttachment:GetChildren()) do
			local nows = v5.particles[child.Name]

			if not (nows and tick() - nows[1] > nows[2]) then
				continue
			end

			child:Emit(nows[3])
			nows[1] = tick()
		end

		for _, child in pairs(clone.RotatedAttachment:GetChildren()) do
			local nows = v5.particles[child.Name]

			if not (nows and tick() - nows[1] > nows[2]) then
				continue
			end

			child:Emit(nows[3])
			nows[1] = tick()
		end

		if tick() - v5.lastShockParticle > 0.05 then
			clone.Shocks:Emit(2)
			v5.lastShockParticle = tick()
		end

		v5.lastDist = (v5.lastCF.p - v5.currentCFrame.p).Magnitude
		local ray, pos, norm = Util.Ray(
			v5.lastCF.p,
			v5.lastCF.lookVector.Unit * v5.lastDist,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		v5.hit = ray
		v5.pos = pos
		v5.norm = norm

		if value then
			if part and part:FindFirstChild("Root") then
				part.Root.Position = positionObject.Value
			end

			break
		else
			if v5.hit then
				break
			end

			if #v5.rotatables > 0 then
				for k, rotatable in pairs(v5.rotatables) do
					if rotatable[1] == nil or rotatable[1].Parent == nil then
						table.remove(v5.rotatables, k)
					elseif rotatable[2] == "RedWind" then
						rotatable[1].Position = part.Position + Vector3.new(0, rotatable[3], 0)
						local v9 = rotatable[1].CFrame - rotatable[1].CFrame.Position
						rotatable[1].CFrame = rotatable[1].CFrame * v9 * CFrame.Angles(0, math.rad(40 * v5.dt * 60), 0)
						rotatable[3] += 0.5
					elseif rotatable[2] == "BlackWind" then
						rotatable[1].Position = part.Position + Vector3.new(0, rotatable[3], 0)
						local v9 = rotatable[1].CFrame - rotatable[1].CFrame.Position
						rotatable[1].CFrame = CFrame.new(part.Position) * CFrame.new(0, rotatable[3], 0) * v9 * CFrame.Angles(
							0,
							math.rad(-25 * v5.dt * 60),
							0
						)
						rotatable[3] += 0.5
					end
				end
			end

			v5.dt = RunService.RenderStepped:Wait()
		end
	end

	if #v5.rotatables > 0 then
		for _, rotatable in pairs(v5.rotatables) do
			if rotatable[1] then
				rotatable[1]:Destroy()
			end
		end
	end

	v5.rotatables = nil

	if v then
		v:Destroy()
	end

	tornadoExplosion(v5.lastCF.Position + createVector(0, 24, 0), player, color)

	if clone2 then
		clone2:Destroy()
	end

	task.spawn(function()
		task.wait(0.5)

		if pointLight then
			local tween = TweenService:Create(
				pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Brightness = 0,
					Range = 1
				}
			)
			tween.Completed:Connect(function()
				if pointLight then
					pointLight:Destroy()
				end
			end)
			tween:Play()
		end

		if clone then
			clone:Destroy()
		end
	end)

	if changedConnection then
		changedConnection:Disconnect()
	end
end

local function tornadoAura(humanoidRootPart, holdValue, maxHoldTime, timestamp, minHoldTime, player, color)
	local position2 = humanoidRootPart.Position - createVector(0, 2, 0)
	local currentCFrame = CFrame.new(position2) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, maxHoldTime + 5)
	part.Anchored = true
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Position = position2
	part.Parent = _WorldOrigin
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	attachment.Orientation = createVector(0, 0, 90)
	local v3 = Util.Sound:Play("ZapWeaponBuzz", part, nil, 0.8, 1.2)
	local clone = script.ParticleBox:Clone()
	Util.Debris:AddItem(clone, maxHoldTime + 5)

	if color then
		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Color = Util.Misc.SwapColorInKeypoints(effect, Color3.new(1, 0, 0), color, 1)
			end
		end
	end

	clone.CFrame = CFrame.new(part.Position + createVector(0, 12.1, 0))
	SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	local pointLight = Instance.new("PointLight")
	local color2

	if color then
		color2 = color
	else
		color2 = Color3.fromRGB(255, 0, 4)

		if typeof(player) == "Instance" and player.Parent then
			color2 = WrapColor3Constructor(color2, player, "CursedDualKatanaFruitVFXColor")
		end
	end

	pointLight.Color = color2
	pointLight.Range = 48
	pointLight.Shadows = true
	pointLight.Parent = clone
	local clone2 = script.FaintWind:Clone()
	Util.Debris:AddItem(clone2, maxHoldTime + 5)
	clone2.CFrame = CFrame.new(clone.Position)
	SetParentWithCursedDualKatanaColor(clone2, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
	local v6 = masterClock:GetTime() - timestamp
	local v7 = math.max(0.01, minHoldTime - v6)
	local v8 = {
		rotatables = {},
		t = tick(),
		particles = {
			Updraft = { tick() - 1, 0.05, 6 },
			VerticalLightning = { tick() - 1, 0.03, 1 },
			RedWind = { tick() - 1, 0.1, 1 },
			GroundAura = { tick() - 1, 0.03, 1 },
			Crescents = { tick() - 1, 0.05, 1 },
			BlackWind = { tick() - 1, 0.1, 1 },
			Back = { tick() - 1, 0.05, 1 }
		},
		lastShockParticle = tick() - 1,
		lastTesla = tick() - 1,
		lastWind = tick() - 1,
		life = maxHoldTime,
		currentCFrame = currentCFrame,
		dt = 0.016666666666666666,
		hit = nil,
		pos = nil,
		norm = nil
	}

	while tick() - v8.t + v6 < v8.life do
		local _ = (tick() - v8.t + v6) / v8.life
		local _ = (tick() - v8.t + v6) / 100 / (v8.life / 100)

		if not humanoidRootPart then
			break
		end

		local _ = humanoidRootPart.Position - createVector(0, 2, 0)

		if (not holdValue or holdValue.Value == false) and not (tick() - v8.t + v6 < v7) then
			break
		end

		v8.currentCFrame = currentCFrame
		part.Position = v8.currentCFrame.Position
		clone.CFrame = CFrame.new(part.Position + createVector(0, 12.1, 0))
		clone2.CFrame = CFrame.new(part.Position + createVector(0, 12.1, 0)) * (clone2.CFrame - clone2.Position) * CFrame.Angles(
			0,
			math.rad(20 * v8.dt * 60),
			0
		)

		if tick() - v8.lastWind > 0.2 then
			local clone3 = script.Wind:Clone()
			Util.Debris:AddItem(clone3, 2)
			clone3.CFrame = CFrame.new(part.Position + createVector(0, 2, 0)) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				0
			)
			SetParentWithCursedDualKatanaColor(clone3, _WorldOrigin, player) -- equivalent call inferred; original call site unknown
			local color3

			if color then
				color3 = color
			else
				color3 = Color3.fromRGB(255, 89, 89)

				if typeof(player) == "Instance" and player.Parent then
					color3 = WrapColor3Constructor(color3, player, "CursedDualKatanaFruitVFXColor")
				end
			end

			clone3.Color = color3
			local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
			local color4

			if color then
				color4 = color
			else
				color4 = Color3.fromRGB(255, 82, 82)

				if typeof(player) == "Instance" and player.Parent then
					color4 = WrapColor3Constructor(color4, player, "CursedDualKatanaFruitVFXColor")
				end
			end

			local v12 = TweenService:Create(clone3, tweenInfo, {
				Transparency = 1,
				Size = createVector(95, 10, 95),
				Color = color4
			})
			v12.Completed:Connect(function()
				if clone3 then
					clone3:Destroy()
				end
			end)
			v12:Play()
			table.insert(v8.rotatables, { clone3, "RedWind", 0 })
			local clone4 = script.LongSwirl:Clone()
			Util.Debris:AddItem(clone4, 2)
			clone4.CFrame = CFrame.new(part.Position + createVector(0, 2, 0)) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				0
			)
			clone4.Parent = _WorldOrigin
			clone4.Transparency = 0.2
			clone4.Color = Color3.fromRGB(0, 0, 0)
			local tween = TweenService:Create(
				clone4,
				TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(50, 25, 50)
				}
			)
			tween.Completed:Connect(function()
				if clone4 then
					clone4:Destroy()
				end
			end)
			tween:Play()
			table.insert(v8.rotatables, { clone4, "BlackWind", 0 })
			local position = part.Position
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 and (humanoidRootPart2.Position - position).magnitude <= 100 then
					Util.CameraShaker:ShakeOnce(2, 10, 0.25, 0.35)
				end
			end

			v8.lastWind = tick()
		end

		if tick() - v8.lastTesla > 0.1 then
			teslaFeeler(
				CFrame.new(part.Position) * CFrame.Angles(
					math.rad((math.random(-30, 30))),
					math.rad((math.random(0, 360))),
					(math.rad((math.random(-30, 30))))
				),
				attachment,
				math.random(65, 85),
				math.random(25, 85),
				player,
				color
			) -- equivalent call inferred; original call site unknown
			v8.lastTesla = tick()
		end

		for _, child in pairs(clone.BottomAttachment:GetChildren()) do
			local nows = v8.particles[child.Name]

			if not (nows and tick() - nows[1] > nows[2]) then
				continue
			end

			child:Emit(nows[3])
			nows[1] = tick()
		end

		for _, child in pairs(clone.RotatedAttachment:GetChildren()) do
			local nows = v8.particles[child.Name]

			if not (nows and tick() - nows[1] > nows[2]) then
				continue
			end

			child:Emit(nows[3])
			nows[1] = tick()
		end

		if tick() - v8.lastShockParticle > 0.05 then
			clone.Shocks:Emit(2)
			v8.lastShockParticle = tick()
		end

		if #v8.rotatables > 0 then
			for k, rotatable in pairs(v8.rotatables) do
				if rotatable[1] == nil or rotatable[1].Parent == nil then
					table.remove(v8.rotatables, k)
				elseif rotatable[2] == "RedWind" then
					rotatable[1].Position = part.Position + Vector3.new(0, rotatable[3], 0)
					local v9 = rotatable[1].CFrame - rotatable[1].CFrame.Position
					rotatable[1].CFrame = rotatable[1].CFrame * v9 * CFrame.Angles(0, math.rad(40 * v8.dt * 60), 0)
					rotatable[3] += 0.5
				elseif rotatable[2] == "BlackWind" then
					rotatable[1].Position = part.Position + Vector3.new(0, rotatable[3], 0)
					local v9 = rotatable[1].CFrame - rotatable[1].CFrame.Position
					rotatable[1].CFrame = CFrame.new(part.Position) * CFrame.new(0, rotatable[3], 0) * v9 * CFrame.Angles(
						0,
						math.rad(-25 * v8.dt * 60),
						0
					)
					rotatable[3] += 0.5
				end
			end
		end

		v8.dt = RunService.RenderStepped:Wait()
	end

	if #v8.rotatables > 0 then
		for _, rotatable in pairs(v8.rotatables) do
			if rotatable[1] then
				rotatable[1]:Destroy()
			end
		end
	end

	v8.rotatables = nil

	if v3 then
		v3:Destroy()
	end

	if clone2 then
		clone2:Destroy()
	end

	if clone then
		if clone.RedBeam then
			clone.RedBeam:Destroy()
		end

		if clone.BlackBeam then
			clone.BlackBeam:Destroy()
		end
	end

	task.spawn(function()
		task.wait(0.5)

		if pointLight then
			local tween = TweenService:Create(
				pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Brightness = 0,
					Range = 1
				}
			)
			tween.Completed:Connect(function()
				if pointLight then
					pointLight:Destroy()
				end
			end)
			tween:Play()
		end

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
		local character = player.Character
		local humanoid = player.Humanoid
		local holdValue = player.HoldValue
		local timestamp = player.Timestamp
		local minHoldTime = player.MinHoldTime
		local maxHoldTime = player.MaxHoldTime
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

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

			task.spawn(function()
				tornadoAura(humanoidRootPart, holdValue, maxHoldTime, timestamp, minHoldTime, player2, color)
			end)
			local currentCamera = workspace.CurrentCamera
			local v = 0.016666666666666666
			local flag = false
			local v2 = false
			task.spawn(function()
				local character2 = game.Players.LocalPlayer.Character

				if character2 and humanoidRootPart and character2 and character2 == character then
					flag = true
					task.spawn(function()
						RunService:BindToRenderStep("CDKCycloneZoom", Enum.RenderPriority.Camera.Value + 1, function()
							local v3 = currentCamera
							local fieldOfView = currentCamera.FieldOfView
							local v4 = v2 and 70 or 110
							local v5 = v2 and 0.1 or v * 60 * 0.03
							v3.FieldOfView = fieldOfView + (v4 - fieldOfView) * v5
							v = RunService.RenderStepped:Wait()
						end)
					end)
				end
			end)
			local spinJoints = getSpinJoints(character, humanoidRootPart)
			local v3 = {}
			local total = 0
			local v4 = 1
			local steppedConnection = RunService.Stepped:connect(function()
				for _, spinJoint in pairs(spinJoints) do
					if not (spinJoint ~= nil and spinJoint.Parent ~= nil) then
						continue
					end

					v3[spinJoint] = cflerp(
						not v3[spinJoint] and spinJoint.Transform or v3[spinJoint],
						CFrame.new(0, -0.5, 0) * CFrame.Angles(0, math.rad(-total), -0.2617993877991494),
						v4
					)
					spinJoint.Transform = v3[spinJoint]
				end

				total += 35

				if total >= 359 then
					total = 0
				end
			end)
			local rightHand = character:FindFirstChild("RightHand")
			local leftHand = character:FindFirstChild("LeftHand")

			if rightHand and leftHand and holdValue and humanoid then
				local clone = script.CDKCursedAura:Clone()
				Util.Debris:AddItem(clone, 60)
				clone.CFrame = leftHand.CFrame
				clone.Light.Enabled = false
				SetParentWithCursedDualKatanaColor(clone, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown
				local clone2 = script.CDKCursedAura:Clone()
				Util.Debris:AddItem(clone2, 60)
				clone2.CFrame = rightHand.CFrame
				clone2.Light.Enabled = false
				SetParentWithCursedDualKatanaColor(clone2, _WorldOrigin, player2) -- equivalent call inferred; original call site unknown

				if color then
					for _, folder in pairs({ clone, clone2 }) do
						for _, descendant in pairs(folder:GetDescendants()) do
							if descendant:IsA("ParticleEmitter") then
								descendant.Color = Util.Misc.SwapColorInKeypoints(
									descendant,
									Color3.new(1, 0, 0),
									color,
									1
								)
							elseif descendant:IsA("SpotLight") then
								descendant.Color = color
								descendant.Enabled = true
							end
						end
					end
				end

				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < minHoldTime or diedConnection and holdValue and holdValue.Value == true
				end

				local v7 = {
					Air = { 1, 0.1, tick() },
					Black = { 1, 0.01, tick() },
					Red = { 1, 0.01, tick() },
					Electric = { 1, 0.05, tick() },
					Orbs = { 1, 0.05, tick() }
				}
				local v8 = {
					Air = { 1, 0.1, tick() },
					Black = { 1, 0.01, tick() },
					Red = { 1, 0.01, tick() },
					Electric = { 1, 0.05, tick() },
					Orbs = { 1, 0.05, tick() }
				}
				local _ = {
					Back = 1,
					Crescents = 1,
					Lightning = 1,
					Ring = 1,
					Updraft = 1,
					VerticalLightning = 1,
					Shocks = 1
				}
				local children = clone.Particles:GetChildren()
				local children2 = clone2.Particles:GetChildren()

				while (tick() - lastTime < minHoldTime or diedConnection and holdValue and holdValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoidRootPart and humanoid and clone and clone2 do
					for _, v9 in pairs(children) do
						if not v7[v9.Name] then
							continue
						end

						local v10 = v7[v9.Name]

						if not (tick() - v10[3] > v10[2]) then
							continue
						end

						v9:Emit(v10[1])
						v7[v9.Name][3] = tick()
					end

					for _, v9 in pairs(children2) do
						if not v8[v9.Name] then
							continue
						end

						local v10 = v8[v9.Name]

						if not (tick() - v10[3] > v10[2]) then
							continue
						end

						v9:Emit(v10[1])
						v8[v9.Name][3] = tick()
					end

					if leftHand and rightHand then
						clone.CFrame = leftHand.CFrame
						clone2.CFrame = rightHand.CFrame
					end

					RunService.RenderStepped:Wait()
				end

				if flag then
					v2 = true
					task.spawn(function()
						task.wait(0.5)
						currentCamera.FieldOfView = 70
						RunService:UnbindFromRenderStep("CDKCycloneZoom")
					end)
				end

				for _, v9 in pairs({ clone, clone2 }) do
					local tween = TweenService:Create(
						v9.Light,
						TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Brightness = 0,
							Range = 0
						}
					)
					local v10 = v9
					tween.Completed:Connect(function()
						if v10 then
							v10:Destroy()
						end
					end)
					tween:Play()
				end

				if diedConnection then
					diedConnection:Disconnect()
				end
			end

			if steppedConnection then
				steppedConnection:Disconnect()
			end
		end
	elseif actionID == 2 then
		local character = player.Character
		local delayUntilSwing = player.DelayUntilSwing
		local projectileCFrame = player.ProjectileCFrame
		local positionObject = player.PositionObject
		local timestamp = player.Timestamp
		local life = player.Life
		local distance = player.Distance

		if character then
			local numberValue = Instance.new("NumberValue")
			Util.Debris:AddItem(numberValue, 5)
			numberValue.Name = "CDKZRelease"
			numberValue.Value = delayUntilSwing
			numberValue.Parent = character

			if (projectileCFrame.Position - workspace.CurrentCamera.CFrame.Position).magnitude > 800 then
				return
			end

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

			tornadoProjectile(projectileCFrame, positionObject, timestamp, life, distance, player2, color)
		end
	end
end