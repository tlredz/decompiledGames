local v = {
	"rbxassetid://16612901487",
	"rbxassetid://16612901209",
	"rbxassetid://16612900970",
	"rbxassetid://16612900673",
	"rbxassetid://16612900426",
	"rbxassetid://16612900092",
	"rbxassetid://16612899797",
	"rbxassetid://16612899543",
	"rbxassetid://16612899179",
	"rbxassetid://16612898917",
	"rbxassetid://16612898595",
	"rbxassetid://16612898335",
	"rbxassetid://16612898097"
}
return function(duration)
	for _, texture in v do
		script.Parent.Decal.Texture = texture
		task.wait(duration)
	end
end