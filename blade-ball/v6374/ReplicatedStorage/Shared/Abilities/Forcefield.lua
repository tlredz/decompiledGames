local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
require3("@game/ReplicatedStorage/Types/Templates")
local v = {}

if RunService:IsServer() then
	function script.ForcefieldCollisionResponse.OnInvoke(instance, _, p)
		if not v[instance] then
			return "Continue"
		end

		p.Parry:Invoke(instance)
		local clone = script.Shield.Parried:Clone()
		clone.Parent = instance:FindFirstChild("HumanoidRootPart")
		clone:Play()
		Debris:AddItem(clone, 2)
		return "CancelAndInvalidate"
	end

	workspace.Balls.ChildAdded:Connect(function(child)
		if not require3(ReplicatedStorage2.Shared.UseBall2)() then
			return
		end

		child.AddCustomCollisionResponse:Invoke(script.ForcefieldCollisionResponse, 50)
	end)
end

return {
	cooldown = 40,
	cooldownReductionPerUpgrade = 5,
	iconId = "rbxassetid://14521165734",
	botsShouldParry = true,
	serverActivationAsync = function(data, p)
		local v2 = 7 + 1.1666666666666667 * data.upgradeLevel

		if workspace.ShowdownActive.Value then
			v2 /= 4
		end

		v[data.character] = true
		task.delay(v2, function()
			v[data.character] = nil
		end)
		local clone

		if data.upgradeLevel >= 2 then
			clone = script.MaxShield:Clone()
		else
			clone = script.Shield:Clone()
		end

		clone.Size = createVector(0, 0, 0)
		clone.Parent = data.rootPart
		clone.CFrame = data.rootPart.CFrame
		clone.WeldConstraint.Part1 = data.rootPart
		Debris:AddItem(clone, v2 + 1)
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(7, 7, 7)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {
			Size = createVector(6, 6, 6)
		}):Play()
		local flag = false

		local function cleanup()
			if flag then
				return
			end

			flag = true
			local shieldDeactivate = clone:FindFirstChild("ShieldDeactivate")

			if shieldDeactivate then
				shieldDeactivate:Play()
			end

			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.inner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0)
			}):Play()
			task.delay(0.5, function()
				clone:Destroy()
			end)
		end

		task.delay(v2, cleanup)
		p.addCleaner(cleanup)
	end
}