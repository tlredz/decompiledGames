local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local humanoid = character:WaitForChild("Humanoid")
character:WaitForChild("HumanoidRootPart")
local v = {
	"RagDoll",
	"ragdoll",
	"Ragdoll",
	"ragDoll"
}
local v2 = { "noragdoll" }

function check_can_ragdoll()
	return humanoid == nil or humanoid.HumanoidState ~= Enum.HumanoidStateType.Dead
end

humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
local child = game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(localPlayer.Name)
local v3 = { Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.PlatformStanding }
local v4 = false
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))

function updvalues()
	if child ~= nil then
		local v5 = false

		for _, childName in pairs(v) do
			if child:FindFirstChild(childName) ~= nil then
				v5 = true
			end
		end

		for _, childName in pairs(v2) do
			if child:FindFirstChild(childName) ~= nil then
				v5 = false
			end
		end

		local swimState = character:GetAttribute("SwimState")

		if typeof(swimState) == "number" and swimState > 0 then
			v5 = false
		end

		if humanoid ~= nil and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			if v5 == true then
				if v4 == false then
					v4 = true

					for _, v6 in pairs(v3) do
						humanoid:SetStateEnabled(v6, false)
					end

					humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			elseif v4 == true then
				v4 = false
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "novelocity"
				boolValue.Parent = child
				DebrisModule:AddItem(boolValue, 0.2)

				for _, v6 in pairs(v3) do
					humanoid:SetStateEnabled(v6, true)
				end

				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end
	end
end

updvalues()
character:GetAttributeChangedSignal("SwimState"):Connect(updvalues)
child.ChildAdded:Connect(function(child2)
	local v5 = table.find(v, child2.Name) ~= nil

	if (table.find(v2, child2.Name) ~= nil or v5) == true then
		updvalues()
	end
end)
child.ChildRemoved:Connect(function(child2)
	local v5 = table.find(v, child2.Name) ~= nil

	if (table.find(v2, child2.Name) ~= nil or v5) == true then
		updvalues()
	end
end)