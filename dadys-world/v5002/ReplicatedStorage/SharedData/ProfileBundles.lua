local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileBackgrounds = require(ReplicatedStorage.SharedData.ProfileBackgrounds)
local ProfileFrames = require(ReplicatedStorage.SharedData.ProfileFrames)
local ProfileBackdrops = require(ReplicatedStorage.SharedData.ProfileBackdrops)
local ProfileBundles = {}
local v = {
	GardenviewDeluxe = {
		DisplayName = "Rainbow Bundle",
		Pass = "BackgroundPrints",
		Print = "RainbowPremium",
		Frame = "RainbowPremium",
		Backdrop = "RainbowPremium"
	},
	SwimmyBarnaby = {
		DisplayName = "Swimmy Barnaby Bundle",
		Pass = "SwimmyBarnaby",
		Print = "SwimmyBarnaby",
		Frame = "SwimmyBarnaby",
		Backdrop = "SwimmyBarnaby",
		Featured = true,
		FeaturedColor = Color3.fromRGB(124, 59, 202)
	}
}
ProfileBundles.Classes = {
	{
		Slot = "Print",
		Field = "BackgroundsOwned",
		Label = "print",
		Catalogue = ProfileBackgrounds
	},
	{
		Slot = "Frame",
		Field = "FramesOwned",
		Label = "frame",
		Catalogue = ProfileFrames
	},
	{
		Slot = "Backdrop",
		Field = "BackdropsOwned",
		Label = "backdrop",
		Catalogue = ProfileBackdrops
	}
}
local v2 = {}
local v3 = { "GardenviewDeluxe", "SwimmyBarnaby" }

for k, v4 in pairs(v) do
	local v5

	if type(v4.Pass) == "string" then
		v5 = v4.Pass ~= ""
	else
		v5 = false
	end

	assert(v5, "ProfileBundles: " .. k .. " has no Pass")
	assert(
		v2[v4.Pass] == nil,
		"ProfileBundles: " .. k .. " and " .. tostring(v2[v4.Pass]) .. " both name pass '" .. v4.Pass .. "' - one pass sells one bundle"
	)
	v2[v4.Pass] = k

	for _, class in ipairs(ProfileBundles.Classes) do
		local v6 = v4[class.Slot]
		local v7

		if type(v6) == "string" then
			v7 = v6 ~= ""
		else
			v7 = false
		end

		assert(v7, "ProfileBundles: " .. k .. " has no " .. class.Slot)
		assert(
			class.Catalogue.Get(v6) ~= nil,
			"ProfileBundles: " .. k .. " names " .. class.Label .. " '" .. v6 .. "', which does not exist in its catalogue"
		)
	end

	local pass = ProfileBackgrounds.GetPass(v4.Print)
	assert(
		pass == v4.Pass,
		"ProfileBundles: " .. k .. " is sold by pass '" .. v4.Pass .. "' but its print '" .. v4.Print .. "' has Pass = " .. tostring(pass) .. " - set them to the same value, or the print is free to everyone"
	)
end

local v4 = nil

for k, v5 in pairs(v) do
	if v5.Featured ~= true then
		continue
	end

	assert(
		v4 == nil,
		"ProfileBundles: " .. k .. " and " .. tostring(v4) .. " are both Featured - there is one banner slot, so only one may be"
	)
	v4 = k
end

function ProfileBundles.Get(value: string)
	if type(value) ~= "string" then
		return nil
	end

	local v5 = v[value]

	if v5 then
		return {
			Key = value,
			DisplayName = v5.DisplayName,
			Pass = v5.Pass,
			Print = v5.Print,
			Frame = v5.Frame,
			Backdrop = v5.Backdrop,
			Enabled = v5.Enabled ~= false,
			Featured = v5.Featured == true,
			FeaturedColor = v5.FeaturedColor
		}
	end

	return nil
end

function ProfileBundles.GetFeatured()
	for _, v5 in ipairs(v3) do
		local v6 = ProfileBundles.Get(v5)

		if v6 and v6.Featured and v6.Enabled then
			return v6
		end
	end

	return nil
end

function ProfileBundles.IsEnabled(p: string)
	local v5 = ProfileBundles.Get(p)
	return v5 ~= nil and v5.Enabled
end

function ProfileBundles.GetByPass(value)
	if type(value) ~= "string" then
		return nil
	end

	local v5 = v2[value]
	return v5 and ProfileBundles.Get(v5) or nil
end

function ProfileBundles.IsBundle(p)
	local v5 = ProfileBundles.GetByPass(p)
	return v5 ~= nil and v5.Enabled
end

function ProfileBundles.GetContents(p: string)
	local v5 = ProfileBundles.GetByPass(p)

	if v5 then
		return {
			Print = v5.Print,
			Frame = v5.Frame,
			Backdrop = v5.Backdrop
		}
	end

	return nil
end

function ProfileBundles.GetOrdered()
	local result = {}

	for _, v5 in ipairs(v3) do
		if v[v5] and ProfileBundles.IsEnabled(v5) then
			table.insert(result, v5)
		end
	end

	return result
end

function ProfileBundles.OwnsAll(p: string, callback)
	local v5 = ProfileBundles.GetByPass(p)

	if not v5 then
		return false
	end

	for _, class in ipairs(ProfileBundles.Classes) do
		if not callback(class.Field, v5[class.Slot]) then
			return false
		end
	end

	return true
end

return ProfileBundles