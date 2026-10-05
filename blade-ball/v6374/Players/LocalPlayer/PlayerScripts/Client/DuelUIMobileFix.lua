local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local DeviceListener = require(ReplicatedStorage2.ClientGameModules.DeviceListener)
local playerGui = Players.LocalPlayer.PlayerGui
local duelUI = playerGui:WaitForChild("DuelUI")
local duelUI_Mobile = playerGui:WaitForChild("DuelUI_Mobile")

local function onDeviceChanged(_)
	local uDim = UDim2.fromScale(0.5, 0)
	local guiInset = GuiService:GetGuiInset()
	local uDim2

	if DeviceListener:IsMobile() then
		uDim2 = UDim2.fromOffset(0, guiInset.Y)
	else
		uDim2 = UDim2.fromOffset(0, 0)
	end

	duelUI.RoundTimer.Position = uDim + uDim2
	duelUI.DuelsHUD.Position = uDim + uDim2
	duelUI_Mobile.DuelsHUD.Position = uDim + uDim2
end

DeviceListener:Observe(onDeviceChanged)
local v = {}
local check

check = function(guiObject, instance)
	if not guiObject:IsA("GuiObject") then
		return
	end

	local child = instance:FindFirstChild(guiObject.Name)

	if not child then
		return
	end

	v[child] = {
		Default = {
			AnchorPoint = child.AnchorPoint,
			Position = child.Position,
			Size = child.Size
		},
		Mobile = {
			AnchorPoint = guiObject.AnchorPoint,
			Position = guiObject.Position,
			Size = guiObject.Size
		}
	}

	for _, child2 in guiObject:GetChildren() do
		check(child2, child)
	end
end

for _, child in duelUI_Mobile:GetChildren() do
	check(child, duelUI)
end

local v2 = nil
UserInputService.LastInputTypeChanged:Connect(function(p)
	local v3 = p == Enum.UserInputType.Touch

	if v3 == v2 then
		return
	end

	v2 = v3

	for k, v4 in v do
		local v6 = v4[v3 and "Mobile" or "Default"]
		local v7 = k
		pcall(function()
			for k2, v8 in v6 do
				v7[k2] = v8
			end
		end)
	end
end)