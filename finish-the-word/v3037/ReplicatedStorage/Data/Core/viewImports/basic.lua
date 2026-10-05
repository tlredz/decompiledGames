local romodel = require(game.ReplicatedStorage:WaitForChild("Services"):WaitForChild("Core"):WaitForChild("romodel"))
local clientUtil = require(game.ReplicatedStorage:WaitForChild("Services"):WaitForChild("Utility"):WaitForChild("clientUtil"))
local dictUtil = require(game.ReplicatedStorage:WaitForChild("Services"):WaitForChild("Utility"):WaitForChild("dictUtil"))
local stack = require(game.ReplicatedStorage:WaitForChild("Classes"):WaitForChild("DataTypes"):WaitForChild("stack"))
local iterator = require(game.ReplicatedStorage:WaitForChild("Classes"):WaitForChild("DataTypes"):WaitForChild("iterator"))
local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local model = romodel.model("Frame")

function model:con(p2)
	self.Cons = self.Cons or {}
	table.insert(self.Cons, p2)
end

function model.clean(p, callback)
	for _, v in pairs(p.Cons or {}) do
		callback(v)
	end
end

model.Locations = {
	TopLeft = {
		AnchorPoint = Vector2.new(),
		Position = UDim2.new()
	},
	TopCenter = {
		AnchorPoint = Vector2.new(0.5),
		Position = UDim2.new(0.5)
	},
	TopRight = {
		AnchorPoint = Vector2.new(1),
		Position = UDim2.new(1)
	},
	CenterLeft = {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0)
	},
	Center = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	},
	CenterRight = {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0)
	},
	BottomLeft = {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0)
	},
	BottomCenter = {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0)
	},
	BottomRight = {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0)
	}
}
local localPlayer = game.Players.LocalPlayer
local model2 = romodel.model("Frame")
local flag = false

function model.prespawn(data)
	local hoverSound = data.HoverSound
	local clickSound = data.ClickSound
	return {
		ResetOnSpawn = false,
		MouseEnter = hoverSound and function(state)
			if state.SoundDisabled or state.HoverCd or flag then
				return
			end

			flag = true
			state.HoverCd = true
			task.delay(0.08, function()
				state.HoverCd = false
				flag = false
			end)
			clientUtil.sound(hoverSound)
		end,
		MouseButton1Down = data.Instance:IsA("GuiButton") and clickSound and function(object)
			if object.ClickSoundCondition and not object:ClickSoundCondition() or object.SoundDisabled or object.ClickCd then
				return
			end

			object.ClickCd = true
			clientUtil.sound(clickSound)
			task.delay(0.08, function()
				object.ClickCd = false
			end)
		end or nil
	}
end

function model.tween(p, p2, p3)
	TweenService:Create(p.Instance, p2, p3):Play()
end

function model:guiChildren()
	local count = 0

	for _, guiObject in pairs(self._Children) do
		if guiObject:IsA("GuiObject") then
			count += 1
		end
	end

	return count
end

function model.spawn(instance)
	local location = model.Locations[instance.Location]
	local parent = instance.Parent

	if type(parent) == "table" then
		local ui = parent.Ui

		if ui and parent.Instance:IsA("GuiObject") then
			model2._levelChildren(ui, instance, instance.Parent.ZIndex)
		end
	end

	return {
		AnchorPoint = location and location.AnchorPoint or instance.AnchorPoint or Vector2.new(),
		Position = location and location.Position or instance.Position or UDim2.new()
	}
end

local model3 = romodel.model(model)

function model3.init(_)
	return {
		BackgroundTransparency = 1
	}
end

local model4 = romodel.model(model)

function model4.init()
	return {
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0
	}
end

local model5 = romodel.model(model3)

