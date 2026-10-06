local v = {
	"rbxassetid://102967474448819",
	"rbxassetid://76102432877166",
	"rbxassetid://105620058098728",
	"rbxassetid://136222265277747",
	"rbxassetid://95138297028906",
	"rbxassetid://106492935713187",
	"rbxassetid://125803688635332",
	"rbxassetid://121610618588389",
	"rbxassetid://94799015851947",
	"rbxassetid://136596147116159",
	"rbxassetid://113835706205107",
	"rbxassetid://87295676525773",
	"rbxassetid://95984108579956",
	"rbxassetid://137329604177959",
	"rbxassetid://128909432475074",
	"rbxassetid://118150882847841",
	"rbxassetid://96701313941915",
	"rbxassetid://72499518684588",
	"rbxassetid://82764952139547",
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
			WaitTime = 0.0175
		}, function(p)
			local v2 = math.floor(p * #v)
			script.Parent.Neon.Texture = v[v2]
			preload(v[v2])
		end)
	end)
end