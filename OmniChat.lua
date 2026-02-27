-- ==========================================
--        OMNICHAT HUB - INTERFACE & API
-- ==========================================

local API_URL = "http://us1.airanode.cloud:25765/api/chat"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not request_func then warn("Ton exécuteur ne supporte pas les requêtes HTTP !") end

local OmniKey = ""
local IsRunning = false
local SystemPrompt = "You are a helpful assistant."
local FormatString = "[ChatBot] %s"
local ChatHistory = {}

local TargetPlayers = {}
local WhitelistMode = false
local ListeningRange = 50
local MaxMessageLength = 150
local AntiSpamEnabled = true
local LastMessageProcessedTime = 0 
local UseBuffer = false
local AutoRemindBot = true
local SelectedLanguage = "English"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "OmniChat Hub 🤖", Icon = 0, LoadingTitle = "OmniChat Interface", LoadingSubtitle = "Optimized", ShowText = "OmniChat", Theme = "Default", ToggleUIKeybind = "K", 
    ConfigurationSaving = { Enabled = true, FolderName = "OmniChatConfig", FileName = "OmniChatSave" },
    Discord = { Enabled = false }, KeySystem = false 
})

local MainTab = Window:CreateTab("Main", "home")
local AITab = Window:CreateTab("AI Settings", "cpu")
local PremiumTab = Window:CreateTab("Premium", "star")
local ChatTab = Window:CreateTab("Chat", "message-square")
local MoreTab = Window:CreateTab("More", "plus-circle")
local HelpTab = Window:CreateTab("Help", "help-circle")

-- ==================== MAIN TAB ====================
local PointsLabel = MainTab:CreateLabel("💳 Current Points: ?", "coins", Color3.fromRGB(255, 215, 0), false)
MainTab:CreateToggle({ Name = "Running", CurrentValue = false, Flag = "Toggle_Running", Callback = function(Value) IsRunning = Value end })
MainTab:CreateDivider()

local Drop_Players
MainTab:CreateToggle({
    Name = "Whitelist Mode (On = Whitelist, Off = Blacklist)",
    CurrentValue = false,
    Flag = "Toggle_Whitelist",
    Callback = function(Value) WhitelistMode = Value end,
})

MainTab:CreateInput({
    Name = "Add player to List",
    CurrentValue = "",
    PlaceholderText = "Enter exact username...",
    RemoveTextAfterFocusLost = true,
    Flag = "Input_List",
    Callback = function(Text)
        if Text ~= "" then
            table.insert(TargetPlayers, Text)
            if Drop_Players then Drop_Players:Refresh(TargetPlayers) end
            Rayfield:Notify({Title = "Added", Content = Text .. " added to the list.", Duration = 3})
        end
    end,
})

Drop_Players = MainTab:CreateDropdown({ Name = "Players in List", Options = {"None"}, CurrentOption = {"None"}, MultipleOptions = false, Flag = "Drop_Players", Callback = function(Options) end })
MainTab:CreateButton({ Name = "Clear the List", Callback = function() TargetPlayers = {}; Drop_Players:Refresh({"None"}) end })

MainTab:CreateDivider()
MainTab:CreateSlider({ Name = "Listening Range (Studs)", Range = {10, 200}, Increment = 10, Suffix = "Studs", CurrentValue = 50, Flag = "Slider_Range", Callback = function(Value) ListeningRange = Value end })
MainTab:CreateSlider({ Name = "Max Message Length", Range = {10, 300}, Increment = 10, Suffix = "Chars", CurrentValue = 150, Flag = "Slider_Length", Callback = function(Value) MaxMessageLength = Value end })
MainTab:CreateToggle({ Name = "Anti Spam (3 sec cooldown)", CurrentValue = true, Flag = "Toggle_AntiSpam", Callback = function(Value) AntiSpamEnabled = Value end })
MainTab:CreateToggle({ Name = "Buffer (Add 3 sec delay)", CurrentValue = false, Flag = "Toggle_Buffer", Callback = function(Value) UseBuffer = Value end })
MainTab:CreateButton({ Name = "Reset AI Memory", Callback = function() ChatHistory = {}; Rayfield:Notify({Title = "Memory Cleared", Content = "The AI forgot the previous conversation.", Duration = 3}) end })
MainTab:CreateInput({ Name = "Chatbot Message Formatting", CurrentValue = "[ChatBot] %s", PlaceholderText = "[ChatBot] %s", RemoveTextAfterFocusLost = false, Flag = "Input_Format", Callback = function(Text) FormatString = Text end })
MainTab:CreateToggle({ Name = "Auto remind you're a chatbot", CurrentValue = true, Flag = "Toggle_RemindBot", Callback = function(Value) AutoRemindBot = Value end })

