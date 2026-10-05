local Players = game:GetService("Players")
return {
	ShouldConstruct = function(p)
		if Players:GetPlayerFromCharacter(p.Instance.Parent) then
			return true
		end

		return false
	end
}