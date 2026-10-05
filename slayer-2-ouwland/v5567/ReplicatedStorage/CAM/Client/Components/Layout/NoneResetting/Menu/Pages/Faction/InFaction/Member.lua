local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Client.Modules.FactionState)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Load_Custom = require(ReplicatedStorage.CAM.Global.Load_Custom)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local color = Color3.fromRGB(80, 200, 110)
local color2 = Color3.fromRGB(215, 75, 75)
local info = faye.Info(0.35)
local color3 = Color3.fromRGB(85, 170, 255)
local color4 = Color3.fromRGB(150, 150, 155)
local color5 = Color3.fromRGB(215, 130, 130)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.3),
	NumberSequenceKeypoint.new(0.7, 0.6),
	NumberSequenceKeypoint.new(1, 0.85)
})
local uDim = UDim2.fromScale(0.56, 0.49)
local color6 = Color3.fromRGB(210, 195, 120)
local color7 = Color3.fromRGB(150, 205, 255)
local v = simplesignal.new()
InputHandler.ScreenClicked(function(p: string, flag: boolean)
	if p == "Down" and not flag then
		v:Fire(nil)
	end
end)

local function action(object, name: string, layoutOrder: number, color8: Color3, text: string, clicked)
	return object:Create("Frame")({
		Name = name,
		CleanDelay = info.Time,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1, 0.4),
		BackgroundTransparency = 1,
		GradientButton(object, {
			Text = text,
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.SourceSansBold,
			BgColor = color8,
			GradientTransparency = numberSequence,
			Properties = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5)
			},
			Clicked = clicked
		})
	})
end

