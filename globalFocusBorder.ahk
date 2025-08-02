#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Variáveis globais para o efeito
global borderGuis := []  ; Array para múltiplas bordas
global borderTimer := ""
global lastActiveWindow := 0
global borderColor := GetWindowsAccentColor()  ; Cor de destaque do Windows
global borderThickness := 2       ; Espessura da borda em pixels - mais fino

; Verifica mudanças de foco a cada 25ms
SetTimer(CheckFocusChange, 25)

; Função para obter a cor de destaque do Windows
GetWindowsAccentColor() {
    try {
        ; Lê a cor de destaque do registro do Windows
        accentColor := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\DWM", "AccentColor")

        ; Converte de ABGR para RGB (Windows usa formato diferente)
        ; AccentColor está em formato AABBGGRR, precisamos converter para 0xRRGGBB
        red := (accentColor & 0xFF)
        green := ((accentColor >> 8) & 0xFF)
        blue := ((accentColor >> 16) & 0xFF)

        ; Retorna no formato hexadecimal correto
        return Format("0x{:02X}{:02X}{:02X}", red, green, blue)
    } catch {
        ; Se falhar, usa uma cor padrão azul
        return "0x0078D4"  ; Azul padrão do Windows 11
    }
}

CheckFocusChange() {
    global lastActiveWindow, borderColor

    currentWindow := WinExist("A")

    ; Se mudou de janela E é uma janela "normal"
    if (currentWindow != lastActiveWindow && currentWindow != 0 && IsNormalWindow(currentWindow)) {
        ; Atualiza a cor de destaque (caso o usuário tenha mudado o tema)
        borderColor := GetWindowsAccentColor()

        ; Aplica o efeito de borda
        ApplyBorderEffect(currentWindow)
        lastActiveWindow := currentWindow
    }
}

; Função para verificar se é uma janela "comum" (não do sistema)
IsNormalWindow(window) {
    try {
        ; Obtém informações da janela
        windowTitle := WinGetTitle(window)
        windowClass := WinGetClass(window)
        style := WinGetStyle(window)
        exStyle := WinGetExStyle(window)

        ; Filtra janelas sem título
        if (windowTitle == "")
            return false

        ; Filtra classes do sistema conhecidas
        systemClasses := [
            "Shell_TrayWnd",           ; Taskbar
            "DV2ControlHost",          ; Alt+Tab
            "MultitaskingViewFrame",   ; Task View
            "Windows.UI.Core.CoreWindow", ; Sistema
            "ForegroundStaging",       ; Sistema
            "MSCTFIME UI",            ; IME
            "Default IME",            ; IME
            "CiceroUIWndFrame",       ; IME
            "TaskListThumbnailWnd",   ; Thumbnails da taskbar
            "ToolbarWindow32",        ; Toolbars
            "ReBarWindow32",          ; Toolbars
            "MSTaskSwWClass",         ; Alt+Tab
            "TaskSwitcherWnd",        ; Task Switcher
            "NotifyIconOverflowWindow", ; System tray overflow
            "Shell_SecondaryTrayWnd", ; Secondary taskbar
            "TrayNotifyWnd",          ; Notification area
            "SystemTrayIcon"          ; System tray icons
        ]

        ; Verifica se é uma classe do sistema
        for className in systemClasses {
            if (windowClass == className)
                return false
        }

        ; Filtra por títulos específicos do sistema
        systemTitles := [
            "Program Manager",
            "Task Switching",
            "Start",
            "Cortana",
            "Search",
            "Action center"
        ]

        for title in systemTitles {
            if (InStr(windowTitle, title))
                return false
        }

        ; Filtra janelas que não são visíveis ou são tool windows
        if (!(style & 0x10000000))  ; WS_VISIBLE
            return false

        if (exStyle & 0x00000080)   ; WS_EX_TOOLWINDOW
            return false

        ; Verifica se tem parent (janelas filhas normalmente não são principais)
        if (DllCall("GetParent", "Ptr", window))
            return false

        return true
    } catch {
        return false
    }
}

ApplyBorderEffect(window) {
    global borderGuis, borderTimer, borderColor, borderThickness

    ; Remove bordas anteriores se existirem
    if (borderTimer) {
        SetTimer(RemoveBorder, 0)
    }
    RemoveBorder()

    ; Cria as bordas ao redor da janela
    try {
        ; Usa a área cliente da janela para melhor precisão
        WinGetClientPos(&clientX, &clientY, &clientW, &clientH, window)
        WinGetPos(&winX, &winY, &winW, &winH, window)

        ; Ignora janelas muito pequenas
        if (clientW < 200 || clientH < 100)
            return

        ; Cria uma única GUI com borda arredondada usando região
        borderGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        borderGui.BackColor := borderColor
        borderGui.Opt("+E0x20")

        ; Posição e tamanho da borda externa
        outerX := clientX - borderThickness
        outerY := clientY - borderThickness
        outerW := clientW + (borderThickness * 2)
        outerH := clientH + (borderThickness * 2)

        ; Cria região externa arredondada
        outerRegion := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", outerW, "Int", outerH, "Int", 12, "Int",
            12)
        ; Cria região interna arredondada (buraco)
        innerRegion := DllCall("CreateRoundRectRgn", "Int", borderThickness, "Int", borderThickness, "Int", outerW -
            borderThickness, "Int", outerH - borderThickness, "Int", 8, "Int", 8)

        ; Combina as regiões (externa - interna = borda)
        DllCall("CombineRgn", "Ptr", outerRegion, "Ptr", outerRegion, "Ptr", innerRegion, "Int", 4) ; RGN_DIFF

        ; Aplica a região na janela
        DllCall("SetWindowRgn", "Ptr", borderGui.Hwnd, "Ptr", outerRegion, "Int", 1)

        ; Deleta a região interna (não mais necessária)
        DllCall("DeleteObject", "Ptr", innerRegion)

        borderGui.Show("x" outerX " y" outerY " w" outerW " h" outerH " NoActivate")
        WinSetTransparent(200, borderGui)

        borderGuis := [borderGui]

        ; Remove as bordas após 250ms
        borderTimer := SetTimer(RemoveBorder, -250)
    }
}

RemoveBorder() {
    global borderGuis, borderTimer

    ; Remove todas as bordas
    if (borderGuis && borderGuis.Length > 0) {
        for border in borderGuis {
            try {
                border.Destroy()
            }
        }
        borderGuis := []
    }
    borderTimer := ""
}
