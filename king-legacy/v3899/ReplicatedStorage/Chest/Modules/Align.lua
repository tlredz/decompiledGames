return {
	Create = function(p, _)
		if p ~= "AlignPosition" then
			return
		end

		local alignPosition = Instance.new("AlignPosition")
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		return alignPosition
	end
}