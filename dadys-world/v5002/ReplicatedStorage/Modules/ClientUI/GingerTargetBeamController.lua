local RunService = game:GetService("RunService")
local GingerTargetBeamController = {}
GingerTargetBeamController.__index = GingerTargetBeamController

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeClamped(p, p2, maxSize)
	return (math.clamp((p - p2) / (maxSize - p2), 0, 1))
end

function GingerTargetBeamController.new(template, p)
	local object = setmetatable({}, GingerTargetBeamController)
	object.Template = template
	object.MaxSize = p or template.Size.X
	object.Part = template:Clone()
	object.Selection = template.Parent:FindFirstChild("targetSelect"):Clone()
	object.Part.Anchored = true
	object.Part.Parent = workspace
	object.Selection.Anchored = true
	object.Selection.Parent = workspace
	object._conn = nil
	return object
end

function GingerTargetBeamController:Attach(instance, instance2)
	self:Detach()
	self._conn = RunService.Heartbeat:Connect(function()
		local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local position = instance2.Position

		if not position then
			return
		end

		local v = not humanoidRootPart.Parent:FindFirstChild("Humanoid") and 0 or humanoidRootPart.Parent:FindFirstChild("Humanoid").HipHeight
		local v2 = humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2 + v - 0.25, 0)
		local v3 = position - v2
		local vector = Vector3.new(v3.X, 0, v3.Z)
		local v4 = self.Part.Size.Z / 2 * math.max(0.1, (math.clamp((v3.Magnitude / self.MaxSize - 1) / -1, 0, 1))) + 0.5
		local v5 = v3.Magnitude + v4
		local maxSize = self.MaxSize
		local clamped = normalizeClamped(v5, maxSize * 0.5, maxSize) -- equivalent call inferred; original call site unknown
		local v7 = math.sin(os.clock() * 40) * clamped
		self.Part.Size = Vector3.new(math.clamp(v5, 5, maxSize), self.Part.Size.Y, self.Part.Size.Z)
		self.Part.PivotOffset = CFrame.new(
			-(self.Part.Size.X / 2) + self.Part.Size.Z / 2 * math.clamp((v5 / maxSize - 1) / -1, 0, 1),
			0,
			0
		)

		if vector.Magnitude > 0.01 then
			self.Part:PivotTo(CFrame.lookAt(v2, v2 + vector) * CFrame.Angles(0, 1.5707963267948966, 0))
			local v8 = not instance2.Parent:FindFirstChild("Humanoid") and 0 or instance2.Parent:FindFirstChild("Humanoid").HipHeight
			self.Selection:PivotTo(CFrame.new(position - Vector3.new(0, instance2.Size.Y / 2 + v8 - 0.25, 0)))
		end

		local surfaceGui = self.Part:FindFirstChild("SurfaceGui")

		if surfaceGui and surfaceGui:FindFirstChild("Frame1") then
			surfaceGui.Frame1.AnchorPoint = Vector2.new(0.5 - v7 * 0.5, 0)
			local v8 = math.max(0.1, (math.clamp((v5 / maxSize - 1) / -1, 0, 1)))
			surfaceGui.Frame1.Size = UDim2.fromScale(v8, 1)
		end
	end)
end

function GingerTargetBeamController:Detach()
	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end
end

function GingerTargetBeamController:Destroy()
	self:Detach()

	if self.Part then
		self.Part:Destroy()
		self.Part = nil
	end

	if self.Selection then
		self.Selection:Destroy()
		self.Selection = nil
	end
end

return GingerTargetBeamController