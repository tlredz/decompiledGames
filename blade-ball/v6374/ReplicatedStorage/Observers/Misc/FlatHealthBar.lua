local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("FlatHealthBar", function(instance)
	local healthBarHolder = instance:WaitForChild("HealthBarHolder", 5)
	local value = healthBarHolder and healthBarHolder.Value

	if not value then
		return
	end

	local function onHealthUpdate(flag: boolean?)
		local health = value:GetAttribute("Health") or 100
		local maxHealth = value:GetAttribute("MaxHealth") or 100
		local v = 1 - health / maxHealth
		instance.ProgressBar.TextLabel.Text = `{health}/{maxHealth}`
		local v2 = flag and 0 or 0.5
		instance.ProgressBar.Holder:TweenPosition(
			UDim2.fromScale(-v, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			v2,
			true
		)
		instance.ProgressBar.Holder.Fill:TweenPosition(
			UDim2.fromScale(v, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			v2,
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