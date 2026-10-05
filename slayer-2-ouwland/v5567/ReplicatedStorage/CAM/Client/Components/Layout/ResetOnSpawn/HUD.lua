local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local visibility = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Layout"):WaitForChild("Visibility")

if localPlayer:FindFirstChild("Items_Config") == nil then
	local folder = Instance.new("Folder")
	local intValue = Instance.new("IntValue")
	intValue.Parent = folder
	intValue.Name = "Equipped"
	folder.Name = "Items_Config"
	folder.Parent = localPlayer
end

local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local hiddenOn = {
	Mobile = true
}
local onlyOn = {
	Mobile = true
}
local v9 = {
	{
		Name = "CenterBottomContent",
		Module = require(script:WaitForChild("CenterBottomContent"))
	},
	{
		Name = "HudBottomRight",
		Module = require(script.HudBottomRight),
		HiddenOn = hiddenOn
	},
	{
		Name = "HudBottomLeft",
		Module = require(script.HudBottomLeft),
		HiddenOn = hiddenOn
	},
	{
		Name = "HudTopLeft",
		Module = require(script.HudTopLeft),
		OnlyOn = onlyOn
	},
	{
		Name = "HudTopRight",
		Module = require(script.HudTopRight),
		OnlyOn = onlyOn
	},
	{
		Name = "AimDot",
		Module = require(script.AimDot),
		OnlyOn = {
			Xbox = true,
			Playstation = true
		}
	}
}
local names = { "HUD" }

for _, v10 in pairs(v9) do
	table.insert(names, v10.Name)
end

return function(p)
	for _, v10 in pairs(v9) do
		v10.Visibility = nil
	end

	local v10 = faye.new()

	local function Update()
		for _, v11 in pairs(v9) do
			local visibility2 = visibility.HUD.Value

			if v11.OnlyOn ~= nil and not v11.OnlyOn[Platform_Handler.Platform.Value] then
				visibility2 = false
			end

			if v11.HiddenOn ~= nil and v11.HiddenOn[Platform_Handler.Platform.Value] then
				visibility2 = false
			end

			if v11.Visibility == visibility2 then
				continue
			end

			v11.Visibility = visibility2

			if visibility2 == true then
				v11.Thread = v10:Extend()
				v11.Module(v11.Thread, p)
			elseif v11.Thread ~= nil then
				v11.Thread:Destroy()
				v11.Thread = nil
			end
		end
	end

	for _, childName in pairs(names) do
		local child = visibility:FindFirstChild(childName)

		if child ~= nil then
			v10:Connect(child.Changed, Update)
		end
	end

	v10:Connect(Platform_Handler.Platform.Changed.Event, Update)
	Update()
	return function()
		v10:Destroy()
	end
end