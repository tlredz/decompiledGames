local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
TweenInfo.new(0.15, Enum.EasingStyle.Sine)
local _ = {
	Size = createVector(25, 15, 35),
	Transparency = 1,
	Color = Color3.new(0, 0, 0)
}
local _ = CFrame.Angles
Random.new()

local function fix(instance)
	local touchTransmitter = instance:FindFirstChildWhichIsA("TouchTransmitter")

	if touchTransmitter then
		touchTransmitter:Destroy()
		return
	end

	local childAddedConnection = nil
	childAddedConnection = instance.ChildAdded:Connect(function(touchTransmitter2)
		if touchTransmitter2:IsA("TouchTransmitter") then
			childAddedConnection:Disconnect()
			touchTransmitter2:Destroy()
		end
	end)
end

local function distanceCK(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

return function(data)
	local part_to_send = data.part_to_send

	if not part_to_send or (part_to_send.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 2000 then
		return
	end

	local character_to_send = data.character_to_send
	local humanoidRootPart

	if character_to_send then
		humanoidRootPart = character_to_send:WaitForChild("HumanoidRootPart")
	else
		humanoidRootPart = nil
	end

	local _ = data.cframe_to_send
	local _ = data.side_to_send
	local _ = data.size_to_send or 15
	local _ = data.magnitude_to_send or 5
	local v = math.random(50, 75) / 100
	local v2 = math.random(20, 25) / 100
	local p = part_to_send.CFrame.p
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 and (humanoidRootPart2.Position - p).magnitude <= 100 then
			Util.CameraShaker:ShakeOnce(2.5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
		end
	end

	local count = 0
	local position = part_to_send.Position
	local HttpService = game:GetService("HttpService")
	local GUID = HttpService:GenerateGUID()
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep(GUID, Enum.RenderPriority.Last.Value, function()
		if part_to_send:IsDescendantOf(workspace) then
			local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("MagmaBall"):Clone()

			for _, part in pairs(clone:GetDescendants()) do
				if not (part:IsA("BasePart") and part.Name ~= "Sphere" and part.Name ~= "old" and part.Name ~= "root") then
					continue
				end

				part:Destroy()
			end

			clone:SetPrimaryPartCFrame(part_to_send.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			))
			clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame * CFrame.Angles(
				math.rad(math.random(-100, 100) / 10),
				math.rad(math.random(-100, 100) / 10),
				(math.rad(math.random(-100, 100) / 10))
			))
			clone:SetPrimaryPartCFrame(CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
			) * CFrame.Angles(1.5707963267948966, 0, 0))
			clone.Parent = workspace:WaitForChild("_WorldOrigin")
			local sphere = clone:WaitForChild("Sphere")
			sphere.Size = createVector(35, 15, 35)

			if math.random(1, 2) == 1 then
				sphere.Color = Color3.fromRGB()
			end

			local tween = TweenService:Create(sphere, TweenInfo.new(v, Enum.EasingStyle.Quart), {
				CFrame = sphere.CFrame * CFrame.new(0, -math.random(200, 250) / 10, 0) * CFrame.Angles(
					0,
					math.rad(math.random(-3600, 3600) / 10),
					0
				),
				Size = sphere.Size * math.random(15, 20) / 10,
				Transparency = 1,
				Color = Color3.fromRGB(255, 0, 0)
			})
			tween:Play()
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			count += 1

			if count % 3 == 0 then
				local clone2 = FX:WaitForChild("MagmaEffects"):WaitForChild("Frontwave"):Clone()
				clone2.CFrame = part_to_send.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.CFrame *= CFrame.Angles(
					math.rad(math.random(-100, 100) / 10),
					math.rad(math.random(-100, 100) / 10),
					(math.rad(math.random(-100, 100) / 10))
				)
				clone2.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
				) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Size = createVector(35, 15, 35)
				clone2.Parent = workspace:WaitForChild("_WorldOrigin")
				local tween2 = TweenService:Create(clone2, TweenInfo.new(v2), {
					CFrame = clone2.CFrame * CFrame.new(0, -10, 0),
					Size = createVector(50, 75, 50),
					Transparency = 1,
					Color = Color3.fromRGB(0, 0, 0)
				})
				tween2:Play()
				tween2.Completed:Connect(function()
					clone2:Destroy()
				end)
			end

			if count % 7 == 0 then
				local clone2 = FX:WaitForChild("MagmaEffects"):WaitForChild("CurvedRing"):Clone()
				clone2.CFrame = part_to_send.CFrame
				clone2.CFrame *= CFrame.Angles(
					math.rad(math.random(-100, 100) / 10),
					math.rad(math.random(-100, 100) / 10),
					(math.rad(math.random(-100, 100) / 10))
				)
				clone2.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector
				) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Size = createVector(60, 2.5, 60)
				clone2.Parent = workspace:WaitForChild("_WorldOrigin")
				local tween2 = TweenService:Create(clone2, TweenInfo.new(v2), {
					CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
					Size = createVector(70, 5, 70),
					Transparency = 1
				})
				tween2:Play()
				tween2.Completed:Connect(function()
					clone2:Destroy()
				end)
			end

			position = part_to_send.Position
		else
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep(GUID)
		end
	end)
end