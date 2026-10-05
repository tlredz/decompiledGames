local import = _G.import("romodel")
local import2 = _G.import("event")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local import3 = _G.import("rankData")
local import4 = _G.import("rankedState")
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local import5 = _G.import("viewImports")
local basic = import5:get("basic")
local ux = import5:get("ux")
local react = import5:get("react")
local avatar = import5:get("avatar").Avatar
local popups = script.Parent.Parent.popups
local modesData = require(popups.modesData)
local rankedCloseButton = require(popups.rankedCloseButton)
local closeButton = rankedCloseButton.CloseButton
local rankedBackdrop = require(popups.rankedBackdrop)
local _ = game.ReplicatedStorage.ReplicatedAssets
local defaultImage = modesData.DefaultImage
local uDim = UDim2.new(0.82, 0, 0.58, 0)
local uDim2 = UDim2.new(0, 0, 0, 0)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.6),
	NumberSequenceKeypoint.new(0.5, 0.725),
	NumberSequenceKeypoint.new(1, 0.6)
})
local numberSequence2 = NumberSequence.new(1)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 230, 78), Color3.fromRGB(223, 137, 34))
local fredokaOne = Enum.Font.FredokaOne
local v2 = {}
local v3 = modesData.get(modesData.LeftMode)
local many = modesData.getMany(modesData.TopModes)
local many2 = modesData.getMany(modesData.BottomModes)
local model = import.model("ImageButton", basic.Corner, basic.Stroke, ux.Button)

function model.init(data)
	local info = data.Info
	return {
		Size = data.Size or UDim2.new(1, 0, 1, 0),
		LayoutOrder = data.LayoutOrder,
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		CornerRadius = UDim.new(0.04, 0),
		StrokeColor = Color3.fromRGB(255, 255, 255),
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		StrokeTransparency = info.Selected and 0 or 1,
		Thickness = info.Selected and 0.006 or 0,
		Selected = info.Selected,
		Disabled = info.Mode == nil,
		Info = info,
		OnHovered = data.OnHovered,
		MouseButton1Down = function(p)
			if p.Disabled then
				return
			end

			if data.OnSelected then
				data.OnSelected(info, p)
			end
		end
	}, {
		Image = import.make(import.wrap("ImageLabel", basic.EmptyElement), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Image = info.Image or defaultImage,
			ScaleType = Enum.ScaleType.Crop,
			BackgroundTransparency = 1
		}, {
			UICorner = import.make("UICorner", {
				CornerRadius = UDim.new(0.04, 0)
			})
		}),
		Dimmer = import.make(import.wrap(basic.Gradient, basic.Corner), {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			GradientTransparency = numberSequence,
			CornerRadius = UDim.new(0.04, 0)
		}),
		TitleLabel = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.92, 0, 0.34, 0),
			Text = info.Text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			StrokeWidth = 3,
			TextWrapped = true
		})
	}
end

function model:setHovered(p)
	if self.Disabled then
		return
	end

	local dimmer = self.Dimmer
	local uIGradient = dimmer and dimmer.UIGradient
	local uIStroke = self.UIStroke

	if dimmer then
		dimmer.BackgroundTransparency = p and 1 or 0
	end

	if uIGradient then
		uIGradient.Transparency = p and numberSequence2 or numberSequence
	end

	if uIStroke then
		uIStroke.Transparency = p and 0 or self.Selected and 0 or 1
		uIStroke.Thickness = p and 0.006 or self.Selected and 0.006 or 0
	end
end

function model:spawn()
	local instance = self.Instance
	return {
		HoverEnterCon = instance.MouseEnter:Connect(function()
			self:setHovered(true)

			if self.OnHovered then
				self.OnHovered(self)
			end
		end),
		HoverLeaveCon = instance.MouseLeave:Connect(function()
			self:setHovered(false)
		end)
	}
end

function model.despawn(p)
	if p.HoverEnterCon then
		p.HoverEnterCon:Disconnect()
	end

	if p.HoverLeaveCon then
		p.HoverLeaveCon:Disconnect()
	end
end

local model2 = import.model(basic.EmptyList)

