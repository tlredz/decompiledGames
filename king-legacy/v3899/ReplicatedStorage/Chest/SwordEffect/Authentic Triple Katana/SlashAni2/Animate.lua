local v = {
	"rbxassetid://8353527287",
	"rbxassetid://8353526964",
	"rbxassetid://8353526680",
	"rbxassetid://8353526289",
	"rbxassetid://8353526028",
	"rbxassetid://8353525738",
	"rbxassetid://8353525413",
	"rbxassetid://8353525217",
	"rbxassetid://8353525002",
	"rbxassetid://8353524622",
	"rbxassetid://8353524389",
	"rbxassetid://8353524094",
	"rbxassetid://8353523803",
	"rbxassetid://8353523506",
	"rbxassetid://8353523214",
	"rbxassetid://8353522949",
	"rbxassetid://8353522702",
	"rbxassetid://8353522504",
	"rbxassetid://8353522308",
	"rbxassetid://8353522054",
	"rbxassetid://8353521828",
	"rbxassetid://8353521623",
	"rbxassetid://8353521373"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local parent = script.Parent
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local texture = v[math.floor(p * #v)]

			if parent:FindFirstChild("Top") then
				parent.Top.Texture = texture
			end
		end)

		if parent:FindFirstChild("Top") then
			parent.Top.Texture = ""
		end
	end)
end