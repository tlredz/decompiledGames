local v = {
	"rbxassetid://16945997177",
	"rbxassetid://16945997004",
	"rbxassetid://16945997004",
	"rbxassetid://16945996722",
	"rbxassetid://16945996533",
	"rbxassetid://16945996185",
	"rbxassetid://16945995890",
	"rbxassetid://16945995890",
	"rbxassetid://16945995574",
	"rbxassetid://16945995452",
	"rbxassetid://16945995300",
	"rbxassetid://16945995134",
	"rbxassetid://16945994962",
	"rbxassetid://16945994825",
	"rbxassetid://16945994715",
	"rbxassetid://16945994581",
	""
}
return function(duration, p)
	for _, texture in v do
		p.Decal.Texture = texture
		task.wait(duration)
	end
end