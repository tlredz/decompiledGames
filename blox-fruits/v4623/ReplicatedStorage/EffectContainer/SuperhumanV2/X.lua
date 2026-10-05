local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local renderLoop = Util.RenderLoop
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lerpOutExpo(p, p2, p3)
	local v = 1 - (1 - p3) * (1 - p3) / math.exp(4 * p3)
	return p + (p2 - p) * v
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

local function debrisPart(data, position, p)
	local v = math.random(40, 100) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 3)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v, v)
	part.CFrame = CFrame.new(position, position + p) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * math.random(90, 130)
	part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(math.random(10, 15) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
		{
			Size = createVector(0.1, 0.1, 0.1)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	return part
end

local function blueWave(position, duration, vector2)
	local clone = script.WindRing:Clone()
	Util.Debris:AddItem(clone, duration + 1)
	clone.CFrame = CFrame.new(position) * CFrame.Angles(0, math.random(0, 360), 0)
	clone.Color = Color3.fromRGB(155, 242, 255)
	clone.Size = createVector(0, 15, 0)
	clone.Material = Enum.Material.Neon
	clone.Transparency = 0
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = vector2,
			CFrame = clone.CFrame * CFrame.Angles(0, ({ -179, 179 })[math.random(1, 2)], 0),
			Transparency = 1,
			Color = Color3.fromRGB(174, 237, 255)
		}
	)
	tween.Completed:Connect(function()
		task.wait(3)

		if clone then
			clone:Destroy()
		end
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function thickWindBeam(cFrame, p, value)
	local v = math.clamp(value, 0.5, 1)
	task.spawn(function()
		local clone = script.ThickWindBeam:Clone()
		Util.Debris:AddItem(clone, p + 1)
		local v2 = {}

		for _, v3 in { clone.Blue, clone.Black, clone.ThinBlue } do
			v2[v3] = {
				Beam = v3.Beam,
				Point0 = v3.At0,
				Point1 = v3.At1,
				GoalProperties = {
					1,
					v3.Beam.Width0,
					v3.Beam.Width1,
					v3.At0.Position.Z,
					v3.At1.Position.Z
				}
			}
			v3.Beam.Width0 = 0
			v3.Beam.Width1 = 0
			v3.At0.Position = createVector(0, 0, 0)
			v3.At1.Position = createVector(0, 0, 0)
			v3.CFrame = cFrame
		end

		clone.Parent = _WorldOrigin
		local lastTime = tick()
		local v3 = 0.016666666666666666

		while true do
			local v4 = v3 * 60
			local v5 = tick() - lastTime
			local v6 = math.clamp(v5 / p, 0.01, 1)

			if p < v5 or not (clone and clone.Blue and clone.Black and clone.ThinBlue) then
				break
			end

			for _, v7 in pairs({ clone.Blue, clone.Black, clone.ThinBlue }) do
				v7.CFrame *= CFrame.Angles(math.rad(2 / v6 * v4), 0, 0)
			end

			for _, v7 in pairs(v2) do
				v7.Beam.Transparency = NumberSequence.new(0 + (v7.GoalProperties[1] - 0) * v6)
				local beam = v7.Beam
				beam.Width0 = lerpOutExpo(0, v7.GoalProperties[2] * v, v6)
				local beam2 = v7.Beam
				beam2.Width1 = lerpOutExpo(0, v7.GoalProperties[3] * v, v6)
				local point0 = v7.Point0
				local v10 = v7.GoalProperties[4] * v
				point0.Position = Vector3.new(0, 0, lerpOutExpo(0, v10, v6))
				local point1 = v7.Point1
				local v11 = v7.GoalProperties[5] * v
				point1.Position = Vector3.new(0, 0, lerpOutExpo(0, v11, v6))
			end

			v3 = RunService.RenderStepped:Wait()
		end

		if clone then
			clone:Destroy()
		end
	end)
end

local function windArea(humanoidRootPart, _, p, p2, p3)
	local v = renderLoop.new(tick(), p3, p3 + 3, 60)
	local v2 = humanoidRootPart.Position - createVector(0, 1.5, 0)
	local ray, position, _ = Util.Ray(
		v2,
		CFrame.new(v2).upVector.Unit * -6,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local clone = nil
	local v4 = 0

	if ray then
		clone = script.GroundDust:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.Position = position
		clone.Parent = _WorldOrigin
		clone.Rock.Color = ColorSequence.new(ray.Color)
		v:AddInstance("SpinEmitter", clone)
	end

	v:SetGroupFunction("WindRibbons", function(instance, _, _, p4, p5)
		instance.CFrame = instance.CFrame * CFrame.new(0, p2 * p4, 0) * CFrame.Angles(
			math.rad(p5 * 1),
			math.rad(30 * p4),
			0
		)
		local size = instance.Size
		local vector2 = Vector3.new(v4, v4 / 8, v4)
		local v5 = p * p4
		instance.Size = size + (vector2 - size) * v5
		local transparency = instance.Transparency
		local v6 = p * p4
		instance.Transparency = transparency + (1 - transparency) * v6

		if instance.Transparency >= 0.95 then
			instance:Destroy()
		end
	end)
	v:SetGroupFunction("DecalWindRibbons", function(instance, _, _, p4, p5)
		instance.CFrame = instance.CFrame * CFrame.new(0, 0.5 * p4, 0) * CFrame.Angles(
			math.rad(p5 * 0.5),
			math.rad(-30 * p4),
			0
		)
		local mesh = instance.Mesh
		local scale = instance.Mesh.Scale
		local vector2 = Vector3.new(v4 / 100 * 5, v4 / 150 * 20, v4 / 100 * 5)
		local v5 = 0.2 * p4
		mesh.Scale = scale + (vector2 - scale) * v5
		local decal = instance.Decal
		local transparency = instance.Decal.Transparency
		local v6 = 0.1 * p4
		decal.Transparency = transparency + (1 - transparency) * v6

		if instance.Decal.Transparency >= 0.95 then
			instance:Destroy()
		end
	end)
	v:SetGroupFunction("ExtraWind", function(p4, _, _, p5, p6)
		p4.CFrame = p4.CFrame * CFrame.new(0, -0.1 * p5, 0) * CFrame.Angles(math.rad(p6 * 0.5), math.rad(-30 * p5), 0)
	end)
	v:SetGroupFunction("SpinEmitter", function(p4, _, _, p5, _)
		p4.CFrame *= CFrame.Angles(0, math.rad(10 * p5), 0)
	end)
	v:AddTick("SpawnWindRibbons", 0.1, function(_, _)
		v4 = math.min(v4 + 10, 200)

		if humanoidRootPart then
			v2 = humanoidRootPart.Position - createVector(0, 1.5, 0)
		end

		Util.Sound:Play("SharpAirGust", v2, nil, 0.8 + math.random(-15, 15) / 100, 1)

		if clone then
			clone.Dust:Emit(5)
			clone.Rock:Emit(2)
		end

		local clone2 = script.Wind2:Clone()
		Util.Debris:AddItem(clone2, 2)
		clone2.Size = createVector(0, 0, 0)
		clone2.CFrame = CFrame.new(v2) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
		clone2.Parent = _WorldOrigin
		v:AddInstance("WindRibbons", clone2)
		local clone3 = script.WindSlash:Clone()
		Util.Debris:AddItem(clone3, 2)
		clone3.CFrame = CFrame.new(v2) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
		clone3.Parent = _WorldOrigin
		clone3.Mesh.Scale = createVector(0.1, 0.1, 0.1)
		clone3.Decal.Transparency = 0.85
		v:AddInstance("DecalWindRibbons", clone3)
	end)
	v:AddTick("SpawnWindPulse", 0.3, function(_, _)
		local v5 = v2
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and (humanoidRootPart2.Position - v5).magnitude <= 60 then
				Util.CameraShaker:ShakeOnce(2, 3, 0.5, 0.5)
			end
		end

		local clone2 = script.SmokeRing:Clone()
		Util.Debris:AddItem(clone2, 2)
		clone2.CFrame = CFrame.new(v2 + createVector(0, 5, 0)) * CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
		clone2.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone2,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = createVector(115, 10, 115),
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			if clone2 then
				clone2:Destroy()
			end
		end)
		v:AddInstance("ExtraWind", clone2)
		tween:Play()
	end)
	v:Start()
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function windParticle(cFrame, p)
	task.spawn(function()
		local _ = cFrame.Position
		local clone = script.ChargeWindTrail:Clone()
		Util.Debris:AddItem(clone, 3)
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local v = { -65, 65 }
		local vector2 = Vector3.new(v[math.random(1, 2)], math.random(5, 10), v[math.random(1, 2)])
		local vector3 = Vector3.new(math.random(-35, 35), math.random(-1, 10), math.random(-35, 35))
		local position = cFrame.Position
		local v2 = math.random(3, 4) / 10
		local lastTime = tick()
		local lastTime2 = tick()
		local v3 = math.random(1, 5)

		while tick() - lastTime2 <= v2 do
			local v4 = tick() - lastTime2

			if tick() - lastTime2 <= v2 / 2 then
				clone.CFrame *= CFrame.new(-11, 0, 0) * CFrame.Angles(
					math.rad(-v3 * math.cos(v4 / 5 + math.random(-15, 15) / 10)),
					0.5585053606381855,
					0
				)
				position = clone.Position
			else
				local v5 = {
					position,
					position + (p.Position + vector2 - position) * 0.33,
					position + (p.Position + vector3 - position) * 0.66,
					p.Position
				}
				local v6 = cubicBezier(math.max(0.001, v4 - v2 / 2) / (v2 - v2 / 2), unpack(v5))
				clone.CFrame = CFrame.new(v6, position) * CFrame.Angles(0, 3.141592653589793, 0)
			end

			if tick() - lastTime > 0.1 then
				clone.Wind:Emit(1)
				lastTime = tick()
			end

			RunService.RenderStepped:Wait()
		end

		task.wait(1)

		if clone then
			clone:Destroy()
		end
	end)
end

local function projectileExplosion(lastCF, hit, norm)
	local position = lastCF.Position
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 40 then
			Util.CameraShaker:ShakeOnce(10, 15, 0.3, 1)
		end
	end

	local clone = script.SlashExplosion:Clone()
	Util.Debris:AddItem(clone, 5)
	local attachment = clone.Attachment
	clone.CFrame = lastCF
	clone.Parent = _WorldOrigin
	clone.Debris:Emit(math.random(40, 50))
	Util.Sound:Play("AirBurst", clone.Position, nil, 1.2 + math.random(-10, 10) / 100, 2)
	Util.Sound:Play("SharpAirGust", clone.Position, nil, 1 + math.random(-10, 10) / 100, 2)

	if hit then
		clone.CFrame = CFrame.new(lastCF.Position, lastCF.Position + norm) * CFrame.Angles(-1.5707963267948966, 0, 0)

		for _ = 1, 5 do
			debrisPart(hit, lastCF.Position, norm)
		end

		local play = Util.Sound:Play("Wallhit2", lastCF.Position, nil, 0.8 + math.random(-10, 10) / 100, 2)
		play.RollOffMaxDistance = 500
	end

	task.spawn(function()
		for _ = 1, 3 do
			attachment.AirSwirls:Emit(1)
			task.wait(0.1)
		end
	end)

	for _, child in pairs(attachment:GetChildren()) do
		if child.Name == "Clouds" then
			child:Emit(math.random(7, 10))
		elseif child.Name == "Dust" then
			child:Emit(25)
		elseif child.Name == "Sparks" then
			child:Emit(math.random(15, 20))
		elseif child.Name == "AirSwirls" then
			child:Emit(3)
		elseif child.Name == "Diamond" then
			child:Emit(math.random(10, 15))
		elseif child.Name == "SpikeBurst" then
			child:Emit(math.random(10, 15))
		elseif child.Name == "Wisp" then
			child:Emit(3)
		else
			child:Emit(math.random(3, 5))
		end
	end

	TweenService:Create(
		attachment.AirSwirls,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			TimeScale = 0.4
		}
	):Play()
