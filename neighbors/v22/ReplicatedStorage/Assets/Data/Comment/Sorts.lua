require("./Types")
return {
	Time = {
		Index = 1,
		Icon = "rbxassetid://11963371162",
		SortFunction = function(p, p2)
			return p.Date.Value > p2.Date.Value
		end
	},
	Likes = {
		Index = 2,
		Icon = "rbxassetid://11419717444",
		SortFunction = function(p, p2)
			local count = p.Likes:GetAttribute("Count")
			local count2 = p2.Likes:GetAttribute("Count")

			if count == count2 then
				return p.Date.Value > p2.Date.Value
			end

			return count2 < count
		end
	},
	Hidden = {
		Index = 3,
		Icon = "rbxassetid://18170156950",
		FilterFunction = function(_: number, p)
			return p.Hidden.Value
		end,
		PermissionFunction = function(instance)
			return instance:GetAttribute("CommentDeletePermission") and true or false
		end
	}
}