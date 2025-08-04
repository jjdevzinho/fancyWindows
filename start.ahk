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
settings["focusBorder"] := true
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

    ; Gerencia borda de foco (apenas a normal)
    try {
        if (settings["focusBorder"]) {
            SetTimer(CheckFocusChange, 25)
        } else {
            SetTimer(CheckFocusChange, 0)
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

    ; Checkboxes para todos os scripts
    cb1 := myGui.Add("Checkbox", "x20 y50", "Borda de Foco")
    cb1.Value := settings["focusBorder"]

    cb2 := myGui.Add("Checkbox", "x20 y75", "Navegação por Zona")
    cb2.Value := settings["focusZone"]

    cb3 := myGui.Add("Checkbox", "x20 y100", "Alternar Mesma Zona")
    cb3.Value := settings["sameZone"]

    cb4 := myGui.Add("Checkbox", "x20 y125", "Alternar Mesmo App")
    cb4.Value := settings["sameApp"]

    cb5 := myGui.Add("Checkbox", "x20 y150", "Maximizar/Restaurar")
    cb5.Value := settings["maxRestore"]

    cb6 := myGui.Add("Checkbox", "x20 y175", "Maximizar/Minimizar")
    cb6.Value := settings["maxMin"]

    cb7 := myGui.Add("Checkbox", "x20 y200", "Fechar Janela")
    cb7.Value := settings["closeWin"]

    cb8 := myGui.Add("Checkbox", "x20 y225", "Centralizar Janela")
    cb8.Value := settings["centerWin"]

    ; Botões
    btnApply := myGui.Add("Button", "x20 y260 w80", "Aplicar")
    btnCancel := myGui.Add("Button", "x110 y260 w80", "Cancelar")
    btnReload := myGui.Add("Button", "x200 y260 w80", "Recarregar")

    ; Função para aplicar configurações
    ApplySettings(*) {
        ; Salva todas as configurações dos checkboxes
        settings["focusBorder"] := cb1.Value
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
    myGui.Show("w320 h300")
}

ReloadScript(*) {
    Reload()
}

ExitScript(*) {
    ExitApp()
}

; Inicialização silenciosa - sem notificações
