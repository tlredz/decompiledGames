local v = {
	"rbxassetid://11114482116",
	"rbxassetid://11114481372",
	"rbxassetid://11114480721",
	"rbxassetid://11114480145",
	"rbxassetid://11114479573",
	"rbxassetid://11114479213",
	"rbxassetid://11114478866",
	"rbxassetid://11114478600",
	"rbxassetid://11114478054",
	"rbxassetid://11114477778",
	"rbxassetid://11114477466",
	"rbxassetid://11114477073",
	""
}
local _ = {
	"rbxassetid://11094874461",
	"rbxassetid://11094874278",
	"rbxassetid://11094874078",
	"rbxassetid://11094873802",
	"rbxassetid://11094873441",
	"rbxassetid://11094873232",
	"rbxassetid://11094873025",
	"rbxassetid://11094872708",
	"rbxassetid://11094872469",
	"rbxassetid://11094872203",
	""
}
local v2 = {
	"rbxassetid://11114482116",
	"rbxassetid://11121409618",
	"rbxassetid://11121409169",
	"rbxassetid://11121408680",
	"rbxassetid://11121408331",
	"rbxassetid://11121407998",
	"rbxassetid://11121407599",
	"rbxassetid://11121407094",
	"rbxassetid://11121416668",
	"rbxassetid://11121416286",
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
			local v3 = math.floor(p * #v)

			if script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[v3]
			end

			preload(v[v3])
		end)

		if script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)

			if script.Parent:FindFirstChild("Decal2") then
				script.Parent.Decal2.Texture = v2[v3]
			end

			preload(v2[v3])
		end)

		if script.Parent:FindFirstChild("Decal2") then
			script.Parent.Decal2.Texture = ""
		end
	end)
end