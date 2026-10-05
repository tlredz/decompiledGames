local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local cameraShaker = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local C = FX:WaitForChild("Dino").Transformed.C

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

local function viewerIsClose(p, p2, callback)
	local loadCharacter = game.Players.LocalPlayer.LoadCharacter

	if loadCharacter ~= nil then
		local humanoidRootPart = loadCharacter:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
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

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RockCrater(position, p, p2, data)
	task.spawn(function()
		local radius = data.Radius
		local size = data.Size
		local duration = data.Duration
		local amount = data.Amount
		local currentRock = data.CurrentRock
		local cframe = AlignCFrame(CFrame.new(position), p) + p * 0.01
		local v = {}

		for _ = 1, amount do
			local v2 = size * math.random(15, 20) / 10
			local v3 = size * math.random(10, 20) / 10
			local v4 = size * math.random(10, 30) / 10
			local clone = currentRock:Clone()
			clone.Size = Vector3.new(v2, v3, v4) + Vector3.new(
				0,
				math.random(-v3 / 3, v3 / 3),
				math.random(-v4 / 3, v4 / 3)
			)
			Util.SetParentOverrideWithColor(clone, p2, player, "TRexFruitVFXColor")
			table.insert(v, clone)
		end

		task.spawn(function()
			task.wait(duration * 2)

			for _, v2 in ipairs(v) do
				v2:Destroy()
			end

			v = nil
		end)

		local function GetXAndYPosition(p3, p4)
			return math.cos(p3) * p4, math.sin(p3) * p4
		end

		for i, v2 in ipairs(v) do
			local v3 = i * (6.283185307179586 / #v)
			local v4 = math.cos(v3) * radius
			local v5 = math.sin(v3) * radius
			local _ = cframe:ToObjectSpace(v2.CFrame).Y
			local position2 = (cframe * CFrame.new(v4, 0, v5)).Position
			v2.CFrame = CFrame.new(position2 + createVector(0, 0.1, 0), cframe.Position)

			if math.random(1, 5) < 2 then
				v2.CFrame = CFrame.new(v2.Position, cframe.Position) * CFrame.new(
					0,
					0,
					v2.Size.Z * math.random(5, 15) / 10
				)
			end

			local ray = Ray.new(v2.Position + createVector(0, 1, 0), createVector(-0, -20, -0))
			local part, v7 = workspace:FindPartOnRayWithIgnoreList(ray, { p2 })

			if part then
				v2.Position = v7 + Vector3.new(0, -v2.Size.Y * math.random(5, 6) / 10, 0)
				v2.CFrame = CFrame.new(
					v2.Position,
					cframe.Position + Vector3.new(0, math.random(-55, -45) + v2.Size.Y / 2, 0)
				) * CFrame.Angles(0, 0, (math.rad((math.random(-5, 5)))))
				v2.Material = part.Material
				v2.Color = part.Color
			else
				v2:Destroy()
				v[v2] = nil
			end

			TweenService:Create(v2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
				Position = v2.Position + Vector3.new(0, v2.Size.Y * math.random(3, 5) / 10, 0)
			}):Play()
			local v8 = v2
			local v9 = v2
			task.spawn(function()
				wait(duration)
				local tween = TweenService:Create(
					v8,
					TweenInfo.new(
						0.5,
						Enum.EasingStyle.Back,
						Enum.EasingDirection.In,
						0,
						false,
						math.random(10, 35) / 100
					),
					{
						Position = v8.Position + Vector3.new(
							math.random(-1, 1),
							-v8.Size.Y * math.random(20, 25) / 10,
							math.random(-1, 1)
						)
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v8:Destroy()
				v[v8] = nil
			end)
		end
	end)
end

local function GroundRocks(cFrame, folder, _, p)
	for _ = 1, 7 do
		task.spawn(function()
			local clone = C.Rock2:Clone()
			clone.Position = cFrame.Position + Vector3.new(
				math.random(-15, 15),
				math.random(1, 15),
				math.random(-15, 15)
			)
			clone.Size = Vector3.new(math.random(3, 5) / 1.5, math.random(3, 5), math.random(3, 5) / 1.5)
			clone.Material = p.Material
			clone.Color = p.Color
			Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
			rocks:ApplyCollision(clone, nil, true)
			task.spawn(function()
				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.wait(1.5 + math.random(10, 50) / 100)

				for _, emitter in ipairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25),
					{
						Size = createVector(0.1, 0.1, 0.1)
					}
				)
				tween.Completed:Connect(function()
					clone:Destroy()
				end)
				tween:Play()
			end)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.P = 3000
			Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "TRexFruitVFXColor")
			bodyVelocity.Velocity = CFrame.new(
				clone.Position,
				(CFrame.new(clone.Position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0) * CFrame.new(
					0,
					0,
					-30
				)).Position + Vector3.new(math.random(-10, 10) / 5, math.random(80, 250), math.random(-10, 10) / 5)
			).LookVector * math.random(70, 100)
			task.delay(0.1, function()
				bodyVelocity:Destroy()
			end)
			clone.Attachment0.Orientation = createVector(0, 0, 0)
			local v = math.random(-100, 100)
			local v2 = math.random(-100, 100)
			local v3 = math.random(-100, 100)
			local v4 = v / 10
			local v5 = v2 / 10
			local v6 = v3 / 10
			task.spawn(function()
				task.wait(0.05)

				for i = 1, 6 do
					v = math.clamp(v - v4, 0, 120)
					v2 = math.clamp(v2 - v5, 0, 120)
					v3 = math.clamp(v3 - v6, 0, 120)
					local tween = TweenService:Create(
						clone.Attachment0,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = clone.Attachment0.CFrame * CFrame.Angles(math.rad(v), math.rad(v2), (math.rad(v3)))
						}
					)
					tween:Play()
					tween.Completed:Wait()
					tween:Destroy()

					if i ~= 6 then
						continue
					end

					for _, emitter in ipairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				clone.AlignOrientation:Destroy()
			end)
		end)
	end
