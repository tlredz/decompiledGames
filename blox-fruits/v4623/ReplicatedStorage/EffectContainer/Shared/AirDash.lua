local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))

function a(player)
	local cFrame = player.CFrame
	local duration = player.Duration or 0.3
	local width = player.Width or 2
	local length = player.Length or 4

	if not player.Color then
		Color3.new(1, 1, 1)
	end

	if cFrame.LookVector ~= cFrame.LookVector then
		cFrame = player.Root.CFrame
	end

	local character = player.Character
	local root = player.Root

	if not root:WaitForChild("RootRigAttachment", 1) then
		return
	end

	local clone = script.DashTrail:Clone()
	clone.Parent = character
	clone.Attachment0 = root.RootRigAttachment
	clone.Attachment1 = character.UpperTorso.NeckAttachment
	task.delay(duration, function()
		clone.Enabled = false
		Util.Debris:AddItem(clone, 0.5)
	end)
	local clone2 = script.AirModel:Clone()
	clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, length / 2) * CFrame.Angles(-1.5707963267948966, 0, 0))
	clone2.Shockwave.Size = Vector3.new(width, width * 0.5, width) * 1.25
	TweenService:Create(clone2.Shockwave, TweenInfo.new(1.25 * duration), {
		Transparency = 1,
		Size = Vector3.new(width * 4, width * 0.066, width * 4),
		CFrame = clone2.Shockwave.CFrame - cFrame.LookVector * length
	}):Play()
	clone2.ShockwaveBig.Size = Vector3.new(width, width * 0.5, width) * createVector(2, 1.25, 2)
	local tween = TweenService:Create(clone2.ShockwaveBig, TweenInfo.new(duration), {
		Transparency = 1,
		Size = Vector3.new(width * 6, width * 0.066, width * 6),
		CFrame = clone2.Shockwave.CFrame - cFrame.LookVector * length * 1.66
	})
	tween.Completed:Connect(function()
		clone2:Destroy()
	end)
	tween:Play()
	clone2.Parent = workspace._WorldOrigin
	clone2.Shockwave.wind.WindStream:Emit(5)
	local clone3 = script.Motion:Clone()
	clone3.Size = createVector(1, 1, 1) * width * 1.25
	clone3.CFrame = cFrame
	local clone4 = script.Motion2:Clone()
	clone4.Size = createVector(1, 1, 1) * width * 2
	clone4.CFrame = cFrame
	task.defer(function()
		local lastTime = tick()
		local now = 0
		local now2 = 0

		while tick() - lastTime < duration * 0.45 do
			local velocity = root.Velocity

			if velocity.Magnitude < 0.1 then
				velocity = cFrame.LookVector
			end

			clone3.CFrame = CFrame.new(root.Position, root.Position + velocity)
			clone4.CFrame = clone3.CFrame

			if tick() - now > 0.03333333333333333 then
				clone3.ParticleEmitter1:Emit(1)
				now = tick()
			end

			if tick() - now2 > 0.015873015873015872 then
				clone4.ParticleEmitter2:Emit(1)
				clone3.ParticleEmitter2:Emit(1)
				now2 = tick()
			end

			task.wait()
		end

		clone3.CFrame = CFrame.new(0, -1000, 0)
		clone4.CFrame = CFrame.new(0, -1000, 0)
		task.wait(0.5)
		clone3:Destroy()
		clone4:Destroy()
	end)
	clone3.Parent = workspace._WorldOrigin
	clone4.Parent = workspace._WorldOrigin
end

return a