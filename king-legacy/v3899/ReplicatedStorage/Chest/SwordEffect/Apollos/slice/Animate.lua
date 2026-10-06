local v = {
	"rbxassetid://10783351351",
	"rbxassetid://10783351060",
	"rbxassetid://10783350771",
	"rbxassetid://10783350518",
	"rbxassetid://10783350349",
	"rbxassetid://10783350163",
	"rbxassetid://10783349928",
	"rbxassetid://10783349704",
	"rbxassetid://10783349410",
	"rbxassetid://10783349071",
	"rbxassetid://10783348812",
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