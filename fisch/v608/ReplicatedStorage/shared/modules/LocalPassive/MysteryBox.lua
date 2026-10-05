local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.packages.Signal)
require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local remoteFunction = Net:RemoteFunction("MysteryBox/Trigger", -1)
local random = Random.new()
local v = {
	Enum.NormalId.Front,
	Enum.NormalId.Back,
	Enum.NormalId.Top,
	Enum.NormalId.Bottom,
	Enum.NormalId.Left,
	Enum.NormalId.Right
}
local MysteryBox = {
	NoMock = true,
	GetRandomEffect = function(self, object)
		local number = object:NextNumber(0, self._effectPoolTotalWeight)
		local v2 = {}
		local v3 = nil
		local total = 0
		local v4 = nil

		for k in self._effectPool do
			table.insert(v2, k)
		end

		table.sort(v2)

		for _, v5 in v2 do
			v3 = v3 or v5

			if total < number and number <= total + self._effectPool[v5] then
				v4 = v5
			end

			total += self._effectPool[v5]
		end

		return self.sconfig.Effects[v4 or v3], v4 or v3
	end,
	SpawnBox = function(self)
		local number = self.spawnRand:NextNumber(0.05, 0.95)
		local clone = script.boxContainer:Clone()
		local mysteryBox = clone.mysteryBox.boxViewport.MysteryBox
		local maid = self.reelTrove:Extend()
		maid:Add(clone)
		local camera = Instance.new("Camera")
		camera.CFrame = CFrame.identity
		camera.FieldOfView = 50
		camera.Parent = clone.mysteryBox.boxViewport
		clone.mysteryBox.boxViewport.CurrentCamera = camera
		clone.mysteryBox.Position = UDim2.fromScale(number, 1)
		clone.mysteryBox.Size = UDim2.fromScale(0, 0)
		local randomEffect, v2 = self:GetRandomEffect(self.effectRand)
		self._effectCounts[v2] += 1

		if randomEffect.MaxCount and self._effectCounts[v2] >= randomEffect.MaxCount then
			self._effectPool[v2] = nil
			self._effectPoolTotalWeight -= randomEffect.ChanceWeight
		end

		for i = 1, 6 do
			local v3 = v[i]
			local randomEffect2

			if i == 2 then
				randomEffect2 = randomEffect
			else
				randomEffect2 = self:GetRandomEffect(random)
			end

			local child = mysteryBox:FindFirstChild((`effect{v3.Name}`))
			child.Texture = randomEffect2.Icon
			child.Color3 = randomEffect2.Color
		end

		local v3 = random:NextUnitVector() * 3.141592653589793 * 0.5
		local v4 = 0
		local flag = false
		local v5 = false
		mysteryBox.CFrame *= CFrame.fromOrientation(v3.X * 10, v3.Y * 10, v3.Z * 10)
		maid:Add(self.current.OnLogicStep:Connect(function(p: number)
			if flag then
				return
			end

			mysteryBox.CFrame *= CFrame.fromOrientation(v3.X * p, v3.Y * p, v3.Z * p)

			if self.current.active and not self.current.isPaused and v4 < 1 then
				if self.current:IsInBar(number, 0.075) then
					v4 = math.clamp(
						v4 + p * math.max(self.current.progressefficiency, 0.5) / self.sconfig.BaseOpenTime,
						0,
						1
					)

					if v4 >= 1 then
						flag = true
						clone.mysteryBox.claimBar.Visible = false
						self:EffectAnimation(randomEffect, clone, v[2])
						self.current:DelayLogic(3, maid.Clean, maid)
						v5 = true
						return
					end
				else
					v4 = math.clamp(v4 - p / self.sconfig.DecayTime, 0, 1)
				end
			end

			clone.mysteryBox.claimBar.fill.Size = UDim2.fromScale(v4, 1)
		end))
		clone.Parent = self.current.reel_bar
		self.current.logicTweens:CreateAndPlay(clone.mysteryBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = UDim2.fromScale(0.15, 0.15)
		})

		repeat
			task.wait()
		until v5 or not (self.current and self.current.active)
	end,
	EffectAnimation = function(self, data, p, _)
		local mysteryBox = p.mysteryBox.boxViewport.MysteryBox
		self.current.logicTweens:CreateAndPlay(p.mysteryBox, TweenInfo.new(1, Enum.EasingStyle.Quint), {
			Position = UDim2.fromScale(0.5, 0.25),
			Size = UDim2.fromScale(0.5, 0.5)
		})
		self.current.logicTweens:CreateAndPlay(
			p.mysteryBox.boxViewport.MysteryBox,
			TweenInfo.new(1, Enum.EasingStyle.Quart),
			{
				CFrame = CFrame.new(mysteryBox.Position)
			}
		)
		self.current:WaitLogic(0.75)
		p.selectedIcon.glow.ImageColor3 = data.Color
		p.selectedIcon.icon.ImageColor3 = data.Color
		p.selectedIcon.icon.Image = data.Icon
		p.selectedIcon.displayName.Text = data.DisplayName
		p.selectedIcon.displayName.TextColor3 = data.Color
		p.selectedIcon.Size = UDim2.fromScale(0.25, 0.25)
		p.selectedIcon.Visible = true
		self.current.renderTweens:CreateAndPlay(p.selectedIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
			Size = UDim2.fromScale(0.5, 0.5)
		})
		self.current.logicTweens:CreateAndPlay(p.mysteryBox.boxViewport, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		})
		self.current.logicTweens:CreateAndPlay(p.selectedIcon.glow, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		})
		self.current.logicTweens:CreateAndPlay(
			p.selectedIcon.icon,
			TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				ImageTransparency = 1
			}
		)
		self.current.logicTweens:CreateAndPlay(
			p.selectedIcon.displayName,
			TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				TextTransparency = 1
			}
		)
		self.current.logicTweens:CreateAndPlay(
			p.selectedIcon.displayName.UIStroke,
			TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Transparency = 1
			}
		)
		self:TriggerEffect(data)
	end,
	TriggerEffect = function(self, p)
		if p.Type == "progress" then
			self.current:AddProgress(p.Value)
		elseif p.Type == "freeze_fish" then
			self:_FreezeEffect(p.Value)
			self.current:FreezeFish(p.Value)
		elseif p.Type == "freeze_player" then
			self.current.core.rod:LockInput(p.Value)
			self.current.core.rod.Paused = true
			self:_FreezeEffect(p.Value)
			self.current:DelayLogic(p.Value, function()
				if not self.current then
					return
				end

				self.current.core.rod.Paused = false
			end)
		elseif p.Type == "control" then
			self.current:TweenModifier("barSize", "add", 0, p.Value, TweenInfo.new(1, Enum.EasingStyle.Quart))
		elseif p.Type == "player_speed" then
			self.current:AddModifier("barMoveSpeed", "multiply", p.Value)
		elseif p.Type == "fish_speed" then
			self.current:AddModifier("movementfactor", "multiply", p.Value)
		elseif p.Type ~= "bird" and p.Type == "progspeed" then
			self.current:AddModifier("progressefficiency", "add", p.Value)
		end

		remoteFunction:InvokeServer(self._reel_uid)
	end,
	_FreezeEffect = function(self, p2: number)
		local GuiService = game:GetService("GuiService")
		local guiInset = GuiService:GetGuiInset()
		local clone = script.FrostImg:Clone()
		clone.Size = UDim2.new(1, guiInset.X, 1, guiInset.Y)
		clone.Parent = self.current.reel
		self.current.logicTweens:CreateAndPlay(clone.CryogenicFlash, TweenInfo.new(3, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		})
		self.current.logicTweens:CreateAndPlay(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
			ImageTransparency = 0.5
		})
		ReplicatedStorage.resources.sounds.sfx.ui.cryogenic:Play()
		self.current:DelayLogic(p2, function()
			local v2 = self.current.logicTweens:CreateAndPlay(clone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			})
			v2:Play()
			v2.Completed:Wait()
			clone:Destroy()
		end)
	end,
	Morph = function(self, _, object2)
		self.spawnRand = object2:GetRandom(51)
		self.effectRand = object2:GetRandom(61)
		self.sconfig = object2.data.MysteryBox_ServerConfig
		self._reel_uid = object2.data.MysteryBox_ReelUid

		if not (self.sconfig and self._reel_uid) then
			warn("No ServerConfig supplied, exiting")
			return
		end

		self._effectCounts = {}
		self._effectPool = {}
		self._effectPoolTotalWeight = 0

		for k, effect in self.sconfig.Effects do
			self._effectCounts[k] = 0
			self._effectPool[k] = effect.ChanceWeight
			self._effectPoolTotalWeight += effect.ChanceWeight
		end

		task.spawn(function()
			self.current:WaitUntilReady()

			while self.current and self.current.active do
				object2:WaitLogic(self.spawnRand:NextNumber(self.sconfig.MinInterval, self.sconfig.MaxInterval))

				if self.current and self.current.active then
					self:SpawnBox()
				else
					break
				end
			end
		end)
	end
}
setmetatable(MysteryBox, module)
return MysteryBox