local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local v = {
	"RightLowerLeg",
	"RightUpperLeg",
	"RightFoot",
	"LeftLowerLeg",
	"LeftUpperLeg",
	"LeftFoot"
}
return function(player)
	local subID = player.SubID or 1

	if subID == 1 then
		local character = player.Character
		local humanoid = player.Humanoid
		local holdValue = player.HoldValue

		if character and humanoid then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart ~= nil then
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 600 then
					return
				end

				local clone = script.sandflighteff:Clone()
				clone.Parent = humanoidRootPart
				clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
				clone.Orientation += createVector(0, 180, 180)
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Name = "sandflighteffweld"
				weldConstraint.Parent = humanoidRootPart
				weldConstraint.Part0 = humanoidRootPart
				weldConstraint.Part1 = clone

				for _, part in ipairs(character:GetDescendants()) do
					if not (part:IsA("BasePart") and table.find(v, part.Name)) then
						continue
					end

					part.Transparency = 1
				end

				local diedConnection = nil

				if humanoid then
					diedConnection = humanoid.Died:Connect(function()
						diedConnection:Disconnect()
					end)
				end

				local lastTime = tick()

				local function running()
					return tick() - lastTime < 0.2 or diedConnection and player.HoldValue and player.HoldValue.Value == true
				end

				tick()
				tick()

				while (tick() - lastTime < 0.2 or diedConnection and player.HoldValue and player.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and humanoidRootPart and humanoid do
					RunService.RenderStepped:Wait()
				end

				if diedConnection then
					diedConnection:Disconnect()
				end

				if humanoidRootPart:FindFirstChild("sandflighteff") then
					for _, emitter in pairs(humanoidRootPart.sandflighteff:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					delay(0.5, function()
						humanoidRootPart.sandflighteff:Destroy()
					end)
				end

				task.delay(0.6, function()
					if humanoidRootPart:FindFirstChild("sandflighteffweld") then
						humanoidRootPart.sandflighteffweld:Destroy()
					end
				end)

				for _, part in ipairs(character:GetDescendants()) do
					if not (part:IsA("BasePart") and table.find(v, part.Name)) then
						continue
					end

					part.Transparency = 0
				end
			end
		end
	end
end