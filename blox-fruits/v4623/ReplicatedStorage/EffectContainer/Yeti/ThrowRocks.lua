local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
return function(p)
	local root = p.Root
	local duration = p.Duration or 2.5

	if typeof(root) ~= "Instance" or not root:IsA("BasePart") then
		return
	end

	local random = Random.new()

	local function spawnRock(vector2: Vector3)
		local ray = Util.Ray
		local v = { workspace.Characters, workspace.Enemies }
		local v2, v3 = ray(vector2, createVector(0, -18, 0), v)

		if not (v2 and v3) then
			return
		end

		local number = random:NextNumber(2.5, 4.5)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(number, number, number)
		part.Material = v2.Material
		part.Color = v2.Color
		part.Position = v3 + createVector(0, -5, 0)
		part.CFrame *= CFrame.Angles(
			math.rad((random:NextInteger(-180, 180))),
			math.rad((random:NextInteger(-180, 180))),
			(math.rad((random:NextInteger(-180, 180))))
		)
		part.Parent = workspace._WorldOrigin
		TweenService:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Exponential), {
			Position = part.Position + createVector(0, 5, 0)
		}):Play()
		task.delay(0.25, function()
			if not part.Parent then
				return
			end

			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = part.Position + createVector(0, -5, 0),
				Size = createVector(0.5, 0.5, 0.5)
			}):Play()
			debris:AddItem(part, 0.5)
		end)
	end

	local lastTime = tick()
	local position = root.Position
	local flag = false
	local count = 0
	local v = 0

	while tick() - lastTime < duration do
		local v2 = RunService.PreSimulation:Wait()

		if not root.Parent then
			break
		end

		local position2 = root.Position
		local v3 = position2 - position
		local magnitude = v3.Magnitude

		if (not (v2 > 0) and 0 or magnitude / v2) < 70 then
			if flag then
				count += 1

				if count >= 5 then
					break
				end
			end

			position = position2
		else
			flag = true
			count = 0

			if magnitude <= 0 then
				position = position2
			else
				v += magnitude
				position = position2

				while v >= 7 do
					v -= 7
					spawnRock(position2 - v3.Unit * math.min(v, magnitude))
				end
			end
		end
	end
end