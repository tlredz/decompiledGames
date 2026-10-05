local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
return function(data)
	local cFrame = data.CFrame
	local segments = data.Segments or 8
	local strength = data.Strength or 10
	local narrowness = data.Narrowness or 1.9
	local scale = data.Scale or 1.15
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
					local v15 = number
					task.delay(count / segments * 0.15 / speedFactor, function()
						if flag then
							return
						end

						v5 *= scale
						v6 *= scale
						local v16 = (0.6 + math.random() * 0.4) * -3.141592653589793 / 4
						local v17 = v6 * 3
						local part = Instance.new("Part")
						part.Size = Vector3.new(v5 + v2 * 0.25 * (1 + math.random()) * 2, scale * v17, scale * v5)
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
						local v18 = nil
						local v19 = nil
						local tween = TweenService:Create(
							part,
							TweenInfo.new(
								(0.3 + math.random() * 0.2) / speedFactor,
								Enum.EasingStyle.Circular,
								Enum.EasingDirection.Out
							),
							{
								CFrame = part.CFrame * CFrame.Angles(v16, 0, 0) + 1.5 / scale * (v11 * (scale * v5) / (narrowness * 2)) + v13 * part.Size.Y * 0.75
							}
						)
						tween.Completed:Connect(function()
							if flag then
								return
							end

							v18 = TweenService:Create(
								part,
								TweenInfo.new(1 / speedFactor, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
								{
									CFrame = part.CFrame * CFrame.Angles(
										-0.7853981633974483 * (0.2 + math.random() * 0.2),
										v16 * v15 * 0.25,
										0
									) + 17 / scale * (lookVector * (scale * v5) / (narrowness * 2)) + v13 * part.Size.Y * 0.25
								}
							)
							v18.Completed:Connect(function()
								if flag then
									return
								end

								v19 = TweenService:Create(
									part,
									TweenInfo.new(0.2 / speedFactor, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
									{
										CFrame = part.CFrame * CFrame.Angles(-v16 * math.random(), -v16 * v15, 0) - v13 * part.Size.Y * 1.5
									}
								)
								v19.Completed:Connect(function()
									if flag then
										return
									end

									part:Destroy()
								end)
								v19:Play()
							end)
							v18:Play()
						end)
						tween:Play()
						signal:Connect(function()
							if v19 then
								v19:Cancel()
								v19:Destroy()
								v18:Destroy()
							elseif v18 then
								v18:Cancel()
								v18:Destroy()
							else
								tween:Cancel()
							end

							tween:Destroy()
							part.Anchored = false
							part.Velocity = createVector(0, 1, 0) * math.random(20, 100) - v11 * math.random(10, 50)
							part.RotVelocity = CFrame.lookAt(createVector(0, 0, 0), v11).RightVector * (1 + math.random()) * 2
						end)
					end)
				end
			end

			task.wait(count / segments * 0.15 / speedFactor)
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