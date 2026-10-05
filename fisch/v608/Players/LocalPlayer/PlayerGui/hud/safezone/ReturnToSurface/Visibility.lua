local WorldController = require(game.ReplicatedStorage.client.legacyControllers.WorldController)

if WorldController:GetCurrentWorldIndex() == "Sea 2" then
	script.Parent.Visible = false
	return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = nil

local function update()
	if v and v:FindFirstChild("Humanoid") and v.Humanoid.SeatPart then
		local seatPart = v.Humanoid.SeatPart
		script.Parent.Visible = seatPart and seatPart:IsA("VehicleSeat") and seatPart.Parent and seatPart.Parent:GetAttribute("IsSubmarine") and true or false
	else
		script.Parent.Visible = false
	end
end

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