local parent = script.Parent.Parent.Parent
script.Parent.Activated:Connect(function()
	parent.AudioScrollingFrame.Visible = false
	parent.ImagesScrollingFrame.Visible = true
	parent.MeshesScrollingFrame.Visible = false
	parent.ModelsScrollingFrame.Visible = false
	parent.RigsScrollingFrame.Visible = false
	parent.RigsEditScrollingFrame.Visible = false
	parent.ToolboxCategoryFrame.ToolboxCategoryButton.Text = "Images"
	script.Parent.Parent.Visible = false
end)