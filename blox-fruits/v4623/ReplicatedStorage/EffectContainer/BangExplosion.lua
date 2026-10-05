local createVector = vector.create
local _WorldOrigin = workspace._WorldOrigin
local FXCreator = require(game.ReplicatedStorage.FXCreator)
local v = FXCreator.Build()
return function(instance)
	local cFrame = instance.CFrame
	local size = instance.Size or 175
	local color = instance.Color or Color3.fromRGB(120, 170, 255)
	local finalColor = instance.FinalColor or color
	local windColor = instance.WindColor or Color3.new(1, 1, 1)
	local duration = instance.Duration or 4
	local skip

	if instance.Skip == nil then
		skip = false
	else
		skip = instance.Skip or false
	end

	local distance = v.Distance(cFrame.Position)

	if 600 + size * 10 < distance then
		return
	end

	if skip then
		duration += duration * 0.375
	end

	local attachment = Instance.new("Attachment")
	attachment.Position = cFrame.Position
	attachment.Parent = workspace.Terrain
	local v2 = {}

	for _ = 1, math.max(2 + size / 10, 30) do
		local width = 4 + math.random() * 4
		local unit = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).unit
		local length = 18 + math.random() * 4
		local beam = Instance.new("Beam")
		beam.Transparency = NumberSequence.new(0)
		beam.LightEmission = 0.5
		beam.FaceCamera = true
		beam.Segments = 1
		beam.Color = ColorSequence.new(instance.BeamSameColor and color or Color3.new(1, 1, 1), color)
		beam.Width0 = 0
		beam.Width1 = width
		local clone = attachment:Clone()
		clone.Position = cFrame.p + unit * length
		beam.Attachment0 = attachment
		beam.Attachment1 = clone
		beam.Parent = _WorldOrigin
		clone.Parent = workspace.Terrain
		table.insert(v2, {
			Ray = beam,
			Width = width,
			Dir = unit,
			Length = length,
			Offset = 0.2 + math.random() * 0.25
		})
	end

	local ball = v.Create.Ball({
		CFrame = cFrame,
		Color = color,
		Material = "Neon"
	})
	local animator = v.Animator(ball, 200 + size * 3)
	animator.Custom({
		Function = function(p)
			local v3 = size * 0.3333333333333333
			local v4 = v3 * math.sin(37.69911184307752 * p) * 0.7 ^ (3 * p)
			ball.Size = createVector(1, 1, 1) * (v3 / 6 + v4)

			for _, v5 in next, v2, nil do
				local quad = v.Tween.ease.inout.quad(math.min(1, p + v5.Offset), 0, 1, 1)
				local ray = v5.Ray
				local _ = ray.Attachment0
				local attachment1 = ray.Attachment1

				if quad > 0.875 then
					local v6 = (quad - 0.875) / 0.125
					ray.Width0 = 0
					ray.Width1 = v5.Width * (1 - v6)
					ray.Transparency = NumberSequence.new(v6)
				end

				attachment1.Position = cFrame.p + (v5.Dir + Vector3.new(0, quad * 0.35, 0)) * v5.Length * (quad * 5)
			end
		end,
		Time = skip and 0 or duration * 0.375,
		Tween = v.Tween.ease.out.linear,
		Completed = function()
			animator.Size({
				From = ball.Size,
				To = createVector(1, 1, 1) * size,
				Time = duration * 0.75,
				Tween = v.Tween.ease.out.expo
			})
			local v3 = false
			animator.Custom({
				Function = function(p)
					if not v3 then
						v3 = true

						for _, v4 in next, v2, nil do
							v4.Width = size * 0.22857142857142856
							v4.Dir = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).unit
							v4.Ray.Transparency = NumberSequence.new(0)
							v4.Ray.Width0 = 0
							v4.Ray.Width1 = v4.Width
						end
					end

					for _, v4 in next, v2, nil do
						v4.Length = ball.Size.X * 0.75
						local quad = v.Tween.ease.inout.quad(math.min(1, p + v4.Offset), 0, 1, 1)
						local ray = v4.Ray
						local _ = ray.Attachment0
						local attachment1 = ray.Attachment1

						if quad > 0.75 then
							local v5 = (quad - 0.75) / 0.25
							ray.Width0 = 0
							ray.Width1 = v4.Width * (1 - v5)
							ray.Transparency = NumberSequence.new(v5)

							if finalColor then
								ray.Color = ColorSequence.new((instance.BeamSameColor and color or Color3.new(1, 1, 1)):Lerp(
									finalColor,
									v5
								))
							end
						end

						attachment1.Position = cFrame.p + (v4.Dir + Vector3.new(0, quad * 0.35, 0)) * v4.Length * (quad * 5)
					end
				end,
				Completed = function()
					for _, v4 in next, v2, nil do
						v4.Ray.Attachment1:Destroy()
						v4.Ray:Destroy()
					end

					attachment:Destroy()
				end,
				Time = duration * 0.75,
				Tween = v.Tween.ease.out.linear
			})
			Spawn(function()
				local v4 = 0

				for _ = 1, duration * 0.25 / 0.1 do
					local cFrame2 = CFrame.new(cFrame.p + createVector(0, 5, 0)) * CFrame.Angles(
						3.141592653589793,
						math.random() * 3.141592653589793 * 2,
						3.141592653589793
					)
					local part = v.Create.Part({
						Material = "Neon",
						CFrame = cFrame2,
						Color = windColor
					})
					local v6 = v.Create.SpecialMesh({
						MeshId = "rbxassetid://769557556",
						Parent = part
					})
					local parent = part
					v.Animator(part, 200 + size * 3).Custom({
						Function = function(transparency)
							v6.Scale = createVector(1, 0.5, 1) * transparency * (size * 0.02857142857142857)
							part.Transparency = transparency
						end,
						Completed = function()
							parent:Destroy()
						end,
						Time = 1,
						Tween = v.Tween.ease.out.sine
					})
					part:AddToWorld()
					local cFrame3 = cFrame * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2
					)
					local part2 = v.Create.Part({
						Material = "Neon",
						CFrame = cFrame3,
						Color = windColor
					})
					local v12 = v.Create.SpecialMesh({
						MeshId = "rbxassetid://854960593",
						Parent = part2
					})
					local parent2 = part2
					v.Animator(part2, 200 + size * 3).Custom({
						Function = function(transparency)
							part2.CFrame = cFrame3 * CFrame.Angles(0, transparency, 0)
							v12.Scale = createVector(1, 1, 1) * size * 0.25 + createVector(1, 0.5, 1) * transparency * size * 2
							part2.Transparency = transparency
						end,
						Completed = function()
							parent2:Destroy()
						end,
						Time = 1,
						Tween = v.Tween.ease.out.linear
					})
					part2:AddToWorld()
					local lastTime = tick()
					wait(0.1 - v4)
					v4 = v4 + (tick() - lastTime) - 0.1
				end
			end)
		end
	})

	if not skip then
		Spawn(function()
			local v3 = 0

			for _ = 1, duration * 0.25 / 0.1 do
				local cFrame2 = cFrame * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				)
				local part = v.Create.Part({
					Material = "Neon",
					CFrame = cFrame2,
					Color = Color3.new(1, 1, 1)
				})
				local v7 = v.Create.SpecialMesh({
					MeshId = "rbxassetid://854960593",
					Parent = part
				})
				local parent = part
				v.Animator(part, 200 + size * 3).Custom({
					Function = function(transparency)
						part.CFrame = cFrame2 * CFrame.Angles(0, transparency * 4, 0)
						v7.Scale = createVector(1, 1, 1) * (size * 0.17142857142857143) + createVector(1, 0.5, 1) * transparency * (size * 0.34285714285714286)
						part.Transparency = transparency
					end,
					Completed = function()
						parent:Destroy()
					end,
					Time = 0.35,
					Tween = v.Tween.ease.out.linear
				})
				part:AddToWorld()
				local lastTime = tick()
				wait(0.1 - v3)
				v3 = v3 + (tick() - lastTime) - 0.1
			end
		end)
	end

	ball:AddToWorld()
	task.wait(duration * 0.75 - (not skip and 0 or duration * 0.375 or 0))
	animator.Transparency({
		From = 0,
		To = 1,
		Time = duration * 0.25,
		Completed = function()
			ball:Destroy()
		end
	})
end