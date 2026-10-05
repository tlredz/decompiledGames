local v = {
	"rbxassetid://16947157226",
	"rbxassetid://16947156591",
	"rbxassetid://16947156427",
	"rbxassetid://16947156278",
	"rbxassetid://16947156036",
	"rbxassetid://16947155812",
	"rbxassetid://16947155658",
	"rbxassetid://16947155446",
	"rbxassetid://16947155253",
	"rbxassetid://16947155108",
	"rbxassetid://16947154925",
	"rbxassetid://16947154682",
	"rbxassetid://16947154355",
	"rbxassetid://16947153998",
	"rbxassetid://16947153722",
	"rbxassetid://16947002154",
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