local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("ClassicHealthBar", function(instance)
	local healthBarHolder = instance:WaitForChild("HealthBarHolder", 5)
	local value = healthBarHolder and healthBarHolder.Value

	if not value then
		return
	end

	local function onHealthUpdate(flag: boolean?)
		local health = value:GetAttribute("Health") or 100
		local maxHealth = value:GetAttribute("MaxHealth") or 100
		instance.Health.Fill:TweenSize(
			UDim2.fromScale(health / maxHealth, 1),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			flag and 0 or 0.5,
			true
		)
	end

	local healthChangedConnection = value:GetAttributeChangedSignal("Health"):Connect(onHealthUpdate)
	local maxHealthChangedConnection = value:GetAttributeChangedSignal("MaxHealth"):Connect(onHealthUpdate)
	task.spawn(onHealthUpdate, true)
	return function()
		healthChangedConnection:Disconnect()
		maxHealthChangedConnection:Disconnect()
	end
end)