local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("rankData")
local import4 = _G.import("effectUtil")
local import5 = _G.import("viewImports")
local basic = import5:get("basic")
local react = import5:get("react")
local ux = import5:get("ux")
local rankedBackdrop = require(script.Parent.rankedBackdrop)
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(255, 205, 58)
local color2 = Color3.fromRGB(220, 68, 64)
local color3 = Color3.fromRGB(0, 0, 0)
local color4 = Color3.fromRGB(255, 255, 255)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 230, 78), Color3.fromRGB(223, 137, 34))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 246, 142), Color3.fromRGB(255, 178, 72))

local function formatNumber(p)
	local v = tostring((math.floor(tonumber(p) or 0)))
	local v2, v3, v4 = string.match(v, "^([^%d]*%d)(%d*)(.-)$")
	return v2 .. v3:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. v4
end

local function upper(value)
	return string.upper((tostring(value or "")))
end

local model = import.model(basic.EmptyElement)

function model.init(p)
	local v = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.055, 0),
		Size = UDim2.new(0.48, 0, 0.16, 0)
	}
	local v2 = {
		Plate = import.make(basic.Element, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = color4,
			BorderSizePixel = 0,
			Rotation = 1
		}, {
			Title = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.4, 0),
				Size = UDim2.new(0.9, 0, 0.78, 0),
				Text = p.Win and "VICTORY" or "DEFEAT",
				TextColor3 = color3,
				StrokeWidth = 0
			})
		}),
		Subtitle = 0
	}
	local make = import.make
	local element = basic.Element
	local v3 = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.78, 0),
		Size = UDim2.new(1.35, 0, 0.33, 0),
		BackgroundColor3 = color3,
		BorderSizePixel = 0,
		Rotation = 1,
		ZIndex = 2
	}
	local make2 = import.make
	local textLabel = basic.TextLabel
	local v5 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.96, 0, 0.78, 0),
		Text = 0,
		TextColor3 = 0,
		StrokeWidth = 0
	}
	local v6 = p.Win and "WHAT A GAME! YOU'RE A REAL WORDSMITH." or "UNFORTUNATE. YOU'LL GET EM NEXT TIME"
	v5.Text = string.upper((tostring(v6 or "")))
	v5.TextColor3 = color4
	v2.Subtitle = make(element, v3, {
		Text = make2(textLabel, v5)
	})
	return v, v2
end

local model2 = import.model(basic.EmptyElement)

function model2.init(data)
	local v = {
		Size = UDim2.new(0.18, 0, 1, 0),
		LayoutOrder = data.LayoutOrder
	}
	local v2 = {
		ValueLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 0.58, 0),
			Text = 0,
			TextColor3 = data.Color,
			StrokeWidth = 3
		}),
		LabelBacker = 0
	}
	local make = import.make
	local element = basic.Element
	local v3 = {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(0.96, 0, 0.36, 0),
		BackgroundColor3 = color3,
		BorderSizePixel = 0,
		Rotation = data.Rotation
	}
	local make2 = import.make
	local textLabel = basic.TextLabel
	local v5 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.9, 0, 0.7, 0),
		Text = 0,
		TextColor3 = 0,
		StrokeWidth = 0
	}
	local label = data.Label
	v5.Text = string.upper((tostring(label or "")))
	v5.TextColor3 = color4
	v2.LabelBacker = make(element, v3, {
		Label = make2(textLabel, v5)
	})
	return v, v2
end

function model2.spawn(p)
	local value = p.Value or 0

	if value == 0 then
		return
	end

	local v = 0
	p.ValueLabel.Text = formatNumber(0)
	task.spawn(function()
		while v < 0.8 do
			local v2 = task.wait()
			v = math.min(v + v2, 0.8)
			local v3 = 1 - (1 - v / 0.8) ^ 2
			p.ValueLabel.Text = formatNumber(math.round(v3 * value))
		end

		p.ValueLabel.Text = formatNumber(value)
	end)
end

