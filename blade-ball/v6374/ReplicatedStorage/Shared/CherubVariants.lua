local v = {
	GetAccessoryVariant = function(instance)
		if instance and instance:GetAttribute("CurrentlyEquippedSword") == "Cherub" and instance:GetAttribute("SelectedAccessoryVariant") == "EvilCherub" then
			return "EvilCherub"
		end

		return "GoodCherub"
	end
}

function v.GetEmoteVFXVariant(p)
	if v.GetAccessoryVariant(p) == "EvilCherub" then
		return "RedVersion"
	end

	return "PinkVersion"
end

function v.GetExplosionModel(p)
	if v.GetAccessoryVariant(p) == "EvilCherub" then
		return "ExplosionKitty2"
	end

	return "ExplosionKitty1"
end

return table.freeze(v)