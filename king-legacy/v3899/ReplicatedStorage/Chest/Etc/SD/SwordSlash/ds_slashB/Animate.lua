local v = {
	"rbxassetid://104264010539250",
	"rbxassetid://138564680244995",
	"rbxassetid://134280926988753",
	"rbxassetid://115064340270545",
	"rbxassetid://139354891547578",
	"rbxassetid://95561105832956",
	"rbxassetid://112794816581928",
	"rbxassetid://96633519963752",
	"rbxassetid://91531571583088",
	"rbxassetid://137596960080271",
	"rbxassetid://88606023709675",
	"rbxassetid://95131823543152",
	"rbxassetid://71638574649403",
	"rbxassetid://75863623847827",
	"rbxassetid://135169636712432",
	"rbxassetid://84863074715903",
	"rbxassetid://74589894063308",
	"rbxassetid://77314054166926",
	"rbxassetid://88141507671771",
	"rbxassetid://113484978884724",
	""
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	local parent = script.Parent
	PeodizService.ForLoop({
		Step = #v
	}, function(p)
		local v2 = math.floor(p * #v)

		if parent:FindFirstChild("Decal") then
			parent.Decal.Texture = v[v2]
		end
	end)
end