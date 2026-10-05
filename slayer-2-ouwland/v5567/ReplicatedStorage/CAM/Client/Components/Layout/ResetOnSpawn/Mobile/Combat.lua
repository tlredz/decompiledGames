local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
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
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Mounted = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Mounted)
local CombatAvailable = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.CombatAvailable)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Skills_Provider = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
local curPower = ReplicatedStorage.CAM.Client.Controllers.Skills_Provider:WaitForChild("CurPower")
local info = faye.Info(0.12)
local uDim = UDim2.fromScale(1, 1)
local size = MobileLayout.Toolbar.Size
local color = Color3.new()
local color2 = Color3.new()
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(0.5, 0.5, 0.5)
local color6 = Color3.new()
return function(maid, _, p)
	local value = maid:Value("")

	local function refreshMode()
		if CombatAvailable.Is() and not Mounted.Is() then
			value:Set("Combat")
		elseif Character_info_provider.Get_equipped_tool(Players.LocalPlayer) == nil then
			value:Set("")
		else
			value:Set("Tool")
		end
	end

	refreshMode()
	maid:Connect(curPower.Changed, refreshMode)
	maid:Add(Skills_Provider.Keys_Changed:Connect(refreshMode), true)
	local value2 = maid:Value(Mounted.Is())
	local character = Players.LocalPlayer.Character

	if character ~= nil then
		maid:Add(Mounted.Watch(character, function(flag: boolean)
			value2:Set(flag)
			refreshMode()
		end))
	end

	local function shown(callback)
		local v = callback(value)

		if v == "Combat" then
			return callback(value2) ~= true
		end

		return v == "Tool"
	end

	local v = 0
	local v2 = 0
	local value3 = maid:Value(Vector2.zero)
	local value4 = maid:Value(UDim2.fromOffset(MobileLayout.Combat.X, MobileLayout.Combat.Y))
	local size2 = maid:Value(UDim2.fromOffset(size, size))
	local v3 = nil

	local function updatePosition()
		local v4 = MobileButtonScale.Get()
		local v5 = size * v4
		local vector = Vector2.new(v5, v5)
		size2:Set(UDim2.fromOffset(v5, v5))
		local v6 = Vector2.new(MobileLayout.Combat.X * v4 + v, MobileLayout.Combat.Y * v4 + v2) + value3:Get()
		local v7 = v3

		if v7 ~= nil and v7.AbsoluteSize.X > 0 then
			local v8 = v6 - Vector2.new(JumpButton.RowShift(v7), 0)
			v6 = Bounds.ClampCornerOffset(v8, vector, v7.AbsoluteSize)
		end

		value4:Set(UDim2.fromOffset(v6.X, v6.Y))
	end

	SavedLayout(maid, "Combat", nil, function(p2, p3)
		v = p2
		v2 = p3
		updatePosition()
	end)
	maid:Connect(value3.Changed, updatePosition)
	maid:Add(MobileButtonScale.Changed:Connect(updatePosition))
	local value6 = maid:Value(color)
	local value7 = maid:Value(0.8)
	local value8 = maid:Value(color2)
	local value9 = maid:Value(color3)

	local function showPressed(flag: boolean)
		local v5

		if flag then
			v5 = color4
		else
			v5 = color
		end

		value6:Set(v5)
		value7:Set(flag and 0 or 0.8)
		local v7

		if flag then
			v7 = color5
		else
			v7 = color2
		end

		value8:Set(v7)
		local v9

		if flag then
			v9 = color6
		else
			v9 = color3
		end

		value9:Set(v9)
	end

	local v4 = nil
	local v5 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function release()
		local v6 = v5
		v4 = nil
		v5 = nil
		value6:Set(color)
		value7:Set(0.8)
		value8:Set(color2)
		value9:Set(color3)

		if v6 ~= nil then
			InputHandler.VirtualRelease(v6)
		end
	end

	maid:Connect(UserInputService.InputEnded, function(p2)
		if p2 ~= v4 then
			return
		end

		release() -- equivalent call inferred; original call site unknown
	end)
	maid:Add(function()
		if v4 ~= nil then
			release() -- equivalent call inferred; original call site unknown
		end
	end)
	return maid:Create("Frame")({
		Name = "Combat",
		AnchorPoint = Vector2.new(1, 1),
		Size = size2,
		Position = maid:Do(function(callback)
			return uDim + callback(value4)
		end),
		BackgroundTransparency = 1,
		function(p2)
			local parent = p2.Parent
			v3 = parent
			maid:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), updatePosition)
			updatePosition()
		end,
		maid:Create("Frame")({
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = maid:Do(function(callback)
				local v6

				if callback(p) == true then
					v6 = false
					return false
				end

				local v7 = callback(value)

				if v7 == "Combat" then
					return callback(value2) ~= true
				end

				return v7 == "Tool"
			end),
			maid:Create("ImageLabel")({
				Name = "Bg",
				Size = UDim2.fromScale(2.15, 2.15),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "http://www.roblox.com/asset/?id=134657809787110",
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
				Name = "Icon",
				ZIndex = 2,
				Size = UDim2.fromScale(0.46, 0.46),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = maid:Do(function(callback)
					if callback(value) == "Combat" then
						return BunchaIcons.Fist
					end

					return BunchaIcons.Mouse
				end),
				ImageColor3 = maid:Animation(value9, info)
			}),
			maid:Create("TextButton")({
				Name = "Press",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1.1, 1.1),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5,
				InputBegan = function(_, p2)
					if v4 ~= nil or p2.UserInputState ~= Enum.UserInputState.Begin or p2.UserInputType ~= Enum.UserInputType.Touch and p2.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end

					local v6 = value:Compare("Combat") and "Combat" or "Screen"
					v4 = p2
					v5 = v6
					value6:Set(color4)
					value7:Set(0)
					value8:Set(color5)
					value9:Set(color6)
					InputHandler.VirtualPress(v6)
				end
			})
		}),
		EditPlate(maid, p, {
			GlowScale = 2.15,
			CircleScale = 0.8
		}),
		HolderDrag(maid, p, value3, {
			Drop = function(point: Vector2)
				v += point.X
				v2 += point.Y
				updatePosition()
				LayoutActions.Move("Combat", nil, v, v2)
			end,
			Tap = function()
				v = 0
				v2 = 0
				updatePosition()
				LayoutActions.Reset("Combat", nil)
			end
		})
	})
end