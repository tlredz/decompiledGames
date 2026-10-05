local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
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

-- equivalent calls inferred from this helper; original call sites unknown
local function viewerIsClose(p, p2, fn)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			fn()
		end
	end
end

local function shockwaveRing(cFrame, p, p2, duration)
	local clone = script.Shockwave:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(35, 1, 35) * p2,
			CFrame = clone.CFrame * CFrame.new(0, -p, 0)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

local function shockwave(p)
	local clone = script.Shockwave2:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.Size = createVector(15, 25, 15)
	clone.CFrame = p * CFrame.new(0, clone.Size.Y / 2, 0)
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(45, 1, 45),
			CFrame = clone.CFrame * CFrame.new(0, -(clone.Size.Y / 2), 0)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lifeOrb(position, position2)
	task.spawn(function()
		local clone = script.ShadowAbsorbPart:Clone()
		Util.Debris:AddItem(clone, 3)
		Util.Sound:Play("ShadowGlide", position, nil, 2 + math.random(-20, 20) / 100, 0.4)
		clone.Parent = _WorldOrigin
		local v2 = position
		local v4 = position
		local v5 = {
			position,
			v2 + (position2 - v2) * 0.33 + Vector3.new(math.random(-35, 35), math.random(-1, 10), math.random(-35, 35)),
			v4 + (position2 - v4) * 0.66 + Vector3.new(math.random(-35, 35), math.random(-1, 10), math.random(-35, 35)),
			position2
		}
		local v6 = math.random(3, 5) / 10
		local lastTime = tick()

		while tick() - lastTime <= v6 do
			local v7 = tick() - lastTime
			clone.Position = cubicBezier(math.max(0.001, v7) / v6, unpack(v5))
			RunService.RenderStepped:Wait()
		end

		clone.Orbs.Enabled = false
		wait(1)

		if clone then
			clone:Destroy()
		end
	end)
end

local function blast(cframe)
	Util.Sound:Play("ShortExplosion3", cframe.p, nil, 1.5 + math.random(-10, 10) / 100, 0.5)
	local cFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
	shockwaveRing(cFrame, 20, 1, 1.5)
	shockwaveRing(cFrame, 30, 1.25, 1)
	local clone = script.Blast:Clone()
	Util.Debris:AddItem(clone, 3)
	clone:SetPrimaryPartCFrame(cframe)
	local shockwave2 = clone.Shockwave
	local windSaucer = clone.WindSaucer
	local root = clone.Root
	shockwave2.Size = createVector(1, 100, 1)
	shockwave2.CFrame *= CFrame.new(0, 50, 0)
	local tween = TweenService:Create(
		shockwave2,
		TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(40, 1, 40),
			CFrame = shockwave2.CFrame * CFrame.new(0, -60, 0)
		}
	)
	tween.Completed:Connect(function()
		shockwave2:Destroy()
	end)
	local tween2 = TweenService:Create(
		windSaucer,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(30, 8.5, 30),
			CFrame = windSaucer.CFrame * CFrame.Angles(0, 3.0543261909900767, 0)
		}
	)
	tween2.Completed:Connect(function()
		windSaucer:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
	tween2:Play()
	local v2 = {
		Smoke = 10,
		SpikyShockwave = 1,
		Star = 1,
		TinyStars = 4
	}

	for _, child in pairs(root.Attachment:GetChildren()) do
		if v2[child.Name] then
			child:Emit(v2[child.Name])
		end
	end
end

local function dashWind(startCFrame, _)
	local clone = script.LeapDust:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = startCFrame
	clone.Parent = _WorldOrigin
	clone.Attachment.Dust:Emit(8)
	local clone2 = script.DashModel:Clone()
	Util.Debris:AddItem(clone2, 5)
	clone2:SetPrimaryPartCFrame(startCFrame)
	clone2.Parent = _WorldOrigin
	local _ = clone2.Core
	local wind1 = clone2.Wind1
	local wind2 = clone2.Wind2
	local longSwirl = clone2.LongSwirl
	longSwirl.Size = createVector(20, 5, 20)
	task.spawn(function()
		TweenService:Create(longSwirl, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			Transparency = 1,
			Size = createVector(2, 40, 2)
		}):Play()
		TweenService:Create(wind1, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			Transparency = 1,
			Size = createVector(3, 40, 3),
			Color = Color3.fromRGB(62, 19, 122)
		}):Play()
		TweenService:Create(wind2, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {
			Transparency = 1,
			Size = createVector(1, 40, 1),
			Color = Color3.fromRGB(29, 16, 100)
		}):Play()
		local lastTime = tick()
		local v = 0.016666666666666666

		while true do
			local v2 = tick() - lastTime

			if v2 > 2 then
				break
			end

			clone2:SetPrimaryPartCFrame(clone2.Core.CFrame * CFrame.Angles(0, 0, (math.rad(v * 1 * 60))))
			longSwirl.CFrame = longSwirl.CFrame * CFrame.new(0, (3 + -2.8 * (v2 / 1)) * v * 60, 0) * CFrame.Angles(
				0,
				math.rad((30 + -30 * (v2 / 1)) * v * 60),
				0
			)
			wind1.CFrame *= CFrame.new(0, (0.5 + -0.5 * (v2 / 2)) * v * 60, 0)
			wind2.CFrame *= CFrame.new(0, (1.6 + -1.6 * (v2 / 2)) * v * 60, 0)
			v = RunService.RenderStepped:Wait()
		end
	end)
