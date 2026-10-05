require(script.Parent.Parent.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Parent.Parent.Misc.FayeUtility)
return function(instance, p2, p3)
	local cleanThread = instance.CleanThread or instance.Thread
	local v = {
		Instance = instance,
		Index = 0
	}
	local v2

	if FayeUtility.tof(p2) ~= FayeUtility.numbertxt then
		v2 = p2 or nil
	end

	v.Index = v2
	local v3 = nil
	local fn

	fn = function()
		if p3 ~= nil and p3.Entries ~= nil then
			local v4 = FayeUtility.tf(p3.Entries, v)

			if v4 ~= nil then
				FayeUtility.tr(p3.Entries, v4)
				p3.Entries.Count -= 1

				if p3.Entries.Count == 0 then
					p3.Entries.Count = nil
					p3.Entries = nil
				end
			end
		end

		FayeUtility.RemoveFromEntity(instance, fn)
		FayeUtility.RemoveFromThread(v3, fn)

		if v ~= nil then
			if v.Thread ~= nil then
				FayeUtility.CallDestroy(v.Thread)
				v.Thread = nil
			end

			FayeUtility.tc(v)
			v = nil
		end
	end

	if p3.Entries == nil then
		p3.Entries = {
			Count = 0
		}
	end

	p3.Entries[p3.Entries.Count + 1] = v
	p3.Entries.Count += 1
	FayeUtility.AddToEntity(instance, fn)

	if cleanThread ~= nil then
		v3 = cleanThread

		if v3._isCleanAncestor then
			local parentThread = v3

			while parentThread ~= nil and not parentThread._hc do
				parentThread = parentThread.ParentThread
			end

			v3 = parentThread or v3
		end

		FayeUtility.AddToThread(v3, fn)
	end
end