function model5.init()
	return nil, {
		Folder = romodel.make("Folder", nil, {
			BorderTop = romodel.make(model4, {
				Location = "TopCenter",
				Size = UDim2.new(1, 0, 0, 2)
			}),
			BorderRight = romodel.make(model4, {
				Location = "CenterRight",
				Size = UDim2.new(0, 2, 1, 0)
			}),
			BorderLeft = romodel.make(model4, {
				Location = "CenterLeft",
				Size = UDim2.new(0, 2, 1, 0)
			}),
			BorderBottom = romodel.make(model4, {
				Location = "BottomCenter",
				Size = UDim2.new(1, 0, 0, 2)
			})
		})
	}
end

local model6 = romodel.model(model)

function model6.prespawn(data)
	local v = {
		Size = data.Scale and UDim2.new(data.Scale, 0, 1, 0) or data.Size
	}
	local aspectRatioConstraint

	if not data.NoAspectRatio then
		aspectRatioConstraint = romodel.make("UIAspectRatioConstraint", {
			AspectRatio = data.AspectRatio or 1
		}) or nil
	end

	return v, {
		AspectRatioConstraint = aspectRatioConstraint
	}
end

local model7 = romodel.model(model)

function model7.init()
	return nil, {
		UIScale = romodel.make(romodel.wrap("UIScale", model))
	}
end

local model8 = romodel.model(model3)

function model8.init(_)
	return {
		MouseButton1Down = function(p)
			if p.ClickDisabled then
				return
			end

			local instance = p.Instance
			TweenService:Create(instance, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.8, 0, 0.8, 0)
			}):Play()
			task.delay(0.075, function()
				TweenService:Create(instance, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Size = UDim2.new(1.09, 0, 1.09, 0)
				}):Play()
			end)
		end
	}
end

local model9 = romodel.model(model3)

function model9.init(data)
	return {
		_scaleUp = data.ScaleUp or 0.3,
		_scaleDn = data.ScaleDn or 0.2,
		_delta = data.Delta or 0.03
	}
end

function model9:_shrink()
	local cachedSize = self.CachedSize
	TweenService:Create(self.Instance, TweenInfo.new(self._scaleDn, Enum.EasingStyle.Back), {
		Size = cachedSize
	}):Play()
end

function model9:_grow()
	local uDim = UDim2.new(self.CachedSize.X.Scale + self._delta, 0, self.CachedSize.Y.Scale + self._delta, 0)
	TweenService:Create(self.Instance, TweenInfo.new(self._scaleUp, Enum.EasingStyle.Back), {
		Size = uDim
	}):Play()
end

function model9:prespawn()
	local _ = self.Instance
	return {
		_Events = {
			MouseEnter = function(object2)
				if object2.HoverDisabled then
					return
				end

				object2:_grow()
			end,
			MouseLeave = function(_)
				if self.HoverDisabled then
					return
				end

				self:_shrink()
			end
		}
	}
end

function model9:spawn()
	local _ = self.Instance
	self.CachedSize = self.Size
end

local model10 = romodel.model(model)

function model10.init(p)
	return nil, {
		UICorner = romodel.make("UICorner", {
			CornerRadius = p.CornerRadius
		})
	}
end

local model11 = romodel.model(model)

function model11.init(p)
	local defaults = {}

	for k, v2 in pairs(p) do
		if k ~= "_Events" then
			defaults[k] = v2
		end
	end

	return nil, {
		UIStroke = romodel.make("UIStroke", romodel.merge(defaults, {
			Thickness = p.StrokeWidth,
			Transparency = p.StrokeTransparency,
			LineJoinMode = p.StrokeLineJoinMode,
			Color = p.StrokeColor,
			BorderStrokePosition = p.StrokePosition
		}))
	}
end

local model12 = romodel.model(model)

function model12.init(items)
	local v = {}

	for k, item in pairs(items) do
		if k ~= "_Events" then
			v[k] = item
		end
	end

	return nil, {
		UIPadding = romodel.make("UIPadding", v)
	}
end

local model13 = romodel.model(model)

function model13.init(data)
	return nil, {
		UIGradient = romodel.make("UIGradient", {
			Rotation = data.GradientRotation or 0,
			Color = data.GradientColor,
			Transparency = data.GradientTransparency,
			Offset = data.GradientOffset or Vector2.new(0, 0)
		})
	}
