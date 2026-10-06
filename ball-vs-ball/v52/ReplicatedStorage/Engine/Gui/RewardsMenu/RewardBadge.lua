local v = {}
local v2 = nil
local bindableEvent = Instance.new("BindableEvent")

local function setNotices(object, p: number)
	object:clearNotices()

	if p <= 0 then
		return
	end

	local parentIconUID = object.parentIconUID
	object.parentIconUID = nil

	for _ = 1, p do
		object:notify(bindableEvent.Event)
	end

	object.parentIconUID = parentIconUID
	object.noticeChanged:Fire(object.totalNotices)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshRoot()
	if not v2 then
		return
	end

	local count = 0

	for _, v3 in v do
		if v3.count > 0 then
			count += 1
		end
	end

	setNotices(v2, count)
end

local RewardBadge = {}

function RewardBadge.SetRoot(p)
	v2 = p
	refreshRoot() -- equivalent call inferred; original call site unknown
end

function RewardBadge.Set(p: string, icon, count: number)
	local v3 = v[p]

	if v3 and v3.icon == icon and v3.count == count then
		return
	end

	v[p] = {
		icon = icon,
		count = count
	}
	setNotices(icon, count)
	refreshRoot() -- equivalent call inferred; original call site unknown
end

return RewardBadge