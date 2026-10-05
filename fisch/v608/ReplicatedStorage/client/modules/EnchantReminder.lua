local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local enchantreminder = script:WaitForChild("enchantreminder")
enchantreminder:WaitForChild("UIStroke")
local EnchantReminder = {
	Clear = function(instance, p: string)
		for _, child in instance:GetChildren() do
			if child.Name:match((`^{p}_enchant%d+$`)) then
				child:Destroy()
			end
		end
	end
}

function EnchantReminder.Render(data)
	EnchantReminder.Clear(data.Frame, data.Prefix)

	if not SettingsController:GetSettingValue("showEnchantInfo") then
		return
	end

	local count = 0

	for _, entry in data.Entries do
		local v

		if entry.Name then
			v = data.Enchants[entry.Name]
		end

		if not v then
			continue
		end

		count += 1
		local clone = enchantreminder:Clone()
		clone.Name = `{data.Prefix}_enchant{count}`
		clone.Text = v.Description

		if v.ColorGradient then
			clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.UIGradient.Color = v.ColorGradient
		else
			clone.TextColor3 = v.Color
		end

		clone.UIStroke.Color = v.StrokeColor
		clone.UIStroke.Transparency = v.ForceStroke and 0 or 0.35

		if entry.Size then
			clone.Size = entry.Size
		end

		if count == 1 and data.FirstPosition then
			clone.Position = data.FirstPosition
		end

		clone.Visible = data.Visible ~= false
		clone.Parent = data.Frame
	end
end

return EnchantReminder