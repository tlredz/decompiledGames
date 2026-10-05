local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

repeat
	task.wait(1)
until game:IsLoaded()

local localPlayer = game.Players.LocalPlayer

local function OnChanged()
	for _, screenGui in pairs(CollectionService:GetTagged("SelectedGui")) do
		if not screenGui:IsA("ScreenGui") then
			continue
		end

		if localPlayer:GetAttribute("TeamSelected") == nil then
			screenGui.Enabled = false
		elseif localPlayer:GetAttribute("TeamSelected") then
			screenGui.Enabled = true
		else
			screenGui.Enabled = false
		end
	end

	for _, screenGui in ipairs(script.Parent:GetChildren()) do
		if not screenGui:IsA("ScreenGui") then
			continue
		end

		if UserInputService.TouchEnabled and localPlayer:GetAttribute("TeamSelected") then
			screenGui.Enabled = true
		elseif UserInputService.TouchEnabled and localPlayer:GetAttribute("TeamSelected") == nil then
			screenGui.Enabled = false
		end
	end
end

OnChanged()
localPlayer:GetAttributeChangedSignal("TeamSelected"):Connect(function()
	local lastTime = tick()

	repeat
		task.wait(0.1)
	until tick() - lastTime >= 1

	OnChanged()
end)