local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
require(script.Parent.SpinnerTypes)
local SpinnerConfig = require(script.Parent.SpinnerConfig)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local Create = require(game.ReplicatedStorage.Modules.Create)
local Groups = require(game.ReplicatedStorage.Util.Sound.Groups)
require(game.ReplicatedStorage.React.RobloxTypes)
local SharedGachaConfig = require(game.ReplicatedStorage.Modules.Gacha.SharedGachaConfig)
local ProfileBackgrounds = require(game.ReplicatedStorage.Modules.ProfileBackgrounds)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local PreviewModel = require(script.Parent.Components.PreviewModel)
local v = {
	"PhysicalMoveset",
	"Moveset",
	"Skin",
	"Redeemable",
	"Consumable",
	"Accessory",
	"Material",
	"Tool",
	"Potion"
}
local frozen = table.freeze({
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0.8),
	Size = UDim2.fromScale(0.2, 0.05)
})
local SpinnerUtil = {
	CloseButtonProperties = table.freeze({
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 79, 79),
		BorderColor3 = Color3.fromRGB(131, 40, 40),
		Trans = {
			BackgroundColor3 = Color3.fromRGB(255, 112, 112)
		}
	}),
	Window = {
		Initialized = false,
		StartSize = UDim2.fromScale(0.93, 0.93),
		EndSize = UDim2.fromScale(0.95, 0.95)
	}
}
local sound = nil
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
script.Parent:FindFirstChild("Instances")
local Sound = require(game.ReplicatedStorage.Util.Sound)

function SpinnerUtil.playSound(p: string)
	if p == "Wind" then
		if sound == nil then
			sound = Instance.new("Sound")
			local assert_2 = assert(sound)
			assert_2.Parent = script
			sound.PlaybackSpeed = 2
			sound.SoundId = "rbxassetid://3418223760"
			Groups.assign(assert(sound), "HighPriority")
		end

		assert(sound):Play()
	else
		local success, result = pcall(function()
			Sound:Play(p)
		end)

		if not success then
			task.spawn(error, `[GACHA_WINDOW] sound error: {p}`, result)
		end
	end
end

function SpinnerUtil.tweenPreview(p, p2, p3)
	local v2 = LastInput:Get() == "Touch" and 1.15 or 1.25
	local TweenService = game:GetService("TweenService")
	return (TweenService:Create(p, p2 or TweenInfo.new(0.2, Enum.EasingStyle.Linear), p3 or {
		Size = UDim2.fromScale(v2, v2)
	}))
end

function SpinnerUtil.scalePreview(p, size: UDim2)
	p.WinnerTile.Frame.Size = size
end

local ThemeColors = require(script.Parent.ThemeColors)

function SpinnerUtil.getTheme(name: string)
	if name:sub(1, 19) == "DungeonTrinketGacha" then
		local name2 = name:split("-")[2]
		local v3 = {
			Bronze = ThemeColors.Bronze,
			Silver = ThemeColors.Silver,
			Gold = ThemeColors.Gold,
			Platinum = ThemeColors.Platinum
		}
		local bronze

		if v3[name2] == nil then
			warn((`unknown config from tier {name}:{name2}`))
			bronze = v3.Bronze
		else
			bronze = v3[name2]
		end

		pcall(function()
			if (localPlayer.Character:GetPivot().Position - workspace.NPCs:FindFirstChild("Trinket Expert"):GetPivot().Position).Magnitude <= 16 then
				name2 = "Random"
			end
		end)
		return {
			Colors = table.clone(bronze),
			HeaderTitleText = `{name2} Trinket Spinner`,
			Name = name2
		}
	else
		local headerTitleText = "Spinner"
		local default = ThemeColors.Default

		if name == "ModifierReforgingGacha" then
			headerTitleText = "Modifier Reforging Spinner"
		elseif name == "DLCBoxData" or name == "ZiolesGacha" then
			headerTitleText = "Fruit Spinner"
		elseif table.find(SharedGachaConfig.SUMMER_BOXES, name) then
			headerTitleText = "Summer 2025 Spinner"
		elseif name == "PremiumBox" or name == "PremiumXmasGacha25" or name == "PremiumChromaticMagnetGacha26" then
			default = ThemeColors.Gold
			headerTitleText = "Premium Spinner"
		elseif name == "RareEasterGift26" then
			default = ThemeColors.Default
			headerTitleText = "Rare Easter Gift"
		elseif name == "LegendaryEasterGift26" then
			default = ThemeColors.Default
			headerTitleText = "Legendary Easter Gift"
		elseif name == "AprilFoolsGacha26" then
			default = ThemeColors.Default
			headerTitleText = "REALLY GOOD Fruit Spinner"
		elseif name == "DogHouseGacha26" then
			default = ThemeColors.Pink
			headerTitleText = "Love Letter"
		else
			warn((`unknown title using {headerTitleText}`))
		end

		return {
			Colors = default,
			HeaderTitleText = headerTitleText,
			Name = name
		}
	end
