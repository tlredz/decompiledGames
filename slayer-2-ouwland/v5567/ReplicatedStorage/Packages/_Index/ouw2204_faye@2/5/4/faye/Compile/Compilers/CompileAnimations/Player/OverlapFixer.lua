local AnimatorStorage = require(script.Parent.AnimatorStorage)
local OverlapFixer = {}

function OverlapFixer.Add(p, p2: string, callback)
	if AnimatorStorage.Active[p] ~= nil and AnimatorStorage.Active[p][p2] ~= nil then
		local v = AnimatorStorage.Active[p][p2]
		AnimatorStorage.Active[p][p2] = nil
		AnimatorStorage.Active[p].Count -= 1
		v()
	end

	if AnimatorStorage.Active[p] == nil then
		AnimatorStorage.Active[p] = {
			Count = 0
		}
	end

	AnimatorStorage.Active[p].Count += 1
	AnimatorStorage.Active[p][p2] = callback
end

function OverlapFixer.Remove(p, p2: string)
	local v = AnimatorStorage.Active[p]

	if not v then
		return
	end

	if v[p2] ~= nil then
		v[p2] = nil
		v.Count -= 1
	end

	if v.Count <= 0 then
		AnimatorStorage.Active[p] = nil
	end
end

return OverlapFixer