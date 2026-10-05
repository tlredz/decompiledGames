local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = nil
local ShopTelemetrySource = {}

function ShopTelemetrySource.Set(p: string?)
	v = p
end

function ShopTelemetrySource.Prefix(p: string)
	if v == nil then
		return p
	end

	return v .. ":" .. p
end

function ShopTelemetrySource.FrameworkInit() end

function ShopTelemetrySource.FrameworkStart()
	PanelController.OnPanelClosed:Connect(function(p: string, p2: string)
		if v == nil or not PanelController.IsInGroup("ShopFlow", p, p2) then
			return
		end

		task.defer(function()
			if #PanelController.GetOpenPanelsByGroup("ShopFlow") == 0 then
				v = nil
			end
		end)
	end)
end

return ShopTelemetrySource