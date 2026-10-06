local v = {
	List = {
		["Pirate King"] = {
			Index = 1,
			Description = "Complete the Heaven Island main quest."
		},
		Hashira = {
			Index = 2,
			Description = "Complete the Slayers Village main quest."
		}
	}
}

for k, v2 in v.List do
	v2.Name = k

	if not v2.Icon then
		v2.Icon = "rbxassetid://94901905310190"
	end

	if not v2.Description then
		v2.Description = "No description given"
	end
end

return table.freeze(v)