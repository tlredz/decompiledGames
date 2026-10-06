local parent = script.Parent.Parent.Parent
script.Parent.Activated:Connect(function()
	parent.AudioScrollingFrame.Visible = false
	parent.ImagesScrollingFrame.Visible = false
	parent.MeshesScrollingFrame.Visible = false
	parent.ModelsScrollingFrame.Visible = true
	parent.RigsScrollingFrame.Visible = false
	parent.RigsEditScrollingFrame.Visible = false
	parent.ToolboxCategoryFrame.ToolboxCategoryButton.Text = "Models"
	script.Parent.Parent.Visible = false
end)