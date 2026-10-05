local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Shared.DynArgs)
local v2 = require3(ReplicatedStorage2.Shared.Statable)
local UIStateController = {
	IsUICovered = v.Or(),
	IsUICoveredState = v2.State(),
	HideHotbar = v.Or(),
	HideHotbarState = v2.State()
}
UIStateController.IsUICovered:LinkState(UIStateController.IsUICoveredState)
UIStateController.HideHotbar:LinkState(UIStateController.HideHotbarState)
v2.setPropertyComputed(playerGui:WaitForChild("Hotbar"), "Enabled", function(callback)
	return not callback(UIStateController.HideHotbarState)
end)
return UIStateController