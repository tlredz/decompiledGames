return {
	Clearance = 1,
	Keys = {
		{
			Type = "Player",
			Required = true
		},
		{
			Type = "Subject",
			Required = true,
			Suggester = { "Water Mark" }
		},
		{
			Type = "Boolean",
			Required = true,
			Completer = function(value: string)
				local lower = value:lower()

				if lower == "true" then
					return true
				elseif lower == "false" then
					return false
				end

				return nil
			end
		}
	},
	Client = function(_, _, localPlayer, p, p2)
		if p == "Water Mark" then
			if not localPlayer then
				local Players = game:GetService("Players")
				localPlayer = Players.LocalPlayer
			end

			local watermark = localPlayer.PlayerGui:FindFirstChild("Watermark", true)

			if watermark == nil then
				error((`No gui named "Watermark" anywhere in {localPlayer.Name}'s PlayerGui, other players' guis aren't visible from your client`))
			end

			if watermark:IsA("GuiObject") then
				watermark.Visible = p2
			else
				watermark.Enabled = p2
			end
		end
	end
}