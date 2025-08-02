#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Variáveis globais para o efeito
global borderGuis := []  ; Array para múltiplas bordas
global borderTimer := ""
global lastActiveWindow := 0
global borderColor := GetWindowsAccentColor()  ; Cor de destaque do Windows
global borderThickness := 2       ; Espessura da borda em pixels - mais fino
global currentBorderWindow := 0    ; Janela que tem borda ativa no momento

; Verifica mudanças de foco a cada 100ms
SetTimer(CheckFocusChange, 100)

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
    global lastActiveWindow, borderColor, currentBorderWindow

    currentWindow := WinExist("A")

    ; Se mudou de janela E é uma janela "normal"
    if (currentWindow != lastActiveWindow && currentWindow != 0 && IsNormalWindow(currentWindow)) {
        ; Atualiza a cor de destaque (caso o usuário tenha mudado o tema)
        borderColor := GetWindowsAccentColor()

        ; Remove borda da janela anterior (se existir)
        if (currentBorderWindow != 0 && currentBorderWindow != currentWindow) {
            RemoveBorder()
        }

        ; Aplica borda permanente na nova janela ativa
        ApplyPermanentBorder(currentWindow)
        lastActiveWindow := currentWindow
        currentBorderWindow := currentWindow
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

ApplyPermanentBorder(window) {
    global borderGuis, borderTimer, borderColor, borderThickness

    ; Remove bordas anteriores se existirem
    RemoveBorder()

    ; Cria a borda permanente ao redor da janela
    try {
        ; Obtém tanto a área cliente quanto a área total da janela
        WinGetClientPos(&clientX, &clientY, &clientW, &clientH, window)
        WinGetPos(&winX, &winY, &winW, &winH, window)

        ; Verifica o título da janela para aplicações conhecidas problemáticas
        windowTitle := WinGetTitle(window)
        windowClass := WinGetClass(window)

        ; Lista de aplicações que devem usar sempre a área total
        problematicApps := ["HeidiSQL", "phpMyAdmin", "MySQL", "Workbench"]
        useFullWindow := false

        for appName in problematicApps {
            if (InStr(windowTitle, appName) || InStr(windowClass, appName)) {
                useFullWindow := true
                break
            }
        }

        ; Verifica se a área cliente parece estar muito deslocada ou pequena
        clientOffsetX := clientX - winX
        clientOffsetY := clientY - winY

        ; Se é app problemático OU área cliente está muito deslocada/pequena, usa área total
        if (useFullWindow || clientOffsetX > 50 || clientOffsetY > 100 || clientW < (winW * 0.7) || clientH < (winH *
            0.7)) {
            ; Usa a área total da janela
            finalX := winX
            finalY := winY
            finalW := winW
            finalH := winH
        } else {
            ; Usa a área cliente (comportamento normal)
            finalX := clientX
            finalY := clientY
            finalW := clientW
            finalH := clientH
        }

        ; Ignora janelas muito pequenas
        if (finalW < 200 || finalH < 100)
            return

        ; Cria uma única GUI com borda arredondada usando região
        borderGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        borderGui.BackColor := borderColor
        borderGui.Opt("+E0x20")

        ; Posição e tamanho da borda externa
        outerX := finalX - borderThickness
        outerY := finalY - borderThickness
        outerW := finalW + (borderThickness * 2)
        outerH := finalH + (borderThickness * 2)

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
        WinSetTransparent(180, borderGui)  ; Transparência um pouco maior para borda permanente

        borderGuis := [borderGui]

        ; NÃO define timer - borda fica permanente até mudança de foco
    }
}

RemoveBorder() {
    global borderGuis, borderTimer, currentBorderWindow

    ; Remove todas as bordas
    if (borderGuis && borderGuis.Length > 0) {
        for border in borderGuis {
            try {
                border.Destroy()
            }
        }
        borderGuis := []
    }

    ; Limpa o timer se existir
    if (borderTimer) {
        SetTimer(borderTimer, 0)
        borderTimer := ""
    }

    ; Reset da janela com borda ativa
    currentBorderWindow := 0
}
