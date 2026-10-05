-- equivalent calls inferred from this helper; original call sites unknown
local function index(value: string)
	return (`|{value:gsub("|", "\\|")}`)
end

local function addLock(instance, attributeName: string, value: string?)
	local attribute = tostring(instance:GetAttribute(attributeName) or "")
	local v = index(value or "Default") -- equivalent call inferred; original call site unknown

	if not attribute:find(v) then
		instance:SetAttribute(attributeName, attribute .. v)
	end
end

local function removeLock(instance, attributeName: string, value: string?)
	local attribute = tostring(instance:GetAttribute(attributeName) or "")
	local v = index(value or "Default") -- equivalent call inferred; original call site unknown

	if attribute:find(v) then
		instance:SetAttribute(attributeName, (attribute:gsub(v, "")))
	end
end

local function hasLock(instance, attributeName: string, value: string?)
	local attribute = tostring(instance:GetAttribute(attributeName) or "")

	if value then
		return attribute:find((`|{value:gsub("|", "\\|")}`)) ~= nil
	end

	return attribute ~= ""
end

local function getLockChangedSignal(object, p: string)
	return object:GetAttributeChangedSignal(p)
end

return table.freeze({
	AddLock = addLock,
	HasLock = hasLock,
	RemoveLock = removeLock,
	GetLockChangedSignal = getLockChangedSignal,
	DefaultKey = "Default"
})