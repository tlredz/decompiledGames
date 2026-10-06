local v = {
	"rbxassetid://11269864574",
	"rbxassetid://11269863846",
	"rbxassetid://11269863230",
	"rbxassetid://11269862606",
	"rbxassetid://11269861961",
	"rbxassetid://11269861492",
	"rbxassetid://11269861093",
	"rbxassetid://11269860718",
	"rbxassetid://11269860263",
	"rbxassetid://11269859800",
	"rbxassetid://11269859250",
	"rbxassetid://11269858709",
	"rbxassetid://11269858253",
	"rbxassetid://11269857677",
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

return function()
	task.spawn(function()
		for i = 1, #v do
			script.Parent.Decal.Texture = v[i]
			preload(v[i])
			task.wait(0.025)
		end

		script.Parent.Decal.Texture = ""
	end)
end