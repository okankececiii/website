# IT Rehberi ikon oluşturucu
Add-Type -AssemblyName System.Drawing

function MakeIcon($size, $file) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'AntiAlias'

    # Arka plan gradient (koyu lacivert)
    $bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 6, 13, 26))
    $g.FillRectangle($bg, 0, 0, $size, $size)

    # Yuvarlak köşe için clip
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $r = [int]($size * 0.22)
    $path.AddArc(0, 0, $r*2, $r*2, 180, 90)
    $path.AddArc($size-$r*2, 0, $r*2, $r*2, 270, 90)
    $path.AddArc($size-$r*2, $size-$r*2, $r*2, $r*2, 0, 90)
    $path.AddArc(0, $size-$r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    $g.SetClip($path)
    $g.FillRectangle($bg, 0, 0, $size, $size)

    # Neon border
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 0, 212, 255), [int]($size*0.025))
    $g.DrawPath($pen, $path)

    # "IT" yazısı
    $fs = [int]($size * 0.38)
    $font = New-Object System.Drawing.Font("Courier New", $fs, [System.Drawing.FontStyle]::Bold)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 212, 255))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = 'Center'
    $sf.LineAlignment = 'Center'
    $rect = New-Object System.Drawing.RectangleF(0, 0, $size, $size)
    $g.DrawString("IT", $font, $brush, $rect, $sf)

    $g.Dispose()
    $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Oluşturuldu: $file"
}

$dir = Split-Path $MyInvocation.MyCommand.Path
MakeIcon 192 "$dir\icon-192.png"
MakeIcon 512 "$dir\icon-512.png"
Write-Host "İkonlar hazır!"
