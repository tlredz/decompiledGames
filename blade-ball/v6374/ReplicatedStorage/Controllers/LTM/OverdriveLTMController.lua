local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
require3(game.ReplicatedStorage.Shared.Policy)
require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Shared.CutsceneUtil)
return {
	Start = function(_)
		v:Connect("PlayMechEmbarkAnimation", function(animator, animator2, state, cframe: CFrame)
			assert(animator and animator:IsA("Animator"))
			assert(animator2 and animator2:IsA("Animator"))
			local preloadAnimations = v2.preloadAnimations({
				[animator] = script.PlayerEmbark,
				[animator2] = script.MechEmbark
			})

			if state and state.Part0 then
				local sound = Instance.new("Sound")
				sound.Looped = false
				sound.RollOffMaxDistance = 2500
				sound.RollOffMode = Enum.RollOffMode.InverseTapered
				sound.SoundId = "rbxassetid://84314502335193"
				sound.Parent = state.Part0
				v2.preloadSound(sound):Play()
			end

			for _, preloadAnimation in preloadAnimations do
				preloadAnimation:Play(0, 100)
			end

			task.wait()

			if state then
				state.C0 = cframe or state.C0
			end
		end)
	end
}