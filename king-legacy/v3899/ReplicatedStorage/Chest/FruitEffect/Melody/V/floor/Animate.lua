local v = {
	"rbxassetid://135836137903580",
	"rbxassetid://81208869851480",
	"rbxassetid://80038048952114",
	"rbxassetid://96046698428727",
	"rbxassetid://79386201755927",
	"rbxassetid://75924074653537",
	"rbxassetid://71957675211776",
	"rbxassetid://81625982162368",
	"rbxassetid://79042388405079",
	"rbxassetid://128599494433286",
	"rbxassetid://117112272992463",
	"rbxassetid://94478147866623",
	"rbxassetid://115471981548588",
	"rbxassetid://83728017576059",
	"rbxassetid://105325983701177",
	"rbxassetid://128109683175131",
	"rbxassetid://109273238737674",
	"rbxassetid://122239552242766",
	"rbxassetid://73203779229653",
	"rbxassetid://114522063737493",
	"rbxassetid://75882012079638",
	"rbxassetid://125938438227210",
	"rbxassetid://121562671110462",
	"rbxassetid://113601289747053"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)

function preload(childName)
	if not workspace.Effects.preload:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace.Effects.preload
		decal.Texture = childName
	end
end

return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v,
			WaitTime = 0.015
		}, function(p)
			local v2 = math.floor(p * #v)
			preload(v[v2])

			if parent:FindFirstChild("Decal") then
				parent.Decal.Texture = v[v2]
			end
		end)
		parent.Transparency = 0
	end)
end