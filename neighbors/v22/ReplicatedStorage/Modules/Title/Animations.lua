local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("StarterPlayer")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local Text = require(ReplicatedStorage.Modules.Text)
local Particle2D = require(ReplicatedStorage.Modules.Particle2D)
local SpriteSheet = require(ReplicatedStorage.Modules.SpriteSheet)

local function sampleColorSequence(sequence, p: number)
	local keypoints = sequence.Keypoints

	if p <= keypoints[1].Time then
		return keypoints[1].Value
	end

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (p < keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value:Lerp(keypoint2.Value, v)
	end

	return keypoints[#keypoints].Value
end

local function sliceColorSequence(color, p: number, p2: number)
	local colorSequenceKeypoints = { ColorSequenceKeypoint.new(0, sampleColorSequence(color, p)) }

	for _, keypoint in color.Keypoints do
		if p < keypoint.Time and keypoint.Time < p2 then
			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new((keypoint.Time - p) / (p2 - p), keypoint.Value)
			)
		end
	end

	table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, sampleColorSequence(color, p2)))
	return ColorSequence.new(colorSequenceKeypoints)
end

local function splitTitleCharacters(instance, maid)
	local title = instance:FindFirstChild("Title", true)
	local v = string.match(title.Text, "<b>") ~= nil
	local v2 = string.gsub(title.Text, "<[^<>]->", "")
	local fontFace = title.FontFace

	if v then
		fontFace = Font.new(fontFace.Family, Enum.FontWeight.Bold, fontFace.Style)
	end

	local frame = Instance.new("Frame")
	frame.Name = "CharacterContainer"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = title
	local result = {}
	local clones = {}
	local textTransparency = title.TextTransparency
	local v3 = false
	maid:Add(task.spawn(function()
		if v2 == "" then
			return
		end

		local zero = Vector2.zero
		local zero2 = Vector2.zero
		local v4 = 0

		while v4 < 3 do
			local absoluteSize = frame.AbsoluteSize
			local textBounds = title.TextBounds
			v4 = not (absoluteSize.X >= 1 and textBounds.Y >= 1 and (absoluteSize - zero).Magnitude < 0.5 and (textBounds - zero2).Magnitude < 0.5) and 0 or v4 + 1
			task.wait()
			zero2 = textBounds
			zero = absoluteSize
		end

		local parent = title
		local v5 = 1

		while parent and parent ~= game do
			for _, uIScale in parent:GetChildren() do
				if uIScale:IsA("UIScale") then
					v5 *= uIScale.Scale
				end
			end

			parent = parent.Parent
		end

		local v6 = math.max(v5, 0.01)
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 1 / v6
		uIScale.Parent = frame
		frame.Size = UDim2.fromScale(v6, v6)
		task.wait()
		local absoluteSize = title.AbsoluteSize
		maid:Add(title:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if absoluteSize.X >= 1 and absoluteSize.Y >= 1 then
				local v7 = title.AbsoluteSize.X / absoluteSize.X
				local v8 = title.AbsoluteSize.Y / absoluteSize.Y
				local v9 = math.min(v7, v8)
				uIScale.Scale = v9 / v6
				frame.Position = UDim2.fromOffset(
					absoluteSize.X * (v7 - v9) / (v6 * 2),
					absoluteSize.Y * (v8 - v9) / (v6 * 2)
				)
			end
		end))
		local v7 = title.TextBounds.Y * v6
		local size = math.clamp(math.floor((math.min(v7, title.AbsoluteSize.Y))), 1, 100)
		local v9 = title.TextStrokeTransparency < 1
		local v10 = {
			Font = fontFace,
			Size = size,
			Color = title.TextColor3,
			StrokeSize = 0,
			StrokeColor = 0,
			StrokeTransparency = 0,
			XAlignment = 0,
			YAlignment = 0
		}
		local strokeSize

		if v9 then
			strokeSize = math.clamp(math.floor(size / 20), 1, 3)
		end

		v10.StrokeSize = strokeSize
		local strokeColor

		if v9 then
			strokeColor = title.TextStrokeColor3
		end

		v10.StrokeColor = strokeColor
		local strokeTransparency

		if v9 then
			strokeTransparency = title.TextStrokeTransparency
		end

		v10.StrokeTransparency = strokeTransparency
		v10.XAlignment = title.TextXAlignment.Name
		v10.YAlignment = title.TextYAlignment.Name
		Text.Create(frame, v2, v10)
		local v14 = 1e999
		local v15 = -1e999

		for _, v16 in Text.GetCharacters(frame) do
			v14 = math.min(v14, v16.Position.X.Offset)
			v15 = math.max(v15, v16.Position.X.Offset + v16.Size.X.Offset)
		end

		local v16 = v15 - v14
		local v17 = math.min(title.AbsoluteSize.X, title.TextBounds.X * v6 * 1.1)

		if v17 < v16 then
			size = math.max(math.floor(size * v17 / v16), 1)
			v10.Size = size
			Text.Create(frame, v2, v10)
		end

		v3 = true

		for _, label in Text.GetCharacters(frame) do
			table.insert(result, {
				Label = label,
				BasePosition = label.Position,
				Size = size
			})
		end

		local titleGradient = title:FindFirstChild("TitleGradient")

		if titleGradient and titleGradient:IsA("UIGradient") and #result > 0 then
			local v18 = 1e999
			local v19 = -1e999

			for _, v20 in result do
				local offset = v20.BasePosition.X.Offset
				v18 = math.min(v18, offset)
				v19 = math.max(v19, offset + v20.Label.Size.X.Offset)
			end

			local v20 = math.max(v19 - v18, 1)
			local v21 = titleGradient.Rotation % 180 == 0

			for _, v22 in result do
				local clone = titleGradient:Clone()

				if v21 then
					local offset = v22.BasePosition.X.Offset
					clone.Color = sliceColorSequence(
						titleGradient.Color,
						(offset - v18) / v20,
						(offset + v22.Label.Size.X.Offset - v18) / v20
					)
				end

				clone.Parent = v22.Label
				table.insert(clones, clone)
			end
		end

		title.TextTransparency = 1
	end))
	maid:Add(function()
		title.TextTransparency = textTransparency

		for _, v4 in clones do
			v4:Destroy()
		end

		if v3 and frame:IsDescendantOf(game) then
			Text.Create(frame, "")
		end

		frame:Destroy()
	end)
	return result, frame
end

