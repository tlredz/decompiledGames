return function(instance, p)
	if instance:FindFirstChild("EquippedWeapon") then
		for _, descendant in pairs(instance.EquippedWeapon:GetDescendants()) do
			if descendant.Name == p then
				return descendant
			end
		end
	end

	return nil
end