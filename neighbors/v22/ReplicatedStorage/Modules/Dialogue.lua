local Dialogue = {}

function Dialogue.Reply(content, next, condition)
	return {
		Type = "Reply",
		Content = content,
		Next = next,
		Condition = condition
	}
end

function Dialogue.Action(callback)
	return {
		Type = "Action",
		Callback = callback
	}
end

function Dialogue.Condition(callback)
	return {
		Type = "Condition",
		Callback = callback
	}
end

function Dialogue.Response(content)
	return {
		Type = "Response",
		Content = content
	}
end

return Dialogue