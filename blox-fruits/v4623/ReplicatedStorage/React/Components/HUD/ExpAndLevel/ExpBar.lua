local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local EXPFunction = require(game.ReplicatedStorage.EXPFunction)
local Ticks = require(script.Ticks)
local useExp = require(game.ReplicatedStorage.React.Hooks.Player.useExp)
local useLevel = require(game.ReplicatedStorage.React.Hooks.Player.useLevel)
local useLevelCap = require(game.ReplicatedStorage.React.Hooks.Player.useLevelCap)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useTick = require(game.ReplicatedStorage.React.Hooks.Animation.useTick)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.Util.LevelCap.CONSTANTS)
local BASE = CONSTANTS2.LEVEL_CAP.BASE
local createElement = React.createElement

-- equivalent calls inferred from this helper; original call sites unknown
local function secondsToTime(p: number)
	local floor = math.floor
	return string.format(
		"%d:%02d:%02d:%02d",
		floor(p / 86400),
		floor(p % 86400 / 3600),
		floor(p % 3600 / 60),
		(floor(p % 60))
	)
end

function expLabel(props)
	local exp = props.Exp
	local expGoal = props.ExpGoal
	local level = props.Level
	local isMaxLevel = props.IsMaxLevel
	local v = useTick()
	local v2 = ""
	local v4

	if RunService:IsRunning() then
		v4 = Players.LocalPlayer
	end

	local v5 = useAttribute(v4, "ExpBoost")
	local v6 = useMockState("EXPBoost", 0)

	if v6 then
		v5 = v6:get()
	end

	local v8

	if RunService:IsRunning() then
		v8 = Players.LocalPlayer
	end

	local v9 = useAttribute(v8, "ExpBoostTick")
	local v10 = useMockState("EXPBoostTick", 0)

	if v10 then
		v9 = v10:get()
	end

	if v5 and v5 > 0 and v9 then
		local v11 = v5 - (v - v9)

		if v11 > 0 then
			v2 = " (2x ends in " .. secondsToTime(v11) .. ")"
		end
	end

	local v11

	if expGoal and exp then
		return createElement("TextLabel", RobloxTypes.mergeTextLabel({
			Text = (BASE <= level and not isMaxLevel and "Secret Levels Available!" or isMaxLevel and "Max Level" or `{FormatUtil.commaInteger(exp)}/{FormatUtil.commaInteger(expGoal)}`) .. v2
		}, props), {
			UIStroke = React.createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.045
			})
		}) or nil
	end

	return v11
end

return function(p)
	local level = useLevel()
	local levelCap = useLevelCap()
	local exp = useExp() or 0
	local expGoal = React.useMemo(function()
		if level then
			return EXPFunction(level)
		end

		return nil
	end, { level })
	local isMaxLevel

	if level == nil then
		isMaxLevel = false
	else
		isMaxLevel = CONSTANTS2.LEVEL_CAP.THEORETICAL_MAX <= level
	end

	local v6 = not expGoal and 0 or isMaxLevel and 1 or math.clamp(exp / expGoal, 0, 1)
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false
	}, p), {
		Exp = React.createElement(expLabel, {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
			Position = UDim2.new(0, 0, 0.3, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromScale(1, 1.75),
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 4,
			ExpGoal = expGoal,
			Exp = exp,
			Level = level,
			LevelCap = levelCap,
			IsMaxLevel = isMaxLevel
		}),
		BarOutline = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(9, 0, 13),
			BorderColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ClipsDescendants = true,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.CONTENT
		}, {
			UIStroke = React.createElement("UIStroke", {
				Color = Color3.fromRGB(76, 0, 106),
				LineJoinMode = Enum.LineJoinMode.Miter,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.15
			})
		}),
		FillContainer = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BackgroundColor3 = Color3.fromRGB(47, 47, 47),
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.THICK,
			ClipsDescendants = true,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Ticks = createElement(Ticks, {
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0, 1),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
				SegmentCount = p.SegmentCount
			}),
			Fill = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				ClipsDescendants = true,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(v6, 1),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(197, 52, 254)),
						ColorSequenceKeypoint.new(0.39551, Color3.fromRGB(197, 52, 254)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 26, 197))
					}),
					Rotation = 90
				}),
				UIStroke = createElement("UIStroke", {
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					Color = CONSTANTS.COLOR.PALETTE.WHITE,
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.1,
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					UIGradient = createElement("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(202, 72, 253)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 90, 231))
						}),
						Rotation = 90
					})
				}),
				Trans = createElement("Frame", {
					BackgroundColor3 = Color3.fromRGB(212, 118, 251),
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.fromOffset(2, 2),
					Size = UDim2.new(1, 0, 0.4, 0)
				}, {
					UIGradient = createElement("UIGradient", {
						Rotation = 90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.388813, 0),
							NumberSequenceKeypoint.new(1, 0.675)
						})
					})
				})
			})
		})
	})
end