local v = {
	"rbxassetid://11642175973",
	"rbxassetid://11642176132",
	"rbxassetid://11642176326",
	"rbxassetid://11642176658",
	"rbxassetid://11642176872",
	"rbxassetid://11642177043",
	"rbxassetid://11642177266",
	"rbxassetid://11642177473",
	"rbxassetid://11642177687",
	"rbxassetid://11642177836",
	"rbxassetid://11642177974",
	"rbxassetid://11642178224",
	"rbxassetid://11642178481",
	"rbxassetid://11642178680",
	"rbxassetid://11642178882",
	"rbxassetid://11642179114",
	"rbxassetid://11642179364",
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