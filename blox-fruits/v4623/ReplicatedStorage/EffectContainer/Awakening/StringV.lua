local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

function cubicBezier(p, p2, p3, p4, p5)
	local lerped = p2:Lerp(p3, p)
	local lerped2 = p3:Lerp(p4, p)
	local lerped3 = p4:Lerp(p5, p)
	return lerped:Lerp(lerped2, p):Lerp(lerped2:Lerp(lerped3, p), p)
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function threadImpact(_, p, p2, p3)
	local clone = FX:WaitForChild("StringEffects").ThreadUltImpact:Clone()
	Util.Debris:AddItem(clone, 5)
	local shockwave = clone.Shockwave
	local wind = clone.Wind
	clone:SetPrimaryPartCFrame(CFrame.new(p, p + p2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0))

	for _, child in pairs(clone:GetChildren()) do
		child.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	end

	shockwave.Size = createVector(0.1, 20, 0.1)
	shockwave.CFrame *= CFrame.new(0, 10, 0)
	local v = math.random(65, 70)
	local tween = TweenService:Create(
		shockwave,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = Vector3.new(v, 4, v),
			CFrame = shockwave.CFrame * CFrame.new(0, -7, 0) * CFrame.Angles(0, -3.12413936106985, 0),
			Color = p3 and p3.Color:Lerp(Color3.new(), 0.3) or Color3.fromRGB(48, 0, 83),
			Transparency = 1
		}
	)
	local tween2 = TweenService:Create(
		wind,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(50, 50, 50),
			CFrame = wind.CFrame * CFrame.Angles(0, 3.12413936106985, 0),
			Color = p3 and p3.Color:Lerp(Color3.new(1, 1, 1), 0.3) or Color3.fromRGB(103, 97, 135),
			Transparency = 1
		}
	)
	clone.Parent = _WorldOrigin
	tween:Play()
	tween2:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	Util.Sound:Play("Wallhit2", shockwave.Position, nil, 1.2 + math.random(-22, 22) / 100, 1)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - p).magnitude <= 15 then
		Util.CameraShaker:ShakeOnce(5, 15, 0.1, 0.5)
	end
end

