local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local fx = require(ReplicatedStorage.shared.modules.fx)
local cutsceneDialog = nil
local main = nil
local template = nil
local template2 = nil
local gothamBold = Enum.Font.GothamBold
local uDim = UDim2.fromScale(0.5, 0.5)

local function hexToColor3(value: string)
	local v = value:gsub("#", "")

	if #v ~= 6 then
		return nil
	end

	local v2 = tonumber(v:sub(1, 2), 16)
	local v3 = tonumber(v:sub(3, 4), 16)
	local v4 = tonumber(v:sub(5, 6), 16)

	if v2 and v3 and v4 then
		return Color3.fromRGB(v2, v3, v4)
	end

	return nil
end

local function parseTaggedText(value: string)
	local total = 1
	local v = {}
	local result = {}

	while total <= #value do
		if value:sub(total, total) == "<" then
			local match = value:match("^</(%w+)>", total)

			if match then
				for i = #v, 1, -1 do
					if v[i].name ~= match then
						continue
					end

					table.remove(v, i)
					break
				end

				total += #match + 3
				continue
			else
				local match2, v2 = value:match("^<(%w+)=([^>]+)>", total)

				if match2 then
					table.insert(v, {
						name = match2,
						value = v2
					})
					total += #match2 + #v2 + 3
					continue
				else
					local match3 = value:match("^<(%w+)>", total)

					if match3 then
						table.insert(v, {
							name = match3,
							value = nil
						})
						total += #match3 + 2
						continue
					end
				end
			end
		end

		local tags = {}

		for _, v3 in v do
			table.insert(tags, {
				name = v3.name,
				value = v3.value
			})
		end

		table.insert(result, {
			char = value:sub(total, total),
			tags = tags
		})
		total += 1
	end

	return result
end

local function getTagValue(list, p: string)
	for i = #list, 1, -1 do
		if list[i].name == p then
			return true, list[i].value
		end
	end

	return false, nil
end

local renderSteppedConnections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function clearActiveEffects()
	for _, connection in renderSteppedConnections do
		connection:Disconnect()
	end

	table.clear(renderSteppedConnections)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyShakeEffect(textLabel, uDim2: UDim2)
	local v = math.random() * 100
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not (textLabel and textLabel.Parent) then
			return
		end

		local v2 = os.clock() * 20 + v
		local v3 = math.sin(v2 * 1.3) * 2
		local v4 = math.cos(v2 * 1.7) * 2
		textLabel.Position = uDim2 + UDim2.fromOffset(v3, v4)
	end)
	table.insert(renderSteppedConnections, renderSteppedConnection)
end

local function fadeOutLine(folder)
	if not (folder and folder.Parent) then
		return
	end

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("TextLabel") then
			TweenService:Create(descendant, tweenInfo, {
				TextTransparency = 1
			}):Play()
		end

		if descendant:IsA("UIStroke") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.35, function()
		if folder and folder.Parent then
			folder:Destroy()
		end
	end)
end

local function slideExistingLinesUp(main2, p: number?)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local Y = main2.AbsoluteSize.Y
	local v = not (Y > 0 and p) and 0.56 or p / Y

	for _, frame in main2:GetChildren() do
		if frame:IsA("Frame") and frame.Name == "Line" then
			TweenService:Create(frame, tweenInfo, {
				Position = frame.Position - UDim2.fromScale(0, v)
			}):Play()
		end
	end
end

local function getCharWidth(text: string, p, size: number)
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text
	getTextBoundsParams.Font = Font.fromEnum(p)
	getTextBoundsParams.Size = size
	getTextBoundsParams.Width = 1e999
	return TextService:GetTextBoundsAsync(getTextBoundsParams).X
end

local function buildLines(items, font, size, X)
	local total = 0
	local v = {}
	local v2 = 0
	local v3 = {}
	local result = {}

	for _, item in items do
		local char = item.char
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = char
		getTextBoundsParams.Font = Font.fromEnum(font)
		getTextBoundsParams.Size = size
		getTextBoundsParams.Width = 1e999
		local X2 = TextService:GetTextBoundsAsync(getTextBoundsParams).X

		if item.char == " " then
			if X < v2 + total + X2 and #v3 > 0 then
				table.insert(result, v3)
				v3 = {}
				v2 = 0
			end

			for _, v4 in v do
				table.insert(v3, v4)
			end

			local v4 = v2 + total
			table.insert(v3, {
				entry = item,
				width = X2
			})
			v2 = v4 + X2
			table.clear(v)
			total = 0
		else
			total += X2
			table.insert(v, {
				entry = item,
				width = X2
			})
		end
	end

	if #v > 0 then
		if X < v2 + total and #v3 > 0 then
			table.insert(result, v3)
			v3 = {}
		end

		for _, v4 in v do
			table.insert(v3, v4)
		end
	end

	if #v3 > 0 then
		table.insert(result, v3)
	end

	return result
end

