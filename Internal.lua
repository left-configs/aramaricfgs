local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local State = {
    vPressed = false,
}

-- 検知されにくい安全かつ確実なクリック関数
local function SafeClick()
    if typeof(mouse1click) == "function" then
        mouse1click()
    elseif VirtualInputManager then
        -- VirtualInputManagerを使った低負荷なクリックシミュレート
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.001)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

-- Vキーの押下状態を監視
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.V then
        State.vPressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        State.vPressed = false
    end
end)

-- 高速連打ループ（フレーム単位で自然かつ高速に実行）
RunService.RenderStepped:Connect(function()
    if State.vPressed then
        SafeClick()
    end
end)

print("Fast Clicker Loaded Successfully!")
