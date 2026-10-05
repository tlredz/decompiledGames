local MoonflowerPlant = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local instances = {}

function OpenFlower(instance)
	local moonflowerBulb = instance:WaitForChild("Moonflower Bulb")

	if moonflowerBulb:IsA("Model") then
		moonflowerBulb:SetAttribute("Interaction", "Item")
	elseif moonflowerBulb:IsA("ObjectValue") then
		moonflowerBulb.Value:SetAttribute("Interaction", "Item")
	end

	if instance.PrimaryPart then
		for _, child in pairs(instance.PrimaryPart:GetChildren()) do
			if child.Name == "OpenParticles" then
				child.Enabled = true
			end
		end
	end

	for _, child in pairs(instance:WaitForChild("Petals"):GetChildren()) do
		local originalCF = child:GetAttribute("OriginalCF")

		if not originalCF then
			child:SetAttribute("OriginalCF", child:GetPivot())
			originalCF = child:GetPivot()
		end

		local v = child
		Client.TweenModule.new(function(p)
			local v2 = p * 90
			v:PivotTo(originalCF * CFrame.Angles(math.rad(-v2), 0, 0))
		end, 3, "Quad", "InOut"):Play()
	end
end

function CloseFlower(instance)
	local moonflowerBulb = instance:WaitForChild("Moonflower Bulb")

	if moonflowerBulb:IsA("Model") then
		moonflowerBulb:SetAttribute("Interaction", "NightPlant")
	elseif moonflowerBulb:IsA("ObjectValue") then
		moonflowerBulb.Value:SetAttribute("Interaction", "NightPlant")
	end

	if instance.PrimaryPart then
		for _, child in pairs(instance.PrimaryPart:GetChildren()) do
			if child.Name == "OpenParticles" then
				child.Enabled = false
			end
		end
	end

	for _, child in pairs(instance:WaitForChild("Petals"):GetChildren()) do
		local originalCF = child:GetAttribute("OriginalCF")

		if not originalCF then
			child:SetAttribute("OriginalCF", child:GetPivot())
			originalCF = child:GetPivot()
		end

		local v = child
		Client.TweenModule.new(function(p)
			local v2 = (1 - p) * 90
			v:PivotTo(originalCF * CFrame.Angles(math.rad(-v2), 0, 0))
		end, 3, "Quad", "InOut"):Play()
	end
end

function TimeSet(p)
	local v = 1

	while instances[v] do
		local v2 = instances[v]

		if v2.Parent == nil then
			table.remove(instances, v)
		else
			if p == "Day" then
				CloseFlower(v2)
			elseif p == "Night" then
				OpenFlower(v2)
			end

			v += 1
		end
	end
end

function MoonflowerPlant.Added(instance)
	table.insert(instances, instance)
	local moonflowerBulb = instance:WaitForChild("Moonflower Bulb")

	if moonflowerBulb:IsA("Model") then
		moonflowerBulb:SetAttribute("Interaction", "NightPlant")
	elseif moonflowerBulb:IsA("ObjectValue") then
		moonflowerBulb.Value:SetAttribute("Interaction", "NightPlant")
	end

	task.spawn(function()
		if workspace:GetAttribute("State") == "Night" then
			task.wait(3)

			if workspace:GetAttribute("State") == "Night" then
				OpenFlower(instance)
			end
		end
	end)
end

function MoonflowerPlant.Init()
	workspace:GetAttributeChangedSignal("State"):Connect(function()
		if workspace:GetAttribute("State") == "Night" then
			task.wait(5)
		end

		TimeSet(workspace:GetAttribute("State"))
	end)
end

return MoonflowerPlant