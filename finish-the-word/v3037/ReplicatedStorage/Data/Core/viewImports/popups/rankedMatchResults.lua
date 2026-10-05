local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("rankData")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local react = import4:get("react")
local menu = import4:get("menu")
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(60, 200, 100)
local color2 = Color3.fromRGB(210, 65, 65)
local color3 = Color3.fromRGB(230, 185, 60)
local model = import.model(basic.Element, basic.Corner, basic.Gradient)

function model.init(data)
	repeat
		task.wait(0)
	until workspace:GetAttribute("MaxPlayers")

	local maxPlayers = workspace:GetAttribute("MaxPlayers")
	local didWin = data.DidWin
	local v = didWin and color or color2
	local eloChange = data.EloChange
	local oldProgress = data.OldProgress or 0
	local _ = data.Progress or 0
	local placementsLeft = data.PlacementsLeft or 0
	local v2 = placementsLeft > 0
	local v3 = import3[data.NewRank]
	local text, textColor

	if eloChange then
		text = (eloChange >= 0 and "+" or "") .. math.round(eloChange) .. " ELO"
		textColor = eloChange >= 0 and color or color2
	end

	local text2 = ""

	for i = 1, maxPlayers do
		text2 ..= "1" .. (i == maxPlayers and "" or "v")
	end

	local rankedDown = not didWin and data.OldRank ~= data.NewRank
	local rankedUp = didWin and data.OldRank ~= data.NewRank
	local v9 = {
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0.25, 0, 0.6, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(),
		CornerRadius = UDim.new(0.02, 0),
		GradientRotation = 90,
		GradientTransparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(0.8, 0.15),
			NumberSequenceKeypoint.new(1, 1)
		}),
		RankedDown = rankedDown,
		RankedUp = rankedUp
	}
	local v10 = {
		Frame1 = import.make(import.wrap(basic.Element, basic.Gradient), {
			Position = UDim2.new(0.5, 0, 0.02, 0),
			Size = UDim2.new(0.95, 0, 0.14, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = v,
			GradientTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.2, 0.8),
				NumberSequenceKeypoint.new(0.4, 0.5),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.6, 0.5),
				NumberSequenceKeypoint.new(0.8, 0.8),
				NumberSequenceKeypoint.new(1, 1)
			})
		}, {
			Top = import.make(import.wrap(basic.Element, basic.Gradient), {
				Size = UDim2.new(1, 0, 0.04, 0),
				BorderSizePixel = 0,
				ZIndex = 2,
				BackgroundColor3 = didWin and Color3.fromRGB(125, 255, 95) or Color3.fromRGB(255, 8, 6),
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.8),
					NumberSequenceKeypoint.new(0.4, 0.5),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(0.6, 0.5),
					NumberSequenceKeypoint.new(0.8, 0.8),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			ResultLabel = import.make(basic.TextLabel, {
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.8, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Text = didWin and "YOU WON!" or "YOU LOST!",
				TextColor3 = v,
				StrokeWidth = 3
			}),
			Bottom = import.make(import.wrap(basic.Element, basic.Gradient), {
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0.04, 0),
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				ZIndex = 2,
				BackgroundColor3 = didWin and Color3.fromRGB(125, 255, 95) or Color3.fromRGB(255, 8, 6),
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.8),
					NumberSequenceKeypoint.new(0.4, 0.5),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(0.6, 0.5),
					NumberSequenceKeypoint.new(0.8, 0.8),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		ModeLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.175, 0),
			Size = UDim2.new(0.45, 0, 0.07, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = text2,
			TextColor3 = color3,
			StrokeWidth = 2
		}),
		RankIcon = import.make(basic.ImageLabel, {
			Position = UDim2.new(0.5, 0, 0.25, 0),
			Size = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Image = v3.Icon
		}),
		PlacementsLabel = 0,
		RankLabel = 0,
		Frame = 0
	}
	local placementsLabel

	if v2 then
		placementsLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.3, 0),
			Size = UDim2.new(0.82, 0, 0.12, 0),
			Text = placementsLeft .. " PLACEMENT" .. (placementsLeft == 1 and "" or "S") .. " LEFT",
			TextColor3 = color3,
			StrokeWidth = 2
		}) or nil
	end

	v10.PlacementsLabel = placementsLabel
	v10.RankLabel = import.make(basic.TextLabel, {
		Position = UDim2.new(0, 0, 0.58, 0),
		Size = UDim2.new(1, 0, 0.082, 0),
		Text = v3.DisplayName,
		TextColor3 = v3.Color,
		StrokeWidth = 2
	})
	local make = import.make
	local emptyElement = basic.EmptyElement
	local v12 = {
		Position = UDim2.new(0.5, 0, 0.97, 0),
		Size = UDim2.new(0.92, 0, 0.2, 0),
		AnchorPoint = Vector2.new(0.5, 1)
	}
	local progressLabel

	if not v2 then
		progressLabel = import.make(basic.TextLabel, {
			Size = UDim2.new(1, 0, 0.3, 0),
			Text = "Rank Progress",
			TextColor3 = color3,
			StrokeWidth = 1,
			TextXAlignment = Enum.TextXAlignment.Left
		}) or nil
	end

	local eloLabel

	if not v2 then
		eloLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(1, 0, 0.3, 0),
			AnchorPoint = Vector2.new(1, 0),
			Text = text,
			TextColor3 = textColor,
			TextXAlignment = Enum.TextXAlignment.Right,
			StrokeWidth = 1
		}) or nil
	end

	local progressTrack

	if not v2 then
		progressTrack = import.make(import.wrap(basic.Corner, basic.Stroke), {
			Position = UDim2.new(0, 0, 0.375, 0),
			Size = UDim2.new(1, 0, 0.35, 0),
			BackgroundColor3 = Color3.fromRGB(),
			CornerRadius = UDim.new(0.2, 0),
			StrokeWidth = 2
		}, {
			Fill = import.make(basic.Corner, {
				Size = UDim2.new(math.clamp(oldProgress, 0, 1), 0, 1, 0),
				BackgroundColor3 = color3,
				CornerRadius = UDim.new(0.2, 0)
			}),
			Fill2 = import.make(basic.Corner, {
				Position = UDim2.new(oldProgress, 0, 0, 0),
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255),
				CornerRadius = UDim.new(0.2, 0)
			})
		}) or nil
	end

	v10.Frame = make(emptyElement, v12, {
		ProgressLabel = progressLabel,
		EloLabel = eloLabel,
		ProgressTrack = progressTrack,
		StatsRow = import.make(basic.EmptyList, {
			Position = UDim2.new(0, 0, 0.8, 0),
			Size = UDim2.new(1, 0, 0.3, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
		}, {
			WinsLabel = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
				Size = UDim2.new(0.4, 0, 1, 0),
				TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Left,
				StrokeWidth = 1,
				LayoutOrder = 1,
				KeyChains = { "RankedData" },
				TextSavedChanged = function(_, object)
					return "Wins: " .. object:getWinLoseRatio(maxPlayers)
				end
			}),
			LossesLabel = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
				Size = UDim2.new(0.4, 0, 1, 0),
				TextColor3 = color2,
				TextXAlignment = Enum.TextXAlignment.Right,
				StrokeWidth = 1,
				LayoutOrder = 2,
				KeyChains = { "RankedData" },
				TextSavedChanged = function(_, object)
					local _, v17 = object:getWinLoseRatio(maxPlayers)
					return "Losses: " .. v17
				end
			})
		})
	})
	return v9, v10
