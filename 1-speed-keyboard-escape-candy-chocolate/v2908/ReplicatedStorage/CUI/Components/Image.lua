require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Image", "Image")

	function extended:Init()
		self._CurrentLoadingId = ""
	end

	function extended.SetImage(p2, image: string)
		p2.UI.Ctn.ImageLabel.Image = image
		return p2
	end

	function extended.GetImage(p2)
		return p2.UI.Ctn.ImageLabel.Image
	end

	function extended.SetImageColor(p2, imageColor: Color3)
		p2.UI.Ctn.ImageLabel.ImageColor3 = imageColor
		return p2
	end

	function extended.GetImageColor(p2)
		return p2.UI.Ctn.ImageLabel.ImageColor3
	end

	function extended.SetImageTransparency(p2, imageTransparency: number)
		p2.UI.Ctn.ImageLabel.ImageTransparency = imageTransparency
		return p2
	end

	function extended.GetImageTransparency(p2)
		return p2.UI.Ctn.ImageLabel.ImageTransparency
	end

	function extended.SetHeight(p2, p3: number)
		p2.UI.Size = UDim2.new(1, 0, 0, p3)
		return p2
	end

	function extended.SetPaddingScale(p2, p3: number)
		p2.UI.Ctn.Size = UDim2.fromScale(1 - p3, 1 - p3)
		return p2
	end

	function extended.MakeItFit(p2)
		local uIAspectRatioConstraint = p2.UI.Ctn:FindFirstChild("UIAspectRatioConstraint")

		if uIAspectRatioConstraint then
			uIAspectRatioConstraint:Destroy()
		end

		p2.UI.Ctn.ImageLabel.ScaleType = Enum.ScaleType.Crop
		return p2
	end

	return extended
end