local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local C = FX:WaitForChild("Soul").C
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local lightningBolt = Util.LightningBolt

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

local function getResource(p, p2, items)
	local clone = C[p]:Clone()

	if p2 then
		Util.Debris:AddItem(clone, p2)
	end

	if items then
		for k, item in pairs(items) do
			if clone[k] then
				clone[k] = item
			end
		end
	end

	return clone
end

local function debrisPart(data, p, p2)
	local v = math.random(40, 100) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 3)
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
	part.Velocity = part.CFrame.lookVector.Unit * math.random(90, 130)
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

local function lightningStrike(p, p2)
	local ray, v, v2 = Util.Ray(
		p,
		CFrame.new(p, p - createVector(0, 1, 0)).lookVector.Unit * p2,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	Util.Sound:Play("Thunderclap", p, nil, math.random(9, 13) / 10, 2)
	local cframe = CFrame.new(p, v)
	local clone = C.CloudMesh:Clone()
	Util.Debris:AddItem(clone, 3)
	clone.Size = Vector3.new()
	clone.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, math.rad((math.random(1, 360))), 0)
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Size = createVector(40, 12, 40)
		}
	)
	tween.Completed:Connect(function()
		if clone then
			clone:Destroy()
		end
	end)
	tween:Play()
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 3)
	part.Size = Vector3.new()
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = cframe
	part.Parent = _WorldOrigin
	local part2 = Instance.new("Part")
	Util.Debris:AddItem(part2, 3)
	part2.Size = Vector3.new()
	part2.Anchored = true
	part2.CanCollide = false
	part2.Transparency = 1
	part2.CFrame = CFrame.new(v)
	part2.Parent = _WorldOrigin
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = part2

	if ray then
		local clone2 = C.Orbs:Clone()
		clone2.Parent = attachment2
		local clone3 = C.Spikes:Clone()
		clone3.Parent = attachment2
		clone2:Emit(15)
		clone3:Emit(15)
		task.spawn(function()
			for _ = 1, math.random(2, 3) do
				debrisPart(ray, v, v2)
			end
		end)
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - v).magnitude <= 50 then
				Util.CameraShaker:ShakeOnce(7, 7, 0.5, 0.5)
			end
		end
	end

	local v3 = lightningBolt.new(
		attachment,
		attachment2,
		math.random(-20, 20),
		math.random(-20, 20),
		math.random(15, 20)
	)
	v3.Color = Color3.fromRGB(119, 0, 255)

	for _, part3 in pairs(v3.Parts) do
		part3.Color = v3.Color
	end

	v3.AnimationSpeed = 15
	v3.FadeLength = 0.5
	v3.Thickness = 1.8
	v3.MaxAngleOffset = 0.5235987755982988
	task.spawn(function()
		wait(0.2)
		v3:Destroy()
	end)
end

