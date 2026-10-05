return {
	ShouldConstruct = function(p)
		return p.Instance:GetAttribute("OwnerId") == game.Players.LocalPlayer.UserId
	end
}