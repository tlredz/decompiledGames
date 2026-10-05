local TemplateServer = {}
TemplateServer.Id = {}

function TemplateServer.Hold(p, _, _)
	print("hold block for ", p)
end

function TemplateServer.UnHold(p, _, _)
	print("Unhold for ", p.Name)
end

function TemplateServer.Cancel(p, _, _)
	print("Cancel block for ", p.Name)
end

return TemplateServer