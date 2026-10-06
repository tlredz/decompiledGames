local v = {
	"rbxassetid://11269490781",
	"rbxassetid://11269489915",
	"rbxassetid://11269488793",
	"rbxassetid://11269488793",
	"rbxassetid://11269488184",
	"rbxassetid://11269487503",
	"rbxassetid://11269487027",
	"rbxassetid://11269486600",
	"rbxassetid://11269486190",
	"rbxassetid://11269485769",
	"rbxassetid://11269485143",
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