local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
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

	local cframe_to_send = data.cframe_to_send
	local side_to_send = data.side_to_send
	local hound_to_send = data.hound_to_send
	local _ = data.size_to_send or 15
	local _ = data.magnitude_to_send or 5
	local parent = part_to_send.Parent

	if parent then
		local hitbox = parent:WaitForChild("hitbox", 10)
		local touchTransmitter = hitbox:FindFirstChildWhichIsA("TouchTransmitter")

		if touchTransmitter then
			touchTransmitter:Destroy()
		else
			local childAddedConnection = nil
			childAddedConnection = hitbox.ChildAdded:Connect(function(touchTransmitter2)
				if touchTransmitter2:IsA("TouchTransmitter") then
					childAddedConnection:Disconnect()
					touchTransmitter2:Destroy()
				end
			end)
		end

		parent:WaitForChild("terrainhitbox", 10):Destroy()
	end

	local p = cframe_to_send.p
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 100 then
			Util.CameraShaker:ShakeOnce(2.5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
		end
	end

	local clone = nil

	if side_to_send and not hound_to_send then
		clone = FX:WaitForChild("MagmaEffects").MagmaZRight:Clone()
	elseif side_to_send or hound_to_send then
		if not side_to_send and hound_to_send then
			clone = FX:WaitForChild("MagmaEffects").MagmaHound:Clone()
		end
	else
		clone = FX:WaitForChild("MagmaEffects").MagmaZLeft:Clone()
	end

	local position = part_to_send.Position

	for _, weld in pairs(clone.PrimaryPart:GetChildren()) do
		if not weld:IsA("Weld") then
			weld:Destroy()
		end
	end

	if data.ultimate then
		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("BasePart") then
				part.Size *= 1.5
			end
		end
	end

	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = clone.PrimaryPart
	motor6D.Part1 = part_to_send
	motor6D.Parent = clone.PrimaryPart
	clone.Parent = workspace._WorldOrigin
	local v = math.random(50, 75) / 100
	local v2 = math.random(20, 25) / 100
	local count = 0
	local HttpService = game:GetService("HttpService")
	local GUID = HttpService:GenerateGUID()
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep(GUID, Enum.RenderPriority.Last.Value, function()
		if part_to_send:IsDescendantOf(workspace) then
			if data.nerf then
				return
			end

			count += 1
			local v4 = data.ultimate and 2 or hound_to_send and 2 or not hound_to_send and 9 or nil

			if count % v4 == 0 then
				local clone2 = FX:WaitForChild("MagmaEffects").MagmaBall:Clone()

				for _, part in pairs(clone2:GetDescendants()) do
					if not (part:IsA("BasePart") and part.Name ~= "Sphere" and part.Name ~= "old" and part.Name ~= "root") then
						continue
					end

					part:Destroy()
				end

				clone2:SetPrimaryPartCFrame(part_to_send.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				))
				clone2:SetPrimaryPartCFrame(clone2.PrimaryPart.CFrame * CFrame.Angles(
					math.rad(math.random(-100, 100) / 10),
					math.rad(math.random(-100, 100) / 10),
					(math.rad(math.random(-100, 100) / 10))
				))
				clone2:SetPrimaryPartCFrame(CFrame.new(clone2.PrimaryPart.Position, position) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				))
				clone2.Parent = _WorldOrigin
				local sphere = clone2.Sphere
				sphere.Size = Vector3.new(35, math.random(10, 15), 35)

				if math.random(1, 2) == 1 then
					sphere.Color = Color3.fromRGB()
				end

				if data.ultimate then
					if data.ultimate then
						local tween = TweenService:Create(sphere, TweenInfo.new(v, Enum.EasingStyle.Quart), {
							CFrame = sphere.CFrame * CFrame.new(0, -math.random(200, 250) / 10, 0) * CFrame.Angles(
								0,
								math.rad(math.random(-3600, 3600) / 10),
								0
							),
							Size = sphere.Size * math.random(25, 35) / 10,
							Transparency = 1,
							Color = Color3.fromRGB(255, 0, 0)
						})
						tween:Play()
						tween.Completed:Connect(function()
							clone2:Destroy()
						end)
					end
				else
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
						clone2:Destroy()
					end)
				end

				local clone3 = FX:WaitForChild("MagmaEffects").Frontwave:Clone()
				clone3.CFrame = CFrame.new(
					part_to_send.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						math.rad(math.random(-100, 100) / 10),
						math.rad(math.random(-100, 100) / 10),
						(math.rad(math.random(-100, 100) / 10))
					).p,
					position
				) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Size = createVector(45, 20, 45)
				clone3.Parent = _WorldOrigin

				if data.ultimate then
					if data.ultimate then
						local tween = TweenService:Create(clone3, TweenInfo.new(v2), {
							Size = createVector(65, 70, 65),
							Transparency = 1,
							Color = Color3.fromRGB(0, 0, 0)
						})
						tween:Play()
						tween.Completed:Connect(function()
							clone3:Destroy()
						end)
					end
				else
					local tween = TweenService:Create(clone3, TweenInfo.new(v2), {
						Size = createVector(65, 70, 65),
						Transparency = 1,
						Color = Color3.fromRGB(0, 0, 0)
					})
					tween:Play()
					tween.Completed:Connect(function()
						clone3:Destroy()
					end)
				end
			end

			position = part_to_send.Position
		else
			local RunService2 = game:GetService("RunService")
			RunService2:UnbindFromRenderStep(GUID)

			if clone then
				motor6D:Destroy()
				clone:Destroy()
			end
		end
	end)
end