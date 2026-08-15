#Requires AutoHotkey v2.0

; --- DIRECTORY SELECTION ---
; Option A: The folder containing this script
TargetDir := A_ScriptDir

; Option B: The PARENT folder of where this script is located (uncomment line below if needed)
; SplitPath(A_ScriptDir, , &TargetDir)


; --- DATE & COMMAND SETUP ---
; Formats current date (e.g., 2026Aug15)
DateStr := FormatTime(, "yyyyMMMdd")
CommitMsg := "updated in " . DateStr

; Combined Git command chain
GitCmd := 'git fetch origin && git pull && git add . && git commit -m "' CommitMsg '" && git push'


; --- CREATE GUI TERMINAL WINDOW ---
LogGui := Gui("+Resize", "Git Auto-Sync Log")
LogGui.SetFont("s10", "Consolas")
LogGui.BackColor := "0x1E1E1E" ; Dark background

; Terminal output box
LogBox := LogGui.Add("Edit", "r22 w680 ReadOnly Multi -E0x200")
LogBox.SetFont("c0xD4D4D4")   ; Light text

LogGui.OnEvent("Close", (*) => ExitApp())
LogGui.Show()


; --- EXECUTE COMMANDS ---
RunGitSequence(TargetDir, GitCmd, LogBox)


; --- FUNCTIONS ---
RunGitSequence(dir, cmd, logControl) {
    Dashes := "------------------------------------------------------------"

    AppendLog(logControl, "=== Starting Git Sync ===")
    AppendLog(logControl, "Folder:  " . dir)
    AppendLog(logControl, "Command: " . cmd . "`n" . Dashes . "`n")

    shell := ComObject("WScript.Shell")
    ; 2>&1 redirects standard errors to standard output so all messages show in the GUI
    exec := shell.Exec(A_ComSpec ' /c "cd /d "' dir '" && ' cmd ' 2>&1"')

    ; Stream terminal output in real time
    while !exec.Status {
        if !exec.StdOut.AtEndOfStream {
            text := exec.StdOut.Read(200)
            AppendLog(logControl, text, false)
        }
        Sleep(50)
    }

    ; Read any remaining text after execution finishes
    if !exec.StdOut.AtEndOfStream {
        AppendLog(logControl, exec.StdOut.ReadAll(), false)
    }

    AppendLog(logControl, "`n" . Dashes)
    AppendLog(logControl, "=== Process Completed (Exit Code: " . exec.ExitCode . ") ===")
}

AppendLog(control, text, addNewline := true) {
    control.Value .= text . (addNewline ? "`n" : "")
    ; Auto-scroll to the bottom of the Edit box (WM_VSCROLL = 0x0115, SB_BOTTOM = 7)
    SendMessage(0x0115, 7, 0, control)
}