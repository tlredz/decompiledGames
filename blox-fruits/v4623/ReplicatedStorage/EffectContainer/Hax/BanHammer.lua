local createVector = vector.create
_G.lastBanHammer = _G.lastBanHammer or 0
local part = Instance.new("Part")
part.Shape = Enum.PartType.Block
part.Material = Enum.Material.Plastic
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Smooth
part.Size = createVector(0.2, 0.2, 0.2)
part.CanCollide = true
part.Locked = true
part.Anchored = false
local clone = part:Clone()
clone.Name = "ShockWave"
clone.Transparency = 1
clone.Size = createVector(0.2, 4, 0.2)
clone.Anchored = true
clone.CanCollide = false
local specialMesh = Instance.new("SpecialMesh")
specialMesh.MeshType = Enum.MeshType.Brick
specialMesh.Scale = createVector(1, 0, 1)
specialMesh.Parent = clone

for i = 1, 2 do
	local decal = Instance.new("Decal")
	decal.Texture = "http://www.roblox.com/asset?id=183210124"
	decal.Transparency = 0.125
	decal.Face = i == 1 and Enum.NormalId.Top or Enum.NormalId.Bottom
	decal.Parent = clone
end

local function explode(position: Vector3)
	local Lighting = game:GetService("Lighting")
	local evilmaxerLighting = Lighting:FindFirstChild("EvilmaxerLighting")

	if evilmaxerLighting then
		evilmaxerLighting.Saturation = math.clamp(evilmaxerLighting.Saturation - 0.5, -1.2, 1)
		evilmaxerLighting.Contrast = math.clamp(evilmaxerLighting.Contrast + 0.2, -1, 0.5)
	end

	task.spawn(function()
		local clone2 = clone:Clone()
		local cframe = CFrame.new(position)
		clone2.CFrame = cframe
		game.Debris:AddItem(clone2, 5)
		clone2.Parent = workspace._WorldOrigin
		task.spawn(function()
			for i = 1, 25 do
				local v = i * 2

				for _, decal in pairs(clone2:GetChildren()) do
					if decal:IsA("Decal") then
						decal.Transparency = i * 1 / 25
					end
				end

				clone2.Size = Vector3.new(v, clone.Size.Y, v)
				clone2.CFrame = cframe
				task.wait(0.016666666666666666)
			end

			if clone2 and clone2.Parent then
				clone2:Destroy()
			end
		end)
	end)
end

local v = {
	781,
	782,
	772,
	773,
	831,
	785,
	774,
	784,
	850,
	855,
	849,
	775,
	776,
	778,
	834,
	835,
	836,
	842,
	843,
	844,
	771,
	770,
	780,
	848,
	768,
	769,
	779,
	783,
	786,
	787,
	788,
	829,
	777,
	867,
	868,
	869,
	870,
	871,
	872,
	873,
	874,
	875,
	876,
	877,
	878,
	879,
	830,
	859
}
local v2 = {
	789,
	795,
	832,
	833,
	856,
	801,
	802,
	807,
	808,
	820,
	821,
	822,
	847,
	860,
	861,
	862,
	863,
	864,
	866,
	824,
	823,
	865,
	1161
}
local v3 = {
	790,
	791,
	792,
	793,
	796,
	797,
	798,
	799,
	800,
	804,
	805,
	806,
	809,
	810,
	811,
	812,
	813,
	814,
	815,
	816,
	817,
	818,
	819,
	825,
	826,
	827,
	828,
	837,
	839,
	840,
	841,
	845,
	846,
	851,
	852,
	853,
	854,
	857,
	858,
	803
}
local random = Random.new()

local function isZalgoChar(p: number, p2: number, p3: number, p4: number)
	for i = 1, p2 do
		if p == v[i] then
			return true
		end
	end

	for i = 1, p3 do
		if p == v3[i] then
			return true
		end
	end

	for i = 1, p4 do
		if p == v2[i] then
			return true
		end
	end

	return false
end

