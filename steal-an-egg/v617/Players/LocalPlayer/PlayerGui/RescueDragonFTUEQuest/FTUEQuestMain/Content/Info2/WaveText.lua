local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local v = {
	WaveAmplitude = 0.16,
	WaveSpeed = 5,
	WavePhase = 0.85,
	WaveRotation = 8,
	WaveScale = 0.1,
	WaveEveryCharacter = false,
	MinFontSize = 6,
	MaxFontSize = 100,
	RebuildDebounce = 0.1,
	RescaleThreshold = 0.04,
	MinStrokeThickness = 0.5
}
local parent = script.Parent
assert(parent:IsA("TextLabel") or parent:IsA("TextButton"), "WaveText must be parented to a text label")
local uIStroke = parent:FindFirstChildOfClass("UIStroke")
local text = parent.Text
local v2 = {
	["&amp;"] = "&",
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&quot;"] = "\"",
	["&apos;"] = "'"
}

local function parseRichText(text2, richText)
	local result = {}

	if richText then
		local v3 = 1
		local v4 = {}

		while v3 <= #text2 do
			local v5 = text2:sub(v3, v3)

			if v5 == "<" then
				local v6 = text2:find(">", v3, true)

				if not v6 then
					break
				end

				local v7 = text2:sub(v3 + 1, v6 - 1)

				if v7:sub(1, 1) == "/" then
					local v8 = table.remove(v4)

					if v8 and v8.isFont and #v8.indices == 1 then
						result[v8.indices[1]].wavy = true
					end
				elseif v7:sub(-1) ~= "/" then
					local isFont = v7:lower():match("^font") ~= nil
					local color = nil

					if isFont then
						local v10 = v7:match("color%s*=%s*\"([^\"]+)\"") or v7:match("color%s*=%s*'([^']+)'")

						if v10 then
							local success, result2 = pcall(Color3.fromHex, v10)
							color = success and result2 or nil
						end
					end

					v4[#v4 + 1] = {
						isFont = isFont,
						color = color,
						indices = {}
					}
				end

				v3 = v6 + 1
			else
				local char = nil

				if v5 == "&" then
					local v7 = text2:find(";", v3, true)
					local v8

					if v7 then
						if v7 - v3 <= 6 then
							v8 = text2:sub(v3, v7)
						else
							v8 = false
						end
					else
						v8 = v7
					end

					if v8 and v2[v8] then
						char = v2[v8]
						v3 = v7 + 1
					end
				end

				if not char then
					local v7 = utf8.offset(text2, 2, v3) or v3 + 1
					char = text2:sub(v3, v7 - 1)
					v3 = v7
				end

				local color = nil

				for i = #v4, 1, -1 do
					if not v4[i].color then
						continue
					end

					color = v4[i].color
					break
				end

				result[#result + 1] = {
					char = char,
					color = color
				}

				for i = 1, #v4 do
					local indices = v4[i].indices
					indices[#indices + 1] = #result
				end
			end
		end

		return result
	else
		for _, v3 in utf8.codes(text2) do
			result[#result + 1] = {
				char = utf8.char(v3)
			}
		end

		return result
	end
end

local getTextBoundsParams = Instance.new("GetTextBoundsParams")
getTextBoundsParams.RichText = false
local v3 = {}

local function measure(text2, size, value)
	if text2 == "" then
		return Vector2.zero
	end

	local v4 = string.format("%d|%d|%s", size, value or 0, text2)
	local v5 = v3[v4]

	if v5 then
		return v5
	end

	getTextBoundsParams.Font = parent.FontFace
	getTextBoundsParams.Text = text2
	getTextBoundsParams.Size = size
	getTextBoundsParams.Width = value or 0
	local success, result = pcall(function()
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)

	if not success then
		return Vector2.zero
	end

	v3[v4] = result
	return result
end

local function fitFontSize(text2, absoluteSize)
	if not parent.TextScaled then
		return parent.TextSize
	end

	local v4 = 6
	local v5 = 100
	local v6 = 6

	while v4 <= v5 do
		local size = math.floor((v4 + v5) / 2)
		local v8 = measure(text2, size, math.floor(absoluteSize.X))

		if v8.X <= absoluteSize.X and v8.Y <= absoluteSize.Y then
			v4 = size + 1
			v6 = size
		else
			v5 = size - 1
		end
	end

	return v6
end

local frame = nil
local v4 = {}
local clones = {}
local v5 = {}
local flag = false
local count = 0
local X = 0
local v6 = 0
local v7 = 0

local function syncSize(p)
	if X <= 0 or #v4 == 0 then
		return
	end

	local v8 = parent.AbsoluteSize.X / X

	if v8 <= 0 or not p and math.abs(v8 - v7) < 0.04 then
		return
	end

	v7 = v8
	local textSize = math.max(1, v6 * v8)

	for _, v10 in ipairs(v4) do
		v10.TextSize = textSize
	end

	for _, v10 in ipairs(clones) do
		v10.Thickness = v10:GetAttribute("BaseThickness") * v8
	end
end

local function syncTransparency()
	for _, v8 in ipairs(v4) do
		v8.TextTransparency = parent.TextTransparency
	end

	if uIStroke then
		for _, v8 in ipairs(clones) do
			v8.Transparency = uIStroke.Transparency
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearBuild()
	table.clear(v4)
	table.clear(clones)
	table.clear(v5)

	if frame then
		frame:Destroy()
		frame = nil
	end
end

local function build()
	if flag then
		return
	end

	flag = true
	count += 1
	local v8 = count
	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		flag = false
		return
	end

	local v9 = parseRichText(text, parent.RichText)

	if #v9 == 0 then
		flag = false
		return
	end

	local v10 = ""

	for _, v11 in ipairs(v9) do
		v10 ..= v11.char
	end

	local textSize = fitFontSize(v10, absoluteSize)
	local v12 = nil
	local v13 = {}

	for _, v14 in ipairs(v9) do
		if v14.char == " " then
			v12 = nil
		else
			if not v12 then
				v12 = {
					entries = {},
					text = ""
				}
				v13[#v13 + 1] = v12
			end

			v12.entries[#v12.entries + 1] = v14
			v12.text ..= v14.char
		end
	end

	for _, v14 in ipairs(v13) do
		v14.width = measure(v14.text, textSize).X
	end

	local v14 = measure("i i", textSize).X - measure("ii", textSize).X

	if v14 <= 0 then
		v14 = textSize * 0.28
	end

	local v15 = nil
	local v16 = {}

	for _, v17 in ipairs(v13) do
		if v15 then
			local width = v15.width + v14 + v17.width

			if width <= absoluteSize.X then
				v15.words[#v15.words + 1] = v17
				v15.width = width
				continue
			end
		end

		v15 = {
			words = { v17 },
			width = v17.width
		}
		v16[#v16 + 1] = v15
	end

	if v8 ~= count then
		flag = false
		return
	end

	clearBuild() -- equivalent call inferred; original call site unknown
	frame = Instance.new("Frame")
	frame.Name = "WaveCharacters"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = parent.ZIndex
	frame.Parent = parent
	local v17 = textSize * parent.LineHeight
	local v18 = v17 * #v16
	local v19

	if parent.TextYAlignment == Enum.TextYAlignment.Top then
		v19 = 0
	elseif parent.TextYAlignment == Enum.TextYAlignment.Bottom then
		v19 = absoluteSize.Y - v18
	else
		v19 = (absoluteSize.Y - v18) * 0.5
	end

	local v20 = textSize * 0.6
	local count2 = 0

	for i, v21 in ipairs(v16) do
		local v22 = v19 + (i - 0.5) * v17
		local v23

		if parent.TextXAlignment == Enum.TextXAlignment.Left then
			v23 = 0
		elseif parent.TextXAlignment == Enum.TextXAlignment.Right then
			v23 = absoluteSize.X - v21.width
		else
			v23 = (absoluteSize.X - v21.width) * 0.5
		end

		for i2, word in ipairs(v21.words) do
			local v24 = ""
			local v25 = 0

			for _, entry in ipairs(word.entries) do
				v24 ..= entry.char
				local X2 = measure(v24, textSize).X
				local v26 = X2 - v25
				local v27 = v23 + v25 + v26 * 0.5
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "Char"
				textLabel.BackgroundTransparency = 1
				textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				textLabel.Position = UDim2.fromScale(v27 / absoluteSize.X, v22 / absoluteSize.Y)
				textLabel.Size = UDim2.fromScale((v26 + v20 * 2) / absoluteSize.X, v17 * 2 / absoluteSize.Y)
				textLabel.ZIndex = parent.ZIndex
				textLabel.FontFace = parent.FontFace
				textLabel.Text = entry.char
				textLabel.RichText = false
				textLabel.TextScaled = false
				textLabel.TextWrapped = false
				textLabel.TextSize = textSize
				textLabel.TextColor3 = entry.color or parent.TextColor3
				textLabel.TextTransparency = parent.TextTransparency
				textLabel.TextStrokeTransparency = parent.TextStrokeTransparency
				textLabel.TextStrokeColor3 = parent.TextStrokeColor3
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.Parent = frame

				if uIStroke and uIStroke.Thickness >= 0.5 then
					local clone = uIStroke:Clone()
					clone:SetAttribute("BaseThickness", uIStroke.Thickness)
					clone.Parent = textLabel
					clones[#clones + 1] = clone
				end

				v4[#v4 + 1] = textLabel

				if entry.wavy then
					count2 += 1
					local uIScale = Instance.new("UIScale")
					uIScale.Parent = textLabel
					v5[#v5 + 1] = {
						label = textLabel,
						scale = uIScale,
						order = count2,
						x = v27 / absoluteSize.X,
						y = v22 / absoluteSize.Y
					}
				end

				v25 = X2
			end

			if i2 < #v21.words then
				v23 += word.width + v14
			end
		end
	end

	X = absoluteSize.X
	v6 = textSize
	syncSize(true)
	parent.MaxVisibleGraphemes = 0
	flag = false
end

local total = 0

local function step(p)
	if #v5 == 0 then
		return
	end

	total += p
	local v8 = 0.16 * v5[1].label.TextSize

	for _, v9 in ipairs(v5) do
		local v10 = total * 5 - v9.order * 0.85
		local v11 = math.sin(v10)
		v9.label.Position = UDim2.new(v9.x, 0, v9.y, -v11 * v8)
		v9.label.Rotation = math.cos(v10) * 8
		v9.scale.Scale = 1 + math.max(v11, 0) * 0.1
	end
end

local function park()
	for _, v8 in ipairs(v5) do
		v8.label.Position = UDim2.fromScale(v8.x, v8.y)
		v8.label.Rotation = 0
		v8.scale.Scale = 1
	end
end

local v8 = false
local renderSteppedConnection = nil
local connections = {}

local function computeShown()
	local parent2 = parent

	while parent2 do
		if parent2:IsA("GuiObject") then
			if not parent2.Visible then
				return false
			end
		elseif parent2:IsA("LayerCollector") then
			return parent2.Enabled
		end

		parent2 = parent2.Parent
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshShown()
	local v9 = computeShown()

	if v9 == v8 then
		return
	end

	v8 = v9

	if v8 then
		if not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(step)
		end
	elseif renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
		park()
	end
end

local function watchAncestors()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
	local parent2 = parent

	while parent2 do
		if parent2:IsA("GuiObject") then
			connections[#connections + 1] = parent2:GetPropertyChangedSignal("Visible"):Connect(refreshShown)
		elseif parent2:IsA("LayerCollector") then
			connections[#connections + 1] = parent2:GetPropertyChangedSignal("Enabled"):Connect(refreshShown)
			break
		end

		parent2 = parent2.Parent
	end

	refreshShown() -- equivalent call inferred; original call site unknown
end

local flag2 = false

local function queueRebuild()
	if flag2 then
		return
	end

	flag2 = true
	task.delay(0.1, function()
		flag2 = false
		build()
	end)
end

local v9 = false
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if #v4 == 0 then
		if flag2 then
			return
		end

		flag2 = true
		task.delay(v.RebuildDebounce, function()
			flag2 = false
			build()
		end)
	else
		syncSize()

		if not v9 then
			v9 = true
			task.delay(0.1, function()
				v9 = false
				syncSize(true)
			end)
		end
	end
end)
parent:GetPropertyChangedSignal("FontFace"):Connect(queueRebuild)
parent:GetPropertyChangedSignal("TextTransparency"):Connect(syncTransparency)

if uIStroke then
	uIStroke:GetPropertyChangedSignal("Transparency"):Connect(syncTransparency)
end

parent:GetPropertyChangedSignal("Text"):Connect(function()
	if parent.Text ~= "" then
		text = parent.Text
		v3 = {}

		if flag2 then
			return
		end

		flag2 = true
		task.delay(v.RebuildDebounce, function()
			flag2 = false
			build()
		end)
	end
end)
parent.AncestryChanged:Connect(watchAncestors)
watchAncestors()
task.spawn(build)