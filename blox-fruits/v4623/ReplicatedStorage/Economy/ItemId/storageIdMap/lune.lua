local parentModule = require(script.Parent)
local Lune = {}

for _, v in parentModule._IDS:unwrap() do
	table.insert(Lune, {
		Key = v.Id.StorageKey,
		Type = v.Id.Type
	})
end

return Lune