local v = {
	"rbxassetid://12882354647",
	"rbxassetid://12882354161",
	"rbxassetid://12882353233",
	"rbxassetid://12882352394",
	"rbxassetid://12882351653",
	"rbxassetid://12882351065",
	"rbxassetid://12882350235",
	"rbxassetid://12882349558",
	"rbxassetid://12882349067",
	"rbxassetid://12882348296",
	"rbxassetid://12882347568",
	""
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)

function preload(childName)
	if not workspace.Effects.preload:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace.Effects.preload
		decal.Texture = childName
	end
end

return function()
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v2 = math.floor(p * #v)
			script.Parent.Neon.Texture = v[v2]
		end)
	end)
end