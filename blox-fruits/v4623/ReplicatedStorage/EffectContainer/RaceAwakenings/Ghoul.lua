local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Pool = require(ReplicatedStorage:WaitForChild("Pool"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local ghoul = FX:WaitForChild("RaceAwakenings").Ghoul
local LeechVFX = require(script.LeechVFX)
local Crow = require(script.Crow)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function lifestealProjectile(originPart, targetPart, p)
	local position = originPart.Position

	if originPart and targetPart then
		local clone = ghoul.LeechVFX.LifestealTrail.Curse:Clone()
		clone.Parent = originPart
		Util.Debris:AddItem(clone, 1)

		for _, child in pairs(clone:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		local magnitude = (position - targetPart.Position).magnitude
		local _ = CFrame.new(position, targetPart.Position) * CFrame.new(0, 0, -magnitude)
		local v = {
			position,
			Vector3.new(math.random(-20, 20), math.random(-5, 8), math.random(-20, 20)),
			Vector3.new(math.random(-20, 20), math.random(-5, 8), math.random(-20, 20)),
			targetPart
		}
		LeechVFX.new(p, v)
	end
end

local function viewerIsClose(position, radius, fn, fn2)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		if (humanoidRootPart.Position - position).magnitude <= radius then
			if fn then
				fn((position - humanoidRootPart.Position).magnitude)
			end
		elseif fn2 then
			fn2((position - humanoidRootPart.Position).magnitude)
		end
	end
end

local function generateTrajectory(list)
	local random = Random.new()
	local v = list[random:NextInteger(1, #list)]
	local v2 = list[random:NextInteger(1, #list)]
	local v3 = list[random:NextInteger(1, #list)]
	local v4 = list[random:NextInteger(1, #list)]
	return function(p, p2, p3, p4, p5)
		local v5 = p2 or p4 + v * p5
		local v6 = p4 + v2 * p5
		local v7 = p4 + v3 * p5
		local v8 = p3 or p4 + v4 * p5
		return cubicBezier(p, v5, v6, v7, v8), cubicBezier(p + 0.016666666666666666, v5, v6, v7, v8)
	end
end

local v = Pool.new(string.format("%s/%s/Crows", script.Parent.Name, script.Name))
v:setAction(function(object, p)
	local now = tick()

	for _, v2 in pairs(object.Pool) do
		local v3 = now - v2.Start
		local v4 = v3 / v2.Lifetime
		local mapped = Util.Misc.map(
			math.clamp(((v2.Root.Position - currentCamera.CFrame.p).Magnitude - 250) / 1200, 0, 1),
			0,
			1,
			p,
			1
		)

		if not (mapped <= now - v2.LastUpdate) then
			continue
		end

		if v2.Root2:IsDescendantOf(workspace) and v2.Root:IsDescendantOf(workspace) and not v2.Root:GetAttribute("Destroying") then
			if v2.Lifetime < v3 then
				v2.Trajectory = generateTrajectory(v2.Points)
				v2.Trajectory(1, v2.Position, nil, v2.Root2.Position, v2.Radius)
				local v5 = v3 - v2.Lifetime
				local random = Random.new()
				v2.Start = now - v5
				v2.Lifetime = random:NextNumber(1.5, 3) / 2
				v2.FlapSpeed = random:NextNumber(1, 4)
				v2.Origin = v2.Trajectory(v5 / v2.Lifetime, v2.Position, nil, v2.Root2.Position, v2.Radius)
				v2.FirstTime = false
				continue
			else
				local trajectory, v5 = v2.Trajectory(v4, v2.Origin, nil, v2.Root2.Position, v2.Radius)

				if v2.FirstTime then
					local v6 = math.min(1, v3 / (v2.Lifetime * 0.1))
					v2.Crow:SetScale(v2.Scale * v6)
				end

				local cframe = CFrame.new(trajectory, v5)

				if math.abs((v5 - trajectory).Y) > 0.1 then
					for _, v6 in pairs({ "Left Wing", "Right Wing" }) do
						v2.Crow.Parts[v6].Trail.Enabled = false
					end
				else
					for _, v6 in pairs({ "Left Wing", "Right Wing" }) do
						v2.Crow.Parts[v6].Trail.Enabled = true
					end
				end

				local v6 = math.sin(v2.Angle) * 1
				v2.Crow:Flap(v6)
				v2.Crow:SetCFrame(cframe)
				v2.Position = trajectory
			end
		else
			if not v2.DestroyTime then
				local random = Random.new()
				v2.DestroyTime = now
				v2.DestroyLifetime = random:NextNumber(0.5, 1.5)
			end

			if now - v2.DestroyTime > v2.DestroyLifetime then
				v2.Crow:Hide(true)

				if math.random() > 0.5 then
					local v5 = v2.Crow:Pop()
					local v6 = v2
					task.delay(v5, function()
						v6.Crow:Destroy()
					end)
					object:remove(v2)
				else
					v2.Crow:Destroy()
					object:remove(v2)
				end

				continue
			else
				local v5 = (now - v2.DestroyTime) / v2.DestroyLifetime
				local trajectory, v6 = v2.Trajectory(v5, v2.Position, v2.Root.Position, v2.Root2.Position, v2.Radius)
				local cframe = CFrame.new(trajectory, v6)
				v2.Crow:Flap(Util.Tween.point(math.sin(v2.Angle), 0.5, v5))
				v2.Crow:SetCFrame(cframe)
			end
		end

		v2.LastUpdate = now
		v2.Angle = v2.Angle % 3.141592653589793 + 3.141592653589793 * v2.FlapSpeed * mapped
	end
end)

local function addCrow(clone, root, spherePoints, radius)
	local raceTransformed = root.Parent:FindFirstChild("RaceTransformed")

	if not raceTransformed then
		return
	end

	raceTransformed:GetAttribute("A")
	local B = raceTransformed:GetAttribute("B")
	raceTransformed:GetAttribute("C")

	if typeof(B) ~= "number" or B < 2 then
		return
	end

	local trajectory = generateTrajectory(spherePoints)
	local v3, v4 = trajectory(0, clone.Position, nil, root.Position, radius)
	trajectory(1, clone.Position, nil, root.Position, radius)
	local random = Random.new()
	local cframe = CFrame.new(v3, v4)
	local crow = Crow.new()
	local number = random:NextNumber(0.75, 1.75)
	crow:SetScale(number)
	crow:SetCFrame(cframe)
	crow.Model.Parent = _WorldOrigin
	crow:Pop()
	v:add({
		Angle = random:NextNumber(0, 3.141592653589793),
		Points = spherePoints,
		Radius = radius,
		Scale = number,
		Root = clone,
		Root2 = root,
		Origin = v3,
		Position = v3,
		Crow = crow,
		Trajectory = trajectory,
		FlapAlpha = 0,
		Lifetime = random:NextNumber(1.5, 3) / 2,
		FlapSpeed = random:NextNumber(1, 4),
		FirstTime = true,
		LastUpdate = 0,
		Start = tick()
	})
	return true
end

local function destroyShield(ID)
	local folder = _WorldOrigin:FindFirstChild(ID)

	if folder then
		folder:SetAttribute("Destroying", true)
		TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = createVector(1, 0, 0)
		}):Play()
		local v2 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v2 = math.max(v2, emitter.Lifetime.Max)
			emitter.Enabled = false
		end

		debris:AddItem(folder, v2)
	end
end

return function(data)
	local index = data.Index or 1

	if index == -1 then
		destroyShield(data.ID)
	elseif index == 0 then
		local cFrame = data.Root.CFrame
		local clone = ghoul.Plane:Clone()
		local emitters = {}
		local v2 = {}

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = false
			table.insert(emitters, emitter)
			table.insert(v2, {
				Size = emitter.Size.Keypoints,
				Speed = emitter.Speed,
				Acceleration = emitter.Acceleration
			})
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
		clone.Name = data.ID
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local v3 = Util.Sound:Play("PortalLoop", clone, 30, 0.125, 0.5)
		local _, v4, v5 = Util.RayMapCollidable(cFrame.p, createVector(-0, -1, -0) * data.Radius, nil, nil, true)
		Util.Misc.AlignCFrame(CFrame.new(v4), v5)
		local dot = (v4 - cFrame.p):Dot(createVector(-0, -1, -0))
		local _ = math.max(0, data.Radius - dot) / data.Radius
		local spherePoints = Util.Misc.GenerateSpherePoints(6.283185307179586, 3.141592653589793, 6, 1)
		local v6 = tick() + 2
		local count = 0
		local v8 = nil
		local now = 0
		local flag = false

		while clone:IsDescendantOf(workspace) do
			if not data.Root:IsDescendantOf(workspace) then
				flag = true
				break
			end

			if clone:GetAttribute("Destroying") then
				break
			end

			local now2 = tick()
			local cFrame2 = data.Root.CFrame
			local rayMapCollidable, v9, v10 = Util.RayMapCollidable(
				cFrame2.p,
				createVector(-0, -1, -0) * data.Radius,
				nil,
				nil,
				true
			)
			local alignCFrame = Util.Misc.AlignCFrame(CFrame.new(v9), v10)
			local dot2 = (v9 - cFrame2.p):Dot(createVector(-0, -1, -0))
			local v11 = math.max(0, data.Radius - dot2)
			local v12 = v11 / data.Radius

			if rayMapCollidable then
				clone.Size = Vector3.new(1, v11, v11)
				clone.CFrame = alignCFrame * CFrame.Angles(0, 0, 1.5707963267948966) + v10 * clone.Size.X

				for k, v13 in pairs(emitters) do
					Util.Misc.ScaleParticle(v13, data.Radius / 25 * v12, v2[k])
					v13.Enabled = true
				end

				clone.Transparency = 0

				if now2 - v6 > 0.175 and count < 12 then
					local position = data.Root.Position
					local v13 = data.Radius * 3
					local v14 = now2

					local function fn()
						if addCrow(clone, data.Root, spherePoints, data.Radius / 2) then
							if not v8 then
								v8 = Util.Sound:Play("CrowWingFlap", clone, 30, 1.5, 0.75)
							end

							count += 1
							v6 = v14
						end
					end

					local character = game.Players.LocalPlayer.Character

					if character ~= nil then
						local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= v13 and fn then
							local _ = (position - humanoidRootPart.Position).magnitude

							if addCrow(clone, data.Root, spherePoints, data.Radius / 2) then
								v8 = v8 or Util.Sound:Play("CrowWingFlap", clone, 30, 1.5, 0.75)
								count += 1
								v6 = now2
							end
						end
					end
				end
			else
				clone.Transparency = 1
				clone.Size = createVector(1, 0, 0)
				clone.CFrame = alignCFrame * CFrame.Angles(0, 0, 1.5707963267948966)

				for _, v13 in pairs(emitters) do
					v13.Enabled = false
					v13:Clear()
				end
			end

			if now2 - now > 0.1 and game.Players.LocalPlayer.Character ~= data.Root.Parent then
				viewerIsClose(data.Root.Position, data.Radius, function(distance)
					local v13 = 1 - math.max(0, distance / data.Radius)
					Effect.new("Dark.Gradient"):replicate({
						Toggle = true,
						Duration = 0.15,
						Transparency = 0.1,
						Distance = distance,
						Range = data.Radius
					})
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
						Brightness = v13 * -0.125,
						Contrast = v13 * 1,
						TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(255, 61, 61), v13),
						Saturation = v13 * -1
					}):Play()
				end, function()
					if colorCorrectionEffect.Saturation < 0 then
						Effect.new("Dark.Gradient"):replicate({
							Duration = 0.15,
							Toggle = false
						})
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
							Brightness = 0,
							Contrast = 0,
							TintColor = Color3.new(1, 1, 1),
							Saturation = 0
						}):Play()
					end
				end)
				now = tick()
			end

			RunService.RenderStepped:Wait()
		end

		if v3 then
			Util.Sound:FadeOut(v3, 0.5)
		end

		if v8 then
			Util.Sound:FadeOut(v8, 0.5)
		end

		if game.Players.LocalPlayer.Character ~= data.Root.Parent then
			Effect.new("Dark.Gradient"):replicate({
				Duration = 0.15,
				Toggle = false
			})

			if colorCorrectionEffect.Saturation < 0 then
				local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
					Brightness = 0,
					Contrast = 0,
					TintColor = Color3.new(1, 1, 1),
					Saturation = 0
				})
				tween:Play()
				Util.Debris:AddItem(colorCorrectionEffect, tween.TweenInfo.Time)
			else
				colorCorrectionEffect:Destroy()
			end
		end

		if flag then
			destroyShield(data.ID)
		end
	elseif index == 1 then
		local origin = data.Origin

		if (origin.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		Util.Sound:Play("WingFlaps", origin.Position, nil, math.random(25, 30) / 10, 1)
		local clone = ghoul.FeatherSpawn:Clone()
		Util.Debris:AddItem(clone, 1.5)
		clone.CFrame = origin
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	elseif index == 2 then
		local position = data.Position

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		if not data.Mute then
			local parent = Util.Sound:Play("QuickSlice", position, nil, math.random(19, 22) / 10, 0.5)
			local chorusSoundEffect = Instance.new("ChorusSoundEffect")
			chorusSoundEffect.Depth = 1
			chorusSoundEffect.Mix = 0.7
			chorusSoundEffect.Rate = 8.2
			chorusSoundEffect.Parent = parent
			local parent2 = Util.Sound:Play("ShadowAura", position, nil, math.random(25, 30) / 10, 0.5)
			local compressorSoundEffect = Instance.new("CompressorSoundEffect")
			compressorSoundEffect.Attack = 0.52
			compressorSoundEffect.Ratio = 47
			compressorSoundEffect.Threshold = -25
			compressorSoundEffect.Release = 2.4
			compressorSoundEffect.Parent = parent2
		end

		local clone = ghoul.FeatherHitEffect:Clone()
		Util.Debris:AddItem(clone, 1.25)
		clone.CFrame = CFrame.new(position)
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	elseif index == 3 then
		local originPart = data.OriginPart
		local targetPart = data.TargetPart

		if targetPart and originPart and typeof(targetPart) == "Instance" and typeof(originPart) == "Instance" then
			if (originPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 and (targetPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			lifestealProjectile(originPart, targetPart, math.random(4, 5) / 10)
		end
	end
end