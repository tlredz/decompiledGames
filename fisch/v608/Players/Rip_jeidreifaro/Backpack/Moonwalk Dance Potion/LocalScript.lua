local parent = script.Parent
local serverControls = parent:WaitForChild("ServerControls", 1e999)
local animations = parent:WaitForChild("Animations")
local R6 = animations:WaitForChild("R6")
local R15 = animations:WaitForChild("R15")
local parent2 = nil
local humanoid = nil
local track = nil
serverControls.OnClientEvent:Connect(function()
	if not track then
		return
	end

	track:Play(0.1, 1, 2)
end)

function OnEquipped()
	parent2 = parent.Parent
	humanoid = parent2:FindFirstChildOfClass("Humanoid")

	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			track = humanoid:LoadAnimation(R15:WaitForChild("moonwalk"))
		else
			track = humanoid:LoadAnimation(R6:WaitForChild("moonwalk"))
		end
	end
end

function OnUnequipped()
	parent2 = nil
	humanoid = nil

	if track then
		track:Stop()
		track:Destroy()
	end

	track = nil
end

parent.Unequipped:Connect(OnUnequipped)
parent.Equipped:Connect(OnEquipped)