end

local RunService2 = game:GetService("RunService")
local v = {}

function model13:spawn()
	local offsetSpeed = self.OffsetSpeed
	local rotSpeed = self.RotSpeed
	local instance = self.UIGradient.Instance

	if RunService2:IsServer() then
		return
	end

	if offsetSpeed then
		if self.OffsetCon then
			return
		end

		local clone = instance:Clone()
		clone.Parent = self.Parent.Instance
		self.OffsetCon = RunService2.RenderStepped:Connect(function(dt)
			instance.Offset += offsetSpeed * dt

			if instance.Offset.X > 0.5 then
				instance.Offset -= Vector2.new(0.5, 0)
			end
		end)
	end

	if rotSpeed then
		if self.OffsetCon then
			return
		end

		v[self] = true
		self.RotCon = RunService2.RenderStepped:Connect(function(dt)
			instance.Rotation += rotSpeed * dt

			if instance.Rotation > 360 then
				instance.Rotation -= 360
			end
		end)
	end
end

function model13.despawn(p)
	if p.OffsetCon then
		p.OffsetCon:Disconnect()
	end

	if p.RotCon then
		p.RotCon:Disconnect()
	end
end

local model14 = romodel.model("Frame")
local v2 = {
	DPadRight = function(p, _, p2, p3)
		return p2 % p > 0 and p2 == p3 - 1
	end,
	DPadLeft = function(p, _, p2, p3)
		return p > 1 and p2 % p ~= 1 and p2 == p3 + 1
	end,
	DPadUp = function(p, _, p2, p3)
		return math.ceil(p2 / p) ~= 1 and p2 == p3 + p
	end,
	DPadDown = function(p, p2, p3, p4)
		return math.ceil(p3 / p) <= p2 and p3 == p4 - p
	end
}

function model14:next(p, callback, p2)
	local v3 = v2[p2]
	local v4 = iterator.values(self._Children):find(function(guiObject)
		return guiObject:IsA("GuiObject")
	end)
	local absoluteSize = self.AbsoluteSize
	local listLayout = self:FindFirstChild("ListLayout")
	local uDim = listLayout and UDim2.new(
		listLayout.Padding.Scale,
		listLayout.Padding.Offset,
		listLayout.Padding.Scale,
		listLayout.Padding.Offset
	) or self.GridLayout.CellPadding

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getSize(p3, p4, p5)
		return p3[p5] * p4[p5].Scale + p4[p5].Offset
	end

	local vector = Vector2.new(getSize(absoluteSize, uDim, "X"), getSize(absoluteSize, uDim, "Y"))
	local v5 = v4.Instance.AbsoluteSize + vector
	local v6 = iterator.values(self:GetChildren()):filter(function(guiObject)
		return guiObject:IsA("GuiObject")
	end):len()
	local x = math.floor(((absoluteSize + vector) / v5).x)
	local v7 = math.ceil(v6 / x)

	for _, guiObject in pairs(self._Children) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v8 = callback(p)
		local v9 = callback(guiObject)

		if v3(x, v7, v8, v9) then
			return guiObject, Vector2.new(v9 % x - 1, math.ceil(v9 / x) - 1) * v5
		end
	end
end

local model15 = romodel.model(model, model14)

function model15.init(p)
	local defaults = {}

	for k, v4 in pairs(p) do
		if k ~= "_Events" then
			defaults[k] = v4
		end
	end

	return {}, {
		ListLayout = romodel.make("UIListLayout", romodel.merge(defaults, {
			FillDirection = p.FillDirection or Enum.FillDirection.Horizontal,
			HorizontalAlignment = p.HorizontalAlignment,
			ItemLineAlignment = p.ItemLineAlignment,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Wraps = p.Wraps or false
		}))
	}
end

local model16 = romodel.model("ImageLabel")

function model16.prespawn(_) end

