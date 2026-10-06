local v = {
	"rbxassetid://103125306199420",
	"rbxassetid://97243983525241",
	"rbxassetid://83783377679922",
	"rbxassetid://122033226273964",
	"rbxassetid://104334734954386",
	"rbxassetid://91343106113205",
	"rbxassetid://125776474240537",
	"rbxassetid://135360356558013",
	"rbxassetid://90242577387766",
	"rbxassetid://104405930367512",
	"rbxassetid://123425612575903",
	"rbxassetid://116976322199263",
	"rbxassetid://106292426953091",
	"rbxassetid://94634907967544",
	"rbxassetid://115395314439191",
	"rbxassetid://122550833819773",
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