local function makeModeChildren(modes, data)
	local paddingScale = data.PaddingScale or 0.008
	local v4 = not (#modes > 0) and 1 or (1 - paddingScale * (#modes - 1)) / #modes or 1
	local result = {}

	for i, info in ipairs(modes) do
		result[info.Mode or tostring(i)] = import.make(model, {
			Info = info,
			LayoutOrder = i,
			Size = UDim2.new(v4, 0, 1, 0),
			OnSelected = data.OnSelected,
			OnHovered = data.OnModeHovered
		})
	end

	return result
end

function model2.init(data)
	local modes = data.Modes or {}
	local modeChildren = makeModeChildren(modes, data)

	for k, v4 in pairs(data.Children or {}) do
		modeChildren[k] = v4
	end

	return {
		Size = data.Size or UDim2.new(1, 0, 1, 0),
		LayoutOrder = data.LayoutOrder,
		Padding = UDim.new(data.PaddingScale or 0.008, 0),
		PaddingScale = data.PaddingScale or 0.008,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top
	}, modeChildren
end

local model3 = import.model(basic.EmptyList)

function model3.init(data)
	return {
		Size = UDim2.new(0.6735, 0, 1, 0),
		LayoutOrder = 2,
		Padding = UDim.new(0.012, 0),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top
	}, {
		Top = import.make(model2, {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0.494, 0),
			Modes = data.TopModes or many,
			OnSelected = data.OnSelected,
			OnModeHovered = data.OnModeHovered
		}, {
			OverlayFolder = import.make("Folder", nil, {
				CloseButton = import.make(closeButton, {
					Position = UDim2.new(1, 0, -0.05, 0),
					OnClose = data.OnClose,
					ZIndex = 101
				}),
				ComingSoonOverlay = import.make(import.wrap(basic.Element, basic.Corner), {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.22,
					BorderSizePixel = 0,
					CornerRadius = UDim.new(0.04, 0),
					ZIndex = 40
				}, {
					Label = import.make(basic.TextLabel, {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.7, 0, 0.32, 0),
						Text = "Coming Soon",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						StrokeWidth = 3,
						ZIndex = 41
					})
				})
			})
		}),
		Bottom = import.make(model2, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0.494, 0),
			PaddingScale = 0.012,
			Modes = data.BottomModes or many2,
			OnSelected = data.OnSelected,
			OnModeHovered = data.OnModeHovered
		})
	}
end

local function getRankInfo(p)
	local v4 = import3[p] and p or "Unranked"
	local v5 = import3[v4]
	return v4, v5, v5.DisplayName, v5.Icon, v5.FontFace or Font.fromEnum(fredokaOne)
end

local function getRankIdFromSave(object)
	if object then
		return object:getHighestModeRank()
	end

	return "Unranked"
end

local function getUsername(p)
	if not p then
		return "Player"
	end

	if v2[p] then
		return v2[p]
	end

	local playerByUserId = Players:GetPlayerByUserId(p)
	local name = playerByUserId and playerByUserId.Name or "Player"
	v2[p] = name
	return name
end

local model4 = import.model(basic.EmptyList)

function model4.init(options)
	local v4 = options or {}
	local player = v4.Player or game.Players.LocalPlayer
	local v5

	if v4.UseMobileLayout == false then
		v5 = false
	else
		v5 = v
	end

	local username = v4.Username or not player and "Player" or player.Name or "Player"
	local rankId = v4.RankId or "Unranked"
	local v7 = import3[import3[rankId] and rankId or "Unranked"]
	local displayName = v7.DisplayName
	local icon = v7.Icon
	local fontFace = v7.FontFace or Font.fromEnum(fredokaOne)
	return {
		Name = v4.Name or "PlayerSummary",
		Player = player,
		AnchorPoint = v4.AnchorPoint or Vector2.new(0, 1),
		Position = v4.Position or UDim2.new(0, 0, -0.04, 0),
		Size = v4.Size or UDim2.new(1, 0, 0.2, 0),
		LayoutOrder = v4.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment[v5 and "Center" or "Left"],
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(v4.PaddingScale or 0.008, 0)
	}, {
		Avatar = import.make(avatar, {
			UserId = v4.UserId or player and player.UserId,
			Image = v4.AvatarImage
		}),
		Info = import.make(basic.EmptyList, {
			Name = "Info",
			Size = UDim2.new(v5 and 0.25 or 0.89, 0, 1, 0),
			LayoutOrder = 2,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(-0.1, 0),
			ZIndex = -1
		}, {
			Rank = import.make(basic.EmptyList, {
				Name = "Rank",
				Size = UDim2.new(1, 0, 0.7, 0),
				LayoutOrder = 1,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.001, 0)
			}, {
				RankIcon = import.make("ImageLabel", {
					Name = "RankIcon",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					LayoutOrder = 1,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Image = icon,
					ScaleType = Enum.ScaleType.Fit
				}),
				RankName = import.make(basic.EmptyElement, {
					Name = "RankName",
					Size = UDim2.new(0.898, 0, 0.7, 0),
					LayoutOrder = 2,
					ZIndex = -1
				}, {
					Text = import.make(basic.TextLabel, {
						Location = "CenterLeft",
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.new(0, 0, 1, 0),
						Text = displayName,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						FontFace = fontFace,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						StrokeColor = Color3.fromRGB(0, 0, 0),
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
						StrokeWidth = 0.05
					})
				})
			}),
			Username = import.make(basic.EmptyElement, {
				Name = "Username",
				Size = UDim2.new(1, 0, 0.35, 0),
				LayoutOrder = 2
			}, {
				Text = import.make(basic.TextLabel, {
					Name = "Text",
					Position = UDim2.new(0.0067, 0, 0, 0),
					Size = UDim2.new(0.965, 0, 1, 0),
					Text = username,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					StrokeWidth = 0.075
				})
			})
		})
	}
