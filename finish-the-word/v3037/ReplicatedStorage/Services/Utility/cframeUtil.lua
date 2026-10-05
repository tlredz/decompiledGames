local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
game:GetService("RunService")
local v = nil
_G.import("configuration")
local import = _G.import("vectorUtil")
local CframeUtil = {
	pos = function(p, p2)
		return p - p.p + p2
	end,
	getRot = function(p)
		return p - p.p
	end
}

function CframeUtil.clampDist(p, p2, p3)
	return CframeUtil.pos(p, import.clampDist(p.p, p2, p3))
end

function CframeUtil.within(p, p2, p3, value)
	return (((typeof(p) == "Vector3" and p or p.Position) - (typeof(p2) == "Vector3" and p2 or p2.Position)) * (value or 1)).magnitude <= p3
end

function CframeUtil.onReach(p, p2, p3, callback, p4)
	local v2 = p4 or createVector(1, 1, 1)
	task.spawn(function()
		local total = 0

		while total <= p3 and not (((p.Position - p2) * v2).magnitude <= 0.5) do
			total += task.wait(0)
		end

		if callback then
			callback()
		end
	end)
end

function CframeUtil.localToWorldDir(data, data2)
	return data.X * data2.rightVector + data.Y * data2.upVector + data.Z * data2.lookVector
end

function CframeUtil.worldToLocalDir(vector2, data)
	return data.rightVector * vector2:Dot(data.rightVector) + data.upVector * vector2:Dot(data.upVector) + data.lookVector * vector2:Dot(data.lookVector)
end

function CframeUtil.part(_)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	return part
end

function CframeUtil.capFloorRange(p, p2, p3)
	local position = p.HumanoidRootPart.Position
	local position2 = p2.Position
	local vector2 = Vector3.new(position.X, position2.Y, position.Z)
	local v2 = position2 - vector2
	return vector2 + v2.unit * math.min(v2.magnitude, p3)
end

function CframeUtil.weldbox(p, p2)
	p2.Weld = p.HumanoidRootPart
	p2.Touch = true
	return CframeUtil.hitbox(p, p2)
end

function CframeUtil.hitbox(p, instance)
	local humanoidRootPart = p.HumanoidRootPart
	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = not instance.Weld
	part.Transparency = instance.Transparency or 1
	part.Size = instance.Size or createVector(2, 2, 2)
	part.Shape = instance.Shape or 1
	part.Massless = true
	part.CollisionGroup = "BallCollide"
	part.CFrame = instance.CFrame or humanoidRootPart.CFrame * (instance.Offset or CFrame.new(0, 0, 0))
	part.Touched:Connect(function() end)
	local discriminant = instance.Discriminant or function(p2)
		return p2
	end
	local cond = instance.Cond or function(_)
		return true
	end

	if instance.Weld then
		v = v or _G.import("bodyUtil")
		v.clientWeld(instance.Weld, part, instance.Offset)
	end

	local v2 = {}
	local count = 0

	local function hit(p2)
		if p2.Parent == p then
			return 1
		end

		local v3 = discriminant(p2)

		if not v3 or v2[v3] then
			return 1
		end

		if count >= (instance.MaxHit or 1e999) then
			return 2
		end

		if not cond(v3) then
			return 1
		end

		count += 1
		v2[v3] = true
		task.spawn(instance.Hit, v3)
	end

	part.Parent = workspace

	if instance.Touch then
		local touchedConnection = nil
		touchedConnection = part.Touched:Connect(function(otherPart)
			if hit(otherPart) == 2 then
				touchedConnection:Disconnect()
			end
		end)
	else
		for _, v4 in pairs(part:GetTouchingParts()) do
			local v5 = hit(v4)

			if v5 ~= 1 and v5 == 2 then
				break
			end
		end
	end

	if instance.Lifetime then
		Debris:AddItem(part, instance.Lifetime)
	elseif instance.Weld then
		part.Parent = instance.Weld
	else
		task.wait(0)
		part:Destroy()
	end

	return part
end

local v2 = {}

function CframeUtil:tweenCFrame(duration, cFrame, p2, _)
	local tween = TweenService:Create(self, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		CFrame = cFrame
	})
	local v3 = v2[self]
	v2[self] = tween

	if v3 then
		v3:Cancel()
	end

	tween:Play()

	if p2 then
		tween.Completed:Connect(function()
			local total = 0

			while total <= 0.25 and v2[self] == tween do
				total += task.wait(0)
				self.CFrame = cFrame
			end
		end)
	end

	return tween
end

function CframeUtil.cancelTween(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v3:Cancel()
	v2[p] = nil
end

function CframeUtil.setPos(p, p2)
	return p - p.p + p2
end

function CframeUtil.knockback(p, p2, p3, p4)
	local humanoidRootPart = p.HumanoidRootPart
	return CframeUtil.tweenCFrame(humanoidRootPart, p2, humanoidRootPart.CFrame - humanoidRootPart.Position + p3, p4)
end

function CframeUtil.faceKnockback(p, p2, p3, p4)
	local humanoidRootPart = p.HumanoidRootPart
	local humanoidRootPart2 = p2.HumanoidRootPart
	humanoidRootPart2.CFrame = CFrame.new(
		humanoidRootPart2.Position,
		humanoidRootPart2.Position + (humanoidRootPart.Position - humanoidRootPart2.Position) * createVector(1, 0, 1)
	)
	return CframeUtil.knockback(p2, p3, p4, true)
end

return CframeUtil