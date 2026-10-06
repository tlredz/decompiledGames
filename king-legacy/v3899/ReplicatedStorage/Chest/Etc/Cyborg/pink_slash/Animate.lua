local v = {
	"rbxassetid://11982535265",
	"rbxassetid://11982535085",
	"rbxassetid://11982534916",
	"rbxassetid://11982534706",
	"rbxassetid://11982534458",
	"rbxassetid://11982534225",
	"rbxassetid://11982533920",
	"rbxassetid://11982533689",
	"rbxassetid://11982533464",
	"rbxassetid://11982533240",
	"rbxassetid://11982533029",
	"rbxassetid://11982532813",
	"rbxassetid://11982532598",
	"rbxassetid://11982532400",
	"rbxassetid://11982532149",
	"rbxassetid://11982531860"
}
local _ = {
	"rbxassetid://11114482116",
	"rbxassetid://11121409618",
	"rbxassetid://11121409169",
	"rbxassetid://11121408680",
	"rbxassetid://11121408331",
	"rbxassetid://11121407998",
	"rbxassetid://11121407599",
	"rbxassetid://11121407094",
	"rbxassetid://11121416668",
	"rbxassetid://11121416286",
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