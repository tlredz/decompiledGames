local QuickChatConfig = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
QuickChatConfig.remoteConfigDirectory = "QuickChat"
QuickChatConfig.isPublic = true
QuickChatConfig.isLoaded = false
QuickChatConfig.cache = nil
QuickChatConfig.middlewares = {}
local mapped = t.map(t.string, t.array(t.string))

local function isFilteredMessagesConfig(p)
	return mapped(p)
end

function QuickChatConfig.GetConfig()
	while not QuickChatConfig.isLoaded do
		task.wait()
	end

	return QuickChatConfig.cache
end

local function getFilteredMessagesByCategory()
	local config = QuickChatConfig.GetConfig()
	assert(t.table(config), "QuickChatConfig root must be a table")
	local messages = config.Messages

	if messages == nil then
		return {}
	end

	assert(mapped(messages), "QuickChatConfig.Messages must be a map<string, string[]>")
	return messages
end

function QuickChatConfig.GetMessages()
	local filteredMessagesByCategory = getFilteredMessagesByCategory()
	local result = {}

	for k, v in filteredMessagesByCategory do
		for _, text in v do
			table.insert(result, {
				Text = text,
				Category = k
			})
		end
	end

	return result
end

function QuickChatConfig.IsValidMessage(p: string)
	local filteredMessagesByCategory = getFilteredMessagesByCategory()

	for _, list in filteredMessagesByCategory do
		if table.find(list, p) ~= nil then
			return true
		end
	end

	return false
end

function QuickChatConfig.IsValidFilter(p: string)
	return getFilteredMessagesByCategory()[p] ~= nil
end

function QuickChatConfig.IsMessageInFilter(p: string, p2: string)
	local v = getFilteredMessagesByCategory()[p2]
	return v ~= nil and table.find(v, p) ~= nil
end

return QuickChatConfig