local Recipebuilder = {}
Recipebuilder.__index = Recipebuilder
local count = 0

function Recipebuilder.new()
	count += 1
	return (setmetatable({
		_order = count,
		_name = nil,
		_hint = nil,
		_level = nil,
		_items = {},
		_cost = nil,
		_output = nil,
		_type = nil,
		_craftOnce = true,
		_premium = false,
		_currency = nil
	}, Recipebuilder))
end

function Recipebuilder:SetName(name)
	self._name = name
	return self
end

function Recipebuilder:SetHint(hint)
	self._hint = hint
	return self
end

function Recipebuilder:SetLevel(level)
	self._level = level
	return self
end

function Recipebuilder:SetItems(...)
	self._items = { ... }
	return self
end

function Recipebuilder:SetCost(cost)
	self._cost = cost
	return self
end

function Recipebuilder:SetOutput(output)
	self._output = output
	return self
end

function Recipebuilder:SetType(p2)
	self._type = p2
	return self
end

function Recipebuilder:SetCraftOnce(craftOnce)
	self._craftOnce = craftOnce
	return self
end

function Recipebuilder:SetPremium(premium)
	self._premium = premium
	return self
end

function Recipebuilder:SetCurrency(currency)
	self._currency = currency
	return self
end

function Recipebuilder:Build()
	return {
		Order = self._order,
		Name = self._name,
		Hint = self._hint,
		Level = self._level,
		Items = self._items,
		Cost = self._cost,
		Output = self._output,
		Type = self._type,
		CraftOnce = self._craftOnce,
		Premium = self._premium,
		Currency = self._currency
	}
end

return Recipebuilder