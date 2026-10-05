local currentCamera = workspace.CurrentCamera

function GetMousePoint(p, p2)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.Shiftlock then
		p = currentCamera.ViewportSize.X / 2
		p2 = currentCamera.ViewportSize.Y / 2 - 36
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(p, p2)
	local Ray = require(game.ReplicatedStorage.Util.Ray)
	local _, v = Ray(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 1000,
		{ game.Players.LocalPlayer.Character }
	)
	return v
end

return GetMousePoint