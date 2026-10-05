local Template = {}

function Template.Do(_, _, _, _, _)
	warn("Start server")
	return true, false
end

function Template.StateChanged(_, _, _, ...)
	warn("State changed server")
end

function Template.Destroying(_, _, _, _)
	warn("Destroying server")
end

function Template.Stop(_, _, _, ...)
	warn("Stop server")
	return true
end

return Template