end

function SpinnerUtil.toggleSpinnerAssetsVisible(visible: boolean)
	local boxHeader = SpinnerUtil.Window.Screen:FindFirstChild("BoxHeader", true)
	local underSpinnerContainer = SpinnerUtil.Window.Screen:FindFirstChild("UnderSpinner.Container", true)
	local aboveSpinnerContainer = SpinnerUtil.Window.Screen:FindFirstChild("AboveSpinner.Container", true)
	local underSpinnerBackground = SpinnerUtil.Window.Screen:FindFirstChild("UnderSpinner.Background", true)
	SpinnerUtil.Window.VirtualContainer.Visible = visible
	SpinnerUtil.Window.WinnersContainerFrame.Visible = visible

	if boxHeader then
		boxHeader.Visible = visible == true
	end

	if underSpinnerContainer then
		underSpinnerContainer.Visible = visible == true
	end

	if aboveSpinnerContainer then
		aboveSpinnerContainer.Visible = visible == true
	end

	if underSpinnerBackground then
		underSpinnerBackground.Visible = visible == true
	end
end

function SpinnerUtil.reflectTheme(p: string)
	local theme = SpinnerUtil.getTheme(p)

	if SpinnerUtil.Window.CurrentTheme == nil then
		local frame = Create.new("Frame", {
			Name = "BoxHeader",
			Size = UDim2.fromScale(0.6, 0.1),
			Position = UDim2.fromScale(0.5, 0.06),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 0.25,
			BackgroundColor3 = Color3.fromRGB(),
			BorderSizePixel = 0,
			Parent = SpinnerUtil.Window.AboveSpinner
		}, { Create.new("UISizeConstraint", {
				MaxSize = Vector2.new(1e999, 65)
			}), Create.new("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1, 0),
					NumberSequenceKeypoint.new(0.298879, 0.24375, 0),
					NumberSequenceKeypoint.new(0.500623, 0.075, 0),
					NumberSequenceKeypoint.new(0.699875, 0.2375, 0),
					NumberSequenceKeypoint.new(1, 1, 0)
				})
			}) })
		local textLabel = Create.new("TextLabel", {
			Name = "BoxHeaderTextLabel",
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Size = UDim2.fromScale(0.9, 0.75),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextColor3 = Color3.new(1, 1, 1),
			Text = "",
			BackgroundTransparency = 1,
			TextScaled = true,
			Parent = frame
		}, { Create.new("UIStroke", {
				Color = Color3.new(),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				LineJoinMode = Enum.LineJoinMode.Round,
				StrokeSizingMode = Enum.StrokeSizingMode.FixedSize,
				Thickness = 1.5,
				Transparency = 0
			}), Create.new("UIGradient", {
				Name = "BoxHeaderTextLabelGradient"
			}) })
		local boxHeaderTextLabelGradient = textLabel:FindFirstChild("BoxHeaderTextLabelGradient", true)
		local header = {
			Toggle = function(visible)
				frame.Visible = visible
			end,
			Reflect = function(p2)
				boxHeaderTextLabelGradient.Color = p2.Colors.HeaderTextColor
				textLabel.Text = p2.HeaderTitleText
			end
		}
		local gradientFrameTop = SpinnerUtil.Window.Screen:FindFirstChild("GradientFrameTop", true)
		local gradientFrameBottom = SpinnerUtil.Window.Screen:FindFirstChild("GradientFrameBottom", true)
		local underglow = {
			Reflect = function(p2)
				gradientFrameTop.BackgroundColor3 = p2.Colors.UnderGlowColor
				gradientFrameBottom.BackgroundColor3 = gradientFrameTop.BackgroundColor3
			end,
			Toggle = function(visible)
				gradientFrameTop.Visible = visible
				gradientFrameBottom.Visible = visible
			end
		}
		local v4 = theme
		local currentTheme = {
			Name = nil,
			Header = header,
			Underglow = underglow,
			Gui = {
				GradientFrameTop = gradientFrameTop,
				GradientFrameBottom = gradientFrameBottom
			},
			GetCurrentTheme = function()
				return v4
			end,
			Reflect = function(p2)
				v4 = p2
				underglow.Reflect(p2)
				header.Reflect(p2)
			end,
			Toggle = function(p2)
				underglow.Toggle(p2)
				header.Toggle(p2)
			end,
			Destroy = function()
				SpinnerUtil.Window.CurrentTheme = nil
				pcall(function(...)
					frame:Destroy()
				end)
			end
		}
		SpinnerUtil.Window.CurrentTheme = currentTheme
	end

	assert(SpinnerUtil.Window.CurrentTheme).Reflect(theme)
