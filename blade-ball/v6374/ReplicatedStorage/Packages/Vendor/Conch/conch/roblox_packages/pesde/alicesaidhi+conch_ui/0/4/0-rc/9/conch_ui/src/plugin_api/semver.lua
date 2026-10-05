local function version_to_string(data)
	return (`{data.major}.{data.minor}.{data.patch}`)
end

return {
	is_compatible = function(data, data2)
		if data.major == 0 and data2.minor == 0 then
			if data.patch == data.patch then
				return "ok", nil
			end

			return
				"likely_incompatible",
				(`requires {`{data.major}.{data.minor}.{data.patch}`}, likely incompatible with {`{data2.major}.{data2.minor}.{data2.patch}`}`)
		elseif data.major == 0 then
			if data.minor > data2.minor then
				return
					"likely_incompatible",
					(`requires {`{data.major}.{data.minor}.{data.patch}`}, likely incompatible with {`{data2.major}.{data2.minor}.{data2.patch}`}`)
			end

			if data.minor == data2.minor then
				if data.patch <= data2.patch then
					return "ok", nil
				end

				if data.patch > data2.patch then
					return
						"compatible",
						(`requires {`{data.major}.{data.minor}.{data.patch}`}, while likely compatible with {`{data2.major}.{data2.minor}.{data2.patch}`}, API might not function as expected`)
				end
			elseif data.minor < data2.minor then
				return
					"likely_incompatible",
					(`requires {`{data.major}.{data.minor}.{data.patch}`}, but api is at {`{data2.major}.{data2.minor}.{data2.patch}`}, this may indicate breaking changes`)
			end

			return
				"bad",
				(`unreachable condition reached {`{data.major}.{data.minor}.{data.patch}`} {`{data2.major}.{data2.minor}.{data2.patch}`}`)
		else
			if data.major ~= data2.major then
				return
					"bad",
					(`requires {`{data.major}.{data.minor}.{data.patch}`}, got {`{data2.major}.{data2.minor}.{data2.patch}`}, there's likely breaking changes`)
			end

			if data.minor > data2.minor then
				return
					"likely_incompatible",
					(`requires {`{data.major}.{data.minor}.{data.patch}`} which may depend on additional api's, which might not be available within {`{data2.major}.{data2.minor}.{data2.patch}`}`)
			end

			if data.minor == data2.minor then
				return "ok", nil
			end

			return
				"compatible",
				(`{`{data.major}.{data.minor}.{data.patch}`} is compatible with {`{data2.major}.{data2.minor}.{data2.patch}`}`)
		end
	end
}