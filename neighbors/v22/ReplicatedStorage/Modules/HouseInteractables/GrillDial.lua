local TweenService = game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local House = require(game.ReplicatedStorage.Modules.Neighbors.House)
local FastSignal = require(game.ReplicatedStorage.Modules.FastSignal)
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v = FastSignal.new()
local connections = {}

local function activeHouseChanged()
	local currentHouse = House:GetCurrentHouse()

	if currentHouse then
		local interactables = currentHouse.Server:FindFirstChild("Interactables")
		task.defer(function()
			if interactables:GetAttribute("Watered") then
				v:Fire(true)
			end
		end)
		table.insert(connections, interactables:GetAttributeChangedSignal("Watered"):Connect(function()
			if interactables:GetAttribute("Watered") then
				v:Fire(true)
			else
				v:Fire(false)
			end
		end))
	else
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
		v:Fire(false)
	end
end

if House:GetCurrentHouse() then
	activeHouseChanged(House:GetCurrentHouse())
end

House.ActiveHouseChanged:Connect(activeHouseChanged)
return function(p)
	local v2 = BaseInteractable.new()
	local v3 = false

	function v2.Run(p2)
		if p2.State then
			p.Interactive.Click:Play()
			TweenService:Create(p.Interactive, tweenInfo, {
				CFrame = p.Interactive.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()

			if not v3 then
				p.Interactive.Burner:Play()

				for _, child in pairs(p.Flames:GetChildren()) do
					if child.Name ~= "Flame" then
						continue
					end

					for _, child2 in pairs(child:GetChildren()) do
						child2.Rate = 1000
					end
				end
			end
		else
			p.Interactive.Click:Play()
			p.Interactive.Burner:Stop()
			TweenService:Create(p.Interactive, tweenInfo, {
				CFrame = p.Interactive.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()

			for _, child in pairs(p.Flames:GetChildren()) do
				if child.Name ~= "Flame" then
					continue
				end

				for _, child2 in pairs(child:GetChildren()) do
					child2.Rate = 0
				end
			end
		end
	end

	v:Connect(function(p2)
		v3 = p2

		if not v3 and v2.State then
			p.Interactive.Burner:Play()
		end

		if v3 then
			p.Interactive.Burner:Stop()
		end

		for _, child in pairs(p.Flames:GetChildren()) do
			if child.Name ~= "Flame" then
				continue
			end

			for _, child2 in pairs(child:GetChildren()) do
				child2.Rate = p2 and 0 or v2.State and 1000 or 0
			end
		end
	end)

	function v2.Reset(_) end

	for _, parent in { p.Interactive } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			v2:ToggleState()
		end)
	end

	return v2
end