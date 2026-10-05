local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local MobileLayout = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MobileLayout)
local SavedLayout = require(script.Parent.SavedLayout)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MobileButtonScale = require(ReplicatedStorage2.CAM.Client.Modules.MobileButtonScale)
local LayoutActions = require(script.Parent.LayoutActions)
local Bounds = require(script.Parent.Bounds)
local EditPlate = require(script.Parent.EditPlate)
local HolderDrag = require(script.Parent.HolderDrag)
local JumpButton = require(script.Parent.JumpButton)
local Run_Handler = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Run_Handler)
local Mounted = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Mounted)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local uDim = UDim2.fromScale(1, 1)
local size = MobileLayout.Toolbar.Size
local info = faye.Info(0.2)
local color = Color3.new()
local color2 = Color3.new()
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.new()
local v = {
	GlowScale = 2.15,
	CircleScale = 0.8
}
local info2 = faye.Info(0.2)
return function(maid, _, p)
	local value = maid:Value(Mounted.Is())
	local character = Players.LocalPlayer.Character

	if character ~= nil then
		maid:Add(Mounted.Watch(character, function(flag: boolean)
			value:Set(flag)
		end))
	end

	local value2 = maid:Value(InputHandler.IsAvailable())
	maid:Add(InputHandler.Available:Connect(function(flag: boolean)
		value2:Set(flag == true)
	end), true)

	local function shown(callback)
		return callback(value2) == true and callback(value) ~= true
	end

	local v2 = 0
	local v3 = 0
	local value3 = maid:Value(Vector2.zero)
	local value4 = maid:Value(UDim2.fromOffset(MobileLayout.Run.X, MobileLayout.Run.Y))
	local size2 = maid:Value(UDim2.fromOffset(size, size))
	local v4 = nil

	local function updatePosition()
		local v5 = MobileButtonScale.Get()
		local v6 = size * v5
		local vector = Vector2.new(v6, v6)
		size2:Set(UDim2.fromOffset(v6, v6))
		local v7 = Vector2.new(MobileLayout.Run.X * v5 + v2, MobileLayout.Run.Y * v5 + v3) + value3:Get()
		local v8 = v4

		if v8 ~= nil and v8.AbsoluteSize.X > 0 then
			local v9 = v7 - Vector2.new(JumpButton.RowShift(v8), 0)
			v7 = Bounds.ClampCornerOffset(v9, vector, v8.AbsoluteSize)
		end

		value4:Set(UDim2.fromOffset(v7.X, v7.Y))
	end

	SavedLayout(maid, "Run", nil, function(p2, p3)
		v2 = p2
		v3 = p3
		updatePosition()
	end)
	maid:Connect(value3.Changed, updatePosition)
	maid:Add(MobileButtonScale.Changed:Connect(updatePosition))
	local value6 = maid:Value(color)
	local value7 = maid:Value(0.8)
	local value8 = maid:Value(color2)
	local value9 = maid:Value(color3)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showRunning()
		local toggled = Run_Handler.Toggled == true
		local v6

		if toggled then
			v6 = color4
		else
			v6 = color
		end

		value6:Set(v6)
		value7:Set(toggled and 0 or 0.8)
		local v8

		if toggled then
			v8 = color5
		else
			v8 = color2
		end

		value8:Set(v8)
		local v10

		if toggled then
			v10 = color6
		else
			v10 = color3
		end

		value9:Set(v10)
	end

	local toggled = Run_Handler.Toggled == true
	local v5

	if toggled then
		v5 = color4
	else
		v5 = color
	end

	value6:Set(v5)
	value7:Set(toggled and 0 or 0.8)
	local v6

	if toggled then
		v6 = color5
	else
		v6 = color2
	end

	value8:Set(v6)
	local v7

	if toggled then
		v7 = color6
	else
		v7 = color3
	end

	value9:Set(v7)
	return maid:Create("Frame")({
		Name = "Run",
		AnchorPoint = Vector2.new(1, 1),
		Size = size2,
		Position = maid:Do(function(callback)
			return uDim + callback(value4)
		end),
		BackgroundTransparency = 1,
		function(p2)
			local parent = p2.Parent
			v4 = parent
			maid:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), updatePosition)
			updatePosition()
		end,
		maid:Create("CanvasGroup")({
			Name = "Fade",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(2.3, 2.3),
			BackgroundTransparency = 1,
			GroupTransparency = maid:Do(function(callback)
				return maid:Animation(callback(value2) == true and callback(value) ~= true and 0 or 1, info2)
			end),
			maid:Create("Frame")({
				Name = "Content",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.4347826086956522, 0.4347826086956522),
				BackgroundTransparency = 1,
				Visible = maid:Do(function(callback)
					return callback(p) ~= true
				end),
				maid:Create("ImageLabel")({
					Name = "Bg",
					ZIndex = -1,
					Image = "http://www.roblox.com/asset/?id=134657809787110",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(2.15, 2.15),
					BackgroundTransparency = 1,
					ImageColor3 = maid:Animation(value8, info),
					ImageTransparency = 0.3
				}),
				maid:Create("ImageLabel")({
					Name = "CircleSelect",
					Size = UDim2.fromScale(0.8, 0.8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=119489413451678",
					ImageTransparency = maid:Animation(value7, info),
					ImageColor3 = maid:Animation(value6, info)
				}),
				maid:Create("ImageLabel")({
					Name = "RunIcon",
					Image = BunchaIcons.RunIcon,
					ImageColor3 = maid:Animation(value9, info),
					Size = UDim2.fromScale(0.46, 0.46),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					ZIndex = 5
				}),
				maid:Create("TextButton")({
					Name = "Press",
					Size = UDim2.fromScale(1, 1),
					Interactable = maid:Do(function(callback)
						return callback(value2) == true and callback(value) ~= true
					end),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 5,
					MouseButton1Click = function()
						Run_Handler.Toggled = not Run_Handler.Toggled
						showRunning() -- equivalent call inferred; original call site unknown
					end
				})
			})
		}),
		EditPlate(maid, p, v),
		HolderDrag(maid, p, value3, {
			Drop = function(point: Vector2)
				v2 += point.X
				v3 += point.Y
				updatePosition()
				LayoutActions.Move("Run", nil, v2, v3)
			end,
			Tap = function()
				v2 = 0
				v3 = 0
				updatePosition()
				LayoutActions.Reset("Run", nil)
			end
		})
	})
end