local model3 = import.model(basic.EmptyList)

function model3.init(data)
	return {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.285, 0),
		Size = UDim2.new(0.52, 0, 0.105, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.05, 0)
	}, {
		Rounds = import.make(model2, {
			LayoutOrder = 1,
			Value = data.AvgSpeed,
			Label = "AVG SPEED",
			Rotation = -1,
			Color = Color3.fromRGB(85, 210, 255)
		}),
		Damage = import.make(model2, {
			LayoutOrder = 2,
			Value = data.AvgLength,
			Label = "AVG LENGTH",
			Rotation = 1,
			Color = Color3.fromRGB(185, 145, 255)
		}),
		Gold = import.make(model2, {
			LayoutOrder = 3,
			Value = data.CashEarned,
			Label = "GOLD EARNED",
			Rotation = -1,
			Color = color
		})
	}
end

local model4 = import.model(basic.EmptyElement)

function model4.init(data)
	local maxPlayers = workspace:GetAttribute("MaxPlayers")
	local v = import3[data.NewRank] or import3.Unranked
	local eloChange = data.EloChange or 0
	local placementsLeft = data.PlacementsLeft or 0
	local v2 = placementsLeft > 0
	local v3 = math.clamp(data.OldProgress or 0, 0, 1)
	local v4 = math.clamp(data.Progress or v3, 0, 1)
	local text = (eloChange >= 0 and "+" or "") .. math.round(eloChange) .. " ELO"
	local color5 = eloChange >= 0 and Color3.fromRGB(70, 225, 105) or color2
	local rankedUp = not v2 and data.Win and data.OldRank ~= data.NewRank
	local rankedDown = not v2 and not data.Win and data.OldRank ~= data.NewRank
	local v8 = data.NewRank == "Pro"
	local v9 = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.3765, 0),
		Size = UDim2.new(0.34, 0, 0.34, 0),
		RankedUp = rankedUp,
		RankedDown = rankedDown
	}
	local v10 = {
		RankIcon = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, -0.02, 0),
			Size = UDim2.new(1.25, 0, 1.25, 0),
			Image = v.Icon,
			ZIndex = 4
		}),
		RankLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1.12, 0),
			Size = UDim2.new(0.7, 0, 0.12, 0),
			Text = v.DisplayName,
			TextColor3 = v.Color,
			FontFace = v.FontFace,
			StrokeWidth = 2,
			ZIndex = 7
		}),
		EloLabel = 0,
		EloDisplay = 0,
		ProgressWrap = 0
	}
	local make = import.make
	local textLabel = basic.TextLabel
	local v11 = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1.25, 0),
		Size = UDim2.new(0.52, 0, 0.1, 0),
		Text = 0,
		TextColor3 = 0,
		StrokeWidth = 2,
		ZIndex = 7
	}

	if v2 then
		text = placementsLeft .. " PLACEMENT" .. (placementsLeft == 1 and "" or "S") .. " LEFT" or text
	end

	v11.Text = text

	if v2 then
		color5 = color or color5
	end

	v11.TextColor3 = color5
	v10.EloLabel = make(textLabel, v11)
	local eloDisplay

	if not (v2 or not v8) then
		eloDisplay = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1.6, 0),
			Size = UDim2.new(0.9, 0, 0.12, 0),
			TextColor3 = color,
			StrokeWidth = 2,
			ZIndex = 7,
			KeyChains = { "RankedData" },
			TextSavedChanged = function(_, object)
				local modeConservativeRating = object:getModeConservativeRating(maxPlayers)
				return modeConservativeRating and formatNumber(math.round(modeConservativeRating)) .. " ELO" or "— ELO"
			end
		}) or nil
	end

	v10.EloDisplay = eloDisplay
	local progressWrap

	if not (v2 or v8) then
		progressWrap = import.make(basic.EmptyElement, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1.55, 0),
			Size = UDim2.new(0.9, 0, 0.18, 0)
		}, {
			ProgressLabel = import.make(basic.TextLabel, {
				Size = UDim2.new(0.45, 0, 0.42, 0),
				Text = "RANK PROGRESS",
				TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Left,
				StrokeWidth = 1
			}),
			ProgressValue = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0.45, 0, 0.42, 0),
				Text = math.round(v4 * 100) .. "%",
				TextColor3 = color4,
				TextXAlignment = Enum.TextXAlignment.Right,
				StrokeWidth = 1
			}),
			ProgressTrack = import.make(import.wrap(basic.Corner, basic.Stroke), {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.new(1, 0, 0.42, 0),
				BackgroundColor3 = color3,
				CornerRadius = UDim.new(0.25, 0),
				StrokeWidth = 2,
				StrokeColor = Color3.fromRGB(30, 30, 34)
			}, {
				Fill = import.make(basic.Element, {
					Size = UDim2.new(v3, 0, 1, 0),
					BackgroundTransparency = 1,
					ClipsDescendants = false
				}, {
					Body = import.make(basic.Element, {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = color4,
						BorderSizePixel = 0
					}, {
						Gradient = import.make("UIGradient", {
							Color = colorSequence,
							Rotation = 90
						})
					}),
					LeftCap = import.make(basic.Corner, {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundColor3 = color4,
						BorderSizePixel = 0,
						CornerRadius = UDim.new(1, 0)
					}, {
						Gradient = import.make("UIGradient", {
							Color = colorSequence,
							Rotation = 90
						})
					})
				}),
				Fill2 = import.make(basic.Element, {
					Position = UDim2.new(v3, 0, 0, 0),
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 1,
					ClipsDescendants = false
				}, {
					Body = import.make(basic.Element, {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = color4,
						BorderSizePixel = 0
					}, {
						Gradient = import.make("UIGradient", {
							Color = colorSequence2,
							Rotation = 90
						})
					}),
					RightCap = import.make(basic.Corner, {
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundColor3 = color4,
						BorderSizePixel = 0,
						CornerRadius = UDim.new(1, 0)
					}, {
						Gradient = import.make("UIGradient", {
							Color = colorSequence2,
							Rotation = 90
						})
					})
				})
			})
		}) or nil
	end

	v10.ProgressWrap = progressWrap
	return v9, v10
