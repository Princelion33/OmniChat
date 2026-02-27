-- ==========================================
--        OMNICHAT HUB - INTERFACE & API
-- ==========================================

-- L'URL de ton API Node.js
local API_URL = "http://us1.airanode.cloud:25765/api/chat"

local HttpService = game:GetService("HttpService")
local request_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

if not request_func then
    warn("Ton exécuteur ne supporte pas les requêtes HTTP !")
end

-- Variables globales pour le fonctionnement
local OmniKey = ""
local IsRunning = false
local SelectedModel = "Meta-Llama-3.1-8B-Instruct (Default | 5 points)"
local SystemPrompt = "You are a helpful assistant."
local FormatString = "[ChatBot] %s"

-- Variables des paramètres
local BlacklistedPlayers = {}
local WhitelistMode = false
local ListeningRange = 50
local MaxMessageLength = 150
local AntiSpamEnabled = true
local UseBuffer = false
local AutoRemindBot = true
local SelectedLanguage = "English"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "OmniChat Hub 🤖",
    Icon = 0, 
    LoadingTitle = "OmniChat Interface",
    LoadingSubtitle = "Connected to Node.js",
    ShowText = "OmniChat",
    Theme = "Default", 
    ToggleUIKeybind = "K", 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "OmniChatConfig",
       FileName = "OmniChatSave"
    },
    Discord = { Enabled = false },
    KeySystem = false 
})

-- ==========================================
--                 TABS
-- ==========================================
local MainTab = Window:CreateTab("Main", "home")
local AITab = Window:CreateTab("AI Settings", "cpu")
local PremiumTab = Window:CreateTab("Premium", "star")
local ChatTab = Window:CreateTab("Chat", "message-square")
local MoreTab = Window:CreateTab("More", "plus-circle")
local HelpTab = Window:CreateTab("Help", "help-circle")

-- ==========================================
--             TAB 1 : MAIN
-- ==========================================
local PointsLabel = MainTab:CreateLabel("💳 Current Points: ?", "coins", Color3.fromRGB(255, 215, 0), false)

MainTab:CreateToggle({
    Name = "Running",
    CurrentValue = false,
    Flag = "Toggle_Running",
    Callback = function(Value)
        IsRunning = Value
    end,
})

MainTab:CreateDivider()

local Drop_Blacklist -- Déclaration pour pouvoir l'utiliser dans l'input

MainTab:CreateInput({
    Name = "Blacklist a player",
    CurrentValue = "",
    PlaceholderText = "Enter exact username...",
    RemoveTextAfterFocusLost = true,
    Flag = "Input_Blacklist",
    Callback = function(Text)
        if Text ~= "" then
            table.insert(BlacklistedPlayers, Text)
            if Drop_Blacklist then
                Drop_Blacklist:Refresh(BlacklistedPlayers)
            end
            Rayfield:Notify({Title = "Blacklisted", Content = Text .. " has been blacklisted.", Duration = 3})
        end
    end,
})

Drop_Blacklist = MainTab:CreateDropdown({
    Name = "Blacklisted Players",
    Options = {"None"},
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "Drop_Blacklist",
    Callback = function(Options) end,
})

MainTab:CreateButton({
    Name = "Reset Blacklist",
    Callback = function()
        BlacklistedPlayers = {}
        Drop_Blacklist:Refresh({"None"})
        Rayfield:Notify({Title = "Reset", Content = "Blacklist has been cleared.", Duration = 3})
    end,
})

MainTab:CreateDivider()

MainTab:CreateToggle({
    Name = "Whitelist Mode",
    CurrentValue = false,
    Flag = "Toggle_Whitelist",
    Callback = function(Value)
        WhitelistMode = Value
    end,
})

MainTab:CreateSlider({
    Name = "Listening Range (Studs)",
    Range = {10, 200},
    Increment = 10,
    Suffix = "Studs",
    CurrentValue = 50,
    Flag = "Slider_Range",
    Callback = function(Value)
        ListeningRange = Value
    end,
})

MainTab:CreateSlider({
    Name = "Max Message Length",
    Range = {10, 300},
    Increment = 10,
    Suffix = "Chars",
    CurrentValue = 150,
    Flag = "Slider_Length",
    Callback = function(Value)
        MaxMessageLength = Value
    end,
})

MainTab:CreateToggle({
    Name = "Anti Spam",
    CurrentValue = true,
    Flag = "Toggle_AntiSpam",
    Callback = function(Value)
        AntiSpamEnabled = Value
    end,
})

MainTab:CreateToggle({
    Name = "Buffer (Add 3 sec delay)",
    CurrentValue = false,
    Flag = "Toggle_Buffer",
    Callback = function(Value)
        UseBuffer = Value
    end,
})

MainTab:CreateButton({
    Name = "Reset AI Memory",
    Callback = function()
        Rayfield:Notify({Title = "Memory Cleared", Content = "The AI forgot the previous conversation.", Duration = 3})
    end,
})

