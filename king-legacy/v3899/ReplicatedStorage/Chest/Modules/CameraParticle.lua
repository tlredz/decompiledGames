local CameraParticle = {}
CameraParticle.__index = CameraParticle
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local currentCamera = workspace.CurrentCamera

function CameraParticle.new(p)
	local object = setmetatable({}, CameraParticle)
	object.Type = p.Type or nil
	object.DebrisTime = p.DebrisTime or 3

	if not (object.Type and script.Particles:FindFirstChild(object.Type)) then
		return
	end

	local clone = script.Particles[object.Type]:Clone()
	clone.Parent = currentCamera
	object.Part = clone
	task.spawn(function()
		local v = FastRenderer.new({
			Time = 1e999
		})
		local lastTime = tick()
		local flag = nil
		local v2 = nil
		v:Connect(function(_)
			local viewportSize = currentCamera.ViewportSize
			local v3 = math.tan((math.rad(currentCamera.FieldOfView / 2))) * 2 * 1
			local v4 = viewportSize.X / viewportSize.Y * v3

			if not clone.Parent then
				return true
			end

			if (object.Destroyed or object.DebrisTime and tick() - lastTime >= object.DebrisTime) and not v2 then
				v2 = true

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.spawn(function()
					wait(1.5)
					flag = true
				end)
			end

			if flag then
				return true
			end

			if clone:FindFirstChild("Left") then
				clone.Size = Vector3.new(v4, v3, 0.01)
				clone.Left.Size = Vector3.new(v4 * 0.1, v3, 0)
				clone.Right.Size = Vector3.new(v4 * 0.1, v3, 0)
				clone.Top.Size = Vector3.new(v4, v3 * 0.1, 0)
				clone.Bottom.Size = Vector3.new(v4, v3 * 0.1, 0)
				clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -1)
				clone.LeftWeld.C0 = CFrame.new(-v4 / 2 + v4 * 0.1 / 2, 0, 0)
				clone.RightWeld.C0 = CFrame.new(v4 / 2 - v4 * 0.1 / 2, 0, 0)
				clone.TopWeld.C0 = CFrame.new(0, v3 / 2 - v3 * 0.1 / 2, 0)
				clone.BottomWeld.C0 = CFrame.new(0, -v3 / 2 + v3 * 0.1 / 2, 0)
			end
		end)
		object = nil
		clone:Destroy()
	end)
	return object
end

function CameraParticle:Destroy()
	self.Destroyed = true
end

return CameraParticle