local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin2 = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
TweenInfo.new(0.15, Enum.EasingStyle.Sine)
local _ = {
	Size = createVector(25, 15, 35),
	Transparency = 1,
	Color = Color3.new(0, 0, 0)
}
local _ = CFrame.Angles
Random.new()
local v = {
	{ "RightUpperArm", "MagmaUltUpperArm" },
	{ "RightLowerArm", "MagmaUltLowerArm" },
	{ "RightHand", "MagmaUltHand" }
}
local v2 = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("ActiveSparks_Magma", 1000, function(p)
	for k, v3 in pairs(v2) do
		local spark_p = v3.spark_p
		local life_time = v3.life_time
		local properties = v3.properties
		local time_started = v3.time_started
		local timer = v3.timer

		if tick() - time_started < life_time then
			local _ = (tick() - time_started) / life_time
			spark_p.CFrame = spark_p.CFrame * CFrame.new(0, 0, -properties.speed) * CFrame.Angles(
				math.rad(properties.angle_x * math.cos(timer / 5 + math.random(-360, 360) / 100)),
				math.rad(properties.angle_y * math.cos(timer / 5 + math.random(-360, 360) / 100)),
				(math.rad(properties.angle_z * math.cos(timer / 5 + math.random(-360, 360) / 100)))
			)
			v3.timer += p * 60
		else
			if spark_p then
				spark_p:Destroy()
			end

			v2[k] = nil
		end
	end
end)