return function(maid, player, p)
	local v2

	if player.Reputation >= 0 then
		v2 = color
	else
		v2 = color2
	end

	local v3

	if Players.LocalPlayer == nil then
		v3 = false
	else
		v3 = Players.LocalPlayer.UserId == player.UserId
	end

	local value = maid:Value(false)
	maid:Add(v:Connect(function(p2: number?)
		if p2 ~= player.UserId then
			value:Set(false)
		end
	end))
	local flag = false

	local function kick()
		if flag then
			return
		end

		flag = true

		if PopUpCreator.new({
			Type = "Question",
			Content = `Kick {Utility.NameTag(player.DisplayName, true)} from the faction?`
		}).Result:Wait() == "Yes" then
			local v4 = PopUpCreator.new({
				Type = "LoadingFull"
			})
			pcall(SignalFunction.ToServer, "Kick From Faction", player.UserId)
			v4:Destroy()
		end

		flag = false
		value:Set(false)
	end

	local function setAdmin()
		if flag then
			return
		end

		flag = true
		local v4 = PopUpCreator.new({
			Type = "LoadingFull"
		})
		pcall(SignalFunction.ToServer, "Set Faction Admin", player.UserId, not player.IsAdmin)
		v4:Destroy()
		flag = false
		value:Set(false)
	end

	local function leave()
		if flag then
			return
		end

		flag = true

		if PopUpCreator.new({
			Type = "Question",
			Content = "Leave the faction?"
		}).Result:Wait() == "Yes" then
			local v4 = PopUpCreator.new({
				Type = "LoadingFull"
			})
			pcall(SignalFunction.ToServer, "Leave Faction")
			v4:Destroy()
		end

		flag = false
		value:Set(false)
	end

	local v4 = maid:Create("Frame")
	local v5 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}
	local v6 = maid:Create("Frame")({
		Name = "Bottom",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -4),
		Size = UDim2.new(1, -4, 0.6),
		BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
		maid:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) }),
			Rotation = -90
		}),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		maid:Create("UIShadow")({
			BlurRadius = UDim.new(1),
			Color = Color3.new(0.3, 0.3, 0.3),
			Transparency = 0
		})
	})
	local v7 = maid:Create("Frame")({
		Name = "Center",
		ZIndex = 2,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(0.7, 0, 0.9),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		maid:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1) }),
			Rotation = -90
		}),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		maid:Create("UIShadow")({
			BlurRadius = UDim.new(0.7),
			Color = Color3.new(0.1, 0.1, 0.1),
			Transparency = 0
		})
	})
	local v8 = maid:Create("Frame")({
		Name = "IconHolder",
		Size = UDim2.fromScale(0.8, 0.8),
		ZIndex = 2,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -4),
		BackgroundTransparency = 1,
		function()
			local playerByUserId = Players:GetPlayerByUserId(player.UserId)

			if playerByUserId == nil then
				return maid:Create("ImageLabel")({
					Name = "Portrait",
					Size = UDim2.fromScale(0.9, 0.9),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = 3,
					BackgroundTransparency = 1,
					Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`,
					maid:Create("UICorner")({
						CornerRadius = UDim.new(1)
					})
				})
			end

			return maid:Create("ViewportFrame")({
				Name = "Portrait",
				Size = UDim2.fromScale(0.9, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ZIndex = 3,
				BackgroundTransparency = 1,
				maid:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				function(parent)
					local data = Utility.GetData(playerByUserId, true)

					if data == nil or parent.Parent == nil then
						return
					end

					local worldModel = Instance.new("WorldModel")
					worldModel.Parent = parent
					local clone = ReplicatedStorage.Assets.StarterCharacterCloneable:Clone()
					clone.Parent = worldModel
					local humanoid = clone:FindFirstChild("Humanoid")

					if humanoid then
						humanoid:Destroy()
					end

					local humanoid2 = Instance.new("Humanoid")
					humanoid2.Name = "Humanoid"
					humanoid2.RigType = Enum.HumanoidRigType.R15
					humanoid2.Parent = clone
					clone.HumanoidRootPart.Anchored = true
					local camera = Instance.new("Camera")
					camera.Parent = parent
					parent.CurrentCamera = camera
					local v9 = clone.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2).Position
					local position = clone.HumanoidRootPart.Position
					camera.CFrame = CFrame.new(v9, position) + vector.create(
						0,
						data.Race.Value == "Demon" and 2 or 1.75,
						0
					)
					Load_Custom(playerByUserId, clone, data, true)
				end
			})
		end
	})
	local v9 = maid:Create("Frame")({
		Name = "Reputation",
		ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.1),
		Size = UDim2.fromScale(0.48, 0.16),
		BackgroundColor3 = v2,
		BackgroundTransparency = 0.15,
		maid:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		maid:Create("UIGradient")({
			Rotation = -90,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.6) })
		}),
		maid:Create("UIShadow")({
			Color = v2,
			BlurRadius = UDim.new(0.5, 0),
			Transparency = 0.4
		}),
		maid:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 3)
		}),
		maid:Create("ImageLabel")({
			Name = "Icon",
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.7, 0.7),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundTransparency = 1,
			Image = BunchaIcons.Reputation
		}),
		maid:Create("TextLabel")({
			Name = "Count",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.5, 0.8),
			BackgroundTransparency = 1,
			Text = tostring(player.Reputation),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = gameSettings.preferedFont
		})
	})
	local v10 = maid:Create("TextLabel")
	local v11 = {
		Name = "DisplayName",
		ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1.06),
		Size = UDim2.fromScale(1.5, 0.12),
		BackgroundTransparency = 1,
		RichText = true
	}
	local v12

	if v3 then
		v12 = `<font color="#{color7:ToHex()}">ME</font>`
	else
		v12 = player.DisplayName
	end

	v11.Text = v12 .. (not player.IsAdmin and "" or ` <font color="#{color6:ToHex()}">(Admin)</font>`)
	v11.TextScaled = true
	v11.TextColor3 = Color3.new(1, 1, 1)
	v11.FontFace = gameSettings.preferedFont
	do local _values = table.pack(maid:Create("UIStroke")({
	Thickness = 2,
	Color = Color3.new(),
	Transparency = 0.6
})); for _k = 1, _values.n do v11[_k] = _values[_k] end end
	do local _values = table.pack(v6, v7, v8, v9, v10(v11), maid:Create("TextButton")({
	Name = "Open",
	Size = UDim2.fromScale(1, 1),
	ZIndex = 5,
	BackgroundTransparency = 1,
	Visible = maid:Do(function(callback)
		local v13 = v3

		if not v13 then
			if p == nil then
				return false
			else
				return callback(p) == true
			end
		end

		return v13
	end),
	MouseButton1Click = function()
		ScreenEffects.CircleClick()
		value:Set(true)
		v:Fire(player.UserId)
	end
}), maid:State(function(callback, object)
	if not callback(value) then
		return
	end

	local v13 = object:Create("CanvasGroup")
	local v14 = {
		Name = "Actions",
		ZIndex = 10,
		Size = UDim2.fromScale(1.2, 1.2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		GroupTransparency = object:Animation(0, info, {
			From = 1
		}),
		OnClean = function(object2)
			return {
				GroupTransparency = object2:Animation(1, info)
			}
		end
	}
	local v15 = object:Create("TextButton")
	local v16 = {
		Name = "Cover",
		ZIndex = 10,
		CleanDelay = info.Time,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.25,
		AutoButtonColor = false,
		MouseButton1Click = function()
			value:Set(false)
		end
	}
	local v17 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.2)
	})
	local v18 = object:Create("Frame")
	local v19 = {
		Name = "Buttons",
		CleanDelay = info.Time,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = uDim,
		BackgroundTransparency = 1
	}
	local v20 = object:Create("UIListLayout")({
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0.08, 0)
	})
	local v21

	if v3 then
		v21 = action(object, "LeaveHolder", 1, color5, "Leave", leave)
	end

	local v22

	if not v3 then
		local v26

		if player.IsAdmin then
			v26 = color4
		else
			v26 = color3
		end

		v22 = action(object, "AdminHolder", 1, v26, player.IsAdmin and "Demote" or "Promote", setAdmin)
	end

	local v23

	if not v3 then
		v23 = action(object, "KickHolder", 2, color5, "Kick", kick)
	end

	v19[1], v19[2], v19[3], v19[4] = v20, v21, v22, v23
	do local _values = table.pack(v17, v18(v19)); for _k = 1, _values.n do v16[_k] = _values[_k] end end
	do local _values = table.pack(v15(v16)); for _k = 1, _values.n do v14[_k] = _values[_k] end end
	return v13(v14)
end)); for _k = 1, _values.n do v5[_k] = _values[_k] end end
	return v4(v5)
end