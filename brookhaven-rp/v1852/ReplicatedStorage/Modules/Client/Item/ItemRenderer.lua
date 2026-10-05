local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Item.Item)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local ItemRenderer = {
	VEHICLES_CONTEXT = {
		__itemRendererContext = true
	},
	TOOLS_CONTEXT = {
		__itemRendererContext = true
	},
	PROPS_CONTEXT = {
		__itemRendererContext = true
	},
	HOUSES_CONTEXT = {
		__itemRendererContext = true
	},
	EMOTES_CONTEXT = {
		__itemRendererContext = true
	}
}
local v = {
	Vehicles = ItemRenderer.VEHICLES_CONTEXT,
	Tools = ItemRenderer.TOOLS_CONTEXT,
	Props = ItemRenderer.PROPS_CONTEXT,
	Houses = ItemRenderer.HOUSES_CONTEXT,
	Emotes = ItemRenderer.EMOTES_CONTEXT
}
ItemRenderer._Renderers = {}

function ItemRenderer.GetContext(p: string)
	return v[p]
end

function ItemRenderer.RegisterRenderer(p, p2, callback)
	local _Renderer = ItemRenderer._Renderers[p]

	if _Renderer == nil then
		_Renderer = {}
		ItemRenderer._Renderers[p] = _Renderer
	end

	assert(_Renderer[p2] == nil, "renderer already exists")
	_Renderer[p2] = callback
end

function ItemRenderer.Render(p, p2, p3)
	assert(p3, "Rendering nil item")
	local _Renderer = ItemRenderer._Renderers[p]

	if _Renderer == nil then
		return true
	end

	local descendants = Object.Descendants(p3)
	local v2 = true

	for i = #descendants, 1, -1 do
		local v3 = _Renderer[descendants[i]]

		if v3 == nil then
			continue
		end

		v2 = v2 and v3(p3, p2)

		if not v2 then
			break
		end
	end

	return v2
end

return ItemRenderer