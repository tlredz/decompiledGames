local TweenService = game:GetService("TweenService")
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local EffectStack = {}
EffectStack.__index = EffectStack
local tweenInfo = TweenInfo.new(0)
local v = {
	BasePart = { "Color", "Transparency" }
}

-- equivalent calls inferred from this helper; original call sites unknown
local function roundDecimals(p)
	return (tonumber(string.format("%.2f", p)))
end

function EffectStack.new(instance)
	local self = setmetatable({}, EffectStack)
	self._tick = 0
	self._instance = instance
	self._stack = {}
	self._originalState = {}
	return self
end

function EffectStack:_recordOriginalState(folder)
	local function recordState(instance)
		for className, v2 in v do
			if not instance:IsA(className) then
				continue
			end

			self._originalState[instance] = {}

			for _, v3 in v2 do
				local color = instance[v3]

				if v3 == "Color" then
					local v4 = roundDecimals(color.R) -- equivalent call inferred; original call site unknown
					local v5 = roundDecimals(color.G) -- equivalent call inferred; original call site unknown
					local B = color.B
					color = Color3.new(v4, v5, (tonumber(string.format("%.2f", B))))
				elseif v3 == "Transparency" then
					color = tonumber(string.format("%.2f", color))
				end

				self._originalState[instance][v3] = color
			end

			break
		end
	end

	recordState(folder)

	for _, descendant in folder:GetDescendants() do
		recordState(descendant)
	end
end

function EffectStack:ReflectState()
	self:_resetState()

	for _, v2 in self._stack do
		v2.EffectFunction(self._instance, v2)
	end
end

function EffectStack:_resetState()
	if self._originalState then
		for k, v2 in self._originalState do
			for k2, v3 in v2 do
				TweenService:Create(k, tweenInfo, {
					[k2] = v3
				}):Play()
			end
		end
	end
end

function EffectStack:AddInstance(folder)
	self:_recordOriginalState(folder)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = folder.AncestryChanged:Connect(function(_, parent)
		if not parent then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil

			if self._originalState then
				for _, descendant in folder:GetDescendants() do
					if self._originalState[descendant] then
						self._originalState[descendant] = nil
					end
				end
			end
		end
	end)
end

function EffectStack:Add(name, effectFunction)
	if not effectFunction then
		return warn("forgot to pass an effect function for", name)
	end

	if #self._stack == 0 then
		self:_recordOriginalState(self._instance)
	end

	self._tick += 1
	local _tick = self._tick
	local maid = Trove.new()
	table.insert(self._stack, {
		Name = name,
		EffectFunction = effectFunction,
		Id = _tick,
		Trove = maid,
		Data = {}
	})
	maid:Add(function()
		for k, v2 in self._stack do
			if v2.Id ~= _tick then
				continue
			end

			table.remove(self._stack, k)
			break
		end

		if not self._dead then
			self:ReflectState()
		end
	end)
	self:ReflectState()
end

function EffectStack:Remove(p2)
	for _, v2 in self._stack do
		if v2.Name ~= p2 then
			continue
		end

		v2.Trove:Destroy()
		break
	end
end

function EffectStack:Destroy()
	self._dead = true

	for i = #self._stack, 1, -1 do
		self._stack[i].Trove:Destroy()
	end

	self:_resetState()
	self._originalState = nil
end

return EffectStack