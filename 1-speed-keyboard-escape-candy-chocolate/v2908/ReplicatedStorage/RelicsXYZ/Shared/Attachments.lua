local v = {
	Root = "HumanoidRootPart",
	Neck = "UpperTorso",
	BodyBack = "UpperTorso",
	LeftFoot = "LeftFoot",
	LeftGrip = "LeftHand",
	BodyFront = "UpperTorso",
	RightFoot = "RightFoot",
	RightGrip = "RightHand",
	WaistBack = "LowerTorso",
	LeftCollar = "UpperTorso",
	WaistFront = "LowerTorso",
	RightCollar = "UpperTorso",
	WaistCenter = "LowerTorso",
	LeftShoulder = "UpperTorso",
	RightShoulder = "UpperTorso"
}

local function getParentName(value: string)
	return v[value:gsub("Attachment$", "")]
end

local function findFirstCharacterAttachment(object)
	for k, v2 in pairs(v) do
		local attachment = object:QueryDescendants((`BasePart #{v2} >> Attachment #{k}Attachment`))[1]

		if attachment and attachment:IsA("Attachment") then
			return attachment
		end
	end

	return nil
end

return table.freeze({
	GetParentName = getParentName,
	FindFirstCharacterAttachment = findFirstCharacterAttachment
})