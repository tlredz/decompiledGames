local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local unixTimestamp = isServer and DateTime.now().UnixTimestamp

if isServer then
	script:SetAttribute("Startup", unixTimestamp)
else
	if not script:GetAttribute("Startup") then
		script:GetAttributeChangedSignal("Startup"):Wait()
	end

	script:GetAttribute("Startup")
end

return {
	Sprout = {
		Start = DateTime.fromUniversalTime(2026, 5, 1, 19, 0, 0),
		Toon = "Sprout"
	},
	Finn = {
		Start = DateTime.fromUniversalTime(2026, 6, 12, 19, 0, 0),
		Toon = "Finn"
	},
	Tisha = {
		Start = DateTime.fromUniversalTime(2026, 7, 24, 19, 0, 0),
		Toon = "Tisha"
	},
	Brusha = {
		Start = DateTime.fromUniversalTime(2026, 8, 14, 18, 55, 0),
		End = DateTime.fromUniversalTime(2026, 8, 21, 19, 0, 0),
		Toon = "Brusha"
	},
	Gigi = {
		Start = DateTime.fromUniversalTime(2026, 9, 18, 18, 55, 0),
		End = DateTime.fromUniversalTime(2026, 9, 25, 19, 0, 0),
		Toon = "Gigi"
	}
}