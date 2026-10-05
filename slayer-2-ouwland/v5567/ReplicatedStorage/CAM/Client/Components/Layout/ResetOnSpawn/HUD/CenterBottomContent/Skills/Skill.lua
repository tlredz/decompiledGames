local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Skill_Switch_Adder = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local info = faye.Info(0.2)
return function(maid, layoutOrder: number, data, _)
	local visible = maid:DelayValue(data.Enabled):For(true, 0.25)
	local delayTime = 0
	local value = maid:Value(0.45)
	local value2 = maid:Value(0.45)
	local value3 = maid:Value(0)
	local value4 = maid:Value(Color3.new(0.1, 0.1, 0.1))
	local value5 = maid:Value(Color3.new())
	local value6 = maid:Value(Color3.new(1, 1, 1))
	local imageColor = maid:Value(Color3.new(1, 1, 1))
	local value8 = maid:Value(UDim2.fromScale(1, 1))
	local springInfo = maid.SpringInfo(0.3, 1, 0.5, nil, nil, 0)
	local value9 = maid:Value(0.25)
	local v3 = nil
	local visible2 = maid:Value(false)
	local v4 = nil

	local function update()
		local v5 = (data.Holding.HoldingState:Compare(true) or data.CoolDown:Compare(true)) and 1 or 0

		if v3 ~= v5 then
			v3 = v5

			if v5 == 1 then
				visible2:Set(true)
				value9:Reset()
			else
				visible2:Reset()
				value9:Set(1)
			end
		end

		local v6

		if not data.Enabled:Compare(true) then
			v6 = 0
		elseif data.Locked:Compare(true) then
			v6 = 4
		elseif data.Switch:Compare(true) then
			v6 = 3
		elseif data.Holding.HoldingState:Compare(true) then
			v6 = 2
		else
			v6 = 1
		end

		if v4 ~= v6 then
			delayTime = 0.03 * ((data.EnabledCount or 1) - ((data.VisualIndex or 1) - 1))
			springInfo.DelayTime = delayTime

			if v6 == 4 then
				value8:Reset()
				imageColor:Reset()
				value3:Set(0.5)
				value5:Reset()
				value:Set(0.5)
				value4:Reset()
				value2:Set(0)
				value6:Set(Color3.new(1, 1, 1))
			elseif v6 == 1 then
				imageColor:Set(Color3.new(1, 0, 0))
				value8:Reset()
				value:Reset()
				value2:Reset()
				value3:Reset()
				value6:Reset()
				value4:Reset()
				value5:Reset()
			elseif v6 == 3 then
				value8:Reset()
				value:Reset()
				value2:Reset()
				value3:Set(1)
				value6:Reset()
				value4:Reset()
				value5:Reset()
			elseif v6 == 2 then
				value8:Reset()
				imageColor:Reset()
				value3:Reset()
				value5:Set(Color3.new(0.35, 0.35, 0.35))
				value:Set(0.5)
				value4:Set(Color3.new(0.75, 0.75, 0.75))
				value2:Set(0)
				value6:Set(Color3.new())
			else
				imageColor:Reset()
				value8:Set(UDim2.fromScale())
				value:Set(1)
				value2:Set(1)
				value3:Set(1)
				value6:Reset()
				value4:Reset()
				value5:Reset()
			end

			v4 = v6
		end
	end

	update()
	maid:Connect(data.CoolDown.Changed, update)
	maid:Connect(data.Enabled.Changed, update)
	maid:Connect(data.Holding.HoldingState.Changed, update)
	maid:Connect(data.Switch.Changed, update)

	if data.Locked then
		maid:Connect(data.Locked.Changed, update)
	end

	return maid:Create("Frame")({
		maid:State(function(callback, object)
			local v5 = callback(data.SplitHere)

			if v5 == 1 then
				return object:Create("Frame")({
					Size = UDim2.fromScale(4.5, 1.1),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1.025, 0.5),
					Visible = object:Do(function(callback2)
						return not callback2(data.Holding.HoldingState)
					end),
					object:Create("UICorner")({
						CornerRadius = UDim.new(0.2)
					}),
					BackgroundTransparency = 0.65,
					BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.4, 0.6),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = 180
					}),
					object:Create("UIStroke")({
						BorderOffset = UDim.new(0, -2),
						Color = Color3.new(1, 1, 1),
						Transparency = 0.45,
						object:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.2, 1),
								NumberSequenceKeypoint.new(1, 1)
							}),
							Rotation = 180
						})
					})
				})
			elseif v5 == 2 then
				return object:Create("Frame")({
					Size = UDim2.fromScale(4.5, 1.1),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(-0.025, 0.5),
					Visible = object:Do(function(callback2)
						return not callback2(data.Holding.HoldingState)
					end),
					object:Create("UICorner")({
						CornerRadius = UDim.new(0.2)
					}),
					BackgroundTransparency = 0.65,
					BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.4, 0.6),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = 0
					}),
					object:Create("UIStroke")({
						BorderOffset = UDim.new(0, -2),
						Color = Color3.new(1, 1, 1),
						Transparency = 0.45,
						object:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.2, 1),
								NumberSequenceKeypoint.new(1, 1)
							}),
							Rotation = 0
						})
					})
				})
			end
		end),
		Name = layoutOrder .. "-Skill",
		LayoutOrder = layoutOrder,
		After = function(p2)
			if data.OnGui == nil then
				return
			end

			data.OnGui(p2)
			maid:Add(function()
				data.OnGui(nil, p2)
			end)
		end,
		Size = maid:Animation(value8, springInfo, {
			From = UDim2.fromScale()
		}),
		Visible = maid:DelayValue(data.Enabled):For(false, delayTime + 0.2),
		BackgroundTransparency = 1,
		maid:Create("ImageLabel")({
			Name = "Bg",
			Size = UDim2.fromScale(1.2, 1.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageColor3 = maid:Animation(value5, info),
			ImageTransparency = maid:Animation(value, info, {
				From = 1
			}),
			Image = "http://www.roblox.com/asset/?id=109235190169711"
		}),
		maid:Create("ImageLabel")({
			Size = UDim2.fromScale(1.15, 1.15),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.new(0.25, 0.25, 0.25),
			maid:Create("Frame")({
				Size = UDim2.fromScale(0.5, 1),
				Name = "Left",
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				maid:Create("ImageLabel")({
					Visible = visible2,
					Size = UDim2.fromScale(2, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://72297746168397",
					ImageColor3 = imageColor,
					maid:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.495, 0),
							NumberSequenceKeypoint.new(0.505, 1),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = maid:Do(function(callback)
							return (math.clamp(180 - callback(data.Holding.Rotation), 0, 180))
						end)
					})
				})
			}),
			maid:Create("Frame")({
				Name = "Right",
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),
				maid:Create("ImageLabel")({
					Visible = visible2,
					Size = UDim2.fromScale(2, 1),
					Position = UDim2.fromScale(-1, 0),
					BackgroundTransparency = 1,
					ImageColor3 = imageColor,
					Image = "rbxassetid://72297746168397",
					maid:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.495, 0),
							NumberSequenceKeypoint.new(0.505, 1),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Rotation = maid:Do(function(callback)
							return -math.clamp(callback(data.Holding.Rotation) - 180, 0, 180)
						end)
					})
				})
			}),
			ImageTransparency = maid:Animation(value9, info),
			Image = "rbxassetid://110991810001935"
		}),
		maid:Create("ImageLabel")({
			ZIndex = 3,
			Name = "Fg",
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			ImageColor3 = maid:Animation(value4, info),
			ImageTransparency = maid:Animation(value2, info, {
				From = 1
			}),
			Image = "http://www.roblox.com/asset/?id=137188897938310"
		}),
		maid:Create("ImageLabel")({
			ZIndex = 4,
			Name = "Image",
			Size = UDim2.fromScale(0.6, 0.6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = maid:Animation(value3, info, {
				From = 1
			}),
			BackgroundTransparency = 1,
			ImageColor3 = maid:Animation(value6, info),
			Image = data.Icon
		}),
		maid:State(function(callback, object, _)
			if callback(data.Locked) then
				return object:Create("ImageLabel")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(0.6, 0.6),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = 6,
					BackgroundTransparency = 1,
					Image = BunchaIcons.Locked
				})
			end

			return object:Create("TextButton")({
				Size = UDim2.new(1, 5, 1),
				ZIndex = 10,
				BackgroundTransparency = 1,
				MouseEnter = function()
					if data.Hover ~= nil then
						data.Hover:Enter()
					end
				end,
				MouseLeave = function()
					if data.Hover ~= nil then
						data.Hover:Leave()
					end
				end
			})
		end),
		maid:State(function(callback, object)
			if callback(data.Switch) == true then
				return object:Create("ImageLabel")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(0.95, 0.95),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = 6,
					BackgroundTransparency = 1,
					Image = Skill_Switch_Adder.Lever_Icon,
					ImageColor3 = Skill_Switch_Adder.Lever_Color,
					Rotation = object:Animation(
						-25,
						object.Info(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
						{
							From = 25
						}
					),
					OnClean = function()
						return {
							ImageTransparency = object:Animation(1, info)
						}
					end
				})
			end
		end),
		Utility.AddTag(maid:Create("Frame")({
			Name = data.Key,
			BackgroundTransparency = gameSettings.KeybindTextTransparency,
			Visible = visible,
			AnchorPoint = Vector2.new(0.5, 1),
			Size = gameSettings.KeybindTextSize,
			Position = UDim2.new(0.5, 0, 0, -3),
			ZIndex = -1
		}), "UIkey")
	})
end