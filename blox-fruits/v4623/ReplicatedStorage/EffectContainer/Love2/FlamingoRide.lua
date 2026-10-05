local createVector = vector.create
game:GetService("TweenService")
game:GetService("RunService")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))

function a(data)
	local rig = data.Rig
	local rootPart = rig.RootPart
	local ownerRoot = data.OwnerRoot
	Util.Sound:Play("LoveFlamingo", rootPart.CFrame.Position)
	local clone = script.release:Clone()
	clone.CFrame = rootPart.CFrame
	clone.Parent = workspace._WorldOrigin

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	task.delay(4, function()
		clone:Destroy()
	end)

	if data.Effect then
		return
	end

	local cFrame = rootPart.CFrame
	local clone2 = script.Motion:Clone()
	clone2.Size = createVector(5, 5, 5)
	clone2.CFrame = cFrame
	local clone3 = script.Motion2:Clone()
	clone3.Size = createVector(8, 8, 8)
	clone3.CFrame = cFrame
	local v = nil
	task.defer(function()
		tick()
		local v2 = nil
		local now = 0
		local now2 = 0

		while rig and rig:IsDescendantOf(workspace) do
			local passengerObject = ownerRoot:FindFirstChild("PassengerObject")
			local value = passengerObject and passengerObject.Value

			if value and ownerRoot.Parent:GetAttribute("HasPassenger") then
				local humanoidRootPart = value:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					humanoidRootPart.CFrame = ownerRoot.CFrame * CFrame.new(0, 0, 1.5)
					humanoidRootPart.Velocity = createVector(0, 0, 0)
				end

				v2 = v2 or value:FindFirstChild("Humanoid")
			end

			v = value
			local velocity = ownerRoot.Velocity

			if not (velocity.Magnitude < 110 or velocity.Unit.Y > 0.2 or velocity.Unit:Dot(ownerRoot.CFrame.LookVector) < 0.8) then
				clone2.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, 0, -4)
				clone3.CFrame = clone2.CFrame

				if tick() - now > 0.05 then
					clone2.ParticleEmitter1:Emit(1)
					now = tick()
				end

				if tick() - now2 > 0.022222222222222223 then
					clone3.ParticleEmitter2:Emit(1)
					clone2.ParticleEmitter2:Emit(1)
					now2 = tick()
				end
			end

			task.wait()
		end

		if v2 then
			v2:SetAttribute("IsPassenger", false)
		end

		Util.Sound:Play("LoveFlamingoOff", rootPart.CFrame.Position)
		local clone4 = script.release:Clone()
		clone4.CFrame = rootPart.CFrame
		clone4.Parent = workspace._WorldOrigin

		for _, child in pairs(clone4.Attachment:GetChildren()) do
			child:Emit((child:GetAttribute("EmitCount") or 1) * 0.49)
		end

		task.delay(4, function()
			clone4:Destroy()
		end)
		clone2.CFrame = CFrame.new(0, -1000, 0)
		clone3.CFrame = CFrame.new(0, -1000, 0)
		task.wait(0.5)
		clone2:Destroy()
		clone3:Destroy()
	end)
	clone2.Parent = workspace._WorldOrigin
	clone3.Parent = workspace._WorldOrigin
end

return a