end

local model5 = import.model(model4, react.Reactive)

function model5.init(_)
	return {
		KeyChains = { "RankedData" },
		SavedChanged = function(p, object)
			local v4 = not object and "Unranked" or object:getHighestModeRank()
			local v6 = import3[import3[v4] and v4 or "Unranked"]
			local displayName = v6.DisplayName
			local icon = v6.Icon
			local fontFace = v6.FontFace or Font.fromEnum(fredokaOne)
			p.Info.Rank.RankIcon.Image = icon
			local text = p.Info.Rank.RankName.Text
			text.Text = displayName
			text.FontFace = fontFace
		end
	}
end

local testLeaderboardEntries = {
	{
		UserId = 1,
		Value = 1950,
		Order = 1
	},
	{
		UserId = 2,
		Value = 1825,
		Order = 2
	},
	{
		UserId = 1,
		Value = 1640,
		Order = 3
	},
	{
		UserId = 2,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	},
	{
		UserId = 1,
		Value = 1410,
		Order = 4
	}
}

local function getLeaderboardEntries(p)
	if p.Entries then
		return p.Entries
	end

	local modeKey = p.ModeKey or "1v1"

	if plugin then
		return testLeaderboardEntries
	end

	local rankedLeaderboards = workspace:GetAttribute("RankedLeaderboards")
	local success, result = pcall(function()
		return HttpService:JSONDecode(rankedLeaderboards or "{}")
	end)
	return success and result[modeKey] or {}
end

local model6 = import.model(basic.EmptyElement)

local function makeLeaderboardChildren(leaderboardEntries, rowSlot, rowPadding, showRankNumber)
	local v5 = rowSlot - rowPadding * 2
	local result = {}

	for i, v6 in ipairs(leaderboardEntries or {}) do
		local order = v6.Order or i
		local make = import.make
		local v9 = {
			Name = "Summary",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			PaddingScale = 0.012,
			UserId = v6.UserId,
			Username = 0,
			RankId = 0,
			UseMobileLayout = false
		}
		local username = v6.Username

		if not username then
			local userId = v6.UserId

			if userId then
				if v2[userId] then
					username = v2[userId]
				else
					local playerByUserId = Players:GetPlayerByUserId(userId)
					username = playerByUserId and playerByUserId.Name or "Player"
					v2[userId] = username
				end
			else
				username = "Player"
			end
		end

		v9.Username = username
		v9.RankId = import4.getRankFromRating(v6.Value)
		local v7 = {
			Summary = make(model4, v9)
		}

		if showRankNumber then
			v7.RankNumber = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(0.95, 0, 0.5, 0),
				Size = UDim2.new(0.16, 0, 0.48, 0),
				Text = "" .. order,
				FontFace = import3.Diamond.FontFace,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Top,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				StrokeWidth = 0.05,
				ZIndex = 12
			})
		end

		result[tostring(i)] = import.make(basic.EmptyElement, {
			Name = i,
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, (i - 1) * rowSlot + rowPadding, 0),
			Size = UDim2.new(1, 0, v5, 0)
		}, v7)
	end

	return result
end

function model6.init(data)
	local leaderboardEntries = getLeaderboardEntries(data)
	local rowSlot = data.RowSlot or 0.2
	local rowPadding = data.RowPadding or 0.01
	return {
		Name = data.Name or "RankedLeaderboardList",
		AnchorPoint = Vector2.new(0, 0),
		Position = data.Position or UDim2.new(0, 0, 0, 0),
		Size = data.Size or UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}, (makeLeaderboardChildren(leaderboardEntries, rowSlot, rowPadding, data.ShowRankNumber))
end

local model7 = import.model(basic.EmptyElement)