local function generateZalgoString(p: string, flag: boolean, flag2: boolean, flag3: boolean, flag4: boolean, p2: number)
	local v4 = {}

	for _, v5 in utf8.codes(p) do
		if not (flag4 or not isZalgoChar(v5, flag and #v or 0, flag3 and #v3 or 0, flag2 and #v2 or 0)) then
			continue
		end

		table.insert(v4, utf8.char(v5))

		if v5 < 32 then
			continue
		end

		for _ = 1, not flag and 0 or random:NextInteger(0, 7) + p2 or 0 do
			table.insert(v4, utf8.char(v[random:NextInteger(1, #v)]))
		end

		for _ = 1, not flag2 and 0 or math.floor(random:NextInteger(0, 5) / 2) + p2 or 0 do
			table.insert(v4, utf8.char(v2[random:NextInteger(1, #v2)]))
		end

		for _ = 1, not flag3 and 0 or math.floor(random:NextInteger(0, 63) / 4) + 3 + p2 or 0 do
			table.insert(v4, utf8.char(v3[random:NextInteger(1, #v3)]))
		end
	end

	return table.concat(v4)
end

return function(p)
	local type = p.type
	local position = p.position

	if type == "explode" then
		explode(position)
	elseif type == "ArenaDialogue" then
		local GetSounds = require(script.Parent.GetSounds)
		local sounds = GetSounds()
		local v5 = {
			sounds["HackEvent_Enter_The_Arena_Dialogue_Popup_01 (1)"],
			sounds.HackEvent_Enter_The_Arena_Dialogue_Popup_03,
			sounds.HackEvent_Enter_The_Arena_Dialogue_Popup_02
		}
		local clone2 = v5[math.random(1, #v5)]:Clone()
		task.delay(10, function()
			if clone2 and clone2.Parent then
				clone2:Stop()
				clone2:Destroy()
			end
		end)
		clone2.Parent = game.Players.LocalPlayer.PlayerGui
		clone2:Play()
	else
		if _G.lastBanHammer > os.clock() then
			return
		end

		_G.lastBanHammer = 1e999
		local back = game.Players.LocalPlayer.PlayerGui.FakeCrash.Back
		back.Visible = true
		back.UIScale.Scale = 0
		local lastTime = tick()
		back.Center.RichText = true
		back.Center.Text = "You have been kicked by ????????.\n(Error Code: LUCKYMAXER)"
		back.TextButton.Text = "Leave"
		task.spawn(function()
			local GetSounds = require(script.Parent.GetSounds)
			local sounds = GetSounds()
			local v5 = {
				sounds["HackEvent_You_Have_Been_Kicked_01 (1)"],
				sounds["HackEvent_You_Have_Been_Kicked_03 (1)"],
				sounds["HackEvent_You_Have_Been_Kicked_02 (1)"]
			}
			local clone2 = v5[math.random(1, #v5)]:Clone()
			task.delay(10, function()
				if clone2 and clone2.Parent then
					clone2:Stop()
					clone2:Destroy()
				end
			end)
			clone2.Parent = game.Players.LocalPlayer.PlayerGui
			clone2:Play()
		end)
		local v4 = { "Go away", "LOL", "Bye" }
		back.Title.Text = v4[random:NextInteger(1, #v4)]
		task.spawn(function()
			while back.Visible do
				task.wait(0.25)
				local v5 = math.ceil((tick() - lastTime) * 1)
				local v6 = "kicked"

				if math.random() < 0.1 then
					v6 = "<font color=\"rgb(255,125,0)\">🅱🅰🅽🅽🅴🅳</font>"
				elseif math.random() < 0.2 then
					v6 = `{generateZalgoString("????????", true, true, true, true, v5)}`
				end

				back.Center.Text = `You have been {v6} by {generateZalgoString("????????", true, true, true, true, v5)}.\n(Error Code: {generateZalgoString("LUCKYMAXER", true, true, true, true, v5)})`

				if math.random() < 0.1 then
					back.TextButton.Text = generateZalgoString("Leave", true, true, true, true, v5)
				else
					back.TextButton.Text = "Give up"
				end
			end
		end)
		local enabledsByScreenGui = {}

		for _, screenGui in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
			if not (screenGui:IsA("ScreenGui") and screenGui.Name ~= "FakeCrash") then
				continue
			end

			enabledsByScreenGui[screenGui] = screenGui.Enabled
			screenGui.Enabled = false
		end

		local blurEffect = Instance.new("BlurEffect", game.Lighting)
		blurEffect.Size = 0
		local TweenService = game:GetService("TweenService")
		TweenService:Create(blurEffect, TweenInfo.new(0.4), {
			Size = 25
		}):Play()
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(back.UIScale, TweenInfo.new(0.4), {
			Scale = 1
		}):Play()
		local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
		humanoidRootPart.Anchored = true
		back.TextButton.Activated:Once(function()
			blurEffect:Destroy()

			for k, enabled in pairs(enabledsByScreenGui) do
				k.Enabled = enabled
			end

			back.Visible = false
			_G.lastBanHammer = os.clock() + 4
			humanoidRootPart.Anchored = false
		end)
	end
end