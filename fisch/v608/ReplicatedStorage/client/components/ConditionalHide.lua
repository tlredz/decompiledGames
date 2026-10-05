local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
local SharedDataHelper = require(ReplicatedStorage.shared.modules.SharedDataHelper)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local v = Component.new({
	Tag = "ConditionalHide",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
end

local function resolvePath(value)
	if typeof(value) == "string" then
		return value:split(".")
	end

	return value
end

local function readPath(child, path)
	if typeof(path) == "string" then
		path = path:split(".")
	end

	for _, childName in path do
		if typeof(child) == "Instance" then
			child = child:FindFirstChild(childName)
		elseif typeof(child) == "table" then
			child = child[childName]
		else
			return child
		end
	end

	return child
end

local function getValue(p)
	if p.Type == "DataInstanceValue" then
		return SharedDataHelper.readLegacyPathValue(Players.LocalPlayer, p.Path)
	end

	if p.Type == "NewFormatValue" then
		return SharedDataHelper.indexNewFormat(Players.LocalPlayer, p.Path)
	end

	if p.Type == "WorldState" then
		local v2 = readPath(ReplicatedStorage.world, p.Path)

		if v2 then
			return v2.Value
		end

		return nil
	else
		if p.Type == "WorkspaceAttribute" then
			return workspace:GetAttribute(p.Path[1])
		end

		if p.Type ~= "HasItem" then
			return nil
		end

		local indexNewFormat = SharedDataHelper.indexNewFormat(Players.LocalPlayer, { "Inventory" })

		if typeof(indexNewFormat) == "table" then
			for _, v2 in indexNewFormat do
				if typeof(v2) == "table" and v2.name == p.Path[1] then
					return true
				end
			end
		end

		return false
	end
end

local function checkCondition(p)
	local value = getValue(p)

	if p.Op == "Equal" then
		return p.Value == value
	end

	if p.Op == "NotEqual" then
		return p.Value ~= value
	end

	if p.Op == "Greater" then
		if typeof(value) == "number" then
			return p.Value < value
		end
	elseif p.Op == "Less" then
		if typeof(value) == "number" then
			return value < p.Value
		end
	elseif p.Op == "GreaterEqual" then
		if typeof(value) == "number" then
			return p.Value <= value
		end
	else
		if p.Op ~= "LessEqual" then
			return false
		end

		if typeof(value) == "number" then
			return value <= p.Value
		end
	end

	return false
end

function v:SetVisible(instance, mineable: boolean)
	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion") then
		instance.LocalTransparencyModifier = mineable and 0 or 1

		if instance:IsA("BasePart") then
			if instance:GetAttribute("OriginalCanCollide") == nil then
				instance:SetAttribute("OriginalCanCollide", instance.CanCollide)
			end

			instance.CanCollide = instance:GetAttribute("OriginalCanCollide") and mineable

			if instance:HasTag("Mineable") then
				instance:SetAttribute("Mineable", mineable)
			end
		end
	elseif instance:IsA("Sound") then
		if not instance:GetAttribute("OriginalVolume") then
			instance:SetAttribute("OriginalVolume", instance.Volume)
		end

		instance.Volume = not mineable and 0 or instance:GetAttribute("OriginalVolume") or 0
	elseif instance:IsA("Light") or instance:IsA("LayerCollector") then
		if instance:GetAttribute("OriginalEnabled") == nil then
			instance:SetAttribute("OriginalEnabled", instance.Enabled)
		end

		local enabled

		if mineable then
			enabled = instance:GetAttribute("OriginalEnabled")
		else
			enabled = false
		end

		instance.Enabled = enabled
	elseif instance:IsA("ProximityPrompt") then
		if not instance:GetAttribute("OriginalMaxActivationDistance") then
			instance:SetAttribute("OriginalMaxActivationDistance", instance.MaxActivationDistance)
		end

		instance.MaxActivationDistance = not mineable and 0 or instance:GetAttribute("OriginalMaxActivationDistance") or 0
	end
end

function v:Show()
	if self.CurrentState == true then
		return
	end

	self.CurrentState = true

	for _, descendant in self.Instance:GetDescendants() do
		self:SetVisible(descendant, true)
	end
end

function v:Hide()
	if self.CurrentState == false then
		return
	end

	self.CurrentState = false

	for _, descendant in self.Instance:GetDescendants() do
		self:SetVisible(descendant, false)
	end
end

function v:Start()
	if self.Instance:IsA("Model") and (self.Instance.ModelStreamingMode == Enum.ModelStreamingMode.Default or self.Instance.ModelStreamingMode == Enum.ModelStreamingMode.Nonatomic) then
		warn((`ConditionalHide model "{self.Instsance:GetFullName()}" is not atomic. This will result in undefined behavior!`))
	end

	local v2 = 1
	local v3 = {}

	while self.Instance:GetAttribute((`Condition{v2}Type`)) do
		table.insert(v3, {
			Type = self.Instance:GetAttribute((`Condition{v2}Type`)),
			Op = self.Instance:GetAttribute((`Condition{v2}Op`)),
			Path = self.Instance:GetAttribute((`Condition{v2}Path`)):split("."),
			Value = self.Instance:GetAttribute((`Condition{v2}Value`))
		})
		v2 += 1
	end

	if #v3 == 0 then
		warn((`No valid conditions defined for {self.Instance:GetFullName()}`))
		return
	end

	local function update()
		for _, v4 in v3 do
			if not checkCondition(v4) then
				continue
			end

			self:Hide()
			return
		end

		self:Show()
	end

	for _, v4 in v3 do
		if v4.Type == "DataInstanceValue" then
			local legacyPath = SharedDataHelper.readLegacyPath(Players.LocalPlayer, v4.Path)

			if legacyPath then
				self.trove:Connect(legacyPath.Changed, update)
			elseif v4.Path[1] == "Cache" then
				local cache = legacyLocalPlayerData.fetch():WaitForChild("Cache")
				local v5 = v4
				self.trove:Connect(cache.ChildAdded, function(p)
					if p.Name == v5.Path[2] then
						self.trove:Connect(p.Changed, update)
						update()
					end
				end)
			end
		elseif v4.Type == "NewFormatValue" then
			self.trove:Add(playerDataReplicator:Listen(v4.Path, update))
		elseif v4.Type == "HasItem" then
			self.trove:Add(playerDataReplicator:Listen({ "Inventory" }, update))
		elseif v4.Type == "WorldState" then
			local v5 = readPath(ReplicatedStorage.world, v4.Path)

			if v5 then
				self.trove:Connect(v5.Changed, update)
			end
		elseif v4.Type == "WorkspaceAttribute" then
			self.trove:Connect(workspace:GetAttributeChangedSignal(v4.Path[1]), update)
		end
	end

	self.trove:Connect(self.Instance.DescendantAdded, function(p)
		if self.CurrentState ~= nil then
			self:SetVisible(p, self.CurrentState)
		end
	end)
	update()
end

function v:Stop()
	self.trove:Clean()
	self.CurrentState = nil
end

return v