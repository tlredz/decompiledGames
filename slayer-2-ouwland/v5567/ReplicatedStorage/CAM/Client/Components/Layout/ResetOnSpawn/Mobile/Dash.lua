local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local MobileLayout = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MobileLayout)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SavedLayout = require(script.Parent.SavedLayout)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MobileButtonScale = require(ReplicatedStorage2.CAM.Client.Modules.MobileButtonScale)
local LayoutActions = require(script.Parent.LayoutActions)
local Bounds = require(script.Parent.Bounds)
local Pointer = require(script.Parent.Pointer)
local EditPlate = require(script.Parent.EditPlate)
local HolderDrag = require(script.Parent.HolderDrag)
local JumpButton = require(script.Parent.JumpButton)
local Dash_Handler = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dash_Handler)
local Mounted = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Mounted)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local info = faye.Info(0.08)
local uDim = UDim2.fromScale(1, 1)
local size = MobileLayout.Toolbar.Size
local color = Color3.new()
local color2 = Color3.new()
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 1, 1)
local dashIcon = BunchaIcons.DashIcon
local uDim2 = UDim2.fromScale(0.5, 0.5)
local v = {
	GlowScale = 2.15,
	CircleScale = 0.8
}
local info2 = faye.Info(0.2)
return function(maid, _, p)
	local value = maid:Value(false)
	local mobileDirectionalDash = SettingsKeys.MobileDirectionalDash
	local v2 = DataValue.new(mobileDirectionalDash.Path, mobileDirectionalDash.Default, SettingsKeys.Scope)
	value:Set(v2:Get() == true)
	maid:Add(v2.Changed:Connect(function(p2)
		value:Set(p2 == true)
	end), true)
	maid:Add(function()
		v2:Destroy()
	end)
	local value2 = maid:Value(false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watch(humanoid)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function read()
			value2:Set(humanoid.MoveDirection.Magnitude > 0)
		end

		maid:Connect(humanoid:GetPropertyChangedSignal("MoveDirection"), read)
		read() -- equivalent call inferred; original call site unknown
	end

	local function hook(instance)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			maid:Connect(instance.ChildAdded, function(humanoid2)
				if humanoid2:IsA("Humanoid") then
					watch(humanoid2) -- equivalent call inferred; original call site unknown
				end
			end)
			return
		end

		watch(humanoid) -- equivalent call inferred; original call site unknown
	end

	local character = Players.LocalPlayer.Character

	if character == nil then
		maid:Connect(Players.LocalPlayer.CharacterAdded, hook)
	else
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			maid:Connect(character.ChildAdded, function(humanoid2)
				if humanoid2:IsA("Humanoid") then
					watch(humanoid2) -- equivalent call inferred; original call site unknown
				end
			end)
		else
			-- equivalent calls inferred from this helper; original call sites unknown
			local function read()
				value2:Set(humanoid.MoveDirection.Magnitude > 0)
			end

			maid:Connect(humanoid:GetPropertyChangedSignal("MoveDirection"), read)
			read() -- equivalent call inferred; original call site unknown
		end
	end

	local value3 = maid:Value(Mounted.Is())
	local character2 = Players.LocalPlayer.Character

	if character2 ~= nil then
		maid:Add(Mounted.Watch(character2, function(flag: boolean)
			value3:Set(flag)
		end))
	end

	local value4 = maid:Value(InputHandler.IsAvailable())
	maid:Add(InputHandler.Available:Connect(function(flag: boolean)
		value4:Set(flag == true)
	end), true)
	local value5 = maid:Value(false)
	local getvaluesfolder = Utility.getvaluesfolder(Players.LocalPlayer)

	if getvaluesfolder ~= nil then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function read()
			value5:Set(getvaluesfolder:FindFirstChild("Blocking") ~= nil)
		end

		maid:Connect(getvaluesfolder.ChildAdded, function(p2)
			if p2.Name == "Blocking" then
				read() -- equivalent call inferred; original call site unknown
			end
		end)
		maid:Connect(getvaluesfolder.ChildRemoved, function(p2)
			if p2.Name == "Blocking" then
				read() -- equivalent call inferred; original call site unknown
			end
		end)
		read() -- equivalent call inferred; original call site unknown
	end

	local function shown(callback)
		if callback(value3) == true then
			return false
		end

		return callback(value5) == true or callback(value2) == true and callback(value4) == true
	end

	local v3 = 0
	local v4 = 0
	local value6 = maid:Value(Vector2.zero)
	local value7 = maid:Value(UDim2.fromOffset(MobileLayout.Dash.X, MobileLayout.Dash.Y))
	local size2 = maid:Value(UDim2.fromOffset(size * 0.75, size * 0.75))
	local v5 = nil

	local function updatePosition()
		local v6 = MobileButtonScale.Get()
		local v7 = size * 0.75 * v6
		local vector = Vector2.new(v7, v7)
		size2:Set(UDim2.fromOffset(v7, v7))
		local v8 = Vector2.new(MobileLayout.Dash.X * v6 + v3, MobileLayout.Dash.Y * v6 + v4) + value6:Get()
		local v9 = v5

		if v9 ~= nil and v9.AbsoluteSize.X > 0 then
			local v10 = v8 - Vector2.new(JumpButton.RowShift(v9), 0)
			v8 = Bounds.ClampCornerOffset(v10, vector, v9.AbsoluteSize)
		end

		value7:Set(UDim2.fromOffset(v8.X, v8.Y))
	end

	SavedLayout(maid, "Dash", nil, function(p2, p3)
		v3 = p2
		v4 = p3
		updatePosition()
	end)
	maid:Connect(value6.Changed, updatePosition)
	maid:Add(MobileButtonScale.Changed:Connect(updatePosition))
	local value9 = maid:Value(uDim2)
	local v6 = nil
	local v7 = nil
	local zero = Vector2.zero
	local v8 = false

	local function release()
		v6 = nil
		value9:Set(uDim2)
		local v9 = zero
		zero = Vector2.zero
		v8 = false

		if v9.Magnitude < 0.2 then
			Dash_Handler.Perform(Dash_Handler.MovementLetter())
		else
			Dash_Handler.Perform(Dash_Handler.Letter(v9))
		end
	end

	maid:Connect(UserInputService.InputEnded, function(p2)
		if p2 ~= v6 then
			return
		end

		release()
	end)
	maid:Connect(RunService.RenderStepped, function()
		local v9 = v6
		local v10 = v7

		if v9 == nil or v10 == nil then
			return
		end

		local absoluteSize = v10.AbsoluteSize

		if absoluteSize.X <= 0 then
			return
		end

		local v11 = v10.AbsolutePosition + absoluteSize * 0.5
		local v12 = (Pointer(v9) - v11) / absoluteSize.X
		local magnitude = v12.Magnitude

		if not v8 then
			if magnitude < 0.12 then
				return
			else
				v8 = true
			end
		end

		if magnitude > 0.32000000000000006 then
			v12 *= 0.32000000000000006 / magnitude
			magnitude = 0.32000000000000006
		end

		value9:Set(uDim2 + UDim2.fromScale(v12.X, v12.Y))

		if zero.Magnitude < magnitude then
			zero = v12
		end
	end)
	return maid:Create("Frame")({
		Name = "Dash",
		AnchorPoint = Vector2.new(1, 1),
		Size = size2,
		Position = maid:Do(function(callback)
			return uDim + callback(value7)
		end),
		BackgroundTransparency = 1,
		function(p2)
			v7 = p2
			local parent = p2.Parent
			v5 = parent
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
				local v10

				if callback(value3) == true then
					v10 = false
				elseif callback(value5) == true then
					v10 = true
				elseif callback(value2) == true then
					v10 = callback(value4) == true
				else
					v10 = false
				end

				return maid:Animation(v10 and 0 or 1, info2)
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
					ImageColor3 = color,
					ImageTransparency = 0.3
				}),
				maid:Create("ImageLabel")({
					Name = "CircleSelect",
					Size = UDim2.fromScale(0.8, 0.8),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=119489413451678",
					ImageTransparency = 0.8,
					ImageColor3 = color2
				}),
				maid:Create("ImageLabel")({
					Name = "Directions",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://72837589649301",
					ImageColor3 = color4,
					ZIndex = 2,
					ImageTransparency = 0.75,
					Visible = maid:Do(function(callback)
						return callback(value) == true
					end)
				}),
				maid:Create("Frame")({
					Name = "CenterStick",
					Size = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					ZIndex = 5,
					Position = maid:Animation(value9, info),
					BackgroundTransparency = 1,
					maid:Create("ImageLabel")({
						Name = "DashIcon",
						Image = dashIcon,
						ImageColor3 = color3,
						Size = UDim2.fromScale(0.9, 0.9),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						ZIndex = 5
					})
				}),
				maid:Create("TextButton")({
					Name = "Press",
					Size = UDim2.fromScale(1, 1),
					Interactable = maid:Do(function(callback)
						if callback(value3) == true then
							return false
						end

						return callback(value5) == true or callback(value2) == true and callback(value4) == true
					end),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 5,
					InputBegan = function(_, p2)
						if v6 ~= nil or p2.UserInputState ~= Enum.UserInputState.Begin or p2.UserInputType ~= Enum.UserInputType.Touch and p2.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end

						if value:Compare(true) then
							v6 = p2
						else
							Dash_Handler.Perform(value5:Compare(true) and "S" or Dash_Handler.MovementLetter())
						end
					end
				})
			})
		}),
		EditPlate(maid, p, v),
		HolderDrag(maid, p, value6, {
			Drop = function(point: Vector2)
				v3 += point.X
				v4 += point.Y
				updatePosition()
				LayoutActions.Move("Dash", nil, v3, v4)
			end,
			Tap = function()
				v3 = 0
				v4 = 0
				updatePosition()
				LayoutActions.Reset("Dash", nil)
			end
		})
	})
end