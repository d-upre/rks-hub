-----------------------------
-- Services
-----------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-----------------------------
-- Variables & Functions
-----------------------------

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:FindFirstChildOfClass("PlayerScripts")

-----------------------------
-- Interface
-----------------------------

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ReliefScript/mogware/refs/heads/main/main.lua"))()

local Window = Library:Window("Military Roleplay")

-- Tab: Main
do
	local Main = Window:Tab("Main")

	-- Section: Anti
	do
		local Anti = Main:Section("Anti")

		Anti:Toggle("AntiCuff", function(Toggle)
			if Toggle then
				C1 = LocalPlayer:GetAttributeChangedSignal("Cuffed"):Connect(function()
					local IsCuffed = LocalPlayer:GetAttribute("Cuffed")
					if IsCuffed then
						local Char = LocalPlayer.Character
						if not Char then return end

						local Root = Char:FindFirstChild("HumanoidRootPart")
						if not Root then return end

						local Old = Root.CFrame
						Char:BreakJoints()
						
						C2 = LocalPlayer.CharacterAdded:Once(function(Char)
							local Root = Char:WaitForChild("HumanoidRootPart")
							if not Root then return end

							Root.CFrame = Old
						end)
					end
				end)
			else
				C1:Disconnect()
				C2:Disconnect()
				C1 = nil
				C2 = nil
			end
		end)
	end

	-- Section: Spoof
	do
		local Spoof = Main:Section("Spoof")

		local Script = PlayerScripts["[ CLIENT ] Engine"]["Game Structure"]["[ OverHead ]"]
		local Overhead = ReplicatedStorage.GameEvents.OverheadEvent
		
		local IsAfk = false
		local Device = "Mobile"

		local function ToggleAfk(bool)
			Overhead:FireServer("AFK", bool and "UnFocused" or "Focused")
		end

		Spoof:Toggle("Enabled", function(Toggle)
			Script.Disabled = Toggle
			ToggleAfk(IsAfk)
		end)

		Spoof:Toggle("AFK", function(Toggle)
			if Script.Disabled then
				IsAfk = Toggle
				ToggleAfk(IsAfk)
			end
		end)

		Spoof:Button("Mobile", function()
			Overhead:FireServer("Device", "Mobile")
		end)

		Spoof:Button("PC", function()
			Overhead:FireServer("Device", "PC")
		end)

		Spoof:Button("Gamepad", function()
			Overhead:FireServer("Device", "Gamepad")
		end)
	end
end