local function animateLetters(displayText, p: string, font, textSize: number, flag: boolean, color: Color3, p2: number?, voice: string?)
	local v = parseTaggedText(p)
	local v2 = not p2 and 0.03 or p2 / math.max(#v, 1)
	local v3 = math.min(0.08, v2 * 2)
	local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(v3 * 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local X = displayText.AbsoluteSize.X
	local v4 = textSize * 1.3
	local lines = buildLines(v, font, textSize, X)
	local child = voice and ReplicatedStorage.resources.sounds.voices:FindFirstChild(voice)
	local children = child and child:GetChildren()
	local count = 0

	for k, line in lines do
		local total = 0

		for _, v5 in line do
			total += v5.width
		end

		local v5 = (X - total) / 2
		local v6 = (k - 1) * v4 + textSize / 2

		for _, v7 in line do
			count += 1
			local entry = v7.entry
			local width = v7.width
			local v8 = v5 + width / 2
			local uDim2 = UDim2.fromOffset(v8, v6)
			local tags = entry.tags
			local flag2 = true
			local value, v9

			for i = #tags, 1, -1 do
				if tags[i].name ~= "color" then
					continue
				end

				value = tags[i].value
				v9 = true
				flag2 = false
				break
			end

			if flag2 then
				v9 = false
				value = nil
			end

			local textColor

			if v9 and value then
				textColor = hexToColor3(value) or color
			else
				textColor = color
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Char_" .. count
			textLabel.Text = entry.char
			textLabel.Font = font
			textLabel.TextSize = textSize
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromOffset(width, textSize)
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Position = uDim2
			textLabel.TextTransparency = 1
			textLabel.Parent = displayText
			v5 += width

			if flag then
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Thickness = 1.8
				uIStroke.Color = Color3.new(0, 0, 0)
				uIStroke.Transparency = 1
				uIStroke.Parent = textLabel
				TweenService:Create(uIStroke, tweenInfo, {
					Transparency = 0
				}):Play()
			end

			local uIScale = Instance.new("UIScale")
			uIScale.Scale = 2.5
			uIScale.Parent = textLabel
			TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 0
			}):Play()
			TweenService:Create(uIScale, tweenInfo, {
				Scale = 1
			}):Play()
			TweenService:Create(textLabel, tweenInfo2, {
				TextColor3 = textColor
			}):Play()
			local tags2 = entry.tags
			local flag3 = true
			local flag4

			for i = #tags2, 1, -1 do
				if tags2[i].name ~= "shake" then
					continue
				end

				local _ = tags2[i].value
				flag4 = true
				flag3 = false
				break
			end

			if flag3 then
				flag4 = false
			end

			if flag4 then
				applyShakeEffect(textLabel, uDim2) -- equivalent call inferred; original call site unknown
			end

			if entry.char == " " then
				task.wait(v2 * 0.3)
			else
				if children then
					fx:PlaySound(children[math.random(1, #children)], cutsceneDialog, true)
				end

				task.wait(v2)
			end
		end
	end
end

local CutsceneDialogController = {}

function CutsceneDialogController.CreateNewDialog(_, data)
	local characters = data.Characters
	local font = data.Font or gothamBold
	local textSize = data.TextSize or 22
	local v = data.UseUIStroke == nil or data.UseUIStroke
	local clones = {}
	local v2 = {
		Start = function(_)
			cutsceneDialog.Enabled = true

			for _, frame in main:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end

			table.clear(clones)
			clearActiveEffects() -- equivalent call inferred; original call site unknown
		end
	}
	local v3 = 0

	function v2.SayAsync(_, p: string, p2: string, p3: number?)
		local character = characters[p]

		if not character then
			warn("[CutsceneDialogController] Unknown character: " .. p)
			return
		end

		if v3 > 0 then
			slideExistingLinesUp(main, v3)
		end

		local clone = template2:Clone()
		clone.Visible = true
		clone.Name = "Line"
		clone.Position = uDim
		table.insert(clones, clone)

		if #clones > 3 then
			fadeOutLine(table.remove(clones, 1))
		end

		local title = clone:FindFirstChild("Title")

		if title then
			title.Text = character.Title
			title.TextColor3 = character.Color
			local uIStroke = title:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				uIStroke.Transparency = v and 0 or 1
			end
		end

		local displayText = clone:FindFirstChild("DisplayText")

		if displayText then
			clone.Parent = main
			task.wait()
			local X = displayText.AbsoluteSize.X
			local v5 = #buildLines(parseTaggedText(p2), font, textSize, X)
			local v6 = textSize * 1.3
			v3 = textSize + 4 + v5 * v6 + 15
			animateLetters(displayText, p2, font, textSize, v, character.Color, p3, character.Voice)
		end

		task.wait(0.5)
	end

	function v2.Wait(_, duration: number)
		task.wait(duration)
	end

	function v2:Destroy()
		clearActiveEffects() -- equivalent call inferred; original call site unknown

		for _, v4 in clones do
			fadeOutLine(v4)
		end

		table.clear(clones)
		task.wait(0.4)

		for _, frame in main:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		cutsceneDialog.Enabled = false
	end

	return v2
end

function CutsceneDialogController.Start(_)
	cutsceneDialog = playerGui:WaitForChild("CutsceneDialog")
	main = cutsceneDialog:WaitForChild("Main")
	template = main:WaitForChild("Template")
	template2 = template:WaitForChild("Template")
	cutsceneDialog.Enabled = false
end

return CutsceneDialogController