end

local function dashWind(cframe)
	local position = cframe.Position
	local ray, v, _ = Util.Ray(
		position,
		CFrame.new(position).UpVector.Unit * -10,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local v2 = cframe * CFrame.new(0, 0, -5)

	if ray then
		cframe = CFrame.new(v, (Vector3.new(v2.X, v.Y, v2.Z)))
	end

	local clone = script.LeftShockwave:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.CFrame = cframe * CFrame.new(-8, 0, 0) * CFrame.Angles(0, -0.2617993877991494, 0)
	clone.Parent = _WorldOrigin
	local clone2 = script.RightShockwave:Clone()
	Util.Debris:AddItem(clone2, 2)
	clone2.CFrame = cframe * CFrame.new(8, 0, 0) * CFrame.Angles(0, 0.2617993877991494, 0)
	clone2.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(8, 15, 80),
			Transparency = 1,
			CFrame = clone.CFrame * CFrame.new(-10, 10, 15)
		}
	)
	tween.Completed:Connect(function()
		if clone then
			clone:Destroy()
		end
	end)
	local tween2 = TweenService:Create(
		clone2,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(8, 15, 80),
			Transparency = 1,
			CFrame = clone2.CFrame * CFrame.new(10, 10, 15)
		}
	)
	tween2.Completed:Connect(function()
		if clone2 then
			clone2:Destroy()
		end
	end)
	tween:Play()
	tween2:Play()
