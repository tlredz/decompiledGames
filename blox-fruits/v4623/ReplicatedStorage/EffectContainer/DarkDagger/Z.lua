local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
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

local function hitEffect(position)
	local clone = script.HitEffects:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Position = position
	clone.Parent = _WorldOrigin
	clone.DustEmitter:Emit(10)
	clone.HitEmitter:Emit(1)
	clone.HitEmitterShadow:Emit(1)
end

local function wind(cFrame, duration, p, p2, color)
	local clone = script.Wind:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin

	if color then
		clone.Color = color
	end

	local v = clone.Size * p2
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = Vector3.new(v.Z, 4, v.Z),
			CFrame = clone.CFrame * CFrame.Angles(0, math.rad(p), 0)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local hand = data.Hand

		if hand then
			if (hand.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			local attachment = Instance.new("Attachment")
			Util.Debris:AddItem(attachment, 2)
			attachment.Parent = hand
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 42))
			particleEmitter.LightEmission = 1
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 5),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.698, 0.153),
				NumberSequenceKeypoint.new(0.887, 0.399),
				NumberSequenceKeypoint.new(1, 1)
			})
			particleEmitter.Rate = 0
			particleEmitter.Texture = "http://www.roblox.com/asset/?id=7252568690"
			particleEmitter.Lifetime = NumberRange.new(0.25)
			particleEmitter.RotSpeed = NumberRange.new(250)
			particleEmitter.Speed = NumberRange.new(0)
			particleEmitter.LockedToPart = true
			particleEmitter.Parent = attachment
			TweenService:Create(
				Util.Sound:Play("PrimeChime", hand.Position, nil, 0.5 + math.random(-10, 10) / 100, 1),
				TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0),
				{
					PlaybackSpeed = 1,
					Volume = 1
				}
			):Play()

			for _ = 1, 3 do
				wait(0.05)
				particleEmitter:Emit(1)
			end
		end
	elseif stage == 2 then
		local startCFrame = data.StartCFrame

		if (startCFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local userRoot = data.UserRoot
		local goalCF = data.GoalCF

		if userRoot then
			Util.Sound:Play("SlightZap", userRoot, nil, 1.5, 1)
			Util.Sound:Play("thrown", userRoot, nil, 1, 1)
			local lifetime = data.Lifetime
			local distance = data.Distance
			local _ = data.Timestamp
			local v = nil
			local childAddedConnection = userRoot.ChildAdded:Connect(function(cFrameValue)
				if cFrameValue:IsA("CFrameValue") and cFrameValue.Name == "DDStabbedSomeone" then
					if v then
						v:Cancel()
					end

					userRoot.CFrame = cFrameValue.Value
				end
			end)
			task.spawn(function()
				wait(3)
				childAddedConnection:Disconnect()
			end)
			v = TweenService:Create(
				userRoot,
				TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = goalCF
				}
			)
			v.Completed:Connect(function()
				Util.BodyMover.new(userRoot.Parent):Create("BodyGyro", {
					Duration = 0.1,
					CFrame = startCFrame
				})
				Util.BodyMover.new(userRoot.Parent):Create("BodyPosition", {
					Duration = 0.1,
					Position = userRoot.Position
				})
			end)
			v:Play()
			local clone = script.Tornado:Clone()
			Util.Debris:AddItem(clone, 2)
			clone.CFrame = startCFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = _WorldOrigin
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					CFrame = clone.CFrame * CFrame.new(0, -distance / 1.5, 0) * CFrame.Angles(0, 2.9670597283903604, 0),
					Size = clone.Size * 4
				}
			)
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
			local ray, _, _ = Util.Ray(
				startCFrame.p,
				-CFrame.new(startCFrame.p).upVector.Unit * 8,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			local clone2 = script.LeapDust:Clone()
			Util.Debris:AddItem(clone2, 2)
			local dust = clone2.Attachment.Dust

			if ray ~= nil then
				local HSV, v2, v3 = ray.Color:ToHSV()
				dust.Color = ColorSequence.new(Color3.fromHSV(HSV, v2, (math.max(0, v3 * 0.7))))
			end

			clone2.CFrame = startCFrame
			clone2.Parent = _WorldOrigin
			dust:Emit(10)
			local clone3 = script.Ring:Clone()
			Util.Debris:AddItem(clone3, 1)
			clone3.CFrame = startCFrame * CFrame.new(0, 0, -distance / 4) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = _WorldOrigin
			local tween2 = TweenService:Create(
				clone3,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					Size = clone3.Size * 3
				}
			)
			tween2.Completed:Connect(function()
				clone3:Destroy()
			end)
			tween2:Play()
		end
	elseif stage == 3 then
		if (data.UserCF.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local user = data.User
		local userCF = data.UserCF
		local victim = data.Victim
		local victimCF = data.VictimCF
		local timestamp = data.Timestamp
		local _ = data.CameraShift
		local humanoidRootPart = victim:FindFirstChild("HumanoidRootPart")
		local v = masterClock:GetTime() - timestamp
		local humanoidRootPart2 = user:FindFirstChild("HumanoidRootPart")
		local v2 = math.max(0.6 - v, 0.1)

		if user and humanoidRootPart2 then
			Util.Sound:Play("MetalPierce", humanoidRootPart2, nil, 1.5, 1)
			Util.Sound:Play("ShortExplosion", humanoidRootPart2, nil, 1.2, 1)
			Util.Sound:Play("shot", humanoidRootPart2, nil, 1.5, 1)
			Util.Sound:Play("FutureWeaponExplosion", humanoidRootPart2, nil, 2.5, 1)
			local clone = script.DarkDaggerThrust:Clone()
			Util.Debris:AddItem(clone, 2)
			clone:SetPrimaryPartCFrame(CFrame.new(userCF.p, victimCF.p) * CFrame.new(0, 0, -5) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			))
			clone.Parent = _WorldOrigin
			hitEffect(victimCF.p)

			for _, child in pairs(clone:GetChildren()) do
				child.Transparency = 1
				local tween = TweenService:Create(
					child,
					TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 0,
						Size = child.Size * 3,
						CFrame = child.CFrame * CFrame.new(0, 0, 10)
					}
				)
				local v3 = child
				tween.Completed:Connect(function()
					v3:Destroy()
				end)
				tween:Play()
			end

			wind(CFrame.new(userCF.p, victimCF.p) * CFrame.Angles(1.5707963267948966, 0, 0), 0.8, 175, 2)
			wind(
				CFrame.new(userCF.p, victimCF.p) * CFrame.new(0, 0, -20) * CFrame.Angles(1.5707963267948966, 0, 0),
				1,
				-175,
				3,
				Color3.fromRGB(0, 116, 62)
			)
			wind(
				CFrame.new(userCF.p, victimCF.p) * CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
				1.2,
				175,
				4,
				Color3.fromRGB(82, 177, 114)
			)
			local ray, v3, v4 = Util.Ray(
				victimCF.p,
				-CFrame.new(victimCF.p).upVector.Unit * 8,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			local clone2 = script.LeapDust:Clone()
			Util.Debris:AddItem(clone2, 2)
			local dust = clone2.Attachment.Dust

			if ray ~= nil then
				local HSV, v5, v6 = ray.Color:ToHSV()
				dust.Color = ColorSequence.new(Color3.fromHSV(HSV, v5, (math.max(0, v6 * 0.7))))

				if humanoidRootPart then
					local clone3 = dust:Clone()
					Util.Debris:AddItem(clone3, 4)
					clone3.Rate = 120
					clone3.EmissionDirection = "Back"
					clone3.Acceleration = createVector(0, 5, 0)
					clone3.SpreadAngle = Vector2.new(-45, 45)
					clone3.Speed = NumberRange.new(15)
					clone3.Lifetime = NumberRange.new(0.25, 0.3)
					clone3.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.2, 2.3, 0.5),
						NumberSequenceKeypoint.new(0.5, 3, 1),
						NumberSequenceKeypoint.new(0.837, 2.3, 0.5),
						NumberSequenceKeypoint.new(1, 0.5)
					})
					clone3.Parent = humanoidRootPart
					clone3.Enabled = true
					task.spawn(function()
						wait(0.8)
						clone3.Enabled = false
					end)
					task.spawn(function()
						local lastTime = tick()

						while tick() - lastTime < 0.8 and clone3 ~= nil and humanoidRootPart ~= nil do
							ray, v3, v4 = Util.Ray(
								humanoidRootPart.Position,
								-CFrame.new(humanoidRootPart.Position).upVector.Unit * 8,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if ray then
								local HSV2, v7, v8 = ray.Color:ToHSV()
								clone3.Color = ColorSequence.new(Color3.fromHSV(HSV2, v7, (math.max(0, v8 * 0.7))))
							else
								clone3.Color = ColorSequence.new(Color3.fromRGB(197, 197, 197))
							end

							RunService.RenderStepped:Wait(0.03333333333333333)
						end
					end)
				end
			end

			clone2.CFrame = victimCF
			clone2.Parent = _WorldOrigin
			dust.Speed = NumberRange.new(120, 160)
			dust.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
			dust.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.2, 2.3),
				NumberSequenceKeypoint.new(0.5, 3),
				NumberSequenceKeypoint.new(0.837, 2.3),
				NumberSequenceKeypoint.new(1, 0.5)
			})
			dust.Drag = 6
			dust:Emit(20)
			local clone3 = script.Splash:Clone()
			Util.Debris:AddItem(clone3, 5)
			clone3.CFrame = CFrame.new(userCF.p, victimCF.p)
			clone3.Parent = _WorldOrigin
			clone3.BlackOrbs:Emit(math.random(10, 15))
			local tween = TweenService:Create(
				clone3,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = clone3.CFrame * CFrame.Angles(0, 0, 3.12413936106985)
				}
			)
			tween.Completed:Connect(function()
				task.spawn(function()
					wait(2)
					clone3:Destroy()
				end)
			end)
			tween:Play()
			task.spawn(function()
				local v5 = Util.BodyMover.new(user):Create("BodyGyro", {
					CFrame = userCF
				})
				local v6 = Util.BodyMover.new(user):Create("BodyPosition", {
					Position = userCF.p
				})
				task.spawn(function()
					local p = userCF.p
					local character = game.Players.LocalPlayer.Character

					if character ~= nil then
						local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart3 and (humanoidRootPart3.Position - p).magnitude <= 60 then
							Util.CameraShaker:ShakeOnce(10, 15, 0.25, 1)
						end
					end
				end)
				wait(v2 / 2)
				v5:Destroy()
				v6:Destroy()
			end)
		end
	end
end