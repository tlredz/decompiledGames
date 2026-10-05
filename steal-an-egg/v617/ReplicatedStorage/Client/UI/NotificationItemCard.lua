local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HoverCard = require(ReplicatedStorage.Client.HoverCard)
local NotificationItem = require(ReplicatedStorage.Shared.NotificationItem)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Sparkles = require(ReplicatedStorage.Client.UI.VFX.Sparkles)
local v = { "Level", "Strength" }

local function child(instance, childName: string)
	local child2 = instance:FindFirstChild(childName)
	assert(child2, (`{instance:GetFullName()} is missing {childName}`))
	return child2
end

local function countText(p: number)
	return (`{Simple.FormatCompact(p)}x`)
end

local function byPriority(p, p2)
	return p.Priority < p2.Priority
end

local function describeItem(data)
	local when = data.Description ~= ""
	local v3 = {
		{
			Priority = 40,
			When = when,
			Row = {
				kind = "body",
				text = data.Description
			}
		},
		{
			Priority = 20,
			When = true,
			Row = {
				kind = "tier",
				rarity = data.Rarity
			}
		},
		{
			Priority = 10,
			When = true,
			Row = {
				kind = "heading",
				text = data.Name
			}
		},
		{
			Priority = 30,
			When = when,
			Row = {
				kind = "rule"
			}
		}
	}
	table.sort(v3, byPriority)
	local rows = {}

	for _, v4 in v3 do
		if v4.When then
			table.insert(rows, v4.Row)
		end
	end

	return rows
end

local function applyPresentation(clone, p, describe, p2)
	local icon = clone:FindFirstChild("Icon")
	assert(icon, (`{clone:GetFullName()} is missing Icon`))
	local quantity = clone:FindFirstChild("Quantity")
	assert(quantity, (`{clone:GetFullName()} is missing Quantity`))
	icon.Image = describe.Icon
	local amount = p.Amount
	quantity.Text = `{Simple.FormatCompact(amount)}x`
	quantity.Visible = p2.ShowCount ~= false

	for _, childName in v do
		local guiObject = clone:FindFirstChild(childName)

		if guiObject and guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sparkleWhenPlaced(clone)
	clone:GetPropertyChangedSignal("Parent"):Once(function()
		if clone.Parent ~= nil then
			task.defer(Sparkles, clone)
		end
	end)
end

return {
	Build = function(p, options)
		assert(NotificationItem.Schema(p), "invalid notification item card")
		local v2 = options or {}
		local describe = NotificationItem.Describe(p)
		local rarity = describe.Rarity
		local clone = rarity.ItemTemplate:Clone()
		applyPresentation(clone, p, describe, v2)
		HoverCard.Attach(clone, (describeItem(describe)))

		if v2.Sparkle ~= false then
			Sparkles(clone)
		end

		if rarity.Rank >= 5 then
			sparkleWhenPlaced(clone) -- equivalent call inferred; original call site unknown
		end

		return clone
	end
}