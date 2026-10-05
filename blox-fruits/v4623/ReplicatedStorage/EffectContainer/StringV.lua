local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage.Util)
local Effect = require(ReplicatedStorage.Effect)
local shakeCam = Effect.new("ShakeCam")
TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local _WorldOrigin = workspace._WorldOrigin
local debris = Util.Debris
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Map }
local currentCamera = workspace.CurrentCamera
local color = Color3.fromRGB(15, 11, 27)
return function(player)
	local origin = player.Origin
	local buso = player.Buso
	local color2

	if buso then
		color2 = buso.Color:Lerp(Color3.new(), 0.75)
	else
		color2 = Color3.new(1, 0, 0):Lerp(Color3.new(), 0.75)
	end

	if color2 then
		color = color2:Lerp(Color3.new(), 0.75)
	end

	if (origin.p - currentCamera.CFrame.p).magnitude > 1500 then
		return
	end

	local clone = script.widnpartic:Clone()
	clone.CFrame = player.Origin * CFrame.new(0, 0, -2) * CFrame.Angles(0, -3.141592653589793, -3.141592653589793)
	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if color2 then
			emitter.Color = Util.Misc.SwapColorInKeypoints(emitter.Color, Color3.fromRGB(76, 0, 76), color2)
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	local v2 = math.clamp(1 - (currentCamera.CFrame.p - origin.p).Magnitude / 300, 0, 1)

	if v2 > 0 then
		shakeCam:replicate({
			Preset = "Bump",
			Power = v2 * 1.4
		})
	end

	debris:AddItem(clone, 3)
	task.wait(0.2)
	coroutine.wrap(function()
		for _ = 1, 4 do
			local clone2 = script.Ring1:Clone()
			clone2.CFrame = player.Origin * CFrame.new(0, 0, -2.5) * CFrame.Angles(
				1.5707963267948966,
				-3.141592653589793,
				0
			)
			clone2.Parent = _WorldOrigin
			TweenService:Create(clone2, tweenInfo, {
				Size = createVector(45.687, 0.942, 45.687),
				Transparency = 1
			}):Play()
			debris:AddItem(clone2, 2)
			wait(0.2)
		end
	end)()
	local colorCorrectionEffect = nil

	if player.Character and game.Players.LocalPlayer.Character == player.Character then
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Parent = game.Lighting
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
			Brightness = 0.5,
			TintColor = color:Lerp(Color3.new(1, 1, 1), 0.3)
		}):Play()
		task.delay(0.2, function()
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
				Brightness = 0,
				TintColor = Color3.new(1, 1, 1)
			}):Play()
			debris:AddItem(colorCorrectionEffect, 2)
		end)
	end

	local clone2 = script.FireGround:Clone()
	clone2.CFrame = player.Origin * CFrame.new(0, 0, -14.5) * CFrame.Angles(-1.5707963267948966, -3.141592653589793, 0)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and color2 then
			emitter.Color = Util.Misc.SwapColorInKeypoints(emitter.Color, Color3.fromRGB(76, 0, 76), color2)
		end
	end

	clone2.PointLight.Color = color2
	clone2.Parent = _WorldOrigin
	debris:AddItem(clone2, 3.5)
	TweenService:Create(clone2.PointLight, tweenInfo, {
		Range = 0,
		Brightness = 0
	}):Play()
	Util.Sound:Play("String.StringVIgnite", clone2)
	task.delay(0.9, function()
		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local v3 = math.clamp(1 - (currentCamera.CFrame.p - origin.p).Magnitude / 400, 0, 1)

	if v3 > 0 then
		shakeCam:replicate({
			Preset = "Explosion",
			Power = v3 * 1.5
		})
	end

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function f(p)
		return p ^ 0.5 * 2 / (p ^ p + 1)
	end

	local v4 = {}
	table.insert(v4, -0.037500000000000006)
	table.insert(v4, 0.04999999999999999)
	table.insert(v4, 0.13749999999999996)
	table.insert(v4, 0.22499999999999998)
	table.insert(v4, 0.3125)
	table.insert(v4, 0.3999999999999999)
	table.insert(v4, 0.48749999999999993)
	table.insert(v4, 0.575)
	local v5 = {}

	for i = 1, 360, 45 do
		local v6 = #v5 + 1
		v5[v6] = {}
		local v7 = i
		spawn(function()
			local v9 = math.random(1, #v4)
			local v10 = v4[v9]
			table.remove(v4, v9)
			wait(v10)
			Util.Sound:Play("WhipStrong", origin)
			local v11 = nil
			local v12 = nil

			for i2 = 0, 7.5, 0.5 do
				local v13 = (i2 / 7.5) ^ 0.5
				local v14 = f(i2)
				local v16 = f(i2 + 0.5)
				local v17 = origin * CFrame.Angles(0, 0, (math.rad(v7))) * CFrame.new(0, 5, 0)
				local v18 = v17 * (Vector3.new(0, v14, -i2) * 15)
				local v19 = v17 * (Vector3.new(0, v16, -(i2 + 0.5)) * 15)
				local magnitude = (v18 - v19).magnitude
				local part = Instance.new("Part")
				part.CanCollide = false
				part.Anchored = true
				part.Color = Color3.new(1, 1, 1)
				part.TopSurface = 0
				part.BottomSurface = 0
				part.Material = "Neon"
				part.Size = createVector(0.05, 0.05, 0.05)
				part.CFrame = CFrame.new(v18, v19) * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, i2 / 2)
				part.Parent = _WorldOrigin
				local clone3 = script.Glow:Clone()
				clone3.Parent = part
				task.delay(0.3, function()
					clone3.Enabled = false
				end)
				local tween = TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
					Color = color2 and color2 or Color3.new(0.298039, 0, 0.298039)
				})

				if i2 == 7.5 then
					tween.Completed:Connect(function()
						v11 = true
					end)
					v12 = tween
				end

				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
					CFrame = CFrame.new(v18, v19) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, 0, i2 / 2),
					Size = Vector3.new((1 - v13 * 0.9) * 2, (1 - v13 * 0.9) * 2, magnitude)
				}):Play()
				tween:Play()
				table.insert(v5[v6], part)
				wait()
			end

			if not v11 then
				v12.Completed:Wait()
			end

			wait(0.2)

			for k, v13 in next, v5[v6], nil do
				local tween = TweenService:Create(
					v13,
					TweenInfo.new(v13.Size.X / 2 * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Size = v13.Size * createVector(0, 0, 1)
					}
				)
				local v14 = v13
				tween.Completed:Connect(function()
					v14:Destroy()
				end)
				tween:Play()
			end
		end)
	end
end