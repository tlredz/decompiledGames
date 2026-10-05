local Component = require(game.ReplicatedStorage.Modules.Component)
local Net = require(game.ReplicatedStorage.Modules.Net)
local remoteFunction = Net:RemoteFunction("ClaimBerry")
local v = 1
local random = Random.new()
local v2 = Component.new({
	Tag = "BerryBushStreamed"
})

local function loadCF(instance, cframe: CFrame)
	return instance:GetAttribute("CFrame"):ToWorldSpace(cframe)
end

function v2:SpawnBerry(instance, childName: string, cframe: CFrame)
	local clone = assert(
		game.ReplicatedStorage.Assets.Models.Berries:FindFirstChild(childName),
		(`No berry with name {childName}`)
	):Clone()
	clone.Name = math.random()
	local integer = random:NextInteger(-180, 180)
	local integer2 = random:NextInteger(-25, 25)
	clone:PivotTo(instance:GetAttribute("CFrame"):ToWorldSpace(cframe) * CFrame.new(
		0,
		clone:GetExtentsSize().Y * 0.15,
		0
	) * CFrame.Angles(0, math.rad(integer), (math.rad(integer2))))
	return clone
end

function v2:Construct()
	local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
	self.trove = Trove.new()
end

function v2:Start()
	local instance = self.Instance
	local parent = instance.Parent
	local v3 = {}
	local v4 = {}

	for k, v5 in pairs(parent:GetAttributes()) do
		if k:sub(1, 12) == "_BerryCFrame" then
			v3[k] = v5
		end
	end

	local function berriesChanged()
		for attributeName in pairs(v3) do
			local attribute = instance:GetAttribute(attributeName)
			local v5 = v4[attributeName]

			if attribute then
				if v5 and v5.Name ~= attribute then
					v4[attributeName] = nil
					self.trove:Remove(v5.Model)
				end
			elseif v5 then
				v4[attributeName] = nil
				self.trove:Remove(v5.Model)
			end
		end

		for attributeName, v5 in pairs(v3) do
			local attribute = instance:GetAttribute(attributeName)

			if not attribute or v4[attributeName] then
				continue
			end

			local berry = self:SpawnBerry(parent, attribute, v5)
			v4[attributeName] = {
				Model = berry,
				Name = attribute
			}
			self.trove:Add(berry)
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt:AddTag("ProximityPrompt")
			proximityPrompt.MaxActivationDistance = 15
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.ActionText = attribute
			local v7 = attributeName
			proximityPrompt.Triggered:Connect(function()
				local serverTimeNow = workspace:GetServerTimeNow()

				if serverTimeNow - v < 0.3 then
					print("debounce")
					return
				end

				v = serverTimeNow
				proximityPrompt.Enabled = false

				if not remoteFunction:InvokeServer(parent.Name, v7) and proximityPrompt.Parent then
					proximityPrompt.Enabled = true
				end
			end)
			proximityPrompt.Parent = berry
			berry.Parent = self.Instance
		end
	end

	self.trove:Add(function()
		table.clear(v4)
	end)
	self.trove:Add(instance.AttributeChanged:Connect(berriesChanged))
	task.spawn(berriesChanged)
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2