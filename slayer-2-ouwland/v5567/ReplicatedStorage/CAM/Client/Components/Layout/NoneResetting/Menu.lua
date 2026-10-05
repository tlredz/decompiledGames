local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local MenuConfig = require(script.MenuConfig)
MenuConfig.InitiateDestination()
local GuiService = game:GetService("GuiService")
local menu = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Layout"):WaitForChild("Visibility"):WaitForChild("Menu")
local pages = {
	Inventory = require(script.Pages.Inventory)
}
local SkillTree = require(script.Pages["Skill Tree"])
pages["Skill Tree"] = SkillTree
pages.Shop = require(script.Pages.Shop)
local Progression = require(script.Pages.Progression)
pages["Player Info / Progression"] = Progression
pages.Faction = require(script.Pages.Faction)
pages.Titles = require(script.Pages.Titles)
pages.Archives = require(script.Pages.Archives)
pages.Settings = require(script.Pages.Settings)
pages.Servers = require(script.Pages.Servers)
local Sidebar = require(script.Sidebar)
InputHandler.ListenTo("Menu", function(p, p2)
	if p ~= "Down" or p2 then
		return
	end

	MenuConfig.Toggle()
end)
InputHandler.ListenTo("Menu_Close", function(p, p2)
	if p ~= "Down" or p2 or not Platform_Handler.IsGamepad() or MenuConfig.InitiateDestination().Value == "" then
		return
	end

	MenuConfig.Toggle()
end)
return function(parent)
	local v2 = faye.new()
	local instancePropertySync = v2:InstancePropertySync(localPlayer.MenuDestination, "Value")
	local maid = nil

	local function updateEnabled(value)
		if maid ~= nil then
			maid:Destroy()
			maid = nil
		end

		if value == true then
			maid = v2:Extend()
			local Y = GuiService:GetGuiInset().Y
			maid:Create("Frame")({
				Name = "Background",
				ZIndex = -1,
				Parent = parent,
				function(p2)
					if not Platform_Handler.IsGamepad() then
						return
					end

					local gamepadCursorEnabled = GamepadService.GamepadCursorEnabled
					local v3 = true
					GamepadService:EnableGamepadCursor(p2)
					maid:Connect(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"), function()
						if v3 and not GamepadService.GamepadCursorEnabled then
							GamepadService:EnableGamepadCursor(p2)
						end
					end)
					maid:Add(function()
						v3 = false

						if not gamepadCursorEnabled then
							GamepadService:DisableGamepadCursor()
						end
					end)
				end,
				Size = UDim2.new(1, 0, 1, Y),
				Position = UDim2.new(0, 0, 0, -Y),
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = maid:Animation(0.1, maid.Info(0.25), {
					From = 1
				}),
				maid:Create("BlurEffect")({
					Parent = workspace.CurrentCamera,
					Size = maid:Animation(20, maid.Info(0.25), {
						From = 0
					}),
					CleanFunction = function(object, p2)
						object:Configure(p2)({
							Size = object:Animation(0, object.Info(0.25))
						})
					end
				}),
				OnClean = function(object, p2)
					object:Configure(p2)({
						BackgroundTransparency = object:Animation(1, object.Info(0.25))
					})
				end,
				Sidebar(maid, instancePropertySync),
				maid:Create("Frame")({
					Size = maid:Animation(UDim2.new(0.88, -5, 1, -5), maid.SpringInfo(0.45, 1, 0.65), {
						From = UDim2.new(1, -35, 1, -35)
					}),
					Position = UDim2.new(0.56, 0, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					CleanFunction = function(object, p2)
						object:Configure(p2)({
							Size = object:Animation(UDim2.fromScale(), object.Info(0.25))
						})
					end,
					maid:State(function(callback, p2, _)
						local v4 = pages[callback(instancePropertySync)]

						if v4 == nil then
							return
						else
							return v4(p2, parent)
						end
					end)
				})
			})
		end
	end

	v2:Connect(menu.Changed, updateEnabled)
	updateEnabled(menu.Value)
	return function()
		v2:Destroy()
	end
end