local function spark_effect(properties)
	local life_time = properties.life_time or 2.5
	local part = Instance.new("Part")
	part.CFrame = properties.cframe * CFrame.Angles(
		math.rad((math.random(360))),
		math.rad((math.random(360))),
		(math.rad((math.random(360))))
	)
	part.Size = createVector(2, 2, 7.5) * properties.scale
	part.Color = properties.color
	part.Material = properties.material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.Massless = true
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Sphere
	specialMesh.Parent = part
	part.Parent = _WorldOrigin2
	table.insert(v2, {
		spark_p = part,
		life_time = life_time,
		properties = properties,
		time_started = tick(),
		timer = 1
	})
	local tween = TweenService:Create(
		specialMesh,
		TweenInfo.new(life_time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Scale = createVector(0, 0, 0)
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if part then
			part:Destroy()
		end
	end)
end

local function fix(instance)
	local touchTransmitter = instance:FindFirstChildWhichIsA("TouchTransmitter")

	if touchTransmitter then
		touchTransmitter:Destroy()
		return
	end

	local childAddedConnection = nil
	childAddedConnection = instance.ChildAdded:Connect(function(touchTransmitter2)
		if touchTransmitter2:IsA("TouchTransmitter") then
			childAddedConnection:Disconnect()
			touchTransmitter2:Destroy()
		end
	end)
end

return function(data)
	local effect_type = data.effect_type

	if effect_type == "magma_takeoff" then
		if data.rhit == nil or workspace.CurrentCamera == nil or (data.rhit.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 2000 then
			return
		end

		local _ = data.rhit
		local rpos = data.rpos
		local rnorm = data.rnorm
		local clone = FX:WaitForChild("MagmaEffects").magma_ground_p:Clone()
		clone.CFrame = CFrame.new(rpos, rpos + rnorm) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "dust_p" then
				emitter:Emit(emitter.Rate)
			end
		end

		Util.Debris:AddItem(clone, 2.5)
		coroutine.resume(coroutine.create(function()
			for i = 1, 3 do
				local clone2 = FX:WaitForChild("MagmaEffects").RingRumble:Clone()

				if i == 1 then
					clone2.CFrame = CFrame.new(rpos, rpos + rnorm) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
						0,
						15,
						0
					)
					clone2.Size = createVector(32.5, 1.625, 32.5)
				elseif i == 2 then
					clone2.CFrame = CFrame.new(rpos, rpos + rnorm) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
						0,
						20,
						0
					)
					clone2.Size = createVector(22.75, 3.25, 22.75)
				elseif i == 3 then
					clone2.CFrame = CFrame.new(rpos, rpos + rnorm) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
						0,
						25,
						0
					)
					clone2.Size = createVector(16.25, 1.625, 16.25)
				end

				clone2.Transparency = 0
				clone2.Parent = _WorldOrigin

				if i == 1 then
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						CFrame = clone2.CFrame * CFrame.new(0, -10, 0),
						Size = createVector(50, 2.5, 50),
						Transparency = 1
					}):Play()
				elseif i == 2 then
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						CFrame = clone2.CFrame * CFrame.new(0, -10, 0),
						Size = createVector(35, 1, 35),
						Transparency = 1
					}):Play()
				elseif i == 3 then
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						CFrame = clone2.CFrame * CFrame.new(0, -5, 0),
						Size = createVector(25, 1, 25),
						Transparency = 1
					}):Play()
				end

				Util.Debris:AddItem(clone2, 1)
			end
		end))
	elseif effect_type == "magma_hand_appear" then
		local character_to_send = data.character_to_send
		local model = Instance.new("Model")
		model.Name = "UltLimbs" .. data.special_id_to_send
		model.Parent = _WorldOrigin

		for k, v3 in pairs(v) do
			local v4 = v3[1]

			if not character_to_send:FindFirstChild(v4) then
				continue
			end

			local v5 = v3[2]
			local clone = FX:WaitForChild("MagmaEffects").Limbs[v5]:Clone()

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Transparency = 1
					TweenService:Create(
						descendant,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					local vector3Value = Instance.new("Vector3Value")
					vector3Value.Name = "original_size"
					vector3Value.Value = descendant.Size
					vector3Value.Parent = descendant
				end

				if descendant:IsA("ParticleEmitter") and descendant.Name == "ad_smoke_p" then
					descendant:Emit(10)
				end
			end

			clone.Parent = model
			local v6 = character_to_send[v4]
			local cframe = CFrame.new()

			if k == 1 then
				cframe = CFrame.new(2.5, -3, 0)
			end

			if k == 2 then
				cframe = CFrame.new(2.5, -7, 0)
			end

			if k == 3 then
				cframe = CFrame.new(2.5, -11, 0) * CFrame.Angles(-1.5707963267948966, 0, -1.5707963267948966)
			end

			local HttpService = game:GetService("HttpService")
			local GUID = HttpService:GenerateGUID()
			local RunService2 = game:GetService("RunService")
			RunService2:BindToRenderStep(GUID, 10000, function()
				if clone:IsDescendantOf(workspace) then
					clone:SetPrimaryPartCFrame(v6.CFrame * cframe)
					return
				end

				local RunService3 = game:GetService("RunService")
				RunService3:UnbindFromRenderStep(GUID)
			end)
			local v10 = clone
			coroutine.resume(coroutine.create(function()
				for i = 1, math.random(1, 3) do
					local clone2 = FX:WaitForChild("MagmaEffects").Swirl:Clone()
					clone2.Position = v10.PrimaryPart.Position
					clone2.CFrame = clone2.CFrame * CFrame.new(
						math.random(-100, 100) / 100,
						math.random(-200, 200) / 100,
						math.random(-100, 100) / 100
					) * CFrame.Angles(0, math.rad((math.random(360))), 0)
					clone2.Size = Vector3.new(
						math.random(50, 100) / 10,
						math.random(85, 100) / math.random(50, 100) / 10
					)
					clone2.Color = math.random(1, 2) == 1 and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(0, 0, 0)
					clone2.Anchored = false
					clone2.Parent = _WorldOrigin
					local tween = TweenService:Create(
						clone2,
						TweenInfo.new(math.random(15, 20) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							CFrame = clone2.CFrame * CFrame.Angles(0, 2.792526803190927, 0),
							Position = v10.PrimaryPart.Position,
							Size = createVector(50, 15, 50),
							Transparency = 1
						}
					)
					tween:Play()
					tween.Completed:Connect(function()
						if clone2 then
							clone2:Destroy()
						end
					end)
				end
			end))
			local v11 = clone
			coroutine.resume(coroutine.create(function()
				for i = 1, 5 do
					spark_effect({
						life_time = math.random(35, 100) / 100,
						cframe = v11.PrimaryPart.CFrame,
						scale = math.random(85, 150) / 100,
						color = math.random(1, 2) == 1 and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(0, 0, 0),
						material = Enum.Material.Neon,
						speed = math.random(10, 20) / 10,
						angle_x = math.random(-360, 360) / 10,
						angle_y = math.random(-360, 360) / 10,
						angle_z = math.random(-360, 360) / 10
					})
					local clone2 = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
					local vector2 = Vector3.new(
						math.random(-360, 360) / 10,
						math.random(-360, 360) / 10,
						math.random(-360, 360) / 10
					)
					local v13 = math.random(20, 30)

					for i2, part in pairs(clone2:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.Size *= v13 / 10
						part.CFrame = CFrame.new(v11.PrimaryPart.CFrame.p, v11.PrimaryPart.CFrame * vector2) * CFrame.Angles(
							math.rad((math.random(-360, 360))),
							math.rad((math.random(-360, 360))),
							(math.rad((math.random(-360, 360))))
						)
						part.Anchored = false
					end

					for i2, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
							emitter.Enabled = true
						end
					end

					clone2.Parent = _WorldOrigin

					for i2, child in pairs(clone2:GetChildren()) do
						if not (child.Name ~= "root" and child.Name ~= "Sphere") then
							continue
						end

						local tween = TweenService:Create(
							child,
							TweenInfo.new(
								math.random(30, 50) / 10,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							),
							{
								Size = createVector(0, 0, 0)
							}
						)
						tween:Play()
						local folder = clone2
						tween.Completed:Connect(function()
							for i3, emitter in pairs(folder:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
									emitter.Enabled = false
								end
							end

							if folder then
								Util.Debris:AddItem(folder, 5)
							end
						end)
					end

					local velocity = clone2.PrimaryPart.CFrame.lookVector * (math.random(500, 1000) / 10)
					local vector3 = Vector3.new(
						math.random(-50, 50) / 10,
						math.random(-50, 50) / 10,
						math.random(-50, 50) / 10
					)

					for i2, part in pairs(clone2:GetChildren()) do
						if not part:IsA("BasePart") then
							continue
						end

						part.Velocity = velocity
						part.RotVelocity = vector3
					end
				end
			end))
		end
	elseif effect_type == "magma_hand_disappear" then
		local child = _WorldOrigin:WaitForChild("UltLimbs" .. data.special_id_to_send, 10)

		if not child then
			return
		end

		child:Destroy()
	elseif effect_type == "magma_projectile_appear" then
		if not data.projectile_to_send or (data.projectile_to_send.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 2000 then
			return
		end

		local clone = FX:WaitForChild("MagmaEffects").MagmaV:Clone()

		for _, weld in pairs(clone.PrimaryPart:GetChildren()) do
			if not weld:IsA("Weld") then
				weld:Destroy()
			end
		end

		clone.hitbox:Destroy()
		clone.terrainhitbox:Destroy()
		clone:SetPrimaryPartCFrame(data.projectile_to_send.CFrame)
		local weld = Instance.new("Weld")
		weld.Part0 = clone.PrimaryPart
		weld.Part1 = data.projectile_to_send
		weld.Parent = clone.PrimaryPart
		clone.Parent = workspace._WorldOrigin
		local HttpService = game:GetService("HttpService")
		local GUID = HttpService:GenerateGUID()
		local RunService2 = game:GetService("RunService")
		RunService2:BindToRenderStep(GUID, Enum.RenderPriority.Last.Value, function()
			if data.projectile_to_send:IsDescendantOf(workspace) then
				return
			end

			local RunService3 = game:GetService("RunService")
			RunService3:UnbindFromRenderStep(GUID)

			if clone then
				clone:Destroy()
			end
		end)
	elseif effect_type == "mamga_air_hand_disappear" then
		local part_to_send = data.part_to_send
		coroutine.resume(coroutine.create(function()
			for _ = 1, math.random(10, 15) do
				spark_effect({
					life_time = math.random(75, 150) / 100,
					cframe = part_to_send.CFrame,
					scale = math.random(250, 350) / 100,
					color = math.random(1, 2) == 1 and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(0, 0, 0),
					material = Enum.Material.Neon,
					speed = math.random(35, 50) / 10,
					angle_x = math.random(-360, 360) / 10,
					angle_y = math.random(-360, 360) / 10,
					angle_z = math.random(-360, 360) / 10
				})
				local clone = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
				local vector2 = Vector3.new(
					math.random(-360, 360) / 10,
					math.random(-360, 360) / 10,
					math.random(-360, 360) / 10
				)
				local v4 = math.random(60, 120)

				for _, part in pairs(clone:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Size *= v4 / 10
					part.CFrame = CFrame.new(part_to_send.CFrame.p, part_to_send.CFrame * vector2) * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					part.Anchored = false
				end

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
						emitter.Enabled = true
					end
				end

				clone.Parent = _WorldOrigin

				for _, child in pairs(clone:GetChildren()) do
					if not (child.Name ~= "root" and child.Name ~= "Sphere") then
						continue
					end

					local tween = TweenService:Create(
						child,
						TweenInfo.new(math.random(30, 50) / 10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween:Play()
					local folder = clone
					tween.Completed:Connect(function()
						for i, emitter in pairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
								emitter.Enabled = false
							end
						end

						if folder then
							Util.Debris:AddItem(folder, 5)
						end
					end)
				end

				local velocity = clone.PrimaryPart.CFrame.lookVector * (math.random(500, 1000) / 10)
				local vector3 = Vector3.new(
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10
				)

				for _, part in pairs(clone:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Velocity = velocity
					part.RotVelocity = vector3
				end
			end
		end))
	elseif effect_type == "shoot_effect" then
		coroutine.resume(coroutine.create(function()
			local cframe_to_send = data.cframe_to_send

			for i = 1, 3 do
				local clone = FX:WaitForChild("MagmaEffects").RingRumble:Clone()

				if i == 1 then
					clone.CFrame = cframe_to_send
				elseif i == 2 then
					clone.CFrame = cframe_to_send * CFrame.new(0, 50, 0)
				elseif i == 3 then
					clone.CFrame = cframe_to_send * CFrame.new(0, 100, 0)
				end

				clone.Size = Vector3.new(75 / i / 0.75, 25, 75 / i / 0.75)
				clone.Transparency = 0
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.new(0, -25, 0),
						Size = Vector3.new(clone.Size.X * 1.5, 15, clone.Size.Z * 1.5),
						Transparency = 0.5
					}
				)
				tween:Play()
				tween.Completed:Connect(function()
					local tween2 = TweenService:Create(
						clone,
						TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(clone.Size.X * 1.25, 5, clone.Size.Z * 1.25),
							Transparency = 1
						}
					)
					tween2:Play()
					tween2.Completed:Connect(function()
						if clone then
							clone:Destroy()
						end
					end)
				end)
				clone.Parent = _WorldOrigin
				wait(0.05)
			end
		end))
	end
end