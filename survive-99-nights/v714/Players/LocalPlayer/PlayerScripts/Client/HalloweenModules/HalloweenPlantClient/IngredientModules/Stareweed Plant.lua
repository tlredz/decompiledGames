local StareweedPlant = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function SetPetalWidth(instance, p, p2)
	for _, child in pairs(instance:GetChildren()) do
		if not (child.Name == "Eye" or child.Name == "Inner") then
			continue
		end

		local originalSize = child:GetAttribute("OriginalSize")

		if not originalSize then
			child:SetAttribute("OriginalSize", child.Size)
			originalSize = child.Size
		end

		local v = child
		Client.TweenModule.new(function(p3)
			if p2 then
				p3 = 1 - p3 or p3
			end

			local v2 = (p - 1) * p3

			if v.Name == "Eye" then
				v2 *= 0.9
			end

			v.Size = originalSize * Vector3.new(1, 1, 1 + v2)
		end, 3, "Quad", "InOut"):Play()
	end
end

function FlowerLitUp(instance)
	if instance:GetAttribute("Open") then
		return
	end

	instance:SetAttribute("Open", true)

	for _, objectValue in pairs(instance:GetChildren()) do
		if objectValue.Name == "Stareweed Petal" and objectValue:IsA("ObjectValue") and objectValue.Value ~= nil then
			SetPetalWidth(objectValue.Value, 4)
		end
	end

	task.wait(3)

	if not instance.Parent then
		return
	end

	for _, objectValue in pairs(instance:GetChildren()) do
		if objectValue.Name == "Stareweed Petal" and objectValue:IsA("ObjectValue") and objectValue.Value ~= nil then
			objectValue.Value:AddTag("Interaction")
		end
	end

	task.wait(15)

	if not instance.Parent then
		return
	end

	for _, objectValue in pairs(instance:GetChildren()) do
		if objectValue.Name == "Stareweed Petal" and objectValue:IsA("ObjectValue") and objectValue.Value ~= nil then
			objectValue.Value:RemoveTag("Interaction")
		end
	end

	for _, objectValue in pairs(instance:GetChildren()) do
		if objectValue.Name == "Stareweed Petal" and objectValue:IsA("ObjectValue") and objectValue.Value ~= nil then
			SetPetalWidth(objectValue.Value, 4, true)
		end
	end

	task.wait(3)

	if not instance.Parent then
		return
	end

	instance:SetAttribute("Open", nil)
end

Client.Events.StareweedLitUp:Connect(FlowerLitUp)

function StareweedPlant.Added(instance)
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if otherPart.Name == "TorchTouchZone" and not instance:GetAttribute("Open") then
			Client.Events.LightUpStareweed:FireServer(instance)
			FlowerLitUp(instance)
		end
	end)
end

function StareweedPlant.Init() end

return StareweedPlant