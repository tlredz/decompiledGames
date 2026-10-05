local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Concert.ConcertState)
local Vide = require(ReplicatedStorage.Packages.Vide)
local MicroProfiler = require(ReplicatedStorage.Utilities.MicroProfiler)
local create = Vide.create
local ConcertUI = {}
local gothamBold = Enum.Font.GothamBold
local uDim = UDim2.fromScale(0, -0.08)
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local uDim2 = UDim2.fromScale(0, 0.08)
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(150, 150, 150)
local color3 = Color3.fromRGB(255, 92, 176)
local color4 = Color3.fromRGB(92, 164, 255)
ConcertUI.WordEffects = {
	"Gradient",
	"Rainbow",
	"Shake",
	"Pulse",
	"Wave"
}
ConcertUI.CurrentWord = Vide.source(0)
ConcertUI.CurrentText = Vide.source("")
ConcertUI.CurrentWords = Vide.source(nil)
ConcertUI.CurrentTransparency = Vide.source(0)
local fn = nil
local v = {}
local values = {}
local v2 = 1

local function Resolve(callback, p)
	if type(callback) == "function" then
		return callback()
	end

	if callback == nil then
		return p
	end

	return callback
end

local function SplitWords(value: string)
	local result = {}

	for k in string.gmatch(value, "%S+") do
		table.insert(result, {
			Text = k
		})
	end

	return result
end