end

return function(instance)
	local stage = instance.Stage or 1

	if stage == 1 then
		local hand = instance.Hand

		if hand then
			if (hand.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local holdValue = instance.HoldValue
			local humanoid = instance.Humanoid

			if holdValue and humanoid then
				local clone = script.HandParticles.Attachment:Clone()
				Util.Debris:AddItem(clone, 300)
				clone.Parent = hand
				TweenService:Create(
					Util.Sound:Play("ShadowAura", hand.Position, nil, 0.5 + math.random(-10, 10) / 100, 1),
					TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0),
					{
						PlaybackSpeed = 2,
						Volume = 1
					}
				):Play()
				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				else
					diedConnection = nil
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < 0.25 or diedConnection and instance.HoldValue and instance.HoldValue.Value == true
				end

				while (tick() - lastTime < 0.25 or diedConnection and instance.HoldValue and instance.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoid do
					RunService.RenderStepped:Wait()
				end

				if clone then
					clone:Destroy()
				end

				if diedConnection then
					diedConnection:Disconnect()
				end
			end
		end
	elseif stage == 2 then
		local startCFrame = instance.StartCFrame

		if (startCFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local userRoot = instance.UserRoot

		if userRoot then
			dashWind(startCFrame, 10)
			TweenService:Create(
				Util.Sound:Play("ElectricBallShot", userRoot, nil, 0.9 + math.random(-10, 10) / 100, 1),
				TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0),
				{
					PlaybackSpeed = 0.4,
					Volume = 1
				}
			):Play()
			Util.Sound:Play("thrown", userRoot, nil, 0.6, 1)
			local lifetime = instance.Lifetime
			local distance = instance.Distance
			local _ = instance.Timestamp
			local v2 = nil
			local childAddedConnection = userRoot.ChildAdded:Connect(function(cFrameValue)
				if cFrameValue:IsA("CFrameValue") and cFrameValue.Name == "ShadowFruitGrabbed" then
					if v2 then
						v2:Cancel()
					end

					userRoot.CFrame = cFrameValue.Value
				end
			end)
			task.spawn(function()
				wait(5)
				childAddedConnection:Disconnect()
			end)
			local _, v3 = Util.Ray(
				userRoot.CFrame.p,
				startCFrame.LookVector * distance,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			v2 = TweenService:Create(
				userRoot,
				TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = CFrame.new(v3, v3 + startCFrame.LookVector) - startCFrame.LookVector * 2
				}
			)
			v2.Completed:Connect(function()
				Util.BodyMover.new(userRoot.Parent):Create("BodyGyro", {
					Duration = 0.1,
					CFrame = startCFrame
				})
				Util.BodyMover.new(userRoot.Parent):Create("BodyPosition", {
					Duration = 0.1,
					Position = userRoot.Position
				})
			end)
			v2:Play()
		end
	elseif stage == 3 then
		if (instance.UserCF.p - workspace.CurrentCamera.CFrame.p).magnitude > 2000 then
			return
		end

		local user = instance.User
		local userCF = instance.UserCF
		local victim = instance.Victim
		local timestamp = instance.Timestamp
		local duration = instance.Duration
		victim:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart = user:FindFirstChild("HumanoidRootPart")
		local v = math.max(duration - (masterClock:GetTime() - timestamp), 0.1)

		if user and humanoidRootPart then
			Util.Sound:Play("BuddhaGrab", humanoidRootPart, nil, 1.5, 1)
			local shadowCGrab = Util.Anims:Get(user, "ShadowCGrab")
			shadowCGrab:Play()
			local rightHand = user:FindFirstChild("RightHand")
			local humanoid = user:FindFirstChild("Humanoid")
			local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
			local humanoid2 = victim:FindFirstChild("Humanoid")

			if rightHand and humanoidRootPart2 and humanoid and humanoid2 then
				task.spawn(function()
					local v2 = Util.BodyMover.new(user):Create("BodyGyro", {
						CFrame = userCF
					})
					local v3 = Util.BodyMover.new(user):Create("BodyPosition", {
						Position = userCF.p
					})
					task.spawn(function()
						local p = userCF.p
						local character = game.Players.LocalPlayer.Character

						if character ~= nil then
							local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart3 and (humanoidRootPart3.Position - p).magnitude <= 60 then
								Util.CameraShaker:ShakeOnce(4, 6, 0.5, 1)
							end
						end
					end)
					wait(v)
					v2:Destroy()
					v3:Destroy()
				end)
				local lastTime = tick()
				local now = 0
				local now2 = 0
				local now3 = 0

				while RunService.RenderStepped:Wait() and humanoidRootPart and humanoid and humanoidRootPart2 and humanoid2 and not (humanoid2.Health <= 0 or humanoid.Health <= 0 or v < tick() - lastTime) do
					if tick() - now > 0.05 then
						lifeOrb(humanoidRootPart2.Position, humanoidRootPart.Position) -- equivalent call inferred; original call site unknown
						now = tick()
					end

					if tick() - now2 > 0.1 then
						shockwave(CFrame.new(humanoidRootPart.Position - createVector(0, 3, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						))
						now2 = tick()
					end

					if tick() - now3 > 0.2 then
						local function fn()
							Util.CameraShaker:ShakeOnce(8, 8, 0.5, 1)
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
							colorCorrectionEffect.Parent = game.Lighting
							local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.1), {
								Brightness = 0.04,
								Contrast = 0.04,
								Saturation = -0.12,
								TintColor = Color3.new(0.9, 0.9, 0.9)
							})
							tween.Completed:Connect(function()
								task.wait(0.1)
								local tween2 = TweenService:Create(colorCorrectionEffect, TweenInfo.new(1.2), {
									Brightness = 0,
									Contrast = 0,
									Saturation = 0,
									TintColor = Color3.new(1, 1, 1)
								})
								tween2.Completed:Connect(function()
									colorCorrectionEffect:Destroy()
								end)
								tween2:Play()
							end)
							tween:Play()
						end

						viewerIsClose(userCF.p, 60, fn) -- equivalent call inferred; original call site unknown
						now3 = tick()
					end

					if not humanoidRootPart2.Parent or humanoidRootPart2.Parent:FindFirstChild("AntiMover") then
						continue
					end

					humanoidRootPart2.CFrame = rightHand.CFrame * CFrame.new(0, -0.5, 0.5) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
				end

				if shadowCGrab then
					shadowCGrab:Stop()
				end

				blast(userCF * CFrame.new(0, 1, -2))
				task.spawn(function()
					local p = userCF.p
					local character = game.Players.LocalPlayer.Character

					if character ~= nil then
						local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart3 and (humanoidRootPart3.Position - p).magnitude <= 60 then
							Util.CameraShaker:ShakeOnce(16, 16, 0.25, 1.5)
						end
					end
				end)
			end
		end
	end
end