end

function SpinnerUtil:previewInstance(currentPreview: number, flag: boolean?)
	if not self then
		print("no session")
		return
	end

	if not self.SessionMaid then
		print("no window.Screen maid")
		return
	end

	if not (self.Replicator and self.Replicator.GetAllItems()[currentPreview]) then
		return
	end

	if currentPreview == self.CurrentPreview then
		print("same preview")
		return
	end

	if not SpinnerUtil.Window then
		print("no window")
		return
	end

	if flag and #self:GetCurrentPack().WinnersLeft ~= 0 then
		print("not done spinning")
		return
	end

	if self.PreviewMaid then
		self.PreviewMaid:Destroy()
	end

	local maid = self.SessionMaid:Extend()
	self.PreviewMaid = maid
	self.CurrentPreview = currentPreview
	assert(maid):Add(function()
		if self then
			self.PreviewMaid = nil
			self.CurrentPreview = nil
		end
	end)
	local winnersAll = self:GetCurrentPack().WinnersAll
	local v2 = nil

	for _, v4 in pairs(winnersAll) do
		local winnerFromUID = self:GetWinnerFromUID(v4)

		if winnerFromUID.ItemId ~= currentPreview then
			continue
		end

		v2 = winnerFromUID
		break
	end

	if v2 == nil then
		self.CurrentPreview = nil
		warn((`no entry found in winners: {currentPreview}`))
		return false
	else
		SpinnerUtil.toggleSpinnerAssetsVisible(false)
		local clone = self.Replicator.GetAllItems()[currentPreview]:Clone()
		maid:Add(PreviewModel.new({
			Host = self.WinnerTile.Frame,
			DisplayName = v2.DisplayName,
			Instance = clone,
			Rarity = v2.Rarity.Name,
			ItemId = v2.ItemId
		}))
		return true
	end
end

local v2 = {
	["Full Moon"] = 133799224341756,
	["Halloween Tapestry"] = 138457857902907,
	["Witch Crafting Box"] = 122086605223365
}

function SpinnerUtil.getImage(p: string, p2: string?, p3: number?)
	local v3 = v2[p]

	if v3 ~= nil then
		return v3
	end

	local nullable = Spritesheets.match(p):asNullable()

	if nullable then
		v3 = ImageUtil.getImageFromSprite(nullable)
	elseif p3 then
		local nullable2 = ItemConfig.match(p3):asNullable()

		if nullable2 and nullable2.Display.Sprite then
			v3 = ImageUtil.getImageFromSprite(nullable2.Display.Sprite)
		end
	end

	if v3 ~= nil then
		return v3
	end

	local v4

	if p2 then
		v4 = table.find({ "Fruit", "PhysicalMoveset" }, p2)
	end

	return (ImageUtil.getImageFromItemId(p, v4 and "PhysicalMoveset" or nil or v))
end

function SpinnerUtil.applyImage(icon, p2: string, p3: string?, p4: number?, flag: boolean?)
	local image = SpinnerUtil.getImage(p2, p3, p4)
	ImageUtil.applySprite(image, {
		Icon = icon
	}, flag)
	return image
end

