local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local MobileLayout = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.MobileLayout)
local SavedLayout = require(script.Parent.SavedLayout)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MobileButtonScale = require(ReplicatedStorage2.CAM.Client.Modules.MobileButtonScale)
local LayoutActions = require(script.Parent.LayoutActions)
local JumpButton = require(script.Parent.JumpButton)
local Bounds = require(script.Parent.Bounds)
local EditPlate = require(script.Parent.EditPlate)
local HolderDrag = require(script.Parent.HolderDrag)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Skills = require(ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.CenterBottomContent.Skills)
local Skills_Provider = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
local v = {
	"Skills_1st",
	"Skills_2nd",
	"Skills_3rd",
	"Skills_4th",
	"Skills_5th",
	"Skills_6th",
	"Skills_7th",
	"Skills_8th",
	"Skills_9th",
	"Skills_10th"
}
local count = MobileLayout.Skills.Count
local size = MobileLayout.Toolbar.Size
local _ = {
	GlowScale = 1.45,
	CircleScale = 0.95,
	VisualScale = 0.8
}
local vector = Vector2.new(0.16, 0.16)
local vector2 = Vector2.new(0.5, 0.5)
return function(maid, p, p2)
	local v2 = {}
	local v3 = {}
	local count2 = 0

	for i = 1, count do
		v2[i] = maid:Value(false)
	end

	local function readKeys(list)
		for i = 1, count do
			v2[i]:Set(list ~= nil and list[i] ~= nil)
		end
	end

	readKeys(Skills_Provider.get_current_keys())
	maid:Connect(Skills_Provider.Keys_Changed, readKeys)
	return maid:Iterate(count, function(p3, _, _, _)
		local numberToWords = Utility.numberToWords(p3)
		local v4 = v[p3]
		local position = maid:Value(UDim2.new())
		local size2 = maid:Value(UDim2.new())
		local skillOffset, v5 = MobileLayout.SkillOffset(p3)
		local v6 = 0
		local v7 = 0
		local value3 = maid:Value(Vector2.zero)
		local v8 = nil

		local function update()
			local v9 = v8

			if v9 == nil then
				return
			end

			local metrics, v10, v11 = JumpButton.Metrics(v9)
			local v12 = metrics - Vector2.new(0, v11)
			local v13 = MobileButtonScale.Get()
			local v14 = size * v13
			local v15 = v12 + (Vector2.new(skillOffset, v5) * v13 + Vector2.new(v6, v7)) * v10 + value3:Get()

			if v9.AbsoluteSize.X > 0 then
				v15 = Bounds.ClampCentre(v15, Vector2.new(v14, v14), v9.AbsoluteSize)
			end

			position:Set(UDim2.fromOffset(v15.X, v15.Y))
			size2:Set(UDim2.fromOffset(v14, v14))
		end

		local v9 = nil
		maid:Connect(UserInputService.InputEnded, function(p4)
			if p4 ~= v9 then
				return
			end

			v9 = nil
			Platform_Handler.EndAim(p4)
			InputHandler.VirtualRelease(v4)
		end)
		maid:Connect(value3.Changed, update)
		maid:Add(MobileButtonScale.Changed:Connect(update))
		return maid:Create("Frame")({
			Name = numberToWords,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = size2,
			Position = position,
			BackgroundTransparency = 1,
			maid:Create("Frame")({
				Name = "Content",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Visible = maid:Do(function(callback)
					return callback(p2) ~= true
				end),
				maid:Create("TextButton")({
					Name = "Press",
					Visible = v2[p3],
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1.05, 1.05),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 5,
					InputBegan = function(_, p4)
						if v9 ~= nil or p4.UserInputState ~= Enum.UserInputState.Begin or p4.UserInputType ~= Enum.UserInputType.Touch and p4.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end

						v9 = p4
						Platform_Handler.BeginAim(p4)
						InputHandler.VirtualPress(v4)
					end
				}),
				function(p4)
					v3[numberToWords] = p4
					count2 += 1

					if count2 == count then
						Skills(maid, p, p, v3)
					end
				end
			}),
			EditPlate(maid, p2, {
				GlowScale = 1.45,
				CircleScale = 0.95,
				VisualScale = 0.8,
				Number = {
					Index = p3,
					At = vector,
					Anchor = vector2
				}
			}),
			HolderDrag(maid, p2, value3, {
				Drop = function(point: Vector2)
					local v10 = v8

					if v10 == nil then
						return
					end

					local _, v11 = JumpButton.Metrics(v10)

					if v11 <= 0 then
						return
					end

					v6 += point.X / v11
					v7 += point.Y / v11
					update()
					LayoutActions.Move("Skills", numberToWords, v6, v7)
				end,
				Tap = function()
					v6 = 0
					v7 = 0
					update()
					LayoutActions.Reset("Skills", numberToWords)
				end
			}),
			function(p4)
				local parent = p4.Parent
				v8 = parent
				SavedLayout(maid, "Skills", numberToWords, function(p5, p6)
					v6 = p5
					v7 = p6
					update()
				end)
				update()
				maid:Connect(parent:GetPropertyChangedSignal("AbsoluteSize"), update)
				local currentCamera = workspace.CurrentCamera

				if currentCamera ~= nil then
					maid:Connect(currentCamera:GetPropertyChangedSignal("ViewportSize"), update)
				end
			end
		})
	end)
end