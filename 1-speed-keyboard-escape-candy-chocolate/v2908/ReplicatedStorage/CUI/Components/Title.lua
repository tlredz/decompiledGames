require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Title", "Title")

	function extended.SetTitle(p2, p3: string)
		p2.UI.TextLabel.Text = "•   " .. p3
		return p2
	end

	function extended.SetTitleVisible(p2, visible: boolean)
		p2.UI.TextLabel.Visible = visible
		return p2
	end

	return extended
end