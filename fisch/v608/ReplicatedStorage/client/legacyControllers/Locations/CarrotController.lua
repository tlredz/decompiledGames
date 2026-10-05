local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local components = ReplicatedStorage:WaitForChild("client").components
local Podium = require(components.Podium)
local packages = ReplicatedStorage:WaitForChild("packages")
local Observers = require(packages.Observers)
local v = false
return {
	Start = function(_)
		Podium.OnPodiumActivated:Connect(function(p: string)
			if not (v ~= true and p == "CarrotPodium" and ReplicatedStorage:WaitForChild("world").cycle.Value == "Day") then
				return
			end

			v = true
			Observers.observeTag("CarrotMusic", function(instance)
				local sound = instance:WaitForChild("Sound", 3)

				if sound then
					sound.Looped = true
					sound:Play()
				end
			end)
			Observers.observeTag("CarrotGuy", function(instance)
				local humanoid = instance:FindFirstChild("Humanoid")

				if humanoid then
					local track = (humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)):LoadAnimation(script.CarrotAnimation)
					track.Looped = true
					track:Play()
				end
			end)
		end)
	end
}