end

local function projectile(cFrame, positionObject, timestamp, lifetime, distance)
	local life = math.max(lifetime - (masterClock:GetTime() - timestamp), 0.1)
	Util.Sound:Play("WhirlWhistle", cFrame.p, nil, 2, 2)
	Util.Sound:Play("shot", cFrame.p, nil, 2, 2)
	local clone = script.Slash:Clone()
	Util.Debris:AddItem(clone, life + 5)
	local lines = clone.Root.Lines
	clone.Parent = _WorldOrigin
	local parent = Util.Sound:Play("AirTurbine", clone.Root, nil, 1.2 + math.random(-10, 10) / 100, 5.5)
	parent.PlaybackSpeed = 3
	parent.TimePosition = 1
	local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
	pitchShiftSoundEffect.Octave = 0.5
	pitchShiftSoundEffect.Parent = parent
	local clone_2 = pitchShiftSoundEffect:Clone()
	clone_2.Parent = parent
	TweenService:Create(parent, TweenInfo.new(life, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
		PlaybackSpeed = 1
	}):Play()
	local _ = cFrame.lookVector
	local value = false
	positionObject.Changed:Connect(function()
		value = positionObject.Value or nil
	end)
	local v3 = {
		rotatables = {},
		t = tick(),
		lastParticle = tick() - 1,
		lastCrescent = tick() - 1,
		life = life,
		currentCFrame = cFrame,
		lastCF = cFrame,
		lastDist = 1,
		dt = 0.016666666666666666,
		hit = nil,
		pos = nil,
		norm = nil
	}
	task.spawn(function()
		for _ = 1, 5 do
			windParticle(
				cFrame * CFrame.new(math.random(-10, 10), math.random(-2, 2), math.random(-16, -12)),
				clone.Root
			) -- equivalent call inferred; original call site unknown
		end
	end)

	while tick() - v3.t < v3.life do
		local _ = (tick() - v3.t) / v3.life
		local v4 = (tick() - v3.t) / 100 / (v3.life / 100)
		v3.lastCF = v3.currentCFrame
		v3.currentCFrame = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v4)
		clone:SetPrimaryPartCFrame(v3.currentCFrame * CFrame.Angles(0, 0, 1.5707963267948966))

		if tick() - v3.lastParticle > 0.1 then
			lines:Emit(1)
			v3.lastParticle = tick()
		end

		if tick() - v3.lastCrescent > 0.05 then
			local clone2 = clone.SlashPartRight:Clone()
			Util.Debris:AddItem(clone2, 2)
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(
				clone2.Decal,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				if clone2 then
					clone2:Destroy()
				end
			end)
			tween:Play()
			table.insert(v3.rotatables, clone2)
			local clone3 = script.Wind2:Clone()
			Util.Debris:AddItem(clone3, 2)
			clone3.CFrame = v3.lastCF * CFrame.Angles(1.5707963267948966, math.rad((math.random(0, 360))), 0)
			clone3.Size /= 4
			clone3.Color = Color3.fromRGB(157, 192, 214)
			clone3.Material = Enum.Material.Neon
			clone3.Parent = _WorldOrigin
			local tween2 = TweenService:Create(
				clone3,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					CFrame = clone3.CFrame * CFrame.Angles(0, -3.0543261909900767, 0),
					Size = clone3.Size * 8
				}
			)
			tween2.Completed:Connect(function()
				if clone3 then
					clone3:Destroy()
				end
			end)
			tween2:Play()
			v3.lastCrescent = tick()
		end

		v3.lastDist = (v3.lastCF.p - v3.currentCFrame.p).Magnitude
		local ray, pos, norm = Util.Ray(
			v3.lastCF.p,
			v3.lastCF.lookVector.Unit * v3.lastDist,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		v3.hit = ray
		v3.pos = pos
		v3.norm = norm

		if value then
			clone.Root.Position = positionObject.Value
			v3.lastCF = CFrame.new(positionObject.Value) * (v3.lastCF - v3.lastCF.p)
			break
		else
			if v3.hit then
				v3.lastCF = CFrame.new(v3.pos) * (v3.lastCF - v3.lastCF.p)
				break
			end

			if #v3.rotatables > 0 then
				for k, rotatable in pairs(v3.rotatables) do
					if rotatable == nil or rotatable.Parent == nil then
						table.remove(v3.rotatables, k)
					else
						local mesh = rotatable:FindFirstChild("Mesh")
						local decal = rotatable:FindFirstChild("Decal")
						local v7 = v3.dt * 60

						if rotatable and mesh and decal then
							local X = mesh.Scale.X
							local v8 = 0.1 * v7
							local v9 = X + (1.3 - X) * v8
							local Y = mesh.Scale.Y
							local v10 = 0.1 * v7
							local v11 = Y + (1.5 - Y) * v10
							local Z = mesh.Scale.Z
							local v12 = 0.1 * v7
							mesh.Scale = Vector3.new(v9, v11, Z + (5 - Z) * v12)
						end
					end
				end
			end

			v3.dt = RunService.RenderStepped:Wait()
		end
	end

	if clone then
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 5)
		part.Size = Vector3.new()
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Position = v3.lastCF.p
		part.Parent = _WorldOrigin
		clone:Destroy()
	end

	projectileExplosion(v3.lastCF, v3.hit, v3.norm)

	if #v3.rotatables > 0 then
		while #v3.rotatables > 0 do
			for k, rotatable in pairs(v3.rotatables) do
				if rotatable == nil or rotatable.Parent == nil then
					table.remove(v3.rotatables, k)
				else
					local mesh = rotatable:FindFirstChild("Mesh")
					local decal = rotatable:FindFirstChild("Decal")
					local v4 = v3.dt * 60

					if rotatable and mesh and decal then
						local X = mesh.Scale.X
						local v5 = 0.1 * v4
						local v6 = X + (1.3 - X) * v5
						local Y = mesh.Scale.Y
						local v7 = 0.1 * v4
						local v8 = Y + (1.5 - Y) * v7
						local Z = mesh.Scale.Z
						local v9 = 0.1 * v4
						mesh.Scale = Vector3.new(v6, v8, Z + (5 - Z) * v9)
					end
				end
			end

			v3.dt = RunService.RenderStepped:Wait()
		end
	end
