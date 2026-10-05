local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.VirtualInstance)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local guiTemplates = {
	AnimalOverhead = script.AnimalOverhead,
	CashPad = script.CashPad
}
local v2 = {
	[guiTemplates.AnimalOverhead] = {
		PhysicalSize = createVector(15, 5, 0.1),
		Ranges = {
			Close = {
				Distance = (ServerData.IsTsunamiServer() or ServerData.IsTradePlaza()) and 120 or 40,
				px = ServerData.IsTsunamiServer() and 480 or 340
			},
			Standard = {
				Distance = (ServerData.IsTsunamiServer() or ServerData.IsTradePlaza()) and 240 or 80,
				px = ServerData.IsTsunamiServer() and 340 or 220
			},
			Far = {
				Distance = 1e999,
				px = 10
			}
		}
	},
	[guiTemplates.CashPad] = {
		PhysicalSize = createVector(5, 3, 0.1),
		Ranges = {
			Close = {
				Distance = 40,
				px = 200
			},
			Standard = {
				Distance = 80,
				px = 100
			},
			Far = {
				Distance = 1e999,
				px = 10
			}
		}
	}
}
local playerOverhead = script:FindFirstChild("PlayerOverhead")

if playerOverhead then
	guiTemplates.PlayerOverhead = playerOverhead
	v2[playerOverhead] = {
		PhysicalSize = createVector(15, 6, 0.1),
		Ranges = {
			Close = {
				Distance = 60,
				px = 320
			},
			Standard = {
				Distance = 120,
				px = 200
			},
			Far = {
				Distance = 1e999,
				px = 100
			}
		}
	}
end

for _, v3 in v2 do
	local v4 = v3.PhysicalSize.Y / v3.PhysicalSize.X

	for _, range in v3.Ranges do
		range.size = Vector2.new(range.px, range.px * v4)
	end
end

local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local upVector = createVector(0, 1, 0)
local lookVector = createVector(0, 0, 1)
local position = createVector(0, 0, 0)
local v3 = {}
local v4 = {}
local parts = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getAdorneePosition(adornee, adorneeType: string)
	if adorneeType == "BasePart" then
		return adornee.Position
	elseif adorneeType == "Attachment" then
		return adornee.WorldPosition
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function solveBillboardCFrame(adorneePosition: Vector3, p)
	local v6 = adorneePosition + upVector * p.studsOffsetY
	return CFrame.lookAlong(v6, -lookVector)
end

local FastOverheadController = {}
FastOverheadController.GuiTemplates = guiTemplates

function FastOverheadController.createFastOverhead(data)
	local adorneeType = data.adornee:IsA("BasePart") and "BasePart" or data.adornee:IsA("Attachment") and "Attachment" or error((`invalid adornee "{data.adornee}"`))
	local v7 = v2[data.guiTemplate]
	local clone = script.FastOverheadTemplate:Clone()
	clone.CFrame = CFrame.new(0, 10000, 0)
	clone.Size = v7.PhysicalSize
	clone.Parent = workspace.Debris
	local relativeToAdornee = data.relativeToAdornee == true
	local adornee = nil

	if relativeToAdornee then
		if adorneeType == "BasePart" then
			adornee = data.adornee
		elseif adorneeType == "Attachment" then
			adornee = data.adornee.Parent

			if not (adornee and adornee:IsA("BasePart")) then
				adornee = nil
			end
		end
	end

	local __foh_transform = clone.__foh_transform

	if FFlags:GetInstant("FastOverhead.UseMotor6D", true) then
		__foh_transform.Part0 = adornee or workspace.Terrain
		__foh_transform.Part1 = clone
		clone.Anchored = false

		if adornee then
			clone.Massless = true
			clone.CanCollide = false
		end
	else
		__foh_transform:Destroy()
		__foh_transform = nil
		relativeToAdornee = false
	end

	local clone2 = data.guiTemplate:Clone()
	clone2.Adornee = clone
	clone2.MaxDistance = v7.Ranges.Standard.Distance * 0.9
	clone2.Parent = clone
	local v8 = {
		part = clone,
		motor6D = __foh_transform,
		gui = clone2,
		adornee = data.adornee,
		adorneeType = adorneeType,
		studsOffsetY = data.studsOffsetY or 2.5,
		relativeToAdornee = relativeToAdornee and adornee ~= nil,
		guiTemplate = data.guiTemplate,
		adorneePosition = createVector(0, 10000, 0),
		lastPositionCheck = -1
	}
	table.insert(v3, v8)
	v4[clone2] = v8
	local destroyingConnection = nil
	local flag = false

	local function cleanup()
		if flag then
			return
		end

		flag = true
		clone:Destroy()
		local index = table.find(v3, v8)

		if index then
			table.remove(v3, index)
		end

		v4[clone2] = nil

		if destroyingConnection then
			destroyingConnection:Disconnect()
			destroyingConnection = nil
		end
	end

	destroyingConnection = clone2.Destroying:Connect(cleanup)
	return clone2, cleanup
end

function FastOverheadController.setStudsOffsetY(p, studsOffsetY: number)
	local v6 = v4[p]

	if v6 then
		v6.studsOffsetY = studsOffsetY
	end
end

function FastOverheadController.Start(_)
	local function updatePositionsAndResolution()
		for _, v6 in v3 do
			local adorneePosition = getAdorneePosition(v6.adornee, v6.adorneeType) -- equivalent call inferred; original call site unknown
			v6.adorneePosition = adorneePosition
			local magnitude = (position - adorneePosition).Magnitude
			local ranges = v2[v6.guiTemplate].Ranges

			if magnitude < ranges.Close.Distance then
				v6.gui.CanvasSize = ranges.Close.size
			elseif magnitude < ranges.Standard.Distance then
				v6.gui.CanvasSize = ranges.Standard.size
			else
				v6.gui.CanvasSize = ranges.Far.size
			end
		end
	end

	local function updateOverheads()
		for _, v6 in v3 do
			local v7 = solveBillboardCFrame(v6.adorneePosition, v6) -- equivalent call inferred; original call site unknown

			if v6.motor6D then
				if v6.relativeToAdornee then
					local part0 = v6.motor6D.Part0

					if part0 then
						v6.motor6D.Transform = part0.CFrame:Inverse() * v7
					end
				else
					v6.motor6D.Transform = v7
				end
			elseif v7 ~= v6.lastCFrame then
				table.insert(parts, v6.part)
				table.insert(v5, v7)
				v6.lastCFrame = v7
			end
		end

		if #parts > 0 then
			workspace:BulkMoveTo(parts, v5, Enum.BulkMoveMode.FireCFrameChanged)
			table.clear(parts)
			table.clear(v5)
		end
	end

	RunService.Stepped:Connect(function(_)
		local cFrame = currentCamera.CFrame
		lookVector = cFrame.LookVector
		upVector = cFrame.UpVector
		position = cFrame.Position
		updatePositionsAndResolution()
		updateOverheads()
	end)
end

return FastOverheadController