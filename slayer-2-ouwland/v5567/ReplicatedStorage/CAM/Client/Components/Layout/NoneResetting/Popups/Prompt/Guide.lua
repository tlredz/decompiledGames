local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Ring = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.CenterBottomContent.ValueHub.Ring)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25)
local info2 = faye.Info(0.25)
local info3 = faye.Info(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local v = {
	Left = Vector2.new(-1, 0),
	Right = Vector2.new(1, 0),
	Top = Vector2.new(0, -1),
	Bottom = Vector2.new(0, 1)
}

local function haloFade(p: number)
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(p * 0.35, 1),
		NumberSequenceKeypoint.new(p, 0),
		NumberSequenceKeypoint.new(1 - p, 0),
		NumberSequenceKeypoint.new(1 - p * 0.35, 1),
		NumberSequenceKeypoint.new(1, 1)
	})
end

return function(maid, instance, data, p: number, flag: boolean?)
	local Y = GuiService:GetGuiInset().Y
	local focus = data.Focus
	local position = maid:Value(UDim2.new())
	local size = maid:Value(UDim2.new())

	local function place(point: Vector2, point2: Vector2)
		local v2 = instance.AbsolutePosition - Vector2.new(0, Y)
		local v3 = point + point2 / 2 - v2
		position:Set(UDim2.fromOffset(v3.X, v3.Y))
		size:Set(UDim2.fromOffset(point2.X + 12, point2.Y + 12))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function follow()
		if focus == nil then
			place(data.FocusPosition or Vector2.zero, data.FocusSize or Vector2.zero)
		else
			place(focus.AbsolutePosition, focus.AbsoluteSize)
		end
	end

	follow() -- equivalent call inferred; original call site unknown
	maid:Connect(instance:GetPropertyChangedSignal("AbsolutePosition"), follow)

	if focus ~= nil then
		maid:Connect(focus:GetPropertyChangedSignal("AbsolutePosition"), follow)
		maid:Connect(focus:GetPropertyChangedSignal("AbsoluteSize"), follow)
		maid:Connect(focus.AncestryChanged, function()
			if not focus:IsDescendantOf(game) then
				PopUpCreator.signal:Fire(p)
			end
		end)
	end

	if data.Timout ~= nil then
		task.delay(data.Timout, function()
			PopUpCreator.signal:Fire(p)
		end)
	end

	local v2 = nil
	local skipDelay = data.SkipDelay or 5
	local v3 = skipDelay <= 0

	if not (v3 or flag) then
		task.delay(skipDelay, function()
			v3 = true
		end)
	end

	if not flag then
		maid:Add(InputHandler.ScreenClicked(function(p2, _, p3)
			if p2 ~= "Down" or not v3 then
				return
			end

			if p3 ~= nil and v2 ~= nil then
				local v4 = Vector2.new(p3.Position.X, p3.Position.Y) - v2.AbsolutePosition

				if v4.X >= 0 and v4.Y >= 0 and v4.X <= v2.AbsoluteSize.X and v4.Y <= v2.AbsoluteSize.Y then
					return
				end
			end

			ScreenEffects.CircleClick()

			if data.OnSkip ~= nil then
				data.OnSkip()
			end

			PopUpCreator.signal:Fire(p)
		end), true)
	end

	local function dimCorner()
		return maid:Create("UICorner")({
			CornerRadius = data.Corner or UDim.new(0, 10)
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dimStroke(thickness: number)
		return maid:Create("UIStroke")({
			Color = Color3.new(),
			Thickness = thickness
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sink(point: Vector2, udim: UDim2, udim2: UDim2)
		return maid:Create("Frame")({
			AnchorPoint = point,
			Position = udim,
			Size = udim2,
			BackgroundTransparency = 1,
			Active = true
		})
	end

	local thickness2 = instance.AbsoluteSize.Y * 0.14

	local function haloShare(callback, p2: string)
		local v5 = callback(size)
		local v6

		if p2 == "X" then
			v6 = v5.X.Offset
		else
			v6 = v5.Y.Offset
		end

		local v7 = v6 + thickness2 * 2
		return haloFade(math.clamp(thickness2 / math.max(v7, 1), 0, 0.5))
	end

	if flag then
		maid:Create("CanvasGroup")({
			Parent = instance,
			Name = "Halo",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = maid:Do(function(callback)
				return callback(position) - UDim2.fromOffset(0, Y)
			end),
			Size = maid:Do(function(callback)
				local v5 = callback(size)
				return UDim2.fromOffset(v5.X.Offset + thickness2 * 2, v5.Y.Offset + thickness2 * 2)
			end),
			BackgroundTransparency = 1,
			GroupTransparency = maid:Animation(data.BackgroundTransparency or 0.45, info, {
				From = 1
			}),
			OnClean = function()
				return {
					GroupTransparency = maid:Animation(1, info2)
				}
			end,
			maid:Create("UIScale")({
				Scale = maid:Animation(1.12, info3, {
					From = 1
				})
			}),
			maid:Create("UIGradient")({
				Transparency = maid:Do(function(p2)
					return haloShare(p2, "X")
				end)
			}),
			maid:Create("CanvasGroup")({
				Name = "FadeMask",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				maid:Create("UIGradient")({
					Rotation = 90,
					Transparency = maid:Do(function(p2)
						return haloShare(p2, "Y")
					end)
				}),
				maid:Create("Frame")({
					Name = "Opening",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -thickness2 * 2, 1, -thickness2 * 2),
					BackgroundTransparency = 1,
					dimCorner(),
					dimStroke(thickness2)
				})
			})
		})
	end

	if not flag then
		local v5 = maid:Create("CanvasGroup")
		local v6 = {
			Parent = instance,
			Name = "Guide",
			Size = UDim2.new(1, 0, 1, Y),
			Position = UDim2.fromOffset(0, -Y),
			BackgroundTransparency = 1,
			GroupTransparency = maid:Animation(data.BackgroundTransparency or 0.2, info, {
				From = 1
			}),
			OnClean = function()
				return {
					GroupTransparency = maid:Animation(1, info2)
				}
			end
		}
		local v7 = maid:Create("Frame")
		local v8 = {
			Name = "Opening",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = size,
			BackgroundTransparency = 1,
			After = function(p2)
				v2 = p2
			end
		}
		local v9 = maid:Create("UIScale")({
			Scale = maid:Animation(1.12, info3, {
				From = 1
			})
		})
		local v10 = dimCorner()
		local v12 = dimStroke(instance.AbsoluteSize.Magnitude + Y) -- equivalent call inferred; original call site unknown
		local v13 = sink(Vector2.new(0.5, 1), UDim2.fromScale(0.5, 0), UDim2.fromOffset(10000, 10000)) -- equivalent call inferred; original call site unknown
		local v14 = sink(Vector2.new(0.5, 0), UDim2.fromScale(0.5, 1), UDim2.fromOffset(10000, 10000)) -- equivalent call inferred; original call site unknown
		local vector3 = Vector2.new(1, 0.5)
		local uDim5 = UDim2.fromScale(0, 0.5)
		local uDim6 = UDim2.new(0, 10000, 1, 0)
		do local _values = table.pack(v9, v10, v12, v13, v14, maid:Create("Frame")({
	AnchorPoint = vector3,
	Position = uDim5,
	Size = uDim6,
	BackgroundTransparency = 1,
	Active = true
}), sink(Vector2.new(0, 0.5), UDim2.fromScale(1, 0.5), UDim2.new(0, 10000, 1, 0))); for _k = 1, _values.n do v8[_k] = _values[_k] end end
		do local _values = table.pack(v7(v8)); for _k = 1, _values.n do v6[_k] = _values[_k] end end
		v5(v6)
	end

	local content = data.Content
	local v5

	if type(content) == "string" then
		v5 = content ~= ""
	else
		v5 = false
	end

	local v6 = v[data.Side or "Bottom"] or v.Bottom
	local anchorPoint = Vector2.new(0.5, 0.5) - v6 / 2
	local v8 = math.clamp(instance.AbsoluteSize.Y * 0.028, 14, 28)
	local v9 = Platform_Handler.Platform.Value == "Mobile"
	local textSize = v8 * (v9 and 2 or 1)
	local count = data.Count

	if v5 and count ~= nil then
		content = `{content}\n<font size="{math.floor(textSize * 0.75)}" color="rgb(110,110,110)">{count.Current} / {count.Goal}</font>`
	end

	local size2 = maid:Value(UDim2.new())

	local function captionAt(callback)
		local v11 = callback(position)
		local v12 = callback(size)
		local v13 = (Vector2.new(v12.X.Offset, v12.Y.Offset) / 2 * 1.12 + Vector2.new(4, 4)) * v6
		return v11 + UDim2.fromOffset(v13.X, v13.Y - Y)
	end

	if not flag then
		local textSize2 = v8 * 0.65 * (v9 and 1.4 or 1)
		local v12 = textSize2 * 0.7
		local v13 = v5 and v6.Y < 0
		local value4 = maid:Value(0)
		local visible = maid:Value(not v3)
		local value6 = maid:Value(360)

		if not v3 then
			local lastTime = os.clock()
			local connection = nil
			connection = maid:Connect(RunService.Heartbeat, function()
				local v14 = 1 - (os.clock() - lastTime) / skipDelay

				if v14 > 0 then
					value6:Set(v14 * 360)
					return
				end

				value6:Set(0)
				visible:Set(false)
				connection:Disconnect()
			end)
		end

		local v14 = maid:Create("Frame")
		local v15 = {
			Parent = instance,
			Name = "GuideSkip",
			AnchorPoint = Vector2.new(0.5, (v13 or not v5) and 1 or 0)
		}
		local position2

		if v5 then
			position2 = maid:Do(function(callback)
				local v17 = captionAt(callback)
				local v18 = callback(size2)
				local v19 = v17.X.Offset - anchorPoint.X * v18.X.Offset
				local v20 = v17.Y.Offset - anchorPoint.Y * v18.Y.Offset
				local v21

				if v13 then
					v21 = v20 + 14 - 10
				else
					v21 = v20 + v18.Y.Offset - 14 + 10
				end

				return UDim2.fromOffset(v19 + v18.X.Offset / 2, v21)
			end)
		else
			position2 = UDim2.fromScale(0.5, 0.97)
		end

		v15.Position = position2
		v15.Size = maid:Do(function(callback)
			local v17 = not callback(visible) and 0 or v12 + 6
			return maid:Animation(UDim2.fromOffset(v17 + callback(value4), v12), info2)
		end)
		v15.BackgroundTransparency = 1
		local v17

		if not v3 then
			v17 = maid:Create("Frame")({
				Name = "Wait",
				Size = UDim2.fromOffset(v12, v12),
				BackgroundTransparency = 1,
				Visible = visible,
				Ring(
					maid,
					value6,
					UDim2.fromScale(0.5, 0.5),
					UDim2.fromScale(1, 1),
					math.max(v12 * 0.2, 3),
					Color3.new(1, 1, 1),
					0
				)
			})
		end

		do local _values = table.pack(v17, maid:Create("TextLabel")({
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.fromScale(1, 0.5),
	Size = UDim2.fromOffset(instance.AbsoluteSize.X, textSize2),
	BackgroundTransparency = 1,
	Text = "Click screen to skip",
	TextSize = textSize2,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.SourceSansSemibold,
	TextTransparency = maid:Animation(0, info, {
		From = 1
	}),
	OnClean = function()
		return {
			TextTransparency = maid:Animation(1, info2)
		}
	end,
	TextBoundsOnChangedInit = function(p2)
		if p2.TextBounds.X <= 0 then
			return
		end

		value4:Set(p2.TextBounds.X)
	end
})); for _k = 1, _values.n do v15[_k] = _values[_k] end end
		v14(v15)
	end

	if not v5 then
		return
	end

	maid:Create("CanvasGroup")({
		Parent = instance,
		Name = "GuideCaption",
		AnchorPoint = anchorPoint,
		Position = maid:Do(captionAt),
		Size = size2,
		BackgroundTransparency = 1,
		GroupTransparency = maid:Animation(0, info, {
			From = 1
		}),
		OnClean = function()
			return {
				GroupTransparency = maid:Animation(1, info2)
			}
		end,
		maid:Create("Frame")({
			Name = "Card",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -28, 1, -28),
			BackgroundColor3 = Color3.new(1, 1, 1),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0, 8)
			}),
			maid:Create("Frame")({
				Name = "Pointer",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(anchorPoint.X, anchorPoint.Y),
				Size = UDim2.fromOffset(14, 14),
				Rotation = 45,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0
			}),
			maid:Create("TextLabel")({
				Name = "Text",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(instance.AbsoluteSize.X * 0.3, textSize * 20),
				BackgroundTransparency = 1,
				Text = content,
				RichText = true,
				TextWrapped = true,
				TextSize = textSize,
				TextColor3 = Color3.new(),
				Font = Enum.Font.SourceSansBold,
				ZIndex = 2,
				TextBoundsOnChangedInit = function(p2)
					local textBounds = p2.TextBounds

					if textBounds.X <= 0 then
						return
					end

					size2:Set(UDim2.fromOffset(
						textBounds.X + textSize * 0.7 * 2 + 28,
						textBounds.Y + textSize * 0.4 * 2 + 28
					))
				end
			})
		})
	})
end