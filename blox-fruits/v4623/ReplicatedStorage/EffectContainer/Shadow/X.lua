local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local v = { -1, 1 }

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
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

local function lingeringSlashParticles(position)
	local clone = script.SlashParticlePart:Clone()
	Util.Debris:AddItem(clone, 4)
	local slashParticles = clone.SlashParticles
	clone.Position = position
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone.SparkFX:GetChildren()) do
		if child.Name == "Sparks" then
			child:Emit(8)
		else
			child:Emit(1)
		end
	end

	task.spawn(function()
		for _ = 1, 8 do
			slashParticles:Emit(1)
			wait(0.1)
		end
	end)
	TweenService:Create(
		slashParticles,
		TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			TimeScale = 0.3
		}
	):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lingeringSlash(cFrame, duration, size)
	task.spawn(function()
		local clone = script.Slash:Clone()
		Util.Debris:AddItem(clone, duration)
		clone.CFrame = cFrame
		clone.Size = createVector(2, 0.1, 2)
		clone.Transparency = 0.3
		clone.Color = Color3.fromRGB(95, 95, 95)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				Size = size,
				Transparency = 1,
				Color = Color3.fromRGB(0, 0, 0)
			}
		)
		clone.Parent = _WorldOrigin
		tween:Play()
		local lastTime = tick()
		local v2 = 0.016666666666666666

		while true do
			local v3 = tick() - lastTime

			if duration < v3 then
				break
			end

			clone.CFrame = clone.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(
				0,
				math.rad((25 + -25 * (v3 / duration)) * v2 * 60),
				0
			)
			v2 = RunService.RenderStepped:Wait()
		end
	end)
end

local function slashEffect(cFrame, duration, size, transparency)
	local clone = script.Slash:Clone()
	Util.Debris:AddItem(clone, duration)
	clone.Size = Vector3.new()
	clone.CFrame = cFrame
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = size,
			CFrame = cFrame * CFrame.Angles(0, 3.0543261909900767, 0),
			Transparency = transparency,
			Color = Color3.fromRGB(255, 255, 255)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function sphere(cFrame)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 1.5)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(93, 0, 255)
	part.Size = createVector(1, 1, 1)
	part.CastShadow = false
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.Parent = part
	specialMesh.MeshType = Enum.MeshType.Sphere
	part.CFrame = cFrame
	part.Size = createVector(0.3, 0.3, 3)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = Vector3.new(0.25, 0.25, math.random(10, 15)),
			CFrame = part.CFrame * CFrame.new(0, 0, 15),
			Transparency = 1,
			Color = Color3.fromRGB(69, 29, 104)
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	part.Parent = _WorldOrigin
	tween:Play()
end

local function tornado(cFrame)
	local v2 = v[math.random(1, 2)]
	local clone = script.Tornado:Clone()
	Util.Debris:AddItem(clone, 1)
	clone.Size = Vector3.new()
	clone.CFrame = cFrame
	clone.Transparency = 0.3
	local v3 = math.random(35, 45)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = Vector3.new(v3, v3, v3),
			CFrame = cFrame * CFrame.Angles(0, math.rad(175 * v2), 0),
			Transparency = 1,
			Color = Color3.fromRGB(57, 26, 104)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	clone.Parent = _WorldOrigin
	tween:Play()
end

local function cone(cframe, _)
	local clone = script.CrowDashCone:Clone()
	Util.Debris:AddItem(clone, 1)
	clone:SetPrimaryPartCFrame(cframe)
	local inner = clone.Inner
	local outer = clone.Outer
	clone.Parent = _WorldOrigin

	for _, v2 in pairs({ inner.Decal, outer.Decal }) do
		local tween = TweenService:Create(
			v2,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 1
			}
		)
		local v3 = v2
		tween.Completed:Connect(function()
			v3:Destroy()
		end)
		tween:Play()
	end

	for _, v2 in pairs({ inner.Mesh, outer.Mesh }) do
		local tween = TweenService:Create(
			v2,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Scale = createVector(0.7, 1.1, 0.7)
			}
		)
		local v3 = v2
		tween.Completed:Connect(function()
			v3:Destroy()
		end)
		tween:Play()
	end

	return clone
end

