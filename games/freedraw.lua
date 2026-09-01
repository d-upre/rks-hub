local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingFolder = workspace["Container(Drawing)"]
local LocalDraw = DrawingFolder[`Collector({LocalPlayer.UserId})`]

local Net = ReplicatedStorage.packages._Index["vorlias_net@2.1.4"].net._NetManaged
local Create = Net.createLine
local Clear = Net.clearAll

local LastColor = nil
local function Draw(LayerFolder, Positions, Thickness, Transparency, Color, Offset)
	if not Positions or #Positions == 0 then return end
	Thickness = Thickness or 0.05
	Transparency = Transparency or 0
	Color = Color or Color3.new(0, 0, 0)
	Offset = Offset or Vector2.new(0, 0)

	local Offsetted = {}
	for _, p in ipairs(Positions) do
		table.insert(Offsetted, Vector2.new(p.X + Offset.X, p.Y + Offset.Y))
	end

	local LayerStr = LayerFolder.Name:sub(7, -2)

	Create:FireServer(
		HttpService:GenerateGUID(false),
		{
			LayerStr,
			{
				thickness = math.clamp(Thickness, 0.05, 2),
				transparency = math.clamp(Transparency, 0, 0.999),
				color = Color,
			},
			Offsetted,
		}
	)

	if LastColor and LastColor ~= Color then
		task.wait(2)
	else
		task.wait(6 / 16)
	end

	LastColor = Color
end

