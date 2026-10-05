local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled ~= true then
	script.Enabled = false
	return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService2 = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
localPlayer:GetMouse()
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local skillEvents = otherEvent:WaitForChild("SkillEvents")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
local cooldown = localPlayer:WaitForChild("Cooldown", 60)
local mobile_Skills = skillEvents:WaitForChild("Mobile_Skills")
local freeMoney = secretEvents:WaitForChild("FreeMoney")
local Generate = require(moduleScript:WaitForChild("Generate"))
local parent = script.Parent.Parent
local v = nil
local _ = script.Parent.Parent.Name
local buttons = {}
local name = nil
local v2 = nil
local uIStroke = parent.Item_Name:FindFirstChild("UIStroke")

if uIStroke then
	uIStroke.Enabled = false
end

for _, button in ipairs(CollectionService:GetTagged("MobileButton")) do
	if not button:IsA("GuiButton") or not button:IsDescendantOf(script.Parent) or table.find(buttons, button) then
		continue
	end

	table.insert(buttons, button)
end

local function Reset_Buttons()
	for _, button in ipairs(buttons) do
		if not (button:IsA("GuiButton") and button.BackgroundTransparency ~= 1) then
			continue
		end

		button.BackgroundTransparency = 1
		break
	end
end

for _, v3 in ipairs(buttons) do
	local v4 = v3
	v3.Activated:Connect(function()
		v = 0

		if v == 0 and name ~= v4.Name then
			if name and v2 and cooldown:FindFirstChild((`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}`)) == nil and cooldown:FindFirstChild((`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}_Holding`)) then
				_G.MobileMouseUpdate(localPlayer)
				mobile_Skills:Fire("End", name, v2)
				name = nil
				v2 = nil
				freeMoney:FireServer("Mobile_Button", nil)
			end

			Reset_Buttons()
			v = 1
			name = v4.Name
			v2 = v4
			v4.BackgroundTransparency = 0.75
			freeMoney:FireServer("Mobile_Button", true)
		elseif v == 0 and name == v4.Name then
			if name and v2 and cooldown:FindFirstChild((`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}`)) == nil and cooldown:FindFirstChild((`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}_Holding`)) then
				_G.MobileMouseUpdate(localPlayer)
				mobile_Skills:Fire("End", name, v2)
				name = nil
				v2 = nil
				freeMoney:FireServer("Mobile_Button", nil)
			end

			Reset_Buttons()
			v = 1
			name = nil
			v2 = nil
			v4.BackgroundTransparency = 1
			freeMoney:FireServer("Mobile_Button", nil)
		end
	end)
	local v5 = v3
	v3:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
		if name == v5.Name and v2 and v5.BackgroundTransparency == 1 then
			name = nil
			v2 = nil
		end
	end)
end

UserInputService2.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.Begin and name and v2 and cooldown:FindFirstChild((`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}`)) == nil then
		mobile_Skills:Fire("Begin", name, v2)
	end
end)
UserInputService2.InputEnded:Connect(function(input, gameProcessed)
	if not gameProcessed and input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.End and name and v2 and cooldown:FindFirstChild((`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}`)) == nil and cooldown:WaitForChild(
		`{Generate.Check_Type(parent:GetAttribute("Tool"))}_{name}_Holding`,
		1
	) then
		_G.MobileMouseUpdate(localPlayer)
		mobile_Skills:Fire("End", name, v2)
		name = nil
		v2 = nil
		freeMoney:FireServer("Mobile_Button", nil)
	end
end)
parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not parent.Enabled then
		Reset_Buttons()
		name = nil
		v2 = nil
		freeMoney:FireServer("Mobile_Button", nil)
	end
end)