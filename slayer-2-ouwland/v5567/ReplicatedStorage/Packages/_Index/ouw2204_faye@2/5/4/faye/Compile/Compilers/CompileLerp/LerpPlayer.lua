local RunService = game:GetService("RunService")
local FayeUtility = require(script.Parent.Parent.Parent.Parent.Misc.FayeUtility)
local object = setmetatable({}, {
	__mode = "k"
})
local typeof2 = typeof

-- equivalent calls inferred from this helper; original call sites unknown
local function lerpValue(p, to, p2)
	if typeof2(p) == "number" then
		return p + (to - p) * p2
	end

	return p:Lerp(to, p2)
end

local LerpPlayer = {
	Holder = {
		Indexes = {},
		Anims = {}
	},
	Count = 0
}

function updateFunction(p: number)
	for _, index in ipairs(LerpPlayer.Holder.Indexes) do
		local anim = LerpPlayer.Holder.Anims[index]

		if anim.Last == false then
			LerpPlayer.Remove(index)
		else
			anim.Last = false

			if anim.Entity == nil or anim.Entity.Parent == nil then
				anim.Delete()
			else
				local v = 1 - (1 - anim.Factor) ^ (p * 60)
				local v2 = anim.Entity[anim.Property]
				local entity = anim.Entity
				local property = anim.Property
				local v3 = lerpValue(v2, anim.To, v) -- equivalent call inferred; original call site unknown
				entity[property] = v3
				local v4 = anim.Entity[anim.Property] == v2

				if anim.Workers then
					for i = anim.Workers.Count, 1, -1 do
						local worker = anim.Workers[i]

						if worker.Entity == nil or worker.Entity.Parent == nil then
							table.remove(anim.Workers, i)
							anim.Workers.Count -= 1
						else
							local v5 = worker.Entity[worker.Property]
							local entity2 = worker.Entity
							local property2 = worker.Property
							local v6 = lerpValue(v5, anim.To, v) -- equivalent call inferred; original call site unknown
							entity2[property2] = v6

							if worker.Entity[worker.Property] ~= v5 then
								v4 = false
							end
						end
					end
				end

				if v4 then
					if anim.IsValue then
						anim.Delete(true)
					else
						anim.Delete()
					end
				else
					anim.Last = true
				end
			end
		end
	end
end

function LerpPlayer.Add(p: string, entity, property: string, to, factor: number, isValue: boolean, delete, workers)
	local anim = LerpPlayer.Holder.Anims[p]

	if anim then
		anim.To = to
		return
	end

	if object[entity] ~= nil and object[entity][property] ~= nil then
		local v = object[entity][property]

		if v ~= p then
			local anim2 = LerpPlayer.Holder.Anims[v]

			if not anim2 then
				return
			end

			anim2.To = to
			anim2.Factor = factor
			anim2.Delete = delete
			anim2.IsValue = isValue
			anim2.Workers = workers
			anim2.Last = true
			return
		end
	end

	if object[entity] == nil then
		object[entity] = {
			Count = 0
		}
	end

	object[entity].Count += 1
	object[entity][property] = p
	table.insert(LerpPlayer.Holder.Indexes, p)
	LerpPlayer.Holder.Anims[p] = {
		Entity = entity,
		Property = property,
		Factor = factor,
		To = to,
		Last = true,
		IsValue = isValue,
		Workers = workers,
		Delete = delete
	}
	LerpPlayer.Count += 1

	if LerpPlayer.Count == 1 then
		LerpPlayer.Connection = RunService.PreRender:Connect(updateFunction)
	end
end

function LerpPlayer.Find(p)
	return FayeUtility.tf(LerpPlayer.Holder.Indexes, p), LerpPlayer.Holder.Anims[p]
end

function LerpPlayer.Remove(p)
	local v = LerpPlayer.Find(p)

	if v ~= nil then
		local anim = LerpPlayer.Holder.Anims[p]

		if anim then
			local v2 = object[anim.Entity]

			if v2 and v2[anim.Property] == p then
				v2[anim.Property] = nil
				v2.Count -= 1

				if v2.Count <= 0 then
					object[anim.Entity] = nil
				end
			end
		end

		FayeUtility.tr(LerpPlayer.Holder.Indexes, v)
		LerpPlayer.Count -= 1

		if LerpPlayer.Count == 0 and LerpPlayer.Connection ~= nil then
			LerpPlayer.Connection:Disconnect()
			LerpPlayer.Connection = nil
		end

		LerpPlayer.Holder.Anims[p] = nil
	end
end

return LerpPlayer