local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.packages.vide)
local fx = require(ReplicatedStorage.shared.modules.fx)
return function(p)
	local function play(soundId)
		if typeof(soundId) == "Instance" then
			fx:PlaySound(soundId, script.Parent, true)
		elseif typeof(soundId) == "string" then
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			sound.Parent = script.Parent
			sound:Play()
			task.delay(10, function()
				sound:Destroy()
			end)
		end
	end

	return vide.action(function(p2)
		p2.Activated:Connect(function()
			play(p.click)
		end)
		p2.MouseEnter:Connect(function()
			play(p.hover)
		end)
	end)
end