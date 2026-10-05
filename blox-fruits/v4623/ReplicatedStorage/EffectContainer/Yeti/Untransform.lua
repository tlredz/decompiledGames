workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
game:GetService("RunService")
local FX = require(ReplicatedStorage.FX)
local V = FX:WaitForChild("YetiEffects").V

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

local function walk(hrp, player)
	local clone = V.untr.Charge:Clone()
	Util.SetParentOverrideWithColor(clone, hrp, player, "YetiFruitVFXColor")
	Util.Sound:Play("YETI_UNTransformation_01", hrp)
	emitAll(clone)
	Util.Debris:AddItem(clone, 1.6)
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	walk(data.hrp, player)
end