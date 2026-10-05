local createVector = vector.create
local _ = workspace._WorldOrigin
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
TweenInfo.new(0.15, Enum.EasingStyle.Sine)
local _ = {
	Size = createVector(25, 15, 35),
	Transparency = 1,
	Color = Color3.new(0, 0, 0)
}
local _ = CFrame.Angles
Random.new()
local _ = {
	{ "RightUpperArm", "MagmaUltUpperArm" },
	{ "RightLowerArm", "MagmaUltLowerArm" },
	{ "RightHand", "MagmaUltHand" }
}

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

local v = {}
local RunService2 = game:GetService("RunService")
RunService2:BindToRenderStep("ActiveSparks_Magma2", 1000, function(p)
	for k, v2 in pairs(v) do
		local spark_p = v2.spark_p
		local life_time = v2.life_time
		local properties = v2.properties
		local time_started = v2.time_started
		local timer = v2.timer

		if tick() - time_started < life_time then
			local _ = (tick() - time_started) / life_time
			spark_p.CFrame = spark_p.CFrame * CFrame.new(0, 0, -properties.speed) * CFrame.Angles(
				math.rad(properties.angle_x * math.cos(timer / 5 + math.random(-360, 360) / 100)),
				math.rad(properties.angle_y * math.cos(timer / 5 + math.random(-360, 360) / 100)),
				(math.rad(properties.angle_z * math.cos(timer / 5 + math.random(-360, 360) / 100)))
			)
			v2.timer += p * 60
		else
			if spark_p then
				spark_p:Destroy()
			end

			v[k] = nil
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
	part.Parent = _WorldOrigin
	table.insert(v, {
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

-- equivalent calls inferred from this helper; original call sites unknown
local function fix2(hitbox)
	local touchTransmitter = hitbox:FindFirstChildWhichIsA("TouchTransmitter")

	if touchTransmitter then
		touchTransmitter:Destroy()
		return
	end

	local childAddedConnection = nil
	childAddedConnection = hitbox.ChildAdded:Connect(function(touchTransmitter2)
		if touchTransmitter2:IsA("TouchTransmitter") then
			childAddedConnection:Disconnect()
			touchTransmitter2:Destroy()
		end
	end)
end

return function(data)
	local effect_type = data.effect_type

	if effect_type == "magma_fly_start" then
		if (data.cframe_to_send.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 2000 then
			return
		end

		Util.CameraShaker:ShakeOnce(10, 8, 0.2, 0.8, createVector(1, 1, 1), createVector(1, 1, 3))
		local cframe_to_send = data.cframe_to_send
		local clone = FX:WaitForChild("MagmaEffects").MaguFlyEffe:Clone()
		clone:SetPrimaryPartCFrame(cframe_to_send)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name == "ad_smoke_p" then
				emitter:Emit(8)
			end
		end

		for _, part in pairs(clone:GetChildren()) do
			if not (part:IsA("BasePart") and part ~= clone.PrimaryPart) then
				continue
			end

			part.Size *= 2.5
			part.Transparency = 1

			if part.Name == "Sphere" then
				part.Size = createVector(0.05, 0.05, 0.05)
			elseif part.Name == "Swirl" then
				part.Size = createVector(0.05, 0.05, 0.05)
			end
		end

		for _, part in pairs(clone:GetChildren()) do
			if not (part:IsA("BasePart") and part ~= clone.PrimaryPart) then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 0
			}):Play()

			if part.Name == "Sphere" then
				local tween = TweenService:Create(
					part,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Size = createVector(50, 50, 50)
					}
				)
				tween:Play()
				local v2 = part
				tween.Completed:Connect(function()
					local tween2 = TweenService:Create(
						v2,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = createVector(0.05, 0.05, 0.05)
						}
					)
					tween2:Play()
					tween2.Completed:Connect(function()
						if v2 then
							v2:Destroy()
						end
					end)
				end)
			elseif part.Name == "Swirl" then
				local v2 = math.random(650, 850) / 10
				local tween = TweenService:Create(
					part,
					TweenInfo.new(math.random(20, 30) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						CFrame = part.CFrame * CFrame.Angles(0, math.rad((math.random(360))), 0),
						Size = Vector3.new(v2, 15, v2)
					}
				)
				tween:Play()
				local v3 = part
				tween.Completed:Connect(function()
					local tween2 = TweenService:Create(
						v3,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							CFrame = clone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad((math.random(360))), 0),
							Size = createVector(0.05, 0.05, 0.05)
						}
					)
					tween2:Play()
					tween2.Completed:Connect(function()
						if v3 then
							v3:Destroy()
						end
					end)
				end)
			end
		end

		clone.Parent = _WorldOrigin
		coroutine.resume(coroutine.create(function()
			for _ = 1, 6 do
				spark_effect({
					life_time = math.random(135, 185) / 100,
					cframe = clone.PrimaryPart.CFrame,
					scale = math.random(275, 350) / 100,
					color = math.random(1, 2) == 1 and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(0, 0, 0),
					material = Enum.Material.Neon,
					speed = math.random(25, 35) / 10,
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
				local v3 = math.random(150, 175)

				for _, part in pairs(clone2:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Size *= v3 / 10
					part.CFrame = CFrame.new(clone.PrimaryPart.CFrame.p, clone.PrimaryPart.CFrame * vector2) * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					part.Anchored = false
				end

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
						emitter.Enabled = true
					end
				end

				clone2.Parent = _WorldOrigin

				for _, child in pairs(clone2:GetChildren()) do
					if not (child.Name ~= "root" and child.Name ~= "Sphere") then
						continue
					end

					local tween = TweenService:Create(
						child,
						TweenInfo.new(math.random(15, 20) / 10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween:Play()
					local folder = clone2
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

				local velocity = clone2.PrimaryPart.CFrame.lookVector * (math.random(1000, 1500) / 10)
				local vector3 = Vector3.new(
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10,
					math.random(-50, 50) / 10
				)

				for _, part in pairs(clone2:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Velocity = velocity
					part.RotVelocity = vector3
				end
			end
		end))
		Util.Debris:AddItem(clone, 5)
	elseif effect_type == "magma_hound_start" then
		if not data.projectile_to_send or (data.projectile_to_send.PrimaryPart.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 1500 then
			return
		end

		pcall(function()
			data.projectile_to_send:WaitForChild("terrainhitbox", 5):Destroy()
		end)
		pcall(function()
			fix2(data.projectile_to_send:WaitForChild("hitbox", 5)) -- equivalent call inferred; original call site unknown
		end)
		local clone = FX:WaitForChild("MagmaEffects").MagmaHound:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("BasePart") then
				part.Massless = true
				part.Anchored = true
				part:ClearAllChildren()
			end

			if part.Name:find("hitbox") then
				part:Destroy()
			end
		end

		clone.Parent = data.projectile_to_send
		local v2 = false
		local HttpService = game:GetService("HttpService")
		local GUID = HttpService:GenerateGUID()
		RunService:BindToRenderStep(GUID, 10000, function()
			if not (data.projectile_to_send and data.projectile_to_send.PrimaryPart) then
				RunService:UnbindFromRenderStep(GUID)
				return
			end

			if v2 == false and data.holding and data.holding.Value and data.holding:IsDescendantOf(workspace) then
				data.projectile_to_send:SetPrimaryPartCFrame(data.caster.CFrame * CFrame.new(0, -12.6, 0))
			else
				v2 = true
			end

			if data.projectile_to_send and data.projectile_to_send:IsDescendantOf(workspace) then
				clone:SetPrimaryPartCFrame(data.projectile_to_send.PrimaryPart.CFrame)
				return
			end

			pcall(function()
				clone:Destroy()
			end)
			RunService:UnbindFromRenderStep(GUID)
		end)
	end
end