local v3 = {}
local v4 = {
	Modifier = function(data, data2)
		local frame = data2.Frame
		local v5 = v3[frame]

		if v5 == nil then
			local size = data2.ImageFrame.Foreground.Size
			local uDim = UDim2.fromScale(size.X.Scale * 0.7, size.Y.Scale * 0.7)
			local position = data2.ImageFrame.Foreground.Position
			local vector = Vector2.new(0.5, 0.6)
			local ModifierStatsImageComponent = require(game.ReplicatedStorage.Modules.Create.ModifierStatsImageComponent)
			v5 = ModifierStatsImageComponent({
				Size = uDim,
				Position = position,
				AnchorPoint = vector,
				SwapMiniForPrimary = true
			})
			v5.Container.ZIndex = data2.ImageFrame.Frame.ZIndex + 1
			v3[frame] = v5
			data2.Frame.Destroying:Connect(function()
				v3[frame] = nil
				v5.Destroy()
			end)
		end

		local rarity = data.Rarity
		data2.RarityFade.BackgroundColor3 = rarity.Color
		data2.RarityLabel.TextColor3 = rarity.Color
		data2.RarityLabel.Text = rarity.Name
		data2.NameLabel.Text = data.DisplayName
		data2.ImageFrame.Foreground.Visible = false
		v5.Update(data.StorageName, data2.ImageFrame.Frame)
	end,
	Default = function(data, data2)
		for _, v5 in pairs(v3) do
			v5.SetVisible(false)
		end

		local mystery = data.Attributes.Mystery == true
		local rarity = data.Rarity
		data2.RarityFade.BackgroundColor3 = rarity.Color
		data2.RarityLabel.TextColor3 = rarity.Color
		data2.RarityLabel.Text = rarity.Name
		data2.NameLabel.Text = mystery and "?????" or data.DisplayName
		data2.ImageFrame.Foreground.Visible = true
		SpinnerUtil.applyImage(data2.ImageFrame.Foreground, data.ImageName, data.ItemType, data.ItemId, mystery)

		if data.ItemType == "ProfileBackground" then
			local v5 = ProfileBackgrounds.List[data.StorageName]

			if v5 then
				data2.ImageFrame.Frame.Visible = false
				data2.PlayerProfileBackground.Image = v5.Image
				data2.PlayerProfileBackground.Visible = true
			end
		else
			data2.ImageFrame.Frame.Visible = true
			data2.PlayerProfileBackground.Visible = false
		end
	end
}

function SpinnerUtil.IgnoreBonusItems()
	return function(p)
		if p.Attributes.BonusItem then
			return true
		end

		return false
	end
end

function SpinnerUtil.canFastForwardBox(object)
	local currentPack = object:GetCurrentPack()

	if table.find(
		{ "PremiumXmasGacha25", "ModifierReforgingGacha", "PremiumChromaticMagnetGacha26" },
		currentPack.BoxName
	) and object:CountWinnersAll(SpinnerUtil.IgnoreBonusItems()) > 1 then
		return true
	end

	return false
end

function SpinnerUtil.canSkipBox(object)
	local currentPack = object:GetCurrentPack()

	if table.find(
		{ "PremiumXmasGacha25", "ModifierReforgingGacha", "PremiumChromaticMagnetGacha26" },
		currentPack.BoxName
	) then
		return object:CountWinnersAll(SpinnerUtil.IgnoreBonusItems()) ~= 3
	end

	return false
end

function SpinnerUtil.getTileWidth()
	return assert(SpinnerUtil.Window, "window is nil<.til.getTileWidth>").TileTemplateRef.Frame.AbsoluteSize.X
end

function SpinnerUtil.getNumFillFrames(p: number?)
	local v5 = p or SpinnerUtil.getTileWidth()
	return (math.min(
		math.ceil(SpinnerUtil.Window.ScrollingFrame.AbsoluteSize.X / v5 + SpinnerConfig.NUM_PADDED_FRAMES),
		10
	))
end

