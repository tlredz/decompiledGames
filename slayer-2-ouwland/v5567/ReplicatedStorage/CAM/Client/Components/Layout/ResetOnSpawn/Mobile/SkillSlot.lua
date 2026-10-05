local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Ring = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.CenterBottomContent.ValueHub.Ring)
local SlotNumber = require(script.Parent.SlotNumber)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Skill_Switch_Adder = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local info = faye.Info(0.2)
local color = Color3.new()
local color2 = Color3.new(0.15, 0.15, 0.15)
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(0.5, 0.5, 0.5)
local color6 = Color3.new()
local color7 = Color3.new(1, 0, 0)
local color8 = Color3.new(1, 1, 1)
local vector = Vector2.new(0.16, 0.16)
local vector2 = Vector2.new(0.5, 0.5)
return function(maid, layoutOrder: number, data, _)
	local value = maid:Value(color)
	local value2 = maid:Value(color2)
	local value3 = maid:Value(color3)
	local value4 = maid:Value(0.8)
	local value5 = maid:Value(0)
	local value6 = maid:Value(2)
	local value7 = maid:Value(color7)
	local visible = maid:Value(false)

	local function update()
		local v

		if data.Locked == nil then
			v = false
		else
			v = data.Locked:Compare(true)
		end

		local compare = data.Switch:Compare(true)
		local v2 = data.Holding.HoldingState:Compare(true) and not (v or compare)
		local v4

		if v2 then
			v4 = color4
		else
			v4 = color
		end

		value:Set(v4)
		value4:Set(v2 and 0 or 0.8)
		local v6

		if v2 then
			v6 = color5
		else
			v6 = color2
		end

		value2:Set(v6)
		local v8

		if v2 then
			v8 = color6
		else
			v8 = color3
		end

		value3:Set(v8)
		value5:Set(v and 0.6 or compare and 1 or 0)
		value6:Set(v2 and 4 or 2)
		local v10

		if data.CoolDown:Compare(true) then
			v10 = color7
		else
			v10 = color8
		end

		value7:Set(v10)
		visible:Set(v)
	end

	update()
	maid:Connect(data.CoolDown.Changed, update)
	maid:Connect(data.Holding.HoldingState.Changed, update)
	maid:Connect(data.Switch.Changed, update)

	if data.Locked ~= nil then
		maid:Connect(data.Locked.Changed, update)
	end

	return maid:Create("Frame")({
		Name = layoutOrder .. "-Skill",
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = maid:Do(function(callback)
			return callback(data.Enabled) == true
		end),
		maid:Create("Frame")({
			Name = "Visual",
			Size = UDim2.fromScale(0.8, 0.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			After = function(p2)
				if data.OnGui == nil then
					return
				end

				data.OnGui(p2)
				maid:Add(function()
					data.OnGui(nil, p2)
				end)
			end,
			maid:Create("ImageLabel")({
				Name = "Bg",
				Size = UDim2.fromScale(1.45, 1.45),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "http://www.roblox.com/asset/?id=134657809787110",
				ImageColor3 = maid:Animation(value2, info),
				ImageTransparency = 0.3
			}),
			maid:Create("ImageLabel")({
				Name = "CircleSelect",
				Size = UDim2.fromScale(0.95, 0.95),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "http://www.roblox.com/asset/?id=119489413451678",
				ImageTransparency = maid:Animation(value4, info),
				ImageColor3 = maid:Animation(value, info)
			}),
			maid:Create("ImageLabel")({
				Name = "Image",
				ZIndex = 2,
				Size = UDim2.fromScale(0.62, 0.62),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = data.Icon,
				ImageColor3 = maid:Animation(value3, info),
				ImageTransparency = maid:Animation(value5, info)
			}),
			maid:Create("ImageLabel")({
				Name = "Locked",
				ZIndex = 10,
				Size = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = BunchaIcons.Locked,
				Visible = visible
			}),
			maid:State(function(callback, object)
				if callback(data.Switch) == true then
					return object:Create("ImageLabel")({
						Name = "Switch",
						ZIndex = 6,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.95, 0.95),
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
						OnClean = {
							ImageTransparency = object:Animation(1, info)
						}
					})
				end

				return nil
			end),
			maid:Create("Frame")({
				Name = "Bar",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = maid:Do(function(callback)
					local v = callback(data.Holding.Rotation)

					if v == nil or v <= 0 then
						return false
					end

					if callback(data.CoolDown) == true then
						return true
					end

					return callback(data.Holding.HoldingState) == true and data.Max ~= nil and data.Max > 0
				end),
				Ring(
					maid,
					data.Holding.Rotation,
					UDim2.fromScale(0.5, 0.5),
					UDim2.fromScale(0.88, 0.88),
					maid:Animation(value6, info),
					value7,
					0
				)
			}),
			SlotNumber(maid, layoutOrder, vector, vector2)
		})
	})
end