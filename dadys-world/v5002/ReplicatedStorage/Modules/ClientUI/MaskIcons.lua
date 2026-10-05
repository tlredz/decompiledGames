local v = {
	sprout = "rbxassetid://124640980204255",
	soulvester = "rbxassetid://133239046674692",
	shelly = "rbxassetid://102321140505240",
	dandy = "rbxassetid://77051890677686",
	gourdy = "rbxassetid://100889449297836",
	vee = "rbxassetid://83045244582968",
	connie = "rbxassetid://122706466702502",
	astro = "rbxassetid://136320597926093",
	pebble = "rbxassetid://74335786893528"
}
local v2 = {
	pebble = Color3.fromRGB(115, 115, 115),
	sprout = Color3.fromRGB(115, 46, 46),
	vee = Color3.fromRGB(40, 115, 36),
	astro = Color3.fromRGB(47, 52, 115),
	shelly = Color3.fromRGB(115, 106, 72),
	soulvester = Color3.fromRGB(40, 64, 115),
	connie = Color3.fromRGB(28, 115, 112),
	gourdy = Color3.fromRGB(115, 62, 18),
	dandy = Color3.fromRGB(74, 115, 99)
}
local v3 = {
	dandy = {
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
			ColorSequenceKeypoint.new(0.259067, Color3.new(1, 0.498039, 0.0588235)),
			ColorSequenceKeypoint.new(0.502591, Color3.new(1, 0.980392, 0.360784)),
			ColorSequenceKeypoint.new(0.692573, Color3.new(0.309804, 1, 0.298039)),
			ColorSequenceKeypoint.new(0.799655, Color3.new(0.411765, 0.588235, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.807843, 0.117647, 1))
		}),
		rotation = -10
	}
}
local MaskIcons = {}

function MaskIcons.iconFor(value: string?)
	if type(value) == "string" then
		return v[string.lower(value)]
	end

	return nil
end

function MaskIcons.backgroundColorFor(value: string?)
	if type(value) == "string" then
		return v2[string.lower(value)]
	end

	return nil
end

function MaskIcons.applyBackgroundGradient(instance, value: string?)
	local v4

	if type(value) == "string" then
		v4 = v3[string.lower(value)] or nil
	end

	if not v4 then
		return
	end

	local uIGradient = instance:FindFirstChildOfClass("UIGradient")

	if not uIGradient then
		warn("[MaskIcons] " .. tostring(value) .. " has a Background gradient but Background has no UIGradient")
		return
	end

	uIGradient.Color = v4.color
	uIGradient.Rotation = v4.rotation
end

function MaskIcons.apply(instance, value: string?)
	local icon = instance:FindFirstChild("Icon", true)

	if icon then
		if not (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
			warn(("[MaskIcons] %s is a %s, not an image; cannot set the mask art"):format(
				icon:GetFullName(),
				icon.ClassName
			))
			return
		end

		local image

		if type(value) == "string" then
			image = v[string.lower(value)]
		end

		if not image then
			warn("[MaskIcons] no icon authored for mask " .. tostring(value))
			return
		end

		icon.Image = image
		print(("[MaskIcons] %s -> %s on %s"):format(tostring(value), image, icon:GetFullName()))
	else
		local fullName = instance:GetFullName()
		local v4 = {}

		for _, child in ipairs(instance:GetChildren()) do
			table.insert(v4, child.Name .. " (" .. child.ClassName .. ")")
		end

		warn(("[MaskIcons] no descendant named Icon under %s; children: %s"):format(fullName, table.concat(v4, ", ")))
	end
end

return MaskIcons