local model17 = romodel.model("ImageButton")

function model17.prespawn(_) end

local model18 = romodel.model("ImageLabel", model3, model6)
local wrapped = romodel.wrap("ImageButton", model3, model6)
local wrapped2 = romodel.wrap("ImageButton", model3, model6)
local model19 = romodel.model("TextLabel", model3)
local model20 = romodel.model(model, model14)

function model20.init(p)
	return {}, {
		GridLayout = romodel.make("UIGridLayout", romodel.merge(p, {
			SortOrder = Enum.SortOrder.LayoutOrder
		}))
	}
end

local wrapped3 = romodel.wrap(model3, model15)
local wrapped4 = romodel.wrap(model3, model20)
local model21 = romodel.model("ScrollingFrame", model)

function model21:resize(p)
	local gridLayout = self.GridLayout
	local padding = self.Padding
	local aspectRatio = self.AspectRatio
	local v3 = not (aspectRatio < 1) and 60 or 60 / aspectRatio or 60
	local v4 = v3 + padding
	local v5 = math.floor(p / v4)
	local v6 = v3 + (p - v5 * v4) / v5 / aspectRatio
	gridLayout.CellPadding = UDim2.new(0, padding, 0, padding)
	gridLayout.CellSize = UDim2.new(0, v6 * aspectRatio, 0, v6)
end

function model21.init(data)
	return nil, {
		GridLayout = romodel.make("UIGridLayout", {
			CellPadding = data.CellPadding,
			CellSize = data.CellSize,
			SortOrder = data.SortOrder,
			HorizontalAlignment = data.HorizontalAlignment
		})
	}
end

function model21.prespawn(instance)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() end)
end

local model22 = romodel.model("ScrollingFrame", model15)

function model22.init(data)
	return {
		FillDirection = data.FillDirection,
		ItemLineAlignment = data.ItemLineAlignment,
		VerticalAlignment = data.VerticalAlignment,
		HorizontalAlignment = data.HorizontalAlignment,
		HorizontalFlex = data.HorizontalFlex,
		Padding = data.Padding,
		Wraps = data.Wraps
	}
end

function model22:resize(_)
	local _ = self.AspectRatio

	for _, _ in pairs(self._Children) do

	end
end

function model22:prespawn()
	self:resize(self.AbsoluteSize.X)
	self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:resize(self.AbsoluteSize.X)
	end)
end

local model23 = romodel.model(model3)

function model23:reposition()
	local xOffset = self.XOffset or 0
	local yOffset = self.YOffset or 0
	local xIncrement = self.XIncrement or 1
	local slope = self.Slope or 1
	local scrollOffset = self.ScrollOffset

	if tonumber(scrollOffset) then
		xOffset -= (scrollOffset - yOffset) / slope * self.Parent.CanvasSize.Y.Scale
	end

	local v3 = {}

	for _, v4 in pairs(self._Children) do
		v3[#v3 + 1] = v4
	end

	table.sort(v3, function(a, b)
		return a.LayoutOrder and b.LayoutOrder and a.LayoutOrder < b.LayoutOrder and true or false
	end)

	for k, guiObject in pairs(v3) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v4 = k - 1
		guiObject.Position = UDim2.new(xOffset + v4 * xIncrement, 0, yOffset + v4 * xIncrement * slope, 0)
	end
end

model23.prespawn = model23.reposition

function model23:spawn()
	self.ChildAdded:Connect(function(_)
		self:reposition()
	end)
	self.ChildRemoved:Connect(function()
		self:reposition()
	end)
end

local model24 = romodel.model("ScrollingFrame", model)

function model24.prespawn(data)
	local scale = data.CanvasSize.Y.Scale
	local v3 = scale >= 1 and 1 / scale or 1
	return {
		ScrollBarThickness = 0
	}, {
		Container = romodel.make(model23, {
			Size = UDim2.new(1, 0, v3, 0),
			XOffset = data.XOffset,
			YOffset = data.YOffset,
			XIncrement = data.XIncrement,
			Slope = data.Slope
		}, data.Elements),
		ScrollBar = romodel.make(wrapped, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			AspectRatio = 0.195238095,
			Image = "rbxgameasset://Images/ScrollbarOverlay",
			MouseButton1Down = function(p)
				local instance = data.Instance
				local _Properties = p._Properties
				local mouse = localPlayer:GetMouse()
				local inputEndedConnection = nil
				inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					_Properties.Down = nil
					inputEndedConnection:Disconnect()
				end)
				_Properties.Down = Vector2.new(mouse.Y, instance.CanvasPosition.Y)

				while _Properties.Down do
					local down = _Properties.Down
					local v4 = mouse.Y - down.X
					instance.CanvasPosition = Vector2.new(0, v4 + down.Y)
					heartbeat:Wait()
				end
			end
		}, {
			ScrollIcon = romodel.make(model18, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.385, 0, 0, 0),
				Scale = 0.6,
				AspectRatio = 0.207386364,
				Image = "rbxgameasset://Images/Scrollbar"
			})
		})
	}
