local v = {
	"rbxassetid://7069859730",
	"rbxassetid://7069859631",
	"rbxassetid://7069859518",
	"rbxassetid://7069859383",
	"rbxassetid://7069859215",
	"rbxassetid://7069859078",
	"rbxassetid://7069858919",
	"rbxassetid://7069858814",
	"rbxassetid://7069858650",
	"rbxassetid://7069858550",
	"rbxassetid://7069858420",
	"rbxassetid://7069858227",
	"rbxassetid://7069858094",
	"rbxassetid://7069857967",
	"rbxassetid://7069857853",
	"rbxassetid://7069857742",
	"rbxassetid://7069857614",
	"rbxassetid://7069857233",
	"rbxassetid://7069856962",
	"rbxassetid://7069856747",
	"rbxassetid://7069856443"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return {
	start = function()
		spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p)
				local v2 = math.floor(p * #v)
				script.Parent.Texture = v[v2]
			end)
		end)
	end
}