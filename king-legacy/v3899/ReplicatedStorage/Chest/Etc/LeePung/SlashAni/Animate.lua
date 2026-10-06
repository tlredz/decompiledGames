local v = {
	"rbxassetid://8007689052",
	"rbxassetid://8007688746",
	"rbxassetid://8007688496",
	"rbxassetid://8007687983",
	"rbxassetid://8007687575",
	"rbxassetid://8007687166",
	"rbxassetid://8007686358",
	"rbxassetid://8007686080",
	"rbxassetid://8007685863",
	"rbxassetid://8007685625",
	"rbxassetid://8007685356",
	"rbxassetid://8007685126",
	"rbxassetid://8007684860",
	"rbxassetid://8007684587",
	"rbxassetid://8007684297",
	"rbxassetid://8007684004",
	"rbxassetid://8007683752",
	"rbxassetid://8007683362",
	"rbxassetid://8007683079"
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

		if parent:FindFirstChild("Top") then
			parent.Top.Texture = ""
		end
	end)
end