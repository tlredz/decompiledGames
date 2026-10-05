local v = {
	Default = {
		DisplayName = "Default",
		Preview = "rbxassetid://82364934163247",
		Images = {
			TL = "rbxassetid://119459916184904",
			TR = "rbxassetid://108939518516632",
			BL = "rbxassetid://114757692345009",
			BR = "rbxassetid://78212258878824"
		},
		Free = true
	},
	RainbowPremium = {
		DisplayName = "Gardenview Rainbow",
		Preview = "rbxassetid://127330816450922",
		Images = {
			TL = "rbxassetid://88870749526181",
			TR = "rbxassetid://77202969846677",
			BL = "rbxassetid://80794676933589",
			BR = "rbxassetid://115233472360818"
		},
		Oversize = true
	},
	SwimmyBarnaby = {
		DisplayName = "Swimmy Barnaby",
		Preview = "rbxassetid://82763765712856",
		Images = {
			TL = "rbxassetid://96315219240654",
			TR = "rbxassetid://95222283348492",
			BL = "rbxassetid://94291685203701",
			BR = "rbxassetid://76178026433238"
		},
		Oversize = true
	}
}
local ProfileBackdrops = {
	DefaultKey = "Default",
	NoneKey = "",
	Quadrants = {
		"TL",
		"TR",
		"BL",
		"BR"
	}
}
local v2 = { "Default", "RainbowPremium", "SwimmyBarnaby" }

for k, v3 in pairs(v) do
	local v4

	if type(v3.DisplayName) == "string" then
		v4 = v3.DisplayName ~= ""
	else
		v4 = false
	end

	assert(v4, "ProfileBackdrops: " .. k .. " has no DisplayName")
	assert(type(v3.Images) == "table", "ProfileBackdrops: " .. k .. " has no Images table")

	for k2 in pairs(v3.Images) do
		assert(
			table.find(ProfileBackdrops.Quadrants, k2) ~= nil,
			"ProfileBackdrops: " .. k .. " has an unknown quadrant '" .. tostring(k2) .. "' - expected one of TL, TR, BL, BR"
		)
	end

	if not (v3.Enabled ~= false and k ~= ProfileBackdrops.DefaultKey) then
		continue
	end

	for _, quadrant in ipairs(ProfileBackdrops.Quadrants) do
		local image = v3.Images[quadrant]
		local v5

		if type(image) == "string" then
			v5 = image ~= ""
		else
			v5 = false
		end

		assert(
			v5,
			"ProfileBackdrops: " .. k .. " is enabled but its " .. quadrant .. " quadrant is empty - set Enabled = false until all four are uploaded"
		)
	end
end

local v3 = v[ProfileBackdrops.DefaultKey]
assert(v3, "ProfileBackdrops: the Default backdrop is missing")
assert(v3.Enabled ~= false, "ProfileBackdrops: the Default backdrop must not be withheld")
assert(v3.Free == true, "ProfileBackdrops: the Default backdrop must be Free")
assert(v3.Oversize ~= true, "ProfileBackdrops: the Default backdrop cannot be Oversize")

for k, v4 in pairs(v) do
	assert(
		v4.Free ~= true or k == ProfileBackdrops.DefaultKey,
		"ProfileBackdrops: " .. k .. " is marked Free - only Default may be, or the premium art is handed to everyone"
	)
end

function ProfileBackdrops.Get(value: string)
	if type(value) ~= "string" then
		return nil
	end

	local v4 = v[value]

	if not v4 then
		return nil
	end

	local images = {}

	for _, quadrant in ipairs(ProfileBackdrops.Quadrants) do
		local image = v4.Images[quadrant]
		images[quadrant] = type(image) == "string" and image or ""
	end

	return {
		Key = value,
		DisplayName = v4.DisplayName,
		Images = images,
		Preview = type(v4.Preview) ~= "string" and "" or v4.Preview or "",
		Oversize = v4.Oversize == true,
		Creator = v4.Creator,
		Enabled = v4.Enabled ~= false,
		Free = v4.Free == true
	}
end

function ProfileBackdrops.IsEnabled(p: string)
	local v4 = ProfileBackdrops.Get(p)
	return v4 ~= nil and v4.Enabled
end

function ProfileBackdrops.IsDefault(p)
	return ProfileBackdrops.Resolve(p) == ProfileBackdrops.DefaultKey
end

function ProfileBackdrops.RequiresOwnership(p: string)
	local v4 = ProfileBackdrops.Get(p)
	return v4 ~= nil and not v4.Free
end

function ProfileBackdrops.Resolve(value)
	if type(value) ~= "string" or value == "" then
		return ProfileBackdrops.DefaultKey
	end

	if ProfileBackdrops.IsEnabled(value) then
		return value
	end

	return ProfileBackdrops.DefaultKey
end

function ProfileBackdrops.PreviewImage(p: string)
	local v4 = ProfileBackdrops.Get(p)

	if not v4 then
		return ""
	end

	if v4.Preview == "" then
		return v4.Images.TL
	end

	return v4.Preview
end

function ProfileBackdrops.GetOrdered()
	local result = {}
	local v4 = {}

	for _, v5 in ipairs(v2) do
		if not (v[v5] and ProfileBackdrops.IsEnabled(v5)) then
			continue
		end

		table.insert(result, v5)
		v4[v5] = true
	end

	local v5 = {}

	for k in pairs(v) do
		if v4[k] or not ProfileBackdrops.IsEnabled(k) then
			continue
		end

		table.insert(v5, k)
	end

	table.sort(v5)

	for _, v6 in ipairs(v5) do
		table.insert(result, v6)
	end

	return result
end

return ProfileBackdrops