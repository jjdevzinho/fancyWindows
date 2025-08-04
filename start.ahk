#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Configuração do system tray (ícone de janelas em cascata)
TraySetIcon("shell32.dll", 47)
A_TrayMenu.Delete()
A_TrayMenu.Add("Configurações", ShowSettings)
A_TrayMenu.Add("")
A_TrayMenu.Add("Recarregar", ReloadScript)
A_TrayMenu.Add("Sair", ExitScript)

; Estados dos scripts (carregados do arquivo INI)
global settings := Map()
settings["focusBorderType"] := "none"  ; "none", "normal", "fixed", "flash"
settings["focusZone"] := true
settings["sameZone"] := true
settings["sameApp"] := true
settings["maxRestore"] := true
settings["maxMin"] := true
settings["closeWin"] := true
settings["centerWin"] := true

; Carrega configurações salvas
LoadSettings()

; Carrega todos os módulos (necessário devido às limitações do AutoHotkey)
#Include globalFocusBorder.ahk
#Include globalFocusBorderFixed.ahk
#Include globalFocusHighlight.ahk
#Include focusZone.ahk
#Include toggleWindowSameZone.ahk
#Include toggleWindowSameApp.ahk
#Include maxRestoreWindow.ahk
#Include maxMinWindow.ahk
#Include closeWindow.ahk
#Include centeredWindow.ahk

; Desabilita hotkeys baseado nas configurações após o carregamento
SetTimer(ApplyHotkeySettings, -100) ; Executa uma vez após 100ms

LoadSettings() {
    global settings
    iniFile := A_ScriptDir "\fancyWindows.ini"

    if (FileExist(iniFile)) {
        for key, value in settings {
            ; Lê como string e converte para boolean
            settingValue := IniRead(iniFile, "Scripts", key, value ? "1" : "0")
            settings[key] := (settingValue = "1" || settingValue = "true")
        }
    }
}

SaveSettings() {
    global settings
    iniFile := A_ScriptDir "\fancyWindows.ini"

    for key, value in settings {
        IniWrite(value ? "1" : "0", iniFile, "Scripts", key)
    }
}

; Aplica configurações de hotkeys (única função para gerenciar tudo)
ApplyHotkeySettings() {
    global settings

    ; Gerencia hotkeys de navegação por zona
    try {
        if (settings["focusZone"]) {
            Hotkey("#+Right", "On")
            Hotkey("#+Left", "On")
            Hotkey("#+Up", "On")
            Hotkey("#+Down", "On")
        } else {
            Hotkey("#+Right", "Off")
            Hotkey("#+Left", "Off")
            Hotkey("#+Up", "Off")
            Hotkey("#+Down", "Off")
        }
    }

    ; Gerencia maximizar/restaurar
    try {
        if (settings["maxRestore"]) {
            Hotkey("#+Enter", "On")
        } else {
            Hotkey("#+Enter", "Off")
        }
    }

    ; Gerencia maximizar/minimizar
    try {
        if (settings["maxMin"]) {
            Hotkey("#+PgUp", "On")
            Hotkey("#+PgDn", "On")
        } else {
            Hotkey("#+PgUp", "Off")
            Hotkey("#+PgDn", "Off")
        }
    }

    ; Gerencia fechar janela
    try {
        if (settings["closeWin"]) {
            Hotkey("#q", "On")
        } else {
            Hotkey("#q", "Off")
        }
    }

    ; Gerencia centralizar janela
    try {
        if (settings["centerWin"]) {
            Hotkey("#Enter", "On")
        } else {
            Hotkey("#Enter", "Off")
        }
    }

    ; Gerencia alternar mesma zona
    try {
        if (settings["sameZone"]) {
            Hotkey("$!``", "On")
            Hotkey("~LAlt Up", "On")
        } else {
            Hotkey("$!``", "Off")
            Hotkey("~LAlt Up", "Off")
        }
    }

    ; Gerencia alternar mesmo app
    try {
        if (settings["sameApp"]) {
            Hotkey("$#``", "On")
            Hotkey("~LWin Up", "On")
            Hotkey("~RWin Up", "On")
        } else {
            Hotkey("$#``", "Off")
            Hotkey("~LWin Up", "Off")
            Hotkey("~RWin Up", "Off")
        }
    }

    ; Gerencia borda de foco (diferentes tipos com funções renomeadas)
    try {
        ; Para todos os timers de borda primeiro
        SetTimer(CheckFocusChange, 0)        ; Borda normal
        SetTimer(CheckFocusChangeFixed, 0)   ; Borda fixa
        SetTimer(CheckFocusChangeFlash, 0)   ; Piscar janela

        ; Ativa apenas o tipo selecionado
        switch settings["focusBorderType"] {
            case "normal":
                SetTimer(CheckFocusChange, 25)
            case "fixed":
                SetTimer(CheckFocusChangeFixed, 100)
            case "flash":
                SetTimer(CheckFocusChangeFlash, 100)
                ; case "none" não faz nada - todos os timers já foram parados
        }
    }
}