local function threadExplosion(_, p, p2, smoke, p3)
	local clone = FX:WaitForChild("StringEffects").ThreadUltExplosion:Clone()
	Util.Debris:AddItem(clone, 12)
	local attachment = Instance.new("Attachment")
	attachment.Parent = clone.Origin

	for _ = 0, math.random(4, 8) do
		local clone2 = FX:WaitForChild("StringEffects").ExplosionSpikeBeam:Clone()

		if p3 then
			clone2.Color = Util.Misc.SwapColorInKeypoints(
				clone2.Color.Keypoints,
				Color3.fromRGB(63, 39, 66),
				p3.Color:Lerp(Color3.new(), 0.5)
			)
		end

		clone2.Parent = attachment
		clone2.Attachment0 = attachment
		clone2.Width0 = 6
		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = clone.Origin
		clone2.Attachment1 = attachment2
		TweenService:Create(
			attachment2,
			TweenInfo.new(math.random(1, 2) / 10, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true, 0),
			{
				Position = Vector3.new(math.random(-40, 40), math.random(20, 40), math.random(-40, 40))
			}
		):Play()
	end

	local cloudShell = clone.CloudShell
	local shockwave = clone.Shockwave
	local shockwaveBillboard = clone.ShockwaveBillboard
	local imageLabel = shockwaveBillboard.ImageLabel
	imageLabel.Rotation = math.random(-180, 180)
	clone:SetPrimaryPartCFrame(CFrame.new(p, p + p2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0))

	for _, part in pairs(clone:GetChildren()) do
		if part:IsA("BasePart") then
			part.CFrame *= CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
		end
	end

	if p3 then
		shockwave.Color = p3.Color:Lerp(Color3.new(), 0.5)
		cloudShell.Color = p3.Color:Lerp(Color3.new(1, 1, 1), 0.5)
		imageLabel.ImageColor3 = p3.Color:Lerp(Color3.new(), 0.15)
	end

	shockwave.Size = createVector(0.1, 20, 0.1)
	shockwave.CFrame *= CFrame.new(0, 10, 0)
	local v = math.random(80, 100)
	local v2 = math.random(250, 300)
	local cframe = CFrame.Angles(
		math.rad((math.random(-30, 30))),
		math.rad((math.random(-90, 90))),
		(math.rad((math.random(-30, 30))))
	)
	local tween = TweenService:Create(
		cloudShell,
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = Vector3.new(v, v, v),
			CFrame = cloudShell.CFrame * CFrame.new(0, 2, 0) * cframe,
			Color = Color3.fromRGB(141, 141, 141),
			Transparency = 1
		}
	)
	local tween2 = TweenService:Create(
		shockwave,
		TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(90, 3, 90),
			CFrame = shockwave.CFrame * CFrame.Angles(
				math.rad((math.random(-20, 20))),
				3.12413936106985,
				(math.rad((math.random(-20, 20))))
			),
			Color = p3 and p3.Color:Lerp(Color3.new(), 0.15) or Color3.fromRGB(44, 0, 83),
			Transparency = 1
		}
	)
	local tween3 = TweenService:Create(
		shockwaveBillboard,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = UDim2.new(v2, 0, v2, 0)
		}
	)
	local tween4 = TweenService:Create(
		imageLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			ImageTransparency = 1,
			ImageColor3 = p3 and p3.Color:Lerp(Color3.new(1, 1, 1), 0.5) or Color3.fromRGB(159, 139, 199)
		}
	)
	clone.Parent = _WorldOrigin

	if smoke == true then
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	else
		cloudShell:Destroy()
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
	end

	tween2:Play()
	tween3:Play()
	tween4:Play()
	Util.Sound:Play("Explosion2", shockwave.Position, nil, 1.2 + math.random(-25, 35) / 100, 0.5)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil and (character:FindFirstChild("HumanoidRootPart").Position - p).magnitude <= 25 then
		Util.CameraShaker:ShakeOnce(10, 15, 0.1, 0.5)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function crossEffect(position, _)
	spawn(function()
		local clone = FX:WaitForChild("StringEffects").ThreadCrossEffect:Clone()
		clone:SetPrimaryPartCFrame(CFrame.new(position))
		local v = { clone.CrossHorizontal, clone.CrossHorizontal.Adornment }
		local v2 = { clone.CrossVertical, clone.CrossVertical.Adornment }
		clone.Parent = _WorldOrigin
		Util.Debris:AddItem(clone, 3)
		local tween = TweenService:Create(
			v2[2],
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector2.new(0, 0)
			}
		)
		local tween2 = TweenService:Create(
			v[2],
			TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
			{
				Transparency = 1,
				Size = Vector2.new(0, 0)
			}
		)
		tween:Play()
		tween2:Play()
		local total = 0
		local lastTime = tick()
		local v3 = CFrame.new(position, workspace.CurrentCamera.CFrame.p) * CFrame.Angles(0, 0, (math.rad(total)))

		while tick() - lastTime < 0.5 do
			local v4 = (tick() - lastTime) / 0.5
			RunService.RenderStepped:Wait()
			total += 2
			v3 = v3:Lerp(
				CFrame.new(position, workspace.CurrentCamera.CFrame.p) * CFrame.Angles(0, 0, (math.rad(total))),
				v4
			)
			clone:SetPrimaryPartCFrame(v3)
		end

		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function holyThread(data, p, value, p2)
	spawn(function()
		local rootCF = data.RootCF
		local shockwaveCF = data.ShockwaveCF or nil
		local smoke = data.Smoke
		local character = game.Players.LocalPlayer.Character

		if character ~= nil and character:FindFirstChild("HumanoidRootPart") and (character:FindFirstChild("HumanoidRootPart").Position - rootCF.p).magnitude <= 15 then
			Util.CameraShaker:ShakeOnce(1, 1, 0.15, 0.15)
		end

		if shockwaveCF == nil then
			local clone = FX:WaitForChild("StringEffects").ThreadUltModel:Clone()

			for _, beam in pairs(clone:GetChildren()) do
				if beam:IsA("Beam") and p2 then
					beam.Color = Util.Misc.SwapColorInKeypoints(
						beam.Color.Keypoints,
						Color3.fromRGB(127, 29, 128),
						p2.Color:Lerp(Color3.new(), 0.2)
					)
				end
			end

			Util.Debris:AddItem(clone, 5)
			local clone2 = FX:WaitForChild("StringEffects").ThreadUltTrail:Clone()

			for _, effect in pairs(clone2:GetChildren()) do
				if (effect:IsA("Trail") or effect:IsA("ParticleEmitter")) and p2 then
					effect.Color = Util.Misc.SwapColorInKeypoints(
						effect.Color.Keypoints,
						Color3.fromRGB(53, 41, 66),
						p2.Color:Lerp(Color3.new(), 0.7)
					)
				end
			end

			Util.Debris:AddItem(clone2, 5)
			local smoke2 = clone2.Smoke
			local startPart = clone:WaitForChild("StartPart")
			local endPart = clone:WaitForChild("EndPart")
			local stringCore = clone:WaitForChild("StringCore")
			local stringGlow = clone:WaitForChild("StringGlow")
			local clone3 = FX:WaitForChild("StringEffects").ThreadUltSpawn:Clone()

			if p2 then
				clone3.Color = Util.Misc.SwapColorInKeypoints(
					clone3.Color.Keypoints,
					Color3.fromRGB(53, 47, 75),
					p2.Color:Lerp(Color3.new(), 0.7)
				)
			end

			clone3.Parent = startPart
			local v = {}
			table.insert(v, stringCore)
			table.insert(v, stringGlow)
			local v2 = math.random(50, 65)

			for _, v3 in pairs(v) do
				v3.CurveSize0 = 0
			end

			local cFrame2 = rootCF * CFrame.new(0, 0, 3)
			local v4 = rootCF * CFrame.new(0, value or 30, 0)
			local v5 = rootCF * CFrame.new(0, 2, -15)
			local v6 = rootCF * CFrame.new(0, -3, -400)
			startPart.CFrame = cFrame2 * CFrame.Angles(0.5235987755982988, 0, 0)
			endPart.CFrame = cFrame2
			clone2.CFrame = cFrame2
			clone.Parent = _WorldOrigin
			clone2.Parent = _WorldOrigin
			clone3:Emit(1)

			if p then
				Util.Sound:Play("BigBangAttackFire", startPart.Position, nil, 1.5 + math.random(-22, 22) / 100, 0.3)
			end

			local lastTime = tick()
			local position = endPart.Position
			local v7 = {
				math.random(10, 15),
				math.random(10, 15),
				-math.random(2, 4),
				-math.random(25, 30)
			}
			local lastTime2 = tick()
			local total = 0
			local total2 = 0
			local count = 0

			while tick() - lastTime2 < 0.25 do
				local v8 = (tick() - lastTime2) / 0.25
				local cFrame3 = cubicBezier(v8, cFrame2, v4, v5, v6)
				local v10 = cubicBezier(
					v8,
					cFrame2,
					v4 * CFrame.new(0, v7[1], v7[2]),
					v5 * CFrame.new(0, v7[3], v7[4]),
					CFrame.new(v6.p, cFrame2.p) * CFrame.new(0, 0, -40)
				)
				endPart.CFrame = cFrame3
				clone2.CFrame = CFrame.new((v10 * CFrame.new(0, 0, 2)).p, v6.p) * CFrame.Angles(0, math.rad(total), 0)

				for _, v11 in pairs(v) do
					local curveSize0 = v11.CurveSize0
					v11.CurveSize0 = curveSize0 + (v2 - curveSize0) * 0.05
				end

				total2 += (1 - total2) * 0.05

				for _, attachment in pairs(clone2:GetChildren()) do
					if attachment:IsA("Attachment") then
						attachment.Position = attachment.Position:Lerp(createVector(0, 0, 0), 0.03)
					end
				end

				clone2.LTrail.Transparency = NumberSequence.new(total2)
				clone2.RTrail.Transparency = NumberSequence.new(total2)
				total += 30
				smoke2:Emit(1)

				if p then
					local magnitude = (position - endPart.Position).magnitude
					local ray, v11, v12 = Util.Ray(
						endPart.CFrame.p,
						endPart.CFrame.lookVector.Unit * magnitude,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray and tick() - lastTime > 0.01 then
						lastTime = tick()

						if count > 0 then
							threadImpact(ray, v11, v12, p2)
						else
							threadImpact(ray, v11, v12, p2)
							threadExplosion(ray, v11, v12, smoke, p2)
						end

						count += 1
					end

					position = endPart.Position
				end

				RunService.RenderStepped:Wait()
			end

			local cFrame = startPart.CFrame
			local color = p2 and p2.Color or Color3.fromRGB(124, 116, 135)
			local v8 = p2 and p2.Color:Lerp(Color3.new(), 0.15) or Color3.fromRGB(55, 48, 77)
			local lastTime3 = tick()

			while tick() - lastTime3 < 0.25 do
				local v9 = (tick() - lastTime3) / 0.25
				startPart.CFrame = cFrame:Lerp(cFrame * CFrame.Angles(-0.5235987755982988, 0, 0), v9)
				local v10 = 0 + 1 * v9
				local v11 = 0 + 1 * v9
				color = color:Lerp(v8, v9 + 0.2)
				stringCore.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color),
					ColorSequenceKeypoint.new(math.clamp(v11 - 0.01, 0, 1), color),
					ColorSequenceKeypoint.new(math.clamp(v11 + 0.01, 0, 1), color),
					ColorSequenceKeypoint.new(1, color)
				})

				for _, v12 in pairs(v) do
					v12.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(math.clamp(v11 - 0.2, 0, 1), 1),
						NumberSequenceKeypoint.new(math.clamp(v11 + 0.2, 0, 1), v10),
						NumberSequenceKeypoint.new(1, v10)
					})
					local width0 = v12.Width0
					v12.Width0 = width0 + (1 - width0) * v9
				end

				RunService.RenderStepped:Wait()
			end

			clone:Destroy()
		else
			local clone = FX:WaitForChild("StringEffects").ThreadUltStart:Clone()
			Util.Debris:AddItem(clone, 5)
			clone.CFrame = shockwaveCF * CFrame.new(0, 0, 2)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and p2 then
					emitter.Color = Util.Misc.SwapColorInKeypoints(
						emitter.Color.Keypoints,
						Color3.fromRGB(74, 0, 200),
						p2.Color:Lerp(Color3.new(), 0.3)
					)
				end
			end

			clone.Parent = _WorldOrigin

			if p then
				Util.Sound:Play("SpiritCharge", clone.Position, nil, 6.75 + math.random(-12, 12) / 100, 0.3)
				Util.Sound:Play("Charge Init", clone.Position, nil, 2 + math.random(-12, 12) / 100, 1)
			end

			local shockwaveBillboard = clone.ShockwaveBillboard
			local imageLabel = shockwaveBillboard.ImageLabel
			local tween = TweenService:Create(
				shockwaveBillboard,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = UDim2.new(1, 0, 1, 0)
				}
			)
			local tween2 = TweenService:Create(
				imageLabel,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					ImageTransparency = 1,
					ImageColor3 = Color3.fromRGB(0, 0, 0)
				}
			)
			tween.Completed:Connect(function()
				shockwaveBillboard:Destroy()
			end)
			tween2:Play()
			tween:Play()
			crossEffect((shockwaveCF * CFrame.new(-5, 3, 0)).p) -- equivalent call inferred; original call site unknown
			crossEffect((shockwaveCF * CFrame.new(5, 3, 0)).p) -- equivalent call inferred; original call site unknown
			local clone2 = FX:WaitForChild("StringEffects").ThreadUltShockwave:Clone()
			Util.Debris:AddItem(clone2, 5)
			clone2.CFrame = shockwaveCF * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
			clone2.Size = createVector(0.1, 0.1, 0.1)
			clone2.Parent = _WorldOrigin
			local tween3 = TweenService:Create(
				clone2,
				TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					Size = createVector(64.264, 2.989, 68.19),
					CFrame = clone2.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
				}
			)
			tween3:Play()
			tween3.Completed:Connect(function()
				clone2:Destroy()
			end)
		end
	end)
