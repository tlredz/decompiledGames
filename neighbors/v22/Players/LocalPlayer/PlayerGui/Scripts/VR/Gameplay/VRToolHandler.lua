local character = game.Players.LocalPlayer.Character
local VRService = game:GetService("VRService")
local VR = require(game.ReplicatedStorage.Modules.VR)
local tool = character:FindFirstChildOfClass("Tool")
local v = 0

local function does_hand_exceed_force(p, value)
	if value == nil then
		return true
	end

	if not VRService:GetUserCFrame(p) then
		return false
	end

	local handVelocity = VR:GetHandVelocity(p)
	local relativeVectorToHead = VR:GetRelativeVectorToHead(handVelocity)

	if typeof(value) == "Vector3" then
		return value.unit:Dot(relativeVectorToHead) > value.Magnitude
	end

	if typeof(value) == "number" then
		return value < handVelocity.Magnitude
	end
end

character.ChildAdded:connect(function(tool2)
	if tool2:IsA("Tool") then
		tool = tool2
	end
end)
character.ChildRemoved:connect(function(tool2)
	if tool2:IsA("Tool") and tool == tool2 then
		tool = nil
	end
end)
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(_)
	local now = os.clock()

	if now - v > 0.35 and tool and tool:FindFirstChild("VRForceEvent") then
		local vRForceEvent = tool.VRForceEvent
		local rightForce = vRForceEvent:GetAttribute("RightForce")
		local leftForce = vRForceEvent:GetAttribute("LeftForce")

		if (rightForce or leftForce) and does_hand_exceed_force(Enum.UserCFrame.RightHand, rightForce) and does_hand_exceed_force(
			Enum.UserCFrame.LeftHand,
			leftForce
		) then
			v = now
			vRForceEvent:FireServer()
		end
	end
end)