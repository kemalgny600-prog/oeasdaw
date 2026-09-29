local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

--------------------------------------------------
-- AYARLAR & DEĞİŞKENLER
--------------------------------------------------
local aimEnabled = false
local silentAimEnabled = false
local autoTargetEnabled = false 
local autoAttackEnabled = false 
local espEnabled = false
local boxEspEnabled = false
local skeletonEspEnabled = false
local tracerEspEnabled = false
local wallbangEnabled = false
local crosshairEnabled = false
local fullbrightEnabled = false
local vehicleUnlockerEnabled = false
local noStaminaEnabled = false
local flyUpEnabled = false
local flyDownEnabled = false
local contractEspEnabled = false

local safeList = {} 
local aimKey = Enum.KeyCode.Q
local toggleKey = Enum.KeyCode.Insert

--------------------------------------------------
-- GUI ARAYÜZÜ OLUŞTURMA
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatMenuGUI"
ScreenGui.ResetOnSpawn = false

-- Oyuncunun CoreGui/PlayerGui erişimi
local parentTarget = game:GetService("CoreGui")
if not pcall(function() ScreenGui.Parent = parentTarget end) then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Ana Çerçeve (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Sürüklenebilir menü
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Başlık Barı (Title Bar)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleLabel.Text = "  CHEAT MENU [INSERT]"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 15
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleLabel

-- Buton Listesi Konteyneri
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollFrame

-- Buton Oluşturma Yardımcı Fonksiyonu
local function createToggleButton(text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = ScrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn

    local state = defaultState
    local function updateVisual()
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(46, 139, 87) -- Yeşil (Açık)
            btn.Text = text .. " : AÇIK"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60) -- Gri (Kapalı)
            btn.Text = text .. " : KAPALI"
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end

    updateVisual()

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        callback(state)
    end)

    return btn
end

-- Menü Butonları
createToggleButton("🎯 Aim Assist (Q)", aimEnabled, function(val) aimEnabled = val end)
createToggleButton("👁️ Player ESP", espEnabled, function(val) espEnabled = val end)
createToggleButton("📜 Kontrat Görme", contractEspEnabled, function(val) contractEspEnabled = val end)
createToggleButton("💡 Fullbright", fullbrightEnabled, function(val) fullbrightEnabled = val end)
createToggleButton("🕊️ Fly (Uçma)", flyUpEnabled, function(val) 
    flyUpEnabled = val 
    flyDownEnabled = val
end)

--------------------------------------------------
-- KONTRAT GÖRME (CONTRACT ESP) MANTIGI
--------------------------------------------------
local contractMarkers = {}

local function findContractObjects()
    local contracts = {}
    local possibleFolders = {"Contracts", "Jobs", "Missions", "Deliveries"}
    for _, folderName in pairs(possibleFolders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                table.insert(contracts, item)
            end
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            if string.find(obj.Name:lower(), "contract") or string.find(obj.Name:lower(), "job") then
                table.insert(contracts, obj)
            end
        end
    end
    return contracts
end

local function createContractMarker(target)
    if target:FindFirstChild("ContractMarker") then return end
    local part = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")) or target
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ContractMarker"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.Text = "📜 " .. target.Name
    label.Parent = billboard

    billboard.Parent = part
    table.insert(contractMarkers, billboard)
end

local function updateContracts()
    if not contractEspEnabled then
        for _, gui in pairs(contractMarkers) do
            if gui and gui.Parent then gui:Destroy() end
        end
        contractMarkers = {}
        return
    end

    for _, contract in pairs(findContractObjects()) do
        createContractMarker(contract)
        local part = contract:IsA("Model") and (contract.PrimaryPart or contract:FindFirstChildWhichIsA("BasePart")) or contract
        if part and part:FindFirstChild("ContractMarker") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = math.floor((player.Character.HumanoidRootPart.Position - part.Position).Magnitude)
            local label = part.ContractMarker:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = string.format("📜 %s\n[%dm]", contract.Name, dist)
            end
        end
    end
end

--------------------------------------------------
-- SİSTEM DÖNGÜLERİ VE TUŞ KONTROLLERİ
--------------------------------------------------
local isAiming = false

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Insert Tuşu: GUI'yi Göster / Gizle
    if input.KeyCode == toggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    -- Q Tuşu: Aimlock
    if input.KeyCode == aimKey then
        isAiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == aimKey then
        isAiming = false
    end
end)

-- Player ESP Mantığı
local function applyESP(targetPlayer)
    if targetPlayer.Character and not targetPlayer.Character:FindFirstChild("ESPHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Parent = targetPlayer.Character
    end
end

local function removeESP(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("ESPHighlight") then
        targetPlayer.Character.ESPHighlight:Destroy()
    end
end

-- Ana Render Döngüsü
RunService.RenderStepped:Connect(function()
    -- Aimlock
    if aimEnabled and isAiming then
        local shortestDist = math.huge
        local closestTarget = nil
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                local pos, onScreen = camera:WorldToViewportPoint(v.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = v
                    end
                end
            end
        end
        if closestTarget then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Character.Head.Position)
        end
    end

    -- Player ESP
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player then
            if espEnabled then applyESP(v) else removeESP(v) end
        end
    end

    -- Fullbright
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    end

    -- Fly
    if flyUpEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.5, 0)
    end

    -- Kontrat Taraması
    updateContracts()
end)

print("GUI Başarıyla Yüklendi! Insert tuşu ile menüyü açıp kapatabilirsin.")