function SpinnerUtil.newTile()
	local clone = game.ReplicatedStorage.Modules.Create.Templates["Spinner.Tile"]:Clone()
	clone.BackgroundTransparency = 1
	clone.Size = UDim2.fromScale(1, 1)
	clone.Position = UDim2.new()
	clone.AnchorPoint = Vector2.zero
	local nameLabel = assert(clone:FindFirstChild("TextLabel"))
	local rarityLabel = assert(clone:FindFirstChild("RarityLabel"))
	local frame2 = assert(clone:FindFirstChild("ImageFrame"))
	local bonusFrame = assert(clone:FindFirstChild("BonusFrame"))
	local grandPrizeFrame = assert(clone:FindFirstChild("GrandPrizeFrame"))
	local rarityFade = assert(clone:FindFirstChild("RarityFade"))
	local outlineGlow = assert(clone:FindFirstChild("OutlineGlow"))
	local uIStroke = assert(clone:FindFirstChildOfClass("UIStroke"))
	grandPrizeFrame.ZIndex = 2
	bonusFrame.ZIndex = 2
	nameLabel.ZIndex = 2
	nameLabel.Size = UDim2.fromScale(0.95, 0.245)
	local frame = Instance.new("Frame")
	frame.Name = "AnimationFrame"
	frame.BackgroundColor3 = Color3.new()
	frame.BackgroundTransparency = 0
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = SpinnerUtil.Window.StartSize

	for _, child in pairs(clone:GetChildren()) do
		child.Parent = frame
	end

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 0.95
	uIAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
	uIAspectRatioConstraint.Parent = clone
	frame.Parent = clone
	local v13 = {
		Frame = clone,
		AnimationFrame = frame,
		NameLabel = nameLabel,
		RarityLabel = rarityLabel,
		PlayerProfileBackground = clone:FindFirstChild("PlayerProfileBackground", true),
		ImageFrame = {
			Frame = frame2,
			Background = assert(frame2:FindFirstChild("Background")),
			Foreground = assert(frame2:FindFirstChild("Icon"))
		},
		BonusFrame = bonusFrame,
		GrandPrizeFrame = grandPrizeFrame,
		RarityFade = rarityFade,
		OutlineGlow = {
			OutlineGlow = outlineGlow,
			UIGradient = assert(outlineGlow:FindFirstChildOfClass("UIGradient"))
		},
		UIStroke = {
			UIStroke = uIStroke,
			UIGradient = assert(uIStroke:FindFirstChildOfClass("UIGradient"))
		},
		_UID = 0
	}
	local HttpService = game:GetService("HttpService")
	v13._UID = HttpService:GenerateGUID(false)

	function v13.Destroy(_)
		clone:Destroy()
	end

	function v13.Render(data, p)
		data.BonusFrame.Visible = p.Attributes.BonusItem ~= nil
		data.GrandPrizeFrame.Visible = p.Attributes.GrandPrize ~= nil
		data.ImageFrame.Background.Visible = false
		data.UIStroke.UIStroke.Enabled = data.GrandPrizeFrame.Visible
		data.OutlineGlow.OutlineGlow.Visible = data.GrandPrizeFrame.Visible

		if AccessoriesShared.GetAllModifiers()[p.StorageName] then
			v4.Modifier(p, data)
		else
			v4.Default(p, data)
		end
	end

	return v13
end

function SpinnerUtil.button(data)
	local v5 = {}
	local callback = nil
	local activatedConnection = data.GetTextButton().Activated:Connect(function(_, _: number)
		if callback then
			callback()
		end
	end)

	function v5.Destroy()
		callback = nil
		activatedConnection:Disconnect()
		pcall(function(...)
			data.GetTextButton():Destroy()
		end)
		return v5
	end

	function v5.OnClick(p)
		callback = p
		return v5
	end

	function v5.SetSuffix(_)
		return v5
	end

	function v5.Instance(callback2)
		callback2({
			TextButton = data.GetTextButton(),
			TextLabel = data.GetTextLabel()
		})
		return v5
	end

	function v5.Init()
		if data.OnInit then
			task.spawn(data.OnInit)
		else
			local getTextButton = data.GetTextButton()
			getTextButton.Visible = true
		end

		return v5
	end

	return v5
end

function SpinnerUtil.textLabelButton()
	local textButton = Create.new("TextButton", {
		Text = "",
		Name = "TextLabelButton",
		BackgroundTransparency = 1,
		ZIndex = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.8),
		Size = UDim2.fromScale(0.5, 0.05),
		Visible = false,
		Parent = SpinnerUtil.Window.AboveSpinner
	})
	return {
		TextLabel = Create.new("TextLabel", {
			TextColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			TextScaled = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Parent = textButton
		}),
		TextButton = textButton
	}
