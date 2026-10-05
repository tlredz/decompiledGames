require(script.TextPlusTypes)
local Handler = require(script.Handler)
local Storage = require(script.Storage)
local Styles = require(script.Animators.AnimatorClass.Styles)
local Textplus = {
	new = function(value: string, p)
		if value == nil then
			return
		end

		local settings = p == nil and {} or p
		settings.Size = settings.Size or 14
		settings.Color = settings.Color or Color3.fromRGB(255, 255, 255)
		settings.Wrapped = settings.Wrapped == nil or settings.Wrapped
		settings.Font = settings.Font or Enum.Font.SourceSans
		settings.FontFace = settings.FontFace or nil
		settings.Overfill = settings.Overfill
		settings.Transparency = settings.Transparency or 0
		settings.Scaled = settings.Scaled or settings.Scale ~= nil
		settings.XAlignment = settings.XAlignment or Enum.TextXAlignment.Left
		settings.YAlignment = settings.YAlignment or Enum.TextYAlignment.Top
		settings.Scale = settings.Scale
		settings.UseCanvas = settings.UseCanvas or false
		settings.ContentScaled = settings.ContentScaled == nil or settings.ContentScaled
		return (setmetatable({
			Animations = {},
			RawContent = value or "",
			Settings = settings
		}, Handler))
	end,
	RegisterId = function(p: string, p2)
		if p == nil or p2 == nil then
			return
		end

		Storage.IdsStorage[p] = p2
		return true
	end,
	UnRegisterId = function(p: string)
		if p == nil then
			return
		end

		Storage.IdsStorage[p] = nil
	end,
	RegisterStyle = function(p: string, callback)
		if p == nil or callback == nil then
			return
		end

		Styles[p] = callback
	end,
	UnRegisterStyle = function(p: string)
		if p == nil then
			return
		end

		Styles[p] = nil
	end
}
local typeof2 = typeof
local tostring2 = tostring
local clamp = math.clamp
local format = string.format
local v = nil
v = {
	Color = function(color: Color3)
		if color == nil then
			return
		end

		return format(
			"rgb(%d,%d,%d)",
			clamp(color.R * 255, 0, 255),
			clamp(color.G * 255, 0, 255),
			(clamp(color.B * 255, 0, 255))
		)
	end,
	Color3 = function(color: Color3)
		if color == nil then
			return
		end

		return format(
			"rgb(%d,%d,%d)",
			clamp(color.R * 255, 0, 255),
			clamp(color.G * 255, 0, 255),
			(clamp(color.B * 255, 0, 255))
		)
	end,
	FontFace = function(data)
		if data == nil then
			return nil
		end

		local v2 = not data.Family and "Unknown" or data.Family or "Unknown"
		local v3 = not data.Weight and "Regular" or data.Weight.Name or "Regular"
		local name = data.Style and data.Style.Name or "Normal"
		return format("(%s,%s,%s)", v2, v3, name)
	end,
	Style = function(list: string)
		if list == nil then
			return
		end

		if typeof2(list) ~= "table" then
			return list
		end

		local v2 = "("

		for i = 1, #list do
			if i ~= 1 then
				v2 ..= ","
			end

			if typeof2(list[i]) == "table" then
				if list[i].Style ~= nil or list[i].style ~= nil then
					local v4 = "("

					for k, v5 in pairs(list[i]) do
						if k == "Style" or k == "style" then
							v4 ..= v5
						else
							v4 ..= `,{k} = {v5}`
						end
					end

					v2 ..= v4 .. ")"
				end
			else
				v2 ..= list[i]
			end
		end

		return v2 .. ")"
	end,
	Font = function(p)
		if p == nil then
			return
		end

		local typeName = typeof2(p)

		if typeName == "Enum" then
			return p.Name
		elseif typeName == "string" then
			return p
		end

		return v.FontFace(p)
	end,
	EnumItem = function(p)
		if p == nil then
			return
		else
			return p.Name
		end
	end
}

function Textplus.Format(items)
	local typeName = typeof2(items)

	if typeName == "table" then
		local count = 0
		local v2 = ""

		for k, item in pairs(items) do
			local v3 = k == "Image" and "Img" or k
			local v4 = nil

			if v[v3] == nil then
				local typeName2 = typeof2(item)

				if typeName2 == "string" then
					v4 = item
				elseif v[typeName2] ~= nil then
					v4 = v[typeName2](item)
				end

				if v4 == nil then
					v4 = tostring2(item)
				end
			else
				v4 = v[v3](item)
			end

			if v4 == nil then
				continue
			end

			if count == 0 then
				v2 ..= `{v3} = {v4}`
			else
				v2 ..= `,{v3} = {v4}`
			end

			count += 1
		end

		return v2
	elseif typeName == "string" then
		return items
	else
		return v[typeName] and v[typeName](items) or tostring2(items)
	end
end

return Textplus