end

function model24:spawn()
	local v3 = self.Size.Y.Scale / self.CanvasSize.Y.Scale
	local v4 = nil
	self:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local Y = self.CanvasSize.Y
		local scrollOffset = self.CanvasPosition.Y / (Y.Scale * self.Parent.AbsoluteSize.Y)
		local v6 = self.CanvasPosition.Y / (self.Parent.AbsoluteSize.Y * Y.Scale - self.AbsoluteSize.Y)
		self.Container.ScrollOffset = scrollOffset
		self.ScrollBar.Position = UDim2.new(1, 0, scrollOffset, 0)
		self.ScrollBar.ScrollIcon.Position = UDim2.new(0.385 + v6 * 0.6 * v4, 0, v6 * v4, 0)
		self.Container:reposition()
	end)
	local scale, count

	if self.Elements then
		scale = 0

		for _, element in pairs(self.Elements) do
			scale = element.Size.Y.Scale
		end

		count = dictUtil.count(self.Elements)
	else
		scale = self.ElementSize
		count = self.ElementNumber
	end

	local v5 = self.XIncrement * self.Slope
	local _ = v5 - scale
	self.CanvasSize = UDim2.new(0, 0, v5 * count + self.YOffset)
	local scale2 = self.CanvasSize.Y.Scale
	local v6 = scale2 >= 1 and 1 / scale2 or 1
	local v7 = v6 * 0.195238095
	v4 = v3 - v7
	self.ScrollBar.Size = UDim2.new(v7, 0, v6, 0)
	self.Container.Size = UDim2.new(1, 0, v6, 0)
end

local function stripColorTags(p)
	return tostring(p):gsub("<font.->", ""):gsub("</font>", "")
end

function model19.init(data)
	local _ = data.Scale or 1
	local font = data.Font or Enum.Font.FredokaOne
	local v3 = {
		TextScaled = data.TextScaled or true,
		BackgroundTransparency = 1,
		Font = 0,
		FontFace = 0,
		TextColor3 = 0
	}
	local font2

	if not (data.FontFace or not font) then
		font2 = font
	end

	v3.Font = font2
	v3.FontFace = data.FontFace
	v3.TextColor3 = Color3.fromRGB(255, 255, 255)
	local v5 = {
		UIStroke = data.StrokeWidth and romodel.make("UIStroke", {
			StrokeSizingMode = data.StrokeSizingMode,
			Thickness = data.StrokeWidth,
			LineJoinMode = data.StrokeLineJoinMode,
			Transparency = data.StrokeTransparency,
			Color = data.StrokeColor
		}),
		ShadowText = 0
	}
	local shadow = data.Shadow

	if shadow then
		local make = romodel.make
		local v7 = {
			TextXAlignment = data.TextXAlignment,
			Text = tostring(data.Text):gsub("<font.->", ""):gsub("</font>", ""),
			TextColor3 = Color3.fromRGB(),
			RichText = data.RichText,
			Font = 0,
			FontFace = 0,
			AnchorPoint = 0,
			Size = 0,
			Position = 0,
			ZIndex = -1
		}

		if data.FontFace or not font then
			font = nil
		end

		v7.Font = font
		local fontFace

		if not data.Font then
			fontFace = data.FontFace or nil
		end

		v7.FontFace = fontFace
		v7.AnchorPoint = Vector2.new(0.5, 1)
		v7.Size = UDim2.new(1, 0, 1, 0)
		v7.Position = data.ShadowOffset or UDim2.new(0.5, 0, 1.1, 0)
		shadow = make(model19, v7, {
			UIStroke = data.StrokeWidth and romodel.make("UIStroke", {
				Thickness = data.ShadowStrokeWidth or data.StrokeWidth,
				LineJoinMode = data.StrokeLineJoinMode
			})
		})
	end

	v5.ShadowText = shadow
	return v3, v5
