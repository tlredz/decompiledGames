local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local BaseInteractable = require(script.Parent.BaseInteractable)
local misc = ReplicatedStorage.Assets.Misc
return function(instance)
	local v = BaseInteractable.new()
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(instance, "Light")
	local C0 = script.Example.LightSwitches.LightSwitch.Union.Interactive.C0

	for _, child in instance.LightSwitches:GetChildren() do
		local clone = script.Example.LightSwitches.LightSwitch:Clone()
		clone:PivotTo(child:GetPivot() * CFrame.Angles(0, 3.141592653589793, 0))
		clone.Parent = child.Parent
		child:Destroy()
	end

	function v.Run(p, flag: boolean?)
		local state = p.State

		local function SetLightState(child, state2: boolean)
			child.Material = state2 and Enum.Material.Neon or Enum.Material.SmoothPlastic

			for _, light in child:GetChildren() do
				if light:IsA("Light") then
					light.Enabled = state2
				end
			end
		end

		for _, child in instance.Lights:GetChildren() do
			SetLightState(child, state)
		end

		for _, child in instance.LightSwitches:GetChildren() do
			TweenService:Create(child.Union.Interactive, TweenInfo.new(0.1), {
				C0 = C0 * CFrame.Angles(math.rad(state and 5 or -5), 0, 0)
			}):Play()

			if flag then
				continue
			end

			if state then
			end

			child.Interactive.Off:Play()
		end
	end

	local interactives = {}

	for _, child in instance.LightSwitches:GetChildren() do
		table.insert(interactives, child.Interactive)
	end

	for _, parent in interactives do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		local v3 = parent
		clickDetector.MouseClick:Connect(function()
			if not localPlayer.Character:GetAttribute("NoInteractablesHouse") then
				v:ToggleState()
				return
			end

			local clone = misc.BLACKOUT_INTERACTABLE:Clone()
			clone.Parent = v3.Parent:FindFirstChild("Union", true)
			clone.Sound:Play()
			task.wait(0.05)
			clone.ParticleEmitter:Emit(1)
			Debris:AddItem(clone, 2)
		end)
	end

	return v
end