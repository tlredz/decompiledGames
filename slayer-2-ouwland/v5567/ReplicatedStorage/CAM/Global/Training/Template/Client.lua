local Template = {}

function Template.Do(_, _, _, _)
	warn("Start client")
end

function Template.Stop(_, _, _)
	warn("Stop client")
end

return Template