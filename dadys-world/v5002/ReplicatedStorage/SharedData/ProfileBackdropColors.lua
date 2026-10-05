local ProfileBackdropColors = {
	DefaultKey = "Default",
	NoneKey = "",
	Colors = {
		Default = {
			DisplayName = "Default",
			Color = Color3.fromRGB(255, 245, 228)
		},
		Red = {
			DisplayName = "Red",
			Color = Color3.fromRGB(255, 197, 197)
		},
		Orange = {
			DisplayName = "Orange",
			Color = Color3.fromRGB(255, 205, 160)
		},
		Yellow = {
			DisplayName = "Yellow",
			Color = Color3.fromRGB(255, 240, 170)
		},
		Green = {
			DisplayName = "Green",
			Color = Color3.fromRGB(200, 235, 186)
		},
		Blue = {
			DisplayName = "Blue",
			Color = Color3.fromRGB(178, 240, 255)
		},
		Purple = {
			DisplayName = "Purple",
			Color = Color3.fromRGB(208, 186, 240)
		},
		Pink = {
			DisplayName = "Pink",
			Color = Color3.fromRGB(255, 190, 224)
		}
	},
	Order = {
		"Default",
		"Red",
		"Orange",
		"Yellow",
		"Green",
		"Blue",
		"Purple",
		"Pink"
	}
}

function ProfileBackdropColors.Get(value: string?)
	if type(value) == "string" then
		return ProfileBackdropColors.Colors[value]
	end

	return nil
end

function ProfileBackdropColors.IsEnabled(p: string?)
	local v = ProfileBackdropColors.Get(p)
	return v ~= nil and v.Enabled ~= false
end

function ProfileBackdropColors.Normalize(value)
	if type(value) ~= "string" or value == "" or value == ProfileBackdropColors.DefaultKey then
		return ProfileBackdropColors.NoneKey
	end

	if ProfileBackdropColors.IsEnabled(value) then
		return value
	end

	return ProfileBackdropColors.NoneKey
end

function ProfileBackdropColors.GetColor(p)
	local normalized = ProfileBackdropColors.Normalize(p)
	local v = ProfileBackdropColors.Get(normalized) or ProfileBackdropColors.Get(ProfileBackdropColors.DefaultKey)
	return v and v.Color or Color3.fromRGB(255, 245, 228)
end

function ProfileBackdropColors.GetOrdered()
	local result = {}

	for _, v in ipairs(ProfileBackdropColors.Order) do
		if ProfileBackdropColors.IsEnabled(v) then
			table.insert(result, v)
		end
	end

	return result
end

function ProfileBackdropColors.GetDisplayName(displayName: string)
	local v = ProfileBackdropColors.Get(displayName)

	if v then
		displayName = v.DisplayName or displayName
	end

	return displayName
end

return ProfileBackdropColors