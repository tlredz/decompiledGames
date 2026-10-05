local TweenService = game:GetService("TweenService")
local v = {
	Rickroll = 5,
	Baller = 2,
	["The Rock"] = 2,
	Scary = 3.5,
	Amongus = 5,
	Beast = 2.5
}
return {
	SetJumpscare = function(player, state)
		player:SetAttribute("Jumpscaring", true)
		state.Enabled = true
		TweenService:Create(state.ImageLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			ImageTransparency = 0
		}):Play()
		task.wait(v[state.Name])

		if state.Enabled == true then
			local character = state.Name == "Rickroll" and player.Character

			if character then
				character.Humanoid.Health = 0
			end

			local tween = TweenService:Create(state.ImageLabel, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				ImageTransparency = 1
			})
			tween:Play()
			tween.Completed:Wait()
			state.Enabled = false
			player:SetAttribute("Jumpscaring", nil)
		end
	end
}