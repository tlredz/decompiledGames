local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HudHideCore = require(script.Parent.HudHideCore)
local v = { Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat }
local v2 = HudHideCore.new()
local v3 = {}
local v4 = {}

local function hideNow(p)
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		for _, screenGui in ipairs(playerGui:GetChildren()) do
			if not (screenGui:IsA("ScreenGui") and HudHideCore.shouldHide(screenGui.Name, screenGui.Enabled, p)) then
				continue
			end

			screenGui.Enabled = false
			HudHideCore.recordHidden(v2, screenGui)
			local v5 = screenGui
			v3[screenGui] = screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
				if v5.Enabled then
					HudHideCore.noteExternalShow(v2, v5)
				end
			end)
		end
	end

	for _, v5 in ipairs(v) do
		local success, coreGuiEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, v5)

		if success and coreGuiEnabled and pcall(StarterGui.SetCoreGuiEnabled, StarterGui, v5, false) then
			table.insert(v4, v5)
		end
	end
end

local function restoreNow()
	for k, connection in pairs(v3) do
		connection:Disconnect()
		v3[k] = nil
	end

	local v5 = HudHideCore.takeRestoreList(v2, function(instance)
		if instance.Parent == nil then
			return nil
		end

		return instance.Enabled
	end)

	for _, v6 in ipairs(v5) do
		v6.Enabled = true
	end

	for _, v6 in ipairs(v4) do
		local success, coreGuiEnabled = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, v6)

		if not success or coreGuiEnabled then
			continue
		end

		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, v6, true)
	end

	table.clear(v4)
end

local HudHide = {}

function HudHide.hide(p, p2)
	local claim, v5 = HudHideCore.claim(v2, p)

	if v5 then
		local success, result = pcall(hideNow, p2 and p2.keep)

		if not success then
			warn("[HudHide] hide failed: " .. tostring(result))
		end
	end

	return {
		release = function()
			if HudHideCore.release(v2, claim) then
				local success, result = pcall(restoreNow)

				if not success then
					warn("[HudHide] restore failed: " .. tostring(result))
				end
			end
		end
	}
end

function HudHide.releaseOwner(p)
	if HudHideCore.releaseOwner(v2, p) then
		local success, result = pcall(restoreNow)

		if not success then
			warn("[HudHide] restore failed: " .. tostring(result))
		end
	end
end

function HudHide.isHidden()
	return HudHideCore.isHiding(v2)
end

return HudHide