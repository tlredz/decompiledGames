return {
	AddCurrency = function(_, instance, p: number)
		local cash = instance:WaitForChild("NoSaveData"):WaitForChild("Cash")
		local v = p + p * (instance:WaitForChild("NoSaveData"):WaitForChild("FriendsPlaying").Value * 10 / 100)
		cash.Value += v
		return v
	end
}