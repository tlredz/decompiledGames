return function(p)
	p.Following.PathRetries.Current = p.Following.PathRetries.Max

	if p.Folder ~= nil then
		p.Folder:SetAttribute("PathExhausted", nil)
	end
end