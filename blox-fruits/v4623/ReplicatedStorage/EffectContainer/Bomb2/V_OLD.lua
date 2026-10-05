local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
Players.LocalPlayer:GetMouse()

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local FX = require(game.ReplicatedStorage.FX)
local V_OLD = FX:WaitForChild("Bomb2").V_OLD
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = {}
local v = {}
return function(player)
	local state = player.State
	local character = player.Character

	if state == "End" and v[character] ~= "Start" or typeof(state) == "number" and v[character] ~= "Start" then
		return
	end

	v[character] = state

	if typeof(state) == "number" then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local v2 = 1
	local clone = V_OLD.BombAppear:Clone()
	clone.Position = humanoidRootPart.Position + Vector3.new(0, v2 * 2.2 + 3, 0)
	clone.Parent = workspace._WorldOrigin
	task.delay(ParticleState(clone), clone.Destroy, clone)
	local clone2 = V_OLD.BombModel:Clone()
	local bomb = clone2.Bomb
	raycastParams2.FilterDescendantsInstances = { bomb }
	print(raycastParams2.FilterDescendantsInstances)
	clone2:ScaleTo(v2)
	bomb.Position = humanoidRootPart.Position + Vector3.new(0, v2 * 2.2 + 3, 0)
	clone2.Parent = workspace._WorldOrigin
	local lastTime = os.clock()
	local lastTime2 = os.clock()
	local v3 = true
	local lastTime3 = os.clock()
	local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		if os.clock() - lastTime3 <= 3 then
			v2 = 3 + 5 * ((os.clock() - lastTime3) / 3)
			clone2:ScaleTo(v2)
			bomb.Position = humanoidRootPart.Position + Vector3.new(0, v2 * 2.2 + 3, 0)

			if os.clock() - lastTime >= 0.06 then
				lastTime = os.clock()
				local clone3 = V_OLD.BombParts:GetChildren()[random:NextInteger(1, #V_OLD.BombParts:GetChildren())]:Clone()
				clone3.Size += createVector(1, 1, 1) * v2
				clone3.Orientation = Vector3.new(
					random:NextNumber(0, 360),
					random:NextNumber(0, 360),
					random:NextNumber(0, 360)
				)
				local v4 = (random:NextInteger(0, 1) * 2 - 1) * (random:NextNumber(5, 12) * v2)
				local lookVector = (bomb.CFrame * CFrame.Angles(
					random:NextInteger(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586)
				)).LookVector
				local raycastResult = workspace:Raycast(bomb.Position, lookVector * v4, raycastParams)
				local position = raycastResult and raycastResult.Position or bomb.Position + lookVector * v4
				local _ = bomb.Position
				local clone4 = V_OLD.BombPartAppearModel:Clone()
				clone4:ScaleTo(v2)
				local bombPartAppear = clone4.BombPartAppear
				bombPartAppear.Position = position
				clone4.Parent = workspace._WorldOrigin
				task.delay(ParticleState(bombPartAppear), clone4.Destroy, bombPartAppear)
				clone3.Position = position
				clone3.Parent = workspace._WorldOrigin
				local number = random:NextNumber(0.1, 0.2)

				for i = 0, 1, RunService.Heartbeat:Wait() / number do
					local position2 = bomb.Position
					local raycastResult2 = workspace:Raycast(
						clone3.Position,
						position + (position2 - position) * i - clone3.Position,
						raycastParams2
					)
					clone3.Position = position + (position2 - position) * i

					if raycastResult2 then
						local clone5 = V_OLD.SurfaceHit:Clone()
						clone5.CFrame = CFrame.lookAt(
							raycastResult2.Position,
							raycastResult2.Position + raycastResult2.Normal
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						clone5.Parent = workspace._WorldOrigin
						task.delay(ParticleState(clone5), clone5.Destroy, clone5)

						for _ = 1, random:NextInteger(2, 3) do
							local clone6 = V_OLD.SparkTrail:Clone()
							clone6.CFrame = clone5.CFrame
							clone6.Parent = workspace._WorldOrigin
							clone6:ApplyAngularImpulse((clone5.CFrame.LookVector + Vector3.new(
								0,
								random:NextNumber(0.5, 1.5)
							)) * random:NextNumber(100, 500))
							task.delay(random:NextNumber(0.1, 0.3), function()
								clone6.Trail.Enabled = false
								task.wait(clone6.Trail.Lifetime)
								clone6:Destroy()
							end)
						end
					end

					RunService.Heartbeat:Wait()
				end

				clone3:Destroy()
			end
		end

		if os.clock() - lastTime2 >= 0.03 then
			lastTime2 = os.clock()
			local clone3 = V_OLD.Trail:Clone()
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(360, 720)
			local v4 = random:NextNumber(5, 12) * v2
			local v5 = v4
			local number3 = random:NextNumber(0, 360)
			local number4 = random:NextNumber(360, 720)
			clone3.Trail.Lifetime = random:NextNumber(0.1, 0.2)
			local position = bomb.Position
			local v6 = math.sin((math.rad(number))) * v4
			local v7 = math.sin((math.rad(number3))) * v4
			clone3.Position = position + Vector3.new(v6, v7, math.cos((math.rad(number))) * v4)
			clone3.Parent = workspace._WorldOrigin
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
				number += number2 * dt
				number3 += number4 * dt
				v4 -= v5 * dt

				if v4 < 0 then
					heartbeatConnection2:Disconnect()
					task.wait(clone3.Trail.Lifetime)
					clone3:Destroy()
				end

				clone3.Position = bomb.Position + Vector3.new(
					math.sin((math.rad(number))) * v4,
					math.sin((math.rad(number3))) * v4,
					math.cos((math.rad(number))) * v4
				)
			end)
		end
	end)
	task.delay(v2, function()
		if v3 == false then
			return
		end

		ParticleState(clone2.Expand, false)
	end)

	repeat
		task.wait()
	until character == nil or character.Parent == nil or typeof(v[character]) == "number"

	if not v[character] then
		return
	end

	v2 = v[character]
	v[character] = nil
	v3 = false
	heartbeatConnection:Disconnect()
	bomb.SurfaceAppearance:Destroy()
	bomb.Material = Enum.Material.Neon
	TweenService:Create(bomb, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Color = Color3.new(1, 0.290196, 0.290196)
	}):Play()
	local clone3 = V_OLD.WarningModel:Clone()
	local warning = clone3.Warning
	clone3:ScaleTo(v2)
	warning.Position = bomb.Position + Vector3.new(0, v2 * 4, 0)
	clone3.Parent = workspace._WorldOrigin
	task.wait(0.3)
	local clone4 = V_OLD.ExplosionModel:Clone()
	local explosion = clone4.Explosion
	clone4:ScaleTo(v2)
	explosion.Position = bomb.Position
	explosion.Parent = workspace._WorldOrigin
	task.delay(ParticleState(explosion), clone4.Destroy, clone4)
	local raycastResult = workspace:Raycast(bomb.Position, Vector3.new(0, v2 * -10, 0), raycastParams)

	if raycastResult then
		local clone5 = V_OLD.FloorScorchModel:Clone()
		local floorScorch = clone5.FloorScorch
		clone5:ScaleTo(v2)
		floorScorch.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone5.Parent = workspace._WorldOrigin
		task.delay(ParticleState(floorScorch), floorScorch.Destroy, floorScorch)

		for _ = 1, random:NextNumber(7, 12) do
			local clone6 = V_OLD.CloudTrail:Clone()
			clone6.Position = raycastResult.Position
			clone6.Color = raycastResult.Instance.Color
			clone6.Size = createVector(1, 1, 1) * random:NextNumber(1, 3)
			clone6.Orientation = Vector3.new(
				random:NextNumber(0, 360),
				random:NextNumber(0, 360),
				random:NextNumber(0, 360)
			)
			clone6.Parent = workspace._WorldOrigin
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
			bodyVelocity.Velocity = Vector3.new(
				random:NextNumber(-0.2, 0.2),
				random:NextNumber(0.1, 0.4),
				random:NextNumber(-0.2, 0.2)
			).Unit * random:NextNumber(50, 300) * (v2 - 1) / 10
			bodyVelocity.Parent = clone6
			task.delay(0.3, function()
				bodyVelocity:Destroy()
				clone6.CanCollide = true
				task.wait(random:NextNumber(0.9, 1.85))
				ParticleState(clone6, true)
				clone6.Material = Enum.Material.Neon
				TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Color = Color3.new(1, 0.372549, 0.160784)
				}):Play()
				clone6.Smoke.Enabled = false
				clone6.Smoke.Enabled = false
				local number = random:NextNumber(0.1, 0.3)
				TweenService:Create(clone6, TweenInfo.new(number, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				task.wait(number)
				task.wait((ParticleState(clone6, false)))
				clone6:Destroy()
			end)
		end
	end

	local clone5 = V_OLD.ColorCorrection:Clone()
	clone5.Parent = Lighting
	TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Brightness = 0,
		TintColor = Color3.new(1, 1, 1)
	}):Play()
	clone3:Destroy()
	clone2:Destroy()
	task.wait(0.3)
	clone5:Destroy()
end