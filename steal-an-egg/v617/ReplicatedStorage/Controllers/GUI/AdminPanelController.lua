local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local AdminPanelEntry = require(ReplicatedStorage.Client.AdminPanelEntry)
local Assets = require(ReplicatedStorage.Data.Assets)
local personalities = Assets.Personalities
local Assets2 = require(ReplicatedStorage.Data.Assets)
require(ReplicatedStorage.Shared.Globals.Constants)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local parse = Numbers.Parse
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local directory = Assets2.Directory
local AssetEarnings = require(ReplicatedStorage.Shared.Util.AssetEarnings)
require(ReplicatedStorage.Shared.Types.AssetItem)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Log = require(ReplicatedStorage.Packages.Log)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local uDim = UDim2.fromOffset(900, 600)
local v = Log.new()
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		local id = nil
		local v2 = {}
		local v3 = "Assets"
		local v4 = false
		local v5 = false
		local v6 = false

		local function clearGradients(textLabel)
			for _, uIGradient in ipairs(textLabel:GetChildren()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient:Destroy()
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function roundToStep(p: number, p2: number)
			return math.round(p / p2) * p2
		end

		local function formatWalkSpeedDisplay(p: number)
			local v7 = roundToStep(p, 0.1) -- equivalent call inferred; original call site unknown
			local v8 = string.format("%.1f", v7)

			if string.sub(v8, -2) == ".0" then
				return (string.sub(v8, 1, #v8 - 2))
			end

			return v8
		end

		local function formatSpeedPowerDisplay(p: number)
			return string.format("%.0f", (math.round(p)))
		end

		local function parseNumericInput(p: string)
			local parsed = parse(p)

			if typeof(parsed) == "number" then
				return parsed
			end

			return (tonumber(p))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function trimText(value: string)
			return string.match(value, "^%s*(.-)%s*$") or ""
		end

		local function parseOptionalNumberInput(value: string)
			local v7 = trimText(value) -- equivalent call inferred; original call site unknown

			if v7 == "" then
				return nil, true
			end

			local parsed = parse(v7)

			if typeof(parsed) ~= "number" then
				parsed = tonumber(v7)
			end

			return parsed, parsed ~= nil
		end

		local function updateSliderVisual(state, p: number)
			local step = state.Step
			local currentValue = math.clamp(roundToStep(p, step), state.MinValue, state.MaxValue)
			local v8 = math.max(state.MaxValue - state.MinValue, 0.0001)
			local v9 = math.clamp((currentValue - state.MinValue) / v8, 0, 1)
			state.CurrentValue = currentValue
			state.Fill.Size = UDim2.fromScale(v9, 1)
			state.Knob.Position = UDim2.fromScale(v9, 0.5)
			state.ValueLabel.Text = state.FormatDisplay(currentValue)
			state.Input.Text = state.FormatInput(currentValue)
		end

		local function createSliderControl(frame, p: string, text: string, p2: number, p3: number, maxValue: number, step: number, formatDisplay, callback2)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = `{p}Label`
			textLabel.Size = UDim2.fromOffset(190, 18)
			textLabel.Position = UDim2.fromOffset(690, p2)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = text
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextSize = 15
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Parent = frame
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = `{p}Value`
			textLabel2.Size = UDim2.fromOffset(190, 16)
			textLabel2.Position = UDim2.fromOffset(690, p2 + 18)
			textLabel2.BackgroundTransparency = 1
			textLabel2.Text = "0"
			textLabel2.TextColor3 = Color3.fromRGB(145, 232, 181)
			textLabel2.TextSize = 13
			textLabel2.Font = Enum.Font.Gotham
			textLabel2.TextXAlignment = Enum.TextXAlignment.Left
			textLabel2.Parent = frame
			local textButton = Instance.new("TextButton")
			textButton.Name = `{p}Track`
			textButton.Size = UDim2.fromOffset(124, 16)
			textButton.Position = UDim2.fromOffset(690, p2 + 40)
			textButton.BackgroundColor3 = Color3.fromRGB(31, 45, 71)
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.Parent = frame
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(1, 0)
			uICorner.Parent = textButton
			local frame2 = Instance.new("Frame")
			frame2.Name = "Fill"
			frame2.Size = UDim2.fromScale(0, 1)
			frame2.BackgroundColor3 = Color3.fromRGB(36, 114, 84)
			frame2.BorderSizePixel = 0
			frame2.Parent = textButton
			local uICorner2 = Instance.new("UICorner")
			uICorner2.CornerRadius = UDim.new(1, 0)
			uICorner2.Parent = frame2
			local frame3 = Instance.new("Frame")
			frame3.Name = "Knob"
			frame3.AnchorPoint = Vector2.new(0.5, 0.5)
			frame3.Size = UDim2.fromOffset(14, 14)
			frame3.Position = UDim2.fromScale(0, 0.5)
			frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			frame3.BorderSizePixel = 0
			frame3.Parent = textButton
			local uICorner3 = Instance.new("UICorner")
			uICorner3.CornerRadius = UDim.new(1, 0)
			uICorner3.Parent = frame3
			local textBox = Instance.new("TextBox")
			textBox.Name = `{p}Input`
			textBox.Size = UDim2.fromOffset(58, 28)
			textBox.Position = UDim2.fromOffset(822, p2 + 34)
			textBox.BackgroundColor3 = Color3.fromRGB(31, 45, 71)
			textBox.BorderSizePixel = 0
			textBox.Text = "0"
			textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			textBox.TextSize = 15
			textBox.Font = Enum.Font.Gotham
			textBox.ClearTextOnFocus = false
			textBox.Parent = frame
			local uICorner4 = Instance.new("UICorner")
			uICorner4.CornerRadius = UDim.new(0, 6)
			uICorner4.Parent = textBox
			return {
				Label = textLabel,
				TrackButton = textButton,
				Fill = frame2,
				Knob = frame3,
				Input = textBox,
				ValueLabel = textLabel2,
				MinValue = p3,
				MaxValue = maxValue,
				Step = step,
				CurrentValue = p3,
				FormatDisplay = formatDisplay,
				FormatInput = callback2
			}
		end

		local function createLabelInput(frame, p: string, text: string, p2: number)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = `{p}Label`
			textLabel.Size = UDim2.fromOffset(190, 18)
			textLabel.Position = UDim2.fromOffset(690, p2)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = text
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextSize = 14
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Parent = frame
			local textBox = Instance.new("TextBox")
			textBox.Name = `{p}Input`
			textBox.Size = UDim2.fromOffset(190, 32)
			textBox.Position = UDim2.fromOffset(690, p2 + 20)
			textBox.BackgroundColor3 = Color3.fromRGB(31, 45, 71)
			textBox.BorderSizePixel = 0
			textBox.Text = ""
			textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			textBox.PlaceholderColor3 = Color3.fromRGB(156, 168, 188)
			textBox.TextSize = 15
			textBox.Font = Enum.Font.Gotham
			textBox.ClearTextOnFocus = false
			textBox.Parent = frame
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 6)
			uICorner.Parent = textBox
			return textLabel, textBox
		end

		local function buildRarityChancePercentById()
			return {}
		end

		local function buildAssetRows()
			local v7 = {}
			local result = {}

			for k, v9 in pairs(directory) do
				local dropWeight = v9.DropWeight or 0
				local rarity = v9.Rarity

				if not rarity then
					continue
				end

				local displayName = rarity.DisplayName or rarity._id or "Unknown"
				local _id = rarity._id or displayName
				local newItemData = personalities.CreateNewItemData({
					Category = k,
					Mutations = {},
					Scale = 1,
					Personality = "Normal",
					HasBeenFirstPlaced = false
				})
				local ratePerSecond = AssetEarnings.RatePerSecond(newItemData)
				v7[_id] = (v7[_id] or 0) + dropWeight
				table.insert(result, {
					Id = k,
					DisplayName = v9.DisplayName or k,
					Icon = v9.Icon or "",
					RarityId = _id,
					RarityName = displayName,
					Rank = rarity.Rank or 0,
					RarityGradient = rarity.RarityGradient,
					MoneyPerSecond = ratePerSecond,
					DropWeight = dropWeight,
					InRarityDropChancePercent = 0
				})
			end

			for _, v9 in ipairs(result) do
				local v10 = v7[v9.RarityId] or 0

				if v10 > 0 then
					v9.InRarityDropChancePercent = v9.DropWeight / v10 * 100
				end
			end

			table.sort(result, function(a, b)
				if a.Rank ~= b.Rank then
					return a.Rank > b.Rank
				end

				if a.MoneyPerSecond == b.MoneyPerSecond then
					return a.DisplayName < b.DisplayName
				end

				return a.MoneyPerSecond > b.MoneyPerSecond
			end)
			return result, {}
		end

		local v7 = {
			Sakura = true,
			GreatBloom = true,
			Monstrous = true
		}

		local function buildMutationNames()
			local all = Mutations.All()
			local result = {}

			for k, v8 in pairs(all) do
				if v8.RollWeight > 0 or v7[k] then
					table.insert(result, k)
				end
			end

			table.sort(result)
			return result
		end

		local function createAdminPanel()
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "AdminPanel"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.Parent = playerGui
			local textButton = Instance.new("TextButton")
			textButton.Name = "Toggle"
			textButton.Size = UDim2.fromScale(0.1, 0.05)
			textButton.AnchorPoint = Vector2.new(0, 0.5)
			textButton.Position = UDim2.new(0, 12, 0.75, 0)
			textButton.BackgroundColor3 = Color3.fromRGB(31, 45, 71)
			textButton.BorderSizePixel = 0
			textButton.Text = "Admin"
			textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			textButton.TextSize = 20
			textButton.Font = Enum.Font.GothamBold
			textButton.Parent = screenGui
			local frame = Instance.new("Frame")
			frame.Name = "Panel"
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.Size = uDim
			frame.Position = UDim2.fromScale(0.5, 0.5)
			frame.BackgroundColor3 = Color3.fromRGB(18, 24, 35)
			frame.BorderSizePixel = 0
			frame.Visible = false
			frame.Parent = screenGui
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 10)
			uICorner.Parent = frame
			local uIDragDetector = Instance.new("UIDragDetector")
			uIDragDetector.Parent = frame
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Title"
			textLabel.Size = UDim2.new(1, -60, 0, 42)
			textLabel.Position = UDim2.fromOffset(18, 8)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = "Admin Asset Grant"
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextSize = 25
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.Parent = frame
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "CloseButton"
			textButton2.Size = UDim2.fromOffset(34, 34)
			textButton2.Position = UDim2.new(1, -42, 0, 8)
			textButton2.BackgroundColor3 = Color3.fromRGB(117, 38, 46)
			textButton2.BorderSizePixel = 0
			textButton2.Text = "X"
			textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
			textButton2.TextSize = 22
			textButton2.Font = Enum.Font.GothamBold
			textButton2.Parent = frame
			local uICorner2 = Instance.new("UICorner")
			uICorner2.CornerRadius = UDim.new(0, 6)
			uICorner2.Parent = textButton2
			local textButton3 = Instance.new("TextButton")
			textButton3.Name = "AssetTabButton"
			textButton3.Size = UDim2.fromOffset(94, 32)
			textButton3.Position = UDim2.fromOffset(456, 18)
			textButton3.BackgroundColor3 = Color3.fromRGB(36, 114, 84)
			textButton3.BorderSizePixel = 0
			textButton3.Text = "Assets"
			textButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
			textButton3.TextSize = 14
			textButton3.Font = Enum.Font.GothamBold
			textButton3.Parent = frame
			local uICorner3 = Instance.new("UICorner")
			uICorner3.CornerRadius = UDim.new(0, 7)
			uICorner3.Parent = textButton3
			local textButton4 = Instance.new("TextButton")
			textButton4.Name = "EggTabButton"
			textButton4.Size = UDim2.fromOffset(94, 32)
			textButton4.Position = UDim2.fromOffset(558, 18)
			textButton4.BackgroundColor3 = Color3.fromRGB(37, 47, 66)
			textButton4.BorderSizePixel = 0
			textButton4.Text = "Eggs"
			textButton4.TextColor3 = Color3.fromRGB(255, 255, 255)
			textButton4.TextSize = 14
			textButton4.Font = Enum.Font.GothamBold
			textButton4.Parent = frame
			local uICorner4 = Instance.new("UICorner")
			uICorner4.CornerRadius = UDim.new(0, 7)
			uICorner4.Parent = textButton4
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "AssetList"
			scrollingFrame.Size = UDim2.fromOffset(430, 520)
			scrollingFrame.Position = UDim2.fromOffset(16, 60)
			scrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 33, 47)
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.ScrollBarThickness = 7
			scrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
			scrollingFrame.Parent = frame
			local uICorner5 = Instance.new("UICorner")
			uICorner5.CornerRadius = UDim.new(0, 8)
			uICorner5.Parent = scrollingFrame
			local scrollingFrame2 = Instance.new("ScrollingFrame")
			scrollingFrame2.Name = "MutationList"
			scrollingFrame2.Size = UDim2.fromOffset(220, 300)
			scrollingFrame2.Position = UDim2.fromOffset(456, 60)
			scrollingFrame2.BackgroundColor3 = Color3.fromRGB(25, 33, 47)
			scrollingFrame2.BorderSizePixel = 0
			scrollingFrame2.ScrollBarThickness = 7
			scrollingFrame2.CanvasSize = UDim2.fromOffset(0, 0)
			scrollingFrame2.Parent = frame
			local uICorner6 = Instance.new("UICorner")
			uICorner6.CornerRadius = UDim.new(0, 8)
			uICorner6.Parent = scrollingFrame2
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "SelectedLabel"
			textLabel2.Size = UDim2.fromOffset(220, 50)
			textLabel2.Position = UDim2.fromOffset(456, 368)
			textLabel2.BackgroundTransparency = 1
			textLabel2.Text = "Selected: None"
			textLabel2.TextColor3 = Color3.fromRGB(226, 230, 236)
			textLabel2.TextSize = 16
			textLabel2.Font = Enum.Font.Gotham
			textLabel2.TextWrapped = true
			textLabel2.TextXAlignment = Enum.TextXAlignment.Left
			textLabel2.TextYAlignment = Enum.TextYAlignment.Top
			textLabel2.Parent = frame
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "MutationSelectionLabel"
			textLabel3.Size = UDim2.fromOffset(220, 50)
			textLabel3.Position = UDim2.fromOffset(456, 420)
			textLabel3.BackgroundTransparency = 1
			textLabel3.Text = "Mutations: None"
			textLabel3.TextColor3 = Color3.fromRGB(226, 230, 236)
			textLabel3.TextSize = 16
			textLabel3.Font = Enum.Font.Gotham
			textLabel3.TextWrapped = true
			textLabel3.TextXAlignment = Enum.TextXAlignment.Left
			textLabel3.TextYAlignment = Enum.TextYAlignment.Top
			textLabel3.Parent = frame
			local textLabel4 = Instance.new("TextLabel")
			textLabel4.Name = "ScaleLabel"
			textLabel4.Size = UDim2.fromOffset(190, 20)
			textLabel4.Position = UDim2.fromOffset(690, 142)
			textLabel4.BackgroundTransparency = 1
			textLabel4.Text = "Size Scale"
			textLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel4.TextSize = 15
			textLabel4.Font = Enum.Font.GothamBold
			textLabel4.TextXAlignment = Enum.TextXAlignment.Left
			textLabel4.Parent = frame
			local textBox = Instance.new("TextBox")
			textBox.Name = "ScaleInput"
			textBox.Size = UDim2.fromOffset(190, 34)
			textBox.Position = UDim2.fromOffset(690, 166)
			textBox.BackgroundColor3 = Color3.fromRGB(31, 45, 71)
			textBox.BorderSizePixel = 0
			textBox.Text = ""
			textBox.PlaceholderText = "blank = roll"
			textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			textBox.PlaceholderColor3 = Color3.fromRGB(156, 168, 188)
			textBox.TextSize = 17
			textBox.Font = Enum.Font.Gotham
			textBox.ClearTextOnFocus = false
			textBox.Parent = frame
			local uICorner7 = Instance.new("UICorner")
			uICorner7.CornerRadius = UDim.new(0, 6)
			uICorner7.Parent = textBox
			local labelInput, colorIndexInput = createLabelInput(frame, "ColorIndex", "Color Index Override", 218)
			colorIndexInput.PlaceholderText = "blank = roll"
			local labelInput2, colorSeedInput = createLabelInput(frame, "ColorSeed", "Color Seed Override", 274)
			colorSeedInput.PlaceholderText = "blank = roll"
			local labelInput3, eyeColorInput = createLabelInput(frame, "EyeColor", "Eye Hex Override", 330)
			eyeColorInput.PlaceholderText = "blank = roll"
			local sliderControl = createSliderControl(
				frame,
				"WalkSpeed",
				"Walk Speed",
				220,
				0,
				1000,
				0.1,
				formatWalkSpeedDisplay,
				formatWalkSpeedDisplay
			)
			local sliderControl2 = createSliderControl(
				frame,
				"SpeedPower",
				"Speed Value",
				288,
				0,
				1e18,
				1,
				TreadmillUtil.FormatSpeedPower,
				formatSpeedPowerDisplay
			)
			local textButton5 = Instance.new("TextButton")
			textButton5.Name = "GiveButton"
			textButton5.Size = UDim2.fromOffset(190, 46)
			textButton5.Position = UDim2.fromOffset(690, 446)
			textButton5.BackgroundColor3 = Color3.fromRGB(36, 114, 84)
			textButton5.BorderSizePixel = 0
			textButton5.Text = "Give Selected Asset"
			textButton5.TextColor3 = Color3.fromRGB(255, 255, 255)
			textButton5.TextSize = 17
			textButton5.Font = Enum.Font.GothamBold
			textButton5.Parent = frame
			local uICorner8 = Instance.new("UICorner")
			uICorner8.CornerRadius = UDim.new(0, 8)
			uICorner8.Parent = textButton5
			local textLabel5 = Instance.new("TextLabel")
			textLabel5.Name = "StatusLabel"
			textLabel5.Size = UDim2.fromOffset(190, 42)
			textLabel5.Position = UDim2.fromOffset(690, 498)
			textLabel5.BackgroundTransparency = 1
			textLabel5.Text = "Ready."
			textLabel5.TextWrapped = true
			textLabel5.TextColor3 = Color3.fromRGB(226, 230, 236)
			textLabel5.TextSize = 15
			textLabel5.Font = Enum.Font.Gotham
			textLabel5.TextXAlignment = Enum.TextXAlignment.Left
			textLabel5.TextYAlignment = Enum.TextYAlignment.Top
			textLabel5.Parent = frame
			local textButton6 = Instance.new("TextButton")
			textButton6.Name = "ResetDataButton"
			textButton6.Size = UDim2.fromOffset(190, 44)
			textButton6.Position = UDim2.fromOffset(690, 546)
			textButton6.BackgroundColor3 = Color3.fromRGB(134, 46, 46)
			textButton6.BorderSizePixel = 0
			textButton6.Text = "Reset Data"
			textButton6.TextColor3 = Color3.fromRGB(255, 255, 255)
			textButton6.TextSize = 17
			textButton6.Font = Enum.Font.GothamBold
			textButton6.Parent = frame
			local uICorner9 = Instance.new("UICorner")
			uICorner9.CornerRadius = UDim.new(0, 8)
			uICorner9.Parent = textButton6
			return {
				screenGui = screenGui,
				panel = frame,
				title = textLabel,
				toggleButton = textButton,
				closeButton = textButton2,
				assetTabButton = textButton3,
				eggTabButton = textButton4,
				assetList = scrollingFrame,
				mutationList = scrollingFrame2,
				selectedLabel = textLabel2,
				mutationSelectionLabel = textLabel3,
				scaleLabel = textLabel4,
				scaleInput = textBox,
				colorIndexLabel = labelInput,
				colorIndexInput = colorIndexInput,
				colorSeedLabel = labelInput2,
				colorSeedInput = colorSeedInput,
				eyeColorLabel = labelInput3,
				eyeColorInput = eyeColorInput,
				walkSpeedControl = sliderControl,
				speedPowerControl = sliderControl2,
				giveButton = textButton5,
				resetButton = textButton6,
				statusLabel = textLabel5
			}
		end

		local function setupAdminPanel()
			local adminPanel = createAdminPanel()
			local v8 = {}
			local v9 = {}
			local visible2 = false
			local v11 = nil
			local v12 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setStatus(text: string, flag: boolean?)
				adminPanel.statusLabel.Text = text

				if flag == nil then
					adminPanel.statusLabel.TextColor3 = Color3.fromRGB(226, 230, 236)
				elseif flag then
					adminPanel.statusLabel.TextColor3 = Color3.fromRGB(145, 232, 181)
				else
					adminPanel.statusLabel.TextColor3 = Color3.fromRGB(255, 146, 146)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setSliderControlVisible(data, visible: boolean)
				data.Label.Visible = visible
				data.ValueLabel.Visible = visible
				data.TrackButton.Visible = visible
				data.Input.Visible = visible
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setEggOverrideControlsVisible(visible: boolean)
				adminPanel.colorIndexLabel.Visible = visible
				adminPanel.colorIndexInput.Visible = visible
				adminPanel.colorSeedLabel.Visible = visible
				adminPanel.colorSeedInput.Visible = visible
				adminPanel.eyeColorLabel.Visible = visible
				adminPanel.eyeColorInput.Visible = visible
			end

			local function applyGrantTabState(p: string)
				v3 = p
				local visible = p == "Eggs"
				adminPanel.title.Text = visible and "Admin Egg Grant" or "Admin Asset Grant"
				local assetTabButton = adminPanel.assetTabButton
				local backgroundColor

				if visible then
					backgroundColor = Color3.fromRGB(37, 47, 66)
				else
					backgroundColor = Color3.fromRGB(36, 114, 84)
				end

				assetTabButton.BackgroundColor3 = backgroundColor
				local eggTabButton = adminPanel.eggTabButton
				local backgroundColor2

				if visible then
					backgroundColor2 = Color3.fromRGB(36, 114, 84)
				else
					backgroundColor2 = Color3.fromRGB(37, 47, 66)
				end

				eggTabButton.BackgroundColor3 = backgroundColor2
				adminPanel.scaleLabel.Text = visible and "Egg Scale Override" or "Size Scale"
				adminPanel.scaleInput.PlaceholderText = "blank = roll"
				adminPanel.giveButton.Text = visible and "Give Selected Egg" or "Give Selected Asset"
				setSliderControlVisible(adminPanel.walkSpeedControl, not visible) -- equivalent call inferred; original call site unknown
				setSliderControlVisible(adminPanel.speedPowerControl, not visible) -- equivalent call inferred; original call site unknown
				setEggOverrideControlsVisible(visible) -- equivalent call inferred; original call site unknown

				if visible and adminPanel.scaleInput.Text == "1" then
					adminPanel.scaleInput.Text = ""
				elseif not visible and trimText(adminPanel.scaleInput.Text) == "1" then
					adminPanel.scaleInput.Text = ""
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function syncSpeedControlsFromSave(flag: boolean)
				local v13 = Save.Await()

				if not v13 then
					return
				end

				local speedPower = TreadmillUtil.NormalizeSpeedPower(v13.SpeedPower)
				updateSliderVisual(adminPanel.speedPowerControl, speedPower)

				if flag then
					local speedPowerToWalkSpeed = TreadmillUtil.SpeedPowerToWalkSpeed(speedPower)
					updateSliderVisual(adminPanel.walkSpeedControl, speedPowerToWalkSpeed)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setSliderValueFromTrack(data, p: number)
				local v13 = math.clamp(
					(p - data.TrackButton.AbsolutePosition.X) / math.max(data.TrackButton.AbsoluteSize.X, 1),
					0,
					1
				)
				updateSliderVisual(data, data.MinValue + (data.MaxValue - data.MinValue) * v13)
			end

			local function attachSliderBehavior(data, fn)
				data.TrackButton.MouseButton1Down:Connect(function(p: number)
					v11 = data
					v12 = fn
					setSliderValueFromTrack(data, p) -- equivalent call inferred; original call site unknown
				end)
				data.Input.FocusLost:Connect(function(flag: boolean)
					if not flag and data.Input.Text == data.FormatInput(data.CurrentValue) then
						return
					end

					local text = data.Input.Text
					local parsed = parse(text)

					if typeof(parsed) ~= "number" then
						parsed = tonumber(text)
					end

					if parsed == nil then
						updateSliderVisual(data, data.CurrentValue)
						setStatus("Enter a valid number.", false) -- equivalent call inferred; original call site unknown
					else
						updateSliderVisual(data, parsed)
						fn(data.CurrentValue)
					end
				end)
			end

			local function updateSelectedAssetState()
				for k, v13 in pairs(v8) do
					local backgroundColor

					if id == k then
						backgroundColor = Color3.fromRGB(36, 114, 84)
					else
						backgroundColor = Color3.fromRGB(37, 47, 66)
					end

					v13.BackgroundColor3 = backgroundColor
				end

				if not id then
					adminPanel.selectedLabel.Text = "Selected: None"
					return
				end

				local selectedLabel = adminPanel.selectedLabel
				local text

				if v3 == "Eggs" then
					text = `Selected egg: {id}`
				else
					text = `Selected asset: {id}`
				end

				selectedLabel.Text = text
			end

			local function updateMutationState()
				local v13 = {}

				for k, v14 in pairs(v2) do
					if v14 then
						table.insert(v13, k)
					end
				end

				table.sort(v13)

				for k, v14 in pairs(v9) do
					local backgroundColor

					if v2[k] then
						backgroundColor = Color3.fromRGB(126, 73, 153)
					else
						backgroundColor = Color3.fromRGB(37, 47, 66)
					end

					v14.BackgroundColor3 = backgroundColor
				end

				if #v13 == 0 then
					adminPanel.mutationSelectionLabel.Text = "Mutations: None"
				else
					adminPanel.mutationSelectionLabel.Text = `Mutations: {table.concat(v13, ", ")}`
				end
			end

			local assetRows, v13 = buildAssetRows()
			local rarityName = nil
			local total = 8
			local v14 = nil

			for _, assetRow in ipairs(assetRows) do
				if rarityName ~= assetRow.RarityName then
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = `Rarity_{assetRow.RarityName}`
					textLabel.Size = UDim2.new(1, -14, 0, 22)
					textLabel.Position = UDim2.fromOffset(7, total)
					textLabel.BackgroundTransparency = 1
					local v15 = v13[assetRow.RarityId] or 0
					textLabel.Text = `{assetRow.RarityName} ({string.format("%.2f%%", v15)})`
					textLabel.TextColor3 = Color3.fromRGB(193, 203, 219)
					textLabel.TextSize = 14
					textLabel.Font = Enum.Font.GothamBold
					textLabel.TextXAlignment = Enum.TextXAlignment.Left
					textLabel.Parent = adminPanel.assetList
					total += 24
					rarityName = assetRow.RarityName
				end

				local textButton = Instance.new("TextButton")
				textButton.Name = assetRow.Id
				textButton.Size = UDim2.new(1, -14, 0, 44)
				textButton.Position = UDim2.fromOffset(7, total)
				textButton.BackgroundColor3 = Color3.fromRGB(37, 47, 66)
				textButton.BorderSizePixel = 0
				textButton.Text = ""
				textButton.Parent = adminPanel.assetList
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0, 7)
				uICorner.Parent = textButton
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "Icon"
				imageLabel.Size = UDim2.fromOffset(34, 34)
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.Position = UDim2.fromOffset(5, 5)
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = assetRow.Icon
				imageLabel.Parent = textButton
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "Name"
				textLabel.Size = UDim2.new(1, -220, 1, 0)
				textLabel.Position = UDim2.fromOffset(44, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = assetRow.DisplayName
				textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				textLabel.TextSize = 14
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextXAlignment = Enum.TextXAlignment.Left
				textLabel.Parent = textButton
				clearGradients(textLabel)

				if assetRow.RarityGradient then
					local clone = assetRow.RarityGradient:Clone()
					clone.Parent = textLabel
				end

				local textLabel2 = Instance.new("TextLabel")
				textLabel2.Name = "MoneyPerSecond"
				textLabel2.Size = UDim2.fromOffset(170, 44)
				textLabel2.AnchorPoint = Vector2.new(1, 0)
				textLabel2.Position = UDim2.new(1, -6, 0, 0)
				textLabel2.BackgroundTransparency = 1
				textLabel2.Text = `{Simple.FormatCompact(assetRow.MoneyPerSecond, ".##")}/s | {string.format("%.2f%%", assetRow.InRarityDropChancePercent)}`
				textLabel2.TextColor3 = Color3.fromRGB(145, 232, 181)
				textLabel2.TextSize = 13
				textLabel2.Font = Enum.Font.Gotham
				textLabel2.TextXAlignment = Enum.TextXAlignment.Right
				textLabel2.Parent = textButton
				local v15 = assetRow
				textButton.MouseButton1Click:Connect(function()
					id = v15.Id
					updateSelectedAssetState()
				end)
				v8[assetRow.Id] = textButton
				total += 48
			end

			adminPanel.assetList.CanvasSize = UDim2.fromOffset(0, total + 4)
			local mutationNames = buildMutationNames()
			local total2 = 8

			for _, mutationName in ipairs(mutationNames) do
				local textButton = Instance.new("TextButton")
				textButton.Name = mutationName
				textButton.Size = UDim2.new(1, -14, 0, 32)
				textButton.Position = UDim2.fromOffset(7, total2)
				textButton.BackgroundColor3 = Color3.fromRGB(37, 47, 66)
				textButton.BorderSizePixel = 0
				textButton.Text = mutationName
				textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				textButton.TextSize = 14
				textButton.Font = Enum.Font.Gotham
				textButton.Parent = adminPanel.mutationList
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0, 7)
				uICorner.Parent = textButton
				local v15 = mutationName
				textButton.MouseButton1Click:Connect(function()
					v2[v15] = not v2[v15]
					updateMutationState()
				end)
				v9[mutationName] = textButton
				total2 += 36
			end

			adminPanel.mutationList.CanvasSize = UDim2.fromOffset(0, total2 + 4)
			adminPanel.assetTabButton.MouseButton1Click:Connect(function()
				applyGrantTabState("Assets")
				updateSelectedAssetState()
			end)
			adminPanel.eggTabButton.MouseButton1Click:Connect(function()
				applyGrantTabState("Eggs")
				updateSelectedAssetState()
			end)
			adminPanel.giveButton.MouseButton1Click:Connect(function()
				if id then
					local mutations = {}

					for k, v16 in pairs(v2) do
						if v16 then
							table.insert(mutations, k)
						end
					end

					table.sort(mutations)

					if v3 == "Eggs" then
						local v16 = trimText(adminPanel.scaleInput.Text) -- equivalent call inferred; original call site unknown
						local flag, parsed

						if v16 == "" then
							flag = true
						else
							parsed = parse(v16)

							if typeof(parsed) ~= "number" then
								parsed = tonumber(v16)
							end

							if parsed == nil then
								flag = false
							else
								flag = true
							end
						end

						if flag then
							local v17 = trimText(adminPanel.colorSeedInput.Text) -- equivalent call inferred; original call site unknown
							local flag2, parsed2

							if v17 == "" then
								flag2 = true
							else
								parsed2 = parse(v17)

								if typeof(parsed2) ~= "number" then
									parsed2 = tonumber(v17)
								end

								if parsed2 == nil then
									flag2 = false
								else
									flag2 = true
								end
							end

							if flag2 then
								local v18 = trimText(adminPanel.colorIndexInput.Text) -- equivalent call inferred; original call site unknown
								local flag3, parsed3

								if v18 == "" then
									flag3 = true
								else
									parsed3 = parse(v18)

									if typeof(parsed3) ~= "number" then
										parsed3 = tonumber(v18)
									end

									if parsed3 == nil then
										flag3 = false
									else
										flag3 = true
									end
								end

								if flag3 then
									local v19 = {
										assetId = id
									}

									if parsed ~= nil then
										v19.scale = parsed
									end

									if parsed2 ~= nil then
										v19.colorSeed = parsed2
									end

									if parsed3 ~= nil then
										v19.colorIndex = parsed3
									end

									local eyeColor = trimText(adminPanel.eyeColorInput.Text) -- equivalent call inferred; original call site unknown

									if eyeColor ~= "" then
										v19.eyeColor = eyeColor
									end

									if #mutations > 0 then
										v19.mutations = mutations
									end

									setStatus("Granting egg...") -- equivalent call inferred; original call site unknown
									Remotes.StaffConsole.GrantSelfEgg:FireServer(v19)
								else
									setStatus("Enter a valid color index override.", false) -- equivalent call inferred; original call site unknown
								end
							else
								setStatus("Enter a valid color seed override.", false) -- equivalent call inferred; original call site unknown
							end
						else
							setStatus("Enter a valid scale override.", false) -- equivalent call inferred; original call site unknown
						end
					else
						local v16 = trimText(adminPanel.scaleInput.Text) -- equivalent call inferred; original call site unknown
						local flag, parsed

						if v16 == "" then
							flag = true
						else
							parsed = parse(v16)

							if typeof(parsed) ~= "number" then
								parsed = tonumber(v16)
							end

							if parsed == nil then
								flag = false
							else
								flag = true
							end
						end

						if flag then
							setStatus("Granting asset...") -- equivalent call inferred; original call site unknown
							local v17 = {
								assetId = id
							}

							if parsed ~= nil then
								v17.scale = parsed
							end

							if #mutations > 0 then
								v17.mutations = mutations
							end

							Remotes.StaffConsole.GrantSelfPet:FireServer(v17)
						else
							setStatus("Enter a valid scale override.", false) -- equivalent call inferred; original call site unknown
						end
					end
				else
					setStatus("Select an asset first.", false) -- equivalent call inferred; original call site unknown
				end
			end)
			attachSliderBehavior(adminPanel.walkSpeedControl, function(p: number)
				v14 = "WalkSpeed"
				local v16 = roundToStep(p, 0.1) -- equivalent call inferred; original call site unknown
				local v17 = string.format("%.1f", v16)

				if string.sub(v17, -2) == ".0" then
					v17 = string.sub(v17, 1, #v17 - 2)
				end

				setStatus((`Setting walk speed to {v17}...`)) -- equivalent call inferred; original call site unknown
				Remotes.StaffConsole.WriteWalkSpeed:FireServer(p)
			end)
			attachSliderBehavior(adminPanel.speedPowerControl, function(p: number)
				v14 = "SpeedPower"
				setStatus((`Setting speed value to {string.format("%.0f", (math.round(p)))}...`)) -- equivalent call inferred; original call site unknown
				Remotes.StaffConsole.WriteSpeedPower:FireServer(p)
			end)
			adminPanel.resetButton.MouseButton1Click:Connect(function()
				setStatus("Resetting your data...") -- equivalent call inferred; original call site unknown
				Remotes.StaffConsole.WipeSelfProfile:FireServer()
			end)
			Remotes.StaffConsole.GrantVerdict.OnClientEvent:Connect(function(flag: boolean, p: string, p2: string?)
				if p2 and p2 ~= "" then
					p = `{p} UID: {p2}`
				end

				setStatus(p, flag)
			end)
			Remotes.StaffConsole.WipeVerdict.OnClientEvent:Connect(function(flag: boolean, text: string)
				setStatus(text, flag)
			end)
			Remotes.StaffConsole.SpeedPowerVerdict.OnClientEvent:Connect(function(flag: boolean, text: string)
				setStatus(text, flag)

				if v14 == "SpeedPower" then
					syncSpeedControlsFromSave(true) -- equivalent call inferred; original call site unknown
				else
					local v15 = v14 == "WalkSpeed" and Save.Await()

					if v15 then
						local speedPower = TreadmillUtil.NormalizeSpeedPower(v15.SpeedPower)
						updateSliderVisual(adminPanel.speedPowerControl, speedPower)
					end
				end

				v14 = nil
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function togglePanel()
				visible2 = not visible2
				adminPanel.panel.Visible = visible2
			end

			adminPanel.toggleButton.MouseButton1Click:Connect(togglePanel)
			adminPanel.closeButton.MouseButton1Click:Connect(togglePanel)
			UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
				if gameProcessed then
					return
				end

				if input.KeyCode == Enum.KeyCode.F9 then
					togglePanel() -- equivalent call inferred; original call site unknown
				end
			end)
			UserInputService.InputChanged:Connect(function(input, _: boolean)
				if v11 == nil or input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				setSliderValueFromTrack(v11, input.Position.X) -- equivalent call inferred; original call site unknown
			end)
			UserInputService.InputEnded:Connect(function(input, _: boolean)
				if v11 == nil or v12 == nil or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				local v15 = v11
				local v16 = v12
				v11 = nil
				v12 = nil
				v16(v15.CurrentValue)
			end)
			syncSpeedControlsFromSave(true) -- equivalent call inferred; original call site unknown
			Save.WatchFields("SpeedPower", function()
				local v15 = Save.Await()

				if not v15 then
					return
				end

				local speedPower = TreadmillUtil.NormalizeSpeedPower(v15.SpeedPower)
				updateSliderVisual(adminPanel.speedPowerControl, speedPower)
			end)
			applyGrantTabState("Assets")
			updateSelectedAssetState()
			updateMutationState()
		end

		local function tryInitializeAdminPanel()
			if v4 or not v6 or Save.Await() == nil then
				return
			end

			v4 = true
			v:AtInfo():Log("Admin status confirmed, initializing admin panel")
			setupAdminPanel()
		end

		Remotes.StaffConsole.StaffVerdict.OnClientEvent:Connect(function(flag: boolean)
			v5 = true
			v6 = flag
			AdminPanelEntry.SetAdminStatus(flag)

			if not flag then
				v:AtInfo():Log("Admin panel unavailable for this user")
			elseif not v4 and v6 then
				if Save.Await() == nil then
					return
				end

				v4 = true
				v:AtInfo():Log("Admin status confirmed, initializing admin panel")
				setupAdminPanel()
			end
		end)
		task.spawn(function()
			while not v5 do
				Remotes.StaffConsole.ProbeStaffStatus:FireServer()
				task.wait(2)
			end
		end)
		task.spawn(function()
			while Save.Await() == nil do
				task.wait(0.25)
			end

			if not v4 and v6 then
				if Save.Await() == nil then
					return
				end

				v4 = true
				v:AtInfo():Log("Admin status confirmed, initializing admin panel")
				setupAdminPanel()
			end
		end)
	end
}