-----------------------------
-- Services
-----------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-----------------------------
-- Variables & Functions
-----------------------------

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Remotes = ReplicatedStorage.Remotes

-----------------------------
-- Interface
-----------------------------

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/rks-hub/refs/heads/main/assets/ui.lua"))({theme="cherry", smoothDragging=false})

local Window = Library.newWindow({text="Roblox Talent Show"})

-- Tab: Main
do
	local Main = Window:addMenu({text="Main"})

	-- Section: Stage
	do
		local Stage = Main:addSection({text="Stage"})

		Stage:addToggle({text="AntiWarp"}):bindToEvent("onToggle", function(Toggle)
			if Toggle then
				AntiWarp = true

				local Save = {
					Position = nil,
					Cam = nil,
					Velocity = nil
				}

				local CanSave = true

				AntiWarpConnection = LocalPlayer.CharacterAdded:Connect(function(Char)
					CanSave = false

					local Root = Char:WaitForChild("HumanoidRootPart")
					if not Root then return end

					Root.CFrame = Save.Position
					Root.Velocity = Save.Velocity
					Camera.CFrame = Save.Cam

					CanSave = true
				end)
				
				while AntiWarp do
					task.wait()

					if not CanSave then continue end
					
					local Char = LocalPlayer.Character
					if Char then
						local Root = Char:FindFirstChild("HumanoidRootPart")
						if Root then
							Save.Position = Root.CFrame
							Save.Velocity = Root.Velocity
						end
					end

					Save.Cam = Camera.CFrame
				end
			else
				AntiWarp = false
				AntiWarpConnection:Disconnect()
			end
		end)

		local Cache = {}
		Stage:addToggle({text="Noclip"}):bindToEvent("onToggle", function(Toggle)
			if Toggle then
				Noclip = true
				Cache = {}
		
				local Char = LocalPlayer.Character
				if Char then
					for _, Part in Char:GetChildren() do
						if Part:IsA("BasePart") then
							Cache[Part.Name] = Part.CanCollide
						end
					end
				end
		
				while Noclip do
					RunService.Stepped:Wait()

					local Char = LocalPlayer.Character
					if not Char then return end
		
					for _, Part in Char:GetChildren() do
						if Part:IsA("BasePart") then
							Part.CanCollide = false
						end
					end
				end
			else
				Noclip = false
		
				local Char = LocalPlayer.Character
				if Char then
					for Name, Collide in Cache do
						local Found = Char:FindFirstChild(Name)
						if not Found then continue end
		
						Found.CanCollide = Collide
					end

					local Hum = Char:FindFirstChildOfClass("Humanoid")
					if Hum then
						Hum:ChangeState(2)
					end
				end
		
				Cache = {}
			end
		end)
	end
end

-- Tab: Farm
do
	local Farm = Window:addMenu({text="Farm"})

	-- Section: RepFarm
	do
		local RepFarm = Farm:addSection({text="RepFarm"})

		local Courses = workspace.ObstacleCourses
		local Rep = LocalPlayer.leaderstats.Rep

		RepFarm:addToggle({text="Enabled"}):bindToEvent("onToggle", function(Toggle)
			if Toggle then
				Farm = true

				while Farm do
					task.wait()

					local Char = LocalPlayer.Character
					if not Char then continue end

					local Hum = Char:FindFirstChildOfClass("Humanoid")
					if not Hum then continue end

					local Cooldown = tick()
					local Old = Char:GetPivot()

					for _, C in Courses:GetChildren() do
						if C:IsA("Model") and C.Name:sub(1, 3) == "Obs" then
							local Detection = C.Detection
							local Touch = C.ObstacleCourse
							
							repeat
								Char:PivotTo(Detection.CFrame)
								Hum:ChangeState(2)
								for _, Part in Char:GetChildren() do
									if Part:IsA("BasePart") then
										Part.Velocity = Vector3.new(0, math.random(-5, 5), 0)
										Part.RotVelocity = Vector3.zero
									end
								end
								task.wait()
							until not Farm or not Char or not Hum or LocalPlayer:FindFirstChild(C.Name)

							repeat
								Char:PivotTo(Touch.CFrame * CFrame.new(0, 3, 0))
								Hum:ChangeState(2)
								for _, Part in Char:GetChildren() do
									if Part:IsA("BasePart") then
										Part.Velocity = Vector3.new(0, math.random(-5, 5), 0)
										Part.RotVelocity = Vector3.zero
									end
								end
								task.wait()
							until not Farm or not Char or not Hum or not LocalPlayer:FindFirstChild(C.Name)

							if not Farm or not Char or not Hum then break end
						end
					end

					if Char and Old then
						task.wait()
						Char:PivotTo(Old)
					end

					repeat task.wait() until (tick() - Cooldown) >= 125
				end
			else
				Farm = false
			end
		end)
	end
end

-- Tab: Fun
do
	local Fun = Window:addMenu({text="Fun"})

	-- Section: Morphs
	do
		local Morphs = Fun:addSection({text="Morphs"})

		local MorphFolder = workspace.Morphs
		Morphs:addToggle({text="MorphSpam"}):bindToEvent("onToggle", function(Toggle)
			if Toggle then
				MorphSpam = true
				while MorphSpam do
					task.wait()

					local Char = LocalPlayer.Character
					if not Char then return end

					for _, Morph in MorphFolder:GetChildren() do
						if Morph:IsA("Model") then
							task.spawn(function()
								local Button = Morph.MorphButton
								Button.CanCollide = false
								Button.CFrame = Char:GetPivot()
								task.wait()
								if Button then
									Button.CFrame = CFrame.new(0, 9e5, 0)
								end
							end)
							task.wait(0.1)
						end
					end
				end
			else
				MorphSpam = false
			end
		end)
	end

	-- Section: QuickChatSpam
	do
		local QuickChat = Fun:addSection({text="QuickChatSpam"})

		local QC = Remotes.QuickChat
		local Option = "I dont love this performance"

		QuickChat:addToggle({text="Enabled"}):bindToEvent("onToggle", function(Toggle)
			QCS = Toggle
			while QCS do
				task.wait()
				QC:FireServer(Option)
			end
		end)

		QuickChat:addTextbox({text="Option"}):bindToEvent("onFocusLost", function(New)
			Option = New
		end)
	end
end
