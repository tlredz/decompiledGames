local v = {
	"rbxassetid://119166909333921",
	"rbxassetid://101690333386705",
	"rbxassetid://127333737291019",
	"rbxassetid://102920415459153",
	"rbxassetid://75372844963703",
	"rbxassetid://96269062394051",
	"rbxassetid://138405606672230",
	"rbxassetid://90609739884214",
	"rbxassetid://134653190467431",
	"rbxassetid://83264533614505",
	"rbxassetid://76919468950225",
	"rbxassetid://108737638849122",
	"rbxassetid://129215545304539"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v2 = math.floor(p * #v)

			if parent:FindFirstChild("Top") then
				parent.Top.Texture = v[v2]
			end
		end)
		parent.Top.Texture = ""
	end)
end