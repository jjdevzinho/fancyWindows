#Requires AutoHotkey v2.0+

#+Enter:: {
    if WinExist("A") { ; Verifica se há uma janela ativa
        winState := WinGetMinMax("A")
        if (winState == 0) {
            WinMaximize("A")
        } else {
            WinRestore("A")
        }
    } else {
        TrayTip("Erro", "Nenhuma janela ativa encontrada.", 5)
    }
}
