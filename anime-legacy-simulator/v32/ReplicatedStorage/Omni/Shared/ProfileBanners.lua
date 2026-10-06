local v = {
	Exclusives = {},
	List = {}
}

function v.Register(name: string, state)
	if v.List[name] then
		warn((`Repeated Banner: {name}!`))
		return
	end

	state.Name = name
	state.Icon = state.Icon or "rbxassetid://132480183482160"
	state.Description = state.Description or "No description given"
	v.List[name] = state
end

for k, v2 in v.List do
	v2.Name = k

	if not v2.Icon then
		v2.Icon = "rbxassetid://132480183482160"
	end

	if not v2.Description then
		v2.Description = "No description given"
	end
end

return table.freeze(v)