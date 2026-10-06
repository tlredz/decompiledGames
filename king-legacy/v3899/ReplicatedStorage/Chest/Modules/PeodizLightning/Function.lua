local createVector = vector.create
local RunService = game:GetService("RunService")
return {
	Play = function(self)
		spawn(function()
			local lastTime = tick()
			local parent = workspace:FindFirstChild("Effects")

			if not parent then
				parent = Instance.new("Folder")
				parent.Name = "Effects"
				parent.Parent = workspace
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Position = self.Position1
			part.Transparency = 1
			part.Parent = parent
			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.Position = self.Position2
			part2.Transparency = 1
			part2.Parent = parent
			local magnitude = (part.Position - part2.Position).Magnitude
			local unit = (part2.Position - part.Position).Unit
			local v2 = {}
			local v3 = {}
			local positions = {}
			local v4 = {}

			for i = 0, self.Step do
				v2[#v2 + 1] = CFrame.new(part.Position, part.Position + unit) * CFrame.new(
					0,
					0,
					-magnitude / self.Step * i
				)
			end

			for i = 1, #v2 do
				local cFrame = v2[i]
				local part3 = Instance.new("Part")
				part3.Anchored = true
				part3.Transparency = 1
				part3.CanCollide = false
				part3.CFrame = cFrame
				part3.Size = createVector(0, 0, 0)
				part3.Parent = workspace.Effects
				v3[i] = part3
				positions[i] = part3.Position
			end

			while true do
				local magnitude2 = (part.Position - part2.Position).Magnitude
				local unit2 = (part2.Position - part.Position).Unit
				local v5 = {}

				for i = 0, self.Step do
					v5[#v5 + 1] = CFrame.new(part.Position, part.Position + unit2) * CFrame.new(
						0,
						0,
						-magnitude2 / self.Step * i
					)
				end

				for i = 1, #v5 do
					positions[i] = v5[i].Position
				end

				for i = 1, #v3 do
					if i == 1 or i == #v3 then
						if i == #v3 then
							local TweenService = game:GetService("TweenService")
							TweenService:Create(v3[i], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Position = part2.Position
							}):Play()
						else
							local TweenService = game:GetService("TweenService")
							TweenService:Create(v3[i], TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Position = part.Position
							}):Play()
						end
					else
						local TweenService = game:GetService("TweenService")
						TweenService:Create(v3[i], self.Tween, {
							Position = positions[i] + Vector3.new(
								math.random(-22, 22),
								math.random(-22, 22),
								math.random(-22, 22)
							)
						}):Play()
					end

					if not v4[i] and v3[i + 1] then
						local magnitude3 = (v3[i].Position - v3[i + 1].Position).Magnitude
						local part3 = Instance.new("Part")
						part3.Anchored = true
						part3.CanCollide = false
						part3.Material = "Neon"
						part3.Color = Color3.fromRGB(255, 255, 255)
						part3.Size = Vector3.new(0.5, 0.5, magnitude3)
						part3.CFrame = CFrame.new(v3[i].Position, v3[i + 1].Position) * CFrame.new(
							0,
							0,
							-magnitude3 / 2
						)
						part3.Parent = workspace.Effects
						v4[i] = part3
					end

					if not (v4[i] and v3[i + 1]) then
						continue
					end

					local magnitude3 = (v3[i].Position - v3[i + 1].Position).Magnitude
					v4[i].Size = Vector3.new(0.5, 0.5, magnitude3)
					v4[i].CFrame = CFrame.new(v3[i].Position, v3[i + 1].Position) * CFrame.new(0, 0, -magnitude3 / 2)
				end

				if tick() - lastTime >= self.Time then
					for _, v6 in pairs(v3) do
						v6:Destroy()
					end

					for _, v6 in pairs(v4) do
						local TweenService = game:GetService("TweenService")
						TweenService:Create(v6, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
							Transparency = 1,
							Size = Vector3.new(0, 0, v6.Size.Z)
						}):Play()
						local v7 = v6
						coroutine.wrap(function()
							wait(0.5)
							v7:Destroy()
						end)()
					end

					part:Destroy()
					part2:Destroy()
					break
				else
					RunService.Heartbeat:Wait()
				end
			end
		end)
	end
}