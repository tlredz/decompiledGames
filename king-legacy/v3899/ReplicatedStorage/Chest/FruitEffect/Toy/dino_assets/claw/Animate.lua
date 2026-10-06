local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local v = {
	"rbxassetid://15835407627",
	"rbxassetid://15835407055",
	"rbxassetid://15835406797",
	"rbxassetid://15835406536",
	"rbxassetid://15835406031",
	"rbxassetid://15835405696",
	"rbxassetid://15835405153",
	"rbxassetid://15835404904",
	"rbxassetid://15835404570",
	"rbxassetid://15835404321",
	"rbxassetid://15835404046",
	"rbxassetid://15835403821",
	"rbxassetid://15835403644",
	"rbxassetid://15835403148",
	""
}
return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local texture = v[math.floor(p * #v)]

			if parent:FindFirstChild("Top") then
				parent.Top.Texture = texture
			end
		end)

		if parent:FindFirstChild("Top") then
			parent.Top.Texture = ""
		end
	end)
end