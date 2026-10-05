workspace:WaitForChild("_WorldOrigin")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
local _ = Util.BoatTween
game:GetService("TweenService")
local container = script.Container
return function(data)
	local color = data.Color or ColorSequence.new(Color3.fromRGB(255, 144, 144), Color3.fromRGB(255, 46, 46))
	local rootPart = data.RootPart
	local shaded = data.Shaded or false
	local drinkDelay = data.DrinkDelay or 0
	task.delay(drinkDelay, function()
		if rootPart ~= nil and rootPart.Parent ~= nil then
			if (workspace.CurrentCamera.CFrame.Position - rootPart.Position).Magnitude > 1000 then
				return
			end

			local clone = (shaded and container.ParticlesDark or container.Particles):Clone()
			debris:AddItem(clone, 4)
			clone.Parent = rootPart

			for _, emitter in ipairs(clone:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Color = color
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end)
end