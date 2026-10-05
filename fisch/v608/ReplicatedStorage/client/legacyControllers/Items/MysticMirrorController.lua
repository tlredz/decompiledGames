local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
game:GetService("GuiService")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("utils"):WaitForChild("FischUtils"))
local Worlds = require(ReplicatedStorage.shared:WaitForChild("modules"):WaitForChild("Worlds"))
local placed = false
local mysticMirrorDecal = ReplicatedStorage.resources.replicated.instances.general.MysticMirrorDecal
local mysticMirror = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("MysticMirror")

local function move(p, vector2: Vector3, flag: boolean)
	p.Position = vector2 + (flag and createVector(0, 0, 0) or createVector(-0, -4.4, -0))
end

local MysticMirrorController = {
	_asset = mysticMirrorDecal:Clone()
}

local function getZoneName(vector2: Vector3)
	local v = -1e999
	local v2 = nil

	for _, child in workspace:WaitForChild("zones"):WaitForChild("player"):GetChildren() do
		if not ((child:GetClosestPointOnSurface(vector2) - vector2).Magnitude <= 0.25) then
			continue
		end

		local value = child:FindFirstChild("priority").Value

		if not (v < value) then
			continue
		end

		v2 = child
		v = value
	end

	local v3 = v2 or ReplicatedStorage:FindFirstChild("Ocean")

	if v3 and v3:FindFirstChild("zonename") then
		return v3.zonename.Value
	end

	return "Ocean"
end

function MysticMirrorController.Start(_)
	MysticMirrorController._asset.Parent = Workspace
	DataController.PlayerDataReplicator:Observe({ "MysticMirrorPos" }, MysticMirrorController._OnPatch)
	mysticMirror.replaceButton.Activated:Connect(function()
		Net:RemoteEvent("MysticMirror/Replace"):FireServer()
		mysticMirror.Visible = false
	end)
	mysticMirror.teleportButton.Activated:Connect(function()
		Net:RemoteEvent("MysticMirror/Teleport"):FireServer()
		mysticMirror.Visible = false
	end)
end

function MysticMirrorController._OnPatch(p)
	if not p then
		return
	end

	placed = p.Placed

	if p.Encoded == "empty" or not p.Placed then
		MysticMirrorController._asset.Position = createVector(0, 10000, 0)
		return
	end

	local jSONDecode = HttpService:JSONDecode(p.Encoded)
	local vector2 = Vector3.new(jSONDecode[1], jSONDecode[2], jSONDecode[3])
	MysticMirrorController._asset.Position = vector2 + createVector(-0, -4.4, -0)
	local zoneName = getZoneName(vector2)
	mysticMirror.coordinates.Text = ("<font color='#ff6675'>%.0f</font>, <font color='#5ee25a'>%.0f</font>, <font color='#7f73ff'>%.0f</font>"):format(
		vector2.X,
		vector2.Y,
		vector2.Z
	)
	mysticMirror.zoneName.Text = zoneName
end

function MysticMirrorController.OnMirrorActivated(_)
	if Worlds.PlaceTypes[game.PlaceId] == "TradePlaza" then
		ReplicatedStorage.events.anno_localthought:Fire("This item cannot be used in the Trade Plaza.")
	elseif placed then
		mysticMirror.Visible = not mysticMirror.Visible
	else
		Net:RemoteEvent("MysticMirror/Replace"):FireServer()
	end
end

return MysticMirrorController