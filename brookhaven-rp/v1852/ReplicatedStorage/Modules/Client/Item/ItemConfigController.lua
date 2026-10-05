local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteConfigItemLoader = require(ReplicatedStorage.Modules.Shared.Item.RemoteConfigItemLoader)
local Logger = require(ReplicatedStorage.Packages.Logger)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ItemConfigController = {
	FrameworkInit = function() end
}

function ItemConfigController.FrameworkStart()
	ItemConfigController.Load()
	Remotes.connect("RefreshDatabase", function()
		ItemConfigController.Load()
	end)
end

function ItemConfigController.Load()
	local success, result = pcall(RemoteConfigItemLoader.Load)
	local flag = true

	while not success do
		if flag then
			task.wait(1)
			flag = false
		else
			Logger.warn("Retrying item registry:", result)
			task.wait(1)
		end

		success, result = pcall(RemoteConfigItemLoader.Load)
	end
end

return ItemConfigController