-- ==================== AI SETTINGS TAB ====================
AITab:CreateDropdown({ Name = "Select the character of your AI", Options = {"Normal", "Aggressive", "Friendly", "Sarcastic", "UwU"}, CurrentOption = {"Normal"}, MultipleOptions = false, Flag = "Drop_Character", Callback = function(Options) SystemPrompt = "You are a " .. Options[1] .. " assistant." end })
AITab:CreateDropdown({ Name = "Select AI Model", Options = {"Meta-Llama-3.1-8B-Instruct (Default | 5 points)"}, CurrentOption = {"Meta-Llama-3.1-8B-Instruct (Default | 5 points)"}, MultipleOptions = false, Flag = "Drop_Model", Callback = function(Options) end })
AITab:CreateDropdown({ Name = "Language", Options = {"English", "French", "Spanish", "German"}, CurrentOption = {"English"}, MultipleOptions = false, Flag = "Drop_Language", Callback = function(Options) SelectedLanguage = Options[1] end })

-- ==================== PREMIUM TAB ====================
PremiumTab:CreateLabel("❌ Premium is not activated", "x-octagon", Color3.fromRGB(255, 50, 50), false)
PremiumTab:CreateToggle({ Name = "Text to Action Mode (Costs 1.5x points)", CurrentValue = false, Flag = "Toggle_TextAction", Callback = function() end })
PremiumTab:CreateToggle({ Name = "Auto Moving", CurrentValue = false, Flag = "Toggle_AutoMove", Callback = function() end })
PremiumTab:CreateDivider()
PremiumTab:CreateToggle({ Name = "Enable Custom Prompt", CurrentValue = false, Flag = "Toggle_CustomPrompt", Callback = function() end })
PremiumTab:CreateInput({ Name = "Enter custom prompt here", CurrentValue = "", PlaceholderText = "Act as a...", RemoveTextAfterFocusLost = false, Flag = "Input_Prompt", Callback = function(Text) SystemPrompt = Text end })
PremiumTab:CreateParagraph({ Title = "Current Custom Prompt", Content = "Just be a normal ai" })
PremiumTab:CreateDivider()
PremiumTab:CreateDropdown({ Name = "Custom AIs", Options = {"None"}, CurrentOption = {"None"}, MultipleOptions = false, Flag = "Drop_CustomAIs", Callback = function() end })
PremiumTab:CreateInput({ Name = "Save custom prompt with name:", CurrentValue = "", PlaceholderText = "Name your AI...", RemoveTextAfterFocusLost = true, Flag = "Input_SavePrompt", Callback = function() end })

-- ==================== CHAT TAB ====================
local AIAnswerParagraph = ChatTab:CreateParagraph({ Title = "AI's Answer", Content = "Waiting for a message..." })
ChatTab:CreateButton({ Name = "Clear Chat", Callback = function() AIAnswerParagraph:Set({Title = "AI's Answer", Content = "Waiting for a message..."}) end })

local LastAIResponse = ""
ChatTab:CreateButton({ Name = "Copy the answer", Callback = function() if LastAIResponse ~= "" then setclipboard(LastAIResponse) end end })

ChatTab:CreateInput({
    Name = "Message", CurrentValue = "", PlaceholderText = "Talk to the AI directly here...", RemoveTextAfterFocusLost = true, Flag = "Input_ManualMessage",
    Callback = function(Text) 
        if not IsRunning or OmniKey == "" then return end
        AIAnswerParagraph:Set({Title = "AI's Answer", Content = "⏳ Thinking..."})
        
        local MemoryContext = #ChatHistory > 0 and (" Recent chat context: " .. table.concat(ChatHistory, " | ")) or ""
        local FinalSystemPrompt = SystemPrompt .. MemoryContext .. " Always reply in " .. SelectedLanguage .. "."
        if AutoRemindBot then FinalSystemPrompt = FinalSystemPrompt .. " Remind the user you are an AI ChatBot." end

        local success, response = pcall(function() return request_func({ Url = API_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ omni_key = OmniKey, system_prompt = FinalSystemPrompt, user_message = Text }) }) end)

        if success and response then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if decodeSuccess and data.success then
                LastAIResponse = data.answer
                AIAnswerParagraph:Set({Title = "AI's Answer", Content = string.format(FormatString, data.answer)})
                PointsLabel:Set("💳 Current Points: " .. tostring(data.remaining_points))
            else
                AIAnswerParagraph:Set({Title = "❌ API Error", Content = tostring(data and data.error or "Unknown error")})
            end
        end
    end,
})

