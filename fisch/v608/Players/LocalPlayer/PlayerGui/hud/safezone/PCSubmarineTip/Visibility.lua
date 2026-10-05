local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local v = nil
local parent = script.Parent
local ascendLabel = parent:WaitForChild("AscendLabel")
local descendLabel = parent:WaitForChild("DescendLabel")

local function update()
	if not (v and v:FindFirstChild("Humanoid") and v.Humanoid.SeatPart) then
		parent.Visible = false
		return
	end

	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		ascendLabel.Text = "E to Ascend"
		descendLabel.Text = "Q to Descend"
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		ascendLabel.Text = "RB to Ascend"
		descendLabel.Text = "LB to Descend"
	elseif preferredInput == Enum.PreferredInput.Touch then
		parent.Visible = false
		return
	end

	local seatPart = v.Humanoid.SeatPart
	parent.Visible = seatPart and seatPart:IsA("VehicleSeat") and seatPart.Parent and (seatPart.Parent:GetAttribute("IsSubmarine") or seatPart.Parent:GetAttribute("FlyingBoat")) and true or false
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)
update()
local Observers = require(ReplicatedStorage.packages.Observers)
Observers.observeCharacter(Players.LocalPlayer, function(_, instance)
	v = instance
	local humanoid = instance:WaitForChild("Humanoid")
	update()
	humanoid:GetPropertyChangedSignal("SeatPart"):Connect(update)
	humanoid.Seated:Connect(update)
	return function() end
end)