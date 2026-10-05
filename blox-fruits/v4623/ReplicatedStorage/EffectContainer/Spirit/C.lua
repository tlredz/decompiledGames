local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local C = FX:WaitForChild("Spirit").C
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris

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

local function freezePlayer(root, p)
	if root then
		local position = root.Position
		Util.Sound:Play("IceShoot", position, nil, math.random(9, 13) / 10, 2)
		task.spawn(function()
			local resource = getResource("BlastWave", 0.7, {
				CFrame = CFrame.new(position + createVector(0, 15, 0)) * CFrame.Angles(
					0,
					math.rad((math.random(-180, 180))),
					0
				),
				Size = createVector(0, 30, 0)
			})
			resource.Parent = _WorldOrigin
			local tween = TweenService:Create(
				resource,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Position = resource.Position - createVector(0, 10, 0),
					Size = createVector(40, 3, 40),
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				if resource then
					resource:Destroy()
				end
			end)
			tween:Play()
			local cframe = CFrame.new(position)
			local v = math.random(8, 13) / 10
			local size = createVector(10, 20, 10) * Vector3.new(v, v, v)
			local resource2 = getResource("IceSpike", 5, {
				CFrame = cframe * CFrame.Angles(
					math.rad((math.random(-10, 10))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-10, 10))))
				),
				Size = createVector(0, 0, 0)
			})
			resource2.Parent = _WorldOrigin
			TweenService:Create(
				resource2,
				TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = size
				}
			):Play()

			for _ = 1, 60 * p do
				if resource2 and root then
					resource2.Position = root.Position
				end

				RunService.RenderStepped:Wait()
			end

			if resource2 and resource2.Parent ~= nil then
				resource2.Mist.Enabled = false
				local tween2 = TweenService:Create(
					resource2,
					TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
					{
						Size = createVector(0, 0, 0)
					}
				)
				tween2.Completed:Connect(function()
					if resource2 then
						resource2:Destroy()
					end
				end)
				tween2:Play()
			end
		end)
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 50 then
				Util.CameraShaker:ShakeOnce(5, 5, 0.4, 0.4)
			end
		end
	end
end

