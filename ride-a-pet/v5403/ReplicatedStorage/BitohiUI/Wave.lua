local TextService = game:GetService("TextService")
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Wave = {
	Defaults = {
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
}
local v = {
	["&amp;"] = "&",
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&quot;"] = "\"",
	["&apos;"] = "'"
}

local function parseRichText(text, richText)
	local result = {}

	if richText then
		local v2 = 1
		local v3 = {}

		while v2 <= #text do
			local v4 = text:sub(v2, v2)

			if v4 == "<" then
				local v5 = text:find(">", v2, true)

				if not v5 then
					break
				end

				local v6 = text:sub(v2 + 1, v5 - 1)

				if v6:sub(1, 1) == "/" then
					local v7 = table.remove(v3)

					if v7 and v7.isFont and #v7.indices == 1 then
						result[v7.indices[1]].wavy = true
					end
				elseif v6:sub(-1) ~= "/" then
					local isFont = v6:lower():match("^font") ~= nil
					local color = nil

					if isFont then
						local v9 = v6:match("color%s*=%s*\"([^\"]+)\"") or v6:match("color%s*=%s*'([^']+)'")

						if v9 then
							local success, result2 = pcall(Color3.fromHex, v9)
							color = success and result2 or nil
						end
					end

					v3[#v3 + 1] = {
						isFont = isFont,
						color = color,
						indices = {}
					}
				end

				v2 = v5 + 1
			else
				local char = nil

				if v4 == "&" then
					local v6 = text:find(";", v2, true)
					local v7

					if v6 then
						if v6 - v2 <= 6 then
							v7 = text:sub(v2, v6)
						else
							v7 = false
						end
					else
						v7 = v6
					end

					if v7 and v[v7] then
						char = v[v7]
						v2 = v6 + 1
					end
				end

				if not char then
					local v6 = utf8.offset(text, 2, v2) or v2 + 1
					char = text:sub(v2, v6 - 1)
					v2 = v6
				end

				local color = nil

				for i = #v3, 1, -1 do
					if not v3[i].color then
						continue
					end

					color = v3[i].color
					break
				end

				result[#result + 1] = {
					char = char,
					color = color
				}

				for i = 1, #v3 do
					local indices = v3[i].indices
					indices[#indices + 1] = #result
				end
			end
		end

		return result
	else
		for _, v2 in utf8.codes(text) do
			result[#result + 1] = {
				char = utf8.char(v2)
			}
		end

		return result
	end
end

function Wave:attach(options)
	assert(self:IsA("TextLabel") or self:IsA("TextButton"), "Wave.attach: needs a text label")
	local object = setmetatable(options or {}, {
		__index = Wave.Defaults
	})
	local v2 = {}
	local uIStroke = self:FindFirstChildOfClass("UIStroke")
	local text = self.Text
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.RichText = false
	local textBoundsAsyncs = {}

	local function measure(text2, size, value)
		if text2 == "" then
			return Vector2.zero
		end

		local v3 = string.format("%d|%d|%s", size, value or 0, text2)
		local v4 = textBoundsAsyncs[v3]

		if v4 then
			return v4
		end

		getTextBoundsParams.Font = self.FontFace
		getTextBoundsParams.Text = text2
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = value or 0
		local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

		if not success then
			return Vector2.zero
		end

		textBoundsAsyncs[v3] = textBoundsAsync
		return textBoundsAsync
	end

	local function fitFontSize(text2, absoluteSize)
		if not self.TextScaled then
			return self.TextSize
		end

		local minFontSize = object.MinFontSize
		local maxFontSize = object.MaxFontSize
		local minFontSize2 = object.MinFontSize

		while minFontSize <= maxFontSize do
			local size = math.floor((minFontSize + maxFontSize) / 2)
			local v4 = measure(text2, size, math.floor(absoluteSize.X))

			if v4.X <= absoluteSize.X and v4.Y <= absoluteSize.Y then
				minFontSize = size + 1
				minFontSize2 = size
			else
				maxFontSize = size - 1
			end
		end

		return minFontSize2
	end

	local frame = nil
	local v3 = {}
	local clones = {}
	local v4 = {}
	local flag = false
	local count = 0
	local X = 0
	local v5 = 0
	local v6 = 0

	local function syncSize(p)
		if X <= 0 or #v3 == 0 then
			return
		end

		local v7 = self.AbsoluteSize.X / X

		if v7 <= 0 or not p and math.abs(v7 - v6) < object.RescaleThreshold then
			return
		end

		v6 = v7
		local textSize = math.max(1, v5 * v7)

		for _, v9 in ipairs(v3) do
			v9.TextSize = textSize
		end

		for _, v9 in ipairs(clones) do
			v9.Thickness = v9:GetAttribute("BaseThickness") * v7
		end
	end

	local function syncTransparency()
		for _, v7 in ipairs(v3) do
			v7.TextTransparency = self.TextTransparency
		end

		if uIStroke then
			for _, v7 in ipairs(clones) do
				v7.Transparency = uIStroke.Transparency
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearBuild()
		table.clear(v3)
		table.clear(clones)
		table.clear(v4)

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
		local v7 = count
		local absoluteSize = self.AbsoluteSize

		if absoluteSize.X < 1 or absoluteSize.Y < 1 then
			flag = false
			return
		end

		local v8 = parseRichText(text, self.RichText)

		if #v8 == 0 then
			flag = false
			return
		end

		if object.WaveEveryCharacter then
			for _, v9 in ipairs(v8) do
				v9.wavy = true
			end
		end

		local v9 = ""

		for _, v10 in ipairs(v8) do
			v9 ..= v10.char
		end

		local v10 = fitFontSize(v9, absoluteSize)
		local v11 = nil
		local v12 = {}

		for _, v13 in ipairs(v8) do
			if v13.char == " " then
				v11 = nil
			else
				if not v11 then
					v11 = {
						entries = {},
						text = ""
					}
					v12[#v12 + 1] = v11
				end

				v11.entries[#v11.entries + 1] = v13
				v11.text ..= v13.char
			end
		end

		for _, v13 in ipairs(v12) do
			v13.width = measure(v13.text, v10).X
		end

		local v13 = string.format("%d|%d|%s", v10, 0, "i i")
		local textBoundsAsync = textBoundsAsyncs[v13]

		if not textBoundsAsync then
			getTextBoundsParams.Font = self.FontFace
			getTextBoundsParams.Text = "i i"
			getTextBoundsParams.Size = v10
			getTextBoundsParams.Width = 0
			local success
			success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

			if success then
				textBoundsAsyncs[v13] = textBoundsAsync
			else
				textBoundsAsync = Vector2.zero
			end
		end

		local X2 = textBoundsAsync.X
		local v14 = string.format("%d|%d|%s", v10, 0, "ii")
		local textBoundsAsync2 = textBoundsAsyncs[v14]

		if not textBoundsAsync2 then
			getTextBoundsParams.Font = self.FontFace
			getTextBoundsParams.Text = "ii"
			getTextBoundsParams.Size = v10
			getTextBoundsParams.Width = 0
			local success
			success, textBoundsAsync2 = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

			if success then
				textBoundsAsyncs[v14] = textBoundsAsync2
			else
				textBoundsAsync2 = Vector2.zero
			end
		end

		local v15 = X2 - textBoundsAsync2.X

		if v15 <= 0 then
			v15 = v10 * 0.28
		end

		local v16 = nil
		local v17 = {}

		for _, v18 in ipairs(v12) do
			if v16 then
				local width = v16.width + v15 + v18.width

				if width <= absoluteSize.X then
					v16.words[#v16.words + 1] = v18
					v16.width = width
					continue
				end
			end

			v16 = {
				words = { v18 },
				width = v18.width
			}
			v17[#v17 + 1] = v16
		end

		if v7 ~= count then
			flag = false
			return
		end

		clearBuild() -- equivalent call inferred; original call site unknown
		frame = Instance.new("Frame")
		frame.Name = "WaveCharacters"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.ZIndex = self.ZIndex
		frame.Parent = self
		local v18 = v10 * self.LineHeight
		local v19 = v18 * #v17
		local v20

		if self.TextYAlignment == Enum.TextYAlignment.Top then
			v20 = 0
		elseif self.TextYAlignment == Enum.TextYAlignment.Bottom then
			v20 = absoluteSize.Y - v19
		else
			v20 = (absoluteSize.Y - v19) * 0.5
		end

		local v21 = v10 * 0.6
		local count2 = 0

		for i, v22 in ipairs(v17) do
			local v23 = v20 + (i - 0.5) * v18
			local v24

			if self.TextXAlignment == Enum.TextXAlignment.Left then
				v24 = 0
			elseif self.TextXAlignment == Enum.TextXAlignment.Right then
				v24 = absoluteSize.X - v22.width
			else
				v24 = (absoluteSize.X - v22.width) * 0.5
			end

			for i2, word in ipairs(v22.words) do
				local v25 = ""
				local v26 = 0

				for _, entry in ipairs(word.entries) do
					v25 ..= entry.char
					local X3 = measure(v25, v10).X
					local v27 = X3 - v26
					local v28 = v24 + v26 + v27 * 0.5
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = "Char"
					textLabel.BackgroundTransparency = 1
					textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					textLabel.Position = UDim2.fromScale(v28 / absoluteSize.X, v23 / absoluteSize.Y)
					textLabel.Size = UDim2.fromScale((v27 + v21 * 2) / absoluteSize.X, v18 * 2 / absoluteSize.Y)
					textLabel.ZIndex = self.ZIndex
					textLabel.FontFace = self.FontFace
					textLabel.Text = entry.char
					textLabel.RichText = false
					textLabel.TextScaled = false
					textLabel.TextWrapped = false
					textLabel.TextSize = v10
					textLabel.TextColor3 = entry.color or self.TextColor3
					textLabel.TextTransparency = self.TextTransparency
					textLabel.TextStrokeTransparency = self.TextStrokeTransparency
					textLabel.TextStrokeColor3 = self.TextStrokeColor3
					textLabel.TextXAlignment = Enum.TextXAlignment.Center
					textLabel.TextYAlignment = Enum.TextYAlignment.Center
					textLabel.Parent = frame

					if uIStroke and uIStroke.Thickness >= object.MinStrokeThickness then
						local clone = uIStroke:Clone()
						clone:SetAttribute("BaseThickness", uIStroke.Thickness)
						clone.Parent = textLabel
						clones[#clones + 1] = clone
					end

					v3[#v3 + 1] = textLabel

					if entry.wavy then
						count2 += 1
						local uIScale = Instance.new("UIScale")
						uIScale.Parent = textLabel
						v4[#v4 + 1] = {
							label = textLabel,
							scale = uIScale,
							order = count2,
							x = v28 / absoluteSize.X,
							y = v23 / absoluteSize.Y
						}
					end

					v26 = X3
				end

				if i2 < #v22.words then
					v24 += word.width + v15
				end
			end
		end

		X = absoluteSize.X
		v5 = v10
		syncSize(true)
		self.MaxVisibleGraphemes = 0
		flag = false
	end

	local total = 0

	local function step(p)
		if #v4 == 0 then
			return
		end

		total += p
		local v7 = object.WaveAmplitude * v4[1].label.TextSize

		for _, v8 in ipairs(v4) do
			local v9 = total * object.WaveSpeed - v8.order * object.WavePhase
			local v10 = math.sin(v9)
			v8.label.Position = UDim2.new(v8.x, 0, v8.y, -v10 * v7)
			v8.label.Rotation = math.cos(v9) * object.WaveRotation
			v8.scale.Scale = 1 + math.max(v10, 0) * object.WaveScale
		end
	end

	local function park()
		for _, v7 in ipairs(v4) do
			v7.label.Position = UDim2.fromScale(v7.x, v7.y)
			v7.label.Rotation = 0
			v7.scale.Scale = 1
		end
	end

	local whileVisible = Ticker.whileVisible(self, step, 0, park)
	local connections = {}
	local flag2 = false
	local v7 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function queueRebuild()
		if flag2 then
			return
		end

		flag2 = true
		task.delay(object.RebuildDebounce, function()
			flag2 = false

			if v2.alive then
				build()
			end
		end)
	end

	connections[#connections + 1] = self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if #v3 == 0 then
			queueRebuild() -- equivalent call inferred; original call site unknown
		else
			syncSize()

			if not v7 then
				v7 = true
				task.delay(object.RebuildDebounce, function()
					v7 = false
					syncSize(true)
				end)
			end
		end
	end)
	connections[#connections + 1] = self:GetPropertyChangedSignal("FontFace"):Connect(queueRebuild)
	connections[#connections + 1] = self:GetPropertyChangedSignal("TextTransparency"):Connect(syncTransparency)

	if uIStroke then
		connections[#connections + 1] = uIStroke:GetPropertyChangedSignal("Transparency"):Connect(syncTransparency)
	end

	connections[#connections + 1] = self:GetPropertyChangedSignal("Text"):Connect(function()
		if self.Text ~= "" then
			text = self.Text
			textBoundsAsyncs = {}
			queueRebuild() -- equivalent call inferred; original call site unknown
		end
	end)
	v2.alive = true

	function v2.Rebuild(_)
		textBoundsAsyncs = {}
		build()
	end

	function v2.Stop(p)
		p.alive = false
		whileVisible:Stop()

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		clearBuild() -- equivalent call inferred; original call site unknown
		self.MaxVisibleGraphemes = -1
	end

	task.spawn(build)
	return v2
end

return Wave