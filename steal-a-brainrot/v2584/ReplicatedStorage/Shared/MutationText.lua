local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Trove = require(ReplicatedStorage.Packages.Trove)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Index = require(datas.Index)
local Mutations = require(datas.Mutations)
local v = {
	Crystal = {
		Gradient = "Crystal"
	},
	Eclipse = {
		Gradient = "Eclipse"
	},
	Phantom = {
		Gradient = "Phantom",
		Bold = true
	},
	Rainbow = {
		Gradient = "Rainbow"
	},
	Christmas = {
		Gradient = "SlowGreenRed"
	}
}
local v2 = {}

local function getTextData(p: string)
	local mutation = Mutations[p]
	local v3 = Index[p]

	if not (mutation or v3) then
		return nil
	end

	local v5

	if mutation then
		v5 = mutation.DisplayText
	else
		v5 = v3 and v3.DisplayText
	end

	local v4 = {
		DisplayText = v5 or p,
		DisplayWithRichText = 0,
		UseRichText = 0,
		UseRichTextInSettings = 0,
		MainColor = 0
	}
	local displayWithRichText

	if mutation then
		displayWithRichText = mutation.DisplayWithRichText
	else
		displayWithRichText = v3 and v3.DisplayWithRichText
	end

	v4.DisplayWithRichText = displayWithRichText
	local useRichText

	if mutation then
		useRichText = mutation.UseRichText
	else
		useRichText = v3 and v3.UseRichText
	end

	v4.UseRichText = useRichText
	v4.UseRichTextInSettings = v3 and v3.UseRichTextInSettings
	v4.MainColor = mutation and mutation.MainColor or v3 and v3.MainColor
	return v4
end

local function buildMarkup(data, displayText: string, flag: boolean)
	if data.RichText then
		return data.RichText
	end

	if flag and data.Color then
		displayText = `<font color="{#data.Color:ToHex()}">{displayText}</font>`
	end

	if data.Bold then
		displayText = `<b>{displayText}</b>`
	end

	if data.Italic then
		displayText = `<i>{displayText}</i>`
	end

	if not data.Stroke then
		return displayText
	end

	local stroke = data.Stroke
	local v3 = ""

	if stroke.Color then
		v3 ..= ` color="{#stroke.Color:ToHex()}"`
	end

	if stroke.Thickness then
		v3 ..= ` thickness="{stroke.Thickness}"`
	end

	if stroke.Transparency then
		v3 ..= ` transparency="{stroke.Transparency}"`
	end

	displayText = `<stroke{v3}>{displayText}</stroke>`
	return displayText
end

local function hasInlineMarkup(data)
	return data.RichText ~= nil or data.Color ~= nil or data.Bold == true or data.Italic == true or data.Stroke ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearLabel(p)
	local v3 = v2[p]

	if v3 then
		v3:Destroy()
	end
end

local function trackLabelEffect(instance, callback)
	local maid = Trove.new()
	v2[instance] = maid
	maid:Add(callback)
	maid:Add(function()
		if v2[instance] == maid then
			v2[instance] = nil
		end
	end)
	maid:Add(instance.Destroying:Connect(function()
		clearLabel(instance) -- equivalent call inferred; original call site unknown
	end))
	return function()
		clearLabel(instance) -- equivalent call inferred; original call site unknown
	end
end

local function resolve(p: string, value: string?)
	local v3 = value or "Rich"
	local textData = getTextData(p)

	if not textData then
		return p, false
	end

	local v4 = v[p]

	if v4 and (v4.RichText ~= nil or v4.Color ~= nil or v4.Bold == true or v4.Italic == true or v4.Stroke ~= nil) then
		return buildMarkup(v4, textData.DisplayText, true), true
	end

	local displayWithRichText = textData.DisplayWithRichText or textData.DisplayText

	if v3 == "Rich" then
		return displayWithRichText, true
	end

	if v3 == "Settings" then
		if textData.UseRichTextInSettings then
			return displayWithRichText, true
		end

		return textData.DisplayText, false
	elseif textData.UseRichText then
		return displayWithRichText, true
	else
		return textData.DisplayText, false
	end
end

local function applyToLabel(p, p2: string?, value: string?)
	local v3 = p2 == nil and "Normal" or p2
	assert(v3)
	local v4 = value or "Auto"
	clearLabel(p) -- equivalent call inferred; original call site unknown
	local textData = getTextData(v3)
	local v5 = v[v3]

	if v5 and textData and (v5.Gradient or v5.RichText ~= nil or v5.Color ~= nil or v5.Bold == true or v5.Italic == true or v5.Stroke ~= nil) then
		if v5.Gradient then
			local markup = buildMarkup(v5, textData.DisplayText, false)
			p.Text = markup
			p.RichText = markup ~= textData.DisplayText
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
			return (trackLabelEffect(p, Gradients.apply(p, v5.Gradient)))
		else
			p.Text = buildMarkup(v5, textData.DisplayText, true)
			p.RichText = true
			return nil
		end
	else
		local text, richText = resolve(v3, v4)
		p.Text = text
		p.RichText = richText

		if v4 ~= "Auto" or (v3 == "Normal" or not textData) then
			return nil
		end

		p.TextColor3 = textData.MainColor or Color3.fromRGB(255, 255, 255)
		trackLabelEffect(p, function()
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		return nil
	end
end

return table.freeze({
	resolve = resolve,
	apply = applyToLabel,
	clear = clearLabel
})