local textLabel = game.Players.LocalPlayer.PlayerGui:WaitForChild("Subtitles"):WaitForChild("TextLabel")
return {
	show = function(text: string, duration: number, p: string?)
		for _, uIGradient in textLabel:GetChildren() do
			if uIGradient:IsA("UIGradient") then
				uIGradient.Enabled = uIGradient.Name == p
			end
		end

		textLabel.Text = text
		textLabel.Visible = true
		local v = time() + duration
		textLabel:SetAttribute("disappear", v)
		task.delay(duration, function()
			if textLabel:GetAttribute("disappear") == v then
				textLabel.Visible = false
			end
		end)
	end
}