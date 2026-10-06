local createVector = vector.create
local WindModule = {}
local v = {}
local now = os.clock()
local _ = game.Players.LocalPlayer
local Config = require(script:WaitForChild("Config"))
local currentCamera = workspace.CurrentCamera

function WindModule:CreateWind()
	local position = (currentCamera.CFrame * CFrame.Angles(
		math.rad((math.random(-25, 70))),
		math.rad((math.random(-75, 75))),
		0
	) * CFrame.new(0, 0, math.random(200, 400) * -0.5)).Position
	local windDirection = CFrame.Angles(0, 0.7853981633974483, 0) * createVector(-0, -0, -1)
	local cframe = CFrame.new(position, position + windDirection)
	local clone = script.WindPart:Clone()
	clone.CFrame = cframe
	clone.Parent = workspace.Effects
	local v3 = {
		WindPart = clone,
		WindDirection = windDirection,
		WindSpeed = math.random(40, 75) * 1.25,
		Seed = math.random(1, 99999),
		Height = math.random(4, 12),
		Frequency = math.random(125, 200) / 100,
		SpawnOrigin = cframe,
		SpawnTime = os.clock(),
		Step = function(callback)
			callback(clone)
		end
	}
	table.insert(v, v3)
end

function WindModule.Update(_, _)
	local now2 = os.clock()

	if now2 - now > 1 / Config.SpawnRate then
		now = os.clock()
		WindModule:CreateWind()
	end

	local count = 0
	local instances = {}
	local v2 = {}

	for i = #v, 1, -1 do
		local v3 = v[i]

		if not v3 then
			continue
		end

		local v4 = v3
		local v5 = i
		local _, _ = pcall(function()
			return v4.Step(function(instance)
				local windSpeed = v4.WindSpeed
				local windDirection = v4.WindDirection
				local seed = v4.Seed
				local spawnTime = v4.SpawnTime
				local spawnOrigin = v4.SpawnOrigin
				local v6 = now2 - spawnTime

				if Config.LifeTime < v6 then
					task.delay(1, function()
						instance:Destroy()
					end)
					table.remove(v, v5)
					table.clear(v4)
				else
					count += 1
					instances[count] = instance
					v2[count] = spawnOrigin * CFrame.new(0, math.sin(tick() * v4.Frequency + v4.Seed) * v4.Height, 0) + windDirection * (os.clock() - v4.SpawnTime) * windSpeed

					if Config.LifeTime / 2 < v6 then
						local maxLength = 100 - 100 * ((v6 - Config.LifeTime / 2) / (Config.LifeTime - Config.LifeTime / 2))
						instance.WindTrail.MaxLength = maxLength
					end
				end
			end)
		end)
	end

	workspace:BulkMoveTo(instances, v2, Enum.BulkMoveMode.FireCFrameChanged)
end

return WindModule