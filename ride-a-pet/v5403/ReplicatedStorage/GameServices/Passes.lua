return {
	Has = function(instance, value: string)
		if not instance or typeof(value) ~= "string" then
			return false
		end

		local savedData = instance:FindFirstChild("SavedData")
		local ownedPasses = savedData and savedData:FindFirstChild("OwnedPasses")

		if ownedPasses then
			return string.find(ownedPasses.Value, value .. ",", 1, true) ~= nil
		end

		return false
	end
}