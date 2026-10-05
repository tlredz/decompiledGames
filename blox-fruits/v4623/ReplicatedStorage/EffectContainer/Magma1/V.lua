local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local map = workspace.Map
local debris = Util.Debris
local MagmaPuddle = require(ReplicatedStorage.EffectContainer.Magma1.MagmaPuddle)
local v = {
	TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
	TweenInfo.new(1.25, Enum.EasingStyle.Exponential),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine),
	TweenInfo.new(0.95, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(player)
	local subEffect = player.SubEffect

	if subEffect == 1 then
		local character = player.Character
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if character and humanoidRootPart then
			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 1000 then
				return
			end

			local random = Random.new()
			local v2 = Util.Sound:Play("MagmaIdle", humanoidRootPart.Position, nil, 1, 1)
			Util.Debris:AddItem(v2, 60)
			v2.Looped = true
			local clones = {}

			for i = 1, 2 do
				local v3 = i == 1 and "Left" or "Right"

				for i2 = 1, 3 do
					local part

					if i2 == 1 then
						part = character[v3 .. "UpperArm"]
					elseif i2 == 2 then
						part = character[v3 .. "LowerArm"]
					else
						part = character[v3 .. "Hand"]
					end

					local cFrame = humanoidRootPart.CFrame
					local ball = script.ball
					local v5 = "ArmBall2" .. character.Name
					local clone = ball:Clone()
					clone.Name = v5 or clone.Name

					if ball:IsA("Model") then
						clone:SetPrimaryPartCFrame(cFrame)
					else
						clone.CFrame = cFrame
					end

					clone.Parent = _WorldOrigin
					table.insert(clones, clone)
					clone.Size *= random:NextNumber(0.5, 0.7)
					local v6 = part.Size.Y / 2 * 120
					clone.CFrame = part.CFrame * CFrame.new(0, math.random(-v6, v6) / 100, 0) * CFrame.Angles(
						random:NextNumber(-6.28, 6.28),
						random:NextNumber(-6.28, 6.28),
						random:NextNumber(-6.28, 6.28)
					)
					local weld = Instance.new("Weld")
					weld.Part0 = part
					weld.Part1 = clone
					weld.C0 = part.CFrame:Inverse() * weld.Part1.CFrame
					weld.Parent = clone
					TweenService:Create(weld, v[1], {
						C0 = part.CFrame:Inverse() * (CFrame.new(weld.Part1.CFrame.Position) * CFrame.new(
							random:NextNumber(-0.444, 0.444),
							0,
							random:NextNumber(-0.444, 0.444)
						)) * CFrame.Angles(
							random:NextNumber(-6.28, 6.28),
							random:NextNumber(-6.28, 6.28),
							random:NextNumber(-6.28, 6.28)
						)
					}):Play()
					TweenService:Create(clone, v[2], {
						Size = clone.Size * random:NextNumber(1.5, 3)
					}):Play()
				end
			end

			task.spawn(function()
				local v3 = false
				local childAddedConnection = nil
				childAddedConnection = character.ChildAdded:Connect(function(child)
					if child.Name == "MagmaFistVHold" then
						v3 = true

						if v2 then
							v2:Destroy()
						end

						childAddedConnection:Disconnect()
					end
				end)
				local lastTime = tick()

				while not (v3 or tick() - lastTime > 60) do
					for i = 1, 2 do
						local cFrame = (i == 1 and character.RightUpperArm.CFrame or character.LeftUpperArm.CFrame) * CFrame.new(
							i == 1 and random:NextNumber(0.5, 1) or random:NextNumber(-1, -0.5),
							-0.25,
							random:NextNumber(-0.5, 0.5)
						)
						local ball = script.ball
						local clone = ball:Clone()
						clone.Name = clone.Name

						if ball:IsA("Model") then
							clone:SetPrimaryPartCFrame(cFrame)
						else
							clone.CFrame = cFrame
						end

						clone.Parent = _WorldOrigin
						clone.Orientation = Vector3.new(0, math.random(0, 90), 0)
						clone.Size = createVector(0.365, 0.365, 0.365)
						debris:AddItem(clone, 5)
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(10000000000, 10000000000, 10000000000)
						bodyVelocity.Velocity = createVector(0, -5, 0)
						bodyVelocity.Parent = clone
						local touchedConnection = nil
						clone.CanTouch = true
						touchedConnection = clone.Touched:Connect(function(otherPart)
							if otherPart:IsDescendantOf(map) and otherPart.CanCollide ~= false then
								touchedConnection:Disconnect()
								bodyVelocity:Destroy()
								MagmaPuddle(clone.Position, 0.05, false)
								clone:Destroy()
							end
						end)
					end

					task.wait(0.8)
				end

				if childAddedConnection then
					childAddedConnection:Disconnect()
				end

				if v2 then
					v2:Destroy()
				end

				for k, v4 in pairs(clones) do
					if v4 == nil then
						continue
					end

					TweenService:Create(v4, v[3], {
						Size = createVector(0, 0, 0)
					}):Play()
					TweenService:Create(v4.Weld, v[4], {
						C0 = v4.Weld.C0
					}):Play()
					local v5 = v4
					local v6 = k
					task.delay(1, function()
						if v5 then
							v5:Destroy()
						end

						table.remove(clones, v6)
					end)
				end
			end)
		end
	elseif subEffect == 2 then
		local character = player.Character
		local projectileCFrame = player.ProjectileCFrame
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if character and humanoidRootPart then
			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 1000 then
				return
			end

			local goalPos = player.GoalPos
			local projectileVelocity = player.ProjectileVelocity
			local projectileLife = player.ProjectileLife
			local _ = player.ProjectileGravity
			local hitValue = player.HitValue
			local timestamp = player.Timestamp
			local random = Random.new()
			local stringValue = Instance.new("StringValue")
			debris:AddItem(stringValue, 2)
			stringValue.Name = "MagmaFistVHold"
			stringValue.Parent = character

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude < 50 then
				local clone = script.Blur:Clone()
				debris:AddItem(clone, 1)
				clone.Parent = game.Lighting
				TweenService:Create(clone, v[9], {
					Size = 5
				}):Play()
			end

			local cFrame3 = projectileCFrame * CFrame.Angles(0, 3.14, 0)
			local fist = script.Fist
			local clone = fist:Clone()
			clone.Name = clone.Name

			if fist:IsA("Model") then
				clone:SetPrimaryPartCFrame(cFrame3)
			else
				clone.CFrame = cFrame3
			end

			clone.Parent = _WorldOrigin
			debris:AddItem(clone, 4)
			Util.Sound:Play("MagmaBigSummon", clone.Position, nil, 1 + math.random(-20, 20) / 100, 1)
			local v3 = false
			local position = projectileCFrame.Position
			local changedConnection = nil
			changedConnection = hitValue.Changed:Connect(function()
				position = hitValue.Value or nil
				v3 = true
				changedConnection:Disconnect()
			end)
			local v4 = math.max(projectileLife - (masterClock:GetTime() - timestamp), 0.1)
			task.spawn(function()
				local v5 = projectileCFrame * projectileVelocity
				local v6 = (goalPos - v5 - createVector(0, -50, 0) * projectileLife * projectileLife) / projectileLife
				local _, _, _ = Util.Ray(
					projectileCFrame.p,
					projectileCFrame.lookVector.Unit * 5,
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local position2 = projectileCFrame.Position
				local total = 0

				while total < projectileLife do
					math.min(1, (tick() - projectileLife) / projectileLife)
					local v7 = projectileLife
					projectileLife = v7 + (v4 - v7) * 0.1
					local v8 = CFrame.new(createVector(0, -50, 0) * total * total + v6 * total + v5, position2) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					)
					clone.CFrame = v8 * CFrame.Angles(0, 3.141592653589793, 0)
					local magnitude = (position2 - v8.Position).magnitude

					if v3 and hitValue then
						clone.Position = hitValue.Value
						break
					end

					local ray, _, _ = Util.Ray(
						v8.Position,
						v8.lookVector.Unit * magnitude * 2,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray then
						break
					end

					position2 = v8.Position
					total += RunService.RenderStepped:Wait()
				end

				if changedConnection then
					changedConnection:Disconnect()
				end

				Util.Sound:Play("MagmaRainExplode", clone.Position, nil, 1 + math.random(-15, 15) / 100, 1.5)
				v3 = true

				for _, emitter in pairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				clone.Anchored = true
				clone.Transparency = 1
				debris:AddItem(clone, 2)

				if (workspace.CurrentCamera.CFrame.Position - clone.Position).magnitude < 50 then
					local clone2 = script.Blur:Clone()
					clone2.Parent = game.Lighting
					TweenService:Create(clone2, v[9], {
						Size = 5
					}):Play()
					debris:AddItem(clone2, 1)
				end

				MagmaPuddle(clone.Detect.Position, 2, true, 1.25)
				local cFrame = clone.Detect.CFrame
				local sphere = script.Sphere
				local clone2 = sphere:Clone()
				clone2.Name = clone2.Name

				if sphere:IsA("Model") then
					clone2:SetPrimaryPartCFrame(cFrame)
				else
					clone2.CFrame = cFrame
				end

				clone2.Parent = _WorldOrigin
				debris:AddItem(clone2, 1)
				TweenService:Create(clone2, v[11], {
					Transparency = 1,
					Size = clone2.Size * 7 / 1.5
				}):Play()
				local cFrame2 = clone.Detect.CFrame
				local explosion = script.Explosion
				local clone3 = explosion:Clone()
				clone3.Name = clone3.Name

				if explosion:IsA("Model") then
					clone3:SetPrimaryPartCFrame(cFrame2)
				else
					clone3.CFrame = cFrame2
				end

				clone3.Parent = _WorldOrigin
				debris:AddItem(clone3, 1.5)

				for _, descendant in pairs(clone3:GetDescendants()) do
					if descendant:IsA("ParticleEmitter") then
						descendant:Emit(descendant:GetAttribute("EmitCount"))
					elseif descendant:IsA("PointLight") then
						TweenService:Create(descendant, v[3], {
							Brightness = 0,
							Range = 0
						}):Play()
					end
				end

				for _ = 1, 2 do
					local cFrame4 = clone.Detect.CFrame * CFrame.new(0, math.random(3, 6), math.random(-11, -9))
					local ball = script.ball
					local clone4 = ball:Clone()
					clone4.Name = clone4.Name

					if ball:IsA("Model") then
						clone4:SetPrimaryPartCFrame(cFrame4)
					else
						clone4.CFrame = cFrame4
					end

					clone4.Parent = _WorldOrigin
					debris:AddItem(clone4, 2)
					clone4.Size *= 4
					clone4.Angular.Enabled = true
					local bodyVelocity = Instance.new("BodyVelocity")
					debris:AddItem(bodyVelocity, 0.2)
					bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyVelocity.Parent = clone4
					local v8 = math.random(-9, 9)
					local v9 = math.random(12, 18)
					local v10 = math.random(-9, 9)
					bodyVelocity.Velocity = Vector3.new(v8 * 3.75, v9 * math.random(3, 4), v10 * 3.75)
					clone4.CanTouch = true
					local touchedConnection = nil
					touchedConnection = clone4.Touched:Connect(function(otherPart)
						if otherPart:IsDescendantOf(map) and otherPart.CanCollide ~= false then
							touchedConnection:Disconnect()
							clone4.Transparency = 1
							clone4.Anchored = true
							debris:AddItem(clone4, 2)
							MagmaPuddle(clone4.Position, Random.new():NextNumber(0.5, 1), false)
						end
					end)
				end

				for _ = 1, 3 do
					local cFrame4 = clone.CFrame * CFrame.new(0, -1, 0)
					local ball = script.ball
					local clone4 = ball:Clone()
					clone4.Name = clone4.Name

					if ball:IsA("Model") then
						clone4:SetPrimaryPartCFrame(cFrame4)
					else
						clone4.CFrame = cFrame4
					end

					clone4.Parent = _WorldOrigin
					debris:AddItem(clone4, 2.5)
					clone4.Size = createVector(8.5, 8.5, 8.5) * random:NextNumber(1.25, 1.6)
					clone4.Anchored = true
					TweenService:Create(clone4, v[12], {
						Size = clone4.Size * 2.45 / 1.5
					}):Play()
					local cFrame5 = CFrame.new(clone.Position) * CFrame.new(
						math.random(-8, 8),
						math.random(-1, 2),
						math.random(-8, 8)
					) * CFrame.Angles(
						random:NextNumber(-6.28, 6.28),
						random:NextNumber(-6.28, 6.28),
						random:NextNumber(-6.28, 6.28)
					)
					TweenService:Create(clone4, v[13], {
						CFrame = cFrame5
					}):Play()
					task.delay(1.5, function()
						local components, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21 = cFrame5:components()
						TweenService:Create(clone4, v[13], {
							Size = createVector(0, 0, 0),
							CFrame = CFrame.new(
								clone.CFrame.X,
								clone.CFrame.Y,
								clone.CFrame.Z,
								v13,
								v14,
								v15,
								v16,
								v17,
								v18,
								v19,
								v20,
								v21
							)
						}):Play()
					end)
				end
			end)
			task.spawn(function()
				local lastTime = tick()

				while clone ~= nil and clone.Parent ~= nil and not v3 do
					if tick() - lastTime > 0.1 then
						lastTime = tick()
						local cFrame = clone.CFrame * CFrame.new(0, 0, 10) * CFrame.Angles(1.57, 0, 0)
						local shockwave = script.Shockwave
						local clone2 = shockwave:Clone()
						clone2.Name = clone2.Name

						if shockwave:IsA("Model") then
							clone2:SetPrimaryPartCFrame(cFrame)
						else
							clone2.CFrame = cFrame
						end

						clone2.Parent = _WorldOrigin
						debris:AddItem(clone2, 0.25)
						TweenService:Create(clone2, v[5], {
							Size = clone2.Size * 5,
							Transparency = 1,
							Color = Color3.new(0, 0, 0),
							CFrame = clone2.CFrame * CFrame.new(0, -10, 0)
						}):Play()
					end

					task.wait(0.065)
				end
			end)
		end
	end
end