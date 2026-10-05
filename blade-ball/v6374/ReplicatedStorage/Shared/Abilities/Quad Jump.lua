local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("ServerScriptService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3(script.Parent["Wind Cloak"])

local function shockwave(clone, p, value, color, p2, p3, p4)
	local clone2 = ReplicatedStorage2.Misc.Wave:Clone()
	clone2.Parent = workspace.Runtime

	if p3 then
		clone2.Transparency = 1
		clone2.Size = Vector3.new(p, 0.25, p)
	else
		clone2.Size = createVector(0.01, 0.5, 0.01)
	end

	if p2 then
		clone2.CFrame = clone.CFrame
	else
		clone2.CFrame = clone.CFrame * CFrame.Angles(1.51, 0, 0)
	end

	if p4 then
		clone2.CFrame *= CFrame.new(0, -2.5, 0)
	end

	if color then
		clone2.Color = color
	end

	local vector2 = Vector3.new(p, 0.5, p)
	local v = value or 0.3
	local v2 = game.TweenService:Create(
		clone2,
		TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = p3 and createVector(0.01, 0.25, 0.01) or vector2
		}
	)
	local v3 = game.TweenService:Create(
		clone2,
		TweenInfo.new(v / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1
		}
	)

	if p3 then
		game.TweenService:Create(
			clone2,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 0
			}
		):Play()
	end

	v2:Play()
	Debris:AddItem(clone2, v)
	task.spawn(function()
		task.wait(v / 2)
		v3:Play()
	end)
end

if RunService:IsServer() then
	local v = {}
	script.RemoteActivated.OnServerEvent:Connect(function(player)
		if not (player.Character and player.Character:GetAttribute("UsingQuadJump")) or v[player] then
			return
		end

		v[player] = true
		task.delay(0.03, function()
			v[player] = nil
		end)
		script.RemoteActivated:FireAllClients(player.Character)
	end)
else
	script.RemoteActivated.OnClientEvent:Connect(function(instance)
		if not instance then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return
		end

		local clone = ReplicatedStorage2.Misc.quadjumpz:Clone()
		clone.Parent = workspace.Runtime
		Debris:AddItem(clone, 1)
		clone.CFrame = humanoidRootPart.CFrame
		clone.Position -= createVector(0, 1, 0)
		clone.Jump:Play()
		local color = Color3.new(0.756863, 0.756863, 0.756863)

		if instance:GetAttribute("QuadJumpMax") then
			color = Color3.new(0.360784, 0.745098, 1)
		end

		shockwave(clone, 10, nil, color, true)
	end)
	script.Activated.Event:Connect(function()
		script.RemoteActivated:FireServer()
	end)
end

return {
	iconId = "rbxassetid://15060531535",
	isPassive = true,
	equipped = function(p)
		p.character:SetAttribute("UsingQuadJump", true)
		p.character:SetAttribute("QuadJumpMax", p.upgradeLevel >= 2)
		return function()
			p.character:SetAttribute("UsingQuadJump", nil)
			p.character:SetAttribute("QuadJumpMax", nil)
		end
	end
}