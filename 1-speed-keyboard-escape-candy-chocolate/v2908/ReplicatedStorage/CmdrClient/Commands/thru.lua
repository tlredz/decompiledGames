return {
	Name = "thru",
	Aliases = { "t", "through" },
	Description = "Teleports you through whatever your mouse is hovering over, placing you equidistantly from the wall.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "number",
			Name = "Extra distance",
			Description = "Go through the wall an additional X studs.",
			Default = 0
		}
	},
	ClientRun = function(p, p2)
		local mouse = p.Executor:GetMouse()
		local character = p.Executor.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			return "You don't have a character."
		end

		local position = character.HumanoidRootPart.Position
		local v = mouse.Hit.p - position
		character:MoveTo(v * 2 + v.unit * p2 + position)
		return "Blinked!"
	end
}