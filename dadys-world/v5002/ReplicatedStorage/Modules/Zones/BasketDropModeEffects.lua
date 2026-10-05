local BasketDropModeEffects = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local screenGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 215, 0)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {
	screenGui:WaitForChild("Slot1"),
	screenGui:WaitForChild("Slot2"),
	screenGui:WaitForChild("Slot3"),
	screenGui:WaitForChild("Slot4")
}

local function updateSlotVisuals(enabled)
	local imageColor = enabled and color2 or color

	for _, v3 in ipairs(v) do
		if v3:FindFirstChild("Frame") then
			local frame = v3.Frame

			if frame:FindFirstChild("UIGradient") and frame:FindFirstChild("UIGradientBasket") then
				frame.UIGradient.Enabled = not enabled
				frame.UIGradientBasket.Enabled = enabled
			end
		end

		if not (v3:FindFirstChild("ItemText") and v3.ItemText.Value ~= "None") then
			continue
		end

		if v3:FindFirstChild("BackgroundImage") then
			TweenService:Create(v3.BackgroundImage, tweenInfo, {
				ImageColor3 = imageColor
			}):Play()
		end

		if v3:FindFirstChild("Border") then
			TweenService:Create(v3.Border, tweenInfo, {
				ImageColor3 = imageColor
			}):Play()
		end

		if v3:FindFirstChild("ItemImage") then
			TweenService:Create(v3.ItemImage, tweenInfo, {
				ImageTransparency = enabled and 0.3 or 0
			}):Play()
		end
	end

	if screenGui:FindFirstChild("ItemMessage") and not (enabled and Color3.fromRGB(255, 215, 0)) then
		Color3.fromRGB(255, 255, 255)
	end

	if enabled then
		screenGui.Ability1.ItemImage.Rotation = 180
	else
		screenGui.Ability1.ItemImage.Rotation = 0
	end
end

function BasketDropModeEffects.Init(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	local v2 = {
		Ability1 = {
			orig = UDim2.new(0.752, 0, 0.924, 0),
			basket = UDim2.new(0.684, 0, 0.924, 0)
		},
		Stickers = {
			orig = UDim2.new(0.68, 0, 0.924, 0),
			basket = UDim2.new(0.612, 0, 0.924, 0)
		},
		ViewStats = {
			orig = UDim2.new(0.608, 0, 0.924, 0),
			basket = UDim2.new(0.536, 0, 0.924, 0)
		},
		Slot1 = {
			orig = UDim2.new(0.83, 0, 0.965, 0),
			basket = UDim2.new(0.765, 0, 0.965, 0)
		},
		Slot2 = {
			orig = UDim2.new(0.895, 0, 0.965, 0),
			basket = UDim2.new(0.83, 0, 0.965, 0)
		},
		Slot3 = {
			orig = UDim2.new(0.961, 0, 0.965, 0),
			basket = UDim2.new(0.895, 0, 0.965, 0)
		},
		Slot4 = {
			orig = UDim2.new(0.765, 0, 0.965, 0),
			basket = UDim2.new(0.961, 0, 0.965, 0)
		}
	}

	if not screenGui:GetAttribute("BasketPositionsSet") then
		if screenGui:FindFirstChild("Ability1") then
			local ability1 = screenGui.Ability1
			ability1:SetAttribute("OriginalPosition", ability1.Position)
			ability1.Position = v2.Ability1.basket
		end

		if screenGui:FindFirstChild("ViewStats") then
			local viewStats = screenGui.ViewStats
			viewStats:SetAttribute("OriginalPosition", viewStats.Position)
			viewStats.Position = v2.ViewStats.basket
		end

		if screenGui:FindFirstChild("Stickers") then
			local stickers = screenGui.Stickers
			stickers:SetAttribute("OriginalPosition", stickers.Position)
			stickers.Position = v2.Stickers.basket
		end

		for _, childName in ipairs({
			"Slot1",
			"Slot2",
			"Slot3",
			"Slot4"
		}) do
			local child = screenGui:FindFirstChild(childName)

			if not child then
				continue
			end

			child:SetAttribute("OriginalPosition", child.Position)
			child.Position = v2[childName].basket
		end

		screenGui:SetAttribute("BasketPositionsSet", true)
	end

	local stats = instance:WaitForChild("Stats", 5)
	local inElevator = stats and stats:WaitForChild("InElevator", 5)

	if inElevator then
		inElevator.Changed:Connect(function()
			if inElevator.Value == true then
				updateSlotVisuals(false)

				if playerFromCharacter:GetAttribute("DropMode") then
					playerFromCharacter:SetAttribute("DropMode", false)
					instance:SetAttribute("DropMode", false)

					if screenGui:FindFirstChild("ItemMessage") then
						local color3 = Color3.fromRGB(255, 100, 100)
						local ReplicatedStorage = game:GetService("ReplicatedStorage")

						if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage") then
							screenGui.ItemMessage.Text = "Drop mode deactivated in elevator"
							screenGui.ItemMessage.TextColor3 = color3
							screenGui.ItemMessage.Visible = true
							spawn(function()
								wait(3)
								screenGui.ItemMessage.Visible = false
							end)
						end
					end
				end
			elseif playerFromCharacter:GetAttribute("DropMode") then
				updateSlotVisuals(true)
			end
		end)

		if inElevator.Value == true then
			updateSlotVisuals(false)
		end
	end

	playerFromCharacter:GetAttributeChangedSignal("DropMode"):Connect(function()
		local dropMode = playerFromCharacter:GetAttribute("DropMode") or false
		local stats2 = instance:FindFirstChild("Stats")
		local v3

		if stats2 and stats2:FindFirstChild("InElevator") then
			v3 = stats2.InElevator.Value
		else
			v3 = false
		end

		if not v3 then
			updateSlotVisuals(dropMode)
		end
	end)
	local dropMode = playerFromCharacter:GetAttribute("DropMode") or false
	local stats2 = instance:FindFirstChild("Stats")
	local v3

	if stats2 and stats2:FindFirstChild("InElevator") then
		v3 = stats2.InElevator.Value
	else
		v3 = false
	end

	if v3 then
		updateSlotVisuals(false)
	else
		updateSlotVisuals(dropMode)
	end

	for _, v4 in ipairs(v) do
		if v4:FindFirstChild("ItemText") then
			v4.ItemText:GetPropertyChangedSignal("Value"):Connect(function()
				local dropMode2 = playerFromCharacter:GetAttribute("DropMode") or false
				local stats3 = instance:FindFirstChild("Stats")
				local v5

				if stats3 and stats3:FindFirstChild("InElevator") then
					v5 = stats3.InElevator.Value
				else
					v5 = false
				end

				if dropMode2 and not v5 then
					updateSlotVisuals(true)
				end
			end)
		end
	end
end

function BasketDropModeEffects.ClientAbility(_, p)
	BasketDropModeEffects.Init(p)
end

return BasketDropModeEffects