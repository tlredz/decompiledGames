local createVector = vector.create
local RockScript = {}
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("RunService")
local visuals = workspace:WaitForChild("Visuals")
local part = script:WaitForChild("Part")
local Folders = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower,
	workspace.Character,
	workspace.Monster
}

function RockScript.Ground(p, p2, p3, p4, duration, p5)
	local v = CFrame.new(p.Position) * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
	local clones = {}

	for i = 1, p4 do
		local clone = part:Clone()
		clone.Anchored = true
		clone.CFrame = v * CFrame.Angles(0, math.rad(360 / p4 * i), 0)
		clone.CFrame *= CFrame.new(0, -p3 / 2, 0)
		Debris:AddItem(clone, 10)
		table.insert(clones, clone)
		local v2 = clone.CFrame * CFrame.new(0, 2, -p2) * CFrame.Angles(
			math.rad((math.random(-360, 360))),
			math.rad((math.random(-360, 360))),
			(math.rad((math.random(-360, 360))))
		)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = Folders
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(
			v2.p + createVector(0, 10, 0),
			CFrame.new(v2.p).UpVector * -25,
			raycastParams
		)

		if raycastResult and raycastResult.Instance then
			local instance = raycastResult.Instance

			if p5 then
				p5.Enabled = true
				task.spawn(function()
					task.wait(duration - 0.25)

					if p5 and p5.Parent then
						p5.Enabled = false
					end
				end)
			end

			clone.Color = instance.Color or Color3.fromRGB(163, 162, 165)
			clone.Material = instance.Material or Enum.Material.Concrete
			local cFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			)
			clone.Parent = visuals

			if p == nil then
				TweenService:Create(clone, TweenInfo.new(0.27, Enum.EasingStyle.Sine), {
					CFrame = cFrame
				}):Play()
				TweenService:Create(clone.Mesh, TweenInfo.new(0.27, Enum.EasingStyle.Sine), {
					Scale = Vector3.new(p3, p3, p3) * (math.random(50, 100) / 100)
				}):Play()
			else
				clone.CFrame = cFrame
				clone.Mesh.Scale = Vector3.new(p3, p3, p3) * (math.random(50, 100) / 100)
			end

			if p == nil then
				task.wait(0.25)
			end
		elseif clone and clone.Parent then
			clone:Destroy()
		end
	end

	task.delay(duration, function()
		for _, v2 in ipairs(clones) do
			if v2 and v2.Parent and v2:FindFirstChild("Mesh") == nil then
				v2:Destroy()
				return
			end

			if not (v2 and v2.Parent) then
				continue
			end

			TweenService:Create(v2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				Position = v2.Position - createVector(0, 7, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(v2, 1)
		end

		table.clear(clones)
		clones = nil
	end)
end

function RockScript.SpawnRock(cFrame, p, p2, p3, duration)
	if typeof(cFrame) == "Instance" then
		cFrame = cFrame.CFrame
	end

	local v = 6.719600000000001 * p2 / p
	local total = 0
	local v2 = {}

	for _ = 1, p do
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.Size = Vector3.new(v, p3, p3)
		part2.CFrame = cFrame * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(0, 2, p2) * CFrame.Angles(
			-math.rad((math.clamp(5 * Random.new():NextNumber(8, 10), 40, 50))),
			math.rad(1 * Random.new():NextNumber(-0.5, 0.5)),
			(math.rad(1 * Random.new():NextNumber(-0.5, 0.5)))
		)
		Debris:AddItem(part2, 10)
		table.insert(v2, part2)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = Folders
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(part2.Position, createVector(0, -20, 0), raycastParams)

		if raycastResult and raycastResult.Instance then
			local instance = raycastResult.Instance

			if instance then
				part2.Position = raycastResult.Position - Vector3.new(0, p3 * 2, 0)
				part2.Parent = visuals
				part2.Color = instance.Color
				part2.Material = instance.Material
				TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
					Position = raycastResult.Position - createVector(0, 0.5, 0)
				}):Play()
			elseif part2 and part2.Parent then
				part2:Destroy()
			end
		end

		total += 360 / p
	end

	task.delay(duration, function()
		for _, v3 in ipairs(v2) do
			if not (v3 and v3.Parent) then
				continue
			end

			TweenService:Create(v3, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
				Position = v3.Position - Vector3.new(0, p3, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(v3, 1)
		end

		table.clear(v2)
		v2 = nil
	end)
end

function RockScript.FlyingRock(position, p, size, data, value, canCollide)
	for _ = 1, p do
		local part2 = Instance.new("Part")
		part2.Size = size

		if canCollide then
			part2.CanCollide = canCollide
			part2.CollisionGroup = "Player"
		else
			part2.CanCollide = false
		end

		part2.Anchored = false
		part2.CFrame = CFrame.new(position)
		Debris:AddItem(part2, 5)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = Folders
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(part2.Position, part2.CFrame.UpVector * -10, raycastParams)

		if raycastResult and raycastResult.Instance then
			part2.Color = raycastResult.Instance.Color or Color3.fromRGB(163, 162, 165)
			part2.Material = raycastResult.Instance.Material or Enum.Material.Concrete
			part2.Parent = visuals
			part2.Velocity = Vector3.new(
				math.random(data.X.Min, data.X.Max),
				math.random(data.Y.Min, data.Y.Max),
				math.random(data.Z.Min, data.Z.Max)
			)
		elseif part2 and part2.Parent then
			part2:Destroy()
		end

		if not (part2 and part2.Parent) then
			continue
		end

		local v = part2
		task.delay(value or 1.5, function()
			TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			task.wait(1)

			if v and v.Parent then
				v:Destroy()
			end
		end)
	end
end

return RockScript