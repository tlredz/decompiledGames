local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local Effect = require(game.ReplicatedStorage.Effect)
local superhumanV2Travel = Effect.new("SuperhumanV2.Travel")
local random = Random.new()

local function areShiftedColorsEqual(instance, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = instance:FindFirstChild(childName)

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

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local function getColorHSVDistance(color: Color3, color2: Color3)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local color3 = Color3.fromRGB(v2, v3, v4)
	local v5 = math.max(1, color2.R, color2.G, color2.B)
	local v6 = math.floor(color2.R / v5 * 255) % 256
	local v7 = math.floor(color2.G / v5 * 255) % 256
	local v8 = math.floor(color2.B / v5 * 255) % 256
	local color4 = Color3.fromRGB(v6, v7, v8)
	local HSV, _, _ = color3:ToHSV()
	local HSV2, _, _ = color4:ToHSV()
	local v9 = math.abs(HSV2 - HSV)
	return (math.min(v9, 1 - v9))
end

local function applyColorShiftHSV2(color: Color3, p: number, p2: number, p3: number)
	if getColorHSVDistance(color, Color3.new(1, 1, 0)) > 0.05555555555555555 then
		return color
	end

	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local FX = require(game.ReplicatedStorage.FX)
local singularBeam = FX:WaitForChild("Pain").X.Assets.Garbage["Singular Beam"]

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil and not effect:IsA("Trail") then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not (effect:IsA("Trail") or effect.Lifetime.Max <= max) then
			max = effect.Lifetime.Max
		end
	end

	return max
end

return function(p, flag: boolean, instance, p2, p3, p4, folder)
	if flag == "End" then
		return
	end

	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local cFrame = p3 * CFrame.new(0, 0, -3)
	local clone = singularBeam.Start:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	task.delay(ParticleState(clone), clone.Destroy, clone)
	task.wait(0.2)
	local lastTime = os.clock()
	local v2 = {}

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function easeOutQuad(p5)
		return 1 - (1 - p5) * (1 - p5)
	end

	local function spawnShockwave(p5)
		local clone2 = singularBeam.Shockwave:Clone()
		Util.SetParentOverrideWithColor(clone2, p2, p, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			p,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p6)
				return applyColorShiftHSV2(p6, 0.41666667, 1.165137614678899, 1) or p6
			end)
		end

		local number = random:NextNumber(0, 6.283185307179586)
		clone2.CFrame = p5 * CFrame.Angles(1.5707963267948966, number, 3.141592653589793)
		local mesh = clone2.Mesh
		table.insert(v2, {
			p = clone2,
			mesh = mesh,
			yaw = number,
			age = 0,
			life = 0.1
		})
	end

	local v3 = Util.Sound:Play("X_Held_Beam_V2_01", humanoidRootPart)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local cframe = CFrame.lookAt(humanoidRootPart.Position, p4.Value)
		local v4 = 1 - math.exp(-20 * dt)
		cFrame = cFrame:Lerp(cframe, v4)

		if os.clock() - lastTime >= 0.08 then
			lastTime = os.clock()
			spawnShockwave(cFrame)
		end

		for i = #v2, 1, -1 do
			local v5 = v2[i]
			v5.age += dt
			local v7 = easeOutQuad(math.clamp(v5.age / v5.life, 0, 1))
			local v8 = 90 * v7
			local v9 = 150 * v7
			v5.p.CFrame = cFrame * CFrame.Angles(1.5707963267948966, v5.yaw, 3.141592653589793) * CFrame.new(0, v8, 0)
			v5.mesh.Scale = Vector3.new(0, v9, 0)

			if not (v5.age >= v5.life) then
				continue
			end

			v5.p:Destroy()
			table.remove(v2, i)
		end
	end)
	local clone2 = singularBeam.Beam:Clone()
	clone2.CFrame = cFrame
	clone2.Part2.CFrame = cFrame
	ParticleState(clone2, false)
	local clone3 = singularBeam.StartAura:Clone()
	clone3.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone3, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone3, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	local part2 = clone2.Part2
	part2.CFrame = clone2.CFrame
	Util.SetParentOverrideWithColor(clone2, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone2, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	local clone4 = singularBeam.BeamParticles:Clone()
	clone4.CFrame = clone2.CFrame
	clone4.Size *= createVector(1, 1, 0)
	Util.SetParentOverrideWithColor(clone4, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone4, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	local clone5 = singularBeam.End:Clone()
	clone5.CFrame = part2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	Util.SetParentOverrideWithColor(clone5, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone5, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	local clone6 = singularBeam.EndTip:Clone()
	clone6.CFrame = part2.CFrame
	Util.SetParentOverrideWithColor(clone6, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone6, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	for _, emitter in pairs(clone6:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(1)
		emitter.Rate *= 2
	end

	local clone7 = singularBeam.Distortion:Clone()
	clone7.CFrame = part2.CFrame
	Util.SetParentOverrideWithColor(clone7, p2, p, "PainFruitVFXColor")
	local color = Color3.fromRGB(113, 15, 36)
	local color2 = Color3.fromRGB(241, 76, 81)
	local isBlue = areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) and true or nil
	superhumanV2Travel:replicate({
		Root = clone7,
		Color = color,
		Scale = 4,
		Duration = 0.49999999999999994,
		IgnoreParticles = true,
		isBlue = isBlue
	})
	superhumanV2Travel:replicate({
		Root = clone7,
		Color = color2,
		Scale = 2,
		Duration = 0.49999999999999994,
		IgnoreParticles = true,
		isBlue = isBlue
	})
	local v5 = tick() + 0.49999999999999994
	local v6 = false
	local now = 0
	local v7 = false
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
		local v8 = (v5 - tick()) / 0.49999999999999994

		if v5 < tick() then
			renderSteppedConnection2:Disconnect()
			v6 = true
		end

		if instance == game.Players.LocalPlayer.Character and tick() - now > 0.03 then
			now = tick()
			Util.CameraShaker:ShakeOnce(4, 4, 0, 0.1)
		end

		local ray, v9, v10 = Util.Ray(
			cFrame.Position,
			cFrame.LookVector * 150,
			{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		)
		local v11 = ray and v9 or cFrame.Position + cFrame.LookVector * 150
		part2.Position = part2.Position:Lerp(v11, dt * 24)

		if ray and v10 then
			clone5.CFrame = CFrame.new(0, -10000, 0)
			clone6.Position = part2.Position
		else
			clone5.CFrame = CFrame.lookAt(part2.Position, part2.Position - cFrame.LookVector)
			clone6.Position = createVector(0, -10000, 0)
		end

		clone7.Position = part2.Position
		clone7.Size = createVector(1, 1, 1) * (math.sin((tick() - v5) * 3.141592653589793 * 24) * 25 + 50)
		clone7.Highlight.FillColor = color:Lerp(color2, math.cos((tick() - v5) * 3.141592653589793 * 8) ^ 2)
		local magnitude = (part2.Position - cFrame.Position).Magnitude
		clone4.CFrame = CFrame.lookAt(cFrame.Position, part2.Position) * CFrame.new(0, 0, -magnitude / 2)
		clone4.Size = Vector3.new(clone4.Size.X, clone4.Size.Y, magnitude)
		clone2.Beam.Width0 = 22 + v8 ^ 3 * 38 + math.sin((tick() - v5) * 3.141592653589793 * 12) * 8
		clone2.Beam.Width1 = 22 + v8 ^ 3 * 38 + math.cos((tick() - v5) * 3.141592653589793 * 12) * 8
		clone3.CFrame = cFrame

		if not v7 then
			v7 = true
			ParticleState(clone2, true)
		end
	end)

	repeat
		task.wait()
	until v6 == true

	if v3 then
		Util.Sound:FadeOut(v3, 0.2)
	end

	task.delay(ParticleState(clone3, false), clone3.Destroy, clone3)
	task.delay(ParticleState(clone4, false), clone4.Destroy, clone4)
	task.delay(ParticleState(clone5, false), clone5.Destroy, clone5)
	task.delay(ParticleState(clone6, false), clone6.Destroy, clone6)
	clone7:Destroy()
	local lastTime2 = tick()

	while tick() - lastTime2 < 0.15 do
		local v8 = (tick() - lastTime2) / 0.15
		clone2.Beam.Width0 = 20 * (1 - v8)
		clone2.Beam.Width1 = 20 * (1 - v8)
		task.wait()
	end

	if instance == game.Players.LocalPlayer.Character or (part2.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
		Util.CameraShaker:ShakeOnce(10, 14, 0.05, 1)
		local Effect2 = require(game.ReplicatedStorage.Effect)
		Effect2.new("ColorCorrection"):replicate({
			TintColor = Color3.fromRGB(126, 64, 64),
			Brightness = 1,
			Contrast = 1,
			Saturation = -1,
			FadeIn = 0,
			FadeOut = 0.3,
			Lifetime = 0
		})
	end

	folder.CFrame = part2.CFrame
	Util.Debris:AddItem(folder, 3)
	Util.Sound:Play("F_Explosion_NoDebris_01_V1", folder.Position)

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v8 = emitter
		task.spawn(function()
			if v8:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v8:GetAttribute("EmitDelay"))
			end

			local emitCount = v8:GetAttribute("EmitCount")

			if emitCount > 1 then
				emitCount = emitCount * 4 or emitCount
			end

			v8:Emit(emitCount)
		end)
	end

	local random2 = Random.new()
	local position = folder.Position
	local ray = Util.Ray
	local v8 = position + createVector(0, 1, 0)
	local v9 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local v10, v11, v12 = ray(v8, createVector(-0, -5, -0), v9)

	if v10 then
		local v13 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), createVector(0, 0, 1)) + v11, v12) + v12 * 0.01
		local clone8 = singularBeam.FloorSmudge:Clone()
		clone8.CFrame = v13 * CFrame.Angles(0, random2:NextNumber(-1, 1) * 3.141592653589793, 0)
		clone8.Attachment.ParticleEmitter.Size = NumberSequence.new(50)
		Util.SetParentOverrideWithColor(clone8, p2, p, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			p,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone8, function(_, p5)
				return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
			end)
		end

		local v14 = ParticleState(clone8) + 0.02
		Util.Debris:AddItem(clone8, v14 + 0.25)

		for i = 1, 12 do
			local v15 = i * 30
			local v16 = CFrame.new(v11, v11 + v12) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				math.rad(v15),
				0
			) * CFrame.new(0, 0, -12)
			local ray2, v17, v18 = Util.Ray(
				v16.Position,
				v16.upVector.Unit * -30,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if not ray2 then
				continue
			end

			local rock = Util.Rock2.new({
				FadeIn = { 0, 0.1 },
				Lifetime = math.random(10, 15) / 10,
				FadeOut = { 0.4, 0.5 },
				Size = Vector3.new(math.random(3, 6) * 0.7, 1.4, math.random(3, 6) * 0.7),
				Scale = { 1, 2 }
			})
			rock:Spawn(CFrame.new(v17, v17 + v18) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				math.rad(v15),
				0
			))

			if not (math.random(1, 100) <= 50) then
				continue
			end

			rock.Type = "Flying"
			rock:Eject({
				Velocity = (v16.UpVector * (workspace.Gravity / 2 + math.random(-20, 40)) + rock.Part.CFrame.lookVector * math.random(
					30,
					50
				)) * 0.7,
				RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
			})
		end
	end

	clone5.Weld:Destroy()
	clone2:Destroy()
	local clone8 = singularBeam.Disappear:Clone()
	clone8.Size = clone4.Size
	clone8.CFrame = clone4.CFrame
	Util.SetParentOverrideWithColor(clone8, p2, p, "PainFruitVFXColor")

	if areShiftedColorsEqual(
		p,
		"PainFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone8, function(_, p5)
			return applyColorShiftHSV2(p5, 0.41666667, 1.165137614678899, 1) or p5
		end)
	end

	task.delay(ParticleState(clone8), clone8.Destroy, clone8)
	renderSteppedConnection:Disconnect()
end