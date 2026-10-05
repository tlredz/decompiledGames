local SequenceUtils = require(script.Parent.SequenceUtils)
local Richtext = {
	color = function(color: Color3, p: string)
		return (`<font color="#{color:ToHex()}">{p}</font>`)
	end
}

function Richtext.gradient(p, value: string)
	local v = string.split(value, "")
	local count = #v

	if count == 0 then
		return ""
	end

	local v2 = table.create(count)

	for k, v3 in v do
		local v4 = (k - 1) / count
		local sequenceValueAtTime = SequenceUtils.getSequenceValueAtTime(p, v4)
		v2[k] = Richtext.color(sequenceValueAtTime, v3)
	end

	return table.concat(v2)
end

function Richtext.bold(p: string)
	return (`<b>{p}</b>`)
end

function Richtext.italic(p: string)
	return (`<i>{p}</i>`)
end

function Richtext.underline(p: string)
	return (`<u>{p}</u>`)
end

function Richtext.strikeThrough(p: string)
	return (`<s>{p}</s>`)
end

function Richtext.size(p: number, p2: string)
	return (`<font size="{p}">{p2}</font>`)
end

function Richtext.font(p: string, p2: string)
	return (`<font face="{p}">{p2}</font>`)
end

function Richtext.weight(p, p2: string)
	return (`<font weight="{p.Name}">{p2}</font>`)
end

function Richtext.transparency(p: number, p2: string)
	return (`<font transparency="{p}">{p2}</font>`)
end

function Richtext.lineBreak()
	return "<br/>"
end

function Richtext.sanitizeForDisplay(value: string)
	local v = string.gsub(value, "<", "&lt;")
	return (string.gsub(v, ">", "&gt;"))
end

function Richtext.sanitize(value: string)
	local v = string.gsub(value, "<br/>", "\n")
	return (string.gsub(v, "<[^<>]->", ""))
end

function Richtext.isRichText(p: string)
	return p ~= Richtext.sanitize(p)
end

function Richtext.mark(color: Color3, p: number, p2: string)
	return (`<mark color="#{color:ToHex()}" transparency="{p}">{p2}</mark>`)
end

function Richtext.highlight1(p: string)
	return (`<font color="rgb(255, 244, 125)">{p}</font>`)
end

function Richtext.textToColor(value: string)
	local v = tonumber(value)

	if v ~= nil then
		return Color3.fromRGB(v, v, v)
	end

	if string.find(value, ",", 1, true) == nil then
		local success, result = pcall(Color3.fromHex, value)

		if success then
			return result
		end

		return nil
	else
		local v2 = string.split(value, ",")

		if #v2 ~= 3 then
			return nil
		end

		local v3 = tonumber(v2[1])
		local v4 = tonumber(v2[2])
		local v5 = tonumber(v2[3])

		if v3 == nil or v4 == nil or v5 == nil then
			return nil
		end

		return Color3.fromRGB(v3, v4, v5)
	end
end

return Richtext