local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
return function(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local superhumanV2 = script.Parent:FindFirstChild("SuperhumanV2")
	local C = superhumanV2 and superhumanV2:FindFirstChild("C")

	if not C then
		return
	end

	local duration = player.Duration or 1.5
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local boolValue = Instance.new("BoolValue")
		boolValue.Value = true
		boolValue.Parent = character
		Util.Debris:AddItem(boolValue, duration + 5)
		Effect.new("SuperhumanV2.C"):replicate({
			Stage = 1,
			Character = character,
			Humanoid = humanoid,
			HoldValue = boolValue
		})
		task.delay(duration, function()
			boolValue.Value = false
		end)
	end

	local windMesh = C:FindFirstChild("WindMesh")

	if windMesh and windMesh:IsA("BasePart") then
		task.spawn(function()
			for _ = 1, 3 do
				local clone = windMesh:Clone()
				Util.Debris:AddItem(clone, 3)
				clone.Size = Vector3.new()
				clone.Transparency = -2
				clone.CFrame = CFrame.new(humanoidRootPart.Position - createVector(0, 2.5, 0))
				clone.Parent = _WorldOrigin
				TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(75, 18, 75),
					Transparency = 1
				}):Play()
				task.wait(0.18)
			end
		end)
	end
end