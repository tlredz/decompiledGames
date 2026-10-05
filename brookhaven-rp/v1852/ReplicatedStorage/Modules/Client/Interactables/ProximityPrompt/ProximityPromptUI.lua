local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Ripple = require(ReplicatedStorage.Packages.Ripple)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ProximityPromptShared = require(script.Parent.Parent.ProximityPromptShared)
local E = Enum.KeyCode.E
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(0, 0, 0)
local color3 = Color3.fromRGB(255, 70, 70)
local rbxassetfontsfamiliesFredokaOnejson = Font.new(
	"rbxasset://fonts/families/FredokaOne.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)
local rbxassetfontsfamiliesFredokaOnejson2 = Font.new(
	"rbxasset://fonts/families/FredokaOne.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function remapProgress(p: number, p2: number, p3: number)
	if p3 <= p2 then
		if p3 <= p then
			return 1
		end

		return 0
	else
		return (math.clamp((p - p2) / (p3 - p2), 0, 1))
	end
end

local function getTemplate()
	local radialInteractGui = ReplicatedStorage:FindFirstChild("RadialInteractGui")
	local v

	if radialInteractGui == nil then
		v = false
	else
		v = radialInteractGui:IsA("BillboardGui")
	end

	assert(v, "ReplicatedStorage.RadialInteractGui missing")
	return radialInteractGui
end

local function readLayoutMetrics(instance)
	local scale = instance.Size.Y.Scale
	local billboardHeight = scale <= 0 and 2 or scale
	local content = instance:FindFirstChild("Content")
	local circle

	if content ~= nil then
		circle = content:FindFirstChild("Circle")
	end

	local textFrame

	if content ~= nil then
		textFrame = content:FindFirstChild("TextFrame")
	end

	local key

	if textFrame ~= nil then
		key = textFrame:FindFirstChild("Key")
	end

	local circleSizeScale = (circle == nil or not (circle:IsA("GuiObject") and circle.Size.Y.Scale > 0)) and 0.35 or circle.Size.Y.Scale
	local textFrameHeightScale = (textFrame == nil or not (textFrame:IsA("GuiObject") and textFrame.Size.Y.Scale > 0)) and 0.35 or textFrame.Size.Y.Scale
	local scale2 = 0.7
	local fontFace = rbxassetfontsfamiliesFredokaOnejson

	if key ~= nil and key:IsA("TextLabel") then
		if key.Size.Y.Scale > 0 then
			scale2 = key.Size.Y.Scale
		end

		fontFace = key.FontFace
	end

	local circleStuds = billboardHeight * circleSizeScale
	return {
		billboardHeight = billboardHeight,
		minWidth = circleStuds + 0.08 + 0.4 + 0.6 + 0.12,
		maxWidth = billboardHeight * 3.6,
		circleSizeScale = circleSizeScale,
		circleStuds = circleStuds,
		textFrameHeightScale = textFrameHeightScale,
		labelHeightScale = scale2,
		fontFace = fontFace
	}
end

local function measureTextWidthStuds(text: string, data)
	if text == "" then
		return 0
	end

	local v = data.billboardHeight * data.textFrameHeightScale * data.labelHeightScale

	if v <= 0 then
		return 0
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text
	getTextBoundsParams.Font = data.fontFace
	getTextBoundsParams.Size = 100
	getTextBoundsParams.Width = 1e999
	local success, result = pcall(function()
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)

	if success and typeof(result) == "Vector2" then
		return v * (result.X / math.max(result.Y, 1)) * 1
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function paddedLabelWidthStuds(p: number)
	return math.max(0.4, p) + 0.6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function measureBillboardWidth(p: number, data)
	return (math.clamp(data.circleStuds + 0.08 + paddedLabelWidthStuds(p) + 0.12, data.minWidth, data.maxWidth))
end

return {
	Create = function(instance, p2: string, callback)
		local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui == nil then
			return nil
		end

		local text2 = p2
		local v2 = {}
		local v3 = {}
		local v4 = callback
		local maid = Janitor.new()
		local radialInteractGui = ReplicatedStorage:FindFirstChild("RadialInteractGui")
		local v5

		if radialInteractGui == nil then
			v5 = false
		else
			v5 = radialInteractGui:IsA("BillboardGui")
		end

		assert(v5, "ReplicatedStorage.RadialInteractGui missing")
		local gui = maid:Add(radialInteractGui:Clone())
		local v7 = readLayoutMetrics(gui)
		local billboardHeight = v7.billboardHeight
		local circleSizeScale = v7.circleSizeScale
		local minWidth = v7.minWidth
		local v8 = measureTextWidthStuds(text2, v7)
		local v9 = math.clamp(v7.circleStuds + 0.08 + paddedLabelWidthStuds(v8) + 0.12, v7.minWidth, v7.maxWidth)
		v2[text2] = v9
		v3[text2] = v8
		gui.Name = "ProximityPrompt"
		gui.Enabled = true
		gui.Adornee = ProximityPromptShared.resolveAdornee(instance)
		gui.StudsOffset = createVector(0, 2.5, 0)
		gui.ClipsDescendants = false
		gui.ResetOnSpawn = false
		gui.AlwaysOnTop = true
		gui.LightInfluence = 0
		gui.Active = true
		gui.Size = UDim2.fromScale(minWidth, billboardHeight)
		local content = gui:WaitForChild("Content")
		local uIScale = content:FindFirstChildOfClass("UIScale")

		if uIScale ~= nil then
			uIScale:Destroy()
		end

		local circle = content:WaitForChild("Circle")
		local uICorner = circle:WaitForChild("UICorner")
		local key = circle:WaitForChild("Key")
		local tapIcon = circle:WaitForChild("TapIcon")
		local textFrame = content:WaitForChild("TextFrame")
		local key2 = textFrame:WaitForChild("Key")
		local tapIcon2 = textFrame:FindFirstChild("TapIcon")

		if tapIcon2 ~= nil and tapIcon2:IsA("GuiObject") then
			tapIcon2.Visible = false
		end

		local name = content:FindFirstChild("Name")

		if name ~= nil and name:IsA("GuiObject") then
			name.Visible = false
		end

		if CollectionService:HasTag(key2, "ConsoleGlyphImage") then
			CollectionService:RemoveTag(key2, "ConsoleGlyphImage")
		end

		key2:SetAttribute("ConsoleGlyphKeyCode", nil)
		local consoleGlyphImageOverlay = key2:FindFirstChild("ConsoleGlyphImageOverlay")

		if consoleGlyphImageOverlay ~= nil then
			consoleGlyphImageOverlay:Destroy()
		end

		key.Text = UserInputService:GetStringForKeyCode(E)
		key.FontFace = rbxassetfontsfamiliesFredokaOnejson2
		key.TextColor3 = color3
		key.TextTransparency = 0
		key.Visible = false
		tapIcon.Visible = false
		tapIcon.ImageTransparency = 1
		key2.Text = text2
		key2.FontFace = rbxassetfontsfamiliesFredokaOnejson
		key2.TextColor3 = color2
		key2.TextTransparency = 0
		key2.Visible = false
		key2.AnchorPoint = Vector2.new(0, 0.5)
		key2.TextXAlignment = Enum.TextXAlignment.Center
		textFrame.BackgroundColor3 = color
		textFrame.BackgroundTransparency = 1
		gui.Parent = playerGui
		circle.Size = UDim2.fromScale(circleSizeScale, circleSizeScale)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Position = UDim2.fromScale(0.5, 0.5)
		circle.BackgroundColor3 = color
		circle.BackgroundTransparency = 0
		circle.ClipsDescendants = true
		uICorner.CornerRadius = UDim.new(1, 0)
		content.GroupTransparency = 1
		local tween = Ripple.createTween(0, {
			easing = "quadOut",
			duration = 0.4,
			start = true
		})
		maid:Add(tween, "destroy")
		local tween2 = Ripple.createTween(1, {
			easing = "quadOut",
			duration = 0.18,
			start = true
		})
		maid:Add(tween2, "destroy")
		local tween3 = Ripple.createTween(1, {
			easing = "quadOut",
			duration = 0.18,
			start = true
		})
		maid:Add(tween3, "destroy")
		local v10 = false
		local flag = false
		local flag2 = false
		local v11 = nil
		local v12 = 0
		local textButton = Instance.new("TextButton")
		textButton.Name = "HitButton"
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Position = UDim2.fromScale(0.5, 0.5)
		textButton.AnchorPoint = Vector2.new(0.5, 0.5)
		textButton.BackgroundTransparency = 1
		textButton.Text = ""
		textButton.ZIndex = 10
		textButton.Parent = content
		maid:Add(textButton.Activated:Connect(function()
			if not v10 then
				return
			end

			if v4 ~= nil then
				v4()
			end
		end))

		local function applyExpandProgress(p3: number)
			local v13 = math.clamp((p3 - 0) / 0.65, 0, 1)
			local v14 = math.clamp((p3 - 0.2) / 0.8, 0, 1)
			local minWidth2 = minWidth
			local v16 = minWidth2 + (v9 - minWidth2) * v14
			gui.Size = UDim2.fromScale(v16, billboardHeight)
			local v17 = v13 * -0.5 + 0.5
			circle.AnchorPoint = Vector2.new(v17, 0.5)
			circle.Position = UDim2.fromScale(v13 * -0.5 + 0.5, 0.5)
			circle.Size = UDim2.fromScale(circleSizeScale, circleSizeScale)
			textFrame.BackgroundTransparency = v14 * -0.65 + 1
			local v18 = v7.circleStuds + 0.08
			local v19 = math.min(math.max(0.05, v16 - v18 - 0.12), paddedLabelWidthStuds(v8))
			key2.Position = UDim2.fromScale(v18 / v16, 0.5)
			key2.Size = UDim2.fromScale(v19 / v16, v7.labelHeightScale)
			local v20 = math.clamp((v14 - 0.82) / 0.18000000000000005, 0, 1)

			if v10 and v20 >= 0.99 then
				key2.Visible = true
				key2.TextTransparency = 0
			else
				key2.Visible = v20 > 0
				key2.TextTransparency = v20 * -1 + 1
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ensurePromptTextVisible()
			if not v10 then
				return
			end

			key2.Visible = true
			key2.TextTransparency = 0
		end

		local function setKeyTransparency(p3: number)
			if Platform.IsMobile() then
				key.TextTransparency = 1
				tapIcon.ImageTransparency = p3
			elseif Platform.IsConsole() then
				key.TextTransparency = 1
				tapIcon.ImageTransparency = 1
				local consoleGlyphImageOverlay2 = key:FindFirstChild("ConsoleGlyphImageOverlay")

				if consoleGlyphImageOverlay2 ~= nil and consoleGlyphImageOverlay2:IsA("ImageLabel") then
					consoleGlyphImageOverlay2.ImageTransparency = p3
				end
			else
				key.TextTransparency = p3
				tapIcon.ImageTransparency = 1
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshMeasuredWidth(text: string)
			local v13 = v2[text]
			local v14 = v3[text]

			if v13 == nil or v14 == nil then
				task.spawn(function()
					local v15 = measureTextWidthStuds(text, v7)
					local billboardWidth = measureBillboardWidth(v15, v7) -- equivalent call inferred; original call site unknown

					if flag or text2 ~= text then
						return
					end

					v2[text] = billboardWidth
					v3[text] = v15
					v9 = billboardWidth
					v8 = v15
					applyExpandProgress(v12)
				end)
				return
			end

			v9 = v13
			v8 = v14
			applyExpandProgress(v12)
		end

		local v13 = {
			Instance = instance,
			Gui = gui,
			RefreshInputIcons = function(self)
				if flag2 then
					if Platform.IsMobile() then
						key.Visible = false
						tapIcon.Visible = true
					else
						key.Visible = true
						key.Text = UserInputService:GetStringForKeyCode(E)
						tapIcon.Visible = false
					end

					setKeyTransparency(tween2:getPosition())
				else
					key.Visible = false
					tapIcon.Visible = false
					setKeyTransparency(1)
				end
			end,
			SetExpanded = function(self, flag3: boolean)
				if flag or v10 == flag3 then
					return
				end

				v10 = flag3
				tween:setGoal(flag3 and 1 or 0, {
					easing = flag3 and "quadOut" or "quadIn",
					duration = 0.4
				})

				if not flag3 and flag2 then
					flag2 = false
					key.Visible = false
					tapIcon.Visible = false
					tween2:setGoal(1, {
						easing = "quadIn",
						duration = 0.18
					})
				end
			end,
			SetPromptText = function(_, text: string)
				if text2 == text then
					return
				end

				text2 = text
				key2.Text = text
				refreshMeasuredWidth(text) -- equivalent call inferred; original call site unknown
			end,
			SetOnActivated = function(_, callback2)
				v4 = callback2
			end,
			FadeIn = function(self)
				if flag then
					return
				end

				v11 = nil
				gui.Enabled = true
				tween3:setGoal(0, {
					easing = "quadOut",
					duration = 0.18
				})
			end,
			FadeOut = function(_, callback2)
				if flag then
					return
				end

				v11 = callback2
				tween3:setGoal(1, {
					easing = "quadIn",
					duration = 0.18
				})
			end
		}

		function v13.CancelAnimations(_)
			if flag then
				return
			end

			v11 = nil
			local v14 = v10 and 1 or 0
			tween:setPosition(v14)
			v12 = v14
			applyExpandProgress(v12)
			tween3:setPosition(0)
			content.GroupTransparency = 0
			gui.Enabled = true

			if v10 == true then
				flag2 = true
				tween2:setPosition(0)
				v13:RefreshInputIcons()
				ensurePromptTextVisible() -- equivalent call inferred; original call site unknown
			end
		end

		function v13:Destroy()
			if flag then
				return
			end

			flag = true
			v11 = nil
			task.defer(function()
				maid:Destroy()
			end)
		end

		maid:Add(tween:onChange(function(value: number)
			if flag then
				return
			end

			v12 = math.clamp(value, 0, 1)
			applyExpandProgress(v12)

			if v10 then
				if flag2 or v12 < 0.45 then
					return
				end

				flag2 = true
				tween2:setPosition(1)
				v13:RefreshInputIcons()
				tween2:setGoal(0, {
					easing = "quadOut",
					duration = 0.18
				})
			end
		end))
		maid:Add(tween2:onChange(function(p3: number)
			if flag then
				return
			end

			if flag2 then
				setKeyTransparency(p3)
			end
		end))
		maid:Add(tween3:onChange(function(groupTransparency: number)
			if flag then
				return
			end

			content.GroupTransparency = groupTransparency
		end))
		maid:Add(tween3:onComplete(function(p3: number)
			if flag then
				return
			end

			if p3 >= 0.999 and v11 ~= nil then
				local v14 = v11
				v11 = nil
				task.defer(v14)
			end
		end))
		maid:Add(Platform.PlatformChangedSignal:Connect(function()
			v13:RefreshInputIcons()
			ensurePromptTextVisible() -- equivalent call inferred; original call site unknown
		end))
		maid:Add(UserInputService.LastInputTypeChanged:Connect(function()
			if flag2 then
				v13:RefreshInputIcons()
			end

			ensurePromptTextVisible() -- equivalent call inferred; original call site unknown
		end))
		applyExpandProgress(0)
		v13:SetExpanded(false)
		v13:FadeIn()
		return v13
	end
}