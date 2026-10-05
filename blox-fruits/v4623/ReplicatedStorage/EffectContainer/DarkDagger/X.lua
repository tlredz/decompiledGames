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

function cflerp(object, p, p2)
	return object:lerp(p, p2)
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

local function ribbonPart(duration, p, cFrame)
	local clone = script.Ribbon:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.CFrame = cFrame
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = clone.CFrame * CFrame.Angles(0, 3.12413936106985, 0),
			Transparency = 1,
			Size = clone.Size * p,
			Color = Color3.fromRGB(0, 0, 0)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function hitEffect(position, victimRoot)
	local clone = script.HitEffects:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.Position = position
	local dustEmitter = clone.DustEmitter
	Util.Debris:AddItem(dustEmitter, 2)
	dustEmitter.Parent = victimRoot
	task.spawn(function()
		dustEmitter.Enabled = true
		wait(0.5)
		dustEmitter.Enabled = false
	end)
	clone.Parent = _WorldOrigin
	dustEmitter:Emit(10)
	clone.HitEmitter:Emit(1)
	clone.HitEmitterShadow:Emit(1)
end

local function backstabSlash(cframe)
	local clone = script.TriSlash:Clone()
	Util.Debris:AddItem(clone, 3)
	clone:SetPrimaryPartCFrame(cframe)
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone:GetChildren()) do
		if child.Name == "Top" then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = child.CFrame * CFrame.Angles(0, 2.9670597283903604, 0),
					Transparency = 0,
					Size = child.Size * 1.5
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Middle" then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = child.CFrame * CFrame.Angles(0, 2.792526803190927, 0),
					Transparency = 0,
					Size = child.Size * 1.6
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		elseif child.Name == "Bottom" then
			local tween = TweenService:Create(
				child,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
				{
					CFrame = child.CFrame * CFrame.Angles(0, 2.6179938779914944, 0),
					Transparency = 0,
					Size = child.Size * 1.7
				}
			)
			local v = child
			tween.Completed:Connect(function()
				v:Destroy()
			end)
			tween:Play()
		end
	end
end

