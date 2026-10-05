local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
ReplicatedStorage:WaitForChild("Sound_Effect")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local updateInventory = otherEvent.ItemEvents:WaitForChild("UpdateInventory")
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local parent = script.Parent
local parent2 = parent.Parent.Parent.Parent
local frame = parent.Frame
local _ = parent.Parent.Parent.AllMenu
local container = frame.Container
local equipFrame = frame.EquipFrame
local accessoryFrame = frame.AccessoryFrame
local dropDown = frame.DropDown
local _ = dropDown.Menu
local select_Button = dropDown.Select_Button
local equip = equipFrame.EquipFrame.Equip
local equip2 = accessoryFrame.EquipFrame.Equip
local item_Template = script.Item_Template
local buff_Template = script.Buff_Template
local container2 = accessoryFrame.Container
local ItemInfo = require(moduleScript:WaitForChild("ItemInfo"))
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local ColorTable = require(moduleScript:WaitForChild("ColorTable"))
require(moduleScript:WaitForChild("Abbreviate"))
local rarity = ItemInfo.Rarity
local icon = ItemInfo.Icon
local item = ColorTable.Item
local gradient = ColorTable.Gradient
local _ = ColorTable.Boarder
local equipBoarder = ColorTable.EquipBoarder
local _ = ColorTable.Name_Background
local weapon = rarity.Weapon
local accessory = rarity.Accessory
local power = rarity.Power
local item2 = rarity.Item
local connections = {}
local lastTime = tick()
local playerData = localPlayer:WaitForChild("PlayerData", 60)
local items = localPlayer:WaitForChild("Items", 60)
local swordEquip = playerData:WaitForChild("SwordEquip")
playerData:WaitForChild("PowerEquip")
local accessoryEquip = playerData:WaitForChild("AccessoryEquip")
local weapon2 = items:WaitForChild("Weapon")
local accessory2 = items:WaitForChild("Accessory")
local power2 = items:WaitForChild("Power")
local itemStorage = items:WaitForChild("ItemStorage")

-- equivalent calls inferred from this helper; original call sites unknown
local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0) and parent2.Main.AllMenu:GetAttribute("CurrentOpen") == parent.Name
end

local function MultiplytoPercent(p)
	return p * 100 - 100
end

