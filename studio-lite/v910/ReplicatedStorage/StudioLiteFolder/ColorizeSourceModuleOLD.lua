local ColorizeSourceModuleOLD = {}
ColorizeSourceModuleOLD.__index = ColorizeSourceModuleOLD
local v = {
	["local"] = "<b><font color='#3030ff'>local</font></b>",
	["elseif"] = "<b><font color='#3030ff'>elseif</font></b>",
	["for"] = "<b><font color='#3030ff'>for</font></b>",
	["if"] = "<b><font color='#3030ff'>if</font></b>",
	["then"] = "<b><font color='#3030ff'>then</font></b>",
	["else"] = "<b><font color='#3030ff'>else</font></b>",
	["end"] = "<b><font color='#3030ff'>end</font></b>",
	["while"] = "<b><font color='#3030ff'>while</font></b>",
	["function"] = "<b><font color='#3030ff'>function</font></b>",
	["in"] = "<b><font color='#3030ff'>in</font></b>",
	["and"] = "<b><font color='#3030ff'>and</font></b>",
	["or"] = "<b><font color='#3030ff'>or</font></b>",
	["return"] = "<b><font color='#3030ff'>return</font></b>",
	["break"] = "<b><font color='#3030ff'>break</font></b>"
}

function ColorizeSourceModuleOLD.ColorizeSource(_, value, p, p2, p3)
	local v2 = ""
	local v3 = ""
	local v4 = 1
	local v5 = ""
	local v6 = ""
	local v7 = 0

	for k, v8 in pairs(value:split("\n")) do
		local v9

		if v8 == "" and p == false and _G.DynamicThumb then
			v9 = " \n"
		else
			local v10 = v8:gsub("<", "&lt;"):gsub("\t", "    ")

			if k == p3 then
				v5 = v10:match("^%s*")
			end

			local v11 = v10:find("--", 1, true)
			local v12

			if v11 then
				v12 = "<font color='#008800'>" .. v10:sub(v11) .. "</font>"
				v10 = v10:sub(1, v11 - 1)
			end

			if p2 then
				v2 ..= v3
				v10 = v10:match("^%s*(.*)")

				if v10:sub(1, 4) == "else" then
					v2 = v2:sub(5)
					v3 = "    "
				elseif v10:sub(1, 3) == "end" then
					v2 = v2:sub(5)
				elseif (v10:sub(1, 2) == "if" or v10:sub(1, 5) == "while" or v10:sub(1, 3) == "for" or v10:find(
					"function",
					1,
					true
				)) and v10:sub(-3) ~= "end" then
					v3 = "    "
				else
					v3 = ""
				end
			end

			local v13 = v10:gsub("%w+", v):gsub("%b\"\"", "<font color=\"#882020\">%1</font>"):gsub(
				"%w+%(",
				"<font color=\"#009999\">%1</font>"
			)

			if v12 then
				v13 ..= v12
			end

			if p then
				v9 = string.format("%4d", v4) .. "   " .. v2 .. v13 .. "\n"
				v4 += 1
			else
				v9 = v2 .. v13 .. "\n"
			end

			if k == p3 then
				v7 = #v2 - #v5
			end
		end

		v6 ..= v9
	end

	if #v6 > 3 and v6:sub(-2) == " \n" then
		return v6:sub(1, -3), v7
	end

	return v6, v7
end

return ColorizeSourceModuleOLD