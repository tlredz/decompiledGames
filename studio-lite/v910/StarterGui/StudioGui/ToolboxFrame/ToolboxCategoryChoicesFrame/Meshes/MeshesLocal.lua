local parent = script.Parent.Parent.Parent
script.Parent.Activated:Connect(function()
	parent.AudioScrollingFrame.Visible = false
	parent.ImagesScrollingFrame.Visible = false
	parent.MeshesScrollingFrame.Visible = true
	parent.ModelsScrollingFrame.Visible = false
	parent.RigsScrollingFrame.Visible = false
	parent.RigsEditScrollingFrame.Visible = false
	parent.ToolboxCategoryFrame.ToolboxCategoryButton.Text = "Meshes"
	script.Parent.Parent.Visible = false
end)