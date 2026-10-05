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

local function cflerp(cFrame, p, p2)
	return cFrame:lerp(p, p2)
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
local function fireProjectile(position, instance, p)
	task.spawn(function()
		if instance and instance.Parent ~= nil then
			if (workspace.CurrentCamera.CFrame.Position - instance.Position).Magnitude > 700 then
				return
			end

			Util.Sound:Play("LaserShot2", position, nil, p and 1 or 2.5, 0.2)
			local clone = cyborgDrone.ProjectileTrail:Clone()
			debris:AddItem(clone, v.PROJECTILE_LIFE + 1)
			clone.Position = position
			clone.A0.FlavorTrail.Enabled = true
			clone.A0.Trail.Enabled = true
			clone.Parent = _WorldOrigin

			if p then
				clone.Electricity.Color = ColorSequence.new(Color3.fromRGB(196, 247, 5))
				clone.PlasmaBurst.Color = ColorSequence.new(Color3.fromRGB(196, 247, 5))
				clone.Spikes.Color = ColorSequence.new(Color3.fromRGB(196, 247, 5))
				clone.A0.FlavorTrail.Color = ColorSequence.new(Color3.fromRGB(196, 247, 5))
				clone.A0.Trail.Color = ColorSequence.new(Color3.fromRGB(196, 247, 5))
			end

			local now = tick()
			local v2 = {
				{ math.random(-15, 15), math.random(-2, 10), math.random(-5, 5) },
				{ math.random(-15, 15), math.random(-2, 10), math.random(-5, 5) }
			}
			table.insert(v.Shots, {
				clone,
				now,
				position,
				instance,
				v2,
				now
			})

			if v.shotLoopActive == false then
				startShotLoop()
			end
		end
	end)
end

