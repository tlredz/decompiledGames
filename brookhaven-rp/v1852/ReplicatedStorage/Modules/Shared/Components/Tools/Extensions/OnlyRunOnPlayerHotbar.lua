local Players = game:GetService("Players")
return {
	ShouldConstruct = function(p)
		local instance = p.Instance

		if not instance:IsA("Tool") then
			return false
		end

		local parent = instance.Parent

		if parent:IsA("Backpack") or Players:GetPlayerFromCharacter(parent) then
			return true
		end

		return false
	end
}