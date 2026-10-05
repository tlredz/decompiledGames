local RunService = game:GetService("RunService")
local LoopsHandler = {
	Counter = 0,
	active = {},
	mapper = {}
}

function binder(p)
	for i = #LoopsHandler.active, 1, -1 do
		local v = LoopsHandler.active[i]
		local v2 = LoopsHandler.mapper[v]

		if v2 and v2(p) then
			LoopsHandler.Remove(v)
		end
	end
end

function LoopsHandler.Add(p: string, callback)
	if table.find(LoopsHandler.active, p) then
		return
	end

	table.insert(LoopsHandler.active, p)
	LoopsHandler.mapper[p] = callback

	if LoopsHandler.Counter == 0 then
		RunService:BindToRenderStep("LoopsBinder", Enum.RenderPriority.Camera.Value, binder)
	end

	LoopsHandler.Counter += 1
end

function LoopsHandler.Remove(p: string)
	local index = table.find(LoopsHandler.active, p)

	if index == nil then
		return
	end

	table.remove(LoopsHandler.active, index)
	LoopsHandler.mapper[p] = nil
	LoopsHandler.Counter -= 1

	if LoopsHandler.Counter == 0 then
		RunService:UnbindFromRenderStep("LoopsBinder")
	end
end

return LoopsHandler