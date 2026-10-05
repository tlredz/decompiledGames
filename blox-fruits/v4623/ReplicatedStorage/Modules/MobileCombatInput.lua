local Players = game:GetService("Players")
local Global = require(game.ReplicatedStorage.Global)
local object = setmetatable({}, {
	__mode = "k"
})
local MobileCombatInput = {}

function MobileCombatInput.isGuiTouch(p)
	if p.UserInputType ~= Enum.UserInputType.Touch then
		return false
	end

	local v = object[p]

	if v ~= nil then
		return v
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		local position = p.Position

		for _, button in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
			if not button:IsA("GuiButton") then
				continue
			end

			object[p] = true
			return true
		end
	end

	object[p] = false
	return false
end

function MobileCombatInput.isM1Blocked()
	return Global.busy and true or false or Global.mobileSelection ~= nil and Global.mobileSelection ~= "G" or Global.mobileSoru == true or (Global.tapCooldown or 0) > os.clock()
end

return MobileCombatInput