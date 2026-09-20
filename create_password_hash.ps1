# Genera clave específica para HMAC-SHA256 (32 bytes recomendados)
$hmacKey = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($hmacKey)
[Convert]::ToBase64String($hmacKey)