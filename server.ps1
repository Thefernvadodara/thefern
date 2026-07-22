$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:3000/')
$listener.Start()
Write-Host "Server running at http://localhost:3000"
Write-Host "Press Ctrl+C to stop"

$root = 'C:\Users\hardik.rangani\Downloads\fern-website'

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    $path = $request.Url.LocalPath
    if ($path -eq '/') { $path = '/index.html' }
    $filePath = Join-Path $root ($path.TrimStart('/'))
    if (Test-Path $filePath) {
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = switch($ext) {
            '.html' {'text/html; charset=utf-8'}
            '.css'  {'text/css'}
            '.js'   {'application/javascript'}
            '.png'  {'image/png'}
            '.jpg'  {'image/jpeg'}
            '.pdf'  {'application/pdf'}
            default {'application/octet-stream'}
        }
        $response.ContentType = $mime
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
        $bytes = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $response.OutputStream.Close()
}