end

return function(player)
	local stage = player.Stage or 1

	if stage == 1 then
		local character = player.Character

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local holdValue = player.HoldValue
			local humanoid = player.Humanoid
			local minHold = player.MinHold

			if humanoidRootPart and holdValue then
				if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
					return
				end

				local v = windArea(humanoidRootPart, createVector(80, 10, 80), 0.2, 1, 3)
				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				end

				local lastTime = tick()
				local now = tick() - 1

				-- equivalent calls inferred from this helper; original call sites unknown
				local function running()
					return tick() - lastTime < minHold or diedConnection and holdValue and holdValue.Value == true
				end

				task.spawn(function()
					while running() and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoidRootPart and humanoid do
						if tick() - now > 0.1 then
							if humanoidRootPart then
								windParticle(
									humanoidRootPart.CFrame * CFrame.new(
										math.random(2, 6),
										math.random(-1, 2),
										math.random(-16, -12)
									),
									humanoidRootPart
								) -- equivalent call inferred; original call site unknown
							end

							now = tick()
						end

						RunService.RenderStepped:Wait()
					end

					if v then
						v:Stop()
					end
				end)
				Util.Sound:Play("SharpAirGust", humanoidRootPart.Position, nil, 0.8 + math.random(-12, 12) / 100, 1.5)
				local attachment = Instance.new("Attachment")
				Util.Debris:AddItem(attachment, 2)
				attachment.Parent = humanoidRootPart
				local clone = script.Rays:Clone()
				clone.Parent = attachment
				local clone2 = script.Ring:Clone()
				clone2.Parent = attachment
				clone2:Emit(1)
				task.spawn(function()
					for _ = 1, 5 do
						clone:Emit(3)
						task.wait(0.1)
					end
				end)
			end
		end
	elseif stage == 2 then
		local cFrame = player.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local lifetime = player.Lifetime
		local distance = player.Distance
		local positionObject = player.PositionObject
		local timestamp = player.Timestamp
		local character = player.Character
		local character2 = game.Players.LocalPlayer.Character

		if character2 and character == character2 then
			local superhumanV2X = Util.Anims:Get(character, "SuperhumanV2X")
			superhumanV2X:Play()
			superhumanV2X.TimePosition = 1.2
			superhumanV2X:AdjustSpeed(1.3)
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			dashWind(humanoidRootPart.CFrame)
		end

		projectile(cFrame, positionObject, timestamp, lifetime, distance)
	elseif stage == 3 then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			local cFrame = player.CFrame
			local _ = player.Floor
			local timestamp = player.Timestamp
			local _ = player.ClapDelay
			local heldScale = player.HeldScale
			local v = Util.MasterClock:GetTime() - timestamp
			local v2 = math.max(player.ClapDelay - v, 0.01)
			local character2 = game.Players.LocalPlayer.Character
			local v3 = character2 and character == character2 and true or false
			task.delay(0.05, function()
				local RocksModule = require(game.ReplicatedStorage.Util.RocksModule)
				RocksModule.Ground(
					cFrame.p,
					67.5 * heldScale,
					createVector(6, 6.6666665, 6) * heldScale,
					{ workspace.Map },
					6 + heldScale * 4,
					false,
					heldScale,
					true
				)
			end)

			if v3 then
				local superhumanV2X = Util.Anims:Get(character, "SuperhumanV2X")
				superhumanV2X:Play()
				superhumanV2X.TimePosition = 0.2
				task.spawn(function()
					task.wait(0.8)

					if superhumanV2X then
						superhumanV2X:Stop()
					end
				end)
			end

			task.wait(v2)
			local parent = Util.Sound:Play(
				"TremorWave1",
				humanoidRootPart.Position,
				nil,
				0.9 + math.random(-15, 15) / 100,
				1
			)

			if heldScale >= 0.8 then
				local chorusSoundEffect = Instance.new("ChorusSoundEffect")
				chorusSoundEffect.Parent = parent
			end

			local cFrame2 = CFrame.new(humanoidRootPart.Position - createVector(0, 3, 0)) * CFrame.Angles(
				0,
				math.rad((math.random(0, 360))),
				0
			)
			local clone = script.Shockwave:Clone()
			Util.Debris:AddItem(clone, 2)
			clone.Size = Vector3.new()
			clone.CFrame = cFrame2
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = Vector3.new(125 * heldScale, 7 * heldScale, 125 * heldScale),
					CFrame = clone.CFrame * CFrame.new(0, 2, 0),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				if clone then
					clone:Destroy()
				end
			end)
			clone.Parent = _WorldOrigin
			tween:Play()
			local part = Instance.new("Part")
			Util.Debris:AddItem(part, 3)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.Size = Vector3.new()
			part.Position = cFrame2.Position
			local clone2 = script.StompRings:Clone()
			clone2.Parent = part
			local clone3 = script.Ring:Clone()
			clone3.Parent = part
			clone3.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 60) })
			part.Parent = _WorldOrigin
			local part2 = Instance.new("Part")
			Util.Debris:AddItem(part2, 3)
			part2.Anchored = true
			part2.CanCollide = false
			part2.Transparency = 1
			part2.Size = createVector(1, 2, 1)
			part2.Position = cFrame2.Position
			part2.Parent = _WorldOrigin
			local clone4 = script.Slash.Root.Lines:Clone()
			clone4.Enabled = false
			clone4.Shape = Enum.ParticleEmitterShape.Disc
			clone4.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
			clone4.ShapePartial = 0
			clone4.EmissionDirection = "Top"
			clone4.Brightness = 5
			clone4.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
			clone4.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 10.7, 2.3),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone4.Speed = NumberRange.new(40, 100)
			clone4.Parent = part2
			local attachment = Instance.new("Attachment")
			attachment.Parent = part2
			local clone5 = script.Dust:Clone()
			clone5.Parent = attachment
			clone5.Speed = NumberRange.new(300 * heldScale, 400 * heldScale)
			clone5.Acceleration = Vector3.new(0, 150 * heldScale, 0)
			local ray, _, _ = Util.Ray(
				humanoidRootPart.Position,
				CFrame.new(humanoidRootPart.Position).upVector.Unit * -6,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				clone5.Color = ColorSequence.new(ray.Color)
			end

			local clone6 = script.Wind:Clone()
			clone6.Parent = attachment
			local clone7 = script.BlueStreaks:Clone()
			clone7.Parent = attachment

			for _, v6 in pairs({
				clone5,
				clone6,
				clone7,
				clone4,
				clone2,
				clone3
			}) do
				local numberSequenceKeypoints = {}

				for _, keypoint in pairs(v6.Size.Keypoints) do
					table.insert(
						numberSequenceKeypoints,
						(NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * heldScale, keypoint.Envelope))
					)
				end

				v6.Size = NumberSequence.new(numberSequenceKeypoints)
			end

			clone5:Emit(math.random(50, 60))
			clone6:Emit(math.random(3, 4))
			clone7:Emit(2)
			clone2:Emit(3)
			clone3:Emit(1)
			local cFrame3 = CFrame.new(part2.Position) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(
				math.rad((math.random(-180, 180))),
				0,
				0
			)
			local v7 = math.clamp(heldScale, 0.5, 1)
			local v8 = 0.6
			task.spawn(function()
				local clone8 = script.ThickWindBeam:Clone()
				Util.Debris:AddItem(clone8, v8 + 1)
				local v9 = {}

				for _, v10 in { clone8.Blue, clone8.Black, clone8.ThinBlue } do
					v9[v10] = {
						Beam = v10.Beam,
						Point0 = v10.At0,
						Point1 = v10.At1,
						GoalProperties = {
							1,
							v10.Beam.Width0,
							v10.Beam.Width1,
							v10.At0.Position.Z,
							v10.At1.Position.Z
						}
					}
					v10.Beam.Width0 = 0
					v10.Beam.Width1 = 0
					v10.At0.Position = createVector(0, 0, 0)
					v10.At1.Position = createVector(0, 0, 0)
					v10.CFrame = cFrame3
				end

				clone8.Parent = _WorldOrigin
				local lastTime = tick()
				local v10 = 0.016666666666666666

				while true do
					local v11 = v10 * 60
					local v12 = tick() - lastTime
					local v13 = math.clamp(v12 / v8, 0.01, 1)

					if v8 < v12 or not (clone8 and clone8.Blue and clone8.Black and clone8.ThinBlue) then
						break
					end

					for _, v14 in pairs({ clone8.Blue, clone8.Black, clone8.ThinBlue }) do
						v14.CFrame *= CFrame.Angles(math.rad(2 / v13 * v11), 0, 0)
					end

					for _, v14 in pairs(v9) do
						v14.Beam.Transparency = NumberSequence.new(0 + (v14.GoalProperties[1] - 0) * v13)
						local beam = v14.Beam
						beam.Width0 = lerpOutExpo(0, v14.GoalProperties[2] * v7, v13)
						local beam2 = v14.Beam
						beam2.Width1 = lerpOutExpo(0, v14.GoalProperties[3] * v7, v13)
						local point0 = v14.Point0
						local v17 = v14.GoalProperties[4] * v7
						point0.Position = Vector3.new(0, 0, lerpOutExpo(0, v17, v13))
						local point1 = v14.Point1
						local v18 = v14.GoalProperties[5] * v7
						point1.Position = Vector3.new(0, 0, lerpOutExpo(0, v18, v13))
					end

					v10 = RunService.RenderStepped:Wait()
				end

				if clone8 then
					clone8:Destroy()
				end
			end)
			task.spawn(function()
				local v9 = 0.016666666666666666

				for _ = 1, 30 do
					local parent2 = part2
					local size = part2.Size
					local vector2 = Vector3.new(200 * heldScale, 2, 200 * heldScale)
					local v11 = v9 * 0.05 * 60
					parent2.Size = size + (vector2 - size) * v11
					clone4:Emit(3)
					v9 = RunService.RenderStepped:Wait()
				end
			end)
			local position = cFrame2.Position
			local character3 = game.Players.LocalPlayer.Character

			if character3 ~= nil then
				local humanoidRootPart2 = character3:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 and (humanoidRootPart2.Position - position).magnitude <= 40 then
					Util.CameraShaker:ShakeOnce(13, 20, 0.3, 1.2)
				end
			end

			for i = 1, 2 do
				blueWave(
					cFrame2.Position + Vector3.new(0, i * 3, 0),
					math.random(30, 50) / 80,
					Vector3.new(200 / i * 0.95 * heldScale, 5, 200 / i * 0.95 * heldScale)
				)
			end
		end
	else
		local humanoidRootPart = stage == 4 and player.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			Util.Sound:Play("PrimeChime", humanoidRootPart.Position, nil, 1.5, 1.5)
			local clone = script.Sparkle:Clone()
			Util.Debris:AddItem(clone, 1)
			clone.Parent = humanoidRootPart
			clone:Emit(1)
		end
	end
end