local module = require("@game/ReplicatedStorage/Omni")
local mouse = module.Instance:GetMouse()
local v = {}
local v2 = {
	Calculate = function(self)
		local X = self.Instance.AbsoluteSize.X
		local X2 = self.Instance.AbsolutePosition.X
		local v3 = X2 + X
		local v4 = math.clamp(mouse.X, X2, v3)
		local v5 = v3 - X2
		local v6 = v4 - X2
		return (module.Utils.Number:Round(v6 / v5, self.Precision))
	end,
	Drag = function(self)
		if self.Dragging then
			return
		end

		self.Dragging = true
		local v3 = true

		while self.Dragging do
			local calculated = self:Calculate()

			for _, v4 in self.Functions do
				v4(calculated, v3 == true and "Start" or "Update")
			end

			task.wait()
			v3 = v3 and false
		end
	end,
	BindFunction = function(p, p2, p3)
		if p.Functions[p2] then
			return
		end

		p.Functions[p2] = p3
	end,
	UnbindFunction = function(p, p2)
		if not p.Functions[p2] then
			return
		end

		p.Functions[p2] = nil
	end
}
module.Services.UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA then
		for _, v3 in v do
			if not v3.Dragging then
				continue
			end

			v3.Dragging = false

			for _, v4 in v3.Functions do
				v4(v3:Calculate(), "Stop")
			end
		end
	end
end)
local Slider = {}

function Slider.Create(_, instance, precision: number?)
	if v[instance] then
		return v[instance]
	end

	local object = setmetatable({}, {
		__index = v2
	})
	object.Instance = instance
	object.Precision = precision
	object.Dragging = false
	object.Functions = {}
	object.Connections = {}
	instance.Active = true
	instance.Selectable = true
	instance.Interactable = true
	object.Connections.Pressed = instance.MouseButton1Down:Connect(function()
		if instance.Parent == nil then
			return
		end

		object:Drag()
	end)
	object.Connections.Ancestry = instance.AncestryChanged:Connect(function(_, parent)
		if not (instance and parent) then
			object = nil
			v[instance] = nil
		end
	end)
	v[instance] = object
	return object
end

function Slider.Get(_, p)
	return v[p]
end

return Slider