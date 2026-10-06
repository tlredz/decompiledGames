local v = {
	"rbxassetid://10246316488",
	"rbxassetid://10246315996",
	"rbxassetid://10246315545",
	"rbxassetid://10246315116",
	"rbxassetid://10246314550",
	"rbxassetid://10246314003",
	"rbxassetid://10246313387",
	"rbxassetid://10246312901",
	"rbxassetid://10246312219",
	"rbxassetid://10246311709",
	"rbxassetid://10246311169",
	"rbxassetid://10246310325",
	"rbxassetid://10246309742",
	"rbxassetid://10246309102",
	"rbxassetid://10246308590",
	"rbxassetid://10246308188",
	"rbxassetid://10246307652",
	""
}
local v2 = {
	"rbxassetid://10246449372",
	"rbxassetid://10246448726",
	"rbxassetid://10246448323",
	"rbxassetid://10246447896",
	"rbxassetid://10246447441",
	"rbxassetid://10246446927",
	"rbxassetid://10246446539",
	"rbxassetid://10246445970",
	"rbxassetid://10246445662",
	"rbxassetid://10246445188",
	"rbxassetid://10246444750",
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
			local v3 = math.floor(p * #v)

			if script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[v3]
			end

			preload(v[v3])
		end)

		if script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)

			if script.Parent:FindFirstChild("Decal2") then
				script.Parent.Decal2.Texture = v2[v3]
			end

			preload(v2[v3])
		end)

		if script.Parent:FindFirstChild("Decal2") then
			script.Parent.Decal2.Texture = ""
		end
	end)
end