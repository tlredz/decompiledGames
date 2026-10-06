local v = {
	"rbxassetid://99222697420802",
	"rbxassetid://104803902513009",
	"rbxassetid://119505279241630",
	"rbxassetid://71117464054334",
	"rbxassetid://112007003892856",
	"rbxassetid://104404525205230",
	"rbxassetid://116768985273731",
	"rbxassetid://136047335712435",
	"rbxassetid://129437797638220",
	"rbxassetid://103841386462591",
	"rbxassetid://132938540300776",
	"rbxassetid://82840807515600",
	"rbxassetid://137163216347279",
	"rbxassetid://104602509979376",
	"rbxassetid://132992084809036",
	"rbxassetid://73319659278432"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local texture = v[math.floor(p * #v)]

			if parent:FindFirstChild("Decal") then
				parent.Decal.Texture = texture
			end
		end)

		if parent:FindFirstChild("Decal") then
			parent.Decal.Texture = ""
		end
	end)
end