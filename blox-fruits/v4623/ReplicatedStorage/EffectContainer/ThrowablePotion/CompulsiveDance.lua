workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = workspace.Map
local _ = Util.Debris
require(game.ReplicatedStorage.FX)
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("TweenService")
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = Players.LocalPlayer
return function(data)
	local pos = data.pos
	local duration = data.duration
	local v = tick() + duration
	local character = localPlayer and localPlayer.Character
	local humanoid = character and (character:GetPivot().Position - pos).Magnitude < 25 and character:FindFirstChild("Humanoid")

	if humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = data.animationId
		local track = humanoid:LoadAnimation(animation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action4
		track:Play()
		local v2 = { "HalloweenPotions_MonsterSong" }
		local v3 = Sound:Play(v2[math.random(1, #v2)], character)

		while tick() < v do
			task.wait()

			if (character:GetAttribute("LastDamageTakenAt") or 0) + 10 > workspace:GetServerTimeNow() then
				break
			end
		end

		Sound:FadeOut(v3, 2)
		track:Stop()
	end
end