local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
ReplicatedStorage:WaitForChild("Sound_Effect")
local colorAssets = guiTemplate:WaitForChild("ColorAssets")
local SetText = require(moduleScript:WaitForChild("SetText"))
local Aura_Color = require(moduleScript:WaitForChild("Aura_Color"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local playerData = localPlayer:WaitForChild("PlayerData", 60)
localPlayer:WaitForChild("PlayerSettings", 60)
localPlayer:WaitForChild("PlayerGui", 60)
local items = localPlayer:WaitForChild("Items", 60)
local cooldown = localPlayer:WaitForChild("Cooldown")
local auraColor = playerData:WaitForChild("AuraColor")
local auraColor2 = items:WaitForChild("AuraColor")
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local auraColor3 = otherEvent.ItemEvents:WaitForChild("AuraColor")
local parent = script.Parent
local parent2 = parent.Parent.Parent.Parent
local container = parent.Container
local auraColor_Template = colorAssets:WaitForChild("AuraColor_Template")
local rainbow_UIGradient = colorAssets:WaitForChild("Rainbow_UIGradient")
local list = Aura_Color.List
local connections = {}

local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function SetColor_State(equip, p: string)
	if p == "Equipped" then
		equip.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		equip.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		equip.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 240, 148)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 126, 93))
		})
		equip.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 74, 36)
	elseif p == "Locked" then
		equip.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		equip.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		equip.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(229, 92, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(163, 38, 38))
		})
		equip.Colours.Pattern.ImageColor3 = Color3.fromRGB(66, 26, 26)
	elseif p == "Equip" then
		equip.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		equip.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		equip.Textlabel.UIStroke.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 60, 141))
		})
		equip.Colours.Pattern.ImageColor3 = Color3.fromRGB(25, 30, 68)
	end
end

local GenerateColor

GenerateColor = function()
	for _, frame in ipairs(container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, childName in ipairs(list) do
		local clone = auraColor_Template:Clone()
		clone.Name = childName
		clone.Example.ImageColor3 = Aura_Color.ConvertColor[childName] or Color3.fromRGB(255, 255, 255)

		if localPlayer:GetAttribute("TH") then
			clone.Title.Text = `#{string.format("%0.3i", #container:GetChildren())} {Translate[childName]}`
		else
			clone.Title.Text = `#{string.format("%0.3i", #container:GetChildren())} {childName}`
		end

		if localPlayer:GetAttribute("TH") then
			clone.Description.Text = "ปลดล็อคโดยการสุ่มได้สีนี้จาก Npc."
		else
			clone.Description.Text = "Unlocked by rolling this color from the Npc."
		end

		if clone.Name == "Spectrum" then
			local uIGradient = clone.Example:FindFirstChild("UIGradient")

			if uIGradient and clone.Name == "Spectrum" then
				uIGradient:Destroy()
			end

			local clone_2 = rainbow_UIGradient:Clone()
			clone_2.Parent = clone.Example
		elseif clone.Name == "Default" then
			clone.Example.Visible = false
		end

		if auraColor2:FindFirstChild(childName) and auraColor2:FindFirstChild(childName).Value == true then
			if auraColor.Value ~= clone.Name then
				clone.EquipFrame.Equip.Textlabel.Text = not localPlayer:GetAttribute("TH") and "Equip" or Translate.Equip
			end

			if clone.Name == "Default" then
				if localPlayer:GetAttribute("TH") then
					clone.Description.Text = "สีนี้จะเปลี่ยนไปตามสีของอาวุธที่คุณใช้งานอยู่."
				else
					clone.Description.Text = "Based on the color of your equipped weapon."
				end
			elseif localPlayer:GetAttribute("TH") then
				clone.Description.Text = "[ปลดล็อคแล้ว]"
			else
				clone.Description.Text = "[Unlocked]"
			end
		else
			clone.EquipFrame.Equip.Textlabel.Text = not localPlayer:GetAttribute("TH") and "Locked" or Translate.Locked
			SetColor_State(clone.EquipFrame.Equip, "Locked")
		end

		if auraColor.Value == clone.Name then
			SetColor_State(clone.EquipFrame.Equip, "Equipped")

			if localPlayer:GetAttribute("TH") then
				clone.EquipFrame.Equip.Textlabel.Text = `{Translate.Equipped}`
			else
				clone.EquipFrame.Equip.Textlabel.Text = "Equipped"
			end
		end

		clone.Visible = true
		clone.Parent = container
		local v2 = childName
		connections[#connections + 1] = clone.EquipFrame.Equip.Activated:Connect(function()
			local child = auraColor2:FindFirstChild(clone.Name)

			if child and auraColor.Value ~= child.Name then
				if child.Value == true then
					if cooldown:FindFirstChild("ChangeColorCD") == nil then
						if auraColor3:InvokeServer(v2) == true then
							GenerateColor()
						end
					elseif localPlayer:GetAttribute("TH") then
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "โปรดรอสักครู่เพื่อเปลี่ยนสีออร่าของคุณอีกครั้ง.",
							MessageColor = "Red"
						})
					else
						SetText.SetText(localPlayer, "CustomMessage", {
							Message = "Please wait a few seconds to change your aura color again.",
							MessageColor = "Red"
						})
					end
				elseif localPlayer:GetAttribute("TH") then
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "คุณยังไม่ได้ปลดล็อคสีนี้!",
						MessageColor = "Red"
					})
				else
					SetText.SetText(localPlayer, "CustomMessage", {
						Message = "You haven't unlocked this color yet!",
						MessageColor = "Red"
					})
				end
			end
		end)
	end
end

for _, child in ipairs(auraColor2:GetChildren()) do
	child:GetPropertyChangedSignal("Value"):Connect(GenerateColor)
end

guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == "AuraColor" and action == "Refresh" then
		GenerateColor()
	end
end)