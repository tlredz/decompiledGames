local parent = script.Parent.Parent.Parent
script.Parent.Activated:Connect(function()
	parent.AudioScrollingFrame.Visible = false
	parent.ImagesScrollingFrame.Visible = false
	parent.MeshesScrollingFrame.Visible = false
	parent.ModelsScrollingFrame.Visible = false
	parent.RigsScrollingFrame.Visible = true
	parent.RigsEditScrollingFrame.Visible = false
	parent.ToolboxCategoryFrame.ToolboxCategoryButton.Text = "Rig Builder"
	script.Parent.Parent.Visible = false
end)