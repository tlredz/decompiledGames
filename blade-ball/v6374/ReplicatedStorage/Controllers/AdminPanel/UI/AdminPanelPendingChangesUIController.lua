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
require3(ReplicatedStorage2.Packages.Charm)
require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Action)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Controllers.Trading.IndexController)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
local v = require3(ReplicatedStorage2.Shared.DataViewer)
require3(ReplicatedStorage2.Shared.DeepCopy)
local v2 = require3(ReplicatedStorage2.Shared.AdminPanel.AdminPanelUtils)
local v3 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local pendingChanges = v3.AdminPanelUI.Window.Content.Pages.PendingChanges
return {
	Start = function(_)
		v3.LoadUserAction.Signal:Connect(function(p)
			local replion = p.Replion

			local function onLoad()
				if not (replion:Get("Exists") and replion:Get("Inventory")) then
					return
				end

				local maid = v3.UserTrove:Extend()

				local function updatePage()
					maid:Clean()

					if pendingChanges.Visible then
						local v4 = maid:Add(pendingChanges.ScrollingFrame.Holder:Clone())
						v4.Parent = pendingChanges.ScrollingFrame
						local v5 = v.new(v4, {
							Data = v2.calculateDeltaTables(replion:Get("Data"), replion:Get("InitialData"), v.NIL_KEY),
							Inventory = v2.calculateDeltaTables(
								replion:Get("Inventory"),
								replion:Get("InitialInventory"),
								v.NIL_KEY
							)
						}, {
							Readonly = true
						})
						maid:Add(function()
							v5.property().ParentFrame(nil)
							v5 = nil
						end)
					end
				end

				v3.UserTrove:Add(pendingChanges:GetPropertyChangedSignal("Visible"):Connect(updatePage))
				v3.UserTrove:Add(replion:OnChange("Data", updatePage))
				v3.UserTrove:Add(replion:OnChange("Inventory", updatePage))
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