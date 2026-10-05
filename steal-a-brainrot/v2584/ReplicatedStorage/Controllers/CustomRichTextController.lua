local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = {
	"rainbow",
	"og",
	"yellowred",
	"zebra",
	"greenred",
	"slowgreenred",
	"phantom",
	"crystal",
	"eclipse"
}

local function transformRichText(value: string)
	local result = {}

	for _, tag in v do
		local formatted = `<{tag}>(.-)</{tag}>`
		local text, v4 = string.gsub(
			value,
			formatted,
			"<stroke transparency=\"0\"><font transparency=\"0\">%1</font></stroke>"
		)

		if not (v4 > 0) then
			continue
		end

		value = string.gsub(value, formatted, "<stroke transparency=\"1\"><font transparency=\"1\">%1</font></stroke>")
		table.insert(result, {
			tag = tag,
			text = text
		})
	end

	return value, result
end

local CustomRichTextController = {}
local v2 = {}

function CustomRichTextController:apply(p: string, p2)
	CustomRichTextController.cleanup(self)
	local maid = Trove.new()
	v2[self] = maid
	maid:Add(function()
		v2[self] = nil
	end)
	self.RichText = true
	local text, v4 = transformRichText(p)
	self.Text = text

	for _, v5 in v4 do
		local clone = maid:Clone(self)
		clone:ClearAllChildren()
		clone.Text = `<stroke transparency="1"><font transparency="1">{v5.text}</font></stroke>`
		clone.Size = UDim2.fromScale(1, 1)
		clone.Position = UDim2.fromScale(0.5, 0.5)
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Parent = self

		if v5.tag == "rainbow" then
			maid:Add(Gradients.apply(clone, "Rainbow"))
		elseif v5.tag == "zebra" then
			maid:Add(Gradients.apply(clone, "Zebra"))
		elseif v5.tag == "og" then
			maid:Add(Gradients.apply(clone, "OG"))
		elseif v5.tag == "yellowred" then
			maid:Add(Gradients.apply(clone, "YellowRed"))
		elseif v5.tag == "greenred" then
			maid:Add(Gradients.apply(clone, "GreenRed"))
		elseif v5.tag == "slowgreenred" then
			maid:Add(Gradients.apply(clone, "SlowGreenRed"))
		elseif v5.tag == "phantom" then
			maid:Add(Gradients.apply(clone, "Phantom"))
		elseif v5.tag == "crystal" then
			maid:Add(Gradients.apply(clone, "Crystal"))
		elseif v5.tag == "eclipse" then
			maid:Add(Gradients.apply(clone, "Eclipse"))
		end
	end

	if p2 and p2.attachToInstance then
		maid:AttachToInstance(self)
	end

	return maid
end

function CustomRichTextController.cleanup(p)
	if v2[p] then
		v2[p]:Destroy()
	end
end

return CustomRichTextController