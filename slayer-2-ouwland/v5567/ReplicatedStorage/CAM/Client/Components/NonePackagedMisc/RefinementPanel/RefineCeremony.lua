local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local faye = require(ReplicatedStorage.Packages.faye)
local RefineCeremony = {
	CHARGE_TIME = 1.168,
	STRIKE_TIME = 0.2
}
local color = Color3.new(1, 0.803922, 0.305882)
local v = {
	Success = {
		Word = "SUCCESS",
		Color = Color3.new(0.627451, 1, 0.466667)
	},
	Great = {
		Word = "GREAT SUCCESS",
		Color = color
	},
	Guarded = {
		Word = "GUARDED",
		Color = Color3.fromRGB(85, 170, 255)
	},
	Fail = {
		Word = "FAILED",
		Color = Color3.new(1, 0.35, 0.35)
	}
}
local info = faye.Info(RefineCeremony.CHARGE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local info2 = faye.Info(RefineCeremony.CHARGE_TIME)
local info3 = faye.Info(RefineCeremony.STRIKE_TIME, Enum.EasingStyle.Quad)
local info4 = faye.Info(0.45, Enum.EasingStyle.Quad)
local info5 = faye.Info(0.35, Enum.EasingStyle.Back)
local info6 = faye.Info(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, nil, nil, 0.75)

function RefineCeremony.Sound(childName: string)
	local refinement = ReplicatedStorage.Assets.Sounds:FindFirstChild("Refinement")
	local child

	if refinement ~= nil then
		child = refinement:FindFirstChild(childName)
	end

	if child == nil then
		return nil
	end

	local clone = child:Clone()
	clone.Parent = script
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength)
	return clone
end

function RefineCeremony.Stage(object, p, p2)
	return object:Create("Frame")({
		Name = "Stage",
		ZIndex = 5,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		object:State(function(callback, object2)
			if callback(p) then
				return object2:Create("Frame")({
					Name = "ChargeRing",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = object2:Animation(UDim2.fromScale(1.05, 1.05), info, {
						From = UDim2.fromScale(2.2, 2.2)
					}),
					BackgroundTransparency = 1,
					object2:Create("UICorner")({
						CornerRadius = UDim.new(0.5, 0)
					}),
					object2:Create("UIStroke")({
						Color = color,
						Thickness = object2:Animation(2, info, {
							From = 26
						}),
						Transparency = object2:Animation(0.1, info, {
							From = 0.6
						}),
						object2:Create("UIGradient")({
							Rotation = object2:Animation(0, info2, {
								From = -900
							}),
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.4, 0.15),
								NumberSequenceKeypoint.new(1, 0.95)
							})
						})
					})
				})
			end

			return nil
		end),
		object:Signal(p2, function(object2, p3, p4: string)
			if p4 == "Strike" then
				return object2:SpecialThread(function(object3)
					return object3:Create("Frame")({
						Name = "Flash",
						ZIndex = 5,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1.1, 1.1),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = object3:Animation(1, info3, {
							From = 0.1
						}),
						object3:Create("UICorner")({
							CornerRadius = UDim.new(0.15, 0)
						})
					})
				end, {
					Lifetime = RefineCeremony.STRIKE_TIME
				})
			end

			local v2 = v[p4]
			RefineCeremony.Sound(p4)

			if p4 == "Fail" then
				task.spawn(function()
					for i = 1, 5 do
						p3.Position = UDim2.new(0.5, (6 - i) * (i % 2 == 0 and 2 or -2), 0.5, 0)
						task.wait(0.04)
					end

					p3.Position = UDim2.fromScale(0.5, 0.5)
				end)
			end

			return object2:SpecialThread(function(object3)
				return { object3:Create("Frame")({
						Name = "Ring",
						ZIndex = 6,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = object3:Animation(UDim2.fromScale(1.9, 1.9), info4, {
							From = UDim2.fromScale(0.6, 0.6)
						}),
						BackgroundTransparency = 1,
						object3:Create("UICorner")({
							CornerRadius = UDim.new(0.5, 0)
						}),
						object3:Create("UIStroke")({
							Color = v2.Color,
							Thickness = object3:Animation(1, info4, {
								From = 12
							}),
							Transparency = object3:Animation(1, info4, {
								From = 0
							})
						})
					}), object3:Create("TextLabel")({
						Name = "Word",
						ZIndex = 7,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1.6, 0.34),
						BackgroundTransparency = 1,
						Text = v2.Word,
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = v2.Color,
						TextTransparency = object3:Animation(1, info6, {
							From = 0
						}),
						object3:Create("UIStroke")({
							Thickness = 2,
							Transparency = object3:Animation(1, info6, {
								From = 0.2
							})
						}),
						object3:Create("UIScale")({
							Scale = object3:Animation(1, info5, {
								From = 0.2
							})
						})
					}) }
			end, {
				Lifetime = 1.15
			})
		end)
	})
end

return RefineCeremony