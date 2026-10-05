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

local script2 = script

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

return function(player)
	local player2 = player.player
	local state = player.State
	local character = player.Character
	local CF = player.CF
	local mouse = player.Mouse

	if state == "End" then
		return
	end

	local chargeAlpha = player.chargeAlpha
	local distance = player.distance
	local folder = Instance.new("Folder", workspace._WorldOrigin)
	task.delay(10, function()
		if folder then
			folder:Destroy()
		end
	end)
	local clone = script.FloorExplosion:Clone()
	Util.SetParentOverrideWithColor(clone, folder, player2, "KitsuneFruitVFXColor")
	local v = false

	local function triggerExplosionAt(position: Vector3, _: Vector3?)
		clone.CFrame = CFrame.new(position)
		Util.Debris:AddItem(clone, 3)
		Util.Sound:Play("KitsuneMutation_Explosion_01", position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				local emitDelay = v2:GetAttribute("EmitDelay") or 0

				if emitDelay ~= 0 then
					task.wait(emitDelay)
				end

				local emitCount = v2:GetAttribute("EmitCount") or 0

				if emitCount > 1 then
					emitCount = emitCount * 4 or emitCount
				end

				v2:Emit(emitCount)
			end)
		end

		local random2 = Random.new()
		local ray = Util.Ray
		local v2 = position + createVector(0, 1, 0)
		local v3 = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
		local v4, v5, v6 = ray(v2, createVector(-0, -5, -0), v3)

		if v4 then
			local v7 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), createVector(0, 0, 1)) + v5, v6) + v6 * 0.01
			local clone2 = script2.FloorSmudge:Clone()
			clone2.CFrame = v7 * CFrame.Angles(0, random2:NextNumber(-1, 1) * 3.141592653589793, 0)
			Util.SetParentOverrideWithColor(clone2, folder, player2, "KitsuneFruitVFXColor")

			if areShiftedColorsEqual(
				player2,
				"KitsuneFruitVFXColor",
				Color3.fromRGB(255, 252, 55),
				Color3.fromRGB(95, 95, 14),
				Color3.fromRGB(255, 255, 112)
			) then
				Util.AdjustObjectDescendantsColors(clone2, function(_, p)
					return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
				end)
			end

			for _, emitter in ipairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end

			Util.Debris:AddItem(clone2, 4)

			for i = 1, 12 do
				local v8 = i * 30
				local v9 = CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v8),
					0
				) * CFrame.new(0, 0, -12)
				local ray2, v10, v11 = Util.Ray(
					v9.Position,
					v9.upVector.Unit * -30,
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
				rock:Spawn(CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v8),
					0
				))

				if not (math.random(1, 100) <= 50) then
					continue
				end

				rock.Type = "Flying"
				rock:Eject({
					Velocity = (v9.UpVector * (workspace.Gravity / 2 + math.random(-20, 40)) + rock.Part.CFrame.lookVector * math.random(
						30,
						50
					)) * 0.7,
					RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
				})
			end
		end
	end

	local flag = false

	local function triggerImpactScreenFX(vector2: Vector3)
		if flag then
			return
		end

		flag = true

		if character == game.Players.LocalPlayer.Character or (vector2 - workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
			Util.CameraShaker:ShakeOnce(10, 14, 0.05, 1)
			local Effect2 = require(game.ReplicatedStorage.Effect)
			local colorCorrection = Effect2.new("ColorCorrection")
			local tintColor

			if player.Tool and player.Tool:FindFirstChild("IsGalaxy") and player.Tool:FindFirstChild("IsGalaxy").Value == false then
				tintColor = Color3.fromRGB(126, 64, 64)
			else
				tintColor = Color3.fromRGB(64, 64, 126)
			end

			colorCorrection:replicate({
				TintColor = tintColor,
				Brightness = 1,
				Contrast = 1,
				Saturation = -1,
				FadeIn = 0,
				FadeOut = 0.3,
				Lifetime = 0
			})
		end
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local v2 = CF * CFrame.new(0, 0, -3)
	local v3

	if player.transformed == true then
		v3 = CFrame.new(0, 5, -12)
	else
		v3 = CFrame.new()
	end

	local cFrame = v2 * v3
	local clone2 = script2.Start:Clone()
	clone2.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone2, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone2, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	task.delay(ParticleState(clone2), clone2.Destroy, clone2)
	task.wait(0.2)
	local lastTime = os.clock()
	local v5 = {}

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function easeOutQuad(p)
		return 1 - (1 - p) * (1 - p)
	end

	local function spawnShockwave(p)
		local clone3 = script2.Shockwave:Clone()
		Util.SetParentOverrideWithColor(clone3, folder, player2, "KitsuneFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"KitsuneFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone3, function(_, p2)
				return applyColorShiftHSV2(p2, 0.41666667, 1.165137614678899, 1) or p2
			end)
		end

		local number = random:NextNumber(0, 6.283185307179586)
		clone3.CFrame = p * CFrame.Angles(1.5707963267948966, number, 3.141592653589793)
		local mesh = clone3.Mesh
		table.insert(v5, {
			p = clone3,
			mesh = mesh,
			yaw = number,
			age = 0,
			life = 0.1
		})
	end

	local clone3 = script2.Beam:Clone()
	clone3.CFrame = cFrame
	clone3.Part2.CFrame = cFrame
	ParticleState(clone3, false)
	local charRedKitsuneZLoop, flag2

	if player.duration > 0.21 then
		charRedKitsuneZLoop = Util.Anims:Get(character, "CharRedKitsuneZLoop")
		charRedKitsuneZLoop.Priority = Enum.AnimationPriority.Action4
		charRedKitsuneZLoop:Play()
		flag2 = false
	else
		flag2 = true
	end

	if flag2 then
		Util.Sound:Play("KitsuneMutation_Beam_TapFire_0" .. tostring(math.random(1, 3)), humanoidRootPart)
	else
		Util.Sound:Play("KitsuneMutation_Beam_HoldFire_01", humanoidRootPart)
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local cframe

		if chargeAlpha >= 1 then
			cframe = CFrame.lookAt(humanoidRootPart.Position, mouse.Value)
		else
			cframe = CF
		end

		local v6

		if player.transformed == true then
			v6 = CFrame.new(0, 5, -12)
		else
			v6 = CFrame.new()
		end

		local v7 = cframe * v6
		local v8 = 1 - math.exp(-20 * dt)
		cFrame = cFrame:Lerp(v7, v8)
		clone3.Attachment.WorldCFrame = clone3.Attachment.CFrame.Rotation + v7.Position

		if os.clock() - lastTime >= 0.08 then
			lastTime = os.clock()
			spawnShockwave(cFrame)
		end

		for i = #v5, 1, -1 do
			local v9 = v5[i]
			v9.age += dt
			local v11 = easeOutQuad(math.clamp(v9.age / v9.life, 0, 1))
			local v12 = 90 * v11
			local v13 = 150 * v11
			v9.p.CFrame = cFrame * CFrame.Angles(1.5707963267948966, v9.yaw, 3.141592653589793) * CFrame.new(0, v12, 0)
			v9.mesh.Scale = Vector3.new(0, v13, 0)

			if not (v9.age >= v9.life) then
				continue
			end

			v9.p:Destroy()
			table.remove(v5, i)
		end
	end)
	local clone4 = script2.StartAura:Clone()
	clone4.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone4, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone4, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	local part2 = clone3.Part2
	part2.CFrame = clone3.CFrame
	Util.SetParentOverrideWithColor(clone3, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone3, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	local clone5 = script2.BeamParticles:Clone()
	clone5.CFrame = clone3.CFrame
	clone5.Size *= createVector(3, 3, 0)
	Util.SetParentOverrideWithColor(clone5, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone5, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	local clone6 = script2.End:Clone()
	clone6.CFrame = part2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	Util.SetParentOverrideWithColor(clone6, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone6, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	local clone7 = script2.EndTip:Clone()
	clone7.CFrame = part2.CFrame
	Util.SetParentOverrideWithColor(clone7, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone7, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	for _, emitter in pairs(clone7:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(1)
		emitter.Rate *= 2
	end

	local clone8 = script2.Distortion:Clone()
	clone8.CFrame = part2.CFrame
	local color

	if player.Tool and player.Tool:FindFirstChild("IsGalaxy") and player.Tool:FindFirstChild("IsGalaxy").Value == false then
		color = Color3.fromRGB(113, 15, 36)
	else
		color = Color3.fromRGB(85, 0, 255)
	end

	local color2

	if player.Tool and player.Tool:FindFirstChild("IsGalaxy") and player.Tool:FindFirstChild("IsGalaxy").Value == false then
		color2 = Color3.fromRGB(241, 76, 81)
	else
		color2 = Color3.fromRGB(85, 0, 255)
	end

	local duration = player.duration
	local isBlue = areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) and true or nil
	local v8 = {
		Root = part2,
		Color = color,
		Scale = 4,
		Duration = duration,
		IgnoreParticles = true,
		isBlue = isBlue,
		colorOverride = 0
	}
	local colorOverride

	if player.Tool and player.Tool:FindFirstChild("IsGalaxy") and player.Tool:FindFirstChild("IsGalaxy").Value == true then
		colorOverride = Color3.fromRGB(85, 0, 255)
	end

	v8.colorOverride = colorOverride
	superhumanV2Travel:replicate(v8)
	local v11 = {
		Root = part2,
		Color = color2,
		Scale = 2,
		Duration = duration,
		IgnoreParticles = true,
		isBlue = isBlue,
		colorOverride = 0
	}
	local colorOverride2

	if player.Tool and player.Tool:FindFirstChild("IsGalaxy") and player.Tool:FindFirstChild("IsGalaxy").Value == true then
		colorOverride2 = Color3.fromRGB(85, 0, 255)
	end

	v11.colorOverride = colorOverride2
	superhumanV2Travel:replicate(v11)
	local v13 = tick() + duration
	local v14 = false
	local now = 0
	local v15 = false
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
		local v16 = (v13 - tick()) / duration

		if v13 < tick() then
			task.spawn(function()
				if not v then
					v = true
					local position = cFrame.Position + cFrame.LookVector * distance
					part2.Position = position
					task.spawn(function()
						triggerExplosionAt(position, nil)
						task.spawn(function()
							triggerImpactScreenFX(position)
						end)
					end)
				end
			end)
			renderSteppedConnection2:Disconnect()
			v14 = true
		else
			if character == game.Players.LocalPlayer.Character and tick() - now > 0.03 then
				now = tick()
				Util.CameraShaker:ShakeOnce(4, 4, 0, 0.1)
			end

			local ray, position, v18 = Util.Ray(
				cFrame.Position,
				cFrame.LookVector * distance,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			local v19 = ray and position or cFrame.Position + cFrame.LookVector * distance

			if ray and not v then
				v = true
				part2.Position = position
				task.spawn(function()
					triggerExplosionAt(position, v18)
				end)
				triggerImpactScreenFX(position)
			end

			part2.Position = part2.Position:Lerp(v19, dt * 24)

			if ray and v18 then
				clone6.CFrame = CFrame.new(0, -10000, 0)
				clone7.CFrame = CFrame.new(part2.Position)
			else
				clone6.CFrame = CFrame.lookAt(part2.Position, part2.Position - cFrame.LookVector)
				clone7.CFrame = CFrame.new(0, -10000, 0)
			end

			clone8.Position = part2.Position
			clone8.Size = createVector(1, 1, 1) * (math.sin((tick() - v13) * 3.141592653589793 * 24) * 25 + 50)
			local magnitude = (part2.Position - cFrame.Position).Magnitude
			clone5.CFrame = CFrame.lookAt(cFrame.Position, part2.Position) * CFrame.new(0, 0, -magnitude / 2)
			clone5.Size = Vector3.new(clone5.Size.X, clone5.Size.Y, magnitude)

			for _, beam in ipairs(clone3:GetChildren()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Width0 = 22 + v16 ^ 3 * 38 + math.sin((tick() - v13) * 3.141592653589793 * 12) * 8
				beam.Width1 = 22 + v16 ^ 3 * 38 + math.cos((tick() - v13) * 3.141592653589793 * 12) * 8
			end

			clone4.CFrame = cFrame

			if not v15 then
				v15 = true
				ParticleState(clone3, true)
			end
		end
	end)

	repeat
		task.wait()
	until v14 == true

	if not flag2 and character == game.Players.LocalPlayer.Character then
		Util.CameraShaker:ShakeOnce(7, 11, 0.05, 1)
	end

	if charRedKitsuneZLoop then
		charRedKitsuneZLoop:Stop()
	end

	task.delay(ParticleState(clone4, false), clone4.Destroy, clone4)
	task.delay(ParticleState(clone5, false), clone5.Destroy, clone5)
	task.delay(ParticleState(clone6, false), clone6.Destroy, clone6)
	task.delay(ParticleState(clone7, false), clone7.Destroy, clone7)
	clone8:Destroy()
	task.spawn(function()
		local lastTime2 = tick()

		while tick() - lastTime2 < 0.15 do
			local v16 = (tick() - lastTime2) / 0.15

			for _, beam in pairs(clone3:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Width0 = 20 * (1 - v16)
				beam.Width1 = 20 * (1 - v16)
			end

			task.wait()
		end
	end)
	task.wait(0.1)
	clone6.Weld:Destroy()
	clone3:Destroy()
	local clone9 = script2.Disappear:Clone()
	clone9.Size = clone5.Size
	clone9.CFrame = clone5.CFrame
	Util.SetParentOverrideWithColor(clone9, folder, player2, "KitsuneFruitVFXColor")

	if areShiftedColorsEqual(
		player2,
		"KitsuneFruitVFXColor",
		Color3.fromRGB(255, 252, 55),
		Color3.fromRGB(95, 95, 14),
		Color3.fromRGB(255, 255, 112)
	) then
		Util.AdjustObjectDescendantsColors(clone9, function(_, p)
			return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
		end)
	end

	task.delay(ParticleState(clone9), clone9.Destroy, clone9)
	task.spawn(function()
		local clone10 = script2.Explosion:Clone()
		clone10.Size = clone5.Size * 0.8
		clone10.CFrame = clone5.CFrame * CFrame.new(0, 0, -clone5.Size.Z * 0.3)
		Util.SetParentOverrideWithColor(clone10, folder, player2, "KitsuneFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"KitsuneFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone10, function(_, p)
				return applyColorShiftHSV2(p, 0.41666667, 1.165137614678899, 1) or p
			end)
		end

		task.delay(ParticleState(clone10), clone10.Destroy, clone10)
	end)
	renderSteppedConnection:Disconnect()
end