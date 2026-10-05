local v = {
	"rbxassetid://16754153391",
	"rbxassetid://16754153213",
	"rbxassetid://16754153044",
	"rbxassetid://16754152776",
	"rbxassetid://16754152271",
	"rbxassetid://16754152102",
	"rbxassetid://16754151902",
	"rbxassetid://16754151722",
	"rbxassetid://16754151528",
	"rbxassetid://16754151360",
	"rbxassetid://16754151195",
	"rbxassetid://16754151025",
	"rbxassetid://16754150826",
	"rbxassetid://16754150563"
}
return function(duration)
	task.spawn(function()
		for _, texture in v do
			if not script.Parent then
				break
			end

			script.Parent.Decal.Texture = texture
			script.Parent.Black.Transparency += 0.6
			task.wait(duration)
		end

		if not script.Parent then
			return
		end

		script.Parent.Decal.Transparency = 1
		script.Parent.Black.Transparency = 1
	end)
end