local v = {
	"rbxassetid://10246449372",
	"rbxassetid://10246448323",
	"rbxassetid://10246447441",
	"rbxassetid://10246446539",
	"rbxassetid://10246445188",
	"rbxassetid://10246444223",
	"rbxassetid://10246443668",
	"rbxassetid://10246443283",
	"rbxassetid://10246442890",
	"rbxassetid://10246442350",
	"rbxassetid://10246441863",
	""
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