return function(instance)
	local stage = instance.Stage or 1

	if stage == 1 then
		local root = instance.Root
		local humanoid = instance.Humanoid
		local holdValue = instance.HoldValue
		local _ = instance.ChargeTime

		if humanoid and root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			local clone = C.Charging.Attachment:Clone()
			debris:AddItem(clone, 60)
			clone.Parent = root
			local diedConnection = nil

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
			end

			local lastTime = tick()

			local function running()
				return tick() - lastTime < 0.25 or diedConnection and instance.HoldValue and instance.HoldValue.Value == true
			end

			local lastTime2 = tick()

			while (tick() - lastTime < 0.25 or diedConnection and instance.HoldValue and instance.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid do
				local _ = tick() - lastTime2 > 1
				RunService.RenderStepped:Wait()
			end

			if clone then
				for _, child in pairs(clone:GetChildren()) do
					child.Enabled = false
				end
			end

			task.delay(1.5, function()
				if clone then
					clone:Destroy()
				end
			end)

			if diedConnection then
				diedConnection:Disconnect()
			end
		end
	else
		if stage == 2 then
			return
		end

		if stage == 3 then
			local position = instance.Position
			local _ = instance.Root
			local _ = instance.Dir

			if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
				return
			end

			task.spawn(function()
				local clone = C.FlashFreeze:Clone()
				debris:AddItem(clone, 10)
				clone.Position = position
				clone.Parent = _WorldOrigin

				for _ = 1, 3 do
					for _, child in pairs(clone.Attachment:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end

					task.wait(0.1)
				end
			end)
			local v = Util.Sound:Play("WindLooped", position, nil, 1, 1)
			local tween = TweenService:Create(
				v,
				TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Volume = 0
				}
			)
			tween.Completed:Connect(function()
				if v then
					v:Destroy()
				end
			end)
			tween:Play()
			local part = Instance.new("Part")
			debris:AddItem(part, 10)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(60, 50, 60)
			part.Shape = Enum.PartType.Ball
			part.Position = position
			local clone = C.IceMist:Clone()
			clone.Parent = part
			part.Parent = _WorldOrigin
			task.delay(2, function()
				if clone then
					clone.Enabled = false
				end

				task.delay(4, function()
					if part then
						part:Destroy()
					end
				end)
			end)
			task.spawn(function()
				local clones = {}
				local v2 = 5

				for i = 1, 3 do
					local clone2 = C.IceTrail:Clone()
					debris:AddItem(clone2, 8)
					clone2.CFrame = CFrame.new(position + Vector3.new(0, math.random(-10, 10) / 10, 0)) * CFrame.Angles(
						0,
						math.rad(i * 120),
						0
					)
					clone2.Parent = _WorldOrigin
					clone2.Trail.Enabled = true
					clone2.Dust.Enabled = true
					clone2.Wind.Enabled = true
					table.insert(clones, clone2)
				end

				local total = 0
				local v3 = 0.016666666666666666

				for i = 1, 180 do
					if i > 100 then
						v2 -= 0.05
					end

					total += i < 90 and 0.1 or 0.01

					for _, v4 in pairs(clones) do
						v4.CFrame *= CFrame.Angles(0, math.rad(v2 * v3 * 60), 0) * CFrame.new(
							0,
							math.sin(total) * 1,
							v3 * -2 * 60
						)
					end

					v3 = RunService.RenderStepped:Wait()
				end

				if #clones > 0 then
					for _, v4 in pairs(clones) do
						for _, effect in pairs(v4:GetChildren()) do
							if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end

							local v5 = v4
							task.delay(1.5, function()
								if v5 then
									v5:Destroy()
								end
							end)
						end
					end
				end
			end)
			local ray, v2, _ = Util.Ray(
				position,
				CFrame.new(position, position - createVector(0, 1, 0)).lookVector.Unit * 20,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			local v3 = CFrame.new(position) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
			TweenService:Create(
				Util.Sound:Play("IcebergExplosion2", position, nil, 0.8, 1),
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Pitch = 1.5
				}
			):Play()
			TweenService:Create(
				Util.Sound:Play("IceShoot", position, nil, 2, 2),
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
				{
					Pitch = 0.3
				}
			):Play()
			Util.Sound:Play("SharpAirGust", position, nil, 0.8, 1)
			local character = game.Players.LocalPlayer.Character

			if character ~= nil then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 150 then
					Util.CameraShaker:ShakeOnce(10, 25, 0.3, 0.3)
				end
			end

			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.Transparency = 1
			part2.Size = createVector(1, 1, 1)
			part2.Position = v3.p
			part2.Parent = _WorldOrigin
			Util.Debris:AddItem(part2, 6)
			local v6 = {}
			local v7 = 0.016666666666666666
			local now = tick()
			task.spawn(function()
				tick()
				local now2 = tick()

				while true do
					local now3 = tick()
					local v8 = now3 - now

					if v8 > 1.5 then
						break
					end

					local _ = v8 / 2

					if v8 < 0.8 and now3 - now2 > 0.2 then
						local resource = getResource("WindRing", 0.4, {
							CFrame = CFrame.new(position - createVector(0, 5, 0)) * CFrame.Angles(
								math.rad((math.random(-10, 10))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-10, 10))))
							),
							Transparency = -5,
							Size = createVector(0, 10, 0)
						})
						resource.Parent = _WorldOrigin
						table.insert(v6, { 2, resource })
						now2 = tick()
						local tween2 = TweenService:Create(
							resource,
							TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Position = resource.Position + createVector(0, 20, 0),
								Size = createVector(135, 30, 135),
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

					if #v6 > 0 then
						local v9 = v7 * 60

						for k, v10 in pairs(v6) do
							if v10[2] == nil then
								table.remove(v6, k)
							elseif v10[1] == 0 then
								v10[2].CFrame *= CFrame.new(0, v9 * -0.25, 0) * CFrame.Angles(0, math.rad(v9 * -25), 0)
							elseif v10[1] == 1 then
								v10[2].CFrame *= CFrame.new(0, v9 * 0.1, 0) * CFrame.Angles(0, math.rad(v9 * 25), 0)
							elseif v10[1] == 2 then
								v10[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v9 * -20), 0)
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
			Util.Sound:Play("SandCWind", position, nil, 0.7, 5)

			if ray then
				local resource = getResource("BlastWave", 0.7, {
					CFrame = CFrame.new(v2 + createVector(0, 15, 0)) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						0
					),
					Size = createVector(0, 30, 0)
				})
				resource.Parent = _WorldOrigin
				table.insert(v6, { 1, resource })
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
		elseif stage == 4 then
			local root = instance.Root
			local duration = instance.Duration
			local timestamp = instance.Timestamp
			freezePlayer(root, math.max(0.1, duration - (masterClock:GetTime() - timestamp)))
		end
	end
end