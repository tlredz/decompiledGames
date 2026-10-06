local TextService = game:GetService("TextService")
local v = {}

local function CommonPrefixLength(text: string, text2: string)
	local v3 = math.min(#text, #text2)
	local count = 0

	while count < v3 and text:byte(count + 1) == text2:byte(count + 1) do
		count += 1
	end

	return count
end

return table.freeze({
	Typewrite = function(_, data)
		if typeof(data) ~= "table" then
			return
		end

		local label = data.Label
		local text = data.Text
		local speed = data.Speed
		local keepPrefix = data.KeepPrefix

		if typeof(label) ~= "Instance" or not label:IsA("TextLabel") or typeof(text) ~= "string" then
			return
		end

		local v3 = (typeof(speed) ~= "number" or speed <= 0) and 1 or speed

		if typeof(keepPrefix) ~= "boolean" then
			keepPrefix = false
		end

		local v4 = v[label]

		if v4 then
			local characterIndex

			if keepPrefix then
				local commonPrefixLength = CommonPrefixLength(v4.Text, text)
				characterIndex = math.min(v4.CharacterIndex, commonPrefixLength)
			else
				characterIndex = 0
			end

			v4.Text = text
			v4.Cooldown = 0.05 / v3
			v4.CharacterIndex = characterIndex
			v4.Running = true
			label.Text = text
			label.MaxVisibleGraphemes = v4.CharacterIndex
		else
			local v5 = {
				Instance = label,
				Text = text,
				Running = true,
				CharacterIndex = 0,
				Cooldown = 0.05 / v3
			}
			label.Text = text
			label.MaxVisibleGraphemes = 0
			v5.Thread = task.spawn(function()
				while v5.Running do
					if v5.Instance and v5.Instance.Parent then
						if #v5.Text < v5.CharacterIndex then
							v5.Running = false
						else
							v5.CharacterIndex += 1
							v5.Instance.MaxVisibleGraphemes = v5.CharacterIndex
							task.wait(v5.Cooldown)
						end
					else
						v5.Running = false
					end
				end

				label.MaxVisibleGraphemes = -1
				v[label] = nil
			end)
			v[label] = v5
		end
	end,
	FilterTextAsync = function(_, p: string, p2: number)
		local v3 = nil
		local v4 = nil

		if pcall(function()
			v3 = TextService:FilterStringAsync(p, p2)
		end) then
			local success, result = pcall(function()
				return v3:GetNonChatStringForBroadcastAsync()
			end)

			if success then
				return result
			end
		end

		return v4
	end
})