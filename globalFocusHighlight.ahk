#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Variáveis globais para o efeito
global highlightGui := ""
global highlightTimer := ""
global lastActiveWindow := 0

; Verifica mudanças de foco a cada 100ms
SetTimer(CheckFocusChange, 100)

CheckFocusChange() {
    global lastActiveWindow

    currentWindow := WinExist("A")

    ; Se mudou de janela E é uma janela "normal"
    if (currentWindow != lastActiveWindow && currentWindow != 0 && IsNormalWindow(currentWindow)) {
        ; Aplica o efeito de piscar
        ApplyFlashEffect(currentWindow)
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

ApplyFlashEffect(window) {
    global highlightGui, highlightTimer

    ; Remove efeito anterior se existir
    if (highlightTimer) {
        SetTimer(RemoveHighlight, 0)
    }
    if (highlightGui) {
        try {
            highlightGui.Destroy()
        }
        highlightGui := ""
    }

    ; Cria o overlay preto
    try {
        WinGetPos(&x, &y, &w, &h, window)

        ; Ignora janelas muito pequenas
        if (w < 200 || h < 100)
            return

        highlightGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        highlightGui.BackColor := "0x000000"
        highlightGui.Opt("+E0x20")
        highlightGui.Show("x" x " y" y " w" w " h" h " NoActivate")
        WinSetTransparent(128, highlightGui)

        ; Remove após 250ms
        highlightTimer := SetTimer(RemoveHighlight, -250)
    }
}

RemoveHighlight() {
    global highlightGui, highlightTimer
    if (highlightGui) {
        try {
            highlightGui.Destroy()
        }
        highlightGui := ""
    }
    highlightTimer := ""
}
