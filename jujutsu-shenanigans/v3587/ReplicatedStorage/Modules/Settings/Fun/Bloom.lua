local clone = nil
return {
	Btn = 1,
	SortOrder = 8,
	Desc = "this will be what jjs will look like in 2014.....",
	Callback = function(p)
		if p == true then
			clone = game.ReplicatedStorage.Utils.Misc.FunBlm:Clone()
			clone.Parent = game.Lighting
		else
			if not clone then
				return
			end

			clone:Destroy()
			clone = nil
		end
	end
}