-- ==================== MORE TAB ====================
MoreTab:CreateInput({
    Name = "OmniChat Key", CurrentValue = "", PlaceholderText = "Paste your OMNI_ key here...", RemoveTextAfterFocusLost = false, Flag = "Input_APIKey",
    Callback = function(Text) 
        OmniKey = Text:match("^%s*(.-)%s*$") or Text
        if OmniKey == "" then return end
        Rayfield:Notify({Title = "Verifying...", Content = "Checking your key...", Duration = 2})
        local verify_url = string.gsub(API_URL, "/chat", "/verify")
        local success, response = pcall(function() return request_func({ Url = verify_url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ omni_key = OmniKey }) }) end)

        if success and response then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if decodeSuccess and data.success then
                PointsLabel:Set("💳 Current Points: " .. tostring(data.points))
                Rayfield:Notify({Title = "Connected!", Content = "Key valid. You have " .. tostring(data.points) .. " points.", Duration = 4})
            else
                Rayfield:Notify({Title = "Server says:", Content = tostring(data and data.error or "Unknown error"), Duration = 5})
            end
        end
    end,
})

MoreTab:CreateButton({ Name = "Official Discord Server", Callback = function() setclipboard("https://discord.gg/tonserveur") end })
MoreTab:CreateToggle({ Name = "Chat Bypass", CurrentValue = false, Flag = "Toggle_Bypass", Callback = function() end })
MoreTab:CreateToggle({ Name = "Anti Chat Logger", CurrentValue = true, Flag = "Toggle_AntiLog", Callback = function() end })
MoreTab:CreateButton({ Name = "Delete Saved AIs", Callback = function() end })

-- ==================== HELP TAB ====================
HelpTab:CreateParagraph({ Title = "How do I use OmniChat?", Content = "1. Get your key from our Discord Server.\n2. Go to the 'More' tab and paste your key.\n3. Go to 'Main' and toggle 'Running'." })
HelpTab:CreateParagraph({ Title = "How to use with a different Roblox account?", Content = "You can add multiple Roblox accounts to a single key! Go to the bot channel in Discord and type /addaccount with your Roblox username." })
HelpTab:CreateParagraph({ Title = "What are the points for?", Content = "The API is expensive. Each message costs points depending on the AI model you choose (5, 8, or 20 pts)." })
HelpTab:CreateParagraph({ Title = "How to get more points?", Content = "Use /claim in Discord every 24h, use /beg to ask other players." })

-- ==========================================
--      ROBLOX CHAT AUTO-REPLY LOGIC
-- ==========================================
local function SendRobloxChatMessage(message)
    if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
        local textChannel = game:GetService("TextChatService").TextChannels.RBXGeneral
        if textChannel then textChannel:SendAsync(message) end
    else
        local SayMessageRequest = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if SayMessageRequest and SayMessageRequest:FindFirstChild("SayMessageRequest") then
            SayMessageRequest.SayMessageRequest:FireServer(message, "All")
        end
    end
end

local function OnPlayerChatted(player, message)
    if not IsRunning or OmniKey == "" then return end
    if player == LocalPlayer then return end

    local isListed = table.find(TargetPlayers, player.Name) ~= nil
    if WhitelistMode and not isListed then return end 
    if not WhitelistMode and isListed then return end 

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and player.Character and player.Character:FindFirstChild("Head") then
        local distance = (LocalPlayer.Character.Head.Position - player.Character.Head.Position).Magnitude
        if distance > ListeningRange then return end
    else return end

    -- Nouveau Anti-Spam: Ne bloque pas aveuglément, met juste un cooldown de 3 secondes
    if AntiSpamEnabled then
        if tick() - LastMessageProcessedTime < 3 then return end
        LastMessageProcessedTime = tick()
    end

    if UseBuffer then task.wait(3) end

    local MemoryContext = #ChatHistory > 0 and (" Recent chat context: " .. table.concat(ChatHistory, " | ")) or ""
    local FinalSystemPrompt = SystemPrompt .. MemoryContext .. " Always reply in " .. SelectedLanguage .. ". You are talking to " .. player.Name .. ". Keep answer short for Roblox."
    if AutoRemindBot then FinalSystemPrompt = FinalSystemPrompt .. " Remind the user you are an AI ChatBot." end

    task.spawn(function()
        local success, response = pcall(function() return request_func({ Url = API_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ omni_key = OmniKey, system_prompt = FinalSystemPrompt, user_message = message }) }) end)

        if success and response then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if decodeSuccess and data.success then
                local rawAnswer = data.answer
                if string.len(rawAnswer) > MaxMessageLength then rawAnswer = string.sub(rawAnswer, 1, MaxMessageLength) .. "..." end
                
                table.insert(ChatHistory, player.Name .. ": " .. message .. " -> AI: " .. rawAnswer)
                if #ChatHistory > 3 then table.remove(ChatHistory, 1) end 

                PointsLabel:Set("💳 Current Points: " .. tostring(data.remaining_points))
                SendRobloxChatMessage(string.format(FormatString, rawAnswer))
            end
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do player.Chatted:Connect(function(msg) OnPlayerChatted(player, msg) end) end
Players.PlayerAdded:Connect(function(player) player.Chatted:Connect(function(msg) OnPlayerChatted(player, msg) end) end)

Rayfield:LoadConfiguration()
