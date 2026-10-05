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

return function(data)
	local player = data.player
	local hrp = data.hrp
	local _ = data.char
	local _ = data.stage
	local transformedObject = data.transformedObject

	if not (transformedObject and transformedObject.Value) then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, workspace._WorldOrigin, player, "LeopardFruitVFXColor")
	local clone = walking.Floor:Clone()
	Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
	local v = false
	local flag = false
	task.spawn(function()
		local now = tick()

		while transformedObject and transformedObject.Value and transformedObject.Value:IsDescendantOf(workspace) do
			if flag then
				Util.Debris:AddItem(folder, 1)
				return
			end

			task.wait()

			if transformedObject and transformedObject.Value and transformedObject.Value:IsDescendantOf(workspace) and transformedObject.Value.Parent:GetAttribute("Awakened") and not v then
				v = true

				if clone then
					clone:Destroy()
				end

				clone = walking.FloorAW:Clone()
				Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
			end

			local ray = Util.Ray
			local v2 = hrp.Position + createVector(0, 2, 0)
			local v3 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
			local v4, v5, _ = ray(v2, createVector(-0, -15, -0), v3, false)

			if v4 == nil then
				continue
			end

			local cframe = CFrame.new(v5)

			if not (now < tick()) then
				continue
			end

			clone.CFrame = cframe
			now = tick() + 0.105
			emitAll(clone)
		end

		flag = true
		Util.Debris:AddItem(folder, 1)
		Util.Debris:AddItem(folder, 1)
	end)
end