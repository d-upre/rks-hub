local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function IsBasePart(Part)
	return Part:IsA("Part") or Part:IsA("MeshPart")
end

local function GetBasePart(Parent)
	return Parent:FindFirstChildOfClass("Part") or Parent:FindFirstChildOfClass("MeshPart")
end

getgenv().fireclickdetector = function(CD)
	local Part = CD.Parent
	if not Part then return end
	
	if Part:IsA("Model") then
		Part = GetBasePart(Part)
	end

	if not Part or not IsBasePart(Part) then return end

	local Archive = {}
	for _, Inst in Part:GetChildren() do
		table.insert(Archive, Inst)
		Inst.Parent = nil
	end

	local Old = Part.CFrame
	local OldDistance = CD.MaxActivationDistance
	local OldT = Part.Transparency
	local OldTouch = Part.CanTouch
	local OldCollide = Part.CanCollide
	Part.Transparency = 1
	Part.CanTouch = false
	Part.CanCollide = false
	Part.CFrame = Camera.CFrame * CFrame.new(0, 0, -Part.Size.Z - 1)
	CD.MaxActivationDistance = math.huge

	task.spawn(function()
		local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
		if OnScreen then
			VirtualInputManager:SendMouseMoveEvent(ScreenPos.X, ScreenPos.Y, game)
			RunService.RenderStepped:Wait()
			VirtualInputManager:SendMouseButtonEvent(ScreenPos.X, ScreenPos.Y, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(ScreenPos.X, ScreenPos.Y, 0, false, game, 0)
		end

		RunService.RenderStepped:Wait()

		Part.CanTouch = OldTouch
		Part.Transparency = OldT
		Part.CFrame = Old
		Part.CanCollide = OldCollide
		CD.MaxActivationDistance = OldDistance

		for _, Inst in Archive do
			Inst.Parent = Part
		end
	end)
end




local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/Dupre-Library/refs/heads/main/library.lua"))()

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local OtherData = LocalPlayer.OtherData
local Stages = workspace.BoatStages.NormalStages
local ChestTrigger = Stages.TheEnd.GoldenChest.Trigger
local ClaimRemote = workspace.ClaimRiverResultsGold
local GoldAmount = LocalPlayer.Data.Gold
local Blocks = workspace.Blocks[LocalPlayer.Name]

local AutoClaim = true
local ClaimChest = true

local StartStage = 2
local ChestClaimStage = 2
local ChestClaimDelay = 1

local function GetZone()
	return workspace[`{LocalPlayer.TeamColor}Zone`]
end

local function CollectStage(StageNumber)
	local Stage = Stages[`CaveStage{StageNumber}`]
	local Collect = Stage.DarknessPart
	local StageData = OtherData[`Stage{StageNumber - 1}`]

	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end
	
	repeat
		task.wait()

		if not Char then continue end

		Char:PivotTo(Collect.CFrame * CFrame.new(0, 0, -20))

		for _, BodyPart in Char:GetChildren() do
			if BodyPart:IsA("BasePart") then
				BodyPart.Velocity, BodyPart.RotVelocity = Vector3.zero, Vector3.zero
			end
		end
	until StageData.Value ~= "" or not Char or not Hum or Hum.Health <= 0
end

local function TouchChest()
	task.spawn(function()
		local Char = LocalPlayer.Character
		if not Char then return end

		local Hum = Char:FindFirstChildOfClass("Humanoid")
		if not Hum then return end

		repeat
			if not Char or not Hum or Hum.Health <= 0 then continue end

			local Old = ChestTrigger.CFrame
			ChestTrigger.CFrame = Char:GetPivot()
			task.wait()
			ChestTrigger.CFrame = Old
		until OtherData.End.Value ~= "" or not Char or not Hum or Hum.Health <= 0
	end)
end

local function Farm()
	local Char = LocalPlayer.Character
	if not Char then return end

	local Hum = Char:WaitForChild("Humanoid")
	if not Hum then return end
	
	for StageNumber = StartStage, 10 do
		local CanContinue = false
		
		task.spawn(function()
			CollectStage(StageNumber)
			CanContinue = true
		end)

		repeat task.wait() until CanContinue or not Char or Hum.Health <= 0

		if StageNumber ~= ChestClaimStage then
			if AutoClaim then
				ClaimRemote:FireServer()
			end
		else
			if ClaimChest then
				task.spawn(function()
					task.wait(ChestClaimDelay)
					TouchChest()
				end)
			end
		end
	end

	if Char then
		Char:BreakJoints()
	end
end

local function Place(Name, Pos)
	local BTool = LocalPlayer.Backpack:FindFirstChild("BuildingTool")
	if BTool then
		BTool.Parent = LocalPlayer.Character
	else
		BTool = LocalPlayer.Character:FindFirstChild("BuildingTool")
	end

	if not BTool then return end

	task.spawn(function()
		BTool.RF:InvokeServer(
			Name,
			LocalPlayer.Data[Name].Value,
			nil,
			nil,
			false,
			Pos,
			false
		)
	end)
end

local Root = Library:Init("Build A Boat")

do
	local Main = Root:Tab("Main")

	do
		local FarmSection = Main:Section("Auto Farm")
		FarmSection:Toggle("Enabled", function(Toggled)
			if Toggled then
				FarmConnection = LocalPlayer.CharacterAdded:Connect(Farm)
				Farm()
			else
				FarmConnection:Disconnect()
			end
		end)
	end

	do
		local QuestSection = Main:Section("Auto Quest")

		local StartQuest = workspace.QuestMakerEvent

		local function GetQuest()
			local Zone = GetZone()
			return Zone:WaitForChild("Quest")
		end

		local Quests = {
			function()
				local Quest = GetQuest()
				Quest:WaitForChild("Cloud"):WaitForChild("Part1").CFrame = LocalPlayer.Character:GetPivot()
			end,
			function()
				local Quest = GetQuest()
				local Target = Quest:WaitForChild("Target")
				local Done = false

				repeat
					for _, Part in Target:GetChildren() do
						if Part.Name == "Part" and Part:FindFirstChildOfClass("Script") then
							Done = true
							Part.CFrame = LocalPlayer.Character:GetPivot()
							break
						end
					end
					task.wait()
				until Done
			end,
			function()
				local Quest = GetQuest()
				local Ramp = Quest:WaitForChild("Ramp")
				local Done = false

				repeat
					for _, Part in Ramp:GetChildren() do
						if Part.Name == "Part" and Part:FindFirstChildOfClass("TouchTransmitter") then
							Done = true
							Part.CFrame = LocalPlayer.Character:GetPivot()
							break
						end
					end
					task.wait()
				until Done
			end,
			function()
				local Quest = GetQuest()
				local Zone = GetZone()

				repeat
					task.wait()

					if not Quest then break end

					local Butter = Quest:FindFirstChild("Butter")
					if not Butter then continue end

					local Part = Butter:FindFirstChild("PPart")
					if not Part then continue end

					local Click = Part:FindFirstChildOfClass("ClickDetector")
					if not Click then continue end

					fireclickdetector(Click)
				until not Zone:FindFirstChild("Quest")
			end,
			function()
				-- dragon
			end,
			function()
				local Zone = GetZone()
				local Quest = GetQuest()

				local MBox = Quest:WaitForChild("MBox")
				if not MBox then return end

				local PPart = MBox:WaitForChild("PPart")
				if not PPart then return end

				Place("Seat", PPart.CFrame * CFrame.new(2, 0, 0))

				local Finished = false
				Blocks.ChildAdded:Once(function(SeatModel)
					local Char = LocalPlayer.Character
					local Hum = Char.Humanoid
					SeatModel:WaitForChild("Seat"):Sit(Hum)
					repeat task.wait() until Hum.Sit
					Zone.VoteLaunchRE:FireServer()
					task.wait(.5)
					Char:PivotTo(ChestTrigger.CFrame * CFrame.new(0, 0, 0))
					task.wait(5)
					Finished = true
				end)

				repeat task.wait() until Finished
			end,
			function()
				-- broken quest
			end,
			function()
				-- soccer
			end,
			function()
				local Collect = Stages.CaveStage1.DarknessPart
				local StageData = OtherData.Stage0

				local Char = LocalPlayer.Character
				if not Char then return end

				local Hum = Char:FindFirstChildOfClass("Humanoid")
				if not Hum then return end
				
				repeat
					task.wait()

					if not Char then continue end

					Char:PivotTo(Collect.CFrame * CFrame.new(0, -60, -10))

					for _, BodyPart in Char:GetChildren() do
						if BodyPart:IsA("BasePart") then
							BodyPart.Velocity, BodyPart.RotVelocity = Vector3.zero, Vector3.zero
						end
					end
				until StageData.Value ~= "" or not Char or not Hum or Hum.Health <= 0

				LocalPlayer.Character:PivotTo(ChestTrigger.CFrame)
			end
		}

		local Questing = false

		QuestSection:Button("Complete", function()
			if Questing then return end
			Questing = true

			local Zone = GetZone()
			if Zone:FindFirstChild("Quest") then
				StartQuest:FireServer(0)
				repeat task.wait() until not Zone:FindFirstChild("Quest")
				task.wait(1)
			end
			
			for Num, Callback in pairs(Quests) do
				if Num == 7 then
					Num = 8
				end

				if OtherData:FindFirstChild(`Q{Num}`) or Num == 5 or Num == 8 then
					continue
				end

				StartQuest:FireServer(Num)
				Callback()

				local Zone = GetZone()
				repeat task.wait() until not Zone:FindFirstChild("Quest")
				task.wait(1)
			end

			Questing = false
		end)
	end
end

do
	local BigT = Root:Tab("Troll")

	local Troll = BigT:Section("Troll")

	local Clicking = false

	Troll:Button("Click Others Blocks", function()
		if Clicking then return end
		Clicking = true

		for _, Folder in workspace.Blocks:GetChildren() do
			if Folder.Name == LocalPlayer.Name then continue end

			for _, Block in Folder:GetChildren() do
				local Click = Block:FindFirstChildOfClass("ClickDetector")
				if Click then
					fireclickdetector(Click)
					RunService.RenderStepped:Wait()
					RunService.RenderStepped:Wait()
					RunService.RenderStepped:Wait()
				end
			end
		end

		Clicking = false
	end)
end
