local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local Allegiance = require(ReplicatedStorage.CAM.Global.Allegiance)
local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0.25, 0.25, 0.25)
local color3 = Color3.new(0.85, 0.85, 0.85)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(0.15, 0.15, 0.15)
local uDim = UDim.new(1, 0)
local uDim2 = UDim2.fromScale(0, 0.08)
local color6 = Color3.new()
local info = faye.Info(0.15)
local color7 = Color3.new(0.15, 0.15, 0.15)
return function(maid, options)
	local v = options or {}
	local rowHeight = v.RowHeight or 22
	local v2 = DataValue.new(SettingsKeys.PvpSwitch.Path, SettingsKeys.PvpSwitch.Default, SettingsKeys.Scope)
	local value = maid:Value(v2:Get())
	maid:Add(v2.Changed:Connect(function(p)
		value:Set(p)
	end))
	maid:Add(v2)
	local value2 = maid:Value(not (Allegiance.PvpSwitchWorldOff or AreaLocator.AreaEquipped.NoPvpSwitch))
	maid:Add(AreaLocator.AreaEquipped.Update:Connect(function()
		value2:Set(not (Allegiance.PvpSwitchWorldOff or AreaLocator.AreaEquipped.NoPvpSwitch))
	end))
	local value3 = maid:Value(Platform_Handler.Platform.Value)
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		value3:Set(Platform_Handler.Platform.Value)
	end)
	return maid:State(function(callback, maid2)
		if callback(value) ~= true or callback(value2) ~= true or v.OnlyOn ~= nil and v.OnlyOn[callback(value3)] ~= true then
			return nil
		end

		local v3 = DataValue.new(Allegiance.PvpPref.Path, Allegiance.PvpPref.Default, "Slot")
		local value4 = maid2:Value(v3:Get() ~= false)
		maid2:Add(v3.Changed:Connect(function(p)
			value4:Set(p ~= false)
		end))
		maid2:Add(v3)
		local value5 = maid2:Value(color2)
		local value6 = maid2:Value(color3)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function upd()
			if value4:Compare(true) then
				value5:Set(color4)
				value6:Set(color5)
			else
				value5:Reset()
				value6:Reset()
			end
		end

		maid2:Connect(value4.Changed, upd)
		upd() -- equivalent call inferred; original call site unknown
		local flag = false
		local flag2 = false
		local v4 = maid2:Create("Frame")
		local size

		if v.FillWidth then
			size = UDim2.new(1, 0, 0, rowHeight)
		else
			size = UDim2.new(0, 0, 0, rowHeight)
		end

		local automaticSize

		if v.FillWidth then
			automaticSize = Enum.AutomaticSize.None
		else
			automaticSize = Enum.AutomaticSize.X
		end

		return v4({
			Name = "PvpSwitch",
			Size = size,
			AutomaticSize = automaticSize,
			AnchorPoint = v.AnchorPoint,
			Position = v.Position,
			BackgroundTransparency = 1,
			maid2:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = v.HorizontalAlignment or Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			maid2:Create("TextButton")({
				Name = "Plate",
				AutoButtonColor = false,
				Text = "",
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = color7,
				BackgroundTransparency = 0.35,
				maid2:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				maid2:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0.75)
					})
				}),
				maid2:Create("UIPadding")({
					PaddingLeft = UDim.new(0, rowHeight * 0.35),
					PaddingRight = UDim.new(0, rowHeight * 0.35)
				}),
				maid2:Create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, rowHeight * 0.2)
				}),
				maid2:Create("ImageLabel")({
					Name = "Glyph",
					LayoutOrder = 1,
					Size = UDim2.fromOffset(rowHeight * 0.8, rowHeight * 0.8),
					BackgroundTransparency = 1,
					Image = "rbxassetid://104031883855826",
					ImageColor3 = color
				}),
				maid2:Create("Frame")({
					Name = "Track",
					LayoutOrder = 2,
					Size = UDim2.fromOffset(rowHeight * 0.5 * 2, rowHeight * 0.5),
					BackgroundColor3 = maid2:Animation(value5, info),
					maid2:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					maid2:Create("Frame")({
						Name = "Knob",
						maid2:Create("UIShadow")({
							BlurRadius = uDim,
							Offset = uDim2,
							Transparency = 0.55,
							Color = color6
						}),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = maid2:Do(function(callback2)
							local uDim3 = UDim2.fromScale(callback2(value4) == true and 0.8 or 0.2, 0.5)

							if flag then
								return maid2:Animation(uDim3, info)
							end

							flag = true
							return uDim3
						end),
						Size = UDim2.fromScale(0.8, 0.8),
						maid2:Create("UIAspectRatioConstraint")({}),
						BackgroundColor3 = maid2:Animation(value6, info),
						maid2:Create("UICorner")({
							CornerRadius = UDim.new(1)
						})
					})
				}),
				maid2:Create("TextLabel")({
					Name = "Word",
					LayoutOrder = 3,
					Text = "PvP",
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					TextColor3 = color,
					TextStrokeTransparency = 0.7,
					Font = Enum.Font.SourceSansBold,
					TextSize = rowHeight * 0.6,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				MouseButton1Click = function()
					if flag2 then
						return
					end

					flag2 = true
					ScreenEffects.CircleClick()
					SignalEvent.ToServer("GeneralPvp", not value4:Compare(true))
					task.delay(0.5, function()
						flag2 = false
					end)
				end
			})
		})
	end)
end