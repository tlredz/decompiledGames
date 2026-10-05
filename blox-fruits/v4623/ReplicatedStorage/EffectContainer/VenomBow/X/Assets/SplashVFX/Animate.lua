local v = {
	"rbxassetid://12227933587",
	"rbxassetid://12227933167",
	"rbxassetid://12227944636",
	"rbxassetid://12227928674",
	"rbxassetid://12227927546",
	"rbxassetid://12227927317",
	"rbxassetid://12227926939",
	"rbxassetid://12227926609",
	"rbxassetid://12227926281",
	"rbxassetid://12227925788",
	"rbxassetid://12227925302",
	"rbxassetid://12227925006",
	"rbxassetid://12227924769",
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