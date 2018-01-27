﻿# Main Assemblies
[void][System.Reflection.Assembly]::LoadWithPartialname("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$m = New-Object System.Windows.Forms.Form
$m.ClientSize = New-Object System.Drawing.Size(1065, 800)
$m.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
$m.Text = "Who Wants to be a Millionaire - PowerShell Edition"
Function ConvertJPG($picture) {
    [byte[]]$Pic = gc $picture -Encoding Byte
    [system.convert]::ToBase64String($Pic)}
ConvertJPG .\Profile.PNG > Profile.txt
$Background = "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
"
$m.Image = ([System.Drawing.Image]([System.Drawing.Image]::FromStream((New-Object System.IO.MemoryStream(($$ = System.Convert]::FromBase64String($Background)),0,$$.Length)))))