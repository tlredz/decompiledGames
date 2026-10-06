local replicatedStorage = game.ReplicatedStorage
local v = {
	"rbxassetid://8694779920",
	"rbxassetid://8694791740",
	"rbxassetid://8694791347",
	"rbxassetid://8694791134",
	"rbxassetid://8694790905",
	"rbxassetid://8694790645",
	"rbxassetid://8694790423",
	"rbxassetid://8694790223",
	"rbxassetid://8694790052",
	"rbxassetid://8694789839",
	"rbxassetid://8694789625",
	"rbxassetid://8694789384",
	"rbxassetid://8694789249",
	"rbxassetid://8694789074",
	"rbxassetid://8694788888",
	"rbxassetid://8694788648",
	"rbxassetid://8694788435",
	"rbxassetid://8694788161",
	"rbxassetid://8694787877"
}
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
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