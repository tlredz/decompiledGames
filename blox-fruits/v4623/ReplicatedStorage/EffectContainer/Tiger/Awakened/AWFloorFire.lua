local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function debrisPart(data, p, p2)
	local v = math.random(20, 44) / 10
	local v2 = math.random(27, 48) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v2, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	Util.SetParentOverrideWithColor(part, _WorldOrigin, player, "LeopardFruitVFXColor")
	part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
		math.random(100, 130),
		math.random(70, 100),
		math.random(100, 120)
	)
	part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	return part
end

local FX = require(ReplicatedStorage:WaitForChild("FX"))
local walking = FX:WaitForChild("TigerEffects").Walking

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local function walk(player2, _, hrp, _)
	local ray = Util.Ray
	local v = hrp.Position + createVector(0, 2, 0)
	local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
	local v3, v4, _ = ray(v, createVector(-0, -15, -0), v2, false)

	if v3 ~= nil then
		local cframe = CFrame.new(v4)
		local clone = walking.FloorAW:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 2.5)
		Util.Sound:Play("TigerBurnWalk", hrp.Position, nil, 1 + math.random(-50, -42) / 100, 0.1)
	end
end

return function(data)
	local player2 = data.player
	local hrp = data.hrp
	walk(player2, data.char, hrp, data.stage)
end