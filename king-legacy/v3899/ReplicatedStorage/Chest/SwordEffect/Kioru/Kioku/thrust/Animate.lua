local v = {
	"rbxassetid://12927859736",
	"rbxassetid://12927859418",
	"rbxassetid://12927858819",
	"rbxassetid://12927858177",
	"rbxassetid://12927857430",
	"rbxassetid://12927857107",
	"rbxassetid://12927856319",
	"rbxassetid://12927855461",
	"rbxassetid://12927855124",
	"rbxassetid://12927854460",
	"rbxassetid://12927853751",
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
			Step = #v,
			WaitTime = 0.013
		}, function(p)
			local v2 = math.floor(p * #v)
			script.Parent.Neon.Texture = v[v2]
		end)
	end)
end