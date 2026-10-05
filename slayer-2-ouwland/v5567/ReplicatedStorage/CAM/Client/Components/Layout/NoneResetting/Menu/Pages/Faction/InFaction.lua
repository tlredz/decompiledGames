local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BannerId = require(script.BannerId)
local DisbandButton = require(script.DisbandButton)
local Member = require(script.Member)
local NameEditor = require(script.NameEditor)
local ReputationHolder = require(script.ReputationHolder)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
require(ReplicatedStorage.CAM.Client.Modules.FactionState)
local Invite = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.CenterLeft.PartyComponents.Invite)
local v = Players.LocalPlayer == nil and 0 or Players.LocalPlayer.UserId
local vector = Vector2.new(1.2, 1.15)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

local function countSize()
	local v2 = Platform_Handler.Platform.Value == "Mobile" and 22 or 14
	return UDim2.new(0.7, 0, 0, v2)
end

local color = Color3.fromRGB(215, 130, 130)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
return function(object, p, data)
	local disabled = #data.Members >= gameSettings.maxFactionMembers
	local size = object:Value(countSize())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		size:Set(countSize())
	end)
	local v3 = object:Create("Frame")
	local v4 = {
		Name = "InFaction",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local state = object:State(function(callback, p2)
		if callback(p) == true then
			return DisbandButton(p2)
		end
	end)
	local v5 = object:Create("Frame")
	local v6 = {
		Name = "Topbar",
		Size = UDim2.fromScale(1, 0.15),
		BackgroundTransparency = 1
	}
	local v7 = object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0.01)
	})
	local v8 = object:Create("Frame")({
		Name = "OThers",
		ZIndex = 2,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.Name
		}),
		object:Create("Frame")({
			Name = "AName",
			Size = UDim2.fromScale(1, 0.35),
			BackgroundTransparency = 1,
			NameEditor(object, data.FactionName, p)
		}),
		object:Create("Frame")({
			Name = "BannerChanger",
			Size = UDim2.fromScale(1, 0.35),
			BackgroundTransparency = 1,
			Visible = object:Do(function(callback)
				return callback(p) == true
			end),
			BannerId(object, p)
		}),
		object:Create("Frame")({
			Name = "CReputation",
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			ReputationHolder(object, data)
		})
	})
	local v9 = object:Create("Frame")
	local v10 = {
		Name = "IconHolder",
		Size = UDim2.fromScale(1, 1),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1
	}
	local v11 = object:Create("Frame")({
		Name = "Bg",
		Size = UDim2.fromScale(0.9, 0.9),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.3)
		}),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1),
			Color = Color3.new(0.3, 0.3, 0.3),
			Transparency = 0
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 1) }),
			Rotation = -90
		})
	})
	local v12 = object:Create("ImageLabel")
	local v13 = {
		Name = "Icon",
		Size = UDim2.new(1, -8, 1, -8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit
	}
	local image

	if data.FactionBanner == nil or data.FactionBanner == "" then
		image = BunchaIcons.NoFactionIcon
	else
		image = data.FactionBanner
	end

	v13.Image = image
	do local _values = table.pack(object:Create("UICorner")({
	CornerRadius = UDim.new(0.3)
})); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	do local _values = table.pack(v11, v12(v13)); for _k = 1, _values.n do v10[1 + _k] = _values[_k] end end
	do local _values = table.pack(v7, v8, v9(v10)); for _k = 1, _values.n do v6[_k] = _values[_k] end end
	local v15 = v5(v6)
	local v16 = object:Create("Frame")({
		Name = "Holder",
		Position = UDim2.fromScale(0.5, 0.16),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromScale(1, 0.74),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.025)
		}),
		BackgroundTransparency = 1,
		object:Create("UIShadow")({
			BlurRadius = UDim.new(0.5, 0),
			Spread = UDim2.new(-0.5, 0, -0.5, 0),
			Transparency = 0.75
		}),
		object:Create("CanvasGroup")({
			Name = "ListMask",
			Size = UDim2.new(1, -4, 1, -4),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			object:Create("UIGradient")({
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.03, 0),
					NumberSequenceKeypoint.new(0.84, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("ScrollingFrame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				CanvasSize = UDim2.new(),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 0,
				object:Create("Frame")({
					Name = "Holder",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -4, 1, -4),
					BackgroundTransparency = 1,
					object:Create("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						FillDirection = Enum.FillDirection.Horizontal,
						Wraps = true,
						SortOrder = Enum.SortOrder.Name,
						Padding = UDim.new(0.01),
						AbsoluteContentSizeOnChangedInit = function(p2, point: Vector2)
							local parent = p2.Parent and p2.Parent.Parent

							if parent ~= nil and parent:IsA("ScrollingFrame") then
								parent.CanvasSize = UDim2.new(0, 0, 0, point.Y * 1.05)
							end
						end
					}),
					object:Iterate(data.Members, function(p2: number, p3, object2)
						return object2:Create("Frame")({
							Name = string.format(
								p3.UserId == v and "AA%03d" or p3.IsAdmin and "AB%03d" or "Member%03d",
								p2
							),
							Size = UDim2.fromScale(0.242, 0.242),
							BackgroundTransparency = 1,
							Instance.new("UIAspectRatioConstraint"),
							Member(object2, p3, p)
						})
					end)
				})
			})
		})
	})
	local v17 = object:Create("Frame")
	local v18 = {
		Name = "InviteHolder",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1
	}
	local v19 = object:Create("UIListLayout")({
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0, 2)
	})
	local state2 = object:State(function(callback, p2)
		if callback(p) ~= true then
			return
		end

		local factionId = data.FactionId
		local v22 = {
			Signal = "Invite To Faction",
			Placeholder = disabled and "Faction is full" or "Write a player name to invite",
			Disabled = disabled,
			Name = "InviteBox",
			SizeScale = vector,
			BgColor = 0,
			NoStroke = true,
			Shadow = true
		}
		local bgColor

		if disabled then
			bgColor = color
		else
			bgColor = Color3.new(0.22, 0.22, 0.25)
		end

		v22.BgColor = bgColor
		return Invite(p2, factionId, 26, v22)
	end)
	local v20 = object:Create("TextLabel")
	local v21 = {
		Name = "ZMembers",
		Size = size,
		BackgroundTransparency = 1,
		TextScaled = true,
		Text = `{#data.Members} of {gameSettings.maxFactionMembers} members`,
		TextColor3 = 0,
		TextTransparency = 0.25,
		Font = 0
	}
	local textColor

	if disabled then
		textColor = color
	else
		textColor = Color3.new(1, 1, 1)
	end

	v21.TextColor3 = textColor
	v21.Font = Enum.Font.SourceSansSemibold
	do local _values = table.pack(v19, state2, v20(v21)); for _k = 1, _values.n do v18[_k] = _values[_k] end end
	do local _values = table.pack(state, v15, v16, v17(v18)); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	return v3(v4)
end