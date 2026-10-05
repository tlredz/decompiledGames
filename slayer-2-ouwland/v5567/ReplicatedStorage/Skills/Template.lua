local Template = {}
Template.Id = 0

function Template.Hold(p)
	print("hold block for ", p)
end

function Template.UnHold(p)
	print("Unhold for ", p.Name)
end

function Template.Cancel(p)
	print("Cancel block for ", p.Name)
end

return Template