local function GetSubtitleWords(p: string, list)
	if not (list and #list > 0) then
		return (SplitWords(p))
	end

	local result = {}

	for _, v3 in list do
		table.insert(result, {
			Text = v3.text,
			NoSpaceAfterThisWord = v3.NoSpaceAfterThisWord,
			Image = v3.Image,
			ImageAspectRatio = v3.ImageAspectRatio,
			Effect = v3.Effect,
			EffectColor1 = v3.EffectColor1,
			EffectColor2 = v3.EffectColor2,
			EffectSpeed = v3.EffectSpeed,
			EffectIntensity = v3.EffectIntensity,
			EffectFadeOut = v3.EffectFadeOut
		})
	end

	return result
end

local function GetSubtitleSignature(items)
	local v3 = {}

	for _, item in items do
		table.insert(v3, item.Text)
		table.insert(v3, item.NoSpaceAfterThisWord and "0" or "1")
		table.insert(v3, item.Image or "")
		table.insert(v3, (tostring(item.ImageAspectRatio or 1)))
		table.insert(v3, item.Effect or "")
		table.insert(v3, item.EffectColor1 or "")
		table.insert(v3, item.EffectColor2 or "")
		table.insert(v3, (tostring(item.EffectSpeed or 1)))
		table.insert(v3, (tostring(item.EffectIntensity or 1)))
		table.insert(v3, (tostring(item.EffectFadeOut or 0)))
	end

	return table.concat(v3, "\31")
end

local function MeasureText(p: string, p2: number, p3: number)
	local formatted = ("%*\31%*\31%*"):format(p2, p3, p)
	local v3 = v[formatted]

	if v3 then
		return v3
	end

	local textSize = TextService:GetTextSize(p, p2, gothamBold, Vector2.new(p3, 100000))

	if #values < 4096 then
		table.insert(values, formatted)
	else
		v[values[v2]] = nil
		values[v2] = formatted
		v2 = v2 % 4096 + 1
	end

	v[formatted] = textSize
	return textSize
end

local function BuildLayout(list, point: Vector2, textSize: number)
	if #list == 0 or point.X <= 0 or point.Y <= 0 then
		return {}, 0, 0
	end

	local v3 = math.max(MeasureText("A A", textSize, 100000).X - MeasureText("AA", textSize, 100000).X, 0)
	local Y = MeasureText("Ag", textSize, 100000).Y
	local v4 = nil
	local v5 = {}

	for _, v6 in list do
		local X

		if v6.Image then
			X = Y * math.max(v6.ImageAspectRatio or 1, 0.01)
		else
			X = MeasureText(v6.Text, textSize, 100000).X
		end

		v4 = v4 or {
			Words = {},
			Width = 0
		}
		table.insert(v4.Words, {
			Text = v6.Text,
			Width = X,
			NoSpaceAfterThisWord = v6.NoSpaceAfterThisWord,
			Image = v6.Image,
			Effect = v6.Effect,
			EffectColor1 = v6.EffectColor1,
			EffectColor2 = v6.EffectColor2,
			EffectSpeed = v6.EffectSpeed,
			EffectIntensity = v6.EffectIntensity,
			EffectFadeOut = v6.EffectFadeOut
		})
		v4.Width += X

		if v6.NoSpaceAfterThisWord then
			continue
		end

		table.insert(v5, v4)
		v4 = nil
	end

	if v4 then
		table.insert(v5, v4)
	end

	local groups = {}
	local total = 0
	local v7 = {}

	for _, v8 in v5 do
		local v9 = not (#groups > 0) and 0 or v3

		if #groups > 0 and total + v9 + v8.Width > point.X then
			table.insert(v7, {
				Groups = groups,
				Width = total
			})
			groups = {}
			v9 = 0
			total = 0
		end

		table.insert(groups, v8)
		total += v9 + v8.Width
	end

	if #groups > 0 then
		table.insert(v7, {
			Groups = groups,
			Width = total
		})
	end

	local v8 = #v7 * Y + math.max(#v7 - 1, 0) * 4
	local v9 = math.max((point.Y - v8) / 2, 0)
	local v10 = 0
	local result = {}

	for _, v11 in v7 do
		v10 = math.max(v10, v11.Width)
		local v12 = math.max((point.X - v11.Width) / 2, 0)

		for k, group in v11.Groups do
			if k > 1 then
				v12 += v3
			end

			for _, word in group.Words do
				table.insert(result, {
					Text = word.Text,
					X = v12,
					Y = v9,
					Width = word.Width,
					Height = Y,
					TextSize = textSize,
					Image = word.Image,
					Effect = word.Effect,
					EffectColor1 = word.EffectColor1,
					EffectColor2 = word.EffectColor2,
					EffectSpeed = word.EffectSpeed,
					EffectIntensity = word.EffectIntensity,
					EffectFadeOut = word.EffectFadeOut
				})
				v12 += word.Width
			end
		end

		v9 += Y + 4
	end

	return result, v8, v10
end

local function GetBestTextSize(p, absoluteSize: Vector2)
	local function FindBestSize(p2: number, p3: number)
		local v3 = nil

		while p2 <= p3 do
			local textSize = math.floor((p2 + p3) / 2)
			local _, v5, v6 = BuildLayout(p, absoluteSize, textSize)

			if v5 <= absoluteSize.Y and v6 <= absoluteSize.X then
				p2 = textSize + 1
				v3 = textSize
			else
				p3 = textSize - 1
			end
		end

		return v3
	end

	local bestSize = FindBestSize(8, math.max(8, (math.min(96, (math.floor(absoluteSize.Y))))))
	return bestSize or FindBestSize(1, 7) or 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetWordTargetPosition(p)
	return UDim2.fromOffset(p.X, p.Y)
end

local function GetWordStatePosition(p, flag: boolean)
	local wordTargetPosition = GetWordTargetPosition(p) -- equivalent call inferred; original call site unknown

	if flag then
		return wordTargetPosition
	end

	return wordTargetPosition + uDim2
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function IsWordActive(p: number, p2: number)
	return p2 > 0 and p <= p2
end

local function ParseHexColor(value: string?)
	if not value then
		return nil
	end

	local v3 = string.match(value, "^#?(%x%x%x%x%x%x)$")

	if v3 then
		return Color3.fromRGB(
			tonumber(string.sub(v3, 1, 2), 16),
			tonumber(string.sub(v3, 3, 4), 16),
			(tonumber(string.sub(v3, 5, 6), 16))
		)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsMotionEffect(p)
	return p == "Shake" or p == "Wave"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEffectFadeOutEnvelope(data, p: number)
	local effectFadeOut = data.EffectFadeOut

	if effectFadeOut and not (effectFadeOut <= 0) then
		return (math.clamp(1 - p / effectFadeOut, 0, 1))
	end

	return 1
end

local function GetEffectLetterColor(word, p: number, p2: number, p3: number)
	local effect = word.Effect
	local effectSpeed = word.EffectSpeed or 1
	local v3 = math.clamp(word.EffectIntensity or 1, 0, 1)
	local v4 = (p - 1) / math.max(p2 - 1, 1)

	if effect == "Gradient" then
		return color:Lerp(
			(ParseHexColor(word.EffectColor1) or color3):Lerp(ParseHexColor(word.EffectColor2) or color4, v4),
			math.clamp((p3 - (p - 1) * 0.05 / effectSpeed) / (0.3 / effectSpeed), 0, 1) * v3 * GetEffectFadeOutEnvelope(
				word,
				p3
			)
		)
	elseif effect == "Rainbow" then
		local v5 = (v4 + p3 * effectSpeed * 0.25) % 1
		return color:Lerp(
			Color3.fromHSV(v5, 0.85, 1),
			math.clamp((p3 - (p - 1) * 0.05 / effectSpeed) / (0.3 / effectSpeed), 0, 1) * v3 * GetEffectFadeOutEnvelope(
				word,
				p3
			)
		)
	else
		if effect ~= "Pulse" then
			return nil
		end

		local v5 = ParseHexColor(word.EffectColor1) or color3
		local v6 = not (p2 > 1) and 0 or math.abs(p - (p2 + 1) * 0.5) / ((p2 - 1) * 0.5)
		local v7 = p3 * effectSpeed - v6 * 0.4

		if v7 <= 0 or v7 >= 0.5 then
			return color
		end

		return color:Lerp(v5, math.sin(3.141592653589793 * v7 / 0.5) * v3)
	end
end

local function GetEffectLetterOffset(word, p: number, p2: number)
	local effect = word.Effect
	local effectSpeed = word.EffectSpeed or 1
	local effectIntensity = word.EffectIntensity or 1
	local v3 = effectIntensity * GetEffectFadeOutEnvelope(word, p2)

	if v3 <= 0 then
		return 0, 0
	end

	if effect == "Shake" then
		local v4 = word.Height * 0.05 * v3
		local v5 = p * 7.31
		return math.sin(p2 * effectSpeed * 41 + v5) * v4, math.cos(p2 * effectSpeed * 47 + v5 * 1.7) * v4
	else
		if effect ~= "Wave" then
			return 0, 0
		end

		local v4 = word.Height * 0.12 * v3
		return 0, math.sin(p2 * effectSpeed * 6.8 - p * 0.55) * v4
	end
end

local function RestEffectEntry(item)
	local word = item.Word

	if #item.Letters == 0 then
		local container = item.Container

		if not container:IsA("ImageLabel") then
			return
		end

		container.ImageColor3 = Color3.new(1, 1, 1)

		if IsMotionEffect(word.Effect) then
			container.Position = UDim2.fromOffset(word.X, word.Y) + uDim2
		end
	else
		for _, letter in item.Letters do
			letter.Label.TextColor3 = color2
			letter.Label.Position = UDim2.fromOffset(letter.BaseX, 0)
		end
	end
end

local function UpdateEffects(items, p: number, now: number)
	for _, item in items do
		local word = item.Word

		if IsWordActive(item.Index, p) then
			if not item.ActivatedAt then
				item.ActivatedAt = now
			end

			item.WasActive = true
			local v4 = now - item.ActivatedAt

			if #item.Letters == 0 then
				local container = item.Container

				if container:IsA("ImageLabel") then
					local imageColor = GetEffectLetterColor(word, 1, 1, v4)

					if imageColor then
						container.ImageColor3 = imageColor
					end

					if IsMotionEffect(word.Effect) then
						local v6, v7 = GetEffectLetterOffset(word, 1, v4)
						container.Position = UDim2.fromOffset(word.X, word.Y) + UDim2.fromOffset(v6, v7)
					end
				end
			else
				local v5 = #item.Letters

				for k, letter in item.Letters do
					local effectLetterColor = GetEffectLetterColor(word, k, v5, v4)
					letter.Label.TextColor3 = effectLetterColor or color
					local v7, v8 = GetEffectLetterOffset(word, k, v4)
					letter.Label.Position = UDim2.fromOffset(letter.BaseX + v7, v8)
				end
			end
		elseif item.WasActive ~= false then
			item.WasActive = false
			item.ActivatedAt = nil
			RestEffectEntry(item)
		end
	end
end

local function UpdateWordStates(instance, items, p: number, flag: boolean)
	for k, item in items do
		local guiObject = instance:FindFirstChild((`Word{k}`))

		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		local wordActive = IsWordActive(k, p)
		local position = GetWordTargetPosition(item) -- equivalent call inferred; original call site unknown

		if not wordActive then
			position += uDim2
		end

		if guiObject:IsA("ImageLabel") then
			local imageTransparency = wordActive and 0 or 0.5

			if guiObject:GetAttribute("MotionEffect") then
				if flag then
					TweenService:Create(guiObject, tweenInfo2, {
						ImageTransparency = imageTransparency
					}):Play()
				else
					guiObject.ImageTransparency = imageTransparency
				end
			elseif flag then
				TweenService:Create(guiObject, tweenInfo2, {
					Position = position,
					ImageTransparency = imageTransparency
				}):Play()
			else
				guiObject.Position = position
				guiObject.ImageTransparency = imageTransparency
			end
		elseif guiObject:IsA("Frame") then
			if flag then
				TweenService:Create(guiObject, tweenInfo2, {
					Position = position
				}):Play()
			else
				guiObject.Position = position
			end
		elseif guiObject:IsA("TextLabel") then
			local textColor

			if wordActive then
				textColor = color
			else
				textColor = color2
			end

			if flag then
				TweenService:Create(guiObject, tweenInfo2, {
					Position = position,
					TextColor3 = textColor
				}):Play()
			else
				guiObject.Position = position
				guiObject.TextColor3 = textColor
			end
		end
	end
end

local function CreateLetterLabel(text: string, p2: number, p3: number, item, flag: boolean, parent)
	local v3 = create("TextLabel")
	local v4 = {
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Font = gothamBold,
		Position = UDim2.fromOffset(p2, 0),
		Size = UDim2.fromOffset(p3, item.Height),
		Text = text
	}
	local textColor

	if flag then
		textColor = color
	else
		textColor = color2
	end

	v4.TextColor3 = textColor
	v4.TextSize = item.TextSize
	v4.TextXAlignment = Enum.TextXAlignment.Center
	v4.TextYAlignment = Enum.TextYAlignment.Center
	v4.Parent = parent
	do local _values = table.pack(create("UIStroke")({
	StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
	Thickness = 0.075,
	Color = Color3.new(0, 0, 0),
	LineJoinMode = Enum.LineJoinMode.Round
})); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	return (v3(v4))
end

local function RenderWordLabels(parent, items, p: number, flag: boolean)
	for _, guiObject in parent:GetChildren() do
		if not (guiObject:IsA("TextLabel") or guiObject:IsA("ImageLabel") or guiObject:IsA("Frame")) then
			continue
		end

		guiObject:Destroy()
	end

	local result = {}

	for k, item in items do
		local wordActive = IsWordActive(k, p)
		local position = GetWordTargetPosition(item) -- equivalent call inferred; original call site unknown

		if not wordActive then
			position += uDim2
		end

		local container

		if item.Image then
			local v6 = create("ImageLabel")
			local v7 = {
				Name = `Word{k}`,
				BackgroundTransparency = 1,
				Image = item.Image,
				ImageTransparency = wordActive and 0 or 0.5,
				Position = 0,
				ScaleType = 0,
				Size = 0,
				Parent = 0
			}
			local position2

			if flag then
				position2 = position + uDim
			else
				position2 = position
			end

			v7.Position = position2
			v7.ScaleType = Enum.ScaleType.Fit
			v7.Size = UDim2.fromOffset(item.Width, item.Height)
			v7.Parent = parent
			container = v6(v7)

			if item.Effect then
				if IsMotionEffect(item.Effect) and wordActive then
					container:SetAttribute("MotionEffect", true)
				end

				table.insert(result, {
					Index = k,
					Word = item,
					Container = container,
					Letters = {},
					ActivatedAt = nil,
					WasActive = nil
				})
			end
		elseif item.Effect then
			local v6 = create("Frame")
			local v7 = {
				Name = `Word{k}`,
				BackgroundTransparency = 1,
				Position = 0,
				Size = 0,
				Parent = 0
			}
			local position2

			if flag then
				position2 = position + uDim
			else
				position2 = position
			end

			v7.Position = position2
			v7.Size = UDim2.fromOffset(item.Width, item.Height)
			v7.Parent = parent
			local container2 = v6(v7)
			container = container2
			local v10 = {}
			local letters = {}

			for k2, v12 in utf8.graphemes(item.Text) do
				table.insert(v10, (string.sub(item.Text, k2, v12)))
			end

			local v12 = ""
			local baseX = 0

			for _, v14 in v10 do
				v12 ..= v14
				local X = MeasureText(v12, item.TextSize, 100000).X
				local width = math.max(X - baseX, 1)
				table.insert(letters, {
					Label = CreateLetterLabel(v14, baseX, width, item, wordActive, container2),
					BaseX = baseX,
					Width = width
				})
				baseX = X
			end

			table.insert(result, {
				Index = k,
				Word = item,
				Container = container2,
				Letters = letters,
				ActivatedAt = nil,
				WasActive = nil
			})
		else
			local v6 = create("TextLabel")
			local v7 = {
				Name = `Word{k}`,
				AutoLocalize = false,
				BackgroundTransparency = 1,
				Font = gothamBold
			}
			local position2

			if flag then
				position2 = position + uDim
			else
				position2 = position
			end

			v7.Position = position2
			v7.Size = UDim2.fromOffset(item.Width, item.Height)
			v7.Text = item.Text
			local textColor

			if wordActive then
				textColor = color
			else
				textColor = color2
			end

			v7.TextColor3 = textColor
			v7.TextSize = item.TextSize
			v7.TextXAlignment = Enum.TextXAlignment.Left
			v7.TextYAlignment = Enum.TextYAlignment.Center
			v7.Parent = parent
			do local _values = table.pack(create("UIStroke")({
	StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
	Thickness = 0.075,
	Color = Color3.new(0, 0, 0),
	LineJoinMode = Enum.LineJoinMode.Round
})); for _k = 1, _values.n do v7[_k] = _values[_k] end end
			container = v6(v7)
		end

		if not flag or container:GetAttribute("MotionEffect") then
			continue
		end

		TweenService:Create(container, tweenInfo, {
			Position = position
		}):Play()
	end

	return result
end

local function BindSubtitleLayout(instance, data)
	local v3 = ""
	local v4 = nil
	local v5 = 0
	local v6 = {}
	local count = 0
	local v7 = ""
	local zero = Vector2.zero
	local v8 = {}

	local function QueueLayout(flag: boolean, flag2: boolean?)
		local subtitleWords = GetSubtitleWords(v3, v4)
		local subtitleSignature = GetSubtitleSignature(subtitleWords)
		local absoluteSize = instance.AbsoluteSize

		if not flag2 and subtitleSignature == v7 and absoluteSize == zero then
			return
		end

		v7 = subtitleSignature
		zero = absoluteSize
		count += 1
		local v11 = count
		local currentWord = data.CurrentWord
		local v12

		if type(currentWord) == "function" then
			v12 = currentWord()
		else
			v12 = currentWord == nil and 0 or currentWord
		end

		task.defer(function()
			if v11 ~= count then
				return
			end

			local v13 = MicroProfiler.Call("ConcertUI.LayoutSubtitle", function()
				return BuildLayout(subtitleWords, absoluteSize, GetBestTextSize(subtitleWords, absoluteSize))
			end)

			if v11 == count and instance.Parent then
				v6 = v13
				v8 = MicroProfiler.Call("ConcertUI.RenderSubtitle", function()
					return (RenderWordLabels(instance, v13, v12, flag))
				end)
			end
		end)
	end

	Vide.effect(function()
		local text = data.Text
		local v9

		if type(text) == "function" then
			v9 = text()
		else
			v9 = text == nil and "SubtitleComponent" or text
		end

		v3 = v9
		QueueLayout(true)
	end)
	Vide.effect(function()
		local words = data.Words

		if type(words) == "function" then
			words = words()
		elseif words == nil then
			words = nil
		end

		v4 = words
		QueueLayout(true)
	end)
	Vide.effect(function()
		local currentWord = data.CurrentWord
		local v9

		if type(currentWord) == "function" then
			v9 = currentWord()
		else
			v9 = currentWord == nil and 0 or currentWord
		end

		v5 = v9
		UpdateWordStates(instance, v6, v5, true)
	end)
	local absoluteSizeChangedConnection = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		QueueLayout(false, true)
	end)
	Vide.cleanup(absoluteSizeChangedConnection)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if #v8 == 0 then
			return
		end

		UpdateEffects(v8, v5, os.clock())
	end)
	Vide.cleanup(heartbeatConnection)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPlayerGui()
	local localPlayer = Players.LocalPlayer
	assert(localPlayer, "ConcertUI.Mount can only be called on the client.")
	return (localPlayer:WaitForChild("PlayerGui"))
