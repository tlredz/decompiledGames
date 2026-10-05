local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"))
local BaseInteractable = require(script.Parent.BaseInteractable)
TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
return function(p)
	local v = BaseInteractable.new()
	local v2 = v:Replace(p, script.Example)

	function v.Run(p2)
		if p2.State then
			v2.FakeCoffee.Transparency = 0
			v2.CoffeePot.Brew:Play()
			TweenService:Create(v2.Button, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = v2.Button.CFrame * CFrame.new(-0.07, 0, 0)
			}):Play()
			TweenService:Create(v2.Stream.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = v2.Stream.Mesh.Scale + createVector(0.4, 0, 0.4)
			}):Play()
			TweenService:Create(
				v2.FakeCoffee.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Scale = v2.FakeCoffee.Mesh.Scale + createVector(0, 0.3, 0)
				}
			):Play()
			TweenService:Create(
				v2.FakeCoffee.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Offset = v2.FakeCoffee.Mesh.Offset + createVector(0, 0.03, 0)
				}
			):Play()
			task.wait(0.5)
			TweenService:Create(
				v2.FakeCoffee.Mesh,
				TweenInfo.new(3.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Scale = v2.FakeCoffee.Mesh.Scale + createVector(0, 2.16, 0)
				}
			):Play()
			TweenService:Create(
				v2.FakeCoffee.Mesh,
				TweenInfo.new(3.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Offset = v2.FakeCoffee.Mesh.Offset + createVector(0, 0.216, 0)
				}
			):Play()
			task.wait(3.6)
			TweenService:Create(v2.Stream.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = createVector(0, 1, 0)
			}):Play()
			TweenService:Create(
				v2.FakeCoffee.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Scale = v2.FakeCoffee.Mesh.Scale + createVector(0, 0.3, 0)
				}
			):Play()
			TweenService:Create(
				v2.FakeCoffee.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Offset = v2.FakeCoffee.Mesh.Offset + createVector(0, 0.03, 0)
				}
			):Play()
			task.wait(0.5)
			v2.Coffee.Transparency = 0
			task.wait()
			v2.FakeCoffee.Transparency = 1
			v2.FakeCoffee.Mesh.Scale = createVector(1, 0, 1)
			v2.FakeCoffee.Mesh.Offset = createVector(0, 0, 0)
		else
			TweenService:Create(v2.Button, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = v2.Button.CFrame * CFrame.new(0.07, 0, 0)
			}):Play()
			v2.Coffee.Transparency = 1
		end
	end

	for _, parent in { v2.Button } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function(_)
			v:ToggleState()
		end)
	end

	return v
end