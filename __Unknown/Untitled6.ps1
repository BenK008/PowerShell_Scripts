$mess = "Ben has a happy noodle"
$key = "abc"
$break = ".{"+$key.Length+"}" # RegEx ex. '.{3}' that specified characters in a string
$String = $mess -replace "$break" , "$&|"
$String
$stringArray = $String.Split("|")
$stringArray