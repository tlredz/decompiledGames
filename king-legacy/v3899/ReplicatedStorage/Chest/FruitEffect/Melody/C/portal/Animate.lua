local v = {
	"rbxassetid://106431305414800",
	"rbxassetid://139841740316856",
	"rbxassetid://89134595364082",
	"rbxassetid://79609912579746",
	"rbxassetid://112288794395266",
	"rbxassetid://124589144279686",
	"rbxassetid://99581536623400",
	"rbxassetid://100519089005380",
	"rbxassetid://126939448332060",
	"rbxassetid://119425891659970",
	"rbxassetid://119749658101249",
	"rbxassetid://89709580920150",
	"rbxassetid://86231405985040",
	"rbxassetid://112357459431915",
	"rbxassetid://71228070768969",
	"rbxassetid://84175136445408",
	"rbxassetid://114179471124917",
	"rbxassetid://86934972459892",
	"rbxassetid://110759263409849",
	"rbxassetid://130172622795932",
	"rbxassetid://138064992502041",
	"rbxassetid://139999279417509",
	"rbxassetid://91480270871175",
	"rbxassetid://127642318482528",
	"rbxassetid://123745536268651",
	"rbxassetid://92638089512582",
	"rbxassetid://103933999691299",
	"rbxassetid://119489620746128",
	"rbxassetid://111561150758797",
	"rbxassetid://102892837504459"
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