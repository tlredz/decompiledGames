local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local Color = require(ReplicatedStorage.Modules.Color)
local parent = script.Parent
local template = parent.Template
template.Parent = nil
local Palette = require(script.Palette)
local count = 0

for i = 1, #Palette / 2 do
	for i2 = 1, 4 do
		for i3 = 1, 2 do
			local v = Palette[i * 2 - 1 + i3 - 1]

			for i4 = 1, 4 do
				local clone = template:Clone()
				clone.BackgroundColor3 = v[(i2 - 1) * 4 + i4]
				clone.IsSelected.Icon.ImageColor3 = Color:GetShadedColor(clone.BackgroundColor3, 0.7)
				clone.Name = clone.BackgroundColor3:ToHex()
				UI:AddShadowOnHover(clone)
				UI:Bind(clone.Button)
				clone.LayoutOrder = count
				clone.Parent = parent
				count += 1
			end
		end
	end
end