local FONT = {
	-- Numbers
	["0"] = {{{0,0},{1,0},{1,1},{0,1},{0,0}}},
	["1"] = {{{0.5,0},{0.5,1}}},
	["2"] = {{{0,1},{1,1},{1,0.5},{0,0.5},{0,0},{1,0}}},
	["3"] = {{{0,1},{1,1},{1,0.5},{0.3,0.5},{1,0.5},{1,0},{0,0}}},
	["4"] = {{{0,1},{0,0.5},{1,0.5},{1,1},{1,0}}},
	["5"] = {{{1,1},{0,1},{0,0.5},{1,0.5},{1,0},{0,0}}},
	["6"] = {{{1,1},{0,1},{0,0},{1,0},{1,0.5},{0,0.5}}},
	["7"] = {{{0,1},{1,1},{0.5,0}}},
	["8"] = {{{0,0},{1,0},{1,1},{0,1},{0,0},{0,0.5},{1,0.5}}},
	["9"] = {{{1,0},{1,1},{0,1},{0,0.5},{1,0.5}}},

	-- Uppercase
	["A"] = {{{0,0},{0.5,1},{1,0},{0.8,0.4},{0.2,0.4}}},
	["B"] = {{{0,0},{0,1},{0.7,1},{1,0.75},{0.7,0.5},{0,0.5},{0.7,0.5},{1,0.25},{0.7,0},{0,0}}},
	["C"] = {{{1,1},{0.3,1},{0,0.7},{0,0.3},{0.3,0},{1,0}}},
	["D"] = {{{0,0},{0,1},{0.6,1},{1,0.7},{1,0.3},{0.6,0},{0,0}}},
	["E"] = {{{1,1},{0,1},{0,0},{1,0},{0,0},{0,0.5},{0.8,0.5}}},
	["F"] = {{{1,1},{0,1},{0,0},{0,0.5},{0.8,0.5}}},
	["G"] = {{{1,1},{0.3,1},{0,0.7},{0,0.3},{0.3,0},{1,0},{1,0.5},{0.5,0.5}}},
	["H"] = {{{0,0},{0,1},{0,0.5},{1,0.5},{1,1},{1,0}}},
	["I"] = {{{0.2,1},{0.8,1},{0.5,1},{0.5,0},{0.2,0},{0.8,0}}},
	["J"] = {{{0.2,1},{0.8,1},{0.7,1},{0.7,0.2},{0.5,0},{0.2,0.2}}},
	["K"] = {{{0,0},{0,1},{0,0.5},{1,1},{0,0.5},{1,0}}},
	["L"] = {{{0,1},{0,0},{1,0}}},
	["M"] = {{{0,0},{0,1},{0.5,0.5},{1,1},{1,0}}},
	["N"] = {{{0,0},{0,1},{1,0},{1,1}}},
	["O"] = {{{0,0.3},{0,0.7},{0.3,1},{0.7,1},{1,0.7},{1,0.3},{0.7,0},{0.3,0},{0,0.3}}},
	["P"] = {{{0,0},{0,1},{0.7,1},{1,0.75},{0.7,0.5},{0,0.5}}},
	["Q"] = {{{0,0.3},{0,0.7},{0.3,1},{0.7,1},{1,0.7},{1,0.3},{0.7,0},{0.3,0},{0,0.3},{0.6,0.3},{1,0}}},
	["R"] = {{{0,0},{0,1},{0.7,1},{1,0.75},{0.7,0.5},{0,0.5},{0.5,0.5},{1,0}}},
	["S"] = {{{1,1},{0.2,1},{0,0.8},{0.2,0.5},{0.8,0.5},{1,0.2},{0.8,0},{0,0}}},
	["T"] = {{{0,1},{1,1},{0.5,1},{0.5,0}}},
	["U"] = {{{0,1},{0,0.2},{0.3,0},{0.7,0},{1,0.2},{1,1}}},
	["V"] = {{{0,1},{0.5,0},{1,1}}},
	["W"] = {{{0,1},{0.2,0},{0.5,0.4},{0.8,0},{1,1}}},
	["X"] = {{{0,0},{1,1},{0,1},{1,0}}},
	["Y"] = {{{0,1},{0.5,0.5},{1,1},{0.5,0.5},{0.5,0}}},
	["Z"] = {{{0,1},{1,1},{0,0},{1,0}}},

	-- Lowercase (x-height = 0.6; ascenders b,d,f,h,k,l,t to ~1; descenders g,j,p,q,y to ~-0.3)
	["a"] = {{{1,0},{1,0.6},{0.3333,0.6},{0,0.45},{0,0.15},{0.3333,0},{0.8333,0.05},{1,0.2}}},
	["b"] = {{{0,1},{0,0},{0,0.45},{0.5,0.6},{1,0.45},{1,0.15},{0.5,0},{0,0.15}}},
	["c"] = {{{1,0.45},{0.5833,0.6},{0.1667,0.45},{0.1667,0.15},{0.5833,0},{1,0.15}}},
	["d"] = {{{1,1},{1,0},{1,0.45},{0.5,0.6},{0,0.45},{0,0.15},{0.5,0},{1,0.15}}},
	["e"] = {{{0,0.3},{1,0.3},{1,0.5},{0.5833,0.6},{0.1667,0.45},{0,0.25},{0.1667,0.05},{0.5833,0},{0.9167,0.1}}},
	["f"] = {{{1,1},{0.5833,1},{0.3333,0.85},{0.3333,0},{0.3333,0.55},{0,0.55},{0.75,0.55}}},
	["g"] = {{{1,0.45},{0.5833,0.6},{0.1667,0.45},{0.1667,0.15},{0.5833,0},{1,0.15},{1,0.6},{1,-0.1},{0.6667,-0.3},{0.1667,-0.25}}},
	["h"] = {{{0,1},{0,0},{0,0.45},{0.5,0.6},{1,0.45},{1,0}}},
	["i"] = {{{0.5,0.6},{0.5,0}},{{0.4667,0.8},{0.5333,0.8},{0.5333,0.85},{0.4667,0.85},{0.4667,0.8}}},
	["j"] = {{{0.6667,0.6},{0.6667,-0.15},{0.4167,-0.3},{0.1667,-0.25}},{{0.6333,0.8},{0.7,0.8},{0.7,0.85},{0.6333,0.85},{0.6333,0.8}}},
	["k"] = {{{0,1},{0,0},{0,0.3},{0.8333,0.6},{0.25,0.45},{0.9167,0}}},
	["l"] = {{{0.5,1},{0.5,0.1},{0.75,0}}},
	["m"] = {{{0,0},{0,0.6},{0.5,0.6},{0.5,0},{0.5,0.45},{0.75,0.6},{1,0.45},{1,0}}},
	["n"] = {{{0,0.6},{0,0},{0,0.45},{0.5,0.6},{1,0.45},{1,0}}},
	["o"] = {{{0,0.3},{0,0.45},{0.5,0.6},{1,0.45},{1,0.15},{0.5,0},{0,0.15},{0,0.3}}},
	["p"] = {{{0,0.6},{0,-0.3},{0,0.15},{0.5,0},{1,0.15},{1,0.45},{0.5,0.6},{0,0.45}}},
	["q"] = {{{1,0.6},{1,-0.3},{1,0.15},{0.5,0},{0,0.15},{0,0.45},{0.5,0.6},{1,0.45}}},
	["r"] = {{{0,0.6},{0,0},{0,0.45},{0.4167,0.6},{0.8333,0.5}}},
	["s"] = {{{0.9167,0.55},{0.25,0.6},{0,0.45},{0.25,0.3},{0.75,0.3},{1,0.15},{0.75,0},{0.0833,0.05}}},
	["t"] = {{{0.5833,0.9},{0.5833,0.6},{0.9167,0.6},{0.1667,0.6},{0.5833,0.6},{0.5833,0.15},{0.8333,0}}},
	["u"] = {{{0,0.6},{0,0.15},{0.5,0},{1,0.15},{1,0.6},{1,0}}},
	["v"] = {{{0,0.6},{0.5,0},{1,0.6}}},
	["w"] = {{{0,0.6},{0.25,0},{0.5,0.3},{0.75,0},{1,0.6}}},
	["x"] = {{{0,0},{1,0.6},{0.5,0.3},{0,0.6},{1,0}}},
	["y"] = {{{0,0.6},{0.5,0},{1,0.6},{0.5,0},{0.25,-0.3}}},
	["z"] = {{{0,0.6},{1,0.6},{0,0},{1,0}}},

	-- Special
	["."] = {{{0.4,0},{0.6,0},{0.6,0.15},{0.4,0.15},{0.4,0}}},
	[","] = {{{0.6,0.15},{0.4,0.15},{0.4,0},{0.6,-0.2}}},
	[":"] = {{{0.4,0},{0.6,0},{0.6,0.15},{0.4,0.15},{0.4,0}},{{0.4,0.5},{0.6,0.5},{0.6,0.65},{0.4,0.65},{0.4,0.5}}},
	[";"] = {{{0.4,0.5},{0.6,0.5},{0.6,0.65},{0.4,0.65},{0.4,0.5}},{{0.6,0.15},{0.4,0.15},{0.4,0},{0.6,-0.2}}},
	["!"] = {{{0.5,1},{0.45,0.35}},{{0.4,0},{0.6,0},{0.6,0.15},{0.4,0.15},{0.4,0}}},
	["?"] = {{{0,0.75},{0.2,1},{0.8,1},{1,0.75},{0.7,0.5},{0.5,0.5},{0.5,0.35}},{{0.4,0},{0.6,0},{0.6,0.15},{0.4,0.15},{0.4,0}}},
	["'"] = {{{0.45,1},{0.55,0.6}}},
	["\""] = {{{0.25,1},{0.35,0.6}},{{0.65,1},{0.75,0.6}}},
	["`"] = {{{0.4,1},{0.6,0.6}}},
	["-"] = {{{0.1,0.5},{0.9,0.5}}},
	["_"] = {{{0,-0.05},{1,-0.05}}},
	["="] = {{{0.1,0.65},{0.9,0.65},{0.9,0.35},{0.1,0.35}}},
	["+"] = {{{0.1,0.5},{0.9,0.5},{0.5,0.5},{0.5,0.9},{0.5,0.1}}},
	["*"] = {{{0.5,0.2},{0.5,0.8},{0.2,0.65},{0.8,0.35},{0.2,0.35},{0.8,0.65}}},
	["/"] = {{{0,0},{1,1}}},
	["\\"] = {{{0,1},{1,0}}},
	["|"] = {{{0.5,0},{0.5,1}}},
	["("] = {{{0.7,1},{0.3,0.7},{0.3,0.3},{0.7,0}}},
	[")"] = {{{0.3,1},{0.7,0.7},{0.7,0.3},{0.3,0}}},
	["["] = {{{0.6,1},{0.3,1},{0.3,0},{0.6,0}}},
	["]"] = {{{0.4,1},{0.7,1},{0.7,0},{0.4,0}}},
	["{"] = {{{0.6,1},{0.4,0.9},{0.4,0.55},{0.2,0.5},{0.4,0.45},{0.4,0.1},{0.6,0}}},
	["}"] = {{{0.4,1},{0.6,0.9},{0.6,0.55},{0.8,0.5},{0.6,0.45},{0.6,0.1},{0.4,0}}},
	["<"] = {{{0.8,1},{0.2,0.5},{0.8,0}}},
	[">"] = {{{0.2,1},{0.8,0.5},{0.2,0}}},
	["@"] = {{{0.65,0.35},{0.45,0.3},{0.35,0.45},{0.35,0.6},{0.45,0.7},{0.6,0.65},{0.65,0.5},{0.65,0.35},{0.8,0.3},{0.85,0.55},{0.75,0.85},{0.45,0.95},{0.15,0.75},{0.1,0.45},{0.3,0.1},{0.65,0.05},{0.9,0.15}}},
	["#"] = {{{0.25,0},{0.4,1},{0.1,0.65},{0.9,0.65},{0.75,1},{0.6,0},{0.9,0.35},{0.1,0.35}}},
	["$"] = {{{1,0.85},{0.2,1},{0,0.8},{0.2,0.5},{0.8,0.5},{1,0.2},{0.8,0},{0,0.15},{0.5,-0.1},{0.5,1.1}}},
	["%"] = {{{0,0},{1,1}},{{0.1,0.85},{0.25,0.85},{0.25,1},{0.1,1},{0.1,0.85}},{{0.75,0},{0.9,0},{0.9,0.15},{0.75,0.15},{0.75,0}}},
	["&"] = {{{1,0},{0.35,0.65},{0.25,0.8},{0.35,0.95},{0.5,0.85},{0.4,0.65},{0.1,0.35},{0.15,0.1},{0.4,0},{0.65,0.1},{1,0.45}}},
	["^"] = {{{0.2,0.6},{0.5,1},{0.8,0.6}}},
	["~"] = {{{0.1,0.4},{0.3,0.6},{0.5,0.4},{0.7,0.6},{0.9,0.4}}},

	-- Space
	[" "] = {},
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d-upre/Dupre-Library/refs/heads/main/library.lua"))()

local Root = Library:Init("Free Draw")

local Main = Root:Tab("Main")

local FontSection = Main:Section("Draw Font")

local DrawText = "example"

local Spacing = 1.2
local Size = 1.5

local Thickness = 0.2
local Transparency = 0
local Color = Color3.new(1, 0, 0)

FontSection:TextBox("Font Text", "text here", function(Text)
	DrawText = Text
	local Layer = DrawingFolder[`Collector({LocalPlayer.UserId})`]:GetChildren()[1]
	local Pos = LocalPlayer.Character:GetPivot()
	local Origin = Vector2.new(Pos.X, Pos.Z)

	local x = 0
	local y = 0

	for i = 1, #Text do
		local Letter = Text:sub(i, i)

		if Letter == "\n" then
			x = 0
			y += 1
			continue
		end

		local Strokes = FONT[Letter] or FONT[" "]

		for _, Stroke in ipairs(Strokes) do
			local Compile = {}

			for pointIndex, Point in ipairs(Stroke) do
				local New = Origin
					+ Vector2.new(
						x * (Spacing * Size) + (Point[1] * Size) + (pointIndex * 0.001),
						-(Point[2] * Size) + (y * ((Spacing * 2) * Size))
					)

				table.insert(Compile, New)
			end

			Draw(Layer, Compile, Thickness, Transparency, Color)
		end

		x += 1
	end
end)

FontSection:TextBox("Transparency", "default 0", function(Text)
	Transparency = tonumber(Text) or 0
end)

FontSection:TextBox("Thickness", "default 0.2", function(Text)
	Thickness = tonumber(Text) or 0
end)

FontSection:TextBox("Size", "default 1.5", function(Text)
	Size = tonumber(Text) or 0
end)

FontSection:TextBox("Spacing", "default 1.2", function(Text)
	Spacing = tonumber(Text) or 0
end)

local CrashSection = Main:Section("Crash")

CrashSection:Toggle("Crash", function(Toggled)
	if Toggled then
		local Layer = DrawingFolder[`Collector({LocalPlayer.UserId})`]:GetChildren()[1]
		local Pos = {}

		for _ = 1, 2500 do
			table.insert(Pos,
				Vector2.new(
					math.random(1, 10000000) / 1000000,
					math.random(1, 10000000) / 1000000
				)
			)
		end

		CrashDelete = Layer.ChildAdded:Connect(function(Line)
			Line:Destroy()
		end)

		CrashLoop = true
		while CrashLoop do
			for _ = 1, 16 do
				if not CrashLoop then break end

				Draw(Layer, Pos, 0.05, 1, Color3.new(1, 1, 1))

				for _, Line in Layer:GetChildren() do
					Line:Destroy()
				end

				task.wait(5.5/16)
			end
		end
	else
		CrashLoop = false
		CrashDelete:Disconnect()
		task.wait(2)
		Clear:FireServer()
	end
end)

local Copy = Root:Tab("Copy")

local CopySection = Copy:Section("Copy Players")

CopySection:TextBox("Target", "username here", function(Text)
	local Target = Players[Text]
	local TargetFolder = DrawingFolder[`Collector({Target.UserId})`]

	local Layers = {}
	for _, L in LocalDraw:GetChildren() do
		local Found = L:GetChildren()[1]
		if not Found then continue end

		local Num = math.round(Found:GetPivot().Y * 100)
		if Num == 0 then
			Num = 1
		end
		
		Layers[Num] = L
	end

	local Num = 0

	local Cache = {}
	local BoundsMin, BoundsMax

	for _, LayerObj in TargetFolder:GetChildren() do
		local Found = LayerObj:GetChildren()[1]
		if not Found then continue end

		local layerNum = math.round(Found:GetPivot().Y * 100)
		if layerNum == 0 then
			layerNum = 1
		end

		for _, Line in LayerObj:GetChildren() do
			local positions = {}
			local thickness, transparency, color

			for _, part in pairs(Line:GetChildren()) do
				local half = part.Size.Z / 2
				local s = part.CFrame.Position - part.CFrame.LookVector * half
				local e = part.CFrame.Position + part.CFrame.LookVector * half
				table.insert(positions, Vector2.new(s.X, s.Z))
				table.insert(positions, Vector2.new(e.X, e.Z))

				thickness = part.Size.X
				transparency = part.Transparency
				color = part.Color

				for _, pos in ipairs({ Vector2.new(s.X, s.Z), Vector2.new(e.X, e.Z) }) do
					if not BoundsMin then
						BoundsMin = Vector2.new(pos.X, pos.Y)
						BoundsMax = Vector2.new(pos.X, pos.Y)
					else
						BoundsMin = Vector2.new(math.min(BoundsMin.X, pos.X), math.min(BoundsMin.Y, pos.Y))
						BoundsMax = Vector2.new(math.max(BoundsMax.X, pos.X), math.max(BoundsMax.Y, pos.Y))
					end
				end
			end

			if #positions > 0 then
				table.insert(Cache, {
					positions = positions,
					thickness = thickness,
					transparency = transparency,
					color = color,
					layerNum = layerNum,
				})
			end
		end
	end

	local PREVIEW_Y = 0.15

	local Center = BoundsMin
		and Vector2.new((BoundsMin.X + BoundsMax.X) / 2, (BoundsMin.Y + BoundsMax.Y) / 2)
		or Vector2.new(0, 0)

	local PreviewFolder = Instance.new("Folder", workspace)
	PreviewFolder.Name = "DrawingPreview"

	local PreviewData = {}

	for _, line in ipairs(Cache) do
		local positions = line.positions
		for i = 1, #positions - 1, 2 do
			local a, b = positions[i], positions[i + 1]
			local a3 = Vector3.new(a.X, PREVIEW_Y, a.Y)
			local b3 = Vector3.new(b.X, PREVIEW_Y, b.Y)
			local len = (b3 - a3).Magnitude
			if len < 0.01 then continue end

			local mid = (a3 + b3) / 2
			local baseCF = CFrame.lookAt(mid, mid + (b3 - a3).Unit)

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Size = Vector3.new(line.thickness, 0.05, len)
			part.CFrame = baseCF
			part.Color = line.color
			part.Material = Enum.Material.SmoothPlastic
			part.Transparency = 0.4
			part.Parent = PreviewFolder

			table.insert(PreviewData, { part = part, baseCF = baseCF })
		end
	end

	local function MovePreview(offset)
		local v3 = Vector3.new(offset.X, 0, offset.Y)
		for _, d in ipairs(PreviewData) do
			d.part.CFrame = d.baseCF + v3
		end
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Name = "DrawingPlacement"
	ScreenGui.Parent = LocalPlayer.PlayerGui

	local CancelBtn = Instance.new("TextButton")
	CancelBtn.Size = UDim2.new(0, 120, 0, 40)
	CancelBtn.Position = UDim2.new(0.5, -60, 1, -60)
	CancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	CancelBtn.TextColor3 = Color3.new(1, 1, 1)
	CancelBtn.Font = Enum.Font.GothamBold
	CancelBtn.TextSize = 16
	CancelBtn.Text = "Cancel"
	CancelBtn.Parent = ScreenGui

	local Mouse = LocalPlayer:GetMouse()
	local PlacementOffset = Vector2.new(0, 0)
	local Placing = true

	local function Cleanup()
		Placing = false
		PreviewFolder:Destroy()
		ScreenGui:Destroy()
	end

	local MoveConn = RunService.RenderStepped:Connect(function()
		if not Placing then return end
		local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
		local t = ray.Direction.Y ~= 0 and (-ray.Origin.Y / ray.Direction.Y) or 0
		if t < 0 then t = 0 end
		local hit = ray.Origin + ray.Direction * t
		PlacementOffset = Vector2.new(hit.X - Center.X, hit.Z - Center.Y)
		MovePreview(PlacementOffset)
	end)

	CancelBtn.MouseButton1Click:Connect(function()
		if not Placing then return end
		MoveConn:Disconnect()
		Cleanup()
	end)

	local ClickConn
	ClickConn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not Placing then return end

		MoveConn:Disconnect()
		ClickConn:Disconnect()
		Cleanup()

		for _, line in ipairs(Cache) do
			local layerFolder = Layers[line.layerNum]
			if not layerFolder then continue end
			Draw(layerFolder, line.positions, line.thickness, line.transparency, line.color, PlacementOffset)
		end
	end)
end)