function model7.init(p)
	local leaderboardEntries = getLeaderboardEntries(p)
	return {
		Name = "RankedLeaderboardScroller",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = -3,
		EntryCount = #leaderboardEntries,
		ScrollSpeed = 0.18
	}, {
		Top = import.make(model6, {
			Entries = leaderboardEntries,
			Position = UDim2.new(0, 0, -1, 0)
		}),
		Bottom = import.make(model6, {
			Entries = leaderboardEntries,
			Position = UDim2.new(0, 0, 0, 0)
		})
	}
end

function model7:spawn()
	local v5 = 0.2 * self.EntryCount
	local v6 = -v5
	local total = 0
	self.Top.Position = UDim2.new(0, 0, v6, 0)
	self.Bottom.Position = UDim2.new(0, 0, total, 0)
	self.ScrollCon = RunService.RenderStepped:Connect(function(dt)
		v6 += self.ScrollSpeed * dt
		total += self.ScrollSpeed * dt

		if v6 >= 0 then
			v6 = -v5
			total = 0
		end

		self.Top.Position = UDim2.new(0, 0, v6, 0)
		self.Bottom.Position = UDim2.new(0, 0, total, 0)
	end)
end

function model7.despawn(p)
	p.ScrollCon:Disconnect()
end

local model8 = import.model(basic.ImageButton, ux.Button, basic.Corner, basic.Gradient, basic.Stroke)

function model8.init(data)
	return {
		Name = "LeaderboardButton",
		AnchorPoint = data.AnchorPoint or Vector2.new(1, 1),
		Position = data.Position or UDim2.new(0.5 + uDim.X.Scale / 2, 0, 0.95, 0),
		Size = UDim2.new(1, 0, 0.15, 0),
		AspectRatio = 3,
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 205, 58),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		CornerRadius = UDim.new(0.08, 0),
		GradientRotation = 90,
		GradientColor = colorSequence,
		StrokeWidth = 3,
		StrokeColor = Color3.fromRGB(18, 18, 18),
		ZIndex = 100,
		MouseButton1Down = function(p)
			if data.OnSelected then
				data.OnSelected(p)
			end
		end
	}, {
		Label = import.make(basic.TextLabel, {
			Size = UDim2.new(0.86, 0, 0.72, 0),
			Location = "Center",
			Text = "Leaderboard",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			StrokeWidth = 2,
			ZIndex = 31
		})
	}
end

local model9 = import.model(basic.EmptyElement)

function model9.init(data)
	local selectedMode = data.SelectedMode or data.LeftMode or v3
	local modeDescription = data.ModeDescription or selectedMode.Description or "Select a mode to queue for a ranked match."

	local function onLeaderboardSelected(p)
		local screenGui = p.Instance:FindFirstAncestorOfClass("ScreenGui")
		local parent = screenGui and screenGui.Parent

		if parent then
			local rankedLeaderboard = require(script.Parent.rankedLeaderboard)
			local rankedLeaderboard2 = rankedLeaderboard.RankedLeaderboard
			import.mount(import.make(rankedLeaderboard2, {
				DisplayOrder = data.DisplayOrder,
				Scale = data.Scale,
				LeaderboardEntries = data.LeaderboardEntries
			}), parent)
		end

		if screenGui then
			screenGui:Destroy()
		end
	end

	local function onModeSelected(p, p2)
		import2.fire("requeue", p.PlayerCount, p2.Ui)
	end

	local function onModeHovered(p)
		local info = p.Info

		if not (info and info.Description and p.Instance) then
			return
		end

		local main = p.Instance:FindFirstAncestor("Main")
		local parent = main and main.Parent
		local modeDescription2 = parent and parent:FindFirstChild("ModeDescription")

		if modeDescription2 then
			modeDescription2.Text = info.Description
		end
	end

	return {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		TweenIn = data.TweenIn ~= false
	}, {
		ModesContainer = import.make(basic.EmptyElement, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = uDim
		}, {
			PlayerSummary = import.make(model5, {
				Player = data.Player,
				UserId = data.UserId,
				Username = data.Username,
				AvatarImage = data.AvatarImage
			}),
			Main = import.make(basic.EmptyList, {
				Size = UDim2.new(1, 0, 1, 0),
				Padding = UDim.new(0.0065, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top
			}, {
				Left = import.make(model, {
					Info = data.LeftMode or v3,
					LayoutOrder = 1,
					Size = UDim2.new(0.32, 0, 1, 0),
					OnSelected = onModeSelected,
					OnHovered = onModeHovered
				}),
				Right = import.make(model3, {
					TopModes = data.TopModes,
					BottomModes = data.BottomModes,
					OnSelected = onModeSelected,
					OnModeHovered = onModeHovered,
					OnClose = data.OnClose
				})
			}),
			ModeDescription = import.make(basic.TextLabel, {
				Name = "ModeDescription",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 1.025, 0),
				Size = UDim2.new(1, 0, 0.075, 0),
				Text = modeDescription,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextWrapped = true,
				StrokeWidth = 1,
				ZIndex = 20
			}),
			LeaderboardButton = import.make(model8, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 1.025, 0),
				OnSelected = onLeaderboardSelected
			})
		})
	}
