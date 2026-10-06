local ColorizeSourceModule = {}
ColorizeSourceModule.__index = ColorizeSourceModule
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
local v2 = {
	["local"] = "<b><font color='#9090ff'>local</font></b>",
	["elseif"] = "<b><font color='#9090ff'>elseif</font></b>",
	["for"] = "<b><font color='#9090ff'>for</font></b>",
	["if"] = "<b><font color='#9090ff'>if</font></b>",
	["then"] = "<b><font color='#9090ff'>then</font></b>",
	["else"] = "<b><font color='#9090ff'>else</font></b>",
	["end"] = "<b><font color='#9090ff'>end</font></b>",
	["while"] = "<b><font color='#9090ff'>while</font></b>",
	["function"] = "<b><font color='#9090ff'>function</font></b>",
	["in"] = "<b><font color='#9090ff'>in</font></b>",
	["and"] = "<b><font color='#9090ff'>and</font></b>",
	["or"] = "<b><font color='#9090ff'>or</font></b>",
	["return"] = "<b><font color='#9090ff'>return</font></b>",
	["break"] = "<b><font color='#9090ff'>break</font></b>"
}

function ColorizeSourceModule.ColorizeSource(_, value, p, p2, p3)
	local uIStroke = nil
	local sL_CodeTextBox = nil
	local altKeyboardTextBox = nil
	pcall(function()
		local viewScriptFrame = game.Players.LocalPlayer.PlayerGui.StudioGui.ViewScriptFrame
		sL_CodeTextBox = viewScriptFrame.ScrollingFrame:FindFirstChild("SL_CodeTextBox") or viewScriptFrame.ViewScriptTextLabelTemplate
		altKeyboardTextBox = viewScriptFrame.AltKeyboardTextBoxFrame.AltKeyboardTextBox
		uIStroke = viewScriptFrame.DarkModeImageButton.UIStroke
	end)
	local v3, v4, v5, v6

	if uIStroke then
		if uIStroke.Color == Color3.new(0, 0, 0) then
			v3 = v2
			sL_CodeTextBox.BackgroundColor3 = Color3.new(0, 0, 0)
			sL_CodeTextBox.TextColor3 = Color3.new(1, 1, 1)
			altKeyboardTextBox.BackgroundColor3 = Color3.new(0, 0, 0)
			altKeyboardTextBox.TextColor3 = Color3.new(1, 1, 1)
			v4 = "#00ff00"
			v5 = "#ff2020"
			v6 = "#00ffff"
		else
			v3 = v
			v5 = "#882020"
			v6 = "#009999"
			v4 = "#008800"

			if altKeyboardTextBox then
				sL_CodeTextBox.BackgroundColor3 = Color3.new(1, 1, 1)
				sL_CodeTextBox.TextColor3 = Color3.new(0, 0, 0)
				altKeyboardTextBox.BackgroundColor3 = Color3.new(1, 1, 1)
				altKeyboardTextBox.TextColor3 = Color3.new(0, 0, 0)
			end
		end
	else
		v3 = v
		v5 = "#882020"
		v6 = "#009999"
		v4 = "#008800"

		if altKeyboardTextBox then
			sL_CodeTextBox.BackgroundColor3 = Color3.new(1, 1, 1)
			sL_CodeTextBox.TextColor3 = Color3.new(0, 0, 0)
			altKeyboardTextBox.BackgroundColor3 = Color3.new(1, 1, 1)
			altKeyboardTextBox.TextColor3 = Color3.new(0, 0, 0)
		end
	end

	local v7 = ""
	local v8 = ""
	local v9 = 1
	local v10 = ""
	local v11 = ""
	local v12 = 0

	for k, v13 in pairs(value:split("\n")) do
		local v14

		if v13 == "" and p == false and _G.DynamicThumb then
			v14 = " \n"
		else
			local v15 = v13:gsub("<", "&lt;"):gsub("\t", "    ")

			if k == p3 then
				v10 = v15:match("^%s*")
			end

			local v16 = v15:find("--", 1, true)
			local v17

			if v16 then
				v17 = "<font color=\"" .. v4 .. "\">" .. v15:sub(v16) .. "</font>"
				v15 = v15:sub(1, v16 - 1)
			end

			if p2 then
				v7 ..= v8
				v15 = v15:match("^%s*(.*)")

				if v15:sub(1, 4) == "else" then
					v7 = v7:sub(5)
					v8 = "    "
				elseif v15:sub(1, 3) == "end" then
					v7 = v7:sub(5)
				elseif (v15:sub(1, 2) == "if" or v15:sub(1, 5) == "while" or v15:sub(1, 3) == "for" or v15:find(
					"function",
					1,
					true
				)) and v15:sub(-3) ~= "end" then
					v8 = "    "
				else
					v8 = ""
				end
			end

			local v18 = v15:gsub("%w+", v3):gsub("%b\"\"", "<font color=\"" .. v5 .. "\">%1</font>"):gsub(
				"%w+%(",
				"<font color=\"" .. v6 .. "\">%1</font>"
			)

			if v17 then
				v18 ..= v17
			end

			if p then
				v14 = string.format("%4d", v9) .. "   " .. v7 .. v18 .. "\n"
				v9 += 1
			else
				v14 = v7 .. v18 .. "\n"
			end

			if k == p3 then
				v12 = #v7 - #v10
			end
		end

		v11 ..= v14
	end

	if #v11 > 3 and v11:sub(-2) == " \n" then
		return v11:sub(1, -3), v12
	end

	return v11, v12
end

return ColorizeSourceModule