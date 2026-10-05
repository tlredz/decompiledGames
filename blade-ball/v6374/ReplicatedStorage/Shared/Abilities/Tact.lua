local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Debris")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Players")
game:GetService("ServerScriptService")
game:GetService("ServerStorage")
require3(ReplicatedStorage2.Shared.ShockwaveEffect)
require3("@game/ReplicatedStorage/Types/Templates")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3(ReplicatedStorage2.Shared.SpeedModifiers)

if RunService:IsServer() then
	local v = {}

	function script.TactCollisionResponse.OnInvoke(instance, _, p)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return "Continue"
		end

		if v[p] then
			p.RemoveCurveModifier:Invoke(v[p])
			v[p] = nil
		end

		if instance:GetAttribute("IsTact") then
			v[p] = p.AddCurveModifier:Invoke(script.CurveModifier, 60)
		end

		return "Continue"
	end

	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		child.AddCustomCollisionResponse:Invoke(script.TactCollisionResponse, 60)
	end)
	workspace.Balls.ChildRemoved:Connect(function(child)
		v[child] = nil
	end)
end

return {
	iconId = "rbxassetid://15641266468",
	isPassive = true,
	equipped = function(p, p2)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function activate()
			p.character:SetAttribute("IsTact", true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function deactivate()
			p.character:SetAttribute("IsTact", false)
		end

		if not p.character:GetAttribute("PULSED") then
			activate() -- equivalent call inferred; original call site unknown
		end

		p2.addCleaner(function(p3)
			deactivate() -- equivalent call inferred; original call site unknown

			if p3 ~= "PULSE" then
				return
			end

			local pULSEDChangedConnection = nil
			pULSEDChangedConnection = p.character:GetAttributeChangedSignal("PULSED"):Connect(function()
				if p.character:GetAttribute("PULSED") then
					return
				end

				activate() -- equivalent call inferred; original call site unknown
				pULSEDChangedConnection:Disconnect()
			end)
		end)
	end
}