end

function SpinnerUtil:closeButton()
	if self._CloseButton then
		return self._CloseButton
	end

	local Create2 = require(game.ReplicatedStorage.Modules.Create)
	local closeButtonProperties = Create2.Template("CloseButton")
	closeButtonProperties.Name = "CloseButton"
	closeButtonProperties.Visible = false
	local v5 = assert((closeButtonProperties:FindFirstChild("Trans")))

	for k, closeButtonProperty in pairs(SpinnerUtil.CloseButtonProperties) do
		if k == "Trans" then
			v5.BackgroundColor3 = closeButtonProperty.BackgroundColor3
		else
			closeButtonProperties[k] = closeButtonProperty
		end
	end

	local frame = SpinnerUtil.Window.Navigation.Frame

	for k, v6 in pairs(frozen) do
		frame[k] = v6
	end

	local icon = closeButtonProperties:FindFirstChild("Icon")

	if icon and not icon:FindFirstAncestorOfClass("UIAspectRatioConstraint") then
		Instance.new("UIAspectRatioConstraint", icon)
	end

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 6
	uIAspectRatioConstraint.Parent = closeButtonProperties
	closeButtonProperties.Parent = SpinnerUtil.Window.Navigation.Frame
	local button = SpinnerUtil.button({
		GetTextButton = function()
			return closeButtonProperties
		end,
		GetTextLabel = function()
			return closeButtonProperties
		end
	})
	self.SessionMaid:Add(button)
	self.SessionMaid:Add(function()
		self._CloseButton = nil
	end)
	self._CloseButton = button
	return button
end

function SpinnerUtil:skipButton()
	if self._SkipButton then
		return self._SkipButton
	end

	local textLabelButton = SpinnerUtil.textLabelButton()
	local v5 = "Skip"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onChanged()
		SpinnerUtil.updateClickText(v5, textLabelButton.TextLabel)
	end

	local button = SpinnerUtil.button({
		GetTextButton = function()
			return textLabelButton.TextButton
		end,
		GetTextLabel = function()
			return textLabelButton.TextLabel
		end
	})

	function button.SetSuffix(p)
		v5 = p
		onChanged() -- equivalent call inferred; original call site unknown
		return button
	end

	button.SetSuffix(v5)
	self.SessionMaid:Add((LastInput.Changed:Connect(onChanged)))
	self.SessionMaid:Add(button)
	self.SessionMaid:Add(function()
		self._SkipButton = nil
	end)
	self._SkipButton = button
	return button
end

function SpinnerUtil:fastFowardButton()
	if self._FastForwardButton then
		return self._FastForwardButton
	end

	local textLabelButton = SpinnerUtil.textLabelButton()
	local v5 = "Fast Forward"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onChanged()
		SpinnerUtil.updateClickText(v5, textLabelButton.TextLabel)
	end

	local button = SpinnerUtil.button({
		GetTextButton = function()
			return textLabelButton.TextButton
		end,
		GetTextLabel = function()
			return textLabelButton.TextLabel
		end
	})

	function button.SetSuffix(p)
		v5 = p
		onChanged() -- equivalent call inferred; original call site unknown
		return button
	end

	button.SetSuffix(v5)
	self.SessionMaid:Add((LastInput.Changed:Connect(onChanged)))
	self.SessionMaid:Add(textLabelButton.TextButton)
	self.SessionMaid:Add(button)
	self.SessionMaid:Add(function()
		self._FastForwardButton = nil
	end)
	self._FastForwardButton = button
	return button
end

function SpinnerUtil:nextPackButton()
	if self._NextPackButton then
		return self._NextPackButton
	end

	local textLabelButton = SpinnerUtil.textLabelButton()
	local v5 = "<i>Next</i>"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onChanged()
		if LastInput:Get() == "Gamepad" then
			SpinnerUtil.updateClickText(v5, textLabelButton.TextLabel)
		else
			textLabelButton.TextLabel.Text = "<i>Next..</i>"
		end
	end

	local button = SpinnerUtil.button({
		GetTextButton = function()
			return textLabelButton.TextButton
		end,
		GetTextLabel = function()
			return textLabelButton.TextLabel
		end
	})

	function button.SetSuffix(p)
		v5 = p
		onChanged() -- equivalent call inferred; original call site unknown
		return button
	end

	button.SetSuffix(v5)
	self.SessionMaid:Add((LastInput.Changed:Connect(onChanged)))
	self.SessionMaid:Add(textLabelButton.TextButton)
	self.SessionMaid:Add(button)
	self.SessionMaid:Add(function()
		self._NextPackButton = nil
	end)
	self._NextPackButton = button
	return button