local function electricDischarge(position, root, charges)
	task.spawn(function()
		for _ = 1, charges do
			lightningStrike(position + Vector3.new(math.random(-40, 40), 45, math.random(-40, 40)), 110)
			task.wait(2 / (charges * 2))
		end
	end)
	local ray, v, _ = Util.Ray(
		position,
		CFrame.new(position, position - createVector(0, 1, 0)).lookVector.Unit * 100,
		{ workspace.Characters, workspace.Enemies },
		false
	)
	local v2 = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
	TweenService:Create(
		Util.Sound:Play("ElectricZap", position, nil, 0.8, 1),
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Pitch = 1.5
		}
	):Play()
	TweenService:Create(
		Util.Sound:Play("PlasmaZap", position, nil, 2, 2),
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Pitch = 0.3
		}
	):Play()
	Util.Sound:Play("ElectricBuzz", position, nil, 0.5, 2)
	Util.Sound:Play("Thunderclap", position, nil, 1, 3)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 150 then
			Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.3)
		end
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Position = v2.p
	part.Parent = _WorldOrigin
	Util.Debris:AddItem(part, 6)
	local v5 = {
		Burst = 5,
		FlickerWaves = 5,
		Lightning = 10,
		Rays = 10,
		Ring = 2,
		Shockwave = 3,
		Sparks = 10,
		Spikes = 5
	}

	for _, emitter in pairs(C:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		clone.Parent = part

		if not v5[clone.Name] then
			continue
		end

		clone:Emit(v5[clone.Name])

		if clone.Name ~= "Lightning" then
			continue
		end

		local v6 = clone
		task.spawn(function()
			wait(1)
			v6.Enabled = false
		end)
	end

	local clone = C.LightningGlow:Clone()
	clone.Brightness = 0
	clone.Range = 0
	clone.Parent = part
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0), {
		Brightness = 3,
		Range = 57
	}):Play()
	local clone2 = C.CloudMesh:Clone()
	Util.Debris:AddItem(clone2, 3)
	clone2.Size = Vector3.new()
	clone2.CFrame = v2 * CFrame.Angles(0, 0.9, 0)
	clone2.Parent = _WorldOrigin
	local tween = TweenService:Create(
		clone2,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
		{
			Size = createVector(55, 10, 55)
		}
	)
	tween.Completed:Connect(function()
		if clone2 then
			clone2:Destroy()
		end
	end)
	tween:Play()
	task.spawn(function()
		wait(1)
		local tween2 = TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Brightness = 0,
				Range = 0
			}
		)
		tween2.Completed:Connect(function()
			if clone then
				clone:Destroy()
			end
		end)
		tween2:Play()
	end)
	local v6 = {}
	local v7 = 0.016666666666666666
	local now = tick()
	local total = 0
	task.spawn(function()
		local now2 = tick()
		local now3 = tick()

		while true do
			local now4 = tick()
			local v8 = now4 - now

			if v8 > 1.7 then
				break
			end

			local _ = v8 / 2.2

			if clone2 and root then
				clone2.CFrame = CFrame.new(root.Position - createVector(0, 5, 0)) * CFrame.Angles(
					0,
					math.rad(-total * (v7 * 60)),
					0
				)
				total += 10
			end

			if v8 < 1.3 then
				if now4 - now2 > 0.15 and ray then
					local resource = getResource("BlastWave", 0.7, {
						CFrame = CFrame.new(v + createVector(0, 15, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						),
						Size = createVector(0, 30, 0)
					})
					resource.Parent = _WorldOrigin
					table.insert(v6, { 1, resource })
					now2 = tick()
					local tween2 = TweenService:Create(
						resource,
						TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Position = resource.Position - createVector(0, 15, 0),
							Size = createVector(100, 5, 100),
							Transparency = 1
						}
					)
					tween2.Completed:Connect(function()
						if resource then
							resource:Destroy()
						end
					end)
					tween2:Play()
				end

				if now4 - now3 > 0.2 then
					local resource = getResource("WindRing", 0.7, {
						CFrame = CFrame.new(position + createVector(0, 10, 0)) * CFrame.Angles(
							0,
							math.rad((math.random(-180, 180))),
							0
						),
						Transparency = 0.5,
						Size = createVector(0, 0, 0)
					})
					resource.Parent = _WorldOrigin
					table.insert(v6, { 2, resource })
					now3 = tick()
					local tween2 = TweenService:Create(
						resource,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Position = resource.Position - createVector(0, -15, 0),
							Size = createVector(69.859, 1, 69.164),
							Transparency = 1
						}
					)
					tween2.Completed:Connect(function()
						if resource then
							resource:Destroy()
						end
					end)
					tween2:Play()
				end
			end

			if #v6 > 0 then
				local v9 = v7 * 60

				for k, v10 in pairs(v6) do
					if v10[2] == nil then
						table.remove(v6, k)
					elseif v10[1] == 0 then
						v10[2].CFrame *= CFrame.new(0, v9 * -0.25, 0) * CFrame.Angles(0, math.rad(v9 * -25), 0)
					elseif v10[1] == 1 then
						v10[2].CFrame *= CFrame.new(0, v9 * 0.1, 0) * CFrame.Angles(0, math.rad(v9 * 25), 0)
						local v12 = v10[2]
						local transparency = v10[2].Transparency
						local v13 = v9 * 0.07
						v12.Transparency = transparency + (1 - transparency) * v13
					elseif v10[1] == 2 then
						v10[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v9 * 25), 0)
					end
				end
			end

			v7 = RunService.RenderStepped:Wait()
		end

		if #v6 > 0 then
			for _, v8 in pairs(v6) do
				if v8[2] then
					v8[2]:Destroy()
				end
			end
		end

		v6 = nil
	end)
end

return function(player)
	local stage = player.Stage or 1

	if stage == 1 then
		local root = player.Root
		local humanoid = player.Humanoid
		local _ = player.Character
		local holdValue = player.HoldValue
		local _ = player.ChargeTime

		if humanoid and root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local diedConnection = nil

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
			end

			local lastTime = tick()

			local function running()
				return tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true
			end

			local lastTime2 = tick()

			while (tick() - lastTime < 0.25 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid do
				local _ = tick() - lastTime2 > 0.25
				RunService.RenderStepped:Wait()
			end

			if diedConnection then
				diedConnection:Disconnect()
			end
		end
	else
		if stage == 2 then
			return
		end

		if stage == 3 then
			local position = player.Position
			local root = player.Root

			if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			else
				electricDischarge(position, root, player.Charges or 5)
			end
		end
	end
end