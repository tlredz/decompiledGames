local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = {
	"LocalTransparencyModifier",
	"CanCollide",
	"CanQuery",
	"CanTouch"
}
local v2 = {
	CanCollide = false,
	CanQuery = false,
	CanTouch = false,
	LocalTransparencyModifier = 1
}
local v3 = { "Decal", "Texture" }
local v4 = { "Transparency" }
local v5 = {
	Transparency = 1
}
local v6 = { "Enabled" }
local v7 = {
	Enabled = false
}
local v8 = {
	"ParticleEmitter",
	"Beam",
	"Trail",
	"BillboardGui",
	"SurfaceGui",
	"Highlight",
	"Light",
	"ProximityPrompt"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function anyClassMatches(part, items)
	for _, className in items do
		if part:IsA(className) then
			return true
		end
	end

	return false
end

local function muteFields(maid, part, list, p)
	local v10 = table.create(#list)

	for k, v11 in list do
		v10[k] = part[v11]
		part[v11] = p[v11]
	end

	maid:Add(function()
		if part.Parent == nil then
			return
		end

		for k, v11 in list do
			part[v11] = v10[k]
		end
	end)
end

local function mute(maid, part)
	if part:IsA("BasePart") then
		muteFields(maid, part, v, v2)
		return
	end

	-- equivalent call inferred; original call site unknown
	if anyClassMatches(part, v3) then
		muteFields(maid, part, v4, v5)
		return
	end

	-- equivalent call inferred; original call site unknown
	if anyClassMatches(part, v8) then
		muteFields(maid, part, v6, v7)
	end
end

return table.freeze({
	Conceal = function(folder)
		local maid = Trove.new()

		for _, descendant in folder:GetDescendants() do
			mute(maid, descendant)
		end

		maid:Add(folder.DescendantAdded:Connect(function(descendant)
			mute(maid, descendant)
		end))
		return maid
	end
})