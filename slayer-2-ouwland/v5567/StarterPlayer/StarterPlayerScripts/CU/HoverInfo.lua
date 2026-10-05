local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local HoverInfo = require(ReplicatedStorage.CAM.Client.Modules.HoverInfo)
local componentsHolder = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ComponentsHolder")
local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
local springInfo = faye.SpringInfo(0.2, 1, 0.5)
local uDim = UDim2.fromOffset(0, -12)
local uDim2 = UDim2.fromOffset(0, 12)

-- equivalent calls inferred from this helper; original call sites unknown
local function flipped(udim: UDim2, udim2: UDim2)
	return udim.Y.Offset - 12 - udim2.Y.Offset < 4
end

local v = faye.new()
local v2 = nil
local text = nil
local v4 = nil
local visible = nil
local v6 = nil
local v7 = nil

local function pointerPosition()
	local mouseLocation = UserInputService:GetMouseLocation()
	return UDim2.fromOffset(mouseLocation.X, mouseLocation.Y - GuiService:GetGuiInset().Y)
end

local function Build(object)
	text = object:Value("")
	v4 = object:Value({})
	visible = object:Value(false)
	v6 = object:Value(UDim2.fromOffset(0, 0))
	v7 = object:Value(UDim2.fromOffset(50, 50))
	local size = object:Value(UDim2.fromOffset(0, 0))
	local size2 = object:Value(UDim2.fromOffset(0, 0))
	object:Create("Frame")({
		Name = "HoverInfo",
		Parent = componentsHolder,
		Position = object:Do(function(callback)
			local v8 = callback(v6)
			local v10

			if flipped(v8, callback(v7)) then
				v10 = uDim2
			else
				v10 = uDim
			end

			return v8 + v10
		end),
		Visible = visible,
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		BackgroundTransparency = 0.35,
		ZIndex = 199,
		AnchorPoint = object:Do(function(callback)
			if flipped(callback(v6), callback(v7)) then
				return (Vector2.new(0.5, 0))
			end

			return (Vector2.new(0.5, 1))
		end),
		Size = object:Animation(v7, springInfo),
		object:Create("ImageLabel")({
			Name = "Pointer",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 22),
			Position = object:Do(function(callback)
				if flipped(callback(v6), callback(v7)) then
					return (UDim2.fromScale(0.5, 0))
				end

				return (UDim2.fromScale(0.5, 1))
			end),
			Rotation = object:Do(function(callback)
				if flipped(callback(v6), callback(v7)) then
					return 180
				end

				return 0
			end),
			AnchorPoint = object:Do(function(callback)
				if flipped(callback(v6), callback(v7)) then
					return (Vector2.new(0.5, 1))
				end

				return (Vector2.new(0.5, 0))
			end),
			Image = "rbxassetid://78357863901704",
			ImageColor3 = Color3.new(0.1, 0.1, 0.1),
			ImageTransparency = 0.35,
			ZIndex = 199
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 5)
		}),
		object:Create("Frame")({
			Name = "ContentHolder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 199,
			object:Create("UIListLayout")({
				AbsoluteContentSizeOnChangedInit = function(_, p)
					v7:Set(UDim2.fromOffset(p.X, p.Y))
				end,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			}),
			object:Create("Frame")({
				Name = "NameHolder",
				Size = size,
				BackgroundTransparency = 1,
				ZIndex = 199,
				object:Create("TextLabel")({
					TextSize = 25,
					Font = Enum.Font.SourceSansSemibold,
					Text = text,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					TextColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					ZIndex = 199,
					TextBoundsOnChangedInit = function(_, p)
						size:Set(UDim2.fromOffset(p.X + 15, 30))
					end
				})
			}),
			object:Create("Frame")({
				Name = "StatsHolder",
				BackgroundTransparency = 1,
				Size = size2,
				ZIndex = 199,
				object:Create("UIListLayout")({
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					AbsoluteContentSizeOnChangedInit = function(_, p)
						size2:Set(UDim2.fromOffset(p.X, p.Y))
					end
				}),
				object:Iterate(v4, function(_, image, object2)
					return object2:Create("ImageLabel")({
						Size = UDim2.fromOffset(35, 35),
						ImageColor3 = Color3.new(1, 1, 1),
						Image = image,
						BackgroundTransparency = 1,
						ZIndex = 199
					})
				end)
			})
		})
	})
end

local function render(p)
	if v2 == nil then
		return
	end

	if p == nil then
		visible:Set(false)
		v4:Set({})
	else
		text:Set(p.Name or "")
		v4:Set(p.Icons or {})
		v6:Set(pointerPosition())
		visible:Set(true)
	end
end

local function update()
	if HUD.Value == true == (v2 ~= nil) then
		return
	end

	if v2 == nil then
		v2 = v:Extend()
		Build(v2)
	else
		HoverInfo.Reset()
		v2:Destroy()
		v2 = nil
		text = nil
		v4 = nil
		visible = nil
		v6 = nil
		v7 = nil
	end
end

update()
v:Connect(HUD.Changed, update)
HoverInfo.Changed:Connect(render)
render(HoverInfo.Current())
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement or (v2 == nil or not visible:Get()) then
		return
	end

	v6:Set(pointerPosition())
end)