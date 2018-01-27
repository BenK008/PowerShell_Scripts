$string = "MIICXAIBAAKBgQDFDxrLz/lBabo/JrRvKN47IRzUgm/LzG9zbn3g8HMnPIpy4ZOFfhjblvb8iNeFMbUIDAT2QmsqDRJhHH7xUVfC6DiYB3YuKJC/RBIHzqlBsxWXI5DFikyS3yT6ThQap3JZEKE7fVXHHJmea4VrsRVhWG6ztoPYf+OfiMyzj0IV3QIDAQABAoGAX1QnSmGZ2yMijlpS/1Nt7nzeTY+sNZL4d4cELkUj799BusGVdAbET7aAVTp9yFl7kiD+ZYNMBFO+iGwYnPUU1sPSlFcS1YNu2S+4ds2ym1VfZu2drTN5qUIGIm222mgyOG1CSx421Ns4X5qIexkQ1gOnqaBuD7Mi3D19c5mK66ECQQDlt99Jcw7Jh1GdTMy8cQ7EBI82YPedRP5SnAv0/sCIgcsBmbABO6WwCeS1BVjoicf+pPmIy3YkyiyO8JIa9GJLAkEA25qwREClnm+2qIBRLal+pG8t7xZlEya+HrlX3ogThf/9GybfImzKZQagbom3sDmRTeu6PhDhu4XZS7D4gfIPdwJANlDrsupJrM0aNx9ZqZTx8NdDJZB3+++8Urwi96Lk02IdJhu4yhHYc29jbIn/I7ywVT2c4wN4w+op7wJjCYyPUQJAaVEoU7NFOlSNHwZa6DEvQSDowI7W7nZYG1f74gcUheEcu5bK0DGoZwbkjd6SL3uMSfhRG07xUwOAEKLQq1ExRQJBAJouci7CVIbd8XqZEBaBAqIEVKCff+qHsHzoZo1ryog8vIgevI9e/01CqyuKIRs9WmM+DU/QnZtLJHUqgkpSCag="

#$string = "QnZtLJHUqgkpSCag="

$utf8 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string))
$uni = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($string))
$ascii = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($string))