end

function SpinnerUtil.updateClickText(p: string, p2)
	local text = ""

	if LastInput:Get() == "MouseKeyboard" then
		text = `Click to {p}..`
	elseif LastInput:Get() == "Gamepad" then
		text = `Press {LastInput:GetControllerType() == "PlayStation" and "O" or "B"} to {p}..`
	elseif LastInput:Get() == "Touch" then
		text = `Tap to {p}..`
	end

	p2.Text = text
end

function SpinnerUtil.initWindow()
	local window = SpinnerUtil.Window

	if window.Initialized ~= false then
		return window
	end

	window.Initialized = true
	window.Screen = Instance.new("ScreenGui")
	window.Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	window.Screen.IgnoreGuiInset = true
	window.Screen.Name = "SpinnerWindow"
	window.Screen.ResetOnSpawn = false
	window.Screen.DisplayOrder = 1
	window.Screen.Enabled = false

	local function copySpinnerProperties(p)
		p.Size = UDim2.new(1, 0, 0.35, 0)
		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.Position = UDim2.fromScale(0.5, 0.5)
		p.BackgroundTransparency = 1
		p.BorderSizePixel = 0
		return p
	end

	local frame = Instance.new("Frame")
	frame.Name = "UnderSpinner"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BorderSizePixel = 0
	frame.ZIndex = -1
	frame.BackgroundTransparency = 1
	frame.Parent = window.Screen
	local frame2 = Instance.new("Frame")
	frame2.Name = "AboveSpinner"
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.BorderSizePixel = 0
	frame2.BackgroundTransparency = 1
	frame2.ZIndex = 2
	frame2.Parent = window.Screen
	window.AboveSpinner = frame2
	local parent = copySpinnerProperties(Instance.new("Frame"))
	parent.Name = "UnderSpinner.Container"
	parent.BackgroundTransparency = 1
	parent.Parent = frame
	local v6 = copySpinnerProperties(Instance.new("Frame"))
	v6.Name = "AboveSpinner.Container"
	v6.BackgroundTransparency = 1
	v6.Parent = frame2
	window.AboveSpinnerFrame = v6
	local frame3 = Instance.new("Frame")
	frame3.Name = "UnderSpinner.Background"
	frame3.BackgroundTransparency = 0.25
	frame3.BackgroundColor3 = Color3.new()
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.ZIndex = -10
	frame3.Parent = frame
	local frame4 = Instance.new("Frame")
	frame4.Name = "Navigation"
	frame4.BackgroundTransparency = 1
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 6
	uIAspectRatioConstraint.Parent = frame4
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = frame4
	frame4.ZIndex = 3
	frame4.Parent = frame2
	window.Navigation = {
		Frame = frame4
	}
	window.ScrollingFrame = copySpinnerProperties(Instance.new("ScrollingFrame"))
	window.ScrollingFrame.ScrollingEnabled = false
	window.ScrollingFrame.ScrollBarThickness = 0
	window.ScrollingFrame.Selectable = false
	window.ScrollingFrame.Active = false
	window.ScrollingFrame.CanvasSize = UDim2.new()
	window.ScrollingFrame.Name = "ScrollingFrame"
	window.ScrollingFrame.Visible = true
	window.ScrollingFrame.ZIndex = 1
	window.ScrollingFrame.Parent = window.Screen
	window.VirtualContainer = copySpinnerProperties(Instance.new("Frame"))
	window.VirtualContainer.Name = "_VirtualContainer"
	window.VirtualContainer.Selectable = false
	window.VirtualContainer.ClipsDescendants = true
	window.VirtualContainer.BackgroundColor3 = window.ScrollingFrame.BackgroundColor3
	window.VirtualContainer.Parent = window.Screen
	window.VirtualList = Instance.new("Frame")
	window.VirtualList.Name = "_VirtualList"
	window.VirtualList.Position = UDim2.fromScale(0.5, 0.5)
	window.VirtualList.AnchorPoint = Vector2.new(0.5, 0.5)
	window.VirtualList.Size = UDim2.fromScale(1, 1)
	window.VirtualList.Selectable = false
	window.VirtualList.BackgroundTransparency = 1
	window.VirtualList.Parent = window.VirtualContainer
	window.WinnersContainerFrame = copySpinnerProperties(Instance.new("Frame"))
	window.WinnersContainerFrame.Name = "WinnersContainerFrame"
	window.WinnersContainerFrame.BackgroundTransparency = 1
	window.WinnersContainerFrame.ZIndex = 3
	window.WinnersContainerFrame.Parent = window.Screen
	window.TileTemplateRef = SpinnerUtil.newTile()
	window.TileTemplateRef.Frame.Visible = false
	window.TileTemplateRef.Frame.Parent = window.ScrollingFrame
	local frame5 = Instance.new("Frame")
	frame5.Size = UDim2.fromScale(1, 1)
	frame5.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
	frame5.BorderSizePixel = 0
	frame5.BackgroundTransparency = 0.1
	frame5.ZIndex = 1
	frame5.Name = "BackgroundFrame"
	frame5.Parent = parent
	local frame6 = Instance.new("Frame")
	frame6.Name = "GradientFrameTop"
	frame6.BorderSizePixel = 0
	frame6.BackgroundTransparency = 0.5
	frame6.Size = UDim2.fromScale(1, 0.226)
	frame6.AnchorPoint = Vector2.new(0.5, 1)
	frame6.Position = UDim2.fromScale(0.5, 0)
	frame6.Parent = frame5
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = 90
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	uIGradient.Parent = frame6
	local frame7 = Instance.new("Frame")
	frame7.Name = "GradientFrameBottom"
	frame7.BorderSizePixel = 0
	frame7.BackgroundTransparency = 0.5
	frame7.Size = UDim2.fromScale(1, 0.226)
	frame7.AnchorPoint = Vector2.new(0.5, 0)
	frame7.Position = UDim2.fromScale(0.5, 1)
	frame7.Parent = frame5
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Rotation = -90
	uIGradient2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	uIGradient2.Parent = frame7
	local frame8 = Instance.new("Frame")
	frame8.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
	frame8.BackgroundTransparency = 0
	frame8.ZIndex = 2
	frame8.Name = "ShadowFrame"
	frame8.Size = UDim2.fromScale(1, 1)
	frame8.Parent = v6
	local uIGradient3 = Instance.new("UIGradient")
	uIGradient3.Name = "Shadow"
	uIGradient3.Rotation = 180
	uIGradient3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2, 1),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(0.8, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	uIGradient3.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB()),
		ColorSequenceKeypoint.new(1, Color3.fromRGB())
	})
	uIGradient3.Parent = frame8
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 1.5
	uIStroke.Transparency = 0
	uIStroke.ZIndex = 1
	uIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Outer
	uIStroke.BorderOffset = UDim.new(0, 0)
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uIStroke.Parent = frame5
	local frame9 = Instance.new("Frame")
	frame9.Name = "CarrotFrame"
	frame9.BackgroundTransparency = 1
	frame9.AnchorPoint = Vector2.new(0.5, 0.5)
	frame9.Position = UDim2.fromScale(0.5, 0.5)
	frame9.Size = UDim2.fromScale(0.03, 1.2)
	frame9.ZIndex = 3
	frame9.Parent = v6
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Top"
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel.Position = UDim2.fromScale(0.5, 0)
	imageLabel.Image = "rbxassetid://74749305000992"
	imageLabel.Parent = frame9
	Instance.new("UIAspectRatioConstraint", imageLabel)
	local clone = imageLabel:Clone()
	clone.Name = "Bottom"
	clone.AnchorPoint = Vector2.new(0.5, 1)
	clone.Position = UDim2.fromScale(0.5, 1)
	clone.Image = "rbxassetid://117635960637931"
	clone.Parent = frame9
	window.UIListLayout = Instance.new("UIListLayout")
	window.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	window.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	window.UIListLayout.Parent = window.VirtualList
	window.Screen.Parent = localPlayer.PlayerGui
	SpinnerUtil.Window = window
	return window
end

return SpinnerUtil