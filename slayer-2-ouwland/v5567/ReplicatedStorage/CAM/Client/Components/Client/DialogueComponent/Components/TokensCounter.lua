local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local wen = ReplicatedStorage.CAM.Client.Components.Layout.ResetOnSpawn.HUD.HudBottomRight.FirstVertical.Wen
local data = Utility.GetData(Players.LocalPlayer, true)
local icon = Items["Ouwigahara Token"].Icon
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(1, 0.0745098, 0.0901961)
local info = faye.Info(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return function(object)
	local function total()
		local v

		if data ~= nil then
			v = Utility.HeldItem(data, "Ouwigahara Token")
		end

		if v == nil then
			return 0
		end

		local amount = v:FindFirstChild("Amount")

		if amount == nil or not amount:IsA("ValueBase") then
			return 1
		end

		return amount.Value
	end

	local v

	if data ~= nil then
		v = Utility.HeldItem(data, "Ouwigahara Token")
	end

	local v2

	if v == nil then
		v2 = 0
	else
		local amount = v:FindFirstChild("Amount")
		v2 = (amount == nil or not amount:IsA("ValueBase")) and 1 or amount.Value
	end

	local value = object:Value(v2)
	local connection = nil

	local function watch()
		if connection ~= nil then
			connection:Disconnect()
			connection = nil
		end

		local v3

		if data ~= nil then
			v3 = Utility.HeldItem(data, "Ouwigahara Token")
		end

		local amount

		if v3 ~= nil then
			amount = v3:FindFirstChild("Amount")
		end

		if amount ~= nil and amount:IsA("ValueBase") then
			connection = object:Connect(amount.Changed, function()
				local v5

				if data ~= nil then
					v5 = Utility.HeldItem(data, "Ouwigahara Token")
				end

				local v6

				if v5 == nil then
					v6 = 0
				else
					local amount2 = v5:FindFirstChild("Amount")
					v6 = (amount2 == nil or not amount2:IsA("ValueBase")) and 1 or amount2.Value
				end

				value:Set(v6)
			end)
		end

		local v5

		if data ~= nil then
			v5 = Utility.HeldItem(data, "Ouwigahara Token")
		end

		local v6

		if v5 == nil then
			v6 = 0
		else
			local amount2 = v5:FindFirstChild("Amount")
			v6 = (amount2 == nil or not amount2:IsA("ValueBase")) and 1 or amount2.Value
		end

		value:Set(v6)
	end

	object:Spawn(function()
		local parent

		if not (data == nil or data.Parent == nil) then
			parent = data.Parent.Parent
		end

		local accountItems

		if parent ~= nil then
			accountItems = parent:WaitForChild("AccountItems", 30)
		end

		local inventory

		if accountItems ~= nil then
			inventory = accountItems:WaitForChild("Inventory", 30)
		end

		if inventory == nil or not object.IsActive then
			return
		end

		object:Connect(inventory.ChildAdded, watch)
		object:Connect(inventory.ChildRemoved, watch)
		watch()
	end)
	local v3

	if data ~= nil then
		v3 = Utility.HeldItem(data, "Ouwigahara Token")
	end

	local v4

	if v3 == nil then
		v4 = 0
	else
		local amount = v3:FindFirstChild("Amount")
		v4 = (amount == nil or not amount:IsA("ValueBase")) and 1 or amount.Value
	end

	local text = object:Value()
	local v5 = 0
	local UpdValue

	UpdValue = function(p: number, flag: boolean?)
		local v6 = math.random(1, 999)
		v5 = v6

		if flag then
			v4 = p
		elseif p ~= 0 then
			local v7 = math.sign(p)
			v4 += math.max(math.floor(math.abs(p) * 0.5), 1) * v7
		end

		text:Set(Utility.addCommasToNumber(v4))
		local v7 = v4
		local v8

		if data ~= nil then
			v8 = Utility.HeldItem(data, "Ouwigahara Token")
		end

		local v9

		if v8 == nil then
			v9 = 0
		else
			local amount = v8:FindFirstChild("Amount")
			v9 = (amount == nil or not amount:IsA("ValueBase")) and 1 or amount.Value
		end

		if v7 ~= v9 then
			task.delay(0.05, function()
				if v5 ~= v6 or not object.IsActive then
					return
				end

				local v11

				if data ~= nil then
					v11 = Utility.HeldItem(data, "Ouwigahara Token")
				end

				local v12

				if v11 == nil then
					v12 = 0
				else
					local amount = v11:FindFirstChild("Amount")
					v12 = (amount == nil or not amount:IsA("ValueBase")) and 1 or amount.Value
				end

				UpdValue(v12 - v4)
			end)
		end
	end

	local v6

	if data ~= nil then
		v6 = Utility.HeldItem(data, "Ouwigahara Token")
	end

	local v7

	if v6 == nil then
		v7 = 0
	else
		local amount = v6:FindFirstChild("Amount")
		v7 = (amount == nil or not amount:IsA("ValueBase")) and 1 or amount.Value
	end

	UpdValue(v7, true)
	local v8 = object:Create("Frame")({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.fromScale(-0.3, 0.5),
		Size = UDim2.fromScale(10, 0.85),
		BackgroundTransparency = 1,
		object:Create("TextLabel")({
			Name = "Txt",
			Size = UDim2.fromScale(1, 0.8),
			Text = text,
			BackgroundTransparency = 1,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = color,
			FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
			object:Create("UIStroke")({
				Thickness = 2,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			})
		}),
		object:Do(function(callback, object2, _)
			local v9 = callback(value)

			if v4 == nil or v4 == v9 then
				if v4 ~= nil then
					v9 = v9 - v4 or v9
				end

				UpdValue(v9)
			else
				local v10 = v9 - v4
				local textColor = color

				if math.sign(v10) < 0 then
					wen.Diplete:Play()
					textColor = color2
				else
					wen.Gain:Play()
				end

				local text2

				if v10 >= 0 then
					text2 = "+" .. Utility.addCommasToNumber(v10)
				else
					text2 = Utility.addCommasToNumber(v10)
				end

				UpdValue(v9 - v4)
				return object2:SpecialThread(function(object3, _)
					return object3:Create("TextLabel")({
						Text = text2,
						Size = UDim2.fromScale(1, 1),
						Position = UDim2.fromScale(0, -1),
						BackgroundTransparency = 1,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextColor3 = textColor,
						TextTransparency = object3:Animation(1, info),
						FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
						object3:Create("UIStroke")({
							Thickness = 1,
							Transparency = object3:Animation(1, info, {
								From = 0.25
							})
						})
					})
				end, {
					Lifetime = 1
				})
			end
		end)
	})
	return object:Create("Frame")({
		Name = "TokensFrame",
		Size = UDim2.fromScale(0.6, 0.6),
		AnchorPoint = Vector2.new(0, 1),
		object:Create("UIAspectRatioConstraint")({}),
		Position = UDim2.fromScale(0.05, 0.65),
		BackgroundTransparency = 1,
		object:Create("Frame")({
			Name = "Bg",
			Size = UDim2.fromScale(3, 1),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = Color3.new(),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = 180
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		}),
		object:Create("Frame")({
			Name = "InnerBg",
			Size = UDim2.new(3, -6, 1, -6),
			Position = UDim2.fromScale(-0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = 180
				})
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		}),
		object:Create("ImageLabel")({
			Name = "Icon",
			Size = UDim2.fromScale(0.975, 0.975),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = icon,
			ZIndex = 2
		}),
		v8
	})
end