end

function model4.spawn(data)
	if not data.ProgressWrap then
		return
	end

	local progressTrack = data.ProgressWrap.ProgressTrack
	local oldProgress = data.OldProgress or 0
	local progress = data.Progress or 0
	local instance = progressTrack.Fill2.Body.Gradient.Instance
	local instance2 = progressTrack.Fill2.RightCap.Gradient.Instance
	local value = colorSequence2.Keypoints[1].Value
	local value2 = colorSequence2.Keypoints[2].Value
	local value3 = colorSequence.Keypoints[1].Value
	local value4 = colorSequence.Keypoints[2].Value

	if not data.IsPlacement then
		local eloChange = data.EloChange or 0
		local instance3 = data.EloLabel.Instance
		local v = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fmt(p)
			local v2 = math.round(p)
			return (v2 >= 0 and "+" or "") .. v2 .. " ELO"
		end

		instance3.Text = "+" .. 0 .. " ELO"
		task.spawn(function()
			while v < 0.8 do
				local v2 = task.wait()
				v = math.min(v + v2, 0.8)
				local v3 = 1 - (1 - v / 0.8) ^ 2
				instance3.Text = fmt(math.round(v3 * eloChange))
			end

			instance3.Text = fmt(eloChange)
		end)
	end

	if data.RankedUp then
		local v = math.max(0.3, (1 - oldProgress) * 1.5)
		task.spawn(function()
			import4.animate(v, function(p)
				local colorSequence3 = ColorSequence.new(value:Lerp(value3, p), value2:Lerp(value4, p))
				instance.Color = colorSequence3
				instance2.Color = colorSequence3
			end)
		end)
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
			instance.Color = colorSequence2
			instance2.Color = colorSequence2
			task.spawn(function()
				import4.animate(math.max(0.3, progress * 1.5), function(p)
					local colorSequence3 = ColorSequence.new(value:Lerp(value3, p), value2:Lerp(value4, p))
					instance.Color = colorSequence3
					instance2.Color = colorSequence3
				end)
			end)
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
		task.spawn(function()
			import4.animate(1.2, function(p)
				local colorSequence3 = ColorSequence.new(value:Lerp(value3, p), value2:Lerp(value4, p))
				instance.Color = colorSequence3
				instance2.Color = colorSequence3
			end)
		end)
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

