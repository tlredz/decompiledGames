local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local boomboxShopPreview = ReplicatedStorage.Assets.BoomboxShopPreview
return {
	mount = function(parent)
		if parent:GetAttribute("Mounted") then
			return
		end

		parent:SetAttribute("Mounted", true)
		local clone = boomboxShopPreview:Clone()

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		clone:PivotTo(CFrame.new())
		clone.Parent = parent
		local boundingBox, v = clone:GetBoundingBox()
		local position = boundingBox.Position
		local v2 = math.max(v.X, v.Y, v.Z) * 1.5
		local camera = Instance.new("Camera")
		camera.FieldOfView = 50
		camera.CFrame = CFrame.lookAt(position + Vector3.new(0, v.Y * 0.1, v2), position)
		camera.Parent = parent
		parent.CurrentCamera = camera
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			clone:PivotTo(CFrame.Angles(0, os.clock(), 0))
		end)
		parent.Destroying:Once(function()
			heartbeatConnection:Disconnect()
		end)
	end
}