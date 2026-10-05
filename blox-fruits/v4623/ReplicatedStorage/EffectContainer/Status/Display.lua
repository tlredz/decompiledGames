local Instance = require(script.Instance)
return function(p)
	local v = Instance.new(p.Type)
	v.Anchor = p.Anchor
	v:Play()
end