local v = {
	DualColor = function(instance, data)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local tween = TweenService:Create(title, data.TweenInfo, {
			TextColor3 = data.Color1
		})
		local tween2 = TweenService:Create(title, data.TweenInfo, {
			TextColor3 = data.Color2
		})
		maid:Add(function()
			tween:Cancel()
			tween2:Cancel()
			tween:Destroy()
			tween2:Destroy()
		end)
		title.TextColor3 = data.TextColor
		tween2:Play()
		tween2.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				tween:Play()
			end
		end)
		tween.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				tween2:Play()
			end
		end)
		return maid
	end,
	TriColor = function(instance, data)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local tween = TweenService:Create(title, data.TweenInfo, {
			TextColor3 = data.Color1
		})
		local tween2 = TweenService:Create(title, data.TweenInfo, {
			TextColor3 = data.Color2
		})
		local tween3 = TweenService:Create(title, data.TweenInfo, {
			TextColor3 = data.Color3
		})
		local v2 = false
		maid:Add(function()
			tween:Cancel()
			tween2:Cancel()
			tween3:Cancel()
			tween:Destroy()
			tween2:Destroy()
			tween3:Destroy()
		end)
		title.TextColor3 = data.TextColor
		tween2:Play()
		tween2.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				if v2 == false then
					tween:Play()
				else
					v2 = false
					tween3:Play()
				end
			end
		end)
		tween3.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				tween2:Play()
			end
		end)
		tween.Completed:Connect(function(p)
			if p == Enum.PlaybackState.Completed then
				v2 = true
				tween2:Play()
			end
		end)
		return maid
	end,
	Wave = function(instance, value: number?)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local v2 = string.match(title.Text, "<b>")
		local v3 = string.gsub(title.Text, "<b>", ""):gsub("</b>", "")
		local v4 = string.len(v3)
		local total = 0
		local v5 = {}

		for _ = 1, v4 do
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 20
			local tween = TweenService:Create(
				numberValue,
				TweenInfo.new(value or 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{
					Value = 28
				}
			)
			maid:Add(task.delay(total, function()
				tween:Play()
			end))
			maid:Add(numberValue)
			local v7 = tween
			maid:Add(function()
				v7:Cancel()
				v7:Destroy()
			end)
			table.insert(v5, numberValue)
			total += 0.1
		end

		if v2 then
			local fontFace = title.FontFace
			fontFace.Bold = true
			title.FontFace = fontFace
		end

		maid:Add(function()
			table.clear(v5)
		end)
		maid:Add(task.spawn(function()
			while true do
				local text = ""

				for i = 1, v4 do
					local v7 = v3:sub(i, i)
					text ..= `<font size="{math.floor(v5[i].Value)}">{v7}</font>`
				end

				title.Text = text
				task.wait(0.05)
			end
		end))
		return maid
	end,
	Riot = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local text = title.Text
		local v2 = {}
		local color = Color3.fromRGB(39, 12, 0)
		local color2 = Color3.fromRGB(255, 200, 100)
		local color3 = Color3.fromRGB(255, 170, 0)
		local color4 = Color3.fromRGB(255, 85, 0)

		if instance.Parent:IsA("BillboardGui") then
			instance.Parent.Brightness = 10
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function colorToHex(currentColor: Color3)
			local v3 = math.floor(currentColor.R * 255)
			local v4 = math.floor(currentColor.G * 255)
			local v5 = math.floor(currentColor.B * 255)
			return (string.format("%02X%02X%02X", v3, v4, v5))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function lerpFireColors(p)
			if p < 0.5 then
				return (color4:Lerp(color3, p * 2))
			end

			return (color3:Lerp(color2, (p - 0.5) * 2))
		end

		local function updateTextLabel()
			local text2 = ""

			for i = 1, #text do
				local v4 = string.sub(text, i, i)
				local v5 = colorToHex(v2[i].CurrentColor) -- equivalent call inferred; original call site unknown

				if v4 == " " then
					text2 ..= " "
				else
					text2 ..= `<font color="#{v5}"><b>{v4}</b></font>`
				end
			end

			title.Text = text2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function igniteCharacter(p: number)
			if v2[p].IsAnimating then
				return
			end

			v2[p].IsAnimating = true
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.4 do
					local v3 = (tick() - lastTime) / 0.4
					local v4 = v2[p]
					local currentColor = lerpFireColors(v3) -- equivalent call inferred; original call site unknown
					v4.CurrentColor = currentColor
					task.wait()
				end

				local lastTime2 = tick()

				while tick() - lastTime2 < 0.6 do
					local v3 = (tick() - lastTime2) / 0.6
					v2[p].CurrentColor = color2:Lerp(color, v3)
					task.wait()
				end

				v2[p].CurrentColor = color
				v2[p].IsAnimating = false
			end)
		end

		local function triggerFireWave()
			local v3 = {}

			for i = 1, #text do
				if string.sub(text, i, i) ~= " " then
					table.insert(v3, i)
				end
			end

			local v4 = {}

			for _ = 1, math.min(3, #v3) do
				local v5 = math.random(1, #v3)
				table.insert(v4, v3[v5])
				table.remove(v3, v5)
			end

			for _, v5 in v4 do
				igniteCharacter(v5) -- equivalent call inferred; original call site unknown
				task.wait(0.075)
			end
		end

		for i = 1, #text do
			v2[i] = {
				CurrentColor = color,
				IsAnimating = false
			}
		end

		title.Text = text
		maid:Add(task.spawn(function()
			while true do
				triggerFireWave()
				task.wait(0.25)
			end
		end))
		maid:Add(task.spawn(function()
			while true do
				updateTextLabel()
				task.wait()
			end
		end))
		return maid
	end,
	["Head Moderator"] = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local text = title.Text
		local v2 = {}
		local color = Color3.fromRGB(7, 7, 18)
		local color2 = Color3.fromRGB(89, 92, 255)
		local color3 = Color3.fromRGB(180, 119, 255)
		local color4 = Color3.fromRGB(128, 64, 255)

		if instance.Parent:IsA("BillboardGui") then
			instance.Parent.Brightness = 10
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function colorToHex(currentColor: Color3)
			local v3 = math.floor(currentColor.R * 255)
			local v4 = math.floor(currentColor.G * 255)
			local v5 = math.floor(currentColor.B * 255)
			return (string.format("%02X%02X%02X", v3, v4, v5))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function lerpFireColors(p)
			if p < 0.5 then
				return (color4:Lerp(color3, p * 2))
			end

			return (color3:Lerp(color2, (p - 0.5) * 2))
		end

		local function updateTextLabel()
			local text2 = ""

			for i = 1, #text do
				local v4 = string.sub(text, i, i)
				local v5 = colorToHex(v2[i].CurrentColor) -- equivalent call inferred; original call site unknown

				if v4 == " " then
					text2 ..= " "
				else
					text2 ..= `<font color="#{v5}"><b>{v4}</b></font>`
				end
			end

			title.Text = text2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function igniteCharacter(p: number)
			if v2[p].IsAnimating then
				return
			end

			v2[p].IsAnimating = true
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.4 do
					local v3 = (tick() - lastTime) / 0.4
					local v4 = v2[p]
					local currentColor = lerpFireColors(v3) -- equivalent call inferred; original call site unknown
					v4.CurrentColor = currentColor
					task.wait()
				end

				local lastTime2 = tick()

				while tick() - lastTime2 < 0.6 do
					local v3 = (tick() - lastTime2) / 0.6
					v2[p].CurrentColor = color2:Lerp(color, v3)
					task.wait()
				end

				v2[p].CurrentColor = color
				v2[p].IsAnimating = false
			end)
		end

		local function triggerFireWave()
			local v3 = {}

			for i = 1, #text do
				if string.sub(text, i, i) ~= " " then
					table.insert(v3, i)
				end
			end

			local v4 = {}

			for _ = 1, math.min(3, #v3) do
				local v5 = math.random(1, #v3)
				table.insert(v4, v3[v5])
				table.remove(v3, v5)
			end

			for _, v5 in v4 do
				igniteCharacter(v5) -- equivalent call inferred; original call site unknown
				task.wait(0.075)
			end
		end

		for i = 1, #text do
			v2[i] = {
				CurrentColor = color,
				IsAnimating = false
			}
		end

		title.Text = text
		maid:Add(task.spawn(function()
			while true do
				triggerFireWave()
				task.wait(0.25)
			end
		end))
		maid:Add(task.spawn(function()
			while true do
				updateTextLabel()
				task.wait()
			end
		end))
		return maid
	end,
	Hearthkeeper = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local text = title.Text
		local v2 = {}
		print(title.Text)
		local color = Color3.fromRGB(39, 12, 0)
		local color2 = Color3.fromRGB(247, 230, 196)
		local color3 = Color3.fromRGB(212, 106, 45)
		local color4 = Color3.fromRGB(91, 60, 41)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function colorToHex(currentColor: Color3)
			local v3 = math.floor(currentColor.R * 255)
			local v4 = math.floor(currentColor.G * 255)
			local v5 = math.floor(currentColor.B * 255)
			return (string.format("%02X%02X%02X", v3, v4, v5))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function lerpFireColors(p)
			if p < 0.5 then
				return (color4:Lerp(color3, p * 2))
			end

			return (color3:Lerp(color2, (p - 0.5) * 2))
		end

		local function updateTextLabel()
			local text2 = ""

			for i = 1, #text do
				local v4 = string.sub(text, i, i)
				local v5 = colorToHex(v2[i].CurrentColor) -- equivalent call inferred; original call site unknown

				if v4 == " " then
					text2 ..= " "
				else
					text2 ..= `<font color="#{v5}"><b>{v4}</b></font>`
				end
			end

			title.Text = text2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function igniteCharacter(p: number)
			if v2[p].IsAnimating then
				return
			end

			v2[p].IsAnimating = true
			task.spawn(function()
				local lastTime = tick()

				while tick() - lastTime < 0.4 do
					local v3 = (tick() - lastTime) / 0.4
					local v4 = v2[p]
					local currentColor = lerpFireColors(v3) -- equivalent call inferred; original call site unknown
					v4.CurrentColor = currentColor
					task.wait()
				end

				local lastTime2 = tick()

				while tick() - lastTime2 < 0.6 do
					local v3 = (tick() - lastTime2) / 0.6
					v2[p].CurrentColor = color2:Lerp(color, v3)
					task.wait()
				end

				v2[p].CurrentColor = color
				v2[p].IsAnimating = false
			end)
		end

		local function triggerFireWave()
			local v3 = {}

			for i = 1, #text do
				if string.sub(text, i, i) ~= " " then
					table.insert(v3, i)
				end
			end

			local v4 = {}

			for _ = 1, math.min(3, #v3) do
				local v5 = math.random(1, #v3)
				table.insert(v4, v3[v5])
				table.remove(v3, v5)
			end

			for _, v5 in v4 do
				igniteCharacter(v5) -- equivalent call inferred; original call site unknown
				task.wait(0.075)
			end
		end

		for i = 1, #text do
			v2[i] = {
				CurrentColor = color,
				IsAnimating = false
			}
		end

		title.Text = text
		maid:Add(task.spawn(function()
			while true do
				triggerFireWave()
				task.wait(0.5)
			end
		end))
		maid:Add(task.spawn(function()
			while true do
				updateTextLabel()
				task.wait()
			end
		end))
		return maid
	end,
	TypeWave = function(instance)
		local v2 = {}
		local v3 = {}
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local text = title.Text
		local v4 = string.len(text)

		if title:FindFirstChild("Gradient") then
			title.Gradient:Destroy()
		end

		for i = 1, v4 do
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 1
			v2[i] = numberValue
			local numberValue2 = Instance.new("NumberValue")
			numberValue2.Value = 0
			v3[i] = numberValue2
			maid:Add(numberValue)
			maid:Add(numberValue2)
		end

		maid:Add(function()
			table.clear(v2)
			table.clear(v3)
		end)
		maid:Add(task.spawn(function()
			while true do
				for i = 1, v4 do
					local tween = TweenService:Create(
						v2[i],
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Value = 0
						}
					)
					tween:Play()
					maid:Add(function()
						tween:Cancel()
						tween:Destroy()
					end)
					task.wait(0.08)
				end

				task.wait(1.5)

				for i = 1, v4 do
					local tween = TweenService:Create(
						v3[i],
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Value = 1
						}
					)
					tween:Play()
					maid:Add(function()
						tween:Cancel()
						tween:Destroy()
					end)
					task.wait(0.08)
				end

				task.wait(1)

				for i = 1, v4 do
					v2[i].Value = 1
					v3[i].Value = 0
				end
			end
		end))
		maid:Add(task.spawn(function()
			while true do
				local text2 = ""

				for i = 1, v4 do
					local v6 = text:sub(i, i)
					local v7 = math.clamp(v2[i].Value + v3[i].Value, 0, 1)
					text2 ..= `<stroke color="#000000" thickness="1" transparency="{v7}"><font transparency="{v7}">{v6}</font></stroke>`
				end

				title.Text = text2
				RunService.RenderStepped:Wait()
			end
		end))
		return maid
	end,
	Explosion = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local tweens = {}

		local function clearTweens()
			for _, v3 in tweens do
				v3:Cancel()
				v3:Destroy()
			end

			table.clear(tweens)
		end

		maid:Add(clearTweens)
		maid:Add(task.spawn(function()
			while true do
				task.wait(1.25)

				for _, v3 in v2 do
					local v4 = math.random() * 3.141592653589793 * 2
					local v5 = v3.Size * (1.5 + math.random() * 2)
					local tween = TweenService:Create(
						v3.Label,
						TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
						{
							Position = v3.BasePosition + UDim2.fromOffset(math.cos(v4) * v5, math.sin(v4) * v5),
							Rotation = math.random(-160, 160),
							TextTransparency = 0.6
						}
					)
					table.insert(tweens, tween)
					tween:Play()
				end

				task.wait(0.85)

				for _, v3 in v2 do
					local tween = TweenService:Create(
						v3.Label,
						TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Position = v3.BasePosition,
							Rotation = 0,
							TextTransparency = 0
						}
					)
					table.insert(tweens, tween)
					tween:Play()
				end

				task.wait(0.55)
				clearTweens()
			end
		end))
		return maid
	end,
	Float = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v3 in v2 do
				local v4 = now * 2 + k * 0.7
				v3.Label.Position = v3.BasePosition + UDim2.fromOffset(
					math.sin(v4) * v3.Size * 0.08,
					math.cos(v4 * 1.3) * v3.Size * 0.18
				)
				v3.Label.Rotation = math.sin(v4 * 0.8) * 6
			end
		end))
		return maid
	end,
	Shockwave = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() * 8 % (#v2 + 6) - 3

			for k, v4 in v2 do
				local v5 = math.max(0, 1 - math.abs(k - v3) / 2.5)
				local v6 = v5 * v5
				local v7 = math.clamp((k - v3) / 2.5, -1, 1)
				v4.Label.Position = v4.BasePosition - UDim2.fromOffset(0, v6 * v4.Size * 0.45)
				v4.Label.Rotation = v7 * v6 * 20
			end
		end))
		return maid
	end,
	Glitch = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local v3 = { Color3.fromRGB(85, 255, 255), Color3.fromRGB(255, 85, 200) }
		maid:Add(task.spawn(function()
			while true do
				task.wait(0.1 + math.random() * 0.4)
				local v4 = v2[1]

				if not v4 then
					continue
				end

				local textColor3 = v4.Label.TextColor3
				local v5 = {}

				for _, v6 in v2 do
					if not (math.random() < 0.35) then
						continue
					end

					table.insert(v5, v6)
					v6.Label.Position = v6.BasePosition + UDim2.fromOffset(
						(math.random() - 0.5) * v6.Size * 0.5,
						(math.random() - 0.5) * v6.Size * 0.4
					)
					v6.Label.TextColor3 = v3[math.random(#v3)]
				end

				task.wait(0.06)

				for _, v6 in v5 do
					v6.Label.Position = v6.BasePosition
					v6.Label.TextColor3 = textColor3
				end
			end
		end))
		return maid
	end,
	Vibrate = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			for _, v3 in v2 do
				v3.Label.Position = v3.BasePosition + UDim2.fromOffset(
					(math.random() - 0.5) * v3.Size * 0.12,
					(math.random() - 0.5) * v3.Size * 0.12
				)
				v3.Label.Rotation = (math.random() - 0.5) * 8
			end
		end))
		return maid
	end,
	Spin = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() * 6 % (#v2 + 8) - 4

			for k, v4 in v2 do
				local v5 = math.clamp((v3 - k) / 4 + 0.5, 0, 1)
				v4.Label.Rotation = v5 * 360
			end
		end))
		return maid
	end,
	Bounce = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local v3 = {}
		maid:Add(task.spawn(function()
			while true do
				task.wait(0.1 + math.random() * 0.25)

				if not (#v2 > 0) then
					continue
				end

				local v4 = v2[math.random(#v2)]

				if not v3[v4] then
					v3[v4] = os.clock()
				end
			end
		end))
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v4 in v3 do
				local v5 = (now - v4) / 0.6

				if v5 >= 1 then
					v3[k] = nil
					k.Label.Position = k.BasePosition
				else
					local v6 = 4 * v5 * (1 - v5)
					k.Label.Position = k.BasePosition - UDim2.fromOffset(0, v6 * k.Size * 0.6)
				end
			end
		end))
		return maid
	end,
	Scramble = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local tweens = {}

		local function clearTweens()
			for _, v3 in tweens do
				v3:Cancel()
				v3:Destroy()
			end

			table.clear(tweens)
		end

		maid:Add(clearTweens)
		maid:Add(task.spawn(function()
			while true do
				task.wait(2)

				if #v2 < 2 then
					continue
				end

				local clone = table.clone(v2)

				for i = #clone, 2, -1 do
					local v3 = math.random(i)
					local v4 = clone[v3]
					local v5 = clone[i]
					clone[i] = v4
					clone[v3] = v5
				end

				for k, v3 in v2 do
					local tween = TweenService:Create(
						v3.Label,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Position = clone[k].BasePosition
						}
					)
					table.insert(tweens, tween)
					tween:Play()
				end

				task.wait(1.2)

				for _, v3 in v2 do
					local tween = TweenService:Create(
						v3.Label,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Position = v3.BasePosition
						}
					)
					table.insert(tweens, tween)
					tween:Play()
				end

				task.wait(0.45)
				clearTweens()
			end
		end))
		return maid
	end,
	Swing = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v3 in v2 do
				local v4 = now * 2.4 + k * 0.45
				v3.Label.Rotation = math.sin(v4) * 14
				v3.Label.Position = v3.BasePosition + UDim2.fromOffset(math.sin(v4) * v3.Size * 0.05, 0)
			end
		end))
		return maid
	end,
	Cascade = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local tweens = {}

		local function clearTweens()
			for _, v3 in tweens do
				v3:Cancel()
				v3:Destroy()
			end

			table.clear(tweens)
		end

		maid:Add(clearTweens)
		maid:Add(task.spawn(function()
			while true do
				task.wait(1.6)

				for _, v3 in v2 do
					local tween = TweenService:Create(
						v3.Label,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Position = v3.BasePosition + UDim2.fromOffset(0, v3.Size * 1.4),
							TextTransparency = 1
						}
					)
					table.insert(tweens, tween)
					tween:Play()
					task.wait(0.05)
				end

				task.wait(0.5)

				for _, v3 in v2 do
					v3.Label.Position = v3.BasePosition - UDim2.fromOffset(0, v3.Size * 1.4)
					v3.Label.TextTransparency = 0
					local tween = TweenService:Create(
						v3.Label,
						TweenInfo.new(0.35, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							Position = v3.BasePosition
						}
					)
					table.insert(tweens, tween)
					tween:Play()
					task.wait(0.05)
				end

				task.wait(0.6)
				clearTweens()
			end
		end))
		return maid
	end,
	Tornado = function(p)
		local maid = Janitor.new()
		local v2, parent = splitTitleCharacters(p, maid)
		local v4 = nil
		maid:Add(task.spawn(function()
			while #v2 == 0 do
				task.wait()
			end

			local size = v2[1].Size
			local v5 = Particle2D.new()
			v5.Texture = "rbxasset://textures/particles/smoke_main.dds"
			v5.Color = Color3.fromRGB(180, 180, 180)
			v5.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, size * 0.5),
				NumberSequenceKeypoint.new(1, size * 1.1)
			})
			v5.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.35),
				NumberSequenceKeypoint.new(1, 1)
			})
			v5.ZOffset = 0
			v5.EmissionDirection = "Right"
			v5.SpreadAngle = 25
			v5.Speed = NumberRange.new(40, 80)
			v5.RotSpeed = NumberRange.new(-200, 200)
			v5.Acceleration = Vector2.new(0, -20)
			v5.Lifetime = NumberRange.new(0.5, 0.8)
			v5.Rate = 30
			v5.Enabled = false
			v5.Parent = parent
			v5:Bind("RenderStepped")
			maid:Add(v5, "Destroy")
			v4 = v5
		end))
		local v5 = false
		local v6 = 0
		local v7 = 0
		local v8 = 0
		maid:Add(RunService.Heartbeat:Connect(function()
			local count = #v2

			if count == 0 then
				return
			end

			if not v5 then
				v5 = true
				local v9 = 1e999
				local v10 = -1e999
				local v11 = 1e999
				local v12 = -1e999

				for _, v13 in v2 do
					local offset = v13.BasePosition.X.Offset
					local offset2 = v13.BasePosition.Y.Offset
					v9 = math.min(v9, offset)
					v10 = math.max(v10, offset + v13.Label.Size.X.Offset)
					v11 = math.min(v11, offset2)
					v12 = math.max(v12, offset2 + v13.Size)
				end

				v6 = (v9 + v10) / 2
				v7 = (v11 + v12) / 2
				v8 = (v10 - v9) / 2 * 0.8 + v2[1].Size * 0.5
			end

			local now = os.clock()
			local v9 = now % 6 / 6
			local v10

			if v9 < 0.15 then
				v10 = 0
			elseif v9 < 0.3 then
				v10 = (v9 - 0.15) / 0.15
			else
				v10 = v9 < 0.75 and 1 or not (v9 < 0.9) and 0 or 1 - (v9 - 0.75) / 0.15
			end

			local v11 = v10 * v10 * (3 - 2 * v10)

			if v4 then
				v4.Enabled = v11 > 0.2
			end

			for k, v12 in v2 do
				local v13 = now * 5 + k * (6.283185307179586 / count)
				local uDim = UDim2.fromOffset(
					v6 + math.cos(v13) * v8 - v12.Label.Size.X.Offset / 2,
					v7 + math.sin(v13) * v12.Size * 0.7 - v12.Size / 2
				)
				v12.Label.Position = v12.BasePosition:Lerp(uDim, v11)
				v12.Label.Rotation = v11 * math.cos(v13) * 20
			end
		end))
		return maid
	end,
	Heartbeat = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)

		local function bump(p2: number, p3: number, p4: number)
			if p2 < p3 or p3 + p4 < p2 then
				return 0
			end

			return (math.sin((p2 - p3) / p4 * 3.141592653589793))
		end

		local textColor3s = {}
		local color = Color3.fromRGB(255, 64, 64)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() % 1.2
			local v4 = ((v3 < 0 or v3 > 0.16) and 0 or math.sin((v3 - 0) / 0.16 * 3.141592653589793)) + ((v3 < 0.24 or v3 > 0.4) and 0 or math.sin((v3 - 0.24) / 0.16 * 3.141592653589793)) * 0.85
			local v5 = v4 * 0.45 + 1

			for _, v6 in v2 do
				local textColor3 = textColor3s[v6]

				if not textColor3 then
					textColor3 = v6.Label.TextColor3
					textColor3s[v6] = textColor3
				end

				local offset = v6.Label.Size.X.Offset
				v6.Label.TextSize = math.min(v6.Size * v5, 100)
				v6.Label.Position = v6.BasePosition - UDim2.fromOffset(offset * (v5 - 1) / 2, v6.Size * (v5 - 1) / 2)
				v6.Label.TextColor3 = textColor3:Lerp(color, v4 * 0.6)
			end
		end))
		return maid
	end,
	Flag = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local count = #v2

			if count == 0 then
				return
			end

			local now = os.clock()

			for k, v3 in v2 do
				local v4 = now * 5 - k * 0.65
				local v5 = v3.Size * 0.28 * (k / count)
				v3.Label.Position = v3.BasePosition + UDim2.fromOffset(0, math.sin(v4) * v5)
				v3.Label.Rotation = math.cos(v4) * 10 * (k / count)
			end
		end))
		return maid
	end,
	Accordion = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local v3 = false
		local v4 = 0
		maid:Add(RunService.Heartbeat:Connect(function()
			if #v2 == 0 then
				return
			end

			if not v3 then
				v3 = true
				local v5 = 1e999
				local v6 = -1e999

				for _, v7 in v2 do
					local offset = v7.BasePosition.X.Offset
					v5 = math.min(v5, offset)
					v6 = math.max(v6, offset + v7.Label.Size.X.Offset)
				end

				v4 = (v5 + v6) / 2
			end

			local v5 = (math.sin(os.clock() * 2.1) + 1) / 2 * 0.55 + -0.12

			for _, v6 in v2 do
				local v7 = v6.BasePosition.X.Offset + v6.Label.Size.X.Offset / 2
				v6.Label.Position = v6.BasePosition + UDim2.fromOffset((v7 - v4) * v5, 0)
			end
		end))
		return maid
	end,
	Firework = function(p)
		local maid = Janitor.new()
		local v2, parent = splitTitleCharacters(p, maid)
		local v4 = {}
		local v5 = {}
		local v6 = nil
		local v7 = nil
		maid:Add(task.spawn(function()
			while #v2 == 0 do
				task.wait()
			end

			local size = v2[1].Size
			local frame = Instance.new("Frame")
			frame.Name = "BurstPoint"
			frame.BackgroundTransparency = 1
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.Size = UDim2.fromOffset(1, 1)
			frame.Parent = parent
			local v8 = Particle2D.new()
			v8.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 170, 60))
			v8.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, size * 0.45),
				NumberSequenceKeypoint.new(1, 0)
			})
			v8.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.7, 0.15),
				NumberSequenceKeypoint.new(1, 1)
			})
			v8.ZOffset = 2
			v8.EmissionDirection = "Top"
			v8.SpreadAngle = 180
			v8.Speed = NumberRange.new(30, 80)
			v8.Drag = 2
			v8.Acceleration = Vector2.new(0, 90)
			v8.RotSpeed = NumberRange.new(-180, 180)
			v8.Lifetime = NumberRange.new(0.35, 0.7)
			v8.Enabled = false
			v8.Parent = frame
			v8:Bind("RenderStepped")
			maid:Add(frame)
			maid:Add(v8, "Destroy")
			v7 = frame
			v6 = v8
		end))
		maid:Add(task.spawn(function()
			while true do
				task.wait(0.9 + math.random() * 1.2)

				if not (#v2 > 0) then
					continue
				end

				local v8 = v2[math.random(#v2)]

				if not v4[v8] then
					v4[v8] = os.clock()
				end
			end
		end))
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v8 in v4 do
				local v9 = (now - v8) / 1.1
				local label = k.Label

				if v9 >= 1 then
					v4[k] = nil
					v5[k] = nil
					label.Position = k.BasePosition
					label.Rotation = 0
					label.TextTransparency = 0
				elseif v9 < 0.45 then
					local v10 = v9 / 0.45
					local v11 = 1 - (1 - v10) * (1 - v10)
					label.Position = k.BasePosition - UDim2.fromOffset(0, v11 * k.Size * 2.2)
					label.Rotation = v10 * 540
					label.TextTransparency = math.clamp((v10 - 0.6) / 0.4, 0, 1)
				elseif v9 < 0.7 then
					if v6 and v7 and not v5[k] then
						v5[k] = true
						v7.Position = UDim2.fromOffset(
							k.BasePosition.X.Offset + label.Size.X.Offset / 2,
							k.BasePosition.Y.Offset + k.Size / 2 - k.Size * 2.2
						)
						v6:Emit(12)
					end

					label.Position = k.BasePosition
					label.Rotation = 0
					label.TextTransparency = 1
				else
					label.TextTransparency = 1 - (v9 - 0.7) / 0.3
				end
			end
		end))
		return maid
	end,
	Sparkle = function(p)
		local maid = Janitor.new()
		local v2, parent = splitTitleCharacters(p, maid)
		maid:Add(task.spawn(function()
			while #v2 == 0 do
				task.wait()
			end

			local size = v2[1].Size
			local v4 = Particle2D.new()
			v4.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 230, 120))
			v4.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.4, size * 0.45),
				NumberSequenceKeypoint.new(1, 0)
			})
			v4.Transparency = 0.15
			v4.ZOffset = 2
			v4.EmissionDirection = "Top"
			v4.SpreadAngle = 40
			v4.Speed = NumberRange.new(2, 8)
			v4.RotSpeed = NumberRange.new(-90, 90)
			v4.Lifetime = NumberRange.new(0.5, 0.9)
			v4.Rate = 8
			v4.Parent = parent
			v4:Bind("RenderStepped")
			maid:Add(v4, "Destroy")
		end))
		local v4 = {}
		local textColor3s = {}
		local color = Color3.fromRGB(255, 255, 255)
		maid:Add(task.spawn(function()
			while true do
				task.wait(0.12 + math.random() * 0.25)

				if not (#v2 > 0) then
					continue
				end

				local v5 = v2[math.random(#v2)]

				if not v4[v5] then
					v4[v5] = os.clock()
				end
			end
		end))
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v5 in v4 do
				local v6 = (now - v5) / 0.5
				local label = k.Label
				local textColor3 = textColor3s[k]

				if not textColor3 then
					textColor3 = label.TextColor3
					textColor3s[k] = textColor3
				end

				if v6 >= 1 then
					v4[k] = nil
					label.TextSize = k.Size
					label.Position = k.BasePosition
					label.TextColor3 = textColor3
				else
					local v7 = math.sin(v6 * 3.141592653589793)
					local v8 = v7 * 0.35 + 1
					local offset = label.Size.X.Offset
					label.TextSize = math.min(k.Size * v8, 100)
					label.Position = k.BasePosition - UDim2.fromOffset(offset * (v8 - 1) / 2, k.Size * (v8 - 1) / 2)
					label.TextColor3 = textColor3:Lerp(color, v7 * 0.8)
				end
			end
		end))
		return maid
	end,
	Lightning = function(p)
		local maid = Janitor.new()
		local v2, v3 = splitTitleCharacters(p, maid)
		maid:Add(task.spawn(function()
			while #v2 == 0 do
				task.wait()
			end

			local size = v2[1].Size
			local parent = p.Parent

			if not parent then
				return
			end

			local frame = Instance.new("Frame")
			frame.Name = "LightningOverlay"
			frame.BackgroundTransparency = 1
			frame.Size = UDim2.fromOffset(v3.AbsoluteSize.X + size * 2, v3.AbsoluteSize.Y + size * 2)
			frame.Position = UDim2.fromOffset(
				v3.AbsolutePosition.X - parent.AbsolutePosition.X - size,
				v3.AbsolutePosition.Y - parent.AbsolutePosition.Y - size
			)
			frame.Parent = parent
			maid:Add(frame)

			for _, emitter in script.Particles.Lightning:GetChildren() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = Particle2D.fromParticle(emitter)
				v4:Scale(size * 1)
				v4.Parent = frame
				v4:Bind("RenderStepped")
				maid:Add(v4, "Destroy")
			end
		end))
		maid:Add(task.spawn(function()
			local color = Color3.fromRGB(255, 255, 255)

			while true do
				task.wait(0.6 + math.random() * 1.4)

				if #v2 == 0 then
					continue
				end

				local textColor3 = v2[1].Label.TextColor3

				for _, v4 in v2 do
					v4.Label.TextColor3 = color
					v4.Label.Position = v4.BasePosition + UDim2.fromOffset(
						(math.random() - 0.5) * v4.Size * 0.25,
						(math.random() - 0.5) * v4.Size * 0.25
					)
				end

				task.wait(0.07)

				for _, v4 in v2 do
					v4.Label.TextColor3 = textColor3
					v4.Label.Position = v4.BasePosition
				end
			end
		end))
		return maid
	end,
	Domino = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() * 5 % (#v2 + 10) - 5

			for k, v4 in v2 do
				local v5 = math.clamp(v3 - k + 1, 0, 2)

				if not (v5 < 1) then
					v5 = 2 - v5
				end

				local v6 = v5 * v5 * (3 - v5 * 2)
				v4.Label.Rotation = v6 * 72
				v4.Label.Position = v4.BasePosition + UDim2.fromOffset(v6 * v4.Size * 0.18, v6 * v4.Size * 0.08)
			end
		end))
		return maid
	end,
	RippleFade = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() * 3.5 % (#v2 + 6) - 3

			for k, v4 in v2 do
				local v5 = math.max(0, 1 - math.abs(k - v3) / 3)
				v4.Label.TextTransparency = 0.65 - v5 * 0.65
			end
		end))
		return maid
	end,
	Orbit = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v3 in v2 do
				local v4 = now * 2.4 + k * 0.9
				local v5 = v3.Size * 0.09
				v3.Label.Position = v3.BasePosition + UDim2.fromOffset(math.cos(v4) * v5, math.sin(v4) * v5)
				v3.Label.Rotation = math.cos(v4) * 5
			end
		end))
		return maid
	end,
	Zipper = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = (math.sin(os.clock() * 2.2) + 1) * 0.5
			local v4 = (#v2 + 1) * 0.5

			for k, v5 in v2 do
				local v6 = math.abs(k - v4) / math.max(v4, 1)
				local v7 = k % 2 == 0 and 1 or -1
				local v8 = v3 * v6 * v5.Size * 0.5
				v5.Label.Position = v5.BasePosition + UDim2.fromOffset(0, v8 * v7)
				v5.Label.Rotation = v7 * v3 * v6 * 12
			end
		end))
		return maid
	end,
	ChaseLight = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local textColor3sByLabel = {}
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() * 7 % (#v2 + 8) - 4

			for k, v4 in v2 do
				local label = v4.Label

				if not textColor3sByLabel[label] then
					textColor3sByLabel[label] = label.TextColor3
				end

				local v5 = math.max(0, 1 - math.abs(k - v3) / 2)
				local v6 = v5 * v5
				label.TextColor3 = textColor3sByLabel[label]:Lerp(Color3.new(1, 1, 1), v6)
			end
		end))
		return maid
	end,
	MagnetSnap = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local v3 = {}
		maid:Add(RunService.Heartbeat:Connect(function()
			local v4 = os.clock() * 0.7 % 1
			local v5 = not (v4 < 0.8) and 0 or (v4 / 0.8) ^ 2

			for _, v6 in v2 do
				local label = v6.Label

				if not v3[label] then
					v3[label] = Vector2.new(math.random() - 0.5, math.random() - 0.5) * 2
				end

				local v7 = v3[label]
				label.Position = v6.BasePosition + UDim2.fromOffset(
					v7.X * v5 * v6.Size * 0.45,
					v7.Y * v5 * v6.Size * 0.45
				)
				label.Rotation = v7.X * v5 * 18
			end
		end))
		return maid
	end,
	Ember = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		local color = Color3.fromRGB(148, 42, 12)
		local color2 = Color3.fromRGB(255, 186, 84)
		maid:Add(RunService.Heartbeat:Connect(function()
			local now = os.clock()

			for k, v3 in v2 do
				local v4 = (math.sin(now * 7 + k * 1.7) + math.sin(now * 11.3 + k * 0.6)) * 0.25 + 0.5
				v3.Label.TextColor3 = color:Lerp(color2, (math.clamp(v4, 0, 1)))
				v3.Label.Position = v3.BasePosition + UDim2.fromOffset(
					math.sin(now * 1.6 + k) * v3.Size * 0.03,
					-math.abs((math.sin(now * 1.1 + k * 0.5))) * v3.Size * 0.05
				)
			end
		end))
		return maid
	end,
	SlotRoll = function(p)
		local maid = Janitor.new()
		local v2 = splitTitleCharacters(p, maid)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v3 = os.clock() * 0.5 % 1

			for k, v4 in v2 do
				local v5 = 1 - (1 - math.clamp((v3 - k * 0.06) / 0.28, 0, 1)) ^ 3
				v4.Label.Position = v4.BasePosition + UDim2.fromOffset(0, (1 - v5) * v4.Size * -1.2)
				v4.Label.TextTransparency = 1 - v5
			end
		end))
		return maid
	end,
	Wolfy = function(p)
		local maid = Janitor.new()
		local parent = p.Parent

		if not parent then
			return maid
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "WolfyEars"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://76441020166691"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.25)
		imageLabel.Position = UDim2.new(0.5, 0, 0.15, 0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateEarsSize()
			local absoluteSize = parent.AbsoluteSize

			if absoluteSize.X < 1 then
				return
			end

			imageLabel.Size = UDim2.new(1, 24, 0, (math.floor((absoluteSize.X + 24) * 1.25)))
		end

		updateEarsSize() -- equivalent call inferred; original call site unknown
		maid:Add(parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateEarsSize))
		imageLabel.Parent = parent
		maid:Add(SpriteSheet:Play(imageLabel, {
			Framerate = 12,
			Rows = 4,
			Columns = 5,
			Frames = 20
		}))
		maid:Add(imageLabel)
		return maid
	end
}
return {
	GrimReaper = function(p)
		return (v.DualColor(p, {
			Color1 = Color3.fromRGB(0, 0, 0),
			Color2 = Color3.fromRGB(255, 255, 255),
			TextColor = Color3.new(1, 1, 1),
			TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		}))
	end,
	TrickOrTreat = function(p)
		return (v.TriColor(p, {
			Color1 = Color3.fromRGB(225, 75, 75),
			Color2 = Color3.fromRGB(225, 160, 47),
			Color3 = Color3.fromRGB(56, 56, 56),
			TextColor = Color3.fromRGB(225, 160, 47),
			TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
		}))
	end,
	Maverick = function(p)
		return (v.DualColor(p, {
			Color1 = Color3.fromRGB(38, 107, 255),
			Color2 = Color3.new(0.705882, 0.768627, 1),
			TextColor = Color3.new(1, 0.847059, 0.239216),
			TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		}))
	end,
	Heartbreaker = function(p)
		return (v.DualColor(p, {
			Color1 = Color3.fromRGB(255, 0, 0),
			Color2 = Color3.new(1, 0, 0.74902),
			TextColor = Color3.new(1, 0, 0),
			TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		}))
	end,
	Moderator = function(p)
		return (v.DualColor(p, {
			Color1 = Color3.fromRGB(255, 0, 0),
			Color2 = Color3.new(0.443137, 0, 0),
			TextColor = Color3.new(1, 0, 0),
			TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		}))
	end,
	Treasure = function(p)
		return (v.DualColor(p, {
			Color1 = Color3.fromRGB(255, 226, 6),
			Color2 = Color3.new(1, 0.584314, 0.109804),
			TextColor = Color3.fromRGB(255, 226, 6),
			TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		}))
	end,
	BrickGod = function(p)
		return (v.TriColor(p, {
			Color1 = Color3.new(1, 0.317647, 0.270588),
			Color2 = Color3.new(1, 0.65098, 0.0941176),
			Color3 = Color3.new(1, 0.847059, 0.239216),
			TextColor = Color3.new(1, 0.847059, 0.239216),
			TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
		}))
	end,
	EventsTeam = function(p)
		return (v.TriColor(p, {
			Color1 = Color3.new(1, 0.635294, 0.635294),
			Color2 = Color3.new(1, 0.270588, 0.282353),
			Color3 = Color3.new(0.905882, 0, 0.0156863),
			TextColor = Color3.new(1, 0, 0.0156863),
			TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
		}))
	end,
	Forsaken = function(instance)
		local v2 = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		local color = Color3.fromRGB(0, 85, 127)
		local color2 = Color3.fromRGB(66, 42, 127)
		uIGradient.Rotation = 90
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.75, color2),
			ColorSequenceKeypoint.new(1, color2)
		})
		uIGradient.Parent = title
		v2:Add(uIGradient)
		return v2
	end,
	Shine = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local shineGradient = title:FindFirstChild("ShineGradient") or Instance.new("UIGradient")
		shineGradient.Name = "ShineGradient"
		shineGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		shineGradient.Parent = title
		maid:Add(RunService.Heartbeat:Connect(function()
			shineGradient.Offset = Vector2.new(os.clock() % 4 - 2, 0)
		end))
		maid:Add(shineGradient)
		return maid
	end,
	Thing = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		local color = Color3.fromRGB(85, 85, 0)
		local color2 = Color3.fromRGB(200, 218, 0)
		maid:Add(uIGradient)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v2 = (math.sin(os.clock() * 6.283185307179586 / 1) + 1) * 0.5
			uIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color:Lerp(color2, v2)),
				ColorSequenceKeypoint.new(0.49, color:Lerp(color2, v2)),
				ColorSequenceKeypoint.new(0.51, color2:Lerp(color, v2)),
				ColorSequenceKeypoint.new(1, color2:Lerp(color, v2))
			})
		end))
		uIGradient.Parent = title
		return maid
	end,
	Cute = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		Color3.fromRGB(255, 165, 248)
		Color3.fromRGB(247, 202, 255)
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 255)),
			ColorSequenceKeypoint.new(0.35, Color3.fromRGB(250, 204, 172)),
			ColorSequenceKeypoint.new(0.65, Color3.fromRGB(160, 199, 247)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(175, 139, 247))
		})
		maid:Add(uIGradient)
		maid:Add(RunService.Heartbeat:Connect(function()
			uIGradient.Rotation = os.clock() * 100 % 360
		end))
		uIGradient.Parent = title
		return maid
	end,
	SodaPop = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		local color = Color3.fromRGB(170, 255, 255)
		local color2 = Color3.fromRGB(253, 185, 255)
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.5, color2),
			ColorSequenceKeypoint.new(1, color)
		})
		uIGradient.Parent = title
		maid:Add(uIGradient)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v2 = os.clock() * 0.5 % 2
			uIGradient.Offset = Vector2.new(v2 - 1, 0)
		end))
		return maid
	end,
	Blaugrana = function(instance)
		if instance.Parent:IsA("BillboardGui") then
			instance.Parent.Brightness = 50
		end

		local typeWave = v.TypeWave(instance)
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 134, 255)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(58, 134, 255)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 0, 25)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 25))
		})
		uIGradient.Parent = title
		typeWave:Add(uIGradient)
		return typeWave
	end,
	Cornucopian = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		local color = Color3.fromRGB(199, 154, 59)
		local color2 = Color3.fromRGB(122, 45, 45)
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.5, color2),
			ColorSequenceKeypoint.new(1, color)
		})
		uIGradient.Parent = title
		maid:Add(uIGradient)
		maid:Add(RunService.Heartbeat:Connect(function()
			local v2 = os.clock() * 0.5 % 2
			uIGradient.Offset = Vector2.new(v2 - 1, 0)
		end))
		return maid
	end,
	Universe = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("703bb3")),
			ColorSequenceKeypoint.new(0.2, Color3.fromHex("5f4ae3")),
			ColorSequenceKeypoint.new(0.4, Color3.fromHex("4bedef")),
			ColorSequenceKeypoint.new(0.6, Color3.fromHex("6530c6")),
			ColorSequenceKeypoint.new(0.8, Color3.fromHex("7f0e67")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("4f66cd"))
		})
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "AnimationStroke"
		uIStroke.Transparency = 0.5
		uIStroke.Thickness = 2
		maid:Add(uIGradient)
		maid:Add(RunService.Heartbeat:Connect(function()
			uIGradient.Rotation = os.clock() * 60 % 360
		end))
		uIGradient.Parent = title
		uIStroke.Parent = title

		if instance.Parent:IsA("BillboardGui") then
			instance.Parent.Brightness = 10
		end

		return maid
	end,
	Jellyfish = function(instance)
		if instance.Parent:IsA("BillboardGui") then
			instance.Parent.Brightness = 7.5
		end

		local wave = v.Wave(instance, 1)
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(170, 255, 255)),
			ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 85, 255)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 85, 255)),
			ColorSequenceKeypoint.new(0.8, Color3.fromRGB(170, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 85, 255))
		})
		uIGradient.Parent = title
		wave:Add(uIGradient)
		return wave
	end,
	Grub = function(p)
		if p.Parent:IsA("BillboardGui") then
			p.Parent.Brightness = 10
		end

		return (v.DualColor(p, {
			Color1 = Color3.fromRGB(115, 89, 74),
			Color2 = Color3.fromRGB(181, 154, 140),
			TextColor = Color3.new(1, 1, 1),
			TweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		}))
	end,
	Mr100 = function(instance)
		local v2 = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 90
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 219, 175)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 39, 30))
		})
		uIGradient.Parent = title
		return v2
	end,
	Rainbow = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		maid:Add(RunService.Heartbeat:Connect(function()
			title.TextColor3 = Color3.fromHSV(tick() % 20 / 20, 1, 1)
			title.TextStrokeColor3 = Color3.fromHSV(tick() % 20 / 20, 1, 0.4)
		end))
		return maid
	end,
	RainbowWave = function(instance)
		local maid = v.Wave(instance)
		local title = instance:FindFirstChild("Title", true)
		maid:Add(RunService.Heartbeat:Connect(function()
			title.TextColor3 = Color3.fromHSV(tick() % 20 / 20, 1, 1)
			title.TextStrokeColor3 = Color3.fromHSV(tick() % 20 / 20, 1, 0.4)
		end))
		return maid
	end,
	Type = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local v2 = string.match(title.Text, "<b>")
		local v3 = string.gsub(title.Text, "<b>", ""):gsub("</b>", "")
		local v4 = string.len(v3)
		local v5 = 1
		local v6 = false
		maid:Add(task.spawn(function()
			while true do
				local v7 = ""

				if v2 then
					v7 ..= "<b>"
				end

				local text

				if v6 == false then
					text = v7 .. v3:sub(1, v5)
				else
					text = v7 .. v3:sub(v5, v4)
				end

				if v2 then
					text ..= "</b>"
				end

				title.Text = text
				task.wait(0.05)
				v5 += 1
				local v9 = v5

				if not (v4 + 1 < v9) then
					continue
				end

				v6 = not v6
				v5 = 1
				task.wait(0.5)
			end
		end))
		return maid
	end,
	BoldWave = function(instance)
		local maid = Janitor.new()
		local title = instance:FindFirstChild("Title", true)
		local v2 = string.match(title.Text, "<b>")
		local v3 = string.gsub(title.Text, "<b>", ""):gsub("</b>", "")
		local v4 = string.len(v3)
		local v5 = 0
		maid:Add(task.spawn(function()
			while true do
				v5 += 1

				if v4 < v5 then
					v5 = 1
				end

				local v6 = ""

				if v2 then
					v6 ..= "<b>"
				end

				local v7 = v6 .. v3:sub(1, v5 - 1)
				local v8

				if v2 then
					v8 = v7 .. "</b>"
				else
					v8 = v7 .. "<b>"
				end

				local v9 = v8 .. v3:sub(v5, v5)
				local v10

				if v2 then
					v10 = v9 .. "<b>"
				else
					v10 = v9 .. "</b>"
				end

				local text = v10 .. v3:sub(v5 + 1, v4)

				if v2 then
					text ..= "</b>"
				end

				title.Text = text
				task.wait(0.05)
			end
		end))
		return maid
	end,
	Wave = function(p, p2: number?)
		return (v.Wave(p, p2))
	end,
	Riot = function(p)
		return (v.Riot(p))
	end,
	["Head Moderator"] = function(p)
		return v["Head Moderator"](p)
	end,
	Hearthkeeper = function(p)
		return (v.Hearthkeeper(p))
	end,
	TypeWave = function(p)
		return (v.TypeWave(p))
	end,
	Glow = function(p)
		if p.Parent:IsA("BillboardGui") then
			p.Parent.Brightness = 5
		end

		return Janitor.new()
	end,
	Dollface = function(p)
		if p.Parent:IsA("BillboardGui") then
			p.Parent.Brightness = 10
		end

		return (v.TypeWave(p))
	end,
	Explosion = function(p)
		return (v.Explosion(p))
	end,
	Float = function(p)
		return (v.Float(p))
	end,
	Shockwave = function(p)
		return (v.Shockwave(p))
	end,
	Glitch = function(p)
		return (v.Glitch(p))
	end,
	Vibrate = function(p)
		return (v.Vibrate(p))
	end,
	Spin = function(p)
		return (v.Spin(p))
	end,
	Bounce = function(p)
		return (v.Bounce(p))
	end,
	Scramble = function(p)
		return (v.Scramble(p))
	end,
	Swing = function(p)
		return (v.Swing(p))
	end,
	Cascade = function(p)
		return (v.Cascade(p))
	end,
	Tornado = function(p)
		return (v.Tornado(p))
	end,
	Heartbeat = function(p)
		return (v.Heartbeat(p))
	end,
	Flag = function(p)
		return (v.Flag(p))
	end,
	Accordion = function(p)
		return (v.Accordion(p))
	end,
	Firework = function(p)
		return (v.Firework(p))
	end,
	Sparkle = function(p)
		return (v.Sparkle(p))
	end,
	Lightning = function(p)
		return (v.Lightning(p))
	end,
	Domino = function(p)
		return (v.Domino(p))
	end,
	RippleFade = function(p)
		return (v.RippleFade(p))
	end,
	Orbit = function(p)
		return (v.Orbit(p))
	end,
	Zipper = function(p)
		return (v.Zipper(p))
	end,
	ChaseLight = function(p)
		return (v.ChaseLight(p))
	end,
	MagnetSnap = function(p)
		return (v.MagnetSnap(p))
	end,
	Ember = function(p)
		return (v.Ember(p))
	end,
	SlotRoll = function(p)
		return (v.SlotRoll(p))
	end,
	Wolfy = function(p)
		return (v.Wolfy(p))
	end
}