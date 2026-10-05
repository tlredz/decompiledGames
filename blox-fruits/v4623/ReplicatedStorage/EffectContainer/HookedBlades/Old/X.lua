local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
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

local function motor6D(parent, part, part2, C0, C1)
	local motor6D2 = Instance.new("Motor6D")
	motor6D2.Parent = parent
	motor6D2.Part0 = part
	motor6D2.Part1 = part2
	motor6D2.C0 = C0
	motor6D2.C1 = C1
	return motor6D2
end

local function debrisPart(data, p, p2)
	local v = math.random(15, 17) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * math.random(80, 110)
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

local function makeHooks(leftLowerArm, rightLowerArm, targetPosition)
	local clone = FX:WaitForChild("Weapons").HookBeam:Clone()
	Util.Debris:AddItem(clone, 10)
	local startPart = clone.StartPart
	local endPart = clone.EndPart
	startPart.Anchored = false
	clone.Parent = _WorldOrigin
	startPart.CFrame = leftLowerArm.CFrame
	endPart.CFrame = CFrame.new(leftLowerArm.Position, targetPosition)
	local cframe = CFrame.new()
	local cframe2 = CFrame.new()
	local motor6D2 = Instance.new("Motor6D")
	motor6D2.Parent = leftLowerArm
	motor6D2.Part0 = leftLowerArm
	motor6D2.Part1 = startPart
	motor6D2.C0 = cframe
	motor6D2.C1 = cframe2
	Util.Debris:AddItem(motor6D2, 5)
	local clone2 = FX:WaitForChild("Weapons").HookBeam:Clone()
	Util.Debris:AddItem(clone2, 10)
	local startPart2 = clone2.StartPart
	local endPart2 = clone2.EndPart
	startPart2.Anchored = false
	clone2.Parent = _WorldOrigin
	startPart2.CFrame = rightLowerArm.CFrame
	endPart2.CFrame = CFrame.new(rightLowerArm.Position, targetPosition)
	local cframe3 = CFrame.new()
	local cframe4 = CFrame.new()
	local motor6D3 = Instance.new("Motor6D")
	motor6D3.Parent = rightLowerArm
	motor6D3.Part0 = rightLowerArm
	motor6D3.Part1 = startPart2
	motor6D3.C0 = cframe3
	motor6D3.C1 = cframe4
	Util.Debris:AddItem(motor6D3, 5)
	return {
		startPart2,
		endPart2,
		startPart,
		endPart
	}
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local char = data.Char
		local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			Util.Sound:Play("PawCannonShoot", humanoidRootPart.Position, nil, 1.5 + math.random(-42, 42) / 100, 0.5)
			local attachment = Instance.new("Attachment")
			Util.Debris:AddItem(attachment, 2)
			attachment.Parent = humanoidRootPart
			local particleEmitter = Instance.new("ParticleEmitter")
			Util.Debris:AddItem(particleEmitter, 2)
			particleEmitter.Texture = "rbxassetid://2916153928"
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 20),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			particleEmitter.LightInfluence = 0
			particleEmitter.LightEmission = 1
			particleEmitter.Rate = 0
			particleEmitter.Lifetime = NumberRange.new(0.2)
			particleEmitter.Parent = attachment
			particleEmitter:Emit(1)
		end
	elseif stage == 2 then
		local char = data.Char
		local targetChar = data.TargetChar
		local _ = data.Timestamp
		local travelTime = data.TravelTime
		local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			local targetPosition = data.TargetPosition
			local magnitude = (humanoidRootPart.Position - targetPosition).magnitude
			local rightLowerArm = char:FindFirstChild("RightLowerArm")
			local leftLowerArm = char:FindFirstChild("LeftLowerArm")

			if rightLowerArm and leftLowerArm then
				local hooks = makeHooks(leftLowerArm, rightLowerArm, targetPosition)
				local hook = hooks[1]
				local hook2 = hooks[2]
				local hook3 = hooks[3]
				local hook4 = hooks[4]
				local v = targetChar and ({ travelTime, false } or { travelTime, true }) or { travelTime, true }
				local tween = TweenService:Create(
					hook2,
					TweenInfo.new(v[1], Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, v[2], 0),
					{
						CFrame = hook2.CFrame * CFrame.new(0, 0, -magnitude)
					}
				)
				tween.Completed:Connect(function()
					hook.Parent:Destroy()
				end)
				tween:Play()
				local tween2 = TweenService:Create(
					hook4,
					TweenInfo.new(v[1], Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, v[2], 0),
					{
						CFrame = hook4.CFrame * CFrame.new(0, 0, -magnitude)
					}
				)
				tween2.Completed:Connect(function()
					hook3.Parent:Destroy()
				end)
				tween2:Play()
			end

			Util.Sound:Play("SwordSwing", humanoidRootPart.Position, nil, 1.4 + math.random(-15, 5) / 100, 0.5)
			local attachment = Instance.new("Attachment")
			Util.Debris:AddItem(attachment, 2)
			attachment.Parent = humanoidRootPart
			local particleEmitter = Instance.new("ParticleEmitter")
			Util.Debris:AddItem(particleEmitter, 2)
			particleEmitter.Texture = "rbxassetid://2812352733"
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 20),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 1, 5))
			particleEmitter.LightInfluence = 0
			particleEmitter.LightEmission = 1
			particleEmitter.Rate = 0
			particleEmitter.Lifetime = NumberRange.new(0.3)
			particleEmitter.Parent = attachment
			particleEmitter.RotSpeed = NumberRange.new(-90, 90)
			particleEmitter.Rotation = NumberRange.new(-180, 180)
			particleEmitter:Emit(1)
		end
	elseif stage == 3 then
		local humanoidRootPart = data.TargetChar:FindFirstChild("HumanoidRootPart")
		local travelTime = data.TravelTime
		local _ = data.Timestamp

		if humanoidRootPart then
			Util.Sound:Play("BlockedHit1", humanoidRootPart.Position, nil, 1.4 + math.random(-15, 5) / 100, 0.7)
		end

		local char = data.Char
		local _ = data.TargetChar
		local humanoidRootPart2 = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			if (humanoidRootPart2.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			local position = humanoidRootPart2.Position
			local targetPosition = data.TargetPosition
			local magnitude = (humanoidRootPart2.Position - targetPosition).magnitude
			local rightLowerArm = char:FindFirstChild("RightLowerArm")
			local leftLowerArm = char:FindFirstChild("LeftLowerArm")

			if rightLowerArm and leftLowerArm then
				local hooks = makeHooks(leftLowerArm, rightLowerArm, targetPosition)
				local hook = hooks[1]
				local hook2 = hooks[2]
				local hook3 = hooks[3]
				local hook4 = hooks[4]
				hook2.CFrame *= CFrame.new(0, 0, -magnitude)
				hook4.CFrame *= CFrame.new(0, 0, -magnitude)
				local cFrame = CFrame.new(humanoidRootPart2.Position, targetPosition) * CFrame.new(0, 0, -magnitude + 5)
				local tween = TweenService:Create(
					humanoidRootPart2,
					TweenInfo.new(travelTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
					{
						CFrame = cFrame
					}
				)
				local stringValue = Instance.new("StringValue")
				Util.Debris:AddItem(stringValue, 1)
				stringValue.Name = "HBGrabbed"
				stringValue.Parent = char
				tween.Completed:Connect(function()
					if stringValue then
						stringValue:Destroy()
					end

					local v2, v3

					if data.NPC then
						v2 = nil
						v3 = nil
					else
						v2 = Util.BodyMover.new(char):Create("BodyGyro", {
							Duration = 2,
							Priority = -10000,
							CFrame = CFrame.new(humanoidRootPart2.Position, targetPosition)
						})
						v3 = Util.BodyMover.new(char):Create("BodyPosition", {
							Duration = 2,
							Priority = -10000,
							Position = humanoidRootPart2.Position
						})
					end

					humanoidRootPart2.CFrame = cFrame
					hook.Parent:Destroy()
					hook3.Parent:Destroy()
					spawn(function()
						local clone = FX:WaitForChild("Weapons").MammothHead:Clone()
						Util.Debris:AddItem(clone, 3)
						clone.CFrame = CFrame.new(position, targetPosition)
						clone.Parent = _WorldOrigin
						local position2 = clone.Position
						local v4 = targetPosition
						local v5 = {
							position2,
							position2:Lerp(v4, 0.25),
							position2:Lerp(v4 + createVector(0, -5, 0), 0.75),
							v4 + createVector(0, 20, 0)
						}
						TweenService:Create(
							clone,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
							{
								Transparency = 0.3,
								Size = clone.Size * 3
							}
						):Play()
						local lastTime = tick()
						tick()

						while tick() - lastTime <= 0.5 do
							local v6 = tick() - lastTime
							local v7 = cubicBezier(math.max(0.001, v6) / 0.5, unpack(v5))
							clone.CFrame = CFrame.new(v7, position2) * CFrame.Angles(0, 3.141592653589793, 0)
							position2 = clone.Position
							RunService.RenderStepped:Wait()
						end

						clone:Destroy()
					end)
					spawn(function()
						wait(0.2)
						local ray, v4, v5 = Util.Ray(
							targetPosition,
							-CFrame.new(targetPosition).upVector.Unit * 5,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if ray then
							if humanoidRootPart then
								Util.Sound:Play(
									"GroundCrash",
									humanoidRootPart.Position,
									nil,
									1 + math.random(-5, 5) / 100,
									0.7
								)
							end

							for _ = 1, math.random(3, 4) do
								debrisPart(ray, v4 + Vector3.new(math.random(-6, 6), 0, math.random(-6, 6)), v5)
							end
						end

						local v6 = targetPosition
						local character = game.Players.LocalPlayer.Character

						if character ~= nil then
							local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart3 and (humanoidRootPart3.Position - v6).magnitude <= 70 then
								Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.8)
							end
						end

						local parent = Util.Sound:Play(
							"GroundSmash",
							targetPosition,
							nil,
							1.2 + math.random(-15, 5) / 100,
							0.7
						)
						local chorusSoundEffect = Instance.new("ChorusSoundEffect")
						chorusSoundEffect.Parent = parent
						Util.Sound:Play("TremorWave1", targetPosition, nil, 1.2 + math.random(-15, 5) / 100, 0.4)
						local clone = FX:WaitForChild("Weapons").HookedBladesKick:Clone()
						Util.Debris:AddItem(clone, 5)
						clone:SetPrimaryPartCFrame(CFrame.new(targetPosition) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						))

						for _, child in pairs(clone:GetChildren()) do
							if child.Name == "Ring" then
								child.Size = createVector(0.05, 0.05, 0.05)
								local tween2 = TweenService:Create(
									child,
									TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
									{
										CFrame = child.CFrame * CFrame.new(0, -15, 0),
										Size = createVector(41.286, 1.602, 41.286),
										Transparency = 1
									}
								)
								local v8 = child
								tween2.Completed:Connect(function()
									v8:Destroy()
								end)
								tween2:Play()
							elseif child.Name == "Shockwave" then
								child.Size = createVector(0.05, 0.05, 0.05)
								local tween2 = TweenService:Create(
									child,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
									{
										CFrame = child.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(
											0,
											2.9670597283903604,
											0
										),
										Size = createVector(25, 0.1, 27.1),
										Transparency = 1
									}
								)
								local v8 = child
								tween2.Completed:Connect(function()
									v8:Destroy()
								end)
								tween2:Play()
							elseif child.Name == "Wind" then
								child.Size = createVector(0.05, 0.05, 0.05)
								local tween2 = TweenService:Create(
									child,
									TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
									{
										CFrame = child.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
											0,
											-3.1066860685499065,
											0
										),
										Size = createVector(59.718, 6.34, 58.328),
										Transparency = 1
									}
								)
								local v8 = child
								tween2.Completed:Connect(function()
									v8:Destroy()
								end)
								tween2:Play()
							elseif child.Name == "LongSwirl" then
								child.Size = createVector(0.05, 0.05, 0.05)
								local tween2 = TweenService:Create(
									child,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
									{
										CFrame = child.CFrame * CFrame.new(0, 15, 0) * CFrame.Angles(
											0,
											3.1066860685499065,
											0
										),
										Size = createVector(24, 30.562, 24),
										Transparency = 1
									}
								)
								local v8 = child
								tween2.Completed:Connect(function()
									v8:Destroy()
								end)
								tween2:Play()
							end
						end

						clone.Parent = _WorldOrigin

						for _, child in pairs(clone.Core.Attachment:GetChildren()) do
							if child.Name == "Lightning" then
								child:Emit(3)
							elseif child.Name == "Ring" then
								child:Emit(1)
							elseif child.Name == "Puff" then
								child:Emit(10)
							end
						end
					end)
					Util.Sound:Play("Roar", targetPosition, nil, 1.5 + math.random(-5, 5) / 100, 0.4)
					spawn(function()
						wait(0.5)

						if v2 then
							v2:Destroy()
						end

						if v3 then
							v3:Destroy()
						end
					end)
				end)
				tween:Play()
				Util.Sound:Play("SeaBite", humanoidRootPart2.Position, nil, 1.2 + math.random(-5, 5) / 100, 0.5)
			end
		end
	end
end