end

function ConcertUI.GetLineFadeTransparency(data, p: number)
	local v3 = math.max(data.duration, 0)
	local v4 = math.min(math.max(data.FadeOutDuration or 0, 0), v3)

	if v4 <= 0 then
		return 0
	end

	return (math.clamp((p - (data.seconds + v3 - v4)) / v4, 0, 1))
end

function ConcertUI:SubtitleComponent()
	self.Text = self.Text or ConcertUI.CurrentText
	self.Words = self.Words or ConcertUI.CurrentWords
	self.CurrentWord = self.CurrentWord or ConcertUI.CurrentWord
	self.Transparency = self.Transparency or ConcertUI.CurrentTransparency
	return create("CanvasGroup")({
		Name = "SubtitleContainer",
		AnchorPoint = self.AnchorPoint or Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		GroupTransparency = self.Transparency,
		Position = self.Position or UDim2.fromScale(0.5, 0.88),
		Size = self.Size or UDim2.fromScale(0.8, 0.12),
		Vide.action(function(p)
			BindSubtitleLayout(p, self)
		end)
	})
end

function ConcertUI.SetLine(p: string, p2, p3: number)
	Vide.batch(function()
		ConcertUI.CurrentText(p)
		ConcertUI.CurrentWords(p2)
		ConcertUI.CurrentWord(p3)
	end)
