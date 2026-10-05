local BloodyZee = require(game.ReplicatedStorage.Modules.BloodyZee)
return {
	Btn = 1,
	SortOrder = 7,
	Desc = "paint the world red",
	Callback = function(permBlood)
		BloodyZee.PermBlood = permBlood

		if permBlood == true then
			return
		end

		for _, child in workspace.Effects.Blood:GetChildren() do
			if child.Name == "Pool" then
				child:Destroy()
			end
		end
	end
}