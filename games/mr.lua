-----------------------------
-- Services
-----------------------------

local Players = game:GetService("Players")

-----------------------------
-- Variables & Functions
-----------------------------

local LocalPlayer = Players.LocalPlayer

-----------------------------
-- Interface
-----------------------------

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/rks-hub/refs/heads/main/assets/ui.lua"))({theme="cherry", smoothDragging=false})

local Window = Library.newWindow({text="Military Roleplay"})

-- Tab: Main
do
	local Main = Window:addMenu({text="Main"})

	-- Section: Anti
	do
		local Anti = Main:addSection({text="Anti"})

		Stage:addToggle({text="AntiCuff"}):bindToEvent("onToggle", function(Toggle)
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
				else
					C1:Disconnect()
					C2:Disconnect()
					C1 = nil
					C2 = nil
				end)
			end
		end)
	end
end