MainTab:CreateInput({
    Name = "Chatbot Message Formatting",
    CurrentValue = "[ChatBot] %s",
    PlaceholderText = "[ChatBot] %s",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_Format",
    Callback = function(Text)
        FormatString = Text
    end,
})

MainTab:CreateToggle({
    Name = "Auto remind you're a chatbot",
    CurrentValue = true,
    Flag = "Toggle_RemindBot",
    Callback = function(Value)
        AutoRemindBot = Value
    end,
})

-- ==========================================
--             TAB 2 : AI SETTINGS
-- ==========================================
AITab:CreateDropdown({
    Name = "Select the character of your AI",
    Options = {"Normal", "Aggressive", "Friendly", "Sarcastic", "UwU"},
    CurrentOption = {"Normal"},
    MultipleOptions = false,
    Flag = "Drop_Character",
    Callback = function(Options) 
        local char = Options[1]
        SystemPrompt = "You are a " .. char .. " assistant."
    end,
})

AITab:CreateDropdown({
    Name = "Select AI Model",
    Options = {
        "Meta-Llama-3.1-8B-Instruct (Default | 5 points)"
    },
    CurrentOption = {"Meta-Llama-3.1-8B-Instruct (Default | 5 points)"},
    MultipleOptions = false,
    Flag = "Drop_Model",
    Callback = function(Options) 
        SelectedModel = Options[1]
    end,
})

AITab:CreateDropdown({
    Name = "Language",
    Options = {"English", "French", "Spanish", "German"},
    CurrentOption = {"English"},
    MultipleOptions = false,
    Flag = "Drop_Language",
    Callback = function(Options)
        SelectedLanguage = Options[1]
    end,
})

-- ==========================================
--             TAB 3 : PREMIUM
-- ==========================================
PremiumTab:CreateLabel("❌ Premium is not activated", "x-octagon", Color3.fromRGB(255, 50, 50), false)

PremiumTab:CreateToggle({ Name = "Text to Action Mode (Costs 1.5x points)", CurrentValue = false, Flag = "Toggle_TextAction", Callback = function(Value) end })
PremiumTab:CreateToggle({ Name = "Auto Moving", CurrentValue = false, Flag = "Toggle_AutoMove", Callback = function(Value) end })
PremiumTab:CreateDivider()
PremiumTab:CreateToggle({ Name = "Enable Custom Prompt", CurrentValue = false, Flag = "Toggle_CustomPrompt", Callback = function(Value) end })
PremiumTab:CreateInput({ Name = "Enter custom prompt here", CurrentValue = "", PlaceholderText = "Act as a...", RemoveTextAfterFocusLost = false, Flag = "Input_Prompt", Callback = function(Text) end })
PremiumTab:CreateParagraph({ Title = "Current Custom Prompt", Content = "Just be a normal ai" })
PremiumTab:CreateDivider()
PremiumTab:CreateDropdown({ Name = "Custom AIs", Options = {"None"}, CurrentOption = {"None"}, MultipleOptions = false, Flag = "Drop_CustomAIs", Callback = function(Options) end })
PremiumTab:CreateInput({ Name = "Save custom prompt with name:", CurrentValue = "", PlaceholderText = "Name your AI...", RemoveTextAfterFocusLost = true, Flag = "Input_SavePrompt", Callback = function(Text) end })

-- ==========================================
--             TAB 4 : CHAT
-- ==========================================
local AIAnswerParagraph = ChatTab:CreateParagraph({
    Title = "AI's Answer", 
    Content = "Waiting for a message..."
})

ChatTab:CreateButton({
    Name = "Clear Chat",
    Callback = function() 
        AIAnswerParagraph:Set({Title = "AI's Answer", Content = "Waiting for a message..."})
    end,
})

local LastAIResponse = ""

ChatTab:CreateButton({
    Name = "Copy the answer",
    Callback = function()
        if LastAIResponse ~= "" then
            setclipboard(LastAIResponse)
            Rayfield:Notify({Title = "Copied!", Content = "Answer copied to clipboard.", Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "Nothing to copy yet!", Duration = 3})
        end
    end,
})

