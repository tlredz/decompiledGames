local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(instance)
	local v = BaseInteractable.new()
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(instance, "Light")
	local renderSteppedConnection = nil

	function v.Run(p)
		local state = p.State

		local function SetFireState(folder, state2: boolean)
			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("Light") then
					descendant.Enabled = state2
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = state2
				elseif descendant:IsA("Sound") then
					descendant.Playing = state2
				end
			end
		end

		for _, child in instance.Fire:GetChildren() do
			SetFireState(child, state)
		end

		if state then
			TweenService:Create(
				instance.Dial.Dial.Interactive,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					CFrame = instance.Dial.Dial.Interactive.CFrame * CFrame.Angles(0, -1.3264502315156905, 0)
				}
			):Play()
			local v2 = 0
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if tick() < v2 then
					return
				end

				v2 = tick() + 0.1

				for _, folder in instance.Fire:GetChildren() do
					for _, light in folder:GetDescendants() do
						if light:IsA("Light") then
							light.Brightness = math.random(50, 150) / 100
						end
					end
				end
			end)
		else
			TweenService:Create(
				instance.Dial.Dial.Interactive,
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{
					CFrame = instance.Dial.Dial.Interactive.CFrame * CFrame.Angles(0, 1.3264502315156905, 0)
				}
			):Play()

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end
	end

	local interactives = {}

	for _, child in instance.Dial:GetChildren() do
		table.insert(interactives, child.Interactive)
	end

	for _, parent in interactives do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end