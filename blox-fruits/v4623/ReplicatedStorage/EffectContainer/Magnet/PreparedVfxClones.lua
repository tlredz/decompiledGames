local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PrepareClonedInstances = require(ReplicatedStorage.Util.PrepareClonedInstances)
local PreparedVfxClones = {}
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function removeState(p: string, p2: string, p3)
	local v2 = v[p]

	if not v2 or v2[p2] ~= p3 then
		return
	end

	v2[p2] = nil

	if next(v2) == nil then
		v[p] = nil
	end
end

function PreparedVfxClones:destroy()
	if not self or self.Destroyed then
		return
	end

	self.Destroyed = true

	for _, bucket in self.Buckets do
		bucket.Pool:Destroy()
	end

	table.clear(self.Buckets)
end

function PreparedVfxClones.begin(p: string, p2: string, items)
	local v2 = v[p]

	if not v2 then
		v2 = {}
		v[p] = v2
	end

	local v3 = v2[p2]

	if v3 then
		PreparedVfxClones.destroy(v3)
	end

	local buckets = {}

	for k, item in items do
		local v5 = table.create(item.Count)
		local templates = item.Templates

		for i = 1, item.Count do
			local template = item.Template

			if not template then
				assert(templates and #templates > 0, (`Prepared VFX clone bucket {k} needs a template`))
				template = templates[math.random(1, #templates)]
			end

			assert(template)
			v5[i] = item.Prepare and {
				Template = template,
				Prepare = item.Prepare
			} or template
		end

		buckets[k] = {
			Pool = PrepareClonedInstances.new(v5),
			Remaining = item.Count
		}
	end

	local v5 = {
		Buckets = buckets,
		Destroyed = false
	}
	v2[p2] = v5
	return v5
end

function PreparedVfxClones.claim(p: string, p2: string)
	local v2 = v[p]
	local selected

	if v2 then
		selected = v2[p2]
	end

	local v4 = selected and v[p]

	if not (v4 and v4[p2] == selected) then
		return selected
	end

	v4[p2] = nil

	if next(v4) == nil then
		v[p] = nil
	end

	return selected
end

function PreparedVfxClones.discard(p: string, p2: string, p3)
	local v2 = v[p]

	if not v2 or v2[p2] ~= p3 then
		return
	end

	removeState(p, p2, p3) -- equivalent call inferred; original call site unknown
	PreparedVfxClones.destroy(p3)
end

function PreparedVfxClones.take(p, p2: string, instance)
	if not p or p.Destroyed then
		return instance:Clone()
	end

	local bucket = p.Buckets[p2]

	if not bucket or bucket.Remaining <= 0 then
		return instance:Clone()
	end

	bucket.Remaining -= 1
	return (bucket.Pool:Take())
end

return PreparedVfxClones