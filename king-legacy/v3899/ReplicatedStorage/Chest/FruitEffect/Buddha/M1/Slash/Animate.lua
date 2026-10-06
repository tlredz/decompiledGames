local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local v = {
	"rbxassetid://17382067615",
	"rbxassetid://17382065978",
	"rbxassetid://17382065346",
	"rbxassetid://17382064743",
	"rbxassetid://17382064141",
	"rbxassetid://17382063586",
	"rbxassetid://17382062645",
	"rbxassetid://17382062091",
	"rbxassetid://17382061582",
	"rbxassetid://17382061582",
	"rbxassetid://17382060253",
	"rbxassetid://17382059080",
	"rbxassetid://17382058379",
	""
}
return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local texture = v[math.floor(p * #v)]
			parent.Decal.Texture = texture
		end)
	end)
end