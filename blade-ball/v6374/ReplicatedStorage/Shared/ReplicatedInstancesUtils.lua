local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3("./ReplicatedInstances")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local v2 = require3("./InstanceSerde")
local v3 = RunService:IsStudio() and 30 or 1800
local deserializedInstances

if RunService:IsServer() then
	deserializedInstances = ServerStorage.DeserializedInstances
else
	deserializedInstances = ReplicatedStorage2:WaitForChild("DeserializedInstances")
end

local frozen = table.freeze({ "Titan Blade" })
local v4 = {}
local v5 = {}
local v6 = {}

local function resetClear(p: string, p2: string)
	local formatted = `{p}/{p2}`

	if v6[formatted] then
		task.cancel(v6[formatted])
		v6[formatted] = nil
	end

	v6[formatted] = task.delay(v3, function()
		v6[`{p}/{p2}`] = nil
		local v7 = v4[formatted]

		if v7 then
			v7:Destroy()
			v4[formatted] = nil
		end
	end)
end

return {
	getInstance = function(p: string, p2: string)
		local formatted = `{p}/{p2}`
		local instance = v:GetInstance(p, p2)

		if not instance then
			return nil
		end

		local v7 = instance:IsA("StringValue") or instance:IsA("ModuleScript")
		local deserialized

		if v7 then
			local v8 = v4[formatted]

			if v8 then
				resetClear(p, p2)
				return v8
			end

			if v5[formatted] then
				local lastTime = os.clock()

				while v5[formatted] do
					if os.clock() - lastTime > 600 then
						return nil
					else
						task.wait()
					end
				end

				return v4[formatted]
			else
				v5[formatted] = true
				deserialized = v2.deserialize(instance)

				for k, v9 in instance:GetAttributes() do
					deserialized:SetAttribute(k, v9)
				end

				deserialized.Parent = deserializedInstances
			end
		else
			deserialized = instance
		end

		if p == "Swords" then
			deserialized:AddTag(table.find(frozen, p2) and "ExceptionVFX" or "SwordModel")

			for _, part in deserialized:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.Massless = true
				part.RootPriority = -1
				part.CanCollide = false
			end
		elseif p == "Explosions" then
			for _, descendant in deserialized:GetDescendants(), nil, nil do
				if descendant:IsA("BasePart") then
					if not descendant:FindFirstAncestorWhichIsA("Model") then
						descendant.Anchored = true
						descendant.CanCollide = false
						descendant.CanQuery = false
						descendant.CanTouch = false
					end
				elseif (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) and descendant.Enabled then
					descendant.Enabled = false
					descendant:SetAttribute("_particleWasEnabled", true)
				end
			end
		elseif p == "EmoteAccessories" or p == "SwordAccessories" or p == "EmoteVFX" then
			for _, v8 in deserialized:QueryDescendants("BasePart"), nil, nil do
				v8.Massless = true
				v8.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0)
				v8.RootPriority = -1
				v8.CanCollide = false
				v8.Anchored = false
			end
		end

		if v7 then
			v4[formatted] = deserialized
			v5[formatted] = nil
			resetClear(p, p2)
		end

		return deserialized
	end
}