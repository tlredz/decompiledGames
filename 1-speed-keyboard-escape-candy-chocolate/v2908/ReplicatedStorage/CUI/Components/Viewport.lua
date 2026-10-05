local createVector = vector.create
require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Viewport", "Viewport")

	function extended:Init()
		self.DisplayedModel = nil
		self:Cleanup()
		local camera = Instance.new("Camera")
		camera.FieldOfView = 30
		camera.Parent = self.UI.ViewportFrame
		local viewportInstance = self:GetViewportInstance()
		viewportInstance.CurrentCamera = camera
	end

	function extended:Cleanup()
		for _, model in self.UI.ViewportFrame:GetChildren() do
			if model:IsA("Model") then
				model:Destroy()
			end
		end
	end

	function extended:Clear()
		self:Cleanup()

		if self.DisplayedModel then
			self.DisplayedModel:Destroy()
			self.DisplayedModel = nil
		end

		return self
	end

	function extended.SetYSize(object, p2: number)
		object.UI.Size = UDim2.new(1, 0, 0, (math.max(p2, 0)))
		object:UpdateParentHeight()
		return object
	end

	function extended:SetModel(instance)
		if self.DisplayedModel then
			self.DisplayedModel:Destroy()
		end

		local clone = instance:Clone()
		clone:PivotTo(CFrame.new())
		clone.Parent = self.UI.ViewportFrame
		self.DisplayedModel = clone
		return self
	end

	function extended:SetDefaultCamera(value: number?, value2: number?)
		local v = value or 6
		local fieldOfView = value2 or 10
		local camera = self:GetCamera()
		local model = self:GetModel()

		if camera and model then
			local model2 = Instance.new("Model")
			local clone = model:Clone()
			clone.Parent = model2
			local _, v3 = model2:GetBoundingBox()
			camera.FieldOfView = fieldOfView
			camera.CFrame = CFrame.lookAt(v3 * v * createVector(1, 2, 1), createVector(0, 0, 0))
			model2:Destroy()
		end

		return self
	end

	function extended:GetModel()
		return self.DisplayedModel
	end

	function extended:GetCamera()
		return self.UI.ViewportFrame:FindFirstChild("Camera")
	end

	function extended.GetViewportInstance(p2)
		return p2.UI.ViewportFrame
	end

	return extended
end