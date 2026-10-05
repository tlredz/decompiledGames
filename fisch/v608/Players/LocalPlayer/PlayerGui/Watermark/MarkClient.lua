if game.GameId == 6756890519 then
	local localPlayer = game.Players.LocalPlayer
	local rankInGroup = localPlayer:GetRankInGroup(7381705)

	if rankInGroup == 60 or rankInGroup == 62 then
		script.Parent.Enabled = true
		script.Parent.TextLabel.Text = localPlayer.Name

		for _ = 1, 249 do
			script.Parent.TextLabel.Text ..= " " .. localPlayer.Name
		end
	end
end