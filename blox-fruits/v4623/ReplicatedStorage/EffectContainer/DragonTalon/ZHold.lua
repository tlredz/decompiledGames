game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Z = FX:WaitForChild("DragonTalon").Z
Random.new()
game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local origin = data.origin

	if (currentCamera.CFrame.p - origin).Magnitude > 600 then
		return
	end

	local root = data.Root

	if not root then
		return
	end

	local holding = data.Holding

	if holding.Value then
		local folder = Instance.new("Folder")
		folder.Parent = _WorldOrigin
		local clone = Z.Hold:Clone()
		clone.CFrame = root.CFrame
		clone.Parent = folder
		local v = Util.Sound:Play("DragonTalon.ZHold", clone)
		local lastTime = tick()
		local v2 = false

		while true do
			task.wait(0.03333333333333333)

			if tick() - lastTime > data.Dur and not v2 then
				clone.Attachment.Particle_1:Emit(1)
				clone.Attachment2.Particle_1.Enabled = false
				sound:Play("DragonTalon.ZChargeReady", origin)
				v2 = true
			end

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if clone then
				clone.Attachment2.Particle_1.Enabled = false
			end

			if v then
				Util.Sound:FadeOut(v, 0.3)
			end

			task.wait(2)
			folder:Destroy()
			break
		end
	end
end