ShowSettings(*) {
    global settings

    myGui := Gui("+Resize", "FancyWindows - Configurações")
    myGui.SetFont("s10")
    myGui.BackColor := "White"

    ; Título
    myGui.Add("Text", "x10 y10 w300 Center", "Configurações do FancyWindows").SetFont("s12 Bold")
    myGui.Add("Text", "x10 y35 w300 h2 0x10")

    ; Grupo de bordas de foco (Radio buttons)
    myGui.Add("Text", "x20 y50", "Tipo de Foco:").SetFont("s9 Bold")
    rb1 := myGui.Add("Radio", "x30 y70", "Nenhum")
    rb2 := myGui.Add("Radio", "x30 y90", "Picar Borda")
    rb3 := myGui.Add("Radio", "x30 y110", "Fixa Borda")
    rb4 := myGui.Add("Radio", "x30 y130", "Piscar Janela")

    ; Define o radio button selecionado baseado na configuração
    switch settings["focusBorderType"] {
        case "none":
            rb1.Value := 1
        case "normal":
            rb2.Value := 1
        case "fixed":
            rb3.Value := 1
        case "flash":
            rb4.Value := 1
        default:
            rb1.Value := 1  ; Padrão para "none"
    }

    ; Checkboxes para outros scripts
    cb2 := myGui.Add("Checkbox", "x20 y160", "Navegação por Zona")
    cb2.Value := settings["focusZone"]

    cb3 := myGui.Add("Checkbox", "x20 y185", "Alternar Mesma Zona")
    cb3.Value := settings["sameZone"]

    cb4 := myGui.Add("Checkbox", "x20 y210", "Alternar Mesmo App")
    cb4.Value := settings["sameApp"]

    cb5 := myGui.Add("Checkbox", "x20 y235", "Maximizar/Restaurar")
    cb5.Value := settings["maxRestore"]

    cb6 := myGui.Add("Checkbox", "x20 y260", "Maximizar/Minimizar")
    cb6.Value := settings["maxMin"]

    cb7 := myGui.Add("Checkbox", "x20 y285", "Fechar Janela")
    cb7.Value := settings["closeWin"]

    cb8 := myGui.Add("Checkbox", "x20 y310", "Centralizar Janela")
    cb8.Value := settings["centerWin"]

    ; Botões
    btnApply := myGui.Add("Button", "x20 y345 w80", "Aplicar")
    btnCancel := myGui.Add("Button", "x110 y345 w80", "Cancelar")
    btnReload := myGui.Add("Button", "x200 y345 w80", "Recarregar")

    ; Função para aplicar configurações
    ApplySettings(*) {
        ; Determina o tipo de borda baseado nos radio buttons
        if (rb1.Value)
            settings["focusBorderType"] := "none"
        else if (rb2.Value)
            settings["focusBorderType"] := "normal"
        else if (rb3.Value)
            settings["focusBorderType"] := "fixed"
        else if (rb4.Value)
            settings["focusBorderType"] := "flash"

        ; Salva as outras configurações
        settings["focusZone"] := cb2.Value
        settings["sameZone"] := cb3.Value
        settings["sameApp"] := cb4.Value
        settings["maxRestore"] := cb5.Value
        settings["maxMin"] := cb6.Value
        settings["closeWin"] := cb7.Value
        settings["centerWin"] := cb8.Value

        SaveSettings()
        myGui.Destroy()

        ; Aplica as mudanças imediatamente sem recarregar
        ApplyHotkeySettings()

        ; Mostra mensagem de confirmação (sem ícone)
        TrayTip("Configurações aplicadas com sucesso!", "FancyWindows")
    }

    ; Função para recarregar da GUI
    ReloadFromGUI(*) {
        myGui.Destroy()
        Reload()
    }

    ; Eventos dos botões
    btnApply.OnEvent("Click", ApplySettings)
    btnCancel.OnEvent("Click", (*) => myGui.Destroy())
    btnReload.OnEvent("Click", ReloadFromGUI)

    ; Mostra a GUI
    myGui.Show("w320 h385")
}

ReloadScript(*) {
    Reload()
}

ExitScript(*) {
    ExitApp()
}

; Inicialização silenciosa - sem notificações
