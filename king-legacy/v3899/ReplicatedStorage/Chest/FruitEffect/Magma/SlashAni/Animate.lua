local v = {
	"rbxassetid://8007689052",
	"rbxassetid://8007688496",
	"rbxassetid://8007687575",
	"rbxassetid://8007686358",
	"rbxassetid://8007685863",
	"rbxassetid://8007685356",
	"rbxassetid://8007684860",
	"rbxassetid://8007684297",
	"rbxassetid://8007683752",
	"rbxassetid://8007683079"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v2 = math.floor(p * #v)

			if script.Parent:FindFirstChild("Top") then
				script.Parent.Top.Texture = v[v2]
			end
		end)
	end)
end