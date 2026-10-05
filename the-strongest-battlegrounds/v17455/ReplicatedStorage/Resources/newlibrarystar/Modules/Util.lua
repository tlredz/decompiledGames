local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
return {
	scaleModel = function(p, p2, p3: number)
		local model = Instance.new("Model")
		model.Name = "ScaleTemp"
		model.Parent = workspace:FindFirstChild("Thrown") or workspace
		p.Parent = model
		Debris:AddItem(model, 5)
		local numberValue = Instance.new("NumberValue")
		numberValue.Parent = model
		numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			model:ScaleTo(numberValue.Value)
		end)
		TweenService:Create(numberValue, p2, {
			Value = p3
		}):Play()
	end
}