end

function model19:setTransparency(p2)
	self.TextTransparency = p2

	if self.UIStroke then
		self.UIStroke.Transparency = p2
	end
end

function model19:setText(text)
	self.Text = text

	if self.ShadowText then
		self.ShadowText.Text = tostring(text):gsub("<font.->", ""):gsub("</font>", "")
	end
end

function model2:prespawn()
	self.Content = self.Container.Content
end

function model2.init(data)
	local maxSize = data.MaxSize or 1e999
	return {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		Background = romodel.make(model3, romodel.merge({
			Size = UDim2.new(1, 0, 1, 40),
			ZIndex = 0
		}, data.Background or {}), data.Background2),
		Container = not data.NoContainer and romodel.make(romodel.wrap(model3, model6), {
			Location = data.Location,
			AnchorPoint = data.ContainerAnchorPoint,
			Position = data.ContainerPosition,
			Size = data.ContainerSize,
			AspectRatio = data.AspectRatio or 1.777,
			Scale = data.Scale,
			NoAspectRatio = data.NoAspectRatio,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		}, {
			SizeConstraint = romodel.make("UISizeConstraint", {
				MaxSize = Vector2.new(maxSize, maxSize),
				MinSize = Vector2.new(data.MinSize, data.MinSize)
			}),
			Content = romodel.make(model3, {
				Size = UDim2.new(1, 0, 1, 0)
			}, data.Content)
		})
	}
end

function model2._levelChildren(ui, data, p, p2)
	local instance = data.Instance
	local isA = instance:IsA("GuiObject")
	local _Properties = data._Properties
	_Properties.Ui = ui

	if isA then
		local originalZIndex = _Properties.OriginalZIndex or instance.ZIndex
		_Properties.OriginalZIndex = originalZIndex
		local zIndex = originalZIndex + p
		instance.ZIndex = zIndex

		for _, v4 in pairs(data._Children) do
			model2._levelChildren(ui, v4, zIndex, p2)
		end
	else
		for _, v3 in pairs(data._Children) do
			model2._levelChildren(ui, v3, p, p2)
		end
	end
end

function model2.spawn(p)
	model2._levelChildren(p, p, 0)
end

local model25 = romodel.model("Frame")

function model25.spawn(p)
	p.Ui[p.Name] = p
end

local model26 = romodel.model("Frame")

function model26.spawn(object)
	if not object.resize then
		return
	end

	romodel.apply(object, object:resize())
	return {
		Con = (pcall(function()
			return object.Instance.AbsoluteSize
		end) and object or object.Parent):GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			romodel.apply(object, object:resize())
		end)
	}
end

function model26.despawn(p)
	if not (p.resize and p.Con) then
		return
	end

	p.Con:Disconnect()
end

local wrapped5 = romodel.wrap(model19, model13)
local model27 = romodel.model(wrapped5)

