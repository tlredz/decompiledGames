local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfileLookup = require(ReplicatedStorage.Controllers.UI.PlayerProfileLookup)

while not PlayerProfileLookup.IsInitialized do
	task.wait()
end

assert(PlayerProfileLookup.IsInitialized, "bad profile lookup")
local v = nil
local v2 = false
local exclamationMark = script.Parent:WaitForChild("ExclamationMark")

-- equivalent calls inferred from this helper; original call sites unknown
local function setOpenedState(flag: boolean)
	script.Parent.Glow.ImageTransparency = flag and 0.6 or 0.22
end

script.Parent.MouseButton1Click:Connect(function()
	if v2 or PlayerProfileLookup:IsOpen() then
		v2 = false
		PlayerProfileLookup:Close()
	else
		if not v2 then
			local Global = require(game.ReplicatedStorage.Global)

			if not Global.getProfileOpen() then
				local AnalyticsUtil = require(game.ReplicatedStorage.Util.AnalyticsUtil)
				AnalyticsUtil.reportActivity("HUD/Button/PlayerProfile")
				setOpenedState(true) -- equivalent call inferred; original call site unknown
				PlayerProfileLookup:Open(true)
				v2 = true

				repeat
					task.wait()
				until not PlayerProfileLookup:IsOpen()

				v2 = false
				return
			end
		end

		v2 = false
		local Global = require(game.ReplicatedStorage.Global)
		Global.closePlayerProfile()
	end
end)
task.spawn(function()
	while true do
		task.wait(1)
		local v3 = ReplicatedStorage.Remotes.GetPlayerProfileOpened:InvokeServer()

		if v3 ~= nil and v ~= v3 then
			v = v3
			setOpenedState(v3) -- equivalent call inferred; original call site unknown
		end

		local _, _, v4 = ReplicatedStorage.Remotes.GetProfileBackgroundList:InvokeServer()
		exclamationMark.Visible = typeof(v4) == "table" and next(v4) ~= nil
	end
end)