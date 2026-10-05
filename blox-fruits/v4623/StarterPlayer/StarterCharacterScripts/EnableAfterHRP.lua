game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local FunctionQueue = require(game.ReplicatedStorage.Util.FunctionQueue)
local v = FunctionQueue.new(2, "EnableAfterHRP")

local function childAdded(instance)
	if instance:GetAttribute("Enabled") then
		if instance.Name == "Animate" then
			instance.Disabled = false
		end

		v(function()
			instance.Disabled = false
		end)
	end
end

script.Parent.ChildAdded:Connect(childAdded)

for _, child in pairs(script.Parent:GetChildren()) do
	if not child:GetAttribute("Enabled") then
		continue
	end

	if child.Name == "Animate" then
		child.Disabled = false
	else
		local v2 = child
		v(function()
			v2.Disabled = false
		end)
	end
end