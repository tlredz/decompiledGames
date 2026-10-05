local HudNavigation = {
	handlers = {},
	available = {},
	states = {},
	wallet = {
		loaded = false,
		coins = 0,
		gems = 0
	},
	Changed = Instance.new("BindableEvent"),
	Opening = Instance.new("BindableEvent"),
	Notice = Instance.new("BindableEvent")
}

function HudNavigation.register(p, p2)
	HudNavigation.handlers[p] = p2
	HudNavigation.Changed:Fire(p)
end

function HudNavigation.setAvailable(p, p2)
	local v = p2 == true

	if HudNavigation.available[p] ~= v then
		HudNavigation.available[p] = v
		HudNavigation.Changed:Fire(p)
	end
end

function HudNavigation.setState(p, p2)
	if HudNavigation.states[p] ~= p2 then
		HudNavigation.states[p] = p2
		HudNavigation.Changed:Fire(p)
	end
end

function HudNavigation.setWallet(p, value, value2)
	HudNavigation.wallet = {
		loaded = p == true,
		coins = value or 0,
		gems = value2 or 0
	}
	HudNavigation.Changed:Fire("Wallet")
end

function HudNavigation.activate(p)
	if HudNavigation.available[p] and HudNavigation.handlers[p] then
		HudNavigation.handlers[p]()
	end
end

function HudNavigation.opening(p)
	HudNavigation.Opening:Fire(p)
end

return HudNavigation