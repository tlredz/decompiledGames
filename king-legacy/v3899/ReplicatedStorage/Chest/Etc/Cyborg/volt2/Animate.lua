local v = {
	"rbxassetid://12016124185",
	"rbxassetid://12016123931",
	"rbxassetid://12016123615",
	"rbxassetid://12016123308",
	"rbxassetid://12016122932",
	"rbxassetid://12016122553",
	"rbxassetid://12016122163",
	"rbxassetid://12016121948",
	"rbxassetid://12016121599",
	"rbxassetid://12016121186"
}

function preload(childName)
	if not workspace.Effects.preload:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace.Effects.preload
		decal.Texture = childName
	end
end

local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v2 = math.floor(p * #v)

			if script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[v2]
			end

			preload(v[v2])
		end)

		if script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
end