end

function ConcertUI.Mount(instance)
	if fn then
		return fn
	end

	if not instance then
		instance = GetPlayerGui()
	end

	local localPlayer = Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function AreLyricsEnabled()
		return not localPlayer or localPlayer:GetAttribute("ConcertLyricsEnabled") ~= false
	end

	local concertUI = instance:FindFirstChild("ConcertUI")

	if concertUI then
		concertUI:Destroy()
	end

	local v3 = Vide.mount(function()
		return create("ScreenGui")({
			Name = "ConcertUI",
			DisplayOrder = 1000000,
			Enabled = AreLyricsEnabled(),
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ConcertUI.SubtitleComponent({})
		})
	end, instance)
	local concertUI2 = instance:FindFirstChild("ConcertUI")
	local concertLyricsEnabledChangedConnection

	if localPlayer and concertUI2 and concertUI2:IsA("ScreenGui") then
		concertLyricsEnabledChangedConnection = localPlayer:GetAttributeChangedSignal("ConcertLyricsEnabled"):Connect(function()
			concertUI2.Enabled = AreLyricsEnabled()
		end)
	else
		concertLyricsEnabledChangedConnection = nil
	end

	fn = function()
		if fn then
			fn = nil

			if concertLyricsEnabledChangedConnection then
				concertLyricsEnabledChangedConnection:Disconnect()
			end

			v3()
		end
	end

	return fn
end

return ConcertUI