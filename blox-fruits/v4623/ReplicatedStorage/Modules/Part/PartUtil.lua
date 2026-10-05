return {
	weld = function(parent, part, C0: CFrame?)
		local weld = Instance.new("Weld", parent)

		if C0 then
			weld.C0 = C0
		else
			weld.C0 = parent.CFrame:Inverse() * part.CFrame
		end

		weld.Part0 = parent
		weld.Part1 = part
		weld.Parent = parent
		return weld
	end
}