end

function model9:spawn()
	local modesContainer = self.ModesContainer
	local main = modesContainer and modesContainer.Main
	local left = main and main.Left
	local right = main and main.Right
	local bottom = right and right.Bottom
	local modeDescription = modesContainer and modesContainer.ModeDescription
	local leaderboardButton = modesContainer and modesContainer.LeaderboardButton

	if not (modesContainer and main and left and right and bottom and modeDescription) then
		return
	end

	local function getLowestBottomIn(folder)
		local v5 = nil

		for _, guiObject in ipairs(folder:GetDescendants()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local v6 = guiObject.AbsolutePosition.Y + guiObject.AbsoluteSize.Y

			if v5 then
				v5 = math.max(v5, v6) or v6
			else
				v5 = v6
			end
		end

		return v5 or folder.AbsolutePosition.Y + folder.AbsoluteSize.Y
	end

	local function updateModeDescriptionPosition()
		if not (modesContainer and left and bottom and modeDescription) then
			return
		end

		local instance = modesContainer.Instance
		local instance2 = left.Instance
		local instance3 = bottom.Instance
		local instance4 = modeDescription.Instance

		if not (instance and instance2 and instance3 and instance4) then
			return
		end

		if instance.AbsoluteSize.X <= 0 or instance.AbsoluteSize.Y <= 0 then
			return
		end

		local v5 = math.max(instance2.AbsolutePosition.Y + instance2.AbsoluteSize.Y, (getLowestBottomIn(instance3)))
		local absolutePosition = instance.AbsolutePosition
		local absoluteSize = instance.AbsoluteSize
		local v6 = absoluteSize.Y * 0.05
		local v7 = (v5 - absolutePosition.Y + v6) / absoluteSize.Y
		modeDescription.AnchorPoint = Vector2.new(0.5, 0)
		modeDescription.Position = UDim2.new(0.5, 0, v7, 0)
		modeDescription.Size = UDim2.new(1, 0, 0.075, 0)

		if leaderboardButton then
			leaderboardButton.Position = UDim2.new(
				leaderboardButton.Position.X.Scale,
				leaderboardButton.Position.X.Offset,
				v7,
				0
			)
		end
	end

	self.ModeDescriptionLayoutCons = {
		modesContainer.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateModeDescriptionPosition),
		modesContainer.Instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateModeDescriptionPosition),
		left.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateModeDescriptionPosition),
		left.Instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateModeDescriptionPosition),
		bottom.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateModeDescriptionPosition),
		bottom.Instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateModeDescriptionPosition)
	}

	for _, guiObject in ipairs(bottom.Instance:GetDescendants()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		table.insert(
			self.ModeDescriptionLayoutCons,
			guiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateModeDescriptionPosition)
		)
		table.insert(
			self.ModeDescriptionLayoutCons,
			guiObject:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateModeDescriptionPosition)
		)
	end

	task.defer(updateModeDescriptionPosition)

	if not self.TweenIn then
		return
	end

	modesContainer.Size = uDim2
	modesContainer:tween(TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = uDim
	})
end

function model9.despawn(p)
	for _, connection in ipairs(p.ModeDescriptionLayoutCons or {}) do
		connection:Disconnect()
	end
end

local model10 = import.model("ScreenGui", basic.Ui)

function model10.init(options)
	local v5 = options or {}
	local props = rankedBackdrop.props(v5)
	props.Background2.RankedLeaderboardScroller = import.make(model7, {
		Entries = v5.LeaderboardEntries,
		ModeKey = v5.LeaderboardModeKey or "1v1"
	})
	return {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = v5.DisplayOrder or 5,
		Name = "RankedOverlay",
		Location = "Center",
		AspectRatio = 1.777,
		Scale = v5.Scale or 1,
		Background = props.Background,
		Background2 = props.Background2,
		Content = v5.Content or {
			Content = import.make(model9, v5)
		}
	}
end

return {
	Ranked = model10,
	LeaderboardList = model6,
	GetLeaderboardEntries = getLeaderboardEntries,
	TestLeaderboardEntries = testLeaderboardEntries
}