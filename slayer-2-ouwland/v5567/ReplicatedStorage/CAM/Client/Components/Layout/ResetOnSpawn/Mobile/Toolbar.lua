local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MobileLayout = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MobileLayout)
local SavedLayout = require(script.Parent.SavedLayout)
local LayoutActions = require(script.Parent.LayoutActions)
local Bounds = require(script.Parent.Bounds)
local EditPlate = require(script.Parent.EditPlate)
local HolderDrag = require(script.Parent.HolderDrag)
local JumpButton = require(script.Parent.JumpButton)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MobileButtonScale = require(ReplicatedStorage2.CAM.Client.Modules.MobileButtonScale)
local Toolbar = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.CenterBottomContent.Toolbar)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local v

if RunService:IsClient() then
	v = DataValue.new(SettingsKeys.MobileToolbarDrag.Path, SettingsKeys.MobileToolbarDrag.Default, SettingsKeys.Scope)
else
	v = nil
end

local function dragEnabled()
	return v == nil or v:Get() ~= false
end

local uDim = UDim2.fromScale(1, 1)
local size = MobileLayout.Toolbar.Size
local count = MobileLayout.Toolbar.Count
local _ = {
	GlowScale = 2.15,
	CircleScale = 0.8
}
local vector = Vector2.new(0.93, 0.93)
return function(maid, p, p2)
	local v2 = {}
	local count2 = 0
	return maid:Iterate(count, function(p3, _, _, _)
		local numberToWords = Utility.numberToWords(p3)
		local toolbarOffset, v3 = MobileLayout.ToolbarOffset(p3)
		local v4 = 0
		local v5 = 0
		local value = maid:Value(Vector2.zero)
		local value2 = maid:Value(UDim2.fromOffset(toolbarOffset, v3))
		local size2 = maid:Value(UDim2.fromOffset(size, size))
		local v6 = nil

		local function update()
			local v7 = MobileButtonScale.Get()
			local v8 = size * v7
			local vector2 = Vector2.new(v8, v8)
			local v9 = Vector2.new(toolbarOffset * v7 + v4, v3 * v7 + v5) + value:Get()
			local v10 = v6

			if v10 ~= nil and v10.AbsoluteSize.X > 0 then
				local v11 = v9 - Vector2.new(JumpButton.RowShift(v10), 0)
				v9 = Bounds.ClampCornerOffset(v11, vector2, v10.AbsoluteSize)
			end

			size2:Set(UDim2.fromOffset(v8, v8))
			value2:Set(UDim2.fromOffset(v9.X, v9.Y))
		end

		maid:Add(MobileButtonScale.Changed:Connect(update))
		SavedLayout(maid, "Toolbar", numberToWords, function(p4, p5)
			v4 = p4
			v5 = p5
			update()
		end)
		maid:Connect(value.Changed, update)
		update()
		return maid:Create("Frame")({
			Name = numberToWords,
			AnchorPoint = Vector2.new(1, 1),
			Size = size2,
			Position = maid:Do(function(callback)
				return uDim + callback(value2)
			end),
			BackgroundTransparency = 1,
			maid:Create("Frame")({
				Name = "Content",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = maid:Do(function(callback)
					return callback(p2) ~= true
				end),
				function(p4)
					v2[numberToWords] = p4
					count2 += 1

					if count2 == count then
						Toolbar(maid, nil, p, v2, {
							DragEnabled = dragEnabled
						})
					end
				end
			}),
			EditPlate(maid, p2, {
				GlowScale = 2.15,
				CircleScale = 0.8,
				Number = {
					Index = p3,
					At = vector
				}
			}),
			HolderDrag(maid, p2, value, {
				Drop = function(point: Vector2)
					v4 += point.X
					v5 += point.Y
					update()
					LayoutActions.Move("Toolbar", numberToWords, v4, v5)
				end,
				Tap = function()
					v4 = 0
					v5 = 0
					update()
					LayoutActions.Reset("Toolbar", numberToWords)
				end
			}),
			function(p4)
				local parent = p4.Parent
				v6 = parent
				maid:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), update)
				update()
			end
		})
	end)
end