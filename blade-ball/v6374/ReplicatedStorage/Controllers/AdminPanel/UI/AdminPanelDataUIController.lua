local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.Statable)
local v = require3(ReplicatedStorage2.Packages.Charm)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
local v2 = require3(ReplicatedStorage2.Shared.DataViewer)
local v3 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local data = v3.AdminPanelUI.Window.Content.Pages.Data
return {
	Start = function(_)
		v3.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion

			local function requestLoadData()
				if not (replion:Get("Exists") and replion:Get("Inventory") and v3:HasPermission("Data.Read")) then
					return
				end

				local v4 = v3.UserTrove:Add(data.ScrollingFrame.Holder:Clone())
				v4.Parent = data.ScrollingFrame
				local v5 = v2.new(v4, {
					Data = replion:Get("Data"),
					Inventory = replion:Get("Inventory")
				}, {
					Readonly = not v3:HasPermission("Data.Write")
				})
				data.Filter.TextBox.PlaceholderText = "Search: name, value, Data.Path or key=value"
				v3.UserTrove:Add(v5.searchHandler.connectTo(data.Filter.TextBox))
				v3.UserTrove:Add(v.effect(function()
					v5.delta()
				end))
				v3.UserTrove:Add(function()
					v5.Destroy()
					v5 = nil
				end)
			end

			local function onLoad()
				if not data.Visible then
					data:GetPropertyChangedSignal("Visible"):Wait()
				end

				requestLoadData()
			end

			if replion:Get("Loaded") then
				v3.UserTrove:Add(task.spawn(onLoad))
				return
			end

			local v4 = nil
			v4 = v3.UserTrove:Add(replion:OnChange("Loaded", function()
				if v4 then
					v3.UserTrove:Remove(v4)
				end

				v3.UserTrove:Add(task.spawn(onLoad))
			end))
		end)
	end
}