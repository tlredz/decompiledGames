local BoothTransferRules = {
	Amounts = {
		10,
		20,
		30,
		40,
		50,
		100,
		150,
		200,
		250,
		300,
		400,
		500
	}
}
local v = {}

for _, amount in BoothTransferRules.Amounts do
	v[amount] = true
end

function BoothTransferRules.Validate(p, value, p2, value2, value3, p3)
	if type(value2) ~= "number" or not v[value2] then
		return "Choose one of the displayed amounts."
	end

	if type(value) ~= "number" or value <= 0 then
		return "This booth is not claimed."
	end

	if value ~= p2 then
		return "The booth owner changed. Choose an amount again."
	end

	if p == value then
		return "You cannot send Robux to yourself."
	end

	if type(value3) ~= "number" or value3 > 20 then
		return "Move closer to the booth."
	end

	if p3 then
		return nil
	end

	return "Sending Robux requires Roblox Plus."
end

return BoothTransferRules