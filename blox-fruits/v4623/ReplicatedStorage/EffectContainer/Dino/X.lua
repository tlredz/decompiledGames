local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local cameraShaker = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local X = FX:WaitForChild("Dino").X

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
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

local function Curve(clone, p, p2, p3, i)
	local position = clone.Position
	local v = 35
	local v2 = 20

	if i == 2 then
		v = 20
		v2 = 15
	elseif i == 3 then
		v = 15
		v2 = 15
	end

	local v3 = p3 == true and 1 or v
	local v4 = p2 * CFrame.new(math.random(-v3, v3), math.random(-v3, v3), -p).Position
	local magnitude = (position - v4).Magnitude
	clone.CFrame = CFrame.new(position, v4)
	local v5 = (position - v4) / 2
	local position2 = CFrame.new(CFrame.new(position) * (v5 / -1.5)).Position
	local position3 = CFrame.new(CFrame.new(v4) * (v5 / 1.5)).Position
	local v6 = position2 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2), math.random(-v2, v2))
	local v7 = position3 + Vector3.new(math.random(-v2, v2), math.random(-v2, v2), math.random(-v2, v2))
	local lastTime = tick()
	local v8 = magnitude / 7 / 60

	while tick() - lastTime < v8 do
		local v9 = (tick() - lastTime) / v8
		local v10 = cubicBezier(v9, position, v6, v7, v4)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v10, v4), v9)
		RunService.Heartbeat:Wait()
	end
end

