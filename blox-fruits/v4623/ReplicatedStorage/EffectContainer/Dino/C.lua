local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local _ = Util.CameraShaker
local script2 = script

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).Magnitude <= p2 then
			callback()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScreenEffect(position)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude <= 50 then
			task.spawn(function()
				local clone = script2.Bloom:Clone()
				debris:AddItem(clone, 5)
				local tween = TweenService:Create(clone, TweenInfo.new(0.03), {
					Size = clone.Size,
					Threshold = clone.Threshold,
					Intensity = clone.Intensity
				})
				clone.Size = 24
				clone.Threshold = 2
				clone.Intensity = 1
				Util.SetParentOverrideWithColor(clone, workspace.CurrentCamera, player, "TRexFruitVFXColor")
				tween:Play()
				tween.Completed:Wait()
				local tween2 = TweenService:Create(clone, TweenInfo.new(0.05), {
					Size = 24,
					Threshold = 2
				})
				tween2:Play()
				tween2.Completed:Wait()
				clone:Destroy()
			end)
		end
	end
end

return function(player2)
	player = player2.player
	local ID = player2.ID

	if ID == 1 then
		local character = player2.Character
		local holdValue = player2.HoldValue

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid then
				local v = sound:Play("Gigantic Leap- Charge", humanoidRootPart, nil, 1, 1)
				v.Looped = true
				local diedConnection = nil
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
					diedConnection = nil
				end)
				tick()

				local function running()
					return diedConnection and holdValue and holdValue.Value == true
				end

				local clone = script2.HoldHand:Clone()
				clone.CFrame = humanoidRootPart.Parent.RightHand.CFrame
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
				clone.Weld.Part0 = humanoidRootPart.Parent.RightHand
				local clone2 = script2.HoldHand:Clone()
				clone2.CFrame = humanoidRootPart.Parent.LeftHand.CFrame
				Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")
				clone2.Weld.Part0 = humanoidRootPart.Parent.LeftHand
				local clone3 = script2.HoldSlashes:Clone()
				clone3.CFrame = humanoidRootPart.CFrame
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")
				clone3.Weld.Part0 = humanoidRootPart

				while diedConnection and holdValue and holdValue.Value == true and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoid and character do
					task.wait(0.05)
				end

				task.delay(0.26666666666666666, function()
					clone:Destroy()
					clone2:Destroy()
					clone3:Destroy()
				end)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if diedConnection then
					diedConnection:Disconnect()
					diedConnection = nil
				end

				if v then
					v:Destroy()
				end
			end
		end
	elseif ID == 2 then
		local _ = player2.MousePos
		local character = player2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local cFrame = player2.CFrame

			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
				return
			end

			sound:Play("Hunters Rage- Release (1)", humanoidRootPart, nil, 1.1, 1)
			local distance = player2.Distance
			local v, v2

			if game.Players.LocalPlayer.Character and character == game.Players.LocalPlayer.Character then
				v = Util.BodyMover.new(character):Create("BodyVelocity", {
					Priority = 2,
					Velocity = cFrame.lookVector * (distance / 0.3),
					Duration = 1.3
				})
				v2 = Util.BodyMover.new(character):Create("BodyGyro", {
					Priority = 2,
					CFrame = cFrame,
					Duration = 1.3
				})
			else
				v = nil
				v2 = nil
			end

			TweenService:Create(
				humanoidRootPart,
				TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = player2.EndCFrame
				}
			):Play()
			local clone = script2.StartImpact:Clone()
			debris:AddItem(clone, 8)
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "TRexFruitVFXColor")
			local descendants = clone:GetDescendants()

			for _, emitter in ipairs(descendants) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v3 = emitter
				task.spawn(function()
					if v3:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v3:GetAttribute("EmitDelay"))
					end

					v3:Emit(v3:GetAttribute("EmitCount"))
				end)
			end

			local clone2 = script2.DashSlash:Clone()
			debris:AddItem(clone2, 3)
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "TRexFruitVFXColor")
			local descendants2 = clone2:GetDescendants()

			for _, emitter in ipairs(descendants2) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			task.spawn(function()
				task.wait(0.05)
				local position = cFrame.Position
				local ray, _, _ = Util.Ray(
					position + createVector(0, 1, 0),
					CFrame.new(position + createVector(0, 1, 0), position + createVector(0, -10, 0)).LookVector * 10,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if ray then
					local clone3 = script2.GroundSpark:Clone()
					debris:AddItem(clone3, 3)
					clone3.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")

					for _ = 1, 10 do
						local v3 = clone2.CFrame * CFrame.new(math.random(-12, 12), 0, math.random(-1, 1)).Position
						local ray2, v4, _ = Util.Ray(
							v3 + createVector(0, 5, 0),
							CFrame.new(v3 + createVector(0, 1, 0), v3 + createVector(0, -10, 0)).LookVector * 10,
							{ workspace.Characters, workspace.Enemies },
							false
						)

						if ray2 then
							clone3.Orientation = Vector3.new(
								clone3.Orientation.X,
								math.random(-90, 90),
								clone3.Orientation.Z
							)
							clone3.Position = v4 + createVector(0, 0.25, 0)
							clone3.Size = Vector3.new(math.random(5, 20), 1, math.random(1, 5))
							local descendants3 = clone3:GetDescendants()

							for _, emitter in ipairs(descendants3) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter:GetAttribute("Scratch") then
									emitter.Size = NumberSequence.new(math.random(10, 20))
								end

								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end

						task.wait(math.random(10, 20) / 1000)
					end
				end
			end)
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, -distance)
			}):Play()
			task.spawn(function()
				task.wait(0.255)
				local descendants3 = clone2:GetDescendants()

				for _, effect in ipairs(descendants3) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
						continue
					end

					effect.Enabled = false

					if not effect:GetAttribute("EMIT") then
						continue
					end

					local v3 = effect
					task.spawn(function()
						task.wait(0.045)
						v3:Emit(v3:GetAttribute("EmitCount"))
					end)
				end
			end)
			task.spawn(function()
				local v3 = math.random(13, 17) / 10
				local v4 = math.random(15, 20) / 10

				for _ = 1, 8 do
					local v5 = math.random(1, 3)
					local clone3 = nil

					if v5 == 1 then
						clone3 = script2.DashSlashes.SlashA:Clone()
					elseif v5 == 2 then
						clone3 = script2.DashSlashes.SlashB:Clone()
					elseif v5 == 3 then
						clone3 = script2.DashSlashes.SlashC:Clone()
					end

					debris:AddItem(clone3, 3)
					clone3.CFrame = clone2.CFrame * CFrame.new(
						math.random(-10, 10),
						math.random(-5, 5),
						math.random(-5, 5)
					) * CFrame.Angles(
						math.rad((math.random(-25, 25))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")
					local descendants3 = clone3:GetDescendants()

					for _, instance in ipairs(descendants3) do
						if instance:IsA("Beam") then
							instance.CurveSize0 *= v3
							instance.CurveSize1 *= v3
							instance.Width0 *= v3 / 1
							instance.Width1 *= v3 / 1
							local tween = TweenService:Create(
								instance,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CurveSize0 = instance.CurveSize0 * v4,
									CurveSize1 = instance.CurveSize1 * v4,
									Width0 = instance.Width0 * v4,
									Width1 = instance.Width1 * v4
								}
							)
							tween:Play()
							local v6 = instance
							task.spawn(function()
								tween.Completed:Wait()
								task.wait(0.05)
								local endDelay = v6:GetAttribute("EndDelay")
								tween = TweenService:Create(
									v6,
									TweenInfo.new(endDelay / 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								)
								tween:Play()
								tween.Completed:Wait()
								v6:Destroy()
							end)
						elseif instance:IsA("Attachment") then
							instance.Position = Vector3.new(
								instance.Position.X * v3,
								instance.Position.Y * v3,
								instance.Position.Z * v3
							)
							TweenService:Create(
								instance,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Position = Vector3.new(
										instance.Position.X * v4,
										instance.Position.Y * v4,
										instance.Position.Z * v4
									)
								}
							):Play()
						end
					end

					task.spawn(function()
						local v6 = math.random(30, 50)

						for _ = 1, 5 do
							local tween = TweenService:Create(
								clone3,
								TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									CFrame = clone3.CFrame * CFrame.Angles(0, 0, (math.rad(-v6)))
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end

						TweenService:Create(clone3, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							CFrame = clone3.CFrame * CFrame.Angles(0, 0, (math.rad(-v6)))
						}):Play()
					end)
					task.wait(0.025)
				end
			end)
			task.spawn(function()
				local clone3 = script2.TRexModel:Clone()
				debris:AddItem(clone3, 3)
				clone3.PrimaryPart.CFrame = cFrame * CFrame.new(0, 12, 10)
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")
				local tween = TweenService:Create(
					clone3.PrimaryPart,
					TweenInfo.new(0.27, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, 0, -distance)
					}
				)
				tween:Play()
				local descendants3 = clone3:GetDescendants()
				tween.Completed:Wait()

				for _, instance in ipairs(descendants3) do
					if instance:IsA("BasePart") then
						TweenService:Create(
							instance,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					elseif instance:IsA("ParticleEmitter") then
						instance.Enabled = false
					elseif instance:IsA("Beam") then
						instance.Enabled = false
					end
				end
			end)
			task.wait(0.3)

			if v and v2 then
				v:Set(cFrame.LookVector * 30)
				task.delay(0.05, function()
					v2:Destroy()
					v:Destroy()
				end)
			end

			local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -15)
			ScreenEffect(cFrame2.Position) -- equivalent call inferred; original call site unknown
			local clone3 = script2.CrossSlash:Clone()
			debris:AddItem(clone3, 2)
			clone3.CFrame = cFrame2
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "TRexFruitVFXColor")
			local descendants3 = clone3:GetDescendants()

			for _, emitter in ipairs(descendants3) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = emitter
				coroutine.wrap(function()
					if v4:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v4:GetAttribute("EmitDelay"))
					end

					v4:Emit(v4:GetAttribute("EmitCount"))
				end)()
			end
		end
	end
end