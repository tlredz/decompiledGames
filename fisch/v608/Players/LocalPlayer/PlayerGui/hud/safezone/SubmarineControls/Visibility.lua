local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local v = nil

local function update()
	if UserInputService.PreferredInput ~= Enum.PreferredInput.Touch then
		script.Parent.Visible = false
		return
	end

	if not (v and v:FindFirstChild("Humanoid") and v.Humanoid.SeatPart) then
		script.Parent.Visible = false
		return
	end

	local seatPart = v.Humanoid.SeatPart
	local parent = script.Parent
	local visible

	if Players.LocalPlayer:GetAttribute("FlyingLocal") == true then
		visible = true
	else
		local isSubmarine = seatPart and seatPart.Parent and (seatPart.Parent:GetAttribute("IsSubmarine") or seatPart.Parent:HasTag("FlyingBoat"))
		visible = isSubmarine and true or false
	end

	parent.Visible = visible
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)
Players.LocalPlayer:GetAttributeChangedSignal("FlyingLocal"):Connect(update)
update()
local Observers = require(ReplicatedStorage.packages.Observers)
Observers.observeCharacter(Players.LocalPlayer, function(_, instance)
	v = instance
	local humanoid = instance:WaitForChild("Humanoid")
	update()
	humanoid.Seated:Connect(update)
	humanoid:GetPropertyChangedSignal("SeatPart"):Connect(update)
	return function() end
end)