local function shatterExplosion(position)
	Util.Sound:Play("Hit1Electric", position, nil, 0.8, 0.5)
	local chorusSoundEffect = Instance.new("ChorusSoundEffect")
	chorusSoundEffect.Depth = 0.55
	chorusSoundEffect.Mix = 0.25
	chorusSoundEffect.Priority = 1
	chorusSoundEffect.Rate = 2
	local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
	pitchShiftSoundEffect.Octave = 1.31
	local parent = Util.Sound:Play("IceExplosion", position, nil, 1.2, 0.5)
	chorusSoundEffect.Parent = parent
	pitchShiftSoundEffect.Parent = parent
	TweenService:Create(
		Util.Sound:Play("DiscCharge", position, nil, 0.2, 0.15),
		TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0),
		{
			PlaybackSpeed = 3
		}
	):Play()
	local clone = script.ImpactParticles:Clone()
	Util.Debris:AddItem(clone, 3)
	local blackOrbs = clone.BlackOrbs
	local static = clone.Static
	clone.Position = position
	ribbonPart(
		0.2,
		5,
		CFrame.new(position) * CFrame.Angles(
			math.rad((math.random(-180, 180))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-180, 180))))
		)
	)
	ribbonPart(
		0.2,
		5,
		CFrame.new(position) * CFrame.Angles(math.rad((math.random(-180, 180))), math.rad((math.random(-180, 180))), 0)
	)
	ribbonPart(
		0.6,
		10,
		CFrame.new(position) * CFrame.Angles(
			math.random(-180, 180),
			math.rad((math.random(-180, 180))),
			math.random(-180, 180)
		)
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, false, 0),
		{
			CFrame = clone.CFrame * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				3.141592653589793,
				(math.rad((math.random(-90, 90))))
			)
		}
	)
	tween.Completed:Connect(function()
		blackOrbs.Enabled = false
		static.Enabled = false
		tween:Play()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function daggerProjectile(cFrame, positionObject, timestamp, lifetime, distance)
	Util.Sound:Play("PawBarrageShoot", cFrame.p, nil, 3, 2)
	local clone = script.DarkDaggerProjectile:Clone()
	Util.Debris:AddItem(clone, lifetime + 5)
	local bladeAt = clone.BladeAt
	local kiAura = bladeAt.KiAura
	local lines = bladeAt.Lines
	local trail = clone.Trail
	clone.Parent = _WorldOrigin
	TweenService:Create(
		Util.Sound:Play("KiDashLoop", clone, nil, 2 + math.random(-10, 10) / 100, 0.55),
		TweenInfo.new(lifetime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			PlaybackSpeed = 0.5
		}
	):Play()
	local v2 = masterClock:GetTime() - timestamp
	local _ = cFrame.lookVector
	local value = false
	positionObject.Changed:Connect(function()
		value = positionObject.Value or nil
	end)
	local lastTime = tick()
	local lastTime2 = tick()
	local v3 = cFrame
	local v4 = v3
	v3 = v4

	while tick() - lastTime + v2 < lifetime do
		local _ = (tick() - lastTime + v2) / lifetime
		local v6 = (tick() - lastTime + v2) / 100 / (lifetime / 100)
		local lerped = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v6)
		clone.CFrame = lerped * CFrame.Angles(-1.5707963267948966, 0, 0)

		if tick() - lastTime2 > 0.1 then
			kiAura:Emit(1)
			lastTime2 = tick()
		end

		local magnitude = (v4.p - lerped.p).Magnitude
		local ray, _, _ = Util.Ray(
			v4.p,
			v4.lookVector.Unit * magnitude,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if value then
			clone.Position = positionObject.Value
			v3 = v4
			break
		else
			if ray then
				v3 = v4
				break
			end

			RunService.RenderStepped:Wait()
			v3 = v4
			v4 = lerped
		end
	end

	if clone then
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 5)
		part.Size = Vector3.new()
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Position = v3.p
		part.Parent = _WorldOrigin
		kiAura.Parent = part
		lines.Parent = part
		trail.Parent = part
		kiAura.Enabled = false
		lines.Enabled = false
		trail.Enabled = false
		shatterExplosion(clone.Position)
		clone:Destroy()
	end
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local char = data.Char
		local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			end

			TweenService:Create(
				Util.Sound:Play("DiscCharge", humanoidRootPart.Position, nil, 0.2 + math.random(-42, 42) / 100, 1),
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					PlaybackSpeed = 2,
					Volume = 0
				}
			):Play()
			local attachment = Instance.new("Attachment")
			Util.Debris:AddItem(attachment, 2)
			attachment.Parent = humanoidRootPart
			local particleEmitter = Instance.new("ParticleEmitter")
			Util.Debris:AddItem(particleEmitter, 2)
			particleEmitter.Texture = "http://www.roblox.com/asset/?id=7252695305"
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 10),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 93))
			particleEmitter.LightInfluence = 0
			particleEmitter.LightEmission = 1
			particleEmitter.Rate = 0
			particleEmitter.Lifetime = NumberRange.new(0.2)
			particleEmitter.Parent = attachment
			particleEmitter:Emit(1)
		end
	elseif stage == 2 then
		local cFrame = data.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
			return
		end

		local lifetime = data.Lifetime
		local distance = data.Distance
		local positionObject = data.PositionObject
		local timestamp = data.Timestamp
		ribbonPart(0.25, 2, cFrame * CFrame.new(0, 0, -2) * CFrame.Angles(-1.5707963267948966, 0, 0))
		daggerProjectile(cFrame, positionObject, timestamp, lifetime, distance)
	elseif stage == 3 then
		local user = data.User
		local userCF = data.UserCF
		local victim = data.Victim
		local victimCF = data.VictimCF
		local timestamp = data.Timestamp
		local camShift = data.CamShift
		local v = masterClock:GetTime() - timestamp
		local victimRoot = data.VictimRoot or victim:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart = user:FindFirstChild("HumanoidRootPart")
		local v2 = math.max(0.6 - v, 0.1)

		if user and humanoidRootPart then
			Util.Sound:Play("ElectricBallShot", humanoidRootPart, nil, 1.2, 1)

			if camShift and game.Players.LocalPlayer.Character and humanoidRootPart.Parent == game.Players.LocalPlayer.Character then
				local currentCamera = workspace.CurrentCamera
				local cFrame = currentCamera.CFrame
				local _ = cFrame.p - humanoidRootPart.Position
				local orientation, _, _ = (cFrame - cFrame.p):ToOrientation()
				local _, v3, v4 = userCF:ToOrientation()
				RunService:BindToRenderStep("darkDaggerTeleportCam", Enum.RenderPriority.Camera.Value + 1, function()
					if currentCamera then
						currentCamera.CFrame = cflerp(
							currentCamera.CFrame,
							CFrame.new(userCF.p) * CFrame.fromOrientation(orientation, v3, v4),
							0.15
						)
					else
						RunService:UnbindFromRenderStep("darkDaggerTeleportCam")
					end

					RunService.RenderStepped:Wait()
				end)
				task.spawn(function()
					wait(v2)
					RunService:UnbindFromRenderStep("darkDaggerTeleportCam")
				end)
			end

			task.spawn(function()
				user.HumanoidRootPart.CFrame = userCF
				local v3 = Util.BodyMover.new(user):Create("BodyGyro", {
					Priority = 1e999,
					CFrame = userCF
				})
				local v4 = Util.BodyMover.new(user):Create("BodyPosition", {
					Priority = 1e999,
					Position = userCF.p
				})
				local clone = script.TeleportTrail:Clone()
				Util.Debris:AddItem(clone, 5)
				local lAt = clone.LAt
				local rAt = clone.RAt
				lAt.Position = createVector(0, 5, 0)
				rAt.Position = createVector(0, -5, 0)

				for _, child in pairs(clone:GetChildren()) do
					Util.Debris:AddItem(child, 3)
					child.Parent = humanoidRootPart
				end

				wait(v2 / 2)
				local darkDaggerXHit = Util.Anims:Get(user, "DarkDaggerXHit")
				darkDaggerXHit:Play()
				darkDaggerXHit:AdjustSpeed(1)
				Util.Sound:Play("BackStab", humanoidRootPart, nil, 1.2, 1)
				task.spawn(function()
					wait(v2 / 4)
					backstabSlash(userCF * CFrame.Angles(0.3490658503988659, 2.6179938779914944, -0.8726646259971648))

					if victimRoot ~= nil then
						hitEffect(victimRoot.Position, victimRoot)
					end

					local p = userCF.p
					local character = game.Players.LocalPlayer.Character

					if character ~= nil then
						local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 and (humanoidRootPart2.Position - p).magnitude <= 60 then
							Util.CameraShaker:ShakeOnce(5, 15, 0.3, 0.5)
						end
					end
				end)
				wait(v2 / 2)
				v3:Destroy()
				v4:Destroy()

				if lAt then
					lAt:Destroy()
				end

				if rAt then
					rAt:Destroy()
				end
			end)
		end

		if victimRoot then
			task.spawn(function()
				victimRoot.CFrame = victimCF
				wait(v2)
			end)
		end
	end
end