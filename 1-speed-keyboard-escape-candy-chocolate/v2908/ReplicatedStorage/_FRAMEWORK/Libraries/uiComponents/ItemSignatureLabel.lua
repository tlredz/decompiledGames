local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AsyncUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.AsyncUtils)
local v = {}
local texts = {}
local v2 = {}

local function applyUsername(p: number, text: string)
	texts[p] = text
	v[p] = nil
	local v3 = v2[p] or {}
	v2[p] = nil

	for _, v4 in v3 do
		local v5 = v4
		pcall(function()
			v5.Text = text
		end)
	end
end

local function bindUsername(clone, userId: number)
	local text = texts[userId]

	if text then
		clone.Text = text
		return
	end

	local v4 = v2[userId] or {}
	v2[userId] = v4
	table.insert(v4, clone)

	if not v[userId] then
		v[userId] = true
		AsyncUtils.getUsernameByUserId(userId):andThen(function(text2: string)
			applyUsername(userId, text2)
		end):catch(function()
			applyUsername(userId, tostring(userId))
		end)
	end
end

local function itemSignatureLabel(p)
	local clone = ReplicatedStorage.Templates.ItemSignatureLabel:Clone()
	clone.Visible = true
	bindUsername(clone, p.userId)
	return clone
end

return itemSignatureLabel