local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("LiveEventHealthBar", function(instance)
	local healthBarHolder = instance:WaitForChild("HealthBarHolder", 5)
	local value = healthBarHolder and healthBarHolder.Value

	if not value then
		return
	end

	local function onHealthUpdate(_: boolean?)
		local health = value:GetAttribute("Health") or 100
		local maxHealth = value:GetAttribute("MaxHealth") or 100
		instance.Frame.BossHealth.TileSize = UDim2.new(1 / maxHealth, 0, 1, 0)
		instance.Frame.BossHealth.Bars.TileSize = UDim2.new(1 / health, 0, 1, 0)
		instance.Frame.BossHealth.Bars.Size = UDim2.fromScale(health / maxHealth, 1)
	end

	local healthChangedConnection = value:GetAttributeChangedSignal("Health"):Connect(onHealthUpdate)
	local maxHealthChangedConnection = value:GetAttributeChangedSignal("MaxHealth"):Connect(onHealthUpdate)
	task.spawn(onHealthUpdate, true)
	return function()
		healthChangedConnection:Disconnect()
		maxHealthChangedConnection:Disconnect()
	end
end)