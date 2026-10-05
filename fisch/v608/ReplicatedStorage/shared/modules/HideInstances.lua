local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.packages.Observers)
return function(instance)
	if not RunService:IsClient() then
		warn((`Can't call HideInstances in Server!\n{debug.traceback()}`))
		return function() end
	end

	local v = "__hidden" .. math.floor((os.clock())) .. math.random(0, 100)

	for k, _ in instance:GetAttributes() do
		if string.match(k, "__hidden(%d*)") then
			return function() end
		end
	end

	instance:SetAttribute(v, true)
	local v2 = Observers.observeDescendants(instance, function(instance2)
		if instance2:IsA("BasePart") or instance2:IsA("Texture") or instance2:IsA("Decal") then
			local localTransparencyModifier = instance2.LocalTransparencyModifier
			local preRenderConnection = RunService.PreRender:Connect(function()
				instance2.LocalTransparencyModifier = 1
			end)
			return function()
				instance2.LocalTransparencyModifier = localTransparencyModifier
				preRenderConnection:Disconnect()
			end
		else
			if instance2:IsA("ParticleEmitter") or instance2:IsA("Trail") then
				local preRenderConnection = RunService.PreRender:Connect(function()
					instance2:Clear()
				end)
				return function()
					preRenderConnection:Disconnect()
				end
			end

			if not ((instance2:IsA("Beam") or instance2:IsA("BillboardGui")) and instance2.Enabled) then
				return nil
			end

			instance2.Enabled = false
			return function()
				instance2.Enabled = true
			end
		end
	end)
	local attributeChangedConnection = nil
	attributeChangedConnection = instance.AttributeChanged:Connect(function(attributeName: string)
		if string.match(attributeName, "__hidden(%d*)") and not instance:GetAttribute(attributeName) then
			local v3 = false

			for k, _ in instance:GetAttributes() do
				if not string.match(k, "__hidden(%d*)") then
					continue
				end

				v3 = true
				break
			end

			if not v3 then
				if attributeChangedConnection then
					attributeChangedConnection:Disconnect()
					attributeChangedConnection = nil
				end

				v2()
			end
		end
	end)
	return function()
		instance:SetAttribute(v, nil)
	end
end