end

local function DashScreenEffect(folder, duration)
	local currentCamera = workspace.CurrentCamera
	local clone = C.CameraFocus:Clone()
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
	end)
	task.delay(duration, function()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
		end

		renderSteppedConnection = nil
	end)
	TweenService:Create(currentCamera, TweenInfo.new(0.15), {
		FieldOfView = 85
	}):Play()
	task.wait(duration)
	TweenService:Create(currentCamera, TweenInfo.new(0.1), {
		FieldOfView = 70
	}):Play()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = nil
	clone:Destroy()
end

local function DashTrail(clone, position, _)
	local position2 = clone.Position
	local magnitude = (position2 - position).Magnitude
	clone.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(20, 30)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, 2), math.random(-v2, v2))
	local v5 = math.random(25, 30) / 5
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local function BiteSlash(folder, humanoidRootPart, data)
	local multiplier = data.Multiplier
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local yPosition = data.YPosition
	local slashType = data.SlashType
	local spinReduction = data.SpinReduction
	local finalSpin = data.FinalSpin
	local semiFinalSpin = data.SemiFinalSpin
	local part = Instance.new("Part")
	debris:AddItem(part, 5)
	part.Size = humanoidRootPart.Size
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = humanoidRootPart.CFrame
	Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "TRexFruitVFXColor")
	local clone = slashType:Clone()
	clone.CFrame = part.CFrame
	clone.Weld.Part0 = part
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, beam in ipairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local startDelay = beam:GetAttribute("StartDelay")
		local v = beam
		local v2 = beam:GetAttribute("EndDelay")
		task.spawn(function()
			local tween = TweenService:Create(v, TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Width0 = v.Width0,
				Width1 = v.Width1
			})
			v.Width0 = 0
			v.Width1 = 0
			task.wait(startDelay)
			tween:Play()
		end)
	end

	for _ = 1, 3 do
		local v

		if finalSpin == true then
			v = TweenService:Create(clone.Weld, TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad(70 / spinReduction),
					0
				)
			})
		elseif semiFinalSpin == true then
			v = TweenService:Create(clone.Weld, TweenInfo.new(0.035, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad(70 / spinReduction),
					0
				)
			})
		else
			v = TweenService:Create(clone.Weld, TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad(70 / spinReduction),
					0
				)
			})
		end

		v:Play()
		v.Completed:Wait()
	end

	clone.Weld.Enabled = false
	clone.Anchored = true
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(0, math.rad(50 / spinReduction), 0)
	}):Play()

	for _, beam in ipairs(clone:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		local v = beam
		task.spawn(function()
			local endDelay = v:GetAttribute("EndDelay")
			local v2

			if finalSpin == true then
				v2 = TweenService:Create(
					v,
					TweenInfo.new(endDelay * 1.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
			elseif semiFinalSpin == true then
				v2 = TweenService:Create(
					v,
					TweenInfo.new(endDelay / 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
			else
				v2 = TweenService:Create(
					v,
					TweenInfo.new(endDelay / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
			end

			v2:Play()
			v2.Completed:Wait()
			v:Destroy()
		end)
	end

	if part then
		part:Destroy()
	end
end

local function PoisonScreenEffect(folder, character, duration, p)
	local currentCamera = workspace.CurrentCamera
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local clone = C.DizzyStar:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
		clone.Weld.Part0 = humanoidRootPart.Parent.Head
		local v = {}

		for _, weld in ipairs(clone:GetDescendants()) do
			if weld:IsA("Weld") and weld.Name ~= "Weld" then
				v[weld] = false
			end
		end

		local lastTime = tick()

		if p then
			task.spawn(function()
				local clone2 = C.PoisonCameraFocus:Clone()
				Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")
				local renderSteppedConnection = RunService.RenderStepped:Connect(function()
					clone2.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
				end)
				task.delay(duration, function()
					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end

					renderSteppedConnection = nil
				end)

				for _, emitter in ipairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				local tweens = {}

				for i = 1, 3 do
					local v2 = i
					task.spawn(function()
						local clone3 = nil

						if v2 == 1 then
							clone3 = C.ScreenColor1:Clone()
						elseif v2 == 2 then
							clone3 = C.ScreenColor2:Clone()
						elseif v2 == 3 then
							clone3 = C.ScreenColor3:Clone()
						end

						Util.SetParentOverrideWithColor(clone3, currentCamera, player, "TRexFruitVFXColor")
						local tween = TweenService:Create(
							clone3,
							TweenInfo.new(
								math.random(10, 30) / 100,
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out,
								0,
								false,
								math.random(0, 10) / 100
							),
							{
								Brightness = clone3.Brightness,
								Contrast = clone3.Contrast,
								Saturation = clone3.Saturation,
								TintColor = clone3.TintColor
							}
						)
						clone3.Brightness = 0
						clone3.Contrast = 0
						clone3.Saturation = 0
						clone3.TintColor = Util.WrapColor3Constructor(
							Color3.fromRGB(255, 255, 255),
							player,
							"TRexFruitVFXColor"
						)
						tweens[clone3] = tween
						tween:Play()
					end)
				end

				local clone3 = C.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone3, currentCamera, player, "TRexFruitVFXColor")
				local tween = TweenService:Create(
					clone3,
					TweenInfo.new(math.random(10, 30) / 100, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						FarIntensity = clone3.FarIntensity,
						FocusDistance = clone3.FocusDistance,
						InFocusRadius = clone3.InFocusRadius,
						NearIntensity = clone3.NearIntensity
					}
				)
				clone3.FarIntensity = 0
				clone3.FocusDistance = 0
				clone3.InFocusRadius = 0
				clone3.NearIntensity = 0
				tween:Play()
				local currentCamera2 = workspace.CurrentCamera
				local lastTime2 = nil
				task.spawn(function()
					tick()
					local total = 1
					pcall(function()
						RunService:UnbindFromRenderStep("dinoStunCam")
					end)
					pcall(function()
						RunService:BindToRenderStep("dinoStunCam", Enum.RenderPriority.Camera.Value + 1, function(p2)
							total += p2 * 60
							local v2 = not lastTime2 and 1 or 1 - (tick() - lastTime2) / 1
							local v3 = { currentCamera2.CFrame:GetComponents() }
							v3[10] -= (math.cos(total / 25) * 0.07 + 0.02) * v2
							v3[11] -= (math.cos(total / 30) * 0.15 + 0.02) * v2
							currentCamera2.CFrame = CFrame.new(table.unpack(v3))
						end)
					end)
				end)
				local v2 = {}
				local v3 = {}

				for _ = 1, 3 do
					local clone4 = C.CameraTrails:Clone()
					Util.SetParentOverrideWithColor(clone4, folder, player, "TRexFruitVFXColor")
					clone4.Weld.Part0 = clone2
					TweenService:Create(
						clone4.Weld,
						TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							C0 = clone4.Weld.Part0.CFrame:ToObjectSpace(clone4.Weld.Part1.CFrame) * CFrame.Angles(
								0,
								1.5707963267948966,
								0
							)
						}
					):Play()
					v2[clone4] = false

					for _, child in ipairs(clone4:GetChildren()) do
						if child.Name ~= "Weld" then
							v3[child] = false
						end
					end
				end

				while true do
					for k, v4 in pairs(tweens) do
						if v4.PlaybackState ~= Enum.PlaybackState.Completed then
							continue
						end

						local tween2 = TweenService:Create(
							k,
							TweenInfo.new(
								math.random(30, 70) / 100,
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out,
								0,
								true,
								0
							),
							{
								Brightness = 0,
								Contrast = 0,
								Saturation = 0,
								TintColor = Util.WrapColor3Constructor(
									Color3.fromRGB(255, 255, 255),
									player,
									"TRexFruitVFXColor"
								)
							}
						)
						tweens[k] = tween2
						tween2:Play()
					end

					if tween.PlaybackState == Enum.PlaybackState.Completed then
						TweenService:Create(
							clone3,
							TweenInfo.new(
								math.random(70, 130) / 100,
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.Out,
								0,
								false,
								0
							),
							{
								FarIntensity = math.random(0, 3) / 5,
								FocusDistance = math.random(0, 3),
								InFocusRadius = math.random(5, 15),
								NearIntensity = math.random(0, 3) / 5
							}
						):Play()
					end

					for k, v4 in pairs(v2) do
						if not (k ~= nil and v4 == false) then
							continue
						end

						local v5 = k
						task.spawn(function()
							v2[v5] = true
							local v6 = v5
							local v7 = math.random(-170, 170)
							local tween2 = TweenService:Create(
								v6.Weld,
								TweenInfo.new(
									math.random(20, 100) / 100,
									Enum.EasingStyle.Linear,
									Enum.EasingDirection.Out
								),
								{
									C0 = v6.Weld.Part0.CFrame:ToObjectSpace(v6.Weld.Part1.CFrame) * CFrame.Angles(
										0,
										math.rad(v7),
										0
									)
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
							v2[v5] = false
						end)
					end

					for k, v4 in pairs(v3) do
						if not (k ~= nil and v4 == false) then
							continue
						end

						local v5 = k
						task.spawn(function()
							v3[v5] = true
							local tween2 = TweenService:Create(
								v5.Weld,
								TweenInfo.new(
									math.random(20, 100) / 100,
									Enum.EasingStyle.Linear,
									Enum.EasingDirection.Out
								),
								{
									C0 = CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
								}
							)
							tween2:Play()
							tween2.Completed:Wait()
							v3[v5] = false
						end)
					end

					task.wait()

					if not (duration <= tick() - lastTime) then
						continue
					end

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for k, _ in pairs(tweens) do
						TweenService:Create(k, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
							Brightness = 0,
							Contrast = 0,
							Saturation = 0,
							TintColor = Util.WrapColor3Constructor(
								Color3.fromRGB(255, 255, 255),
								player,
								"TRexFruitVFXColor"
							)
						}):Play()
					end

					TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						FarIntensity = 0,
						FocusDistance = 0,
						InFocusRadius = 0,
						NearIntensity = 0
					}):Play()
					lastTime2 = tick()
					task.wait(1)
					pcall(function()
						RunService:UnbindFromRenderStep("dinoStunCam")
					end)
					clone3:Destroy()

					for k, _ in pairs(v2) do
						k:Destroy()
					end

					for k, _ in pairs(tweens) do
						k:Destroy()
					end

					if renderSteppedConnection then
						renderSteppedConnection:Disconnect()
					end

					renderSteppedConnection = nil
					clone2:Destroy()
					break
				end
			end)
		end

		task.spawn(function()
			while tick() - lastTime < duration do
				for k, v2 in pairs(v) do
					if not (k ~= nil and v2 == false) then
						continue
					end

					local v3 = k
					task.spawn(function()
						v[v3] = true
						local v4 = v3
						local tween = TweenService:Create(
							v4,
							TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								C0 = v4.Part0.CFrame:ToObjectSpace(v4.Part1.CFrame) * CFrame.Angles(
									0,
									-1.2217304763960306,
									0
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v[v3] = false
					end)
				end

				task.wait()
			end

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end

local function makeProxyPartAtBone(bone007, _WorldOrigin2, cframe)
	local cFrame = cframe or CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. bone007.Name
	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame
	Util.SetParentOverrideWithColor(attachment, part, player, "TRexFruitVFXColor")
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = bone007
	rigidConstraint.Attachment1 = attachment
	Util.SetParentOverrideWithColor(rigidConstraint, part, player, "TRexFruitVFXColor")
	part.Transparency = 1
	Util.SetParentOverrideWithColor(part, _WorldOrigin2, player, "TRexFruitVFXColor")
	return part
end

return function(player2)
	local DISTANCE_THRESHOLD = 1000
	player = player2.player
	local ID = player2.ID

	if ID == 1 then
		return
	end

	if ID == 2 then
		local cFrame = player2.CFrame
		local goalCFrame = player2.GoalCFrame
		local character = player2.Character
		local distance = player2.Distance
		local duration = player2.Duration
		local _ = player2.Speed
		local _ = player2.Rig

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 7)
		sound:Play("Hunters Rage- Release (1)", humanoidRootPart, nil, 1, 1)
		TweenService:Create(humanoidRootPart, TweenInfo.new(duration), {
			CFrame = goalCFrame
		}):Play()
		local clone = C.StartImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		local clone2 = C.Dash:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")
		clone2.Weld.Part0 = humanoidRootPart

		for _, emitter in ipairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.spawn(function()
			local v = "Right"
			local v2 = 7
			local distance2 = distance
			local distance3 = distance

			if distance3 <= 1 then
				v2 = 2
			elseif distance3 > 1 and distance3 <= distance2 then
				v2 = 2 + (v2 - 2) * ((distance3 - 1) / (distance2 - 1))
			end

			local cFrame2 = cFrame
			local v6 = distance / v2
			local clone3 = C.GroundStomp:Clone()
			clone3.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone3, folder, player, "TRexFruitVFXColor")

			for _ = 1, v2 do
				v = v == "Right" and "Left" or v == "Left" and "Right" or v
				cFrame2 *= CFrame.new(0, 0, -v6)
				clone3.CFrame = cFrame2
				local ray, v7, _ = Util.Ray(
					clone3.Position + createVector(0, 1, 0),
					CFrame.new(clone3.Position).UpVector * -15,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if ray then
					local v8 = v7 + createVector(0, 0.5, 0)
					clone3.CFrame = CFrame.new(v8, v8 + clone3.CFrame.LookVector)

					if v == "Right" then
						for _, emitter in ipairs(clone3.Right:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					elseif v == "Left" then
						for _, emitter in ipairs(clone3.Left:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end
				end

				task.wait(0.03)
			end
		end)

		if game.Players.LocalPlayer.LoadCharacter == character then
			task.spawn(function()
				DashScreenEffect(folder)
			end)
		end

		for _ = 1, 5 do
			task.spawn(function()
				local clone3 = C.DashTrail:Clone()
				clone3.CFrame = cFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5) / 2, math.random(-5, 5))
				Util.SetParentOverrideWithColor(clone3, folder, player, "TRexFruitVFXColor")

				for _, effect in ipairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				DashTrail(
					clone3,
					CFrame.new(goalCFrame.Position, cFrame.Position) * CFrame.new(
						math.random(-5, 5) * 2,
						math.random(-5, 5) / 2,
						math.random(-7, -5)
					).Position,
					goalCFrame
				)

				for _, effect in ipairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end

		task.spawn(function()
			clone2.Attachment.Particle_1.Enabled = false
			clone2.Attachment.Particle_2.Enabled = false
			clone2.Attachment.Particle_3.Enabled = false
			task.wait(0.2857142857142857)
			clone2.Weld.Enabled = false
			clone2.Anchored = true

			for _, effect in ipairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
		task.spawn(function()
			BiteSlash(folder, humanoidRootPart, {
				Multiplier = 2.75,
				SlashAngle = CFrame.Angles(0, -2.9670597283903604, 0),
				SlashAngle2 = CFrame.Angles(0.4363323129985824, 0, 0),
				YPosition = 0,
				SlashType = C.BiteSlash,
				SpinReduction = 1
			})
		end)
	elseif ID == 3 then
		local cFrame = player2.CFrame
		local character = player2.Character
		local _ = player2.Rig

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > DISTANCE_THRESHOLD or not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 7)
		local clone = C.Bite:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 4, -5)
		Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
		sound:Play("Hunters Rage- Release (2)", humanoidRootPart or cFrame.Position, nil, 1, 1)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		task.spawn(function()
			for i = 1, 5 do
				if i % 2 == 0 then
					task.spawn(function()
						task.wait(math.random(1, 10) / 100)
						BiteSlash(folder, humanoidRootPart, {
							Multiplier = 2.5,
							SlashAngle = CFrame.new(0, math.random(-5, 5), 0) * CFrame.Angles(
								0,
								math.rad(-math.random(35, 70)),
								0
							),
							SlashAngle2 = CFrame.Angles(0, 0, (math.rad((math.random(-15, 15))))),
							YPosition = 0,
							SlashType = C.BiteSlash2,
							SpinReduction = math.random(10, 25) / 10
						})
					end)
				else
					task.spawn(function()
						task.wait(math.random(1, 10) / 100)
						BiteSlash(folder, humanoidRootPart, {
							Multiplier = 2.5,
							SlashAngle = CFrame.new(0, math.random(-5, 5), 0) * CFrame.Angles(
								0,
								math.rad(-math.random(35, 90)),
								0
							),
							SlashAngle2 = CFrame.Angles(3.141592653589793, 0, (math.rad((math.random(-15, 15))))),
							YPosition = 0,
							SlashType = C.BiteSlash2,
							SpinReduction = math.random(10, 25) / 10
						})
					end)
				end

				task.wait(0.15)
			end

			task.spawn(function()
				BiteSlash(folder, humanoidRootPart, {
					Multiplier = 3,
					SlashAngle = CFrame.Angles(0, 1.6406094968746698, 0),
					SlashAngle2 = CFrame.Angles(-0.6806784082777885, 0, -3.01941960595019),
					YPosition = 10,
					SlashType = C.BiteSlash3,
					SpinReduction = 1,
					SemiFinalSpin = true
				})
			end)
			task.wait(0.25)
			task.spawn(function()
				task.wait(0.07)
				BiteSlash(folder, humanoidRootPart, {
					Multiplier = 3,
					SlashAngle = CFrame.Angles(0, -3.0543261909900767, 0),
					SlashAngle2 = CFrame.Angles(0.4886921905584123, 0, -2.443460952792061),
					YPosition = 10,
					SlashType = C.BiteSlash3,
					SpinReduction = 1,
					FinalSpin = true
				})
			end)
			task.spawn(function()
				local ray = Util.Ray
				local v = cFrame.Position + createVector(0, 1, 0)
				local v2 = { workspace.Characters, workspace.Enemies }
				local v3, v4, v5 = ray(v, createVector(-0, -50, -0), v2, true)

				if v3 then
					cameraShaker:ShakeOnce(15, 15, 0.1, 0.25)
					RockCrater(v4, v5, folder, {
						Radius = 15,
						Size = 4,
						Duration = 3,
						Amount = 14,
						CurrentRock = C.CraterRock
					}) -- equivalent call inferred; original call site unknown
					GroundRocks(cFrame, folder, v4, v3)
					sound:Play("Gigantic Leap- Explosion", v4, nil, 1, 2)
					sound:Play("Reptilian Scales- Meteor Explode", v4, nil, 1, 1)
					local clone2 = C.GroundSlamHit:Clone()
					clone2.CFrame = AlignCFrame(CFrame.new(v4), v5) + v5 * 0.01
					Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

					for _, emitter in ipairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v8 = emitter
						task.spawn(function()
							if v8:GetAttribute("EmitDelay") ~= 0 then
								task.wait(v8:GetAttribute("EmitDelay"))
							end

							v8:Emit(v8:GetAttribute("EmitCount"))
						end)
					end
				end
			end)
		end)
	elseif ID == 4 then
		local duration = player2.Duration
		local character = player2.Character

		if not character then
			return
		end

		local character2 = game.Players.LocalPlayer.Character

		if not character2 then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local v = character2 == character

		if humanoidRootPart and not v and (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > DISTANCE_THRESHOLD then
			return
		end

		local folder = Instance.new("Folder", workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 7)
		PoisonScreenEffect(folder, character, duration, v)
	elseif ID == 5 then
		local rig = player2.Rig
		local victimChar = player2.VictimChar
		local userChar = player2.UserChar
		local grab = player2.Grab

		if not (rig and victimChar and userChar and grab) then
			return
		end

		local humanoidRootPart = userChar:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart2 = userChar:FindFirstChild("HumanoidRootPart")
		local humanoid = userChar:FindFirstChild("Humanoid")
		local humanoid2 = victimChar:FindFirstChild("Humanoid")

		if not (humanoidRootPart and humanoidRootPart2 and humanoid and humanoid2) then
			return
		end

		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 1500 then
			return
		end

		local proxyPartAtBone = makeProxyPartAtBone(
			rig.RootPart.Bone["Bone.008"]["Bone.005"]["Bone.002"]["Bone.003"]["Bone.004"]["Bone.007"],
			_WorldOrigin,
			CFrame.new(0, -6, -2.5)
		)
		debris:AddItem(proxyPartAtBone, 8)
		Effect.new("Dino.Grab"):replicate({
			Adornee = proxyPartAtBone,
			AttackerChar = userChar,
			AttackerHum = humanoid,
			VictimChar = victimChar,
			VictimHum = humanoid2,
			GrabExists = grab,
			Timeout = 8
		})
	end
end