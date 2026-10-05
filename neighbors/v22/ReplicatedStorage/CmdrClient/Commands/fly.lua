return {
	Name = "fly",
	Aliases = { "" },
	Description = "Gives you the ability to fly",
	Group = "Moderator",
	Args = {},
	ClientRun = function(p)
		local executor = p.Executor
		local flightEnabled = executor:GetAttribute("FlightEnabled") or false
		executor:SetAttribute("FlightEnabled", not flightEnabled)

		if flightEnabled then
			return "Flight Disabled"
		end

		return "Flight Enabled"
	end
}