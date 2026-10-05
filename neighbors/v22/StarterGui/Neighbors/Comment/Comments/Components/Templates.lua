local comment = script:FindFirstAncestorOfClass("Frame").List.Comment
comment.Parent = nil
return {
	CommentTemplate = comment
}