local HudHideCore = {
	new = function()
		return {
			claims = {},
			seq = 0,
			hidden = {}
		}
	end,
	isKept = function(value: string, list)
		if not list then
			return false
		end

		for _, v in ipairs(list) do
			if value == v or string.sub(value, 1, #v) == v then
				return true
			end
		end

		return false
	end
}

function HudHideCore.shouldHide(p: string, flag: boolean, p2)
	return flag == true and not HudHideCore.isKept(p, p2)
end

function HudHideCore.isHiding(p)
	return next(p.claims) ~= nil
end

function HudHideCore:claim(p: string)
	local v = not HudHideCore.isHiding(self)
	self.seq += 1
	self.claims[self.seq] = p
	return self.seq, v
end

function HudHideCore.release(p, p2: number)
	if p.claims[p2] == nil then
		return false
	end

	p.claims[p2] = nil
	return not HudHideCore.isHiding(p)
end

function HudHideCore.releaseOwner(p, p2: string)
	local v = false

	for k, claim in pairs(p.claims) do
		if claim ~= p2 then
			continue
		end

		p.claims[k] = nil
		v = true
	end

	return v and not HudHideCore.isHiding(p)
end

function HudHideCore.recordHidden(p, p2)
	p.hidden[p2] = {
		yielded = false
	}
end

function HudHideCore.noteExternalShow(p, p2)
	local v = p.hidden[p2]

	if v then
		v.yielded = true
	end
end

function HudHideCore:takeRestoreList(callback)
	local result = {}

	for k, v in pairs(self.hidden) do
		if v.yielded or callback(k) ~= false then
			continue
		end

		table.insert(result, k)
	end

	self.hidden = {}
	return result
end

return HudHideCore