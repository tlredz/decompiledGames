local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local _, v = Utility.GetData(Players.LocalPlayer, true)

local function slotOf(childName: string, childName2: string?)
	if v == nil then
		return nil
	end

	local settings = v:FindFirstChild("Settings")

	if settings == nil then
		return nil
	end

	local mobile = settings:FindFirstChild("Mobile")

	if mobile == nil then
		return nil
	end

	local child = mobile:FindFirstChild(childName)

	if child == nil or childName2 == nil then
		return child
	end

	return child:FindFirstChild(childName2)
end

return function(object, p: string, p2: string?, callback)
	local v2 = slotOf(p, p2)

	if v2 == nil then
		return false
	end

	local X = v2:FindFirstChild("X")
	local Y = v2:FindFirstChild("Y")

	if X == nil or Y == nil or not (X:IsA("ValueBase") and Y:IsA("ValueBase")) then
		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function push()
		callback(X.Value, Y.Value)
	end

	push() -- equivalent call inferred; original call site unknown
	object:Connect(X.Changed, push)
	object:Connect(Y.Changed, push)
	return true
end