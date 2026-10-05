return table.freeze({
	MaxLength = 20,
	MaxSpaces = 3,
	Normalize = function(value: string)
		local v = string.gsub(value, "%s+", " ")
		return string.match(v, "^%s*(.-)%s*$") or ""
	end,
	Check = function(value: string)
		if value == "" then
			return false, "Enter a name"
		end

		if string.find(value, "[^%a ]") then
			return false, "Names can only use letters A-Z"
		end

		local _, v = string.gsub(value, " ", "")

		if v > 3 then
			return false, (`Names can have at most {3} spaces`)
		end

		if #value > 20 then
			return false, (`Name must be {20} characters or less`)
		end

		return true, nil
	end,
	GetNickname = function(instance, childName)
		if not instance or type(childName) ~= "string" then
			return nil
		end

		local petNicknames = instance:FindFirstChild("PetNicknames")
		local stringValue = petNicknames and petNicknames:FindFirstChild(childName)

		if stringValue and stringValue:IsA("StringValue") and stringValue.Value ~= "" then
			return stringValue.Value
		end

		return nil
	end,
	Display = function(p: string?, p2: string)
		if p then
			return (`"{p}" {p2}`)
		end

		return p2
	end
})