local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
game:GetService("GuiService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local Statable = require(ReplicatedStorage.Shared.Statable)
local state = Statable.State("PS")
local v = {
	XBOX = script:WaitForChild("XBOX", 1000000),
	PS = script:WaitForChild("PS", 1000000)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateConsoleType()
	if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonB) == "ButtonCircle" then
		state:Set("PS")
	else
		state:Set("XBOX")
	end
end

UserInputService.GamepadConnected:Connect(updateConsoleType)
UserInputService.GamepadDisconnected:Connect(updateConsoleType)
updateConsoleType() -- equivalent call inferred; original call site unknown
return Observers.observeTagNoAncestry("UI_GamepadIcon", function(p)
	local maid = Utils.Maid.new()
	maid.propertyComputed = Statable.setPropertyComputed(p, "Image", function(callback)
		local child = v[callback(state)]:FindFirstChild(callback((Statable.getAttributeState(p, "KeyCode"))) or "")

		if child then
			return child.Image
		end

		return "rbxassetid://6034407076"
	end)
	return function()
		maid:Destroy()
	end
end)