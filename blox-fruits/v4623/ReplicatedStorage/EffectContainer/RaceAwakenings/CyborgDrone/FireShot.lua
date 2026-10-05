local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
local cyborgDrone = FX:WaitForChild("RaceAwakenings").CyborgDrone
local v = {
	MAX = 5,
	DURATION = 10,
	FIRE_TIME = 0.2,
	CHANCE = 0.25,
	RADIUS = 12.5,
	PROJECTILE_LIFE = 0.2,
	loopActive = false,
	shotLoopActive = false,
	Active = {},
	Shots = {}
}

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function explodeAt(position)
	local clone = cyborgDrone.Explode:Clone()
	debris:AddItem(clone, 1)
	clone.Position = position
	clone.Parent = _WorldOrigin
	Util.Sound:Play("DiamondBreak", position, nil, 0.8, 0.2)
	Util.Sound:Play("Hit1Electric", position, nil, math.random(18, 25) / 10, 0.15)

	for _, child in pairs(clone.Particles:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end
end

local function startShotLoop()
	local _, result = pcall(function()
		if #v.Shots > 0 then
			v.shotLoopActive = true

			while #v.Shots > 0 do
				local now = tick()

				for k, nows in pairs(v.Shots) do
					if nows[1] and nows[1].Parent ~= nil and nows[4] and nows[4].Parent ~= nil then
						if now - nows[2] < v.PROJECTILE_LIFE then
							local magnitude = (nows[3] - nows[4].Position).Magnitude
							local cframe = CFrame.new(nows[3], nows[4].Position)
							local v2 = cframe * CFrame.new(0, 0, -magnitude)
							local v3 = {
								nows[3],
								(cframe:lerp(v2, 0.25) * CFrame.new(
									nows[5][1][1] * magnitude / 35,
									nows[5][1][2] * magnitude / 35,
									nows[5][1][3] * magnitude / 35
								)).Position,
								(cframe:lerp(v2, 0.5) * CFrame.new(
									nows[5][2][1] * magnitude / 35,
									nows[5][2][2] * magnitude / 35,
									nows[5][2][3] * magnitude / 35
								)).Position,
								nows[4].Position
							}
							local v4 = nows[1]
							v4.Position = cubicBezier((now - nows[2]) / v.PROJECTILE_LIFE, v3[1], v3[2], v3[3], v3[4])

							if now - nows[6] > 0.02 then
								nows[1].Electricity:Emit(1)
								nows[6] = tick()
							end
						else
							nows[1].Spikes:Emit(3)
							nows[1].PlasmaBurst:Emit(1)
							local v2 = nows[1]
							table.remove(v.Shots, k)
							task.delay(0.4, function()
								if v2 then
									v2:Destroy()
								end
							end)
						end
					else
						table.remove(v.Shots, k)
					end
				end

				RunService.RenderStepped:Wait()
			end

			v.shotLoopActive = false
		end
	end)

	if result then
		warn("[Cyborg Drones] Something went wrong in the projectile loop: \n")
		warn(result)

		if #v.Shots > 0 then
			for _, shot in pairs(v.Shots) do
				if shot[1] ~= nil then
					shot[1]:Destroy()
				end
			end
		end

		v.Shots = {}
		v.shotLoopActive = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireProjectile(startPos, goalPart)
	task.spawn(function()
		if goalPart and goalPart.Parent ~= nil then
			if (workspace.CurrentCamera.CFrame.Position - goalPart.Position).Magnitude > 700 then
				return
			end

			Util.Sound:Play("LaserShot2", startPos, nil, 2.5, 0.2)
			local clone = cyborgDrone.ProjectileTrail:Clone()
			debris:AddItem(clone, v.PROJECTILE_LIFE + 1)
			clone.Position = startPos
			clone.A0.FlavorTrail.Enabled = true
			clone.A0.Trail.Enabled = true
			clone.Parent = _WorldOrigin
			local now = tick()
			local v2 = {
				{ math.random(-15, 15), math.random(-2, 10), math.random(-5, 5) },
				{ math.random(-15, 15), math.random(-2, 10), math.random(-5, 5) }
			}
			table.insert(v.Shots, {
				clone,
				now,
				startPos,
				goalPart,
				v2,
				now
			})

			if v.shotLoopActive == false then
				startShotLoop()
			end
		end
	end)
end

return function(p)
	fireProjectile(p.startPos, p.goalPart) -- equivalent call inferred; original call site unknown
end