function model27.init(p)
	return p, {
		Shadow = romodel.make(wrapped5, romodel.merge(p, {
			Position = UDim2.new(0, 0, 0.25, 0),
			Size = UDim2.new(1, 0, 1, 0),
			GradientTransparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(0.65, 0.85),
				NumberSequenceKeypoint.new(0.95, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}))
	}
end

local model28 = romodel.model("ViewportFrame")

function model28.init(_)
	return {
		BackgroundTransparency = 1
	}
end

local model29 = romodel.model("Folder")
local v3 = {
	DPadRight = true,
	DPadLeft = true,
	DPadUp = true,
	DPadDown = true
}

function model29.init(_)
	return {
		Contexts = stack()
	}
end

function model29:startController()
	if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
		return
	end

	for _, v4 in pairs({ self.DefaultContext(self) }) do
		self:push(v4)
	end

	self.Contexts:peek().OnMove(self, self.Current)
end

function model29:spawn()
	local function onBegan(input, _, p)
		if not self.Contexts:peek() then
			return
		end

		local keyCode = input.KeyCode
		local v4 = nil
		local inputEndedConnection = nil
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input2)
			if input2.KeyCode ~= keyCode then
				return
			end

			inputEndedConnection:Disconnect()
			v4 = true
		end)
		local v5 = 0.15

		while true do
			local current = self.Current
			local v6 = self.Contexts:peek()
			local controller = v6.Controller
			local name = keyCode.Name
			local v7 = nil
			local v8 = v3[name]

			if v6 then
				if v8 then
					v7 = v6.ListHandle:next(self.Current, v6.Order, name)
				end

				if v6.OnMove then
					v6.OnMove(self, v7, current, name)
				end
			end

			local v9 = controller[input.KeyCode]

			if v9 then
				v9(self, v7, current)
			end

			task.wait(v5)

			if p or v4 or not (UserInputService:IsKeyDown(keyCode) or UserInputService:IsGamepadButtonDown(
				Enum.UserInputType.Gamepad1,
				keyCode
			)) then
				break
			else
				v5 = 0.075
			end
		end
	end

	self.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		onBegan(input, gameProcessed)
	end)
end

function model29:select(current)
	self.Current = current
end

function model29:mouseLeave(object)
	object:Fire("MouseLeave")
end

function model29:mouseEnter(object2, p)
	if p then
		self:mouseLeave(p)
	end

	object2:Fire("MouseEnter")
end

function model29:runContext(_)
	local _ = self.Current
	local v4 = self.Contexts:peek()

	if not v4 then
		return
	end

	local current = self.Current
	v4.ListHandle = v4.List(self)
	self.Current = v4.Current(v4.ListHandle)
	v4.OnMove(self, self.Current, current)
	return v4
end

function model29:push(p, p2)
	self.Contexts:push(p)
	self:runContext(p2)
end

function model29:pop()
	self.Contexts:pop()
	return self:runContext()
end

function model29:swapContext(p)
	self.Contexts:pop()
	self:push(p)
end

function model29.getList(p)
	return p.Contexts:peek().ListHandle
end

function model29.despawn(p)
	p.InputBegan:Disconnect()
end

return {
	Controller = model29,
	Element = model,
	EmptyElement = model3,
	ConstrainedElement = model6,
	ImageLabel = model18,
	ImageButton = wrapped,
	ImageButton2 = wrapped2,
	TextLabel = model19,
	Corner = model10,
	Padding = model12,
	Gradient = model13,
	Stroke = model11,
	Ui = model2,
	List = model15,
	EmptyList = wrapped3,
	DiagnolList = model23,
	Grid = model20,
	EmptyGrid = wrapped4,
	WireFrame = model5,
	WireList = romodel.wrap(model5, model15),
	ScrollingList = model22,
	ScrollingGrid = model21,
	DiagnolScroll = model24,
	HoverScale = model9,
	ClickScale = model8,
	Global = model25,
	Resizable = model26,
	GlowingShadow = model27,
	Viewport = model28,
	Sound = romodel.wrap(model17, model16),
	HoverSound = model16,
	ClickSound = model17,
	Scale = model7
}