local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local _ = Util.CameraShaker

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function insertFlakeParticles(parent, p)
	local clone = script.ParticleContainer[p]:Clone()
	clone.Parent = parent
	return clone
end

return function(player)
	local ID = player.ID or 1

	if ID == 1 then
		local character = player.Character
		local holdValue = player.HoldValue

		if character and holdValue then
			local rightHand = character:FindFirstChild("RightHand")
			local leftHand = character:FindFirstChild("LeftHand")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if rightHand and leftHand and humanoid and humanoidRootPart then
				if (workspace.CurrentCamera.CFrame.Position - rightHand.Position).Magnitude > 300 then
					return
				end

				local chargeTime = player.ChargeTime or 1
				local _ = player.Timestamp
				Util.Sound:Play("Ice_startup", rightHand)
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
				local lastTime = tick()

				local function running()
					if holdValue.Parent == nil or holdValue.Parent.Parent == nil then
						return false
					end

					if rightHand and leftHand and humanoid and humanoidRootPart then
						return tick() - lastTime < 0.1 or diedConnection and player.HoldValue and player.HoldValue.Value == true
					end

					return false
				end

				local clone = script.ParticleContainer.HandAttachment:Clone()
				debris:AddItem(clone, 60)
				clone.Parent = rightHand
				local clone2 = script.ParticleContainer.HandAttachment:Clone()
				debris:AddItem(clone2, 60)
				clone2.Parent = leftHand
				local v = {}
				local v2 = {}

				for i = 1, 2 do
					local clone3 = script.Flake1:Clone()
					Util.Debris:AddItem(clone3, 60)
					local clone_2 = script.ParticleContainer.Charging:Clone()
					clone_2.Parent = clone3
					clone3.Size = Vector3.new()
					table.insert(i == 1 and v2 or v, clone3)
					local clone_3 = script.ChargeRing:Clone()
					clone_3.Parent = clone3
					local clone_4 = script.ChargeRing:Clone()
					clone_4.Parent = clone3
					clone3.Parent = _WorldOrigin

					for _, child in pairs(clone3.Charging:GetChildren()) do
						child.Enabled = true
					end

					TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(1.8, 0.12, 1.8)
					}):Play()
				end

				local clones = {}
				local total = 0

				for i = 1, 2 do
					local clone3 = script.BeamWind:Clone()
					debris:AddItem(clone3, 60)
					clone3:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
						0,
						math.rad(i == 1 and 0 or 90),
						0
					))

					if i == 2 then
						for _, child in pairs(clone3:GetChildren()) do
							if child.Name == "Beam2" then
								child.Position += createVector(0, 8, 0)
							end
						end
					end

					clone3.Parent = _WorldOrigin
					table.insert(clones, clone3)
				end

				local v3 = false
				local v4 = 0.016666666666666666

				while running() do
					if not v3 and chargeTime <= tick() - lastTime then
						local play = Util.Sound:Play("IceBlock", rightHand, nil, 1.3, 0.6)
						play.TimePosition = 0.3

						for i = 1, 2 do
							for i2 = 1, 2 do
								local clone3 = script["Flake" .. (i == 1 and 2 or 3)]:Clone()
								Util.Debris:AddItem(clone3, 60 - chargeTime)
								local clone_5 = script.ParticleContainer.Charging:Clone()
								clone_5.Parent = clone3
								clone3.Size = Vector3.new()
								table.insert(i2 == 1 and v2 or v, clone3)
								clone3.Parent = _WorldOrigin
								TweenService:Create(
									clone3,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = createVector(1.8, 0.12, 1.8) * (1 - i * 0.2),
										Color = Color3.fromRGB(115 - i * 8, 146 - i * 8, 165 - i * 8)
									}
								):Play()
							end
						end

						v3 = true
					end

					for k, v5 in pairs(v2) do
						v5.CFrame = leftHand.CFrame * CFrame.new(-0.2 * k, -0.5 * k, -0.5 * k) * CFrame.Angles(
							0,
							0,
							1.5707963267948966
						)
					end

					for k, v5 in pairs(v) do
						v5.CFrame = rightHand.CFrame * CFrame.new(0.2 * k, -0.5 * k, -0.5 * k) * CFrame.Angles(
							0,
							0,
							1.5707963267948966
						)
					end

					for k, v5 in pairs(clones) do
						v5:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * CFrame.Angles(
							0,
							math.rad((k == 1 and 0 or 90) + total),
							0
						))
					end

					total += v4 * 5 * 60
					v4 = RunService.RenderStepped:Wait()
				end

				local v5 = { "BurstMist", "BurstLines", "Snow" }

				for _, v6 in pairs({ clone, clone2 }) do
					if v6 == nil then
						continue
					end

					for _, child in pairs(v6:GetChildren()) do
						if v5[child.Name] then
							if child.Name == "Snow" then
								child.Speed = NumberRange.new(40, 60)
							end

							child:Emit(child:GetAttribute("EmitCount"))
						end

						child.Enabled = false
					end

					local v7 = v6
					task.delay(1, function()
						if v7 then
							v7:Destroy()
						end
					end)
				end

				if diedConnection then
					diedConnection:Disconnect()
				end

				if #v2 > 0 then
					for _, v6 in pairs(v2) do
						v6:Destroy()
					end
				end

				if #v > 0 then
					for _, v6 in pairs(v) do
						v6:Destroy()
					end
				end

				if #clones > 0 then
					for _, folder in pairs(clones) do
						for _, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("Beam") then
								local v6 = effect
								local v7 = folder
								task.spawn(function()
									local v8 = 0.3

									for i = 1, 60 do
										if v6 and v7 then
											v6.Transparency = NumberSequence.new(0 + 1 * (i * 0.6))
											v8 += 1
											RunService.RenderStepped:Wait()
										else
											break
										end
									end
								end)
							elseif effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end
						end
					end
				end

				task.wait(2)

				if #clones > 0 then
					for _, v6 in pairs(clones) do
						v6:Destroy()
					end
				end
			end
		end
	elseif ID == 2 then
		local cFrame = player.CFrame
		local life = player.Life
		local distance = player.Distance
		local timestamp = player.Timestamp
		local sineMax = player.SineMax
		local sineStr = player.SineStr

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 1000 then
			return
		end

		Util.Sound:Play("ColdGust", cFrame.Position, nil, 0.75, 0.5)
		local v = masterClock:GetTime() - timestamp
		math.max(0.1, life - v)
		local v2 = cFrame * CFrame.new(0, 0, -distance)
		local position = cFrame.Position
		local model = Instance.new("Model")
		debris:AddItem(model, life + 5)
		model.Name = "Blizznado"
		model.Parent = _WorldOrigin
		local clone = script.BlizznadoBase:Clone()
		clone.CFrame = cFrame
		clone.Parent = model
		model.PrimaryPart = clone
		local v3 = position

		for _, child in pairs(clone.Floor:GetChildren()) do
			child.Enabled = true
		end

		local v4 = Util.Sound:Play("WindTunnelLoop", clone, nil, 0.75, 0.5)
		local clone2 = script.FunnelWind:Clone()
		clone2.CFrame = CFrame.new(clone.Position + Vector3.new(0, clone2.Size.Y / 2, 0))
		clone2.Parent = model
		local v5 = 1 * math.sin(1 / sineStr)
		local lastTime = tick()
		local lastTime2 = tick()
		local time = masterClock:GetTime()
		local v6 = 1
		local clones = {}
		local v7 = 0.016666666666666666
		local v8 = { "RoundWind", "FleckWind" }

		while masterClock:GetTime() - time + v < life do
			local v9 = (masterClock:GetTime() - time + v) / life
			local v10 = 1 + (sineMax - 1) * v9
			local v11 = 60 * life * v9

			if tick() - lastTime2 > 0.1 then
				for _, emitter in pairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				lastTime2 = tick()
			end

			if tick() - lastTime > 0.2 then
				v6 = v6 == 1 and 2 or 1
				local clone3 = script[v8[v6]]:Clone()
				clone3.Material = Enum.Material.ForceField
				clone3.Color = Color3.fromRGB(255, 255, 255)
				clone3.Size = createVector(4, 1, 4)
				clone3.CFrame = clone.CFrame * CFrame.new(v5 / 5, v7 * 1 * 60, v5 / 5)
				local v12 = math.random(-15, 15) + v11 / (v11 * life) * 15
				local tween = TweenService:Create(
					clone3,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(65 + v12, 25 + v12 * 0.38, 65 + v12)
					}
				)
				tween.Completed:Connect(function()
					local tween2 = TweenService:Create(
						clone3,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					)
					tween2.Completed:Connect(function()
						if clone3 then
							clone3:Destroy()
						end
					end)
					tween2:Play()
				end)
				clone3.Parent = model
				table.insert(clones, clone3)
				tween:Play()
				lastTime = tick()
			end

			local lerped = cFrame:lerp(v2, v9)
			v5 = v10 * math.sin(v11 / sineStr)
			local v12 = lerped * CFrame.new(v5, 0, 0)
			local magnitude = (v12.Position - v3).Magnitude
			local cframe = CFrame.new(v12.Position, v3)
			local _, _, _ = Util.Ray(
				cframe.Position,
				cframe.lookVector.Unit * -magnitude,
				{ workspace.Characters, workspace.Enemies },
				false
			)
			v3 = position
			position = v12.Position

			if #clones > 0 then
				for _, v13 in pairs(clones) do
					v13.CFrame *= CFrame.new(0, v7 * 0.45 * 60, 0) * CFrame.Angles(
						math.rad(v5 / 25) * v7 * 60,
						math.rad(v7 * 30 * 60),
						math.rad(v5 / 25) * v7 * 60
					)
				end
			end

			if clone2 then
				clone2.CFrame = CFrame.new(clone.Position + Vector3.new(0, clone2.Size.Y / 2, 0)) * CFrame.Angles(
					0,
					math.rad(v11 * -10 * v7 * 60),
					0
				)
			end

			model:SetPrimaryPartCFrame(CFrame.new(position))
			v7 = RunService.RenderStepped:Wait()
		end

		for _, child in pairs(clone.Floor:GetChildren()) do
			child.Enabled = false
		end

		if clone2 then
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			)
			tween.Completed:Connect(function()
				if clone2 then
					clone2:Destroy()
				end
			end)
			tween:Play()

			if v4 then
				local tween2 = TweenService:Create(
					v4,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Volume = 0
					}
				)
				tween2.Completed:Connect(function()
					if v4 then
						v4:Destroy()
					end
				end)
				tween2:Play()
			end
		end

		if #clones > 0 then
			for _, v9 in pairs(clones) do
				local tween = TweenService:Create(
					v9,
					TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				)
				local v10 = v9
				tween.Completed:Connect(function()
					if v10 then
						v10:Destroy()
					end
				end)
				tween:Play()
			end

			local v9 = 0.016666666666666666

			for _ = 1, 120 do
				for _, v10 in pairs(clones) do
					if v10 then
						v10.CFrame *= CFrame.new(0, v9 * 0.45 * 60, 0) * CFrame.Angles(0, math.rad(v9 * 35 * 60), 0)
					end
				end

				v9 = RunService.RenderStepped:Wait()
			end
		end
	end
end