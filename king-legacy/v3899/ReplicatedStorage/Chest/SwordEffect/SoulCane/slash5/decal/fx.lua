local v = {
	"rbxassetid://9051285479",
	"rbxassetid://9051285231",
	"rbxassetid://9051285043",
	"rbxassetid://9051284824",
	"rbxassetid://9051284673",
	"rbxassetid://9051284519",
	"rbxassetid://9051284319",
	"rbxassetid://9051284195",
	"rbxassetid://9051284067",
	"rbxassetid://9051283931",
	"rbxassetid://9051283730",
	"rbxassetid://9051283505"
}
return function()
	task.spawn(function()
		for _, texture in pairs(v) do
			task.wait()

			if script.Parent and script.Parent:IsA("Decal") then
				script.Parent.Texture = texture
			end
		end
	end)
end