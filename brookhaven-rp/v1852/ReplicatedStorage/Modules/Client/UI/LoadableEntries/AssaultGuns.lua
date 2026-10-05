game:GetService("ReplicatedStorage")
return {
	Entries = {
		{
			Icon = "rbxassetid://13618607924",
			Name = "Silencer"
		},
		{
			Icon = "rbxassetid://13618604427",
			Name = "Flashlight"
		}
	},
	Setup = function(p, p2)
		p.Name = p2.Name
		p.Icon.Image = p2.Icon
	end
}