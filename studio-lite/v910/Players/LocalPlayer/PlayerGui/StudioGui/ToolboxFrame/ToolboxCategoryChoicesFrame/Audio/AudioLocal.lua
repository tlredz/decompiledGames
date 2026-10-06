local parent = script.Parent.Parent.Parent
script.Parent.Activated:Connect(function()
	parent.AudioScrollingFrame.Visible = true
	parent.ImagesScrollingFrame.Visible = false
	parent.MeshesScrollingFrame.Visible = false
	parent.ModelsScrollingFrame.Visible = false
	parent.RigsScrollingFrame.Visible = false
	parent.RigsEditScrollingFrame.Visible = false
	parent.ToolboxCategoryFrame.ToolboxCategoryButton.Text = "Audio"
	script.Parent.Parent.Visible = false
end)