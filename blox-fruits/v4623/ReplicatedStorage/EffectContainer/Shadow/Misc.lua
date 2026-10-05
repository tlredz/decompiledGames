local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function crowHitEffect(position)
	local clone = script.SwirlSpiral:Clone()
	clone.Size = createVector(1, 0.05, 2)
	Util.Debris:AddItem(clone, 3)
	clone.CFrame = CFrame.new(position) * CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1,
			Size = createVector(2.34, 0.05, 35.13),
			CFrame = clone.CFrame * CFrame.Angles(0, 0.3490658503988659, 0)
		}
	)
	clone.Parent = _WorldOrigin
	Util.Sound:Play("QuickSlice", position, nil, 1.7 + math.random(-32, 32) / 100, 0.25)
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 1)
	part.Anchored = true
	part.Size = Vector3.new()
	part.CanCollide = false
	part.Transparency = 1
	part.Position = position
	part.Parent = _WorldOrigin
	local clone2 = script.HitEmitter:Clone()
	Util.Debris:AddItem(clone2, 1)
	clone2.Parent = part
	clone2:emit(1)
end

return function(data)
	local type = data.Type

	if type == 1 then
		local position = data.Position
		local clone = script.ShadowPuff:Clone()
		Util.Debris:AddItem(clone, 2)
		clone.Position = position
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone.Attachment:GetChildren()) do
			if child.Name == "Smoke" then
				child:Emit(5)
			else
				child:Emit(1)
			end
		end
	elseif type == 2 then
		local root = data.Root

		if typeof(root) == "Instance" then
			crowHitEffect(root.Position)
		else
			crowHitEffect(root)
		end
	elseif type == 3 then
		local position = data.Position
		local size = data.Size or 10

		if not data.Color then
			Color3.fromRGB(255, 255, 255)
		end

		local clone = script.GenericHit:Clone()
		Util.Debris:AddItem(clone, 1)
		local kiImpact = clone.FXAttachment.KiImpact
		local kiSpikes = clone.FXAttachment.KiSpikes
		clone.Position = position
		clone.Parent = _WorldOrigin

		for _, v in pairs({ kiImpact, kiSpikes }) do
			v.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, v == kiSpikes and size or size / 2),
				NumberSequenceKeypoint.new(1, 0)
			})
			v:Emit(2)
		end
	end
end