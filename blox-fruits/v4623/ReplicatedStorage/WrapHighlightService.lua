local RunService = game:GetService("RunService")
local ServiceProxy = require(game.ReplicatedStorage.Packages.ServiceProxy)
local v = nil
local class = {}
class.__index = class

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false
	local _DescAddedConnection = self._DescAddedConnection

	if _DescAddedConnection then
		_DescAddedConnection:Disconnect()
	end

	table.clone(self)
end

function class:GetIfInitialized()
	return v ~= nil and v._IsAlive == true
end

function class:TryWrap(highlight)
	if RunService:IsServer() then
		if typeof(highlight) == "Instance" and highlight:IsA("Highlight") then
			return highlight
		end

		warn((`bad target: {highlight}`))
		return nil
	else
		if typeof(highlight) == "number" then
			return self._IdLookup[highlight]
		end

		if highlight:IsA("Highlight") then
			return highlight
		end

		if highlight:FindFirstChild("IsOriginal") then
			local v2 = self._HighlightData[highlight]

			if not v2 then
				warn("Couldn't get highlight data?", highlight and highlight:GetFullName() or nil)
			end

			return v2
		else
			local spawnedHighlight = highlight:FindFirstChild("SpawnedHighlight")

			if spawnedHighlight then
				assert(spawnedHighlight:IsA("ObjectValue"), (`bad spawned reference: {spawnedHighlight:GetFullName()}`))
				local value = spawnedHighlight.Value

				if not value then
					return nil
				end

				assert(value:IsA("Highlight"), (`bad highlight: {value:GetFullName()}`))
				return value
			else
				local original = highlight:GetAttribute("Original")
				assert(typeof(original) == "number", (`no Original for {highlight:GetFullName()}`))
				local v2 = self:TryWrap(original)
				assert(v2, (`couldn't find highlight at proxy {highlight:GetAttribute("Original")}`))
				local clone = v2:Clone()
				local fillColor = highlight:FindFirstChild("FillColor")

				if fillColor and fillColor:IsA("Color3Value") then
					clone.FillColor = fillColor.Value
				end

				local outlineColor = highlight:FindFirstChild("OutlineColor")

				if outlineColor and outlineColor:IsA("Color3Value") then
					clone.OutlineColor = outlineColor.Value
				end

				clone.Parent = highlight.Parent
				local objectValue = Instance.new("ObjectValue", highlight)
				objectValue.Name = "SpawnedHighlight"
				objectValue.Value = clone
				highlight.Name = "__HighlightProxyWarning__"
				return clone
			end
		end
	end
end

function class.new()
	local object = setmetatable({
		_IsAlive = true,
		_IdLookup = {},
		_HighlightData = {},
		_DescAddedConnection = nil
	}, class)

	if RunService:IsClient() then
		local v2 = 1

		local function registerHighlightProxy(highlight)
			if highlight:IsA("Highlight") then
				if highlight:GetAttribute("proxyhighlight") then
					return
				end

				local clone = script.HighlightProxyWarning:Clone()
				clone.IsOriginal.Archivable = false
				clone.Parent = highlight.Parent
				clone.Name = highlight.Name
				local color3Value = Instance.new("Color3Value")
				color3Value.Name = "FillColor"
				color3Value.Value = highlight.FillColor
				color3Value.Parent = clone
				local color3Value2 = Instance.new("Color3Value")
				color3Value2.Name = "OutlineColor"
				color3Value2.Value = highlight.OutlineColor
				color3Value2.Parent = clone
				clone:SetAttribute("Original", v2)
				object._IdLookup[v2] = highlight
				v2 += 1
				task.defer(function()
					highlight.Parent = nil
				end)
				local ancestryChangedConnection = nil
				ancestryChangedConnection = clone.AncestryChanged:Connect(function(_, parent)
					if not parent then
						ancestryChangedConnection:Disconnect()
						object._IdLookup[v2] = nil
						object._HighlightData[clone] = nil
					end
				end)
				object._HighlightData[clone] = highlight
			end
		end

		for _, descendant in pairs(game.ReplicatedStorage:GetDescendants()) do
			registerHighlightProxy(descendant)
		end

		object._DescAddedConnection = game.ReplicatedStorage.DescendantAdded:Connect(function(descendant)
			registerHighlightProxy(descendant)
		end)
	end

	if not v then
		v = object
		return object
	end

	local v2 = v
	v = object
	v2:Destroy()
	return object
end

function class.init()
	if class:GetIfInitialized() and v then
		return function()
			v:Destroy()
		end
	end

	local v2 = class.new()
	return function()
		v2:Destroy()
	end
end

return ServiceProxy(function()
	return v or class
end)