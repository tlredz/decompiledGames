local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local dateTime = DateTime.fromUniversalTime(2026, 8, 17, 23, 59, 59)
local localPlayer = Players.LocalPlayer

local function toTime(p: number)
	local v = math.floor(p / 86400)
	local v2 = p % 86400
	local v3 = math.floor(v2 / 3600)
	local v4 = v2 % 3600
	local v5 = math.floor(v4 / 60)
	local v6 = v4 % 60
	local v7 = ""

	if v >= 1 then
		v7 ..= `{string.format("%02d", v)}d `
	end

	if v >= 1 or v3 >= 1 then
		v7 ..= `{string.format("%02d", v3)}h `
	end

	local v8 = v7 .. `{string.format("%02d", v5)}m`

	if v < 1 then
		return v8 .. ` {string.format("%02d", v6)}s`
	end

	return v8
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tween(p, tweenInfo, p2)
	local tween2 = TweenService:Create(p, tweenInfo, p2)
	tween2.Completed:Connect(function()
		tween2:Destroy()
	end)
	tween2:Play()
end

return {
	Start = function(_)
		task.spawn(function()
			local track = nil
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://135103009173896"

			local function refresh(instance)
				local tool = instance:FindFirstChildOfClass("Tool")
				local v

				if tool == nil then
					v = false
				else
					v = tool.Name == "Developer Gift"
				end

				if v and not track then
					local humanoid = instance:FindFirstChildOfClass("Humanoid")

					if humanoid then
						track = humanoid:LoadAnimation(animation)
						track.Priority = Enum.AnimationPriority.Action
						track.Looped = true
						track:Play()
					end
				elseif not v and track then
					track:Stop()
					track = nil
				end
			end

			local function watchCharacter(character)
				track = nil
				refresh(character)
				character.ChildAdded:Connect(function()
					refresh(character)
				end)
				character.ChildRemoved:Connect(function()
					task.defer(refresh, character)
				end)
			end

			if localPlayer.Character then
				watchCharacter(localPlayer.Character)
			end

			localPlayer.CharacterAdded:Connect(watchCharacter)
		end)
		task.spawn(function()
			local playerGui = localPlayer:WaitForChild("PlayerGui")
			local devgift = playerGui:WaitForChild("devgift", 60)

			if not devgift then
				return
			end

			local giftBox = devgift:WaitForChild("GiftBox")
			local giftButton = giftBox:WaitForChild("GiftButton")
			local timeleft = giftButton:WaitForChild("timeleft")
			local letter = devgift:WaitForChild("Letter")
			local images = {}

			for _, image in (giftBox:FindFirstChild("spinner") or giftBox):GetChildren() do
				if image:IsA("ImageLabel") then
					table.insert(images, image)
				end
			end

			letter.Visible = false
			giftBox.Visible = false
			DataController.PlayerDataReplicator:WaitForLoaded()
			local index = DataController.PlayerDataReplicator:Index({ "DevGift" })

			if index and index.Claimed and not RunService:IsStudio() then
				devgift:Destroy()
				return
			end

			local v = false

			local function setPromptOpen(visible: boolean)
				if v == visible then
					return
				end

				v = visible
				letter.Visible = visible
				local hud = playerGui:FindFirstChild("hud")

				if hud then
					hud.Enabled = not visible
				end

				local backpack = playerGui:FindFirstChild("backpack")

				if backpack then
					backpack.Enabled = not visible
				end

				tween(workspace.CurrentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					FieldOfView = visible and 60 or 70
				}) -- equivalent call inferred; original call site unknown
				tween(
					Lighting:WaitForChild("uiblur"),
					TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Size = visible and 10 or 0
					}
				) -- equivalent call inferred; original call site unknown
				tween(
					Lighting:WaitForChild("uicc"),
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					visible and {
						Brightness = -0.07,
						TintColor = Color3.fromRGB(184, 184, 184),
						Saturation = -0.3
					} or {
						Brightness = 0,
						TintColor = Color3.fromRGB(255, 255, 255),
						Saturation = 0
					}
				) -- equivalent call inferred; original call site unknown

				if visible then
					local clone = ReplicatedStorage.resources.sounds.sfx.ui.open:Clone()
					clone.Parent = devgift
					clone:Play()
					clone.Ended:Once(function()
						clone:Destroy()
					end)
				end
			end

			local now = 0
			giftButton.Activated:Connect(function()
				if os.clock() - now < 0.5 then
					return
				end

				now = os.clock()
				setPromptOpen(true)
			end)
			letter.Later.Activated:Connect(function()
				setPromptOpen(false)
			end)
			local flag = false
			letter.Claim.Activated:Connect(function()
				if flag then
					return
				end

				flag = true

				if not Net:RemoteFunction("DevGift/Claim"):InvokeServer() then
					flag = false
					return
				end

				setPromptOpen(false)
				devgift:Destroy()
			end)
			local v2 = {}

			for k, v3 in images do
				v2[v3] = {
					size = v3.Size,
					transparency = v3.ImageTransparency,
					phase = (k - 1) * 0.9
				}
			end

			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if not devgift.Parent then
					renderSteppedConnection:Disconnect()
					return
				end

				if not giftBox.Visible then
					return
				end

				local now2 = os.clock()

				for k, v3 in v2 do
					local v4 = math.sin((now2 + v3.phase) * 2.2) * 0.5 + 0.5
					local v5 = v4 * 0.07 + 1
					k.Size = UDim2.fromScale(v3.size.X.Scale * v5, v3.size.Y.Scale * v5)
					k.ImageTransparency = v3.transparency + v4 * 0.18
				end
			end)

			while devgift.Parent do
				local unixTimestamp = DateTime.now().UnixTimestamp

				if unixTimestamp <= dateTime.UnixTimestamp then
					giftBox.Visible = true
					timeleft.Text = "Ends In: " .. toTime(dateTime.UnixTimestamp - unixTimestamp)
					task.wait(1)
				else
					setPromptOpen(false)
					devgift:Destroy()
					break
				end
			end
		end)
	end
}