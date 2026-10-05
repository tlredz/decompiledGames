local v = {
	"Root",
	"Neck",
	"BodyBack",
	"LeftFoot",
	"LeftGrip",
	"BodyFront",
	"RightFoot",
	"RightGrip",
	"WaistBack",
	"LeftCollar",
	"WaistFront",
	"RightCollar",
	"WaistCenter",
	"LeftShoulder",
	"RightShoulder"
}

local function findFirstCharacterAttachment(object)
	for _, v2 in ipairs(v) do
		local attachment = object:QueryDescendants((`Attachment #{v2}Attachment`))[1]

		if attachment and attachment:IsA("Attachment") then
			return attachment
		end
	end

	return nil
end

return table.freeze({
	FindFirstCharacterAttachment = findFirstCharacterAttachment
})