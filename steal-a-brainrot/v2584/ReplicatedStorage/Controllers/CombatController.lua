local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local CharacterController = require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local remoteEvent = Net:RemoteEvent("CombatService/ApplyImpulse")
local CombatController = {
	ApplyImpulse = function(self, p: number, vector: Vector3)
		local character, v, v2 = CharacterController:GetCharacter()

		if not (character and v and v2) then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function canApplyImpulse()
			return not v2.Anchored and not v2:GetAttribute("NetworkOwnerSet")
		end

		local v3 = os.clock() + 1

		while true do
			local v4 = canApplyImpulse() -- equivalent call inferred; original call site unknown

			if v4 or not (os.clock() < v3) then
				v2:ApplyImpulse(vector * p)
				break
			else
				task.wait()
			end
		end
	end
}

function CombatController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(...)
		CombatController:ApplyImpulse(...)
	end)
end

return CombatController