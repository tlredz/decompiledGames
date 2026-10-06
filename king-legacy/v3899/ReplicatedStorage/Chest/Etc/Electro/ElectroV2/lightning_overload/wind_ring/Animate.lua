local _ = {
	"rbxassetid://10783329117",
	"rbxassetid://10783328876",
	"rbxassetid://10783328572",
	"rbxassetid://10783328289",
	"rbxassetid://10783327967",
	"rbxassetid://10783327531",
	"rbxassetid://10783327074",
	"rbxassetid://10783326824",
	"rbxassetid://10783326436",
	"rbxassetid://10783325996",
	"rbxassetid://10783325670",
	""
}
local v = {
	"rbxassetid://10846462310",
	"rbxassetid://10846462022",
	"rbxassetid://10846461740",
	"rbxassetid://10846461484",
	"rbxassetid://10846461139",
	"rbxassetid://10846460903",
	"rbxassetid://10846460574",
	"rbxassetid://10846460168",
	"rbxassetid://10846459809",
	"rbxassetid://10846459397",
	"rbxassetid://10846459003",
	"rbxassetid://10846458740",
	"rbxassetid://10846458402",
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

			if script.Parent and script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[v2]
			end

			preload(v[v2])
		end)

		if script.Parent and script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
end