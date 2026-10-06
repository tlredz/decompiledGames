local v = {
	"rbxassetid://8279864587",
	"rbxassetid://8279868671",
	"rbxassetid://8279870152",
	"rbxassetid://8279871616",
	"rbxassetid://8279875789",
	"rbxassetid://8279888716",
	"rbxassetid://8279889941",
	"rbxassetid://8279891385",
	"rbxassetid://8279894730",
	"rbxassetid://8279898424",
	"rbxassetid://8279899738"
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