local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
return function(data)
	local cFrame = data.CFrame
	local segments = data.Segments or 3
	local strength = data.Strength or 5
	local narrowness = data.Narrowness or 1.9
	local scale = data.Scale or 1
	local initialGap = data.InitialGap or 7
	local speedFactor = data.SpeedFactor or 1.5
	local folder = Instance.new("Folder", workspace._WorldOrigin)
	local signal = Util.Signal2.new()
	local flag = false
	task.spawn(function()
		while true do
			local count = 0

			for _ = 1, strength do
				for _ = 1, segments do
					count += 1
					local v = (4 + math.random() * 2) * 2
					local v2 = 2 + math.random() * 4
					local number = Random.new(tick() * count):NextNumber(-1, 1)
					local v3 = math.map(number, -1, 1, 0, 1)
					local v4 = 6.283185307179586 * math.random() + (v % 2 == 0 and 1 or 0) * 3.141592653589793 / 4 + 0.20943951023931956 * number
					local v5 = v2 / 4 + 1
					local v6 = ((1 - v3) * 0.1 + v3) * 0.25 + v5 * 0.1
					local v7 = cFrame * CFrame.Angles(0, v4, 0) * CFrame.new(
						0,
						0,
						-(scale * v5) / narrowness * v - initialGap
					)
					local p = v7.p
					local v8 = v7 * Vector3.new(0, v3 * v, 0)
					local unit = (cFrame.p - v8).Unit
					local rayMap, v9, v10 = Util.RayMap(p, createVector(-0, -10, -0))

					if not rayMap then
						continue
					end

					local v11 = unit
					local v12 = v9
					local v13 = v10
					local v14 = rayMap
					task.delay(count / segments * 0.9 / speedFactor, function()
						if flag then
							return
						end

						v5 *= scale
						v6 *= scale
						local v15 = (0.8 + math.random() * 0.2) * -3.141592653589793 / 2.5
						local v16 = v6 * 2
						local part = Instance.new("Part")
						part.Size = createVector(1, 1, 1) * v5 * scale * 0.8 + Vector3.new(
							math.random(),
							math.random() / 2,
							math.random()
						) * scale
						part.CFrame = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), v11) + v12, v13) - v13 * part.Size.Y / 2
						local lookVector = part.CFrame.LookVector
						part.Color = v14.Color
						part.Material = v14.Material
						part.Anchored = true
						part.CanCollide = false
						part.CanQuery = false
						part.CanTouch = false
						part.TopSurface = 0
						part.BottomSurface = 0
						part.Parent = folder
						local v17 = nil
						local v18 = nil
						local tween = TweenService:Create(
							part,
							TweenInfo.new(
								(2.4 + math.random() * 0.6) / speedFactor,
								Enum.EasingStyle.Circular,
								Enum.EasingDirection.In
							),
							{
								CFrame = part.CFrame * CFrame.Angles(v15, 0, 0) + 1.5 / scale * (v11 * (scale * v5) / (narrowness * 2)) + v13 * part.Size.Y * 0.75
							}
						)
						tween.Completed:Connect(function()
							if flag then
								return
							end

							v17 = TweenService:Create(
								part,
								TweenInfo.new(2.4 / speedFactor, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
								{
									CFrame = part.CFrame * CFrame.Angles(
										math.random() * 3.141592653589793,
										math.random() * 3.141592653589793,
										math.random() * 3.141592653589793
									) + createVector(0, 1, 0) * (6 + math.random() * 8) + 2 / scale * (lookVector * (scale * v5) / (narrowness * 2)) + v13 * part.Size.Y * 0.25
								}
							)
							v17.Completed:Connect(function()
								if flag then
									return
								end

								v18 = TweenService:Create(
									part,
									TweenInfo.new(0.2 / speedFactor, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
									{
										Size = createVector(0.01, 0.01, 0.01)
									}
								)
								v18.Completed:Connect(function()
									if flag then
										return
									end

									part:Destroy()
								end)
								v18:Play()
							end)
							v17:Play()
						end)
						tween:Play()
						signal:Connect(function()
							if v18 then
								v18:Cancel()
								v18:Destroy()
								v17:Destroy()
							elseif v17 then
								v17:Cancel()
								v17:Destroy()
							else
								tween:Cancel()
							end

							tween:Destroy()
							part.Anchored = false
							part.Velocity = createVector(0, 1, 0) * math.random(40, 260) * scale - v11 * math.random(
								10,
								20
							) * scale
							part.RotVelocity = CFrame.lookAt(createVector(0, 0, 0), v11).RightVector * (2 + math.random()) * 2
							local tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.2 / speedFactor, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Size = createVector(0.01, 0.01, 0.01)
								}
							)
							tween2.Completed:Connect(function()
								part:Destroy()
							end)
							tween2:Play()
						end)
					end)
				end
			end

			task.wait(count / segments * 0.9 / speedFactor)
		end
	end)
	task.spawn(function()
		while data.Holding and data.Holding:IsDescendantOf(workspace) and data.Holding.Value do
			task.wait()
		end

		flag = true
		signal:Fire()
		task.wait(3)
		folder:Destroy()
		signal:Destroy()
	end)
end