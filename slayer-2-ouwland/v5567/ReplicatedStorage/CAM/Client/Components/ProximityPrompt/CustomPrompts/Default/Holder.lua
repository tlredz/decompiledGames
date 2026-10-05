local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Config = require(script.Parent.Parent.Config)
local HoldPress = require(script.Parent.Parent.HoldPress)
return function(object, p, p2, object2, image: string?)
	local value = object:Value(1)
	local value2 = object:Value(0.5)
	local value3 = object:Value(Config.Holder.Positions.p1)
	local value4 = object:Value(0)
	local value5 = object:Value(0.25)
	local textStrokeTransparency = object:Value(0.85)
	local value7 = object:Value(0.25)
	local value8 = object:Value(Color3.new(0, 0, 0))
	local value9 = object:Value(1)
	local color = object:Value(Color3.new(1, 1, 1))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function upd()
		local v = typeof(p.Text:Get()) == "table" and 2 or 1

		if not value:Compare(v) then
			value:Set(v)
		end
	end

	upd() -- equivalent call inferred; original call site unknown
	local v = nil

	local function updState()
		local v2 = p.State:Get()
		local v3 = object2:Get()

		if v3 >= 2 then
			v2 = v3 + 1
		end

		if v2 ~= v then
			v = v2
			local v4 = false

			if v2 == 2 then
				value2:Set(0.15)
				value9:Set(0.65)
				value3:Set(Config.Holder.Positions.p2)
			elseif v2 >= 3 then
				v4 = true
				color:Set(Config.TriggeredColor)
				textStrokeTransparency:Set(1)
				value7:Set(1)

				if v2 == 3 then
					value8:Set(Config.TriggeredColor)
				end

				value9:Reset()
				value2:Set(1)
				value3:Set(Config.Holder.Positions.p3)
				value4:Set(1)
				value5:Set(1)
			else
				value9:Reset()
				value2:Reset()
				value3:Reset()
			end

			if not v4 then
				value8:Reset()
				value4:Reset()
				value5:Reset()
				textStrokeTransparency:Reset()
				value7:Reset()
				color:Reset()
			end
		end
	end

	updState()
	object2.Changed:Connect(updState)
	p.State.Changed:Connect(updState)
	p.Text.Changed:Connect(upd)
	local value11 = object:Value()
	local value12 = object:Value()
	local v2 = 0

	local function GetScaled()
		local v3 = math.random(1, 999)
		v2 = v3
		task.wait()

		if not (object.IsActive and v2 == v3) then
			return
		end

		local v4 = nil
		local v5 = nil
		local value13 = value11.Value
		local value14 = value12.Value

		if value13 then
			local instance = value13.Instance
			local X = instance.Parent.Parent.AbsoluteSize.X

			if X > 0 and instance.TextBounds.X > 0 then
				v4 = instance.TextBounds.X / X
			end
		end

		if not value14 then
			return (math.max(v4 or 0, v5 or 0))
		end

		local instance = value14.Instance
		local X = instance.Parent.Parent.AbsoluteSize.X

		if X > 0 and instance.TextBounds.X > 0 then
			v5 = instance.TextBounds.X / X
		end

		return (math.max(v4 or 0, v5 or 0))
	end

	return object:Create("Frame")({
		Name = "ZContentHolder",
		Size = UDim2.fromScale(1, 0.75),
		BackgroundTransparency = 1,
		Instance.new("UIAspectRatioConstraint"),
		object:Create("Frame")({
			Name = "Holder",
			Size = object:Animation(UDim2.fromScale(1, 1), Config.InTween, {
				From = UDim2.fromScale(0.8, 0.8)
			}),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = object:Animation(value3, Config.TransitionInfoSmooth),
			object:Create("Frame")({
				Name = "Bg",
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				BackgroundColor3 = object:Animation(value8, Config.TransitionInfo),
				BackgroundTransparency = object:Animation(value7, Config.TransitionInfoLong, {
					From = 1
				}),
				object:Create("TextButton")({
					BackgroundTransparency = 1,
					Name = "DetectBox",
					Size = UDim2.fromScale(1, 1),
					InputBegan = HoldPress(object, p2)
				}),
				object:Create("UIStroke")({
					Thickness = 1,
					Color = color,
					Transparency = object:Animation(value2, Config.TransitionInfo, {
						From = 1
					}),
					BorderOffset = UDim.new(0, -4),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					})
				}),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0.45)
					}),
					Rotation = 0
				}),
				object:Create("Frame")({
					Size = UDim2.new(1, -10, 1, -10),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = object:Animation(value9, Config.TransitionInfo, {
						From = 1
					}),
					object:Create("UICorner")({
						CornerRadius = UDim.new(1)
					}),
					object:Create("UIGradient")({
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					})
				})
			}),
			object:Create("Frame")({
				Name = "Actual",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.new(0.35, 0),
				BackgroundTransparency = 1,
				object:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 5),
					AbsoluteContentSizeOnChangedInit = function(p4)
						local X = p4.AbsoluteContentSize.X
						p4.Parent.Parent.Bg.Size = UDim2.fromScale(
							X / p4.Parent.Parent.AbsoluteSize.X + p4.Parent.Position.X.Scale * 2,
							1.3
						)
					end
				}),
				function()
					if image == nil then
						return
					else
						return object:Create("ImageLabel")({
							Size = UDim2.fromScale(0.75, 0.75),
							Instance.new("UIAspectRatioConstraint"),
							BackgroundTransparency = 1,
							Image = image,
							ImageTransparency = object:Animation(value4, Config.TransitionInfo, {
								From = 1
							})
						})
					end
				end,
				object:Create("Frame")({
					Name = "TextHolder",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					object:Create("TextLabel")({
						Size = object:Do(function(callback, _, p4)
							if callback(value) == 2 then
								return UDim2.fromScale(250, 0.65)
							end

							p4.Position = UDim2.fromScale(0, 0.15)
							return UDim2.fromScale(250, 0.7)
						end),
						TextStrokeTransparency = textStrokeTransparency,
						BackgroundTransparency = 1,
						TextScaled = true,
						TextColor3 = Color3.new(1, 1, 1),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTransparency = object:Animation(value4, Config.TransitionInfo, {
							From = 1
						}),
						Text = object:Do(function(callback)
							local v3 = callback(p.Text)

							if typeof(v3) == "table" then
								return v3.Primary
							end

							return p.Text
						end),
						object:SetTo(value11),
						Font = Enum.Font.SourceSansSemibold,
						TextBoundsOnChangedInit = function(p4)
							local scaled = GetScaled()

							if scaled == nil or scaled <= 0 then
								return
							end

							p4.Parent.Size = UDim2.fromScale(scaled, p4.Parent.Size.Y.Scale)
						end
					}),
					object:State(function(callback)
						if callback(value) == 2 then
							return object:Create("TextLabel")({
								Name = "SecondaryText",
								AnchorPoint = Vector2.new(0, 1),
								TextColor3 = Color3.new(1, 1, 1),
								Position = UDim2.fromScale(0, 1),
								Size = UDim2.fromScale(250, 0.5),
								BackgroundTransparency = 1,
								TextTransparency = object:Animation(value5, Config.TransitionInfo, {
									From = 1
								}),
								TextScaled = true,
								object:SetTo(value12),
								TextStrokeTransparency = textStrokeTransparency,
								TextXAlignment = Enum.TextXAlignment.Left,
								Text = object:Do(function(callback2)
									return callback2(p.Text).Secondary
								end),
								Font = Enum.Font.SourceSansSemibold,
								TextBoundsOnChangedInit = function(p4)
									local scaled = GetScaled()

									if scaled == nil or scaled <= 0 then
										return
									end

									p4.Parent.Size = UDim2.fromScale(scaled, p4.Parent.Size.Y.Scale)
								end
							})
						end

						return nil
					end)
				})
			})
		})
	})
end