local BetterAnalyticsService = {}
local BetterAnalyticsServiceConfig = require(script.Parent:WaitForChild("BetterAnalyticsServiceConfig"))
local debugMode = BetterAnalyticsServiceConfig.DebugMode
local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function matchType(p, p2)
	local typeName = typeof(p)

	if typeName == p2 then
		return true
	end

	return false, typeName
end

function BetterAnalyticsService.sanitizeCustomFieldValue(value)
	if typeof(value) ~= "string" then
		value = tostring(value)
	end

	local v = string.gsub(value, ",", "+")
	local v2 = string.gsub(v, "[\"']", "")

	if #v2 > 100 then
		return (string.sub(v2, 1, 100))
	end

	return v2
end

local function sanitizeCustomFields(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		if typeof(k) == "string" and item ~= nil then
			result[k] = BetterAnalyticsService.sanitizeCustomFieldValue(item)
		end
	end

	return result
end

function BetterAnalyticsService:LogEconomyEvent(instance, flowType: string, currencyType: string, amount: number, endingBalance: number, transactionType: string, itemSku: string, p7)
	if typeof(instance) ~= "Instance" or instance.Parent ~= Players then
		warn("Player Instance is not valid")
		return
	end

	local success, result = pcall(function()
		return Enum.AnalyticsEconomyFlowType[flowType]
	end)

	if not success then
		warn(string.format([[
%s is not a valid Transaction Type.
Refer to https://create.roblox.com/docs/reference/engine/enums/AnalyticsEconomyFlowType for more information.]], flowType))
		return
	end

	local typeName = typeof(currencyType)
	local v

	if typeName == "string" then
		v = true
		typeName = nil
	else
		v = false
	end

	if not v then
		warn(string.format("Invalid argument #3 to 'LogEconomyEvent' (string expected, got %s)", typeName))
		return
	end

	local typeName2 = typeof(amount)
	local v2

	if typeName2 == "number" then
		v2 = true
		typeName2 = nil
	else
		v2 = false
	end

	if not v2 then
		warn(string.format("Invalid argument #4 to 'LogEconomyEvent' (number expected, got %s)", typeName2))
		return
	end

	local typeName3 = typeof(endingBalance)
	local v3

	if typeName3 == "number" then
		v3 = true
		typeName3 = nil
	else
		v3 = false
	end

	if not v3 then
		warn(string.format("Invalid argument #5 to 'LogEconomyEvent' (number expected, got %s)", typeName3))
		return
	end

	local success2, result2 = pcall(function()
		return Enum.AnalyticsEconomyTransactionType[transactionType]
	end)

	if not success2 then
		warn(string.format([[
%s is not a valid Transaction Type.
Refer to https://create.roblox.com/docs/reference/engine/enums/AnalyticsEconomyTransactionType for more information.]], transactionType))
		return
	end

	if itemSku ~= nil then
		local typeName4 = typeof(itemSku)
		local v4

		if typeName4 == "string" then
			v4 = true
			typeName4 = nil
		else
			v4 = false
		end

		if not v4 then
			warn(string.format("Invalid argument #7 to 'LogEconomyEvent' (string expected, got %s)", typeName4))
			return
		end
	end

	local customFields = sanitizeCustomFields(p7)
	local success3, result3 = pcall(function()
		AnalyticsService:LogEconomyEvent(
			instance,
			result,
			currencyType,
			amount,
			endingBalance,
			result2.Name,
			itemSku,
			customFields
		)
	end)

	if not success3 then
		error(result3)
		return
	end

	if debugMode then
		local v5 = {
			player = instance.UserId,
			flowType = flowType,
			currencyType = currencyType,
			amount = amount,
			endingBalance = endingBalance,
			transactionType = transactionType,
			itemSku = itemSku,
			customFields = customFields
		}
		print("Published the following data to Roblox using 'LogEconomyEvent':")
		print(v5)
	end

	return result3
end

function BetterAnalyticsService:LogFunnelStepEvent(instance, funnelName: string, funnelSessionId: string, step: number, stepName: string, p5)
	if typeof(instance) ~= "Instance" or instance.Parent ~= Players then
		warn("Player Instance is not valid")
		return
	end

	local typeName = typeof(funnelName)
	local v

	if typeName == "string" then
		v = true
		typeName = nil
	else
		v = false
	end

	if not v then
		warn(string.format("Invalid argument #2 to 'LogFunnelStepEvent' (string expected, got %s)", typeName))
		return
	end

	if funnelSessionId == nil then
		funnelSessionId = HttpService:GenerateGUID()
	else
		local typeName2 = typeof(funnelSessionId)
		local v2

		if typeName2 == "string" then
			v2 = true
			typeName2 = nil
		else
			v2 = false
		end

		if not v2 then
			warn(string.format([[
Invalid argument #3 to 'LogFunnelStepEvent' (string expected, got %s):
Using HttpService:GenerateGUID() as fallback]], typeName2))
			funnelSessionId = HttpService:GenerateGUID()
		end
	end

	local typeName2 = typeof(step)
	local v2

	if typeName2 == "number" then
		v2 = true
		typeName2 = nil
	else
		v2 = false
	end

	if not v2 then
		warn(string.format("Invalid argument #4 to 'LogFunnelStepEvent' (number expected, got %s)", typeName2))
		return
	end

	local typeName3 = typeof(stepName)
	local v3

	if typeName3 == "string" then
		v3 = true
		typeName3 = nil
	else
		v3 = false
	end

	if not v3 then
		warn(string.format("Invalid argument #5 to 'LogFunnelStepEvent' (string expected, got %s)", typeName3))
		return
	end

	local customFields = sanitizeCustomFields(p5)
	local success, result = pcall(function()
		AnalyticsService:LogFunnelStepEvent(instance, funnelName, funnelSessionId, step, stepName, customFields)
	end)

	if not success then
		error(result)
		return
	end

	if debugMode then
		local v5 = {
			player = instance.UserId,
			funnelName = funnelName,
			funnelSessionId = funnelSessionId,
			step = step,
			stepName = stepName,
			customFields = customFields
		}
		print("Published the following data to Roblox using 'LogFunnelStepEvent':")
		print(v5)
	end

	return result
end

function BetterAnalyticsService:LogOnboardingFunnelStepEvent(instance, step: number, stepName: string, p3)
	if typeof(instance) ~= "Instance" or instance.Parent ~= Players then
		warn("Player Instance is not valid")
		return
	end

	local typeName = typeof(step)
	local v

	if typeName == "number" then
		v = true
		typeName = nil
	else
		v = false
	end

	if not v then
		warn(string.format("Invalid argument #2 to 'LogFunnelStepEvent' (number expected, got %s)", typeName))
		return
	end

	local typeName2 = typeof(stepName)
	local v2

	if typeName2 == "string" then
		v2 = true
		typeName2 = nil
	else
		v2 = false
	end

	if not v2 then
		warn(string.format("Invalid argument #3 to 'LogFunnelStepEvent' (string expected, got %s)", typeName2))
		return
	end

	local customFields = sanitizeCustomFields(p3)
	local success, result = pcall(function()
		AnalyticsService:LogOnboardingFunnelStepEvent(instance, step, stepName, customFields)
	end)

	if not success then
		error(result)
		return
	end

	if debugMode then
		local v4 = {
			player = instance.UserId,
			step = step,
			stepName = stepName,
			customFields = customFields
		}
		print("Published the following data to Roblox using 'LogOnboardingFunnelStepEvent':")
		print(v4)
	end

	return result
end

function BetterAnalyticsService:LogCustomEvent(instance, event_name: string, p2: number, p3)
	if typeof(instance) ~= "Instance" or instance.Parent ~= Players and event_name ~= "PlayerLeft" then
		warn("Player Instance is not valid")
		return
	end

	local typeName = typeof(event_name)
	local v

	if typeName == "string" then
		v = true
		typeName = nil
	else
		v = false
	end

	if not v then
		warn(string.format("Invalid argument #2 to 'LogCustomEvent' (string expected, got %s)", typeName))
		return
	end

	local typeName2 = typeof(p2)
	local v2

	if typeName2 == "number" then
		v2 = true
		typeName2 = nil
	else
		v2 = false
	end

	if not v2 then
		warn(string.format("Invalid argument #3 to 'LogCustomEvent' (number expected, got %s)", typeName2))
		return
	end

	local customFields = sanitizeCustomFields(p3)
	local success, result = pcall(function()
		AnalyticsService:LogCustomEvent(instance, event_name, p2, customFields)
	end)

	if not success then
		error(result)
		return
	end

	if debugMode then
		local v4 = {
			player = instance.UserId,
			event_name = event_name,
			value = p2,
			customFields = customFields
		}
		print("Published the following data to Roblox using 'LogCustomEvent':")
		print(v4)
	end

	return result
end

return BetterAnalyticsService