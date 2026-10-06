local v = {
	"rbxassetid://98788884592261",
	"rbxassetid://97104540723741",
	"rbxassetid://114618316877152",
	"rbxassetid://78920394076229",
	"rbxassetid://108421829578696",
	"rbxassetid://106965292426503",
	"rbxassetid://118752785534558",
	"rbxassetid://80431501194311",
	"rbxassetid://74235228396449",
	"rbxassetid://86416074734683",
	"rbxassetid://106482921544013",
	"rbxassetid://99995989328048",
	"rbxassetid://121292861834139",
	"rbxassetid://81351498895925",
	"rbxassetid://74366719422272",
	"rbxassetid://113282780284035",
	"rbxassetid://125819124942491",
	"rbxassetid://70746548996775",
	"rbxassetid://131517590965431",
	"rbxassetid://92950337097859",
	"rbxassetid://96164144149365",
	"rbxassetid://84475358012765"
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