local function TrailsCurve(p, p2, p3)
	local clone = X.Trail:Clone()
	debris:AddItem(clone, 5)
	clone.CFrame = p * CFrame.new(math.random(-50, 50), math.random(-50, 50), math.random(-35, 35) / 10)
	Util.SetParentOverrideWithColor(clone, p2, player, "TRexFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local v = p3

	for i = 1, 3 do
		if p3 / 3 <= v and i ~= 3 then
			local v3 = p3 / 3
			Curve(clone, v3, p, false, i)
			p *= CFrame.new(0, 0, -v3)
			v -= p3 / 3
			continue
		end

		Curve(clone, v, p, true, i)
		p *= CFrame.new(0, 0, -v)
		break
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Util.Debris:AddItem(clone, 1)
end

local function PullBezierTrails(p, _WorldOrigin2, range)
	for _ = 1, 7 do
		task.spawn(function()
			TrailsCurve(p, _WorldOrigin2, range)
		end)
	end
end

local function PullTornadoTrails(fn, _WorldOrigin2, range, onRelease)
	task.spawn(function()
		local flag = false
		onRelease(function()
			flag = true
		end)
		local v = math.random(15, 25) / 100

		for i = 1, 60 do
			if flag then
				break
			end

			local clone = X.TornadoSlashPull:Clone()
			debris:AddItem(clone, 5)
			clone.CFrame = fn() * CFrame.new(0, 0, -range) * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= 2.75
					descendant.CurveSize1 *= 2.75
					descendant.Width0 *= 2.75
					descendant.Width1 *= 2.75
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(v * 1.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							CurveSize0 = descendant.CurveSize0 * 0.3,
							CurveSize1 = descendant.CurveSize1 * 0.3,
							Width0 = descendant.Width0 * 0,
							Width1 = descendant.Width1 * 0
						}
					)
					tween:Play()
					local v3 = descendant
					task.spawn(function()
						tween.Completed:Wait()
						v3:Destroy()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * 2.75,
						descendant.Position.Y * 2.75,
						descendant.Position.Z * 2.75
					)
					TweenService:Create(
						descendant,
						TweenInfo.new(v * 1.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
						{
							Position = Vector3.new(
								descendant.Position.X * 0.3,
								descendant.Position.Y * 0.3,
								descendant.Position.Z * 0.3
							)
						}
					):Play()
				end
			end

			task.spawn(function()
				local v3 = math.random(40, 70)

				for i2 = 1, 7 do
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(v / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, range / 7) * CFrame.Angles(0, 0, (math.rad(-v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)

			if i < 3 then
				task.wait(0.025)
			else
				task.wait(0.125)
			end
		end
	end)
	task.spawn(function()
		local v = math.random(30, 40) / 100

		for _ = 1, 3 do
			local clone = X.Trail2:Clone()
			debris:AddItem(clone, 5)
			clone.CFrame = fn() * CFrame.new(0, 0, -range) * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

			for _, attachment in ipairs(clone:GetDescendants()) do
				if attachment:IsA("Attachment") then
					attachment.Position = Vector3.new(
						attachment.Position.X,
						attachment.Position.Y * 1.25,
						attachment.Position.Z
					)
				end
			end

			for _, attachment in ipairs(clone:GetDescendants()) do
				if attachment:IsA("Attachment") then
					TweenService:Create(attachment, TweenInfo.new(v, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Position = Vector3.new(attachment.Position.X, attachment.Position.Y * 0, attachment.Position.Z)
					}):Play()
				end
			end

			task.spawn(function()
				local v3 = math.random(40, 70)
				local v4 = math.random(3, 5)

				for i = 1, v4 do
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(v / v4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, range / v4) * CFrame.Angles(0, 0, (math.rad(-v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)
		end
	end)
	task.spawn(function()
		local v = math.random(30, 40) / 100

		for _ = 1, 3 do
			local clone = X.Trail2:Clone()
			debris:AddItem(clone, 5)
			clone.CFrame = fn() * CFrame.new(0, 0, -range) * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

			for _, attachment in ipairs(clone:GetDescendants()) do
				if attachment:IsA("Attachment") then
					attachment.Position = Vector3.new(
						attachment.Position.X,
						attachment.Position.Y * 1.35,
						attachment.Position.Z
					)
				end
			end

			for _, attachment in ipairs(clone:GetDescendants()) do
				if attachment:IsA("Attachment") then
					TweenService:Create(attachment, TweenInfo.new(v, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Position = Vector3.new(attachment.Position.X, attachment.Position.Y * 0, attachment.Position.Z)
					}):Play()
				end
			end

			task.spawn(function()
				local v3 = math.random(40, 70)
				local v4 = math.random(3, 5)

				for i = 1, v4 do
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(v / v4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, range / v4) * CFrame.Angles(0, 0, (math.rad(v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)
		end
	end)
end

local function PullGroundSpark(fn, range, _WorldOrigin2, minDuration, onRelease)
	for i = 1, 2 do
		local cframe = nil
		local v = nil

		if i == 1 then
			cframe = CFrame.Angles(0, 0.3490658503988659, 0)
			v = -3
		elseif i == 2 then
			cframe = CFrame.Angles(0, -0.3490658503988659, 0)
			v = 3
		end

		local v3 = fn() * cframe * CFrame.new(v, 0, -range).Position
		local ray, v4, _ = Util.Ray(
			v3 + createVector(0, 15, 0),
			CFrame.new(v3).UpVector * -40,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if not ray then
			continue
		end

		local v6 = v4 + createVector(0, 5, 0)
		local v7 = ray
		task.spawn(function()
			local clone = X.GroundSparkPull:Clone()
			debris:AddItem(clone, 5)
			clone.CFrame = fn() * cframe
			clone.Orientation = Vector3.new(0, clone.Orientation.Y, clone.Orientation.Z)
			clone.Position = v6 + createVector(0, -6, 0)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

			for i2, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:GetAttribute("Color") then
					emitter.Color = ColorSequence.new(v7.Color, v7.Color)
				end

				emitter.Enabled = true
			end

			local v8 = false
			onRelease(function()
				v8 = true
			end)
			local v9 = fn() * cframe
			local v10 = v9 * CFrame.new(v, 0, -range).Position
			local ray2, v11, v12 = Util.Ray(
				v10 + createVector(0, 15, 0),
				CFrame.new(v10).UpVector * -40,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			local lastTime = tick()

			while task.wait() and not v8 do
				local v13 = math.min(1, (tick() - lastTime) / minDuration)

				if v13 == 1 then
					lastTime = tick()
					v9 = fn() * cframe
					local v14 = v9 * CFrame.new(v, 0, -range).Position
					ray2, v11, v12 = Util.Ray(
						v14 + createVector(0, 15, 0),
						CFrame.new(v14).UpVector * -40,
						{ workspace.Characters, workspace.Enemies },
						false
					)
				end

				if ray2 then
					clone.CFrame = Util.Misc.AlignCFrame(v9 - v9.p + v11, v12) * CFrame.new(v * v13, 0, range * v13)
				end
			end

			for i2, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end

local function RoarTornadoTrails(p, _WorldOrigin2, range)
	task.spawn(function()
		local v = math.random(15, 25) / 100

		for _ = 1, 10 do
			local clone = X.TornadoSlash:Clone()
			debris:AddItem(clone, 5)
			clone.CFrame = p * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= 0.75
					descendant.CurveSize1 *= 0.75
					descendant.Width0 *= 0.75
					descendant.Width1 *= 0.75
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = descendant.CurveSize0 * 5.25,
							CurveSize1 = descendant.CurveSize1 * 5.25,
							Width0 = descendant.Width0 * 5.25,
							Width1 = descendant.Width1 * 5.25
						}
					)
					tween:Play()
					local v2 = descendant
					task.spawn(function()
						tween.Completed:Wait()
						local endDelay = v2:GetAttribute("EndDelay")
						tween = TweenService:Create(
							v2,
							TweenInfo.new(endDelay / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * 0.75,
						descendant.Position.Y * 0.75,
						descendant.Position.Z * 0.75
					)
					TweenService:Create(descendant, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(
							descendant.Position.X * 5.25,
							descendant.Position.Y * 5.25,
							descendant.Position.Z * 5.25
						)
					}):Play()
				end
			end

			task.spawn(function()
				local v3 = math.random(30, 50)

				for i = 1, 7 do
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(v / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, -range / 7) * CFrame.Angles(0, 0, (math.rad(-v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)
			task.wait(0.035)
		end
	end)
	task.spawn(function()
		local v = math.random(15, 25) / 100

		for _ = 1, 10 do
			local clone = X.TornadoSlashPull:Clone()
			debris:AddItem(clone, 5)
			clone.CFrame = p * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
			Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= 0.85
					descendant.CurveSize1 *= 0.85
					descendant.Width0 *= 0.85
					descendant.Width1 *= 0.85
					local tween = TweenService:Create(
						descendant,
						TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = descendant.CurveSize0 * 5,
							CurveSize1 = descendant.CurveSize1 * 5,
							Width0 = descendant.Width0 * 5,
							Width1 = descendant.Width1 * 5
						}
					)
					tween:Play()
					local v2 = descendant
					task.spawn(function()
						tween.Completed:Wait()
						local endDelay = v2:GetAttribute("EndDelay")
						tween = TweenService:Create(
							v2,
							TweenInfo.new(endDelay / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * 0.85,
						descendant.Position.Y * 0.85,
						descendant.Position.Z * 0.85
					)
					TweenService:Create(descendant, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = Vector3.new(
							descendant.Position.X * 5,
							descendant.Position.Y * 5,
							descendant.Position.Z * 5
						)
					}):Play()
				end
			end

			task.spawn(function()
				local v3 = math.random(30, 50)

				for i = 1, 7 do
					local tween = TweenService:Create(
						clone,
						TweenInfo.new(v / 7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, -range / 7) * CFrame.Angles(0, 0, (math.rad(-v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
				end
			end)
			task.wait(0.035)
		end
	end)
end

local function RoarGroundSparks(p, range, _WorldOrigin2, duration)
	for i = 1, 2 do
		local v = i
		task.spawn(function()
			local cframe = nil
			local v2 = nil

			if v == 1 then
				cframe = CFrame.Angles(0, 0.3490658503988659, 0)
				v2 = -3
			elseif v == 2 then
				cframe = CFrame.Angles(0, -0.3490658503988659, 0)
				v2 = 3
			end

			local v3 = p * cframe * CFrame.new(v2, 0, -range).Position
			local ray, v4, v5 = Util.Ray(
				v3 + createVector(0, 15, 0),
				CFrame.new(v3).UpVector * -50,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				for i2 = 1, 6 do
					local v7 = v4 + createVector(0, 5, 0)
					task.spawn(function()
						local clone = X.GroundSpark:Clone()
						debris:AddItem(clone, 5)
						clone.CFrame = p * cframe
						clone.Orientation = Vector3.new(0, clone.Orientation.Y, clone.Orientation.Z)
						clone.Position = v7 + createVector(0, -6, 0)
						clone.CFrame *= CFrame.new(v2, 0, range)
						Util.SetParentOverrideWithColor(clone, _WorldOrigin2, player, "TRexFruitVFXColor")

						for i3, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end

						local tween = TweenService:Create(
							clone,
							TweenInfo.new(duration / 1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Position = clone.CFrame * CFrame.new(v2, 0, -range).Position
							}
						)
						clone.CFrame *= CFrame.Angles(-1.2217304763960306, 0, 0)
						tween:Play()
						task.wait(duration / 1.5 * 0.95)

						for i3, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter:GetAttribute("Color") then
								emitter.Color = ColorSequence.new(ray.Color, ray.Color)
							end

							emitter.Enabled = false
						end
					end)
					task.wait(0.05)
				end
			end
		end)
	end
end

return function(player2)
	player = player2.player
	local ID = player2.ID

	if ID == 1 then
		local character = player2.Character
		local minDuration = player2.MinDuration
		local maxDuration = player2.MaxDuration
		local mousePos = player2.MousePos
		local range = player2.Range
		local holding = player2.Holding
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
				return
			end

			local v = sound:Play("Predatory Screech- Pull", humanoidRootPart, nil, 1, 1)
			v.Looped = true

			local function fn()
				return CFrame.new(humanoidRootPart.Position, mousePos.Value)
			end

			local bindableEvent = Instance.new("BindableEvent")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function onRelease(fn2)
				bindableEvent.Event:Connect(function()
					if typeof(fn2) == "function" then
						fn2()
					elseif typeof(fn2) == "Instance" then
						if fn2.ClassName == "Tween" then
							fn2:Cancel()
						end

						fn2:Destroy()
					end
				end)
			end

			task.spawn(function()
				local lastTime = tick()

				while task.wait() do
					if maxDuration < tick() - lastTime or minDuration < tick() - lastTime and (holding.Value == false or not holding:IsDescendantOf(workspace)) then
						break
					end
				end

				if v then
					v:Destroy()
				end

				bindableEvent:Fire()
				Util.Debris:AddItem(bindableEvent, 5)
			end)
			PullTornadoTrails(fn, _WorldOrigin, range, onRelease)
			PullGroundSpark(fn, range, _WorldOrigin, minDuration, onRelease)
			task.spawn(function()
				PullBezierTrails(
					CFrame.new(humanoidRootPart.Position, mousePos.Value) * CFrame.new(0, 0, -range) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					),
					_WorldOrigin,
					range,
					true
				)
			end)
			local clone = X.AirStart:Clone()
			debris:AddItem(clone, 3)
			clone.CFrame = CFrame.new(humanoidRootPart.Position, mousePos.Value)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
			clone.Weld.Part0 = humanoidRootPart

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					if effect:GetAttribute("EMIT") then
						effect:Emit(effect:GetAttribute("EmitCount"))
						effect.Enabled = true
						local v2 = effect

						local function fn2()
							v2.Enabled = false
						end

						onRelease(fn2) -- equivalent call inferred; original call site unknown
					else
						effect.Enabled = true
						local v2 = effect

						local function fn2()
							v2.Enabled = false
						end

						onRelease(fn2) -- equivalent call inferred; original call site unknown
					end
				elseif effect:IsA("Beam") then
					local v2 = effect
					task.spawn(function()
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				end
			end

			if character == game.Players.LocalPlayer.LoadCharacter then
				task.spawn(function()
					local currentCamera = workspace.CurrentCamera
					TweenService:Create(
						currentCamera,
						TweenInfo.new(minDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							FieldOfView = 60
						}
					):Play()
					task.spawn(function()
						local clone2 = X.ScreenColor1:Clone()
						debris:AddItem(clone2, 5)
						Util.SetParentOverrideWithColor(clone2, currentCamera, player, "TRexFruitVFXColor")
						local tween = TweenService:Create(clone2, TweenInfo.new(minDuration), {
							Brightness = clone2.Brightness,
							Contrast = clone2.Contrast,
							Saturation = clone2.Saturation,
							TintColor = clone2.TintColor
						})
						clone2.Brightness = 0
						clone2.Contrast = 0
						clone2.Saturation = 0
						clone2.TintColor = Util.WrapColor3Constructor(
							Color3.fromRGB(255, 255, 255),
							player,
							"TRexFruitVFXColor"
						)
						tween:Play()
						tween.Completed:Wait()
						local tween2 = TweenService:Create(clone2, TweenInfo.new(0.015), {
							TintColor = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 255, 255),
								player,
								"TRexFruitVFXColor"
							),
							Brightness = 0,
							Contrast = 0,
							Saturation = 0
						})
						tween2:Play()
						tween2.Completed:Wait()
						clone2:Destroy()
					end)

					local function fn2()
						task.spawn(function()
							local clone2 = X.Blur:Clone()
							debris:AddItem(clone2, 5)
							local tween = TweenService:Create(clone2, TweenInfo.new(0.15), {
								Size = clone2.Size
							})
							clone2.Size = 0
							Util.SetParentOverrideWithColor(
								clone2,
								workspace.CurrentCamera,
								player,
								"TRexFruitVFXColor"
							)
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(clone2, TweenInfo.new(0.25), {
								Size = 0
							})
							tween2:Play()
							tween2.Completed:Wait()
							clone2:Destroy()
						end)
						task.spawn(function()
							cameraShaker:ShakeOnce(20, 10, 0.3, 0.25)
							local clone2 = X.ScreenColor2:Clone()
							debris:AddItem(clone2, 5)
							Util.SetParentOverrideWithColor(clone2, currentCamera, player, "TRexFruitVFXColor")
							local tween = TweenService:Create(clone2, TweenInfo.new(0.075), {
								Brightness = clone2.Brightness,
								Contrast = clone2.Contrast,
								Saturation = clone2.Saturation,
								TintColor = clone2.TintColor
							})
							clone2.Brightness = 0
							clone2.Contrast = 0
							clone2.Saturation = 0
							clone2.TintColor = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 255, 255),
								player,
								"TRexFruitVFXColor"
							)
							tween:Play()
							tween.Completed:Wait()
							local tween2 = TweenService:Create(clone2, TweenInfo.new(0.3), {
								TintColor = Util.WrapColor3Constructor(
									Color3.fromRGB(255, 255, 255),
									player,
									"TRexFruitVFXColor"
								),
								Brightness = 0,
								Contrast = 0,
								Saturation = 0
							})
							tween2:Play()
							tween2.Completed:Wait()
							clone2:Destroy()
						end)
					end

					onRelease(fn2) -- equivalent call inferred; original call site unknown
				end)
			end
		end
	elseif ID == 2 then
		local lookCF = player2.LookCF
		local character = player2.Character
		local duration = player2.Duration
		local range = player2.Range
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
				return
			end

			sound:Play("Predatory Screech- Release", humanoidRootPart.Position, nil, 1, 1)
			sound:Play("DinoXRelease", humanoidRootPart.Position, nil, 1, 1)
			local cFrame = CFrame.new(humanoidRootPart.Position) * (lookCF - lookCF.Position)

			if character == game.Players.LocalPlayer.Character then
				local currentCamera = workspace.CurrentCamera
				local clone = X.CameraFocus:Clone()
				debris:AddItem(clone, duration + 1)
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
				end)
				local tween = TweenService:Create(currentCamera, TweenInfo.new(duration), {
					FieldOfView = 100
				})
				tween:Play()
				task.spawn(function()
					tween.Completed:Wait()
					tween = TweenService:Create(currentCamera, TweenInfo.new(0.25), {
						FieldOfView = 70
					})
					tween:Play()
					renderSteppedConnection:Disconnect()
					clone:Destroy()
				end)
			end

			local clone = X.RoarStartImpact:Clone()
			debris:AddItem(clone, 2)
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = X.RoarStart:Clone()
			debris:AddItem(clone2, 5)
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					if effect:GetAttribute("EMIT") then
						effect:Emit(effect:GetAttribute("EmitCount"))
						effect.Enabled = true
						local v2 = effect
						task.spawn(function()
							task.wait(duration)
							v2.Enabled = false
						end)
					else
						effect.Enabled = true
						local v2 = effect
						task.spawn(function()
							task.wait(duration)
							v2.Enabled = false
						end)
					end
				elseif effect:IsA("Beam") then
					local v2 = effect
					task.spawn(function()
						task.wait(duration)
						local tween = TweenService:Create(
							v2,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v2:Destroy()
					end)
				end
			end

			RoarTornadoTrails(cFrame, _WorldOrigin, range)
			RoarGroundSparks(cFrame, range, _WorldOrigin, duration)
		end
	end
end