end

return function(data)
	local _ = data.TimeStamp
	local rootPart = data.RootPart
	local hum = data.Hum or nil
	local castDelay = data.CastDelay or 0.08
	local holdValue = data.HoldValue
	local mouseP = data.MouseP
	local buso = data.Buso or {
		Color = Color3.new(1, 0, 0):Lerp(Color3.new(), 0.6)
	}

	if rootPart ~= nil and holdValue ~= nil then
		if (rootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local v = true

		if hum then
			hum.Died:Connect(function()
				v = false
			end)
		else
			v = false
		end

		local flag = false
		local v2 = 2
		local ray, _, _ = Util.Ray(
			rootPart.Position,
			-CFrame.new(rootPart.Position).upVector.Unit * 5,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local lastTime = tick()

		local function running()
			return tick() - lastTime < 0.5 or v and data.HoldValue and data.HoldValue.Value == true
		end

		spawn(function()
			local clone = FX:WaitForChild("StringEffects").ThreadUltSpinner:Clone()
			Util.Debris:AddItem(clone, 10)
			local v3 = {}
			local keypointsByChild = {}

			for _, child in pairs(clone:GetChildren()) do
				if child:IsA("Attachment") then
					table.insert(v3, { child, child.Position })
					child.Position *= 3
				elseif (child:IsA("Trail") or child:IsA("ParticleEmitter")) and buso then
					keypointsByChild[child] = child.Color.Keypoints
					child.Color = Util.Misc.SwapColorInKeypoints(
						keypointsByChild[child],
						Color3.fromRGB(60, 37, 116),
						buso.Color:Lerp(Color3.new(), 0.25)
					)
				end
			end

			local rays = clone.Rays
			clone.CFrame = CFrame.new((rootPart.CFrame * CFrame.new(0, 0, -3)).p, mouseP) * CFrame.Angles(0, 0, 0)
			clone.Parent = _WorldOrigin
			local total = 1

			while (tick() - lastTime < 0.5 or v and data.HoldValue and data.HoldValue.Value == true) and rootPart ~= nil and data.HoldValue.Parent ~= nil and data.HoldValue.Parent.Parent ~= nil do
				RunService.RenderStepped:Wait()
				rays:Emit(1)
				total += (20 - total) * 0.05
				clone.CFrame *= CFrame.Angles(0, 0, (math.rad(total)))

				for k, v4 in pairs(keypointsByChild) do
					k.Color = Util.Misc.SwapColorInKeypoints(
						v4,
						Color3.fromRGB(60, 37, 116),
						buso.Color:Lerp(Color3.new(), 0.25)
					)
				end

				for _, v4 in pairs(v3) do
					local v5 = v4[1]
					local position = v4[1].Position
					v5.Position = position + (v4[2] - position) * 0.025
				end
			end
		end)
		local values = nil

		local function adjustColors()
			if not (values and buso) then
				return
			end

			local lerped = buso.Color:Lerp(Color3.new(), 0.725)

			for k, v3 in pairs(values) do
				k.Color = Util.Misc.SwapColorInKeypoints(k.Color, v3, lerped)
				values[k] = lerped
			end
		end

		local clone = script.FireGround:Clone()
		local descendants = clone:GetDescendants()
		task.delay(0.25, function()
			local v3

			if buso then
				v3 = buso.Color:Lerp(Color3.new(), 0.725)
			else
				v3 = Color3.new(1, 0, 0):Lerp(Color3.new(), 0.725)
			end

			clone.CFrame = CFrame.new(rootPart.Position, mouseP) * CFrame.new(0, 0, -18) * CFrame.Angles(
				-1.5707963267948966,
				-3.141592653589793,
				0
			)
			values = {}

			for _, emitter in pairs(descendants) do
				if not (emitter:IsA("ParticleEmitter") and v3) then
					continue
				end

				emitter.Color = Util.Misc.SwapColorInKeypoints(emitter.Color, Color3.fromRGB(76, 0, 76), v3)
				values[emitter] = v3
			end

			clone.Parent = workspace._WorldOrigin
			Util.Sound:Play("String.StringVIgnite", clone)
		end)
		local count = 0

		while (tick() - lastTime < 0.5 or v and data.HoldValue and data.HoldValue.Value == true) and rootPart ~= nil and data.HoldValue.Parent ~= nil and data.HoldValue.Parent.Parent ~= nil do
			count += 1

			if count % 4 == 0 then
				local v3, v4
				ray, v3, v4 = Util.Ray(
					rootPart.Position,
					-CFrame.new(rootPart.Position).upVector.Unit * 5,
					{ workspace.Characters, workspace.Enemies },
					false
				)
			end

			local v3 = ray and math.random(-100, 100) or math.random(-180, 180)
			local _ = CFrame.new(rootPart.Position, mouseP) * CFrame.Angles(0, 0, (math.rad(v3))) * CFrame.new(0, 3, -6)
			local v4 = {
				RootCF = CFrame.new(rootPart.Position, mouseP) * CFrame.Angles(0, 0, (math.rad(v3))) * CFrame.new(
					0,
					3,
					-6
				),
				ShockwaveCF = not flag and (rootPart.CFrame or false),
				Smoke = v2 >= 2
			}
			holyThread(v4, true, nil, buso) -- equivalent call inferred; original call site unknown
			holyThread(v4, false, nil, buso) -- equivalent call inferred; original call site unknown
			holyThread(v4, false, 10, buso) -- equivalent call inferred; original call site unknown
			v2 = v2 >= 2 and 0 or v2 + 1

			if not flag then
				wait(0.25)
				flag = true
			end

			adjustColors()
			wait(castDelay)
		end

		Util.Debris:AddItem(clone, 3.5)

		for _, emitter in pairs(descendants) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		values = nil
	end
end