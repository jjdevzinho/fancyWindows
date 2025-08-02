#Requires AutoHotkey v2.0+

; Variáveis globais para armazenar a última janela minimizada
lastMinimizedWindow := 0
lastMinimizedTime := 0

#+PgUp:: { ; Win + Shift + Seta para cima
    global lastMinimizedWindow, lastMinimizedTime ; Declaração global
    if WinExist("A") {
        ; Verifica se existe uma janela recentemente minimizada (nos últimos 1750ms)
        if (lastMinimizedWindow && A_TickCount - lastMinimizedTime < 1750) {
            WinRestore("ahk_id " lastMinimizedWindow)
            lastMinimizedWindow := 0 ; Limpa a referência
            return
        }
        WinMaximize("A")
    } else {
        TrayTip("Erro", "Nenhuma janela ativa encontrada.", 5)
    }
}

#+PgDn:: { ; Win + Shift + Seta para baixo
    global lastMinimizedWindow, lastMinimizedTime ; Declaração global
    if WinExist("A") {
        currentWindow := WinGetID("A")
        winState := WinGetMinMax("A")

        ; Pega todas as janelas visíveis e não minimizadas
        windowList := []
        for hwnd in WinGetList() {
            if (hwnd != currentWindow && WinGetStyle(hwnd) & 0x10000000 && !WinGetMinMax(hwnd)) { ; WS_VISIBLE
                windowList.Push(hwnd)
            }
        }

        if (winState == 1) { ; Se estiver maximizada
            WinRestore("A") ; Apenas restaura
        } else { ; Se não estiver maximizada
            ; Salva referência da janela que será minimizada
            lastMinimizedWindow := currentWindow
            lastMinimizedTime := A_TickCount

            ; Primeiro ativa próxima janela, depois minimiza a atual
            if windowList.Length > 0 {
                WinActivate("ahk_id " windowList[1])
                Sleep(50) ; Pequena pausa para garantir a ativação
            }
            WinMinimize("ahk_id " currentWindow)
        }
    } else {
        TrayTip("Erro", "Nenhuma janela ativa encontrada.", 5)
    }
}