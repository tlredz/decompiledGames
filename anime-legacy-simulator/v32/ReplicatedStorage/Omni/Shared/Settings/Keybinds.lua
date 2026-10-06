local Keybinds = require(script.Parent.Parent.Keybinds)
local Keybinds2 = {
	Index = 5,
	Icon = "rbxassetid://128508361754018",
	Description = "Customize your shortcuts",
	List = {}
}

for _, device in { "Computer", "Console" } do
	for _, v2 in Keybinds.List do
		local setting = Keybinds.Settings[`{v2.Name} Keybind {device}`]
		table.insert(Keybinds2.List, {
			Name = setting.Name,
			DisplayName = setting.DisplayName,
			Description = device == "Computer" and "Click to change. Double-click to reset." or "Press to change. Double-press to reset.",
			Type = "Keybind",
			Device = device,
			Default = setting.Default
		})
	end
end

return Keybinds2