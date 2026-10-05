local Validation = {}
local Logger = require(script.Parent.Logger)
local Utilities = require(script.Parent.Utilities)

function Validation.validateCustomDimensions(_, p)
	return Validation:validateArrayOfStrings(20, 32, false, "custom dimensions", p)
end

function Validation.validateDimension(_, p, p2)
	if Utilities:isStringNullOrEmpty(p2) or Utilities:stringArrayContainsString(p, p2) then
		return true
	end

	return false
end

function Validation.validateResourceCurrencies(_, items)
	if not Validation:validateArrayOfStrings(20, 64, false, "resource currencies", items) then
		return false
	end

	for _, item in pairs(items) do
		if string.find(item, "^[A-Za-z]+$") then
			continue
		end

		Logger:w("resource currencies validation failed: a resource currency can only be A-Z, a-z. String was: " .. item)
		return false
	end

	return true
end

function Validation.validateResourceItemTypes(_, items)
	if not Validation:validateArrayOfStrings(20, 32, false, "resource item types", items) then
		return false
	end

	for _, item in pairs(items) do
		if Validation:validateEventPartCharacters(item) then
			continue
		end

		Logger:w("resource item types validation failed: a resource item type cannot contain other characters than A-z, 0-9, -_., ()!?. String was: " .. item)
		return false
	end

	return true
end

function Validation:validateEventPartCharacters(value)
	if string.find(value, "^[A-Za-z0-9%s%-_%.%(%)!%?]+$") then
		return true
	end

	return false
end

