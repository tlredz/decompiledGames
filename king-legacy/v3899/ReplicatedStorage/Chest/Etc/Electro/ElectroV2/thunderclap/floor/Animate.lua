local v = {
	"rbxassetid://11115056370",
	"rbxassetid://11115056011",
	"rbxassetid://11115055647",
	"rbxassetid://11115055261",
	"rbxassetid://11115054838",
	"rbxassetid://11115054487",
	"rbxassetid://11115054119",
	"rbxassetid://11115053727",
	"rbxassetid://11115053346",
	"rbxassetid://11115052982",
	"rbxassetid://11115052600",
	"rbxassetid://11115052304",
	"rbxassetid://11115052024",
	"rbxassetid://11115051686",
	"rbxassetid://11115051278",
	"rbxassetid://11115050751",
	"rbxassetid://11115050342",
	"rbxassetid://11115049913",
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

		if script.Parent:FindFirstChild("Neon") then
			script.Parent.Neon.Texture = ""
		end
	end)
end