local v = {
	RainbowPremium = {
		DisplayName = "Rainbow",
		Image = "rbxassetid://90328887205982",
		Color = Color3.fromRGB(214, 186, 138)
	},
	SwimmyBarnaby = {
		DisplayName = "Swimmy Barnaby",
		Image = "rbxassetid://100729539475226",
		Color = Color3.fromRGB(138, 196, 214)
	}
}
local ProfileFrames = {
	NoneKey = ""
}
local v2 = { "RainbowPremium", "SwimmyBarnaby" }

for k, v3 in pairs(v) do
	local v4

	if type(v3.DisplayName) == "string" then
		v4 = v3.DisplayName ~= ""
	else
		v4 = false
	end

	assert(v4, "ProfileFrames: " .. k .. " has no DisplayName")
	assert(
		type(v3.Image) == "string" and v3.Image ~= "" or typeof(v3.Color) == "Color3",
		"ProfileFrames: " .. k .. " has neither an Image nor a Color to fall back on"
	)
end

function ProfileFrames.Get(value: string)
	if type(value) ~= "string" then
		return nil
	end

	local v3 = v[value]

	if v3 then
		return {
			Key = value,
			DisplayName = v3.DisplayName,
			Image = v3.Image or "",
			Color = v3.Color,
			Creator = v3.Creator,
			Enabled = v3.Enabled ~= false
		}
	end

	return nil
end

function ProfileFrames.IsEnabled(p: string)
	local v3 = ProfileFrames.Get(p)
	return v3 ~= nil and v3.Enabled
end

function ProfileFrames.RequiresOwnership(p: string)
	return ProfileFrames.Get(p) ~= nil
end

function ProfileFrames.GetOrdered()
	local result = {}
	local v3 = {}

	for _, v4 in ipairs(v2) do
		if not (v[v4] and ProfileFrames.IsEnabled(v4)) then
			continue
		end

		table.insert(result, v4)
		v3[v4] = true
	end

	local v4 = {}

	for k in pairs(v) do
		if v3[k] or not ProfileFrames.IsEnabled(k) then
			continue
		end

		table.insert(v4, k)
	end

	table.sort(v4)

	for _, v5 in ipairs(v4) do
		table.insert(result, v5)
	end

	return result
end

return ProfileFrames