ChatTab:CreateInput({
    Name = "Message",
    CurrentValue = "",
    PlaceholderText = "Talk to the AI directly here...",
    RemoveTextAfterFocusLost = true,
    Flag = "Input_ManualMessage",
    Callback = function(Text) 
        if not IsRunning then
            Rayfield:Notify({Title = "Error", Content = "You must enable 'Running' in the Main tab!", Duration = 3})
            return
        end
        if OmniKey == "" then
            Rayfield:Notify({Title = "Error", Content = "Please enter your OmniChat Key in the More tab.", Duration = 4})
            return
        end

        -- LOGIQUE DU PARAMÉTRAGE :
        if string.len(Text) > MaxMessageLength then
            Rayfield:Notify({Title = "Message trop long", Content = "La limite est de " .. tostring(MaxMessageLength) .. " caractères.", Duration = 4})
            return
        end

        AIAnswerParagraph:Set({Title = "AI's Answer", Content = "⏳ Thinking..."})

        -- Logique du Buffer (Délai)
        if UseBuffer then
            task.wait(3)
        end

        -- On force l'IA à utiliser la langue choisie
        local FinalSystemPrompt = SystemPrompt .. " Always reply in " .. SelectedLanguage .. "."
        if AutoRemindBot then
            FinalSystemPrompt = FinalSystemPrompt .. " Remind the user you are an AI ChatBot."
        end

        local payload = {
            omni_key = OmniKey,
            model = SelectedModel,
            system_prompt = FinalSystemPrompt,
            user_message = Text
        }

        local success, response = pcall(function()
            return request_func({
                Url = API_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)

        if success and response then
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)

            if decodeSuccess then
                if data.success then
                    local rawAnswer = data.answer
                    LastAIResponse = rawAnswer
                    
                    local finalMessage = string.format(FormatString, rawAnswer)
                    AIAnswerParagraph:Set({Title = "AI's Answer", Content = finalMessage})
                    PointsLabel:Set("💳 Current Points: " .. tostring(data.remaining_points))
                else
                    AIAnswerParagraph:Set({Title = "❌ API Error", Content = tostring(data.error)})
                    Rayfield:Notify({Title = "API Error", Content = tostring(data.error), Duration = 5})
                end
            else
                warn("Erreur serveur (Pas du JSON) :", response.Body)
                AIAnswerParagraph:Set({Title = "❌ Server Error", Content = "The API did not return valid JSON."})
            end
        else
            AIAnswerParagraph:Set({Title = "❌ Connection Error", Content = "Could not connect to the API."})
        end
    end,
})

-- ==========================================
--             TAB 5 : MORE
-- ==========================================
MoreTab:CreateInput({
    Name = "OmniChat Key",
    CurrentValue = "",
    PlaceholderText = "Paste your OMNI_ key here...",
    RemoveTextAfterFocusLost = false,
    Flag = "Input_APIKey",
    Callback = function(Text) 
        OmniKey = Text:match("^%s*(.-)%s*$") or Text
        if OmniKey == "" then return end

        Rayfield:Notify({Title = "Verifying...", Content = "Checking your key...", Duration = 2})

        local verify_url = string.gsub(API_URL, "/chat", "/verify")

        local success, response = pcall(function()
            return request_func({
                Url = verify_url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ omni_key = OmniKey })
            })
        end)

        if success and response then
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)

            if decodeSuccess then
                if data.success then
                    PointsLabel:Set("💳 Current Points: " .. tostring(data.points))
                    Rayfield:Notify({Title = "Connected!", Content = "Key valid. You have " .. tostring(data.points) .. " points.", Duration = 4})
                else
                    Rayfield:Notify({Title = "Server says:", Content = tostring(data.error), Duration = 5})
                end
            else
                warn("Erreur API (Pas du JSON) :", response.Body)
                Rayfield:Notify({Title = "API Error", Content = "Erreur serveur, regarde la console (F9).", Duration = 6})
            end
        else
            Rayfield:Notify({Title = "Connection Error", Content = "Impossible de joindre le serveur.", Duration = 4})
        end
    end,
})

MoreTab:CreateButton({ Name = "Official Discord Server", Callback = function() setclipboard("https://discord.gg/tonserveur"); Rayfield:Notify({Title = "Discord", Content = "Link copied to clipboard!", Duration = 3}) end })
MoreTab:CreateToggle({ Name = "Chat Bypass", CurrentValue = false, Flag = "Toggle_Bypass", Callback = function(Value) end })
MoreTab:CreateToggle({ Name = "Anti Chat Logger", CurrentValue = true, Flag = "Toggle_AntiLog", Callback = function(Value) end })
MoreTab:CreateButton({ Name = "Delete Saved AIs", Callback = function() end })

-- ==========================================
--             TAB 6 : HELP
-- ==========================================
HelpTab:CreateParagraph({ Title = "How do I use OmniChat?", Content = "1. Get your key from our Discord Server.\n2. Go to the 'More' tab and paste your key.\n3. Go to 'Main' and toggle 'Running'." })
HelpTab:CreateParagraph({ Title = "How to use with a different Roblox account?", Content = "You can add multiple Roblox accounts to a single key! Go to the bot channel in Discord and type /addaccount with your Roblox username." })
HelpTab:CreateParagraph({ Title = "What are the points for?", Content = "The API is expensive. Each message costs points depending on the AI model you choose (5, 8, or 20 pts)." })
HelpTab:CreateParagraph({ Title = "How to get more points?", Content = "Use /claim in Discord every 24h, use /beg to ask other players, or buy premium packages via tickets." })
HelpTab:CreateParagraph({ Title = "I forgot my key!", Content = "Use the /remind command in the Discord bot channel to get it back in DM." })

Rayfield:LoadConfiguration()
