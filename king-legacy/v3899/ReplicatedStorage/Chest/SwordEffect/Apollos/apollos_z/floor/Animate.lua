local v = {
	"rbxassetid://10964266562",
	"rbxassetid://10964266430",
	"rbxassetid://10964266215",
	"rbxassetid://10964266068",
	"rbxassetid://10964265943",
	"rbxassetid://10964265789",
	"rbxassetid://10964265595",
	"rbxassetid://10964265451",
	"rbxassetid://10964265296",
	"rbxassetid://10964265083",
	"rbxassetid://10964264839",
	"rbxassetid://10964264576",
	"rbxassetid://10964264576",
	"rbxassetid://10964264443",
	"rbxassetid://10964264290",
	"rbxassetid://10964264159",
	"rbxassetid://10964264026",
	"rbxassetid://10964263850",
	"rbxassetid://10964263742",
	"rbxassetid://10964263609"
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