function Validation:validateArrayOfStrings(p, p2, p3, value, list)
	local v = value or "Array"

	if not list then
		Logger:w(v .. " validation failed: array cannot be nil.")
		return false
	end

	if not p3 and #list == 0 then
		Logger:w(v .. " validation failed: array cannot be empty.")
		return false
	end

	if p > 0 and p < #list then
		Logger:w(v .. " validation failed: array cannot exceed " .. tostring(p) .. " values. It has " .. #list .. " values.")
		return false
	end

	for _, v2 in ipairs(list) do
		local v3 = v2 and #v2 or 0

		if v3 == 0 then
			Logger:w(v .. " validation failed: contained an empty string.")
			return false
		end

		if not (p2 > 0 and p2 < v3) then
			continue
		end

		Logger:w(v .. " validation failed: a string exceeded max allowed length (which is: " .. tostring(p2) .. "). String was: " .. v2)
		return false
	end

	return true
end

function Validation.validateBuild(_, p)
	if Validation:validateShortString(p, false) then
		return true
	end

	return false
end

function Validation:validateShortString(list, p)
	if p and Utilities:isStringNullOrEmpty(list) then
		return true
	end

	return not (Utilities:isStringNullOrEmpty(list) or #list > 32)
end

function Validation.validateKeys(_, value, value2)
	if string.find(value, "^[A-Za-z0-9]+$") and #value == 32 and string.find(value2, "^[A-Za-z0-9]+$") and #value2 == 40 then
		return true
	end

	return false
end

function Validation.validateAndCleanInitRequestResponse(_, data, p)
	if not data then
		Logger:w("validateInitRequestResponse failed - no response dictionary.")
		return nil
	end

	local v = {}
	local server_ts = data.server_ts or -1

	if server_ts > 0 then
		v.server_ts = server_ts
	end

	if p then
		v.configs = data.configs or {}
		v.ab_id = data.ab_id or ""
		v.ab_variant_id = data.ab_variant_id or ""
	end

	return v
end

function Validation.validateClientTs(_, p)
	return not (p < 1000000000 or p > 9999999999)
end

function Validation:validateCurrency(value)
	if Utilities:isStringNullOrEmpty(value) then
		return false
	end

	if string.find(value, "^[A-Z]+$") and #value == 3 then
		return true
	end

	return false
end

function Validation:validateEventPartLength(list, p)
	if p and Utilities:isStringNullOrEmpty(list) then
		return true
	end

	return not Utilities:isStringNullOrEmpty(list) and #list ~= 0 and not (#list > 64)
end

function Validation.validateBusinessEvent(_, p, p2, p3, p4, p5)
	if not Validation:validateCurrency(p) then
		Logger:w("Validation fail - business event - currency: Cannot be (null) and need to be A-Z, 3 characters and in the standard at openexchangerates.org. Failed currency: " .. p)
		return false
	end

	if p2 < 0 then
		Logger:w("Validation fail - business event - amount: Cannot be less then 0. Failed amount: " .. p2)
		return false
	end

	if not Validation:validateShortString(p3, true) then
		Logger:w("Validation fail - business event - cartType. Cannot be above 32 length. String: " .. p3)
		return false
	end

	if not Validation:validateEventPartLength(p4, false) then
		Logger:w("Validation fail - business event - itemType: Cannot be (null), empty or above 64 characters. String: " .. p4)
		return false
	end

	if not Validation:validateEventPartCharacters(p4) then
		Logger:w("Validation fail - business event - itemType: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p4)
		return false
	end

	if not Validation:validateEventPartLength(p5, false) then
		Logger:w("Validation fail - business event - itemId. Cannot be (null), empty or above 64 characters. String: " .. p5)
		return false
	end

	if Validation:validateEventPartCharacters(p5) then
		return true
	end

	Logger:w("Validation fail - business event - itemId: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p5)
	return false
end

function Validation.validateResourceEvent(_, p, p2, p3, p4, p5, p6, p7, p8)
	if p2 ~= p.Source and p2 ~= p.Sink then
		Logger:w("Validation fail - resource event - flowType: Invalid flow type " .. tostring(p2))
		return false
	end

	if Utilities:isStringNullOrEmpty(p3) then
		Logger:w("Validation fail - resource event - currency: Cannot be (null)")
		return false
	end

	if not Utilities:stringArrayContainsString(p7, p3) then
		Logger:w("Validation fail - resource event - currency: Not found in list of pre-defined available resource currencies. String: " .. p3)
		return false
	end

	if not (p4 > 0) then
		Logger:w("Validation fail - resource event - amount: Float amount cannot be 0 or negative. Value: " .. tostring(p4))
		return false
	end

	if Utilities:isStringNullOrEmpty(p5) then
		Logger:w("Validation fail - resource event - itemType: Cannot be (null)")
		return false
	end

	if not Validation:validateEventPartLength(p5, false) then
		Logger:w("Validation fail - resource event - itemType: Cannot be (null), empty or above 64 characters. String: " .. p5)
		return false
	end

	if not Validation:validateEventPartCharacters(p5) then
		Logger:w("Validation fail - resource event - itemType: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p5)
		return false
	end

	if not Utilities:stringArrayContainsString(p8, p5) then
		Logger:w("Validation fail - resource event - itemType: Not found in list of pre-defined available resource itemTypes. String: " .. p5)
		return false
	end

	if not Validation:validateEventPartLength(p6, false) then
		Logger:w("Validation fail - resource event - itemId: Cannot be (null), empty or above 64 characters. String: " .. p6)
		return false
	end

	if Validation:validateEventPartCharacters(p6) then
		return true
	end

	Logger:w("Validation fail - resource event - itemId: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p6)
	return false
end

function Validation.validateProgressionEvent(_, data, p, p2, p3, p4)
	if p ~= data.Start and p ~= data.Complete and p ~= data.Fail then
		Logger:w("Validation fail - progression event: Invalid progression status " .. tostring(p))
		return false
	end

	if not Utilities:isStringNullOrEmpty(p4) and Utilities:isStringNullOrEmpty(p3) and not Utilities:isStringNullOrEmpty(p2) then
		Logger:w("Validation fail - progression event: 03 found but 01+02 are invalid. Progression must be set as either 01, 01+02 or 01+02+03.")
		return false
	end

	if not Utilities:isStringNullOrEmpty(p3) and Utilities:isStringNullOrEmpty(p2) then
		Logger:w("Validation fail - progression event: 02 found but not 01. Progression must be set as either 01, 01+02 or 01+02+03")
		return false
	end

	if Utilities:isStringNullOrEmpty(p2) then
		Logger:w("Validation fail - progression event: progression01 not valid. Progressions must be set as either 01, 01+02 or 01+02+03")
		return false
	end

	if not Validation:validateEventPartLength(p2, false) then
		Logger:w("Validation fail - progression event - progression01: Cannot be (null), empty or above 64 characters. String: " .. p2)
		return false
	end

	if not Validation:validateEventPartCharacters(p2) then
		Logger:w("Validation fail - progression event - progression01: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p2)
		return false
	end

	if not Utilities:isStringNullOrEmpty(p3) then
		if not Validation:validateEventPartLength(p3, false) then
			Logger:w("Validation fail - progression event - progression02: Cannot be empty or above 64 characters. String: " .. p3)
			return false
		end

		if not Validation:validateEventPartCharacters(p3) then
			Logger:w("Validation fail - progression event - progression02: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p3)
			return false
		end
	end

	if Utilities:isStringNullOrEmpty(p4) then
		return true
	end

	if not Validation:validateEventPartLength(p4, false) then
		Logger:w("Validation fail - progression event - progression03: Cannot be empty or above 64 characters. String: " .. p4)
		return false
	end

	if not Validation:validateEventPartCharacters(p4) then
		Logger:w("Validation fail - progression event - progression03: Cannot contain other characters than A-z, 0-9, -_., ()!?. String: " .. p4)
		return false
	end

	return true
end

function Validation:validateEventIdLength(value)
	if Utilities:isStringNullOrEmpty(value) then
		return false
	end

	local count = 0

	for k in string.gmatch(value, "([^:]+)") do
		count += 1

		if count > 5 or #k > 64 then
			return false
		end
	end

	return true
end

function Validation:validateEventIdCharacters(value)
	if Utilities:isStringNullOrEmpty(value) then
		return false
	end

	local count = 0

	for k in string.gmatch(value, "([^:]+)") do
		count += 1

		if count > 5 or not string.find(k, "^[A-Za-z0-9%s%-_%.%(%)!%?]+$") then
			return false
		end
	end

	return true
end

function Validation.validateDesignEvent(_, p)
	if not Validation:validateEventIdLength(p) then
		Logger:w("Validation fail - design event - eventId: Cannot be (null) or empty. Only 5 event parts allowed seperated by :. Each part need to be 32 characters or less. String: " .. p)
		return false
	end

	if Validation:validateEventIdCharacters(p) then
		return true
	end

	Logger:w("Validation fail - design event - eventId: Non valid characters. Only allowed A-z, 0-9, -_., ()!?. String: " .. p)
	return false
end

function Validation:validateLongString(list, p)
	if p and Utilities:isStringNullOrEmpty(list) then
		return true
	end

	return not (Utilities:isStringNullOrEmpty(list) or #list > 8192)
end

function Validation.validateErrorEvent(_, data, p, p2)
	if p ~= data.debug and p ~= data.info and p ~= data.warning and p ~= data.error and p ~= data.critical then
		Logger:w("Validation fail - error event - severity: Severity was unsupported value " .. tostring(p))
		return false
	end

	if Validation:validateLongString(p2, true) then
		return true
	end

	Logger:w("Validation fail - error event - message: Message cannot be above 8192 characters.")
	return false
end

return Validation