local function Clear_Button(container3)
	for _, button in ipairs(container3:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end
end

local function Clear_Frame(container3)
	for _, frame2 in ipairs(container3:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end
end

local function roundNumber(p, value)
	return (tonumber(string.format("%." .. (value or 0) .. "f", p)))
end

local function SetColor_State(p: string, equip3)
	if p == "Equip" then
		equip3.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		equip3.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		equip3.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		equip3.Colour.Pattern.ImageColor3 = Color3.fromRGB(29, 85, 41)
	elseif p == "Unequip" then
		equip3.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		equip3.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		equip3.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		equip3.Colour.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	end
end

local function Setup_Buff(name)
	local itemSetting = ItemSettings[name]

	if itemSetting then
		for k, v in pairs(itemSetting) do
			local clone = buff_Template:Clone()
			clone.Name = k
			clone.Visible = true
			clone.Parent = container2

			if k == "FightingStyle_Damage" then
				clone.LayoutOrder = 5
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "ดาเมจระยะประชิด" or "Melee Damage"

				if v < 1 then
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				else
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				end

				clone.Icon.Image = "rbxassetid://15925328944"
			elseif k == "Weapon_Damage" then
				clone.LayoutOrder = 6
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "ดาเมจอาวุธ" or "Weapon Damage"

				if v < 1 then
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				else
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				end

				clone.Icon.Image = "rbxassetid://15884792645"
			elseif k == "Power_Damage" then
				clone.LayoutOrder = 7
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "ดาเมจพลังพิเศษ" or "Power Damage"

				if v < 1 then
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				else
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				end

				clone.Icon.Image = "rbxassetid://14757615135"
			elseif k == "Defense" then
				clone.LayoutOrder = 3
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "พลังป้องกัน" or "Defense"
				local buff_Value = clone.Buff_Value
				local v2 = v * 100 - 100
				buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				clone.Icon.Image = "rbxassetid://17443866660"
			elseif k == "Regeneration_Boost" then
				clone.LayoutOrder = 4
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "การฟื้นฟูพลังชีวิต" or "Health Regen"
				local buff_Value = clone.Buff_Value
				local v2 = v * 100 - 100
				buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				clone.Icon.Image = "rbxassetid://17444541581"
			elseif k == "WalkSpeed_Boost" then
				clone.LayoutOrder = 11
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "ความเร็วในการเดิน" or "Walk Speed"

				if v < 0 then
					clone.Buff_Value.Text = `{math.floor(v)}`
				else
					clone.Buff_Value.Text = `+{math.floor(v)}`
				end

				clone.Icon.Image = "rbxassetid://17445223562"
			elseif k == "Instinct_Dodge" then
				clone.LayoutOrder = 12
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "การหลบสัญชาตญาณ" or "Instinct Dodge"
				clone.Buff_Value.Text = `+{math.floor(v)}`
				clone.Icon.Image = "rbxassetid://17462561576"
			elseif k == "FightingStyle_Cooldown" then
				clone.LayoutOrder = 8
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "คูลดาวน์ระยะประชิด" or "Melee Cooldown"

				if v < 1 then
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				else
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `-{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				end

				clone.Icon.Image = "rbxassetid://17444274511"
			elseif k == "Weapon_Cooldown" then
				clone.LayoutOrder = 9
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "คูลดาวน์อาวุธ" or "Weapon Cooldown"

				if v < 1 then
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				else
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `-{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				end

				clone.Icon.Image = "rbxassetid://17444326477"
			elseif k == "Power_Cooldown" then
				clone.LayoutOrder = 10
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "คูลดาวน์พลังพิเศษ" or "Power Cooldown"

				if v < 1 then
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				else
					local buff_Value = clone.Buff_Value
					local v2 = v * 100 - 100
					buff_Value.Text = `-{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				end

				clone.Icon.Image = "rbxassetid://17444337979"
			elseif k == "Health" then
				clone.LayoutOrder = 0
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "พลังชีวิต" or "Health"

				if v < 0 then
					clone.Buff_Value.Text = `{math.floor(v)}`
				else
					clone.Buff_Value.Text = `+{math.floor(v)}`
				end

				clone.Icon.Image = "rbxassetid://17437877830"
			elseif k == "Exp_Boost" then
				clone.LayoutOrder = 1
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "บูสต์ค่าประสบการณ์" or "Exp Boost"
				local buff_Value = clone.Buff_Value
				local v2 = v * 100 - 100
				buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				clone.Icon.Image = "rbxassetid://13719827501"
			elseif k == "Money_Boost" then
				clone.LayoutOrder = 2
				clone.Buff_Name.Text = localPlayer:GetAttribute("TH") and "บูสต์เงิน" or "Money Boost"
				local buff_Value = clone.Buff_Value
				local v2 = v * 100 - 100
				buff_Value.Text = `+{tonumber(string.format("%." .. 1 .. "f", v2))}%`
				clone.Icon.Image = "rbxassetid://15925746677"
			end
		end
	end
end

local function ClearCamera(instance)
	for _, camera in ipairs(instance:GetChildren()) do
		if camera:IsA("Camera") or camera.Name == "Handle" then
			camera:Destroy()
		end
	end
end

local function Searching()
	local text = string.lower(frame.DropDown.Search_Frame.Search.Text)

	if container then
		for _, button in ipairs(container:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			if text == "" or string.find(string.lower(button.ItemName.Text), text) or string.find(
				string.lower(button.ItemRarity.Text),
				text
			) then
				button.Visible = true
			else
				button.Visible = false
			end
		end
	end
end

local v = {
	Secret = 0,
	Exclusive = 1,
	Legendary = 2,
	Rare = 3,
	Uncommon = 4,
	Common = 5
}
local v2 = {
	Weapon = weapon2,
	Accessory = accessory2,
	Power = power2,
	Item = itemStorage,
	["อาวุธ"] = weapon2,
	["อุปกรณ์เสริม"] = accessory2,
	["พลังพิเศษ"] = power2,
	["ไอเทม"] = itemStorage
}
frame.DropDown.Search_Frame.Search:GetPropertyChangedSignal("Text"):Connect(Searching)

local function getLayoutOrder(p)
	return v[p]
end

local function OnChanged(instance, text)
	equipFrame.Visible = false
	equipFrame:SetAttribute("Current", "None")
	accessoryFrame.Visible = false
	accessoryFrame:SetAttribute("Current", "None")

	if text == "Weapon" or text == "อาวุธ" then
		Clear_Button(container)

		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end

		table.clear(connections)

		for _, child in ipairs(instance:GetChildren()) do
			if not (child.Value > 0 and weapon[child.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child.Name
			clone.ItemName.Text = child.Name

			if localPlayer:GetAttribute("TH") == true then
				clone.ItemType.Text = Translate.Weapon
				clone.ItemRarity.Text = Translate[weapon[clone.Name]]
			else
				clone.ItemType.Text = "Weapon"
				clone.ItemRarity.Text = weapon[clone.Name]
			end

			if child.Value > 1 then
				clone.Amount.Visible = true
				clone.Amount.Text = `x{child.Value}`
			end

			clone.BackgroundColor3 = item[weapon[child.Name]]
			clone.Icon.Image = icon[child.Name]
			clone.Board.ImageColor3 = item[weapon[child.Name]]
			clone.Name_Board.ImageColor3 = item[weapon[child.Name]]
			clone.ItemName.UIStroke.Color = item[weapon[child.Name]]
			clone.LayoutOrder = v[weapon[child.Name]]
			clone.Parent = container

			if equipFrame:GetAttribute("Current") == clone.ItemName.Text then
				if localPlayer:GetAttribute("TH") == true then
					equipFrame.WhichText.Text = `{Translate[weapon[child.Name]]}`
				else
					equipFrame.WhichText.Text = `{weapon[child.Name]}`
				end

				equipFrame.WhichText.UIGradient.Color = gradient[weapon[child.Name]]
				equipFrame.WhichText.UIStroke.UIGradient.Color = gradient[weapon[child.Name]]
				equipFrame.ToolName.Text = child.Name
				equipFrame.ToolFrame_BG.BackgroundColor3 = item[weapon[child.Name]]
				equipFrame.ToolFrame_BG.Icon.Image = icon[child.Name]
				equipFrame.ToolFrame_BG.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
				equipFrame.ToolFrame_BG.Board.Image = equipBoarder[weapon[child.Name]]

				if child.Value > 1 then
					equipFrame.AmountText.Visible = true
					equipFrame.AmountText.Text = `x{child.Value}`
				else
					equipFrame.AmountText.Visible = false
				end

				if tostring(swordEquip.Value) == tostring(clone.Name) then
					if localPlayer:GetAttribute("TH") == true then
						equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unequip
					else
						equipFrame.EquipFrame.Equip.Textlabel.Text = "Unequip"
					end

					SetColor_State("Unequip", equip)
				else
					if localPlayer:GetAttribute("TH") == true then
						equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Equip
					else
						equipFrame.EquipFrame.Equip.Textlabel.Text = "Equip"
					end

					SetColor_State("Equip", equip)
				end

				equipFrame.ToolFrame_BG.Visible = true
				equipFrame.Visible = true
			end

			local v5 = child
			connections[#connections + 1] = clone.Activated:Connect(function()
				if accessoryFrame.Visible then
					accessoryFrame.Visible = false
					accessoryFrame:SetAttribute("Current", "None")
				end

				if equipFrame:GetAttribute("Current") == clone.Name then
					equipFrame.Visible = false
					equipFrame:SetAttribute("Current", "None")
				else
					equipFrame:SetAttribute("Current", clone.Name)

					if localPlayer:GetAttribute("TH") == true then
						equipFrame.WhichText.Text = `{Translate[weapon[v5.Name]]}`
					else
						equipFrame.WhichText.Text = `{weapon[v5.Name]}`
					end

					if v5.Value > 1 then
						equipFrame.AmountText.Visible = true
						equipFrame.AmountText.Text = `x{v5.Value}`
					else
						equipFrame.AmountText.Visible = false
					end

					equipFrame.WhichText.UIGradient.Color = gradient[weapon[v5.Name]]
					equipFrame.WhichText.UIStroke.UIGradient.Color = gradient[weapon[v5.Name]]
					equipFrame.ToolName.Text = v5.Name
					equipFrame.ToolFrame_BG.BackgroundColor3 = item[weapon[v5.Name]]
					equipFrame.ToolFrame_BG.Icon.Image = icon[v5.Name]
					equipFrame.ToolFrame_BG.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					equipFrame.ToolFrame_BG.Board.Image = equipBoarder[weapon[v5.Name]]

					if tostring(swordEquip.Value) == tostring(clone.Name) then
						if localPlayer:GetAttribute("TH") == true then
							equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unequip
						else
							equipFrame.EquipFrame.Equip.Textlabel.Text = "Unequip"
						end

						SetColor_State("Unequip", equip)
					else
						if localPlayer:GetAttribute("TH") == true then
							equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Equip
						else
							equipFrame.EquipFrame.Equip.Textlabel.Text = "Equip"
						end

						SetColor_State("Equip", equip)
					end

					equipFrame.ToolFrame_BG.Visible = true
					equipFrame.Visible = true
				end
			end)
		end

		frame.DropDown.Search_Frame.Search.Text = ""
	elseif text == "Accessory" or text == "อุปกรณ์เสริม" then
		Clear_Button(container)

		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end

		table.clear(connections)

		for _, child in ipairs(instance:GetChildren()) do
			if not (child.Value > 0 and accessory[child.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child.Name
			clone.ItemName.Text = child.Name

			if localPlayer:GetAttribute("TH") == true then
				clone.ItemType.Text = Translate.Accessory
				clone.ItemRarity.Text = Translate[accessory[clone.Name]]
			else
				clone.ItemType.Text = "Accessory"
				clone.ItemRarity.Text = accessory[clone.Name]
			end

			if child.Value > 1 then
				clone.Amount.Visible = true
				clone.Amount.Text = `x{child.Value}`
			end

			clone.BackgroundColor3 = item[accessory[child.Name]]
			clone.Icon.Image = icon[child.Name]
			clone.Name_Board.ImageColor3 = item[accessory[child.Name]]
			clone.ItemName.UIStroke.Color = item[accessory[child.Name]]
			clone.Board.ImageColor3 = item[accessory[child.Name]]
			clone.LayoutOrder = v[accessory[child.Name]]
			clone.Parent = container

			if accessoryFrame:GetAttribute("Current") == clone.ItemName.Text then
				if localPlayer:GetAttribute("TH") == true then
					accessoryFrame.WhichText.Text = `{Translate[accessory[child.Name]]}`
				else
					accessoryFrame.WhichText.Text = `{accessory[child.Name]}`
				end

				Clear_Frame(container2)
				Setup_Buff(clone.Name)
				accessoryFrame.WhichText.UIGradient.Color = gradient[accessory[child.Name]]
				accessoryFrame.WhichText.UIStroke.UIGradient.Color = gradient[accessory[child.Name]]
				accessoryFrame.ToolName.Text = child.Name
				accessoryFrame.ToolFrame_BG.BackgroundColor3 = item[accessory[child.Name]]
				accessoryFrame.ToolFrame_BG.Icon.Image = icon[child.Name]
				accessoryFrame.ToolFrame_BG.Board.Image = equipBoarder[accessory[child.Name]]

				if child.Value > 1 then
					accessoryFrame.AmountText.Visible = true
					accessoryFrame.AmountText.Text = `x{child.Value}`
				else
					accessoryFrame.AmountText.Visible = false
				end

				if tostring(accessoryEquip.Value) == tostring(clone.Name) then
					if localPlayer:GetAttribute("TH") == true then
						accessoryFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unequip
					else
						accessoryFrame.EquipFrame.Equip.Textlabel.Text = "Unequip"
					end

					SetColor_State("Unequip", equip2)
				else
					if localPlayer:GetAttribute("TH") == true then
						accessoryFrame.EquipFrame.Equip.Textlabel.Text = Translate.Equip
					else
						accessoryFrame.EquipFrame.Equip.Textlabel.Text = "Equip"
					end

					SetColor_State("Equip", equip2)
				end

				accessoryFrame.ToolFrame_BG.Visible = true
				accessoryFrame.Visible = true
			end

			local v5 = child
			connections[#connections + 1] = clone.Activated:Connect(function()
				if equipFrame.Visible then
					equipFrame.Visible = false
					equipFrame:SetAttribute("Current", "None")
				end

				if accessoryFrame:GetAttribute("Current") == clone.Name then
					accessoryFrame.Visible = false
					accessoryFrame:SetAttribute("Current", "None")
				else
					accessoryFrame:SetAttribute("Current", clone.Name)

					if localPlayer:GetAttribute("TH") == true then
						accessoryFrame.WhichText.Text = `{Translate[accessory[v5.Name]]}`
					else
						accessoryFrame.WhichText.Text = `{accessory[v5.Name]}`
					end

					Clear_Frame(container2)
					Setup_Buff(clone.Name)
					accessoryFrame.WhichText.UIGradient.Color = gradient[accessory[v5.Name]]
					accessoryFrame.WhichText.UIStroke.UIGradient.Color = gradient[accessory[v5.Name]]
					accessoryFrame.ToolName.Text = v5.Name
					accessoryFrame.ToolFrame_BG.BackgroundColor3 = item[accessory[v5.Name]]
					accessoryFrame.ToolFrame_BG.Icon.Image = icon[v5.Name]
					accessoryFrame.ToolFrame_BG.Board.Image = equipBoarder[accessory[v5.Name]]

					if v5.Value > 1 then
						accessoryFrame.AmountText.Visible = true
						accessoryFrame.AmountText.Text = `x{v5.Value}`
					else
						accessoryFrame.AmountText.Visible = false
					end

					if tostring(accessoryEquip.Value) == tostring(clone.Name) then
						if localPlayer:GetAttribute("TH") == true then
							accessoryFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unequip
						else
							accessoryFrame.EquipFrame.Equip.Textlabel.Text = "Unequip"
						end

						SetColor_State("Unequip", equip2)
					else
						if localPlayer:GetAttribute("TH") == true then
							accessoryFrame.EquipFrame.Equip.Textlabel.Text = Translate.Equip
						else
							accessoryFrame.EquipFrame.Equip.Textlabel.Text = "Equip"
						end

						SetColor_State("Equip", equip2)
					end

					accessoryFrame.ToolFrame_BG.Visible = true
					accessoryFrame.Visible = true
				end
			end)
		end

		frame.DropDown.Search_Frame.Search.Text = ""
	elseif text == "Power" or text == "พลังพิเศษ" then
		Clear_Button(container)

		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end

		table.clear(connections)

		for _, child in ipairs(instance:GetChildren()) do
			if not (child.Value > 0 and power[child.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child.Name
			clone.ItemName.Text = child.Name

			if localPlayer:GetAttribute("TH") == true then
				clone.ItemType.Text = Translate.Power
				clone.ItemRarity.Text = Translate[power[clone.Name]]
			else
				clone.ItemType.Text = "Power"
				clone.ItemRarity.Text = power[clone.Name]
			end

			clone.Amount.Visible = true
			clone.Amount.Text = `x{child.Value}`
			clone.BackgroundColor3 = item[power[child.Name]]
			clone.Icon.ImageColor3 = Color3.fromRGB(235, 233, 227)
			clone.Icon.Image = icon[child.Name]

			if clone.Name == "Invisible Power" then
				clone.Icon.ImageTransparency = 0.5
			end

			clone.Name_Board.ImageColor3 = item[power[child.Name]]
			clone.ItemName.UIStroke.Color = item[power[child.Name]]
			clone.Board.ImageColor3 = item[power[child.Name]]
			clone.LayoutOrder = v[power[child.Name]]
			clone.Parent = container

			if equipFrame:GetAttribute("Current") == clone.ItemName.Text then
				if localPlayer:GetAttribute("TH") == true then
					equipFrame.WhichText.Text = `{Translate[power[child.Name]]}`
				else
					equipFrame.WhichText.Text = `{power[child.Name]}`
				end

				equipFrame.WhichText.UIGradient.Color = gradient[power[child.Name]]
				equipFrame.WhichText.UIStroke.UIGradient.Color = gradient[power[child.Name]]
				equipFrame.ToolName.Text = child.Name
				equipFrame.ToolFrame_BG.BackgroundColor3 = item[power[child.Name]]
				equipFrame.ToolFrame_BG.Icon.Image = icon[child.Name]
				equipFrame.ToolFrame_BG.ImageColor3 = Color3.fromRGB(235, 233, 227)
				equipFrame.ToolFrame_BG.Board.Image = equipBoarder[power[child.Name]]
				equipFrame.AmountText.Visible = true
				equipFrame.AmountText.Text = `x{child.Value}`
				SetColor_State("Equip", equip)

				if localPlayer:GetAttribute("TH") == true then
					equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unstore
				else
					equipFrame.EquipFrame.Equip.Textlabel.Text = "Unstore"
				end

				equipFrame.ToolFrame_BG.Visible = true
				equipFrame.Visible = true
			end

			local v5 = child
			connections[#connections + 1] = clone.Activated:Connect(function()
				if accessoryFrame.Visible then
					accessoryFrame.Visible = false
					accessoryFrame:SetAttribute("Current", "None")
				end

				if equipFrame:GetAttribute("Current") == clone.Name then
					equipFrame.Visible = false
					equipFrame:SetAttribute("Current", "None")
				else
					equipFrame:SetAttribute("Current", clone.Name)
					SetColor_State("Equip", equip)

					if localPlayer:GetAttribute("TH") == true then
						equipFrame.WhichText.Text = `{Translate[power[v5.Name]]}`
						equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unstore
					else
						equipFrame.WhichText.Text = `{power[v5.Name]}`
						equipFrame.EquipFrame.Equip.Textlabel.Text = "Unstore"
					end

					equipFrame.WhichText.UIGradient.Color = gradient[power[v5.Name]]
					equipFrame.WhichText.UIStroke.UIGradient.Color = gradient[power[v5.Name]]
					equipFrame.ToolName.Text = v5.Name
					equipFrame.ToolFrame_BG.BackgroundColor3 = item[power[v5.Name]]
					equipFrame.ToolFrame_BG.Icon.Image = icon[v5.Name]
					equipFrame.ToolFrame_BG.Icon.ImageColor3 = Color3.fromRGB(235, 233, 227)
					equipFrame.ToolFrame_BG.Board.Image = equipBoarder[power[v5.Name]]
					equipFrame.AmountText.Visible = true
					equipFrame.AmountText.Text = `x{v5.Value}`
					equipFrame.ToolFrame_BG.Visible = true
					equipFrame.Visible = true
				end
			end)
		end

		frame.DropDown.Search_Frame.Search.Text = ""
	elseif text == "Item" or text == "ไอเทม" then
		Clear_Button(container)

		for _, connection in ipairs(connections) do
			if connection then
				connection:Disconnect()
			end
		end

		table.clear(connections)

		for _, child in ipairs(instance:GetChildren()) do
			if not (child.Value > 0 and item2[child.Name]) then
				continue
			end

			local clone = item_Template:Clone()
			clone.Name = child.Name
			clone.ItemName.Text = child.Name

			if localPlayer:GetAttribute("TH") == true then
				clone.ItemType.Text = Translate.Item
				clone.ItemRarity.Text = Translate[item2[clone.Name]]
			else
				clone.ItemType.Text = "Item"
				clone.ItemRarity.Text = item2[clone.Name]
			end

			clone.Amount.Visible = true
			clone.Amount.Text = `x{child.Value}`
			clone.BackgroundColor3 = item[item2[child.Name]]
			clone.Icon.Image = icon[child.Name]
			clone.ItemName.UIStroke.Color = item[item2[child.Name]]
			clone.Name_Board.ImageColor3 = item[item2[child.Name]]
			clone.Board.ImageColor3 = item[item2[child.Name]]
			clone.LayoutOrder = v[item2[child.Name]]
			clone.Parent = container

			if equipFrame:GetAttribute("Current") == clone.ItemName.Text then
				if localPlayer:GetAttribute("TH") == true then
					equipFrame.WhichText.Text = `{Translate[item2[child.Name]]}`
				else
					equipFrame.WhichText.Text = `{item2[child.Name]}`
				end

				equipFrame.WhichText.UIGradient.Color = gradient[item2[child.Name]]
				equipFrame.WhichText.UIStroke.UIGradient.Color = gradient[item2[child.Name]]
				equipFrame.ToolName.Text = child.Name
				equipFrame.ToolFrame_BG.BackgroundColor3 = item[item2[child.Name]]
				equipFrame.ToolFrame_BG.Icon.Image = icon[child.Name]
				equipFrame.ToolFrame_BG.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
				equipFrame.ToolFrame_BG.Board.Image = equipBoarder[item2[child.Name]]
				equipFrame.AmountText.Visible = true
				equipFrame.AmountText.Text = `x{child.Value}`
				local itemSetting = ItemSettings[clone.Name]

				if itemSetting and itemSetting.Unstoreable then
					SetColor_State("Equip", equip)
				else
					SetColor_State("Unequip", equip)
				end

				if localPlayer:GetAttribute("TH") == true then
					equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unstore
				else
					equipFrame.EquipFrame.Equip.Textlabel.Text = "Unstore"
				end

				equipFrame.ToolFrame_BG.Visible = true
				equipFrame.Visible = true
			end

			local v5 = child
			connections[#connections + 1] = clone.Activated:Connect(function()
				if accessoryFrame.Visible then
					accessoryFrame.Visible = false
					accessoryFrame:SetAttribute("Current", "None")
				end

				if equipFrame:GetAttribute("Current") == clone.Name then
					equipFrame.Visible = false
					equipFrame:SetAttribute("Current", "None")
				else
					equipFrame:SetAttribute("Current", clone.Name)
					local itemSetting = ItemSettings[clone.Name]

					if itemSetting and itemSetting.Unstoreable then
						SetColor_State("Equip", equip)
					else
						SetColor_State("Unequip", equip)
					end

					if localPlayer:GetAttribute("TH") == true then
						equipFrame.WhichText.Text = `{Translate[item2[v5.Name]]}`
						equipFrame.EquipFrame.Equip.Textlabel.Text = Translate.Unstore
					else
						equipFrame.WhichText.Text = `{item2[v5.Name]}`
						equipFrame.EquipFrame.Equip.Textlabel.Text = "Unstore"
					end

					equipFrame.WhichText.UIGradient.Color = gradient[item2[v5.Name]]
					equipFrame.WhichText.UIStroke.UIGradient.Color = gradient[item2[v5.Name]]
					equipFrame.ToolName.Text = v5.Name
					equipFrame.ToolFrame_BG.BackgroundColor3 = item[item2[v5.Name]]
					equipFrame.ToolFrame_BG.Icon.Image = icon[v5.Name]
					equipFrame.ToolFrame_BG.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					equipFrame.ToolFrame_BG.Board.Image = equipBoarder[item2[v5.Name]]
					equipFrame.AmountText.Visible = true
					equipFrame.AmountText.Text = `x{v5.Value}`
					equipFrame.ToolFrame_BG.Visible = true
					equipFrame.Visible = true
				end
			end)
		end

		frame.DropDown.Search_Frame.Search.Text = ""
	end
end

guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == parent.Name and action == "Open" then
		OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
	end
end)
select_Button.SelectedText:GetPropertyChangedSignal("Text"):Connect(function()
	equipFrame.Visible = false
	equipFrame:SetAttribute("Current", "None")
	accessoryFrame.Visible = false
	accessoryFrame:SetAttribute("Current", "None")
	OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
end)
equipFrame.EquipFrame.Equip.Activated:Connect(function()
	if tick() - lastTime >= 0.1 then
		lastTime = tick()

		if weapon[equipFrame.ToolName.Text] then
			local v3 = updateInventory:InvokeServer("Weapon", {
				SelectedItem = equipFrame.ToolName.Text
			})

			if v3 == "Equip" then
				equipFrame.Visible = false
				equipFrame:SetAttribute("Current", "None")
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			elseif v3 == "Unequip" then
				equipFrame.Visible = false
				equipFrame:SetAttribute("Current", "None")
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		elseif power[equipFrame.ToolName.Text] then
			if updateInventory:InvokeServer("Power", {
				SelectedItem = equipFrame.ToolName.Text,
				Action = "Unstore"
			}) == "Unstore" then
				equipFrame.Visible = false
				equipFrame:SetAttribute("Current", "None")
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		elseif updateInventory:InvokeServer("Item", {
			SelectedItem = equipFrame.ToolName.Text,
			Action = "Unstore"
		}) == "Unstore" then
			equipFrame.Visible = false
			equipFrame:SetAttribute("Current", "None")
			OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
		end
	end
end)
accessoryFrame.EquipFrame.Equip.Activated:Connect(function()
	if tick() - lastTime >= 0.1 then
		lastTime = tick()

		if accessory[accessoryFrame.ToolName.Text] then
			local v3 = updateInventory:InvokeServer("Accessory", {
				SelectedItem = accessoryFrame.ToolName.Text
			})

			if v3 == "Equip" then
				accessoryFrame.Visible = false
				accessoryFrame:SetAttribute("Current", "None")
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			elseif v3 == "Unequip" then
				accessoryFrame.Visible = false
				accessoryFrame:SetAttribute("Current", "None")
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		end
	end
end)
task.spawn(function()
	while localPlayer:GetAttribute("LoadedItem") == nil and localPlayer:GetAttribute("LoadedItem") ~= true do
		task.wait(1)
	end

	for _, child in ipairs(weapon2:GetChildren()) do
		child.Changed:Connect(function()
			if OpeningThisFrame() and select_Button.SelectedText.Text == "Weapon" or select_Button.SelectedText.Text == "อาวุธ" then
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		end)
	end

	for _, child in ipairs(accessory2:GetChildren()) do
		child.Changed:Connect(function()
			if OpeningThisFrame() and select_Button.SelectedText.Text == "Accessory" or select_Button.SelectedText.Text == "อุปกรณ์เสริม" then
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		end)
	end

	for _, child in ipairs(power2:GetChildren()) do
		child.Changed:Connect(function()
			if OpeningThisFrame() and select_Button.SelectedText.Text == "Power" or select_Button.SelectedText.Text == "พลังพิเศษ" then
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		end)
	end

	for _, child in ipairs(itemStorage:GetChildren()) do
		child.Changed:Connect(function()
			if OpeningThisFrame() and select_Button.SelectedText.Text == "Item" or select_Button.SelectedText.Text == "ไอเทม" then
				OnChanged(v2[select_Button.SelectedText.Text], select_Button.SelectedText.Text)
			end
		end)
	end
end)