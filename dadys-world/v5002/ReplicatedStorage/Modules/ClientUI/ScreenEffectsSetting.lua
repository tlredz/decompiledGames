local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage.Modules.ClientUI.MyDataController)
local ScreenEffectsCore = require(ReplicatedStorage.Modules.Gameplay.ScreenEffectsCore)
local v = { "Settings", "ScreenEffects" }
local ScreenEffectsSetting = {}
local v2 = {}
local flag = false

function ScreenEffectsSetting.level()
	return ScreenEffectsCore.resolve(MyDataController:getDataFromPath("Settings.ScreenEffects"))
end

function ScreenEffectsSetting.profile()
	return ScreenEffectsCore.profile(MyDataController:getDataFromPath("Settings.ScreenEffects"))
end

local function fire()
	for _, callback in ipairs(v2) do
		local success, result = pcall(callback)

		if not success then
			warn("[ScreenEffectsSetting] listener failed:", result)
		end
	end
end

function ScreenEffectsSetting.onChanged(callback)
	table.insert(v2, callback)

	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v3 = MyDataController:waitForReplica()

		if not v3 then
			return
		end

		v3:ListenToChange(v, function()
			print("[ScreenEffectsSetting] level is now", ScreenEffectsSetting.level())
			fire()
		end)
		fire()
	end)
end

return ScreenEffectsSetting