local Players = game:GetService("Players")
return {
	list = function()
		local players = Players:GetPlayers()
		local bots = script.Parent.Parent:FindFirstChild("Bots")
		local actors = bots and bots:FindFirstChild("Actors")

		if not actors then
			return players
		end

		for _, child in actors:GetChildren() do
			if child:GetAttribute("IsBot") ~= true then
				continue
			end

			local character = child:FindFirstChild("Character")
			local v = child
			table.insert(players, {
				UserId = child:GetAttribute("UserId"),
				DisplayName = child:GetAttribute("DisplayName"),
				Name = child.Name,
				IsBot = true,
				Character = character and character.Value,
				GetAttribute = function(self, attributeName)
					return v:GetAttribute(attributeName)
				end
			})
		end

		return players
	end
}