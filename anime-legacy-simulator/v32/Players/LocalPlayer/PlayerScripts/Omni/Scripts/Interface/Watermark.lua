local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
local watermark = Omni.Instance.PlayerGui.Watermark:WaitForChild("Watermark")
local playerGroupInfo = Omni.Utils.Players.GetPlayerGroupInfo(Omni.Instance)
local universalTime = DateTime.now():ToUniversalTime()
local formatted = `{universalTime.Day}/{universalTime.Month}/{universalTime.Year}`
watermark.Template.Label1.Text = `{Omni.Instance.Name} ({Omni.Instance.UserId}): {formatted}`
watermark.Template.Label2.Text = `{Omni.Instance.Name} ({Omni.Instance.UserId}): {formatted}`
watermark.Template.Label3.Text = `{Omni.Instance.Name} ({Omni.Instance.UserId}): {formatted}`
local Watermark = {}

for _ = 1, 19 do
	local clone = watermark.Template:Clone()
	clone.Parent = watermark
	task.wait()
end

if game.PlaceId == Omni.Settings.TestPlaceId and not Omni.Services.RunService:IsStudio() and playerGroupInfo < 3 and not table.find(
	{ 6190836969, 713434647 },
	Omni.Instance.UserId
) then
	watermark.Visible = true
	return Watermark
end

watermark.Visible = false
return Watermark