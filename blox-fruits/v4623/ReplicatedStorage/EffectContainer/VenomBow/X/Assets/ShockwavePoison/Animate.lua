local v = {
	"rbxassetid://16946482827",
	"rbxassetid://16946482608",
	"rbxassetid://16946482350",
	"rbxassetid://16946482191",
	"rbxassetid://16946481891",
	"rbxassetid://16946481712",
	"rbxassetid://16946481496",
	"rbxassetid://16946481291",
	"rbxassetid://16946481124",
	"rbxassetid://16946480843",
	"rbxassetid://16946480558",
	"rbxassetid://16946480359",
	""
}
return function(duration)
	for _, texture in v do
		if not script.Parent then
			break
		end

		script.Parent.Decal.Texture = texture
		task.wait(duration)
	end
end