local NetworkClient = game:GetService("NetworkClient")
local module = require("@game/ReplicatedStorage/Omni")
local autoRejoin = module.Interface:WaitForChild("HUD"):WaitForChild("AutoRejoin")
local count = 0
local flag = true
local flag2 = false
local AntiAfk = {
	IsEnabled = function()
		return module.Data.Settings["Anti Afk"] == true
	end,
	Reconnect = function()
		module.AutoRoll.Hold()
		module.Signal:Fire("General", "AntiAfk", "Reconnect")
	end
}

function AntiAfk.Refresh()
	if count > 10 and AntiAfk.IsEnabled() then
		local v = math.max(0, 900 - count)
		autoRejoin.Text = "Auto Rejoin in " .. module.Utils.Number:Time2(v)

		if v == 0 then
			AntiAfk.Reconnect()
		end
	else
		autoRejoin.Text = ""
	end
end

module.Services.UserInputService.InputBegan:Connect(function()
	count = 0
	flag = false
	AntiAfk.Refresh()
end)
module.Services.UserInputService.InputEnded:Connect(function()
	flag = true
	AntiAfk.Refresh()
end)
module.Instance.Idled:Connect(function(p: number)
	if flag2 or not AntiAfk.IsEnabled() or p < 900 then
		return
	end

	flag2 = true

	while true do
		AntiAfk.Reconnect()
		task.wait(1)
	end
end)
NetworkClient.ChildRemoved:Connect(function()
	if not AntiAfk.IsEnabled() or flag2 then
		return
	end

	flag2 = true
	module.AutoRoll.Hold()

	while true do
		pcall(function()
			module.Services.TeleportService:Teleport(game.PlaceId, module.Instance)
		end)
		task.wait(15)
	end
end)
module:OnDataChanged({ "Settings", "Anti Afk" }, AntiAfk.Refresh)
task.spawn(function()
	while task.wait(1) do
		if not flag then
			continue
		end

		count += 1
		AntiAfk.Refresh()
	end
end)
return AntiAfk