local model5 = import.model("ImageButton", basic.Corner, basic.Stroke, ux.Button)

function model5.init(data)
	return {
		AnchorPoint = data.AnchorPoint,
		Position = data.Position,
		Size = data.Size,
		Rotation = data.Rotation or 0,
		BackgroundColor3 = data.Color,
		BorderSizePixel = 0,
		AutoButtonColor = true,
		CornerRadius = UDim.new(0.02, 0),
		StrokeWidth = 3,
		StrokeColor = Color3.fromRGB(18, 18, 18),
		MouseButton1Down = data.MouseButton1Down
	}, {
		Gradient = import.make("UIGradient", {
			Rotation = 90,
			Color = data.GradientColor
		}),
		Label = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.86, 0, 0.68, 0),
			Rotation = -(data.Rotation or 0),
			Text = data.Text,
			TextColor3 = color4,
			StrokeWidth = 4
		})
	}
end

local model6 = import.model(basic.EmptyElement)

function model6.init()
	local lastTime = os.time()
	return {
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		Play = import.make(model5, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0.035, 0, 0.962, 0),
			Size = UDim2.new(0.2, 0, 0.075, 0),
			Rotation = -1,
			Text = "PLAY AGAIN",
			Color = color,
			GradientColor = colorSequence,
			MouseButton1Down = function()
				import2.fire("requeue", workspace:GetAttribute("MaxPlayers"))
				game.Players.LocalPlayer.PlayerGui.rankedMatchOver:Destroy()
			end
		}),
		MainMenu = import.make(model5, {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(0.965, 0, 0.96, 0),
			Size = UDim2.new(0.18, 0, 0.06, 0),
			Text = "RETURN",
			Color = Color3.fromRGB(70, 70, 74),
			GradientColor = ColorSequence.new(Color3.fromRGB(92, 92, 96), Color3.fromRGB(34, 34, 38)),
			MouseButton1Down = function()
				if os.time() - lastTime < 0.5 then
					return
				end

				lastTime = os.time()
				import2.fire("signal", "Teleporting to lobby. Please wait")
				import2.fire("teleport", "Normal")
			end
		})
	}
end

local model7 = import.model(basic.EmptyElement)

function model7.init(p)
	return {
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		Title = import.make(model, p),
		Stats = import.make(model3, p),
		Rank = import.make(model4, p),
		Buttons = import.make(model6, p)
	}
end

local model8 = import.model("ScreenGui", basic.Ui)

function model8.init(p)
	local props = rankedBackdrop.props({
		OverlayTransparency = 0.28
	})
	props.Background2.Vignette = import.make(basic.ImageLabel, {
		Size = UDim2.new(1, 0, 1, 0),
		NoAspectRatio = true,
		Image = "rbxassetid://127132160355523",
		ImageColor3 = p.Win and Color3.fromRGB(47, 210, 94) or Color3.fromRGB(210, 52, 48),
		ImageTransparency = p.Win and 0.92 or 0.72,
		ScaleType = Enum.ScaleType.Stretch,
		ZIndex = 2
	})
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = -10,
		Name = "rankedMatchOver",
		Location = "Center",
		AspectRatio = 1.777,
		Scale = 1,
		Background = props.Background,
		Background2 = props.Background2,
		Content = {
			Container = import.make(model7, p)
		}
	}
end

return {
	RankedMatchOver = model8
}