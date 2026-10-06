local v = {
	"rbxassetid://11048899649",
	"rbxassetid://11048898168",
	"rbxassetid://11048896795",
	"rbxassetid://11048894358",
	"rbxassetid://11048892338",
	"rbxassetid://11048890306",
	"rbxassetid://11048888099",
	"rbxassetid://11048885960",
	"rbxassetid://11048884524",
	"rbxassetid://11048882973",
	""
}
local v2 = {
	"rbxassetid://11048974766",
	"rbxassetid://11048973352",
	"rbxassetid://11048971891",
	"rbxassetid://11048968817",
	"rbxassetid://11048965498",
	"rbxassetid://11048964263",
	"rbxassetid://11048962283",
	"rbxassetid://11048961060",
	"rbxassetid://11048959875",
	"rbxassetid://11048958556",
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

			if script.Parent and script.Parent:FindFirstChild("Decal") then
				script.Parent.Decal.Texture = v[v3]
			end

			preload(v[v3])
		end)

		if script.Parent and script.Parent:FindFirstChild("Decal") then
			script.Parent.Decal.Texture = ""
		end
	end)
	task.spawn(function()
		PeodizService.ForLoop({
			Step = #v2
		}, function(p)
			local v3 = math.floor(p * #v2)

			if script.Parent and script.Parent:FindFirstChild("Decal2") then
				script.Parent.Decal2.Texture = v2[v3]
			end

			preload(v2[v3])
		end)

		if script.Parent and script.Parent:FindFirstChild("Decal2") then
			script.Parent.Decal2.Texture = ""
		end
	end)
end