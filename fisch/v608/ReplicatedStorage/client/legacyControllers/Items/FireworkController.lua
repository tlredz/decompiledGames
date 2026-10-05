local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaneDebris = require(ReplicatedStorage.shared.modules:WaitForChild("SaneDebris"))
local v = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 58, 58),
	Color3.fromRGB(255, 245, 137),
	Color3.fromRGB(255, 164, 8),
	Color3.fromRGB(104, 211, 92),
	Color3.fromRGB(255, 131, 164),
	Color3.fromRGB(255, 171, 97),
	Color3.fromRGB(92, 130, 255)
}

local function getActiveFolder()
	local v2 = workspace:FindFirstChild("active")

	if not v2 then
		v2 = Instance.new("Folder")
		v2.Name = "active"
		v2.Parent = workspace
	end

	return v2
end

return {
	Spawn = function(_, cFrame: CFrame, duration: number?)
		task.spawn(function()
			duration = duration or 2
			task.wait(math.random(20, 30) / 100)
			local parent = workspace:FindFirstChild("active")

			if not parent then
				parent = Instance.new("Folder")
				parent.Name = "active"
				parent.Parent = workspace
			end

			local clone = script:WaitForChild("Firework"):Clone()
			clone.Parent = parent

			if clone:IsA("Model") and clone.PrimaryPart then
				clone:PivotTo(cFrame)
			else
				local handle = clone:FindFirstChild("handle")

				if handle and handle:IsA("BasePart") then
					handle.CFrame = cFrame
				end
			end

			local handle = clone:FindFirstChild("handle")

			if handle and handle:IsA("BasePart") then
				local linearVelocity = handle:FindFirstChildWhichIsA("LinearVelocity", true)

				if linearVelocity then
					linearVelocity.VectorVelocity = createVector(0, 90, 0)
				end

				local sizzle = handle:FindFirstChild("Sizzle")

				if sizzle and sizzle:IsA("Sound") then
					sizzle:Play()
				end

				local fuse = handle:FindFirstChild("Fuse")

				if fuse and fuse:IsA("Sound") then
					fuse:Play()
				end
			end

			task.wait(duration)
			local cFrame2 = cFrame

			if handle then
				cFrame2 = handle.CFrame
			elseif clone.PrimaryPart then
				cFrame2 = clone.PrimaryPart.CFrame
			end

			local clone2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fx"):WaitForChild("Firework"):Clone()

			if clone2:IsA("BasePart") then
				clone2.CFrame = cFrame2
			elseif clone2:IsA("Model") then
				clone2:PivotTo(cFrame2)
			end

			local v3 = v[math.random(1, #v)]
			clone2.sparks.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v3),
				ColorSequenceKeypoint.new(1, v3)
			})
			clone2.Parent = parent
			clone2.sparks.Enabled = true
			clone2.sparks:Emit(600)
			clone2.Pop:Play()
			clone2.Bang:Play()
			task.wait(0.9)
			clone2.sparks.Enabled = false
			SaneDebris:AddItem(clone2, 7)
			SaneDebris:AddItem(clone, 7)
		end)
	end
}