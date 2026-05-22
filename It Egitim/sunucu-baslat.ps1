# IT Rehberi — Yerel Sunucu
# Aynı Wi-Fi'deki telefon ve tabletlerden erişim sağlar

$port = 8080
$dir  = Split-Path $MyInvocation.MyCommand.Path

# PC'nin yerel IP adresini bul
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.IPAddress -notmatch '^127\.' -and $_.PrefixOrigin -ne 'WellKnown' } |
       Select-Object -First 1).IPAddress

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://+:$port/")

try {
    $listener.Start()
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   IT Egitim Rehberi — Sunucu Aktif" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Bilgisayarda : " -NoNewline
    Write-Host "http://localhost:$port" -ForegroundColor Yellow
    Write-Host "  Telefon/Tablet: " -NoNewline
    Write-Host "http://${ip}:$port" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Telefonda bu adresi tarayiciya yazin!" -ForegroundColor Green
    Write-Host "  Durdurmak icin Ctrl+C" -ForegroundColor Gray
    Write-Host ""

    $mimeTypes = @{
        '.html' = 'text/html; charset=utf-8'
        '.json' = 'application/json'
        '.js'   = 'application/javascript'
        '.png'  = 'image/png'
        '.ico'  = 'image/x-icon'
        '.css'  = 'text/css'
    }

    while ($listener.IsListening) {
        $ctx  = $listener.GetContext()
        $req  = $ctx.Request
        $resp = $ctx.Response

        $path = $req.Url.LocalPath -replace '/', '\'
        if ($path -eq '\') { $path = '\IT-Egitim-Rehberi.html' }
        $file = Join-Path $dir $path.TrimStart('\')

        if (Test-Path $file -PathType Leaf) {
            $ext  = [System.IO.Path]::GetExtension($file)
            $mime = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { 'application/octet-stream' }
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $resp.ContentType   = $mime
            $resp.ContentLength64 = $bytes.Length
            $resp.OutputStream.Write($bytes, 0, $bytes.Length)
            Write-Host "  GET $($req.Url.LocalPath)" -ForegroundColor DarkGray
        } else {
            $resp.StatusCode = 404
        }
        $resp.OutputStream.Close()
    }
} catch {
    if ($_.Exception.Message -notmatch 'cannot be bound') {
        Write-Host "Hata: $($_.Exception.Message)" -ForegroundColor Red
    }
} finally {
    $listener.Stop()
    Write-Host "Sunucu durduruldu." -ForegroundColor Gray
}
