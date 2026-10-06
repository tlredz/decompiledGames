local v = {
	"rbxassetid://7083874122",
	"rbxassetid://7083874365",
	"rbxassetid://7083874122",
	"rbxassetid://7083873917",
	"rbxassetid://7083873816",
	"rbxassetid://7083873544",
	"rbxassetid://7083873299",
	"rbxassetid://7083872858",
	"rbxassetid://7083872439",
	"rbxassetid://7083871607"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v2 = math.floor(p * #v)

			if script.Parent and script.Parent:IsA("Decal") then
				script.Parent.Texture = v[v2]
			end
		end)
	end)
end