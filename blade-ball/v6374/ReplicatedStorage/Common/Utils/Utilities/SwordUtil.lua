local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v2 = require3(script.Parent.FFlag)
local SwordUtil = {}

function SwordUtil.GetSwordList(_, callback)
	if not callback then
		return {}
	end

	local result = {}

	for _, v3 in v:GetCollection() do
		if not callback or callback(v3) then
			table.insert(result, v3)
		end
	end

	return result
end

function SwordUtil:GetDisabledSwords()
	local fFlag = v2.GetFFlag("DisabledSwords", "")
	return string.split(fFlag, ";") or {}
end

function SwordUtil:IsSwordDisabled(p: string?)
	if not p then
		return false
	end

	local disabledSwords = self:GetDisabledSwords()
	return table.find(disabledSwords, p) ~= nil
end

return SwordUtil