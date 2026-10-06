local v = {
	"rbxassetid://12920753978",
	"rbxassetid://12920753637",
	"rbxassetid://12920753334",
	"rbxassetid://12920752798",
	"rbxassetid://12920752573",
	"rbxassetid://12920752291",
	"rbxassetid://12920752031",
	"rbxassetid://12920751559",
	"rbxassetid://12920751345",
	"rbxassetid://12920750860",
	"rbxassetid://12920750516",
	"rbxassetid://12920750322",
	"rbxassetid://12920750050",
	"rbxassetid://12920749768",
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

			if script.Parent:FindFirstChild("Neon") then
				script.Parent.Neon.Texture = v[v2]
			end

			preload(v[v2])
		end)
	end)
end