local v = {
	"rbxassetid://140295060107302",
	"rbxassetid://74614613277704",
	"rbxassetid://99216742965128",
	"rbxassetid://90883011573015",
	"rbxassetid://139427818447571",
	"rbxassetid://97990783211498",
	"rbxassetid://114514962799869",
	"rbxassetid://122799322032678",
	"rbxassetid://123909742280810",
	"rbxassetid://83915926383656"
}
local _ = {
	"rbxassetid://83634539306572",
	"rbxassetid://106573665641774",
	"rbxassetid://121653611684532",
	"rbxassetid://119098567770244",
	"rbxassetid://134661723761108",
	"rbxassetid://111064560782454",
	"rbxassetid://118499619445550",
	"rbxassetid://108373002777932",
	"rbxassetid://110879678318396",
	"rbxassetid://113847034648091"
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