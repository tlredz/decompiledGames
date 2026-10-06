local v = {
	"rbxassetid://129742260562172",
	"rbxassetid://90844968675041",
	"rbxassetid://71703696897026",
	"rbxassetid://120798684912051",
	"rbxassetid://74225159808620",
	"rbxassetid://136350044934159",
	"rbxassetid://80733345001540",
	"rbxassetid://114688796668812",
	"rbxassetid://105559805228527",
	"rbxassetid://132671075312912",
	"rbxassetid://108008815505103",
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
			script.Parent.Decal.Texture = v[v2]
			preload(v[v2])
		end)
	end)
end