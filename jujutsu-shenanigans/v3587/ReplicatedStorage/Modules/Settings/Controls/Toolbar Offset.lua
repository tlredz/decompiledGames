return {
	Btn = 3,
	SortOrder = 6,
	Val = "TBO",
	Desc = "Change the offset of the toolbar from the center",
	Max = 2,
	Callback = function(p)
		game.Players.LocalPlayer.PlayerGui.Main.Controls.Position = UDim2.new(p / 2, 0, 0, 0)
	end
}