local createVector = vector.create
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(instance)
	local v = BaseInteractable.new()
	local clone = script.Example:Clone()
	clone:PivotTo(instance:GetPivot())
	clone.Parent = instance.Parent
	clone.Name = instance.Name
	instance:Destroy()
	local clones = {}

	function v.Run(p)
		if p.State then
			clone.Button.Down.TimePosition = 0.4
			clone.Button.Down:Play()
			TweenService:Create(clone.Button, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = clone.Button.Position - createVector(0, 0.4, 0)
			}):Play()

			for _, child in clone:GetChildren() do
				if child.Name ~= "Bread" then
					continue
				end

				local clone2 = child:Clone()
				clone2.Name = "ToastClone"
				clone2.Transparency = 0
				clone2.CanCollide = true
				clone2.Anchored = true
				clone2.Parent = clone
				table.insert(clones, clone2)
			end
		else
			clone.Button.Up:Play()
			TweenService:Create(
				clone.Button,
				TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Position = clone.Button.Position + createVector(0, 0.4, 0)
				}
			):Play()

			for _, v2 in clones do
				v2.Position += createVector(0, 0.5, 0)
				v2.Anchored = false
				v2:ApplyImpulse((Vector3.new(0, math.random(5, 15), 0)))
				game.Debris:AddItem(v2, 7)
				TweenService:Create(
					v2,
					TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 4),
					{
						Transparency = 1
					}
				):Play()
			end

			clones = {}
		end
	end

	for _, parent in { clone.Button } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end