local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local textBox = parent.Entry.TextBox
local textLabel = parent.Entry.TextLabel
local UserInputService = game:GetService("UserInputService")
local preview = textBox.Preview
local remote = parent.remote
local v = {}
local clones = {}
local v2 = {}
local v3 = false
local fn = nil
local v4 = {}
local v5 = 1
local textLabel2 = Instance.new("TextLabel")
textLabel2.Size = UDim2.new(0, 2000, 0, 200)
textLabel2.Visible = false
textLabel2.Parent = parent.Parent
textLabel2.TextTransparency = 1

-- equivalent calls inferred from this helper; original call sites unknown
local function addToHistory(value)
	if value:match("^%s*$") then
		return
	end

	local v6 = v4[#v4]
	local v7 = v4[v5]
	local v8 = not v7 or value ~= v7

	if v6 ~= value and v8 then
		local v9 = v5 == #v4
		table.insert(v4, value)

		if v9 then
			v5 = #v4 + 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateInputFromHistory(p)
	v5 = math.clamp(v5 + p, 1, #v4 + 1)

	if v5 <= #v4 then
		textBox.Text = v4[v5]
	else
		textBox.Text = ""
	end

	textBox.CursorPosition = #textBox.Text + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function textWidth(text, p)
	textLabel2.Font = p.Font
	textLabel2.TextSize = p.TextSize
	textLabel2.TextWrapped = false
	textLabel2.Text = text
	return textLabel2.TextBounds.X
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerCommand(p)
	v[p.command] = p
end

local function matchCommand(part)
	local lower = part:split(" ")[1]:lower()

	if part:match("^%s*$") then
		return
	end

	for k, v6 in pairs(v) do
		if k:lower():sub(1, #lower) == lower then
			return k, v6
		end
	end
end

local function fn2(p)
	local v6 = {}

	for _, v7 in pairs(clones) do
		if v7.Parent then
			table.insert(v6, v7)
		end
	end

	clones = v6
	local v7 = math.clamp(#clones, 0, 10)
	local _ = #clones < 10
	parent.Size = UDim2.new(0.95, 0, 0, v7 * 20 + 40)
	parent.Position = UDim2.new(0.025, 0, 1, -parent.Size.Y.Offset - 25)

	if not p then
		parent.CanvasPosition = Vector2.new(0, 2000000000)
	end
end

local function escapeRichText(value)
	return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&#39;"))
end

local v6 = {}
local total = 0
local v7 = nil

for i = 1, 30 do
	v6[i] = ("!@#$%^&*()_+-={}[]/?;:,.'\"\\|~`"):sub(i, i)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rand()
	return v6[math.random(1, #v6)]
end

local function shortname(part, fill)
	local lower = part:lower()

	if fill then
		for _, fill2 in ipairs(fill) do
			if fill2:lower():sub(1, #lower) == lower then
				return {
					Fill = fill2
				}, "Fill"
			end
		end
	else
		local Players = game:GetService("Players")

		for _, v8 in ipairs(Players:GetPlayers()) do
			if v8.Name:lower():sub(1, #lower) == lower then
				return v8, "Name"
			end

			if v8.DisplayName:lower():sub(1, #lower) == lower then
				return v8, "DisplayName"
			end
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stripRichText(text)
	return text:gsub("<[^>]->", "")
end

local function maskOnce(value, value2, value3)
	if not value:match("^login%s") then
		return value
	end

	local v8 = value2 or 3
	local _, v10 = value:match("^(%S+)%s+(%S+)")

	if not v10 then
		return value
	end

	local total2 = 0

	for i = 1, #v10 do
		total2 += string.byte(v10, i) * i
	end

	local v11 = v8 + total2 % ((value3 or 8) - v8 + 1)
	return value:gsub("^(%S+)%s+%S+", "%1 " .. "<font color=\"rgb(0,0,0)\">" .. string.rep("█", v11) .. "</font>", 1)
end

local v8 = nil

local function fn3()
	textBox.Text = textBox.Text:gsub("%c", "")

	if textBox.Text == "" then
		v5 = #v4 + 1
	end

	local text = textBox.Text
	local parts = text:split(" ")
	local part = parts[1]
	local text2, v10 = matchCommand(part)

	for _, v11 in pairs(v2) do
		v11.Visible = false
	end

	preview.Text = ""

	if not text2 or #text == 0 then
		return
	end

	local color = Color3.fromRGB(255, 73, 73)
	local v11 = {}

	if part == text2 then
		color = Color3.fromRGB(255, 255, 255)
		fn = nil

		for i, argument in ipairs(v10.arguments) do
			local arg = argument.arg
			local part2 = parts[i + 1]

			if part2 and #part2 > 0 then
				arg = part2
			end

			if (argument.player or argument.fill) and part2 and #part2 > 0 then
				local parts2 = part2:split(",")
				local v12 = {}

				for k, part3 in pairs(parts2) do
					if typeof(argument.fill) == "string" then
						local HttpService = game:GetService("HttpService")
						argument.fill = HttpService:JSONDecode(argument.fill)
					end

					local v14, v15 = shortname(part3, argument.fill)
					table.insert(v12, part3)

					if not (v14 and v14[v15] ~= part3 and v14) then
						continue
					end

					local v16 = v14[v15]

					if v15 == "DisplayName" then
						v16 ..= (" (@%s)"):format(v14.Name)
					end

					parts2[k] = v16
					arg = table.concat(parts2, ",")
					local v17 = v15
					local v18 = v14

					fn = function()
						local v19 = stripRichText(preview.Text) -- equivalent call inferred; original call site unknown

						if v17 == "DisplayName" then
							local match = v19:match(v18.DisplayName .. "%s*%(@([^%)]+)%)")

							if match then
								v19 = v19:gsub(v18.DisplayName .. "%s*%(@[^%)]+%)", match)
							end
						end

						local parts3 = v19:split(" ")
						local parts4 = {}

						for k2, part4 in pairs(parts3) do
							if k2 <= #parts then
								table.insert(parts4, part4)
							end
						end

						local joined = table.concat(parts4, " ")
						local RunService = game:GetService("RunService")
						RunService.RenderStepped:Wait()
						textBox.Text = joined
					end

					break
				end
			end

			if argument.censored then
				v11[i + 1] = true
			end

			text2 ..= " " .. arg
		end
	else
		fn = function()
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
			textBox.Text = text2
		end
	end

	for i, part2 in ipairs(parts) do
		if not v11[i] then
			continue
		end

		if not v2[i] then
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BorderSizePixel = 0
			frame.ZIndex = 9999
			frame.Parent = parent.Parent
			v2[i] = frame
		end

		local v12 = v2[i]
		local v14 = textWidth(table.concat(parts, " ", 1, i - 1), textBox) -- equivalent call inferred; original call site unknown
		local v16 = textWidth("W", textBox) -- equivalent call inferred; original call site unknown
		local v18 = textWidth(part2, textBox) -- equivalent call inferred; original call site unknown
		local v19 = textBox.AbsolutePosition.X + v14 + v16
		local Y = textBox.AbsolutePosition.Y
		v12.Position = UDim2.fromOffset(v19, Y)
		v12.Size = UDim2.fromOffset(v18, textBox.AbsoluteSize.Y)
		v12.Visible = true

		if v8 then
			continue
		end

		local renderSteppedConnection = nil
		local RunService = game:GetService("RunService")
		local v20 = v12
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if v20.Visible and v20.Parent then
				parent.ScrollingEnabled = false
				parent.CanvasPosition = Vector2.new(0, 150000)
			else
				v8 = nil
				parent.ScrollingEnabled = true
				return renderSteppedConnection:Disconnect()
			end
		end)
		v8 = renderSteppedConnection
	end

	local v12 = #text
	local v13 = text2:sub(1, v12)
	local v14 = #text + 1
	local v15 = text2:sub(v14)
	preview.Text = string.format("<font transparency=\"1\">%s</font>%s", escapeRichText(v13), v15)
	textBox.TextColor3 = color
end

local function hackerWrite(p, value)
	local text = p.Text
	local v9 = math.max(#text, #value)

	if #text < v9 then
		text ..= string.rep(" ", v9 - #text)
	end

	if #value < v9 then
		value ..= string.rep(" ", v9 - #value)
	end

	for i = 1, v9 do
		local v10 = value:sub(i, i)

		if text:sub(i, i) == v10 then
			continue
		end

		for _ = 1, 3 do
			p.Text = text:sub(1, i - 1) .. rand() .. text:sub(i + 1)
			task.wait(0.01)
		end

		text = text:sub(1, i - 1) .. v10 .. text:sub(i + 1)
		p.Text = text
	end
end

local function fn4()
	task.spawn(function()
		for _, v9 in pairs(remote:InvokeServer("_GETCOMMANDS")) do
			registerCommand(v9) -- equivalent call inferred; original call site unknown
		end

		v.login = nil
	end)
	task.spawn(function()
		local v9 = { "cmd" }
		hackerWrite(textLabel, string.format("server@%s:~#", v9[#v9]))
	end)
end

local fn5

fn5 = function(data)
	local text = data.text
	local type = data.type

	if data.ratelimit and v3 then
		return
	end

	if type == "clear" then
		for _, v9 in pairs(clones) do
			v9:Destroy()
		end

		table.clear(clones)
		total = 0
		textBox.Text = ""
		return fn2()
	else
		if data.clear then
			textBox.Text = ""
		end

		if data.granted then
			fn4()
		elseif type == "displaycmds" then
			for _, v9 in pairs(v) do
				local v10 = ""

				for _, v11 in ipairs(v9.arguments or {}) do
					v10 ..= string.format(" <font color=\"rgb(58, 153, 255)\">[%s]</font>", v11.arg)
				end

				fn5({
					text = "<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>" .. string.format(
						"%s %s",
						v9.command,
						v10
					),
					type = "white"
				})
			end

			fn2()
			return
		end

		local clone = script.Line:Clone()

		for i = #clones, 1, -1 do
			if text == "help" or data.dropdown then
				break
			end

			local v9 = clones[i]

			if v9.Text:find("<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>") then
				if i == #clones and (text == v9.Text or text == v9:GetAttribute("OG")) then
					local OG = v9:GetAttribute("OG")
					local count = v9:GetAttribute("Count")

					if not OG then
						v9:SetAttribute("OG", v9.Text)
						v9:SetAttribute("Count", 2)
						OG = v9.Text
						count = 2
					end

					v9.Text = OG .. (" <font size=\"10\">x%s</font>"):format(count)
					clone:Destroy()
					fn2()
					v9:SetAttribute("Count", count + 1)
					return
				end
			else
				if type ~= "white" or text ~= v9.Text then
					break
				end

				clone:Destroy()
				fn2()
				return
			end
		end

		local v9 = {}
		clone:GetPropertyChangedSignal("CursorPosition"):Connect(function()
			local cursorPosition = clone.CursorPosition
			local outputted = clone:GetAttribute("outputted") or text

			if cursorPosition == -1 then
				local count = clone:GetAttribute("Count")

				if count then
					outputted ..= (" <font size=\"10\">x%s</font>"):format(count)
				end

				clone.Text = outputted

				for k, v10 in pairs(v9) do
					local v11 = v10
					task.spawn(function()
						local RunService = game:GetService("RunService")
						RunService.Heartbeat:Wait()
						v11:Destroy()
						fn2(true)
					end)
					v9[k] = nil
				end
			else
				clone.Text = outputted:gsub("<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>", ""):gsub(
					"<[^>]->",
					""
				)

				if data.dropdown or not data.command or v9["<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>Convert"] or not v.kill then
					return
				end

				for _, v11 in pairs({
					{
						text = "<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>Convert",
						type = "blue",
						dropdown = {
							line = clone,
							callback = function()
								local tool = Instance.new("Tool")
								tool.Name = clone.Text
								tool.RequiresHandle = false
								tool.CanBeDropped = false
								tool:SetAttribute("Special", true)
								tool.Parent = localPlayer.Backpack
								tool.Activated:Connect(function()
									shared.enterCommand(nil, tool.Name)
								end)
							end
						}
					}
				}) do
					local v12 = fn5(v11)
					table.insert(v9, v12)
					v9[v11.text] = v12
				end
			end
		end)

		if data.dropdown then
			local textButton = Instance.new("TextButton")
			textButton.Parent = clone
			textButton.Size = UDim2.new(1, 0, 1, 0)
			textButton.BackgroundTransparency = 1
			textButton.Text = ""
			textButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					data.dropdown.callback()
				end
			end)
			textButton.ZIndex = clone.ZIndex + 1
		end

		clone.Text = text

		if type == "blue" then
			clone.TextColor3 = Color3.fromRGB(58, 153, 255)
		elseif type == "yellow" then
			clone.TextColor3 = Color3.fromRGB(255, 228, 26)
		elseif type == "white" then
			if text:find("<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>") then
				clone.TextColor3 = Color3.fromRGB(200, 200, 200)
			else
				clone.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end

		if type == "blue" and text == "<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>..." then
			task.spawn(function()
				v7 = clone
				local v10 = 1
				v3 = true

				repeat
					clone.Text = "<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>" .. string.rep(
						".",
						v10
					)
					local v11 = v10 + 1
					v10 = v11 > 3 and 1 or v11
					task.wait(0.33)
				until not clone.Parent or localPlayer.PlayerGui:FindFirstChild("authorizeddd")

				v3 = false
			end)
		end

		if data.followingWait and v7 then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(v7, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextColor3 = clone.TextColor3
			}):Play()
			hackerWrite(v7, text)
			v7:SetAttribute("outputted", text)
			v7 = nil
			return clone:Destroy()
		else
			if text:find("<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>") then
				total += 1
			else
				total += 25
			end

			clone.LayoutOrder = data.dropdown and data.dropdown.line.LayoutOrder + 1 or total
			table.insert(clones, clone)
			clone.Parent = parent

			if not data.dropdown then
				fn2()
			end

			return clone
		end
	end
end

for _, v9 in pairs(remote:InvokeServer("_GETCOMMANDS")) do
	registerCommand(v9) -- equivalent call inferred; original call site unknown
end

if v.kill then
	task.spawn(fn4)
end

function shared.enterCommand(p, p2)
	local v9 = p2 or textBox.Text
	task.spawn(function()
		if not p then
			return
		end

		wait()
		textBox:CaptureFocus()
	end)

	if v9:match("^%s*$") or v3 then
		return
	end

	local text = maskOnce(v9)

	if v9 ~= "clear" then
		fn5({
			text = text,
			command = true,
			type = "white"
		})
	end

	addToHistory(text:match("^login%s") and "login" or text) -- equivalent call inferred; original call site unknown
	local v12 = remote:InvokeServer(v9)

	if v12 == "#NONEED" then
		return
	end

	v12.text = "<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>" .. v12.text
	fn5(v12)
end

textBox:GetPropertyChangedSignal("Text"):Connect(fn3)
textBox.FocusLost:Connect(function(p)
	if p then
		shared.enterCommand(true)
	end
end)
local v9 = nil
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F2 then
		parent.Visible = not parent.Visible

		if parent.Visible then
			textBox.Text = ""
			textBox:CaptureFocus()
		else
			for _, v10 in pairs(v2) do
				v10.Visible = false
			end

			textBox:ReleaseFocus()
		end
	elseif input.KeyCode == Enum.KeyCode.T and parent.Visible and not gameProcessed then
		textBox.Text = ""
		textBox:CaptureFocus()
	elseif textBox:IsFocused() and (input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down) then
		local v10 = math.random(1, 2000000000)
		v9 = v10
		local v11 = input.KeyCode == Enum.KeyCode.Up and -1 or 1
		updateInputFromHistory(v11) -- equivalent call inferred; original call site unknown
		task.wait(0.25)

		if v9 ~= v10 then
			return
		end

		while UserInputService:IsKeyDown(input.KeyCode) do
			updateInputFromHistory(v11) -- equivalent call inferred; original call site unknown
			task.wait(0.1)
		end
	end

	if not gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Tab then
		local v10 = fn

		if textBox:IsFocused() and v10 then
			v10()
			textBox.CursorPosition = 2000000000
		end
	end
end)

remote.OnClientInvoke = function(...)
	local v10 = ({ ... })[1]

	if v10.arrow then
		v10.text = "<font family=\"rbxasset://fonts/families/Guru.json\">  ↳  </font>" .. v10.text
	end

	return fn5(v10)
end