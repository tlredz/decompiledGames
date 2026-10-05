local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Packages.Charm)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.Shared.StatableCleaner)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.DataViewer)
local v3 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local trading = v3.AdminPanelUI.Window.Content.Pages.Trading
return {
	Start = function(_)
		v3.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion
			local maid = v3.UserTrove:Extend()

			local function onLoad()
				local maid2 = maid:Add(v2.new())
				local v4 = maid2:Add(v.State("TradeHistory"))
				maid2:Add(v.Computed(function(callback)
					local v5 = callback(v4)

					for _, guiObject in trading.Tabs:GetChildren() do
						if not guiObject:IsA("GuiObject") then
							continue
						end

						local backgroundColor

						if guiObject.Name == v5 then
							backgroundColor = Color3.fromRGB(33, 107, 226)
						else
							backgroundColor = Color3.fromRGB(74, 74, 74)
						end

						guiObject.BackgroundColor3 = backgroundColor
					end

					for _, guiObject in trading.Pages:GetChildren() do
						if guiObject:IsA("GuiObject") then
							guiObject.Visible = guiObject.Name == v5
						end
					end

					return nil
				end))

				for _, button in trading.Tabs:GetChildren() do
					if not button:IsA("GuiButton") then
						continue
					end

					local v5 = button
					maid:Add(button.Activated:Connect(function()
						v4:Set(v5.Name)
					end))
				end
			end

			if replion:Get("Loaded") then
				maid:Add(task.spawn(onLoad))
			else
				maid:Add(replion:OnChange("Loaded", onLoad))
			end
		end)
	end
}