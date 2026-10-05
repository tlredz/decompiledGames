local createVector = vector.create

local function ScaleParticle(clone, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local FX = require(game.ReplicatedStorage.FX)
workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local mochiMochi = FX:WaitForChild("Mochi-Mochi")

local function Particles(instance)
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local maid = Maid.new()
	local v = {}
	local clones = {}

	for _ = 1, 2 do
		local attachment = Instance.new("Attachment")
		local clone = mochiMochi.Dust:Clone()
		maid:GiveTask(clone)
		maid:GiveTask(attachment)
		clone.Enabled = false
		clone.Size = ScaleParticle(clone, instance.Size.Magnitude * 0.075)
		clone.Parent = attachment
		attachment.Parent = workspace.Terrain
		v[#v + 1] = attachment
		clones[#clones + 1] = clone
	end

	return {
		Enable = function(self, enabled)
			for _, v2 in next, clones, nil do
				v2.Enabled = enabled
			end
		end,
		SetColor = function(self, p)
			for _, v2 in next, clones, nil do
				v2.Color = ColorSequence.new(p)
			end
		end,
		SetCFrame = function(self, p)
			for k, v2 in next, v, nil do
				local v3 = k == 1 and 1 or -1
				v2.CFrame = p * CFrame.new(v3 * instance.Size.X * 0.4, 0, 0) * CFrame.Angles(
					0,
					v3 * 0.17453292519943295,
					0
				)
			end
		end,
		Destroy = function(self)
			spawn(function()
				pcall(function()
					self:Enable(false)
				end)
				wait(1)
				pcall(function()
					maid:DoCleaning()
				end)
			end)
		end
	}
end

return function(instance)
	if not (instance and instance.Parent) then
		return
	end

	local particles = Particles(instance)
	local v2 = tick() - 0.016666666666666666

	while instance and instance.Parent do
		local now = tick()
		local v4 = now - v2
		pcall(function()
			local ray = Ray.new(
				instance.Position,
				(Vector3.new(0, -(instance.Size.Y + instance.Size.Y / 2 * math.abs(instance.Velocity.Y * v4))))
			)
			local part, v5, v6 = workspace:FindPartOnRayWithWhitelist(ray, { workspace.Map })

			if part then
				particles:SetColor(part.Color)
				particles:SetCFrame(instance.CFrame * CFrame.new(0, -instance.Size.Y / 2, -1))
			end

			particles:Enable(part and (instance.Velocity * createVector(1, 0, 1)).Magnitude > 10)
		end)
		RunService.RenderStepped:Wait()
		v2 = now
	end

	particles:Destroy()
end