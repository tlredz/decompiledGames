local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local info2 = faye.Info(0.4)
local info3 = faye.Info(0.2)
local info4 = faye.Info(0.5, Enum.EasingStyle.Back)
local info5 = faye.Info(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local info6 = faye.Info(0.1)
local info7 = faye.Info(0.2)
local color = Color3.fromRGB(90, 255, 68)
local color2 = Color3.fromRGB(255, 255, 255)
return function(parent, character, _, _, object)
	local v = nil
	local v2 = false
	local v3 = nil

	local function onBlocking(instance)
		if v then
			v:Destroy()
			v = nil
		end

		local blocking = instance:FindFirstChild("Blocking")

		if not blocking then
			return
		end

		v = faye.new()
		local value = v:Value(UDim2.fromScale(1, 1))
		local value2 = v:Value(0.7)
		local value3 = v:Value(Color3.new(0.678431, 0.678431, 0.678431))
		local alwaysFrom = v:Value(Color3.new(1, 1, 1))
		local value5 = v:Value(Color3.new(1, 1, 1))
		local value6 = v:Value(UDim2.fromScale(1.1, 1.1))
		local value7 = v:Value(0.3)
		local v4 = nil

		local function updatePercent()
			local v5 = blocking.Value - (blocking:GetAttribute("D") or 0)

			if v4 ~= nil then
				if v4 < v5 then
					alwaysFrom:Set(color)
				elseif v5 < v4 then
					alwaysFrom:Set(color2)
					value6:Refresh()
				end
			end

			value:Refresh()
			value2:Refresh()
			value3:Refresh()
			value5:Refresh()
			v4 = v5
			value7:Set(1 - v5 / blocking.MaxValue)
		end

		v:Connect(blocking:GetPropertyChangedSignal("Value"), updatePercent)
		v:Connect(blocking:GetAttributeChangedSignal("D"), updatePercent)
		v:Connect(blocking:GetPropertyChangedSignal("MaxValue"), updatePercent)
		updatePercent()
		local blockRegen = blocking:GetAttribute("BlockRegen")
		local addedBlockPoints = blocking:GetAttribute("AddedBlockPoints")
		local v5 = blockRegen and blockRegen > 0
		local v6 = addedBlockPoints and addedBlockPoints > 0
		local v7

		if v5 or v6 then
			v7 = {}

			if v6 then
				table.insert(v7, {
					Value = string.format("%g", addedBlockPoints),
					Prefix = "+",
					Size = 0.6
				})
			end

			if v5 then
				table.insert(v7, {
					Value = string.format("%.2f", 1 + blockRegen),
					Prefix = "x",
					Size = 0.3,
					Transparency = 0.5
				})
			end
		else
			v7 = nil
		end

		local v8 = v:Create("Frame")
		local v9 = {
			Parent = parent,
			v:Create("UIAspectRatioConstraint")({
				AspectRatio = 1.65
			}),
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1
		}
		local v10

		if v7 then
			v10 = v:SpecialThread(function(object2, _)
				task.wait(0.25)
				return object2:Create("Frame")({
					Name = "Added",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(0.5454545454545455, 0.9),
					ZIndex = 9,
					CleanDelay = 0.5,
					BackgroundTransparency = 1,
					object2:Create("Frame")({
						Name = "holder",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = object2:Animation(UDim2.fromScale(1, 1), info5, {
							From = UDim2.fromScale(2, 2)
						}),
						object2:Create("UIListLayout")({
							FillDirection = Enum.FillDirection.Vertical,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(-0.125, 0)
						}),
						BackgroundTransparency = 1,
						object2:Iterate(v7, function(_, data, _, _)
							return object2:Create("TextLabel")({
								Size = UDim2.fromScale(1, data.Size),
								BackgroundTransparency = 1,
								Text = `{data.Prefix}{data.Value}`,
								TextScaled = true,
								TextTransparency = object2:Animation(data.Transparency or 0, info6, {
									From = 1
								}),
								object2:Create("UIStroke")({
									Thickness = object2:Animation(0, info2, {
										From = 2
									}),
									Transparency = object2:Animation(0, info6, {
										From = 1
									})
								}),
								OnClean = function(object3)
									return {
										TextTransparency = object3:Animation(1, info7)
									}
								end,
								TextColor3 = object2:Animation(Color3.new(0, 0, 0), info2, {
									From = Color3.new(1, 1, 1)
								}),
								Font = Enum.Font.SourceSansBold
							})
						end)
					})
				})
			end, {
				Lifetime = 1.25,
				YieldSafe = true
			})
		end

		do local _values = table.pack(v10, v:Create("Frame")({
	Name = "Center",
	Size = UDim2.fromScale(0.6060606060606061, 1),
	Position = UDim2.fromScale(0.5, 1),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundTransparency = 1,
	v:Create("ImageLabel")({
		Name = "Bg",
		ZIndex = -1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = v:Animation(value, info, {
			AlwaysFrom = UDim2.fromScale(1.75, 1.75)
		}),
		ImageTransparency = v:Animation(value2, info2, {
			AlwaysFrom = 0.3
		}),
		ImageColor3 = v:Animation(value3, info2, {
			AlwaysFrom = alwaysFrom
		}),
		Image = "rbxassetid://95215444880583",
		BackgroundTransparency = 1
	}),
	v:Create("ImageLabel")({
		Name = "Img",
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://85221511423087",
		ImageColor3 = v:Animation(value5, info3, {
			AlwaysFrom = alwaysFrom
		}),
		v:Create("UIGradient")({
			Offset = v:Do(function(callback, _, _)
				return Vector2.new(0, callback(value7) - 0.5)
			end),
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.499, 0),
				NumberSequenceKeypoint.new(0.501, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	}),
	v:Create("Frame")({
		Name = "OutlineHolder",
		Size = v:Animation(value6, info4, {
			AlwaysFrom = UDim2.fromScale(1.5, 1.5)
		}),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		v:Create("Frame")({
			Name = "Left",
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			v:Create("ImageLabel")({
				Name = "Img",
				Size = UDim2.fromScale(2, 1),
				ImageColor3 = v:Animation(value5, info3, {
					AlwaysFrom = alwaysFrom
				}),
				BackgroundTransparency = 1,
				Image = "rbxassetid://82904759785021",
				v:Create("UIGradient")({
					Rotation = v:Do(function(callback)
						return (math.clamp(callback(value7) * 360 - 180, 0, 180))
					end),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.499, 0),
						NumberSequenceKeypoint.new(0.501, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			})
		}),
		v:Create("Frame")({
			Name = "Right",
			Size = UDim2.fromScale(0.5, 1),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			v:Create("ImageLabel")({
				Name = "Img",
				Size = UDim2.fromScale(2, 1),
				Position = UDim2.fromScale(-1, 0),
				BackgroundTransparency = 1,
				ImageColor3 = v:Animation(value5, info3, {
					AlwaysFrom = alwaysFrom
				}),
				Image = "rbxassetid://82904759785021",
				v:Create("UIGradient")({
					Rotation = v:Do(function(callback)
						return (math.clamp(callback(value7) * 360, 0, 180))
					end),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.499, 1),
						NumberSequenceKeypoint.new(0.501, 0),
						NumberSequenceKeypoint.new(1, 0)
					})
				})
			})
		})
	})
})); for _k = 1, _values.n do v9[1 + _k] = _values[_k] end end
		v8(v9)
	end

	local function bind(instance)
		if instance == nil or v2 then
			return
		end

		if instance:FindFirstChild("Blocking") then
			onBlocking(instance)
		end

		if object then
			v3 = object:Extend()
			v3:Connect(instance.ChildAdded, function(p2)
				if p2.Name == "Blocking" then
					onBlocking(instance)
				end
			end)
			v3:Connect(instance.ChildRemoved, function(p2)
				if p2.Name == "Blocking" then
					if instance:FindFirstChild("Blocking") then
						onBlocking(instance)
					elseif v then
						v:Destroy()
						v = nil
					end
				end
			end)
		end
	end

	if Players:GetPlayerFromCharacter(character) then
		task.spawn(function()
			bind(Utility.getvaluesfolder(character, true))
		end)
	else
		bind(Utility.getvaluesfolder(character))
	end

	return function()
		v2 = true

		if v then
			v:Destroy()
		end

		if v3 then
			v3:Destroy()

			if object then
				object:Remove(v3)
			end

			v3 = nil
		end
	end
end