local function crowManProjectile(cFrame, positionObject, timestamp, lifetime, distance)
	local clone = script.SmokeHumanoid:Clone()
	Util.Debris:AddItem(clone, lifetime + 5)
	local animationController = Instance.new("AnimationController")
	animationController.Parent = clone
	clone.Parent = _WorldOrigin
	local track = animationController:LoadAnimation(clone.ShadowXProjectile)
	track:Play()
	track.TimePosition = 0.4
	track:AdjustSpeed(0.025)
	Util.Sound:Play("CrowShot", clone.Head, nil, 1 + math.random(-15, 15) / 100, 2)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(20)
		end
	end

	local v2 = masterClock:GetTime() - timestamp
	local _ = cFrame.lookVector
	local position2 = false
	positionObject.Changed:Connect(function()
		position2 = positionObject.Value
		track.TimePosition = 0.4
		track:AdjustSpeed(1)
	end)
	local lastTime = tick()
	local now = tick() - 0.2
	local lastTime2 = tick()
	local lastTime3 = tick()
	local v3 = cFrame
	local v4 = v3
	v3 = v4
	local v6 = {}
	local v7 = { -25, 25 }

	while tick() - lastTime + v2 < lifetime do
		local _ = (tick() - lastTime + v2) / lifetime
		local v8 = (tick() - lastTime + v2) / 100 / (lifetime / 100)
		local lerped = cFrame:Lerp(cFrame * CFrame.new(0, 0, -distance), v8)
		clone:SetPrimaryPartCFrame(lerped)
		local magnitude = (v4.p - lerped.p).Magnitude

		if #v6 > 0 then
			v3 = v4
			v4 = lerped

			for _, v9 in pairs(v6) do
				if not (v9 ~= nil and v9.PrimaryPart ~= nil) then
					continue
				end

				local v10 = v9.PrimaryPart.CFrame - v9.PrimaryPart.CFrame.p
				v9:SetPrimaryPartCFrame(CFrame.new(v4.p) * v10)
			end
		else
			v3 = v4
			v4 = lerped
		end

		if tick() - now > 0.05 then
			tornado(v4 * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0))
			table.insert(
				v6,
				(cone(v4 * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(0, math.random(-180, 180), 0)))
			)
			now = tick()
		end

		if tick() - lastTime3 > 0.15 then
			local v9 = v[math.random(1, 2)]
			local v10 = v7[math.random(1, 2)]
			local cframe = CFrame.Angles(0, math.rad((math.random(-180, 180))), (math.rad((math.random(-30, 30)))))
			local p = (v4 * cframe * CFrame.new(v10, 0, 0)).p
			local p2 = (v4 * cframe * CFrame.new(-v10, 0, 0)).p
			local bezier = {
				p,
				p + (p2 - p) * 0.33 + Vector3.new(0, v9 * 25, 0),
				p + (p2 - p) * 0.66 + Vector3.new(0, v9 * 25, 0),
				p2
			}
			Effect.new("Shadow.Crows"):replicate({
				Type = 0,
				Life = math.random(30, 45) / 100,
				Bezier = bezier
			})
			lastTime3 = tick()
		end

		if tick() - lastTime2 > 0.025 then
			sphere(v4 * CFrame.new(math.random(-5, 5), math.random(-5, 5), -8))
			lastTime2 = tick()
		end

		local ray, v9, _ = Util.Ray(
			v3.p,
			v3.lookVector.Unit * magnitude,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if position2 then
			TweenService:Create(
				clone.HumanoidRootPart,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					CFrame = CFrame.new(v3.p, position2)
				}
			):Play()
			local cframe = CFrame.new(v3.p, position2)
			slashEffect(cframe * CFrame.Angles(0, 0, 0.5235987755982988), 0.15, createVector(25, 0.29, 25), 0)
			slashEffect(cframe * CFrame.Angles(0, 0, -0.5235987755982988), 0.15, createVector(25, 0.29, 25), 0)
			slashEffect(
				cframe * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0),
				0.4,
				createVector(65, 0.29, 65),
				1
			)
			local position = clone.Torso.Position
			lingeringSlashParticles(position2)
			lingeringSlash(
				CFrame.new(position) * CFrame.Angles(
					math.rad((math.random(-45, 45))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-45, 45))))
				),
				math.random(15, 20) / 10,
				createVector(65, 4, 65)
			) -- equivalent call inferred; original call site unknown
			lingeringSlash(
				CFrame.new(position) * CFrame.Angles(
					math.rad((math.random(-25, 25))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-25, 25))))
				),
				math.random(10, 15) / 10,
				createVector(45, 3, 45)
			) -- equivalent call inferred; original call site unknown
			Effect.new("Shadow.Misc"):replicate({
				Type = 3,
				Position = position2,
				Size = 25
			})
			local parent = Util.Sound:Play("QuickSlice", v3.p, nil, 1.4 + math.random(-25, 25) / 100, 0.5)
			local echoSoundEffect = Instance.new("EchoSoundEffect")
			echoSoundEffect.Delay = 0.05
			echoSoundEffect.Feedback = 0.25
			local flangeSoundEffect = Instance.new("FlangeSoundEffect")
			flangeSoundEffect.Depth = 0.8
			flangeSoundEffect.Rate = 6
			flangeSoundEffect.Parent = parent
			echoSoundEffect.Parent = parent
			TweenService:Create(
				parent,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Pitch = 0.4
				}
			):Play()
			local character = game.Players.LocalPlayer.Character

			if character == nil then
				break
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - v9).magnitude <= 100 then
				Util.CameraShaker:ShakeOnce(5, 15, 0.5, 0.5)
			end

			break
		elseif ray then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	if clone then
		if position2 then
			for _, v8 in pairs({ clone["Left Arm"].Mesh, clone["Right Arm"].Mesh }) do
				TweenService:Create(
					v8,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Scale = createVector(0.5, 2, 0.5),
						Offset = createVector(0, -0.4, 0)
					}
				):Play()
			end

			TweenService:Create(
				clone.HumanoidRootPart,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
				{
					CFrame = CFrame.new((CFrame.new(v3.p, position2) * CFrame.new(0, 10, 10)).p, position2)
				}
			):Play()
		end

		if position2 then
			wait(1)
		end

		local position = clone.Torso.Position
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 80 then
				Util.CameraShaker:ShakeOnce(3, 10, 0.5, 0.6)
			end
		end

		lingeringSlash(
			CFrame.new(position) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-25, 25))))
			),
			math.random(5, 15) / 25,
			createVector(45, 3, 45)
		) -- equivalent call inferred; original call site unknown
		lingeringSlash(
			CFrame.new(position) * CFrame.Angles(
				math.rad((math.random(-15, 15))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-15, 15))))
			),
			math.random(5, 15) / 25,
			createVector(65, 4, 65)
		) -- equivalent call inferred; original call site unknown
		Effect.new("Shadow.Misc"):replicate({
			Type = 3,
			Position = position,
			Size = 30
		})
		local clone2 = script.ShadowXExplode:Clone()
		Util.Debris:AddItem(clone2, 5)
		clone2.Position = clone.Torso.Position
		clone2.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Parent = clone2
			emitter.Enabled = false
		end

		Effect.new("Shadow.Crows"):replicate({
			Type = 3,
			LifeRange = { 4, 12 },
			Position = clone.Torso.Position
		})
		local v14 = {
			GlowDust = 5,
			LingerSmoke = 10,
			DarkDust = 10,
			Smoke = 5,
			Ray = 5,
			SpikyShockwave = 1
		}

		for _, child in pairs(clone2:GetChildren()) do
			if v14[child.Name] then
				child:Emit(v14[child.Name])
			end
		end

		Util.Sound:Play("Explosion2", v3.p, nil, 1.4 + math.random(-15, 15) / 100, 0.65)
		clone:Destroy()
	end
end

return function(player)
	local stage = player.Stage or 1

	if stage == 1 then
		local root = player.Root
		local character = player.Character
		local holdValue = player.HoldValue

		if character and root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local v2 = Util.Sound:Play("SetFire2", root, nil, 2, 1)
			local tween = TweenService:Create(
				v2,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					PlaybackSpeed = 0.1
				}
			)
			tween.Completed:Connect(function()
				v2:Destroy()
			end)
			tween:Play()
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoid then
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
					return tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true
				end

				local clone = script.HoldXEffect.Attachment:Clone()
				debris:AddItem(clone, 300)
				clone.Parent = root

				while (tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid do
					RunService.RenderStepped:Wait()
				end

				if clone then
					for _, child in pairs(clone:GetChildren()) do
						local v3 = child
						task.spawn(function()
							v3.Enabled = false
							wait(1.5)
							v3:Destroy()
						end)
					end
				end

				if diedConnection then
					diedConnection:Disconnect()
				end
			end
		end
	elseif stage == 2 then
		local cFrame = player.CFrame

		if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local lifetime = player.Lifetime
		local distance = player.Distance
		crowManProjectile(cFrame, player.PositionObject, player.Timestamp, lifetime, distance)
	end
end