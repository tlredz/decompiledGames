local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetItem = require(ReplicatedStorage.Shared.Types.AssetItem)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	["\""] = "&quot;"
}
local AssetDisplayText = {}

local function escape(value: string)
	return (value:gsub("[&<>\"]", v))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colourRun(p: string)
	local v2 = Mutations.Get(p)
	return v2 and `<font color="#{v2.Tint:ToHex()}">{v2.Label:gsub("[&<>\"]", v)}</font>`
end

function AssetDisplayText.IsDroppable(value: string?)
	return typeof(value) == "string" and value ~= "" and Mutations.RollChanceOf(value) > 0
end

function AssetDisplayText.FirstDroppable(p: string?, p2)
	local v2 = typeof(p2) ~= "table" and {} or p2

	for i = 0, #v2 do
		local selected

		if i == 0 then
			selected = p
		else
			selected = v2[i]
		end

		if AssetDisplayText.IsDroppable(selected) then
			return selected
		end
	end

	return nil
end

function AssetDisplayText.Compose(p: string, p2, p3: string?)
	local v2 = Mutations.Sanitize(p2, p3)
	local v3 = table.create(#v2)

	for i, v4 in ipairs(v2) do
		v3[i] = Mutations.LabelOf(v4)
	end

	if #v2 == 0 then
		return p
	end

	return (`{table.concat(v3, " + ")} {p}`)
end

function AssetDisplayText.WithMass(p: string, p2, p3: string?, p4: number)
	return string.format("%s (%.2f kg)", AssetDisplayText.Compose(p, p2, p3), p4)
end

function AssetDisplayText.ForRecord(data)
	assert(AssetItem.AssetItemData(data))
	local displayName = Assets.Directory[data.Category].DisplayName or "Unknown"
	return AssetDisplayText.Compose(displayName, data.Mutations, data.BaseMutation)
end

function AssetDisplayText.MutationRun(p, p2: string?)
	t.strict(t.table)(p)
	t.strict(t.optional(t.string))(p2)
	local v2 = {}

	for _, v3 in Mutations.Sanitize(p, p2) do
		local v4 = #v2 + 1
		v2[v4] = colourRun(v3)
	end

	if #v2 == 0 then
		return nil
	end

	return (table.concat(v2, ", "))
end

return AssetDisplayText