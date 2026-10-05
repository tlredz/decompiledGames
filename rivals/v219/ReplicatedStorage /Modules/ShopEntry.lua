local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CurrencyLibrary = require(ReplicatedStorage.Modules.CurrencyLibrary)
local ShopEntry = {}
ShopEntry.__index = ShopEntry

function ShopEntry.new(entryType, entryName, rewards, options, value, value2, p, value3, value4, value5, temp_properties)
	assert(typeof(entryType) == "string", "Argument 1 invalid, expected a string, got " .. tostring(entryType))
	assert(typeof(entryName) == "string", "Argument 2 invalid, expected a string, got " .. tostring(entryName))
	assert(typeof(rewards) == "table", "Argument 3 invalid, expected a table, got " .. tostring(rewards))
	assert(
		not options or typeof(options) == "table",
		"Argument 4 invalid, expected a table or nil, got " .. tostring(options)
	)
	assert(
		not value or typeof(value) == "number",
		"Argument 5 invalid, expected a number or nil, got " .. tostring(value)
	)
	assert(
		not value2 or typeof(value2) == "number",
		"Argument 6 invalid, expected a number or nil, got " .. tostring(value2)
	)
	assert(not p or typeof(p) == "boolean", "Argument 7 invalid, expected a boolean or nil, got " .. tostring(p))
	assert(
		not value3 or typeof(value3) == "number",
		"Argument 8 invalid, expected a number or nil, got " .. tostring(value3)
	)
	assert(
		not value4 or typeof(value4) == "number",
		"Argument 9 invalid, expected a number or nil, got " .. tostring(value4)
	)
	assert(
		not value5 or typeof(value5) == "number",
		"Argument 10 invalid, expected a number or nil, got " .. tostring(value5)
	)
	assert(
		not temp_properties or typeof(temp_properties) == "table",
		"Argument 11 invalid, expected a table or nil, got " .. tostring(temp_properties)
	)
	local self = setmetatable({}, ShopEntry)
	self.EntryType = entryType
	self.EntryName = entryName
	self.Rewards = rewards
	self.Prices = options or {}
	self.MainCurrency = nil
	self.ProductID = value or nil
	self.ProductIDTriple = value2 or nil
	self.IsLimited = p or nil
	self.PurchaseAppearTime = value3 or -1
	self.PurchaseStartTime = value4 or -1
	self.PurchaseDuration = value5 or 1e999
	self._temp_properties = temp_properties
	self:_Init()
	return self
end

function ShopEntry:_Setup()
	for k in pairs(self.Prices) do
		assert(
			CurrencyLibrary.Info[k] ~= nil,
			"Argument 4 invalid, expected a valid currency name, got " .. tostring(k)
		)

		if not self.MainCurrency or CurrencyLibrary.Info[k].OrderIndex < CurrencyLibrary.Info[self.MainCurrency].OrderIndex then
			self.MainCurrency = k
		end
	end

	assert(self.MainCurrency or self.ProductID or self.ProductIDTriple, "Argument 4 invalid, currency missing")

	for k, v in pairs(self._temp_properties or {}) do
		self[k] = v
	end

	self._temp_properties = nil
end

function ShopEntry:_Init()
	self:_Setup()
end

return ShopEntry