local function startDroneLoop()
	local _, result = pcall(function()
		local v2 = 0.016666666666666666
		local v3 = 0

		if #v.Active > 0 then
			v.loopActive = true

			while #v.Active > 0 do
				local now = tick()

				for k, v4 in pairs(v.Active) do
					if v4[1] == nil or v4[1].Parent == nil then
						if v4[2] then
							for _, v5 in pairs(v4[2]) do
								if v5[1] ~= nil then
									v5[1]:Destroy()
								end
							end
						end

						table.remove(v.Active, k)
					elseif #v4[2] > 0 then
						for k2, v5 in pairs(v4[2]) do
							if v5[1] == nil or v5[1].Parent == nil then
								table.remove(v4[2], k2)
							elseif v5[1].PrimaryPart then
								if now - v5[2] < v.DURATION then
									if v5[4] == false then
										local v6 = CFrame.new(v4[1].Position) * CFrame.Angles(
											0,
											math.rad(v3 + 360 / #v4[2] * k2),
											0
										) * CFrame.new(0, 0, -v.RADIUS)
										local v7 = CFrame.new(v6.Position) * v5[3]
										v5[1]:SetPrimaryPartCFrame(cflerp(v5[1].PrimaryPart.CFrame, v7, v2 * 0.1 * 60))
									end
								else
									explodeAt(v5[1].PrimaryPart.Position)
									v5[1]:Destroy()
								end
							else
								v5[1]:Destroy()
							end
						end
					else
						table.remove(v.Active, k)
					end
				end

				local v4 = v3 + v2 * 60 * 1
				v3 = v4 >= 360 and 0 or v4
				v2 = RunService.RenderStepped:Wait()
			end

			v.loopActive = false
			v.Active = {}
		end
	end)

	if result then
		warn("[Cyborg Drones] Something went wrong in the main loop: \n")
		warn(result)

		if #v.Active > 0 then
			for _, v2 in pairs(v.Active) do
				if not (v2[2] and #v2[2] > 0) then
					continue
				end

				for _, v3 in pairs(v2[2]) do
					if v3[1] ~= nil then
						v3[1]:Destroy()
					end
				end
			end
		end

		v.Active = {}
		v.loopActive = false
	end
end

function v:Lookup(p)
	if not (#v.Active > 0) then
		return nil
	end

	for _, v2 in pairs(v.Active) do
		if v2[1] ~= nil and v2[1] == p then
			return v2
		end
	end
end

function v:DoLogic(p, list)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function getRandomDrone()
		local lookup = v:Lookup(p)

		if lookup and #lookup[2] > 0 then
			return lookup[2][math.random(1, #lookup[2])]
		end
	end

	local function fireEffect(primaryPart, instance)
		if instance and instance:IsDescendantOf(workspace) and primaryPart ~= nil and primaryPart.Parent ~= nil then
			if (workspace.CurrentCamera.CFrame.Position - instance.Position).Magnitude > 700 then
				return
			end

			fireProjectile(primaryPart.Position, instance, nil) -- equivalent call inferred; original call site unknown

			for _, child in pairs(primaryPart.FireAt:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end

	local function fireDrones(list2, list3)
		if list3 and #list3 > 0 then
			task.spawn(function()
				for k, v2 in pairs(list3) do
					if v2 and v2:IsDescendantOf(workspace) then
						if list2 == nil or k ~= 1 then
							local randomDrone = getRandomDrone() -- equivalent call inferred; original call site unknown

							if randomDrone and randomDrone[1] and randomDrone[1].PrimaryPart then
								fireEffect(randomDrone[1].PrimaryPart, v2)
								randomDrone[2] = tick()
								local cframe = CFrame.new(randomDrone[1].PrimaryPart.Position, v2.Position)
								randomDrone[3] = cframe - cframe.Position
							end
						else
							local primaryPart = list2[1].PrimaryPart

							if primaryPart then
								fireEffect(primaryPart, v2)
							end
						end
					end

					task.wait(v.FIRE_TIME / #list3)
				end
			end)
		end
	end

	local lookup = v:Lookup(p)

	if typeof(list) == "table" then
		local v2 = math.random(100) / 100

		if lookup == nil then
			local clone = cyborgDrone.DroneModel:Clone()
			clone.Parent = _WorldOrigin
			clone:SetPrimaryPartCFrame(CFrame.new(p.Position))
			table.insert(v.Active, {
				p,
				{
					{
						clone,
						tick(),
						CFrame.Angles(0, 0, 0),
						false
					}
				}
			})
			local v3 = v.Active[1][2][1]

			if list and #list > 0 then
				task.spawn(function()
					for k, v4 in pairs(list) do
						if v4 and v4:IsDescendantOf(workspace) then
							if v3 == nil or k ~= 1 then
								local randomDrone = getRandomDrone() -- equivalent call inferred; original call site unknown

								if randomDrone and randomDrone[1] and randomDrone[1].PrimaryPart then
									fireEffect(randomDrone[1].PrimaryPart, v4)
									randomDrone[2] = tick()
									local cframe = CFrame.new(randomDrone[1].PrimaryPart.Position, v4.Position)
									randomDrone[3] = cframe - cframe.Position
								end
							else
								local primaryPart = v3[1].PrimaryPart

								if primaryPart then
									fireEffect(primaryPart, v4)
								end
							end
						end

						task.wait(v.FIRE_TIME / #list)
					end
				end)
			end
		elseif v2 <= v.CHANCE and #lookup[2] < v.MAX or #lookup[2] == 0 then
			local clone = cyborgDrone.DroneModel:Clone()
			clone.Parent = _WorldOrigin
			clone:SetPrimaryPartCFrame(CFrame.new(p.Position))
			table.insert(lookup[2], {
				clone,
				tick(),
				CFrame.Angles(0, 0, 0),
				false
			})
			local v3 = lookup[2][#lookup[2]]

			if list and #list > 0 then
				task.spawn(function()
					for k, v4 in pairs(list) do
						if v4 and v4:IsDescendantOf(workspace) then
							if v3 == nil or k ~= 1 then
								local randomDrone = getRandomDrone() -- equivalent call inferred; original call site unknown

								if randomDrone and randomDrone[1] and randomDrone[1].PrimaryPart then
									fireEffect(randomDrone[1].PrimaryPart, v4)
									randomDrone[2] = tick()
									local cframe = CFrame.new(randomDrone[1].PrimaryPart.Position, v4.Position)
									randomDrone[3] = cframe - cframe.Position
								end
							else
								local primaryPart = v3[1].PrimaryPart

								if primaryPart then
									fireEffect(primaryPart, v4)
								end
							end
						end

						task.wait(v.FIRE_TIME / #list)
					end
				end)
			end
		elseif list and #list > 0 then
			local v3 = nil
			task.spawn(function()
				for k, v4 in pairs(list) do
					if v4 and v4:IsDescendantOf(workspace) then
						if v3 == nil or k ~= 1 then
							local randomDrone = getRandomDrone() -- equivalent call inferred; original call site unknown

							if randomDrone and randomDrone[1] and randomDrone[1].PrimaryPart then
								fireEffect(randomDrone[1].PrimaryPart, v4)
								randomDrone[2] = tick()
								local cframe = CFrame.new(randomDrone[1].PrimaryPart.Position, v4.Position)
								randomDrone[3] = cframe - cframe.Position
							end
						else
							local primaryPart = v3[1].PrimaryPart

							if primaryPart then
								fireEffect(primaryPart, v4)
							end
						end
					end

					task.wait(v.FIRE_TIME / #list)
				end
			end)
		end

		if v.loopActive == false then
			task.spawn(function()
				startDroneLoop()
			end)
		end
	elseif lookup ~= nil and lookup[2] and #lookup[2] > 0 then
		for _, v2 in pairs(lookup[2]) do
			if not (v2[1] ~= nil or v2[1].Parent ~= nil) then
				continue
			end

			explodeAt(v2[1].PrimaryPart.Position)
			v2[1]:Destroy()
		end
	end
end

return function(data)
	if data.FireShot then
		fireProjectile(data.FireShot.startPos, data.FireShot.goalPart, true) -- equivalent call inferred; original call site unknown
	else
		local rootOrigin = data.RootOrigin
		local rootTargets = data.RootTargets

		if rootOrigin then
			v:DoLogic(rootOrigin, rootTargets)
		end
	end
end