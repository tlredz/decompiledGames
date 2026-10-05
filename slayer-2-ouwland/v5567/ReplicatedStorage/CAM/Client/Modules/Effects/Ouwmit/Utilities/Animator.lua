local remove = table.remove
local find = table.find
local RunService = game:GetService("RunService")
local insert = table.insert
local v = nil
v = {
	Counter = 0,
	Holder = {},
	Update = function(p)
		for i = #v.Holder, 1, -1 do
			local v2 = v.Holder[i]

			if v2 == nil then
				continue
			end

			local success, result = pcall(v2, p)

			if not success then
				warn("Ouwmit animator step failed: " .. tostring(result))
			end
		end
	end
}

function v.Add(callback)
	if callback == nil then
		return
	end

	insert(v.Holder, callback)
	v.Counter += 1

	if v.Counter == 1 then
		RunService:BindToRenderStep("OuwmitAnimator", Enum.RenderPriority.Last.Value, v.Update)
	end
end

function v.Remove(callback)
	if callback == nil then
		return
	end

	local index = find(v.Holder, callback)

	if index == nil then
		return
	end

	remove(v.Holder, index)
	v.Counter -= 1

	if v.Counter == 0 then
		RunService:UnbindFromRenderStep("OuwmitAnimator")
	end
end

return v