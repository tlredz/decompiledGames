local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = workspace.Map
local _ = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("TweenService")
local _ = Players.LocalPlayer
return function(data)
	local clone = FX:Get("ThrowablePotion"):WaitForChild("Splash"):Clone()
	task.delay(5, clone.Destroy, clone)
	clone.Anchored = true
	clone.Position = data.pos
	clone.Parent = _WorldOrigin
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, data.color1),
		ColorSequenceKeypoint.new(1, data.color1)
	})
	local colorSequence2 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, data.color2),
		ColorSequenceKeypoint.new(1, data.color2)
	})

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local colorType = emitter:GetAttribute("ColorType")
		emitter.Color = colorType == 1 and colorSequence or colorType == 2 and colorSequence2 or emitter.Color
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	task.wait(1)
	clone:Destroy()
end