end

function model.spawn(data)
	local progressTrack = data.Frame.ProgressTrack

	if not progressTrack then
		return
	end

	local oldProgress = data.OldProgress or 0
	local progress = data.Progress or 0

	if data.RankedUp then
		local v = math.max(0.3, (1 - oldProgress) * 1.5)
		TweenService:Create(
			progressTrack.Fill2.Instance,
			TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.new(1 - oldProgress, 0, 1, 0)
			}
		):Play()
		task.delay(v, function()
			progressTrack.Fill.Instance.Size = UDim2.new(0, 0, 1, 0)
			progressTrack.Fill2.Instance.Position = UDim2.new(0, 0, 0, 0)
			progressTrack.Fill2.Instance.Size = UDim2.new(0, 0, 1, 0)
			TweenService:Create(
				progressTrack.Fill2.Instance,
				TweenInfo.new(math.max(0.3, progress * 1.5), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(progress, 0, 1, 0)
				}
			):Play()
		end)
	elseif data.RankedDown then
		local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(progressTrack.Fill.Instance, tweenInfo, {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
		TweenService:Create(progressTrack.Fill2.Instance, tweenInfo, {
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(oldProgress, 0, 1, 0)
		}):Play()
		task.delay(1.35, function()
			progressTrack.Fill.Instance.Size = UDim2.new(1, 0, 1, 0)
			progressTrack.Fill2.Instance.Position = UDim2.new(1, 0, 0, 0)
			progressTrack.Fill2.Instance.Size = UDim2.new(0, 0, 1, 0)
			local v = 1 - progress
			local tweenInfo2 = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(progressTrack.Fill.Instance, tweenInfo2, {
				Size = UDim2.new(progress, 0, 1, 0)
			}):Play()
			TweenService:Create(progressTrack.Fill2.Instance, tweenInfo2, {
				Position = UDim2.new(progress, 0, 0, 0),
				Size = UDim2.new(v, 0, 1, 0)
			}):Play()
		end)
	else
		if oldProgress <= progress then
			TweenService:Create(
				progressTrack.Fill2.Instance,
				TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(progress - oldProgress, 0, 1, 0)
				}
			):Play()
			return
		end

		local v = oldProgress - progress
		local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(progressTrack.Fill.Instance, tweenInfo, {
			Size = UDim2.new(progress, 0, 1, 0)
		}):Play()
		TweenService:Create(progressTrack.Fill2.Instance, tweenInfo, {
			Position = UDim2.new(progress, 0, 0, 0),
			Size = UDim2.new(v, 0, 1, 0)
		}):Play()
	end
end

local model2 = import.model(basic.EmptyList)

function model2.init()
	return {
		Position = UDim2.new(0.5, 0, 0.9, 0),
		Size = UDim2.new(0.7, 0, 0.1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.025, 0)
	}, {
		ReturnButton = import.make(menu.Button, {
			Size = UDim2.new(0.2, 0, 0.7, 0),
			Color = Color3.fromRGB(255, 33, 34),
			BackgroundColor3 = Color3.fromRGB(164, 53, 41),
			Text = "Return",
			LayoutOrder = 1,
			MouseButton1Down = function()
				import2.fire("teleport", "Normal")
			end
		}),
		RequeueButton = import.make(menu.Button, {
			Size = UDim2.new(0.2, 0, 0.7, 0),
			Text = "Requeue",
			LayoutOrder = 2,
			MouseButton1Down = function(_)
				local maxPlayers = workspace:GetAttribute("MaxPlayers")
				import2.fire("requeue", maxPlayers)
			end
		})
	}
end

local model3 = import.model("ScreenGui", basic.Ui)

function model3.init(p)
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		NoAspectRatio = true,
		DisplayOrder = 4,
		Name = "RankedMatchResults",
		Scale = 0.85,
		Location = "Center",
		Background = {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.6
		},
		DepthOfField = import.mount(import.make("DepthOfFieldEffect", {
			Name = "RankedMatchResultsBlur",
			InFocusRadius = 7,
			FarIntensity = 0.5
		}), game.Lighting),
		Content = {
			Card = import.make(model, p),
			ButtonList = import.make(model2)
		}
	}
end

function model3.despawn(p)
	if p.DepthOfField then
		p.DepthOfField:Destroy()
	end
end

return {
	RankedMatchResults = model3
}