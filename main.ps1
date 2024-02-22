$ErrorActionPreference = "SilentlyContinue"
class Question {
    [int]$id
    [string]$type = 'default' # Default = text answer; code = answer generated by a scriptblock; TODO: Add type setup where the preliminery would be the setup and the answer would be predefined.
    [string]$prompt
    [scriptblock]$preliminary = $null
    [object]$answer 
    [string]$hint = "There is no hint for this question, try harder!"

    Question([int]$id, [string]$type, [string]$prompt, [scriptblock]$preliminary, [object]$answer) {
        $this.id = $id
        $this.type = $type
        $this.prompt = $prompt
        $this.preliminary = $preliminary
        $this.answer = $answer
    }

        Question([int]$id, [string]$type, [string]$prompt, [scriptblock]$preliminary, [object]$answer, [string]$hint) {
        $this.id = $id
        $this.type = $type
        $this.prompt = $prompt
        $this.preliminary = $preliminary
        $this.answer = $answer
        $this.hint = $hint
    }

    [bool]CheckAnswer([string]$userInput) {
        try {
            if ($this.Type -eq 'code') {
                $preliminaryOutput = & $this.preliminary
                $this.answer = $preliminaryOutput.ToString().Trim()
            } 

        } catch {
            Write-Host "Error executing preliminary code. Please check the question setup."
        }
        
        if ($this.answer -eq "")
        {
            write-host "Error in getting answer for Question $($this.id)"
            $this.answer = "ERROR | Error getting the result for this question, please skip it"
            return $false
        }

        return $userInput.trim() -eq $this.answer.ToString().Trim()
    }
}

function Convert-ToBase64 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text
    )
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $base64 = [Convert]::ToBase64String($bytes)
    return $base64
}

function Convert-FromBase64 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Base64
    )
    $bytes = [Convert]::FromBase64String($Base64)
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    return $text
}

### consts

$intro_text = '
Hello! Welcome to the ''Powershell Zero to Hero'' game!
The name is pretty indicative so without further ado, some instructions:

1. The basic structure of a Powershell command resembles a CMD command structure of <Command> [-Parameters [Parameters'' Value]] [| <Another Command>]
For instance - Get-Process -Name "chrome" | Stop-Process

2. The goal of this game is to answer all the questions one by one. When you answer correctly, you advance to the next question. 

3. From now on, you should prefer Powershell over CMD, old habits die hard but between us, you know it''s time. 
If for some reason you would still prefer to use CMD commands in this exercise, mostly in the first questions, you might struggle more with more advanced questions as they rely on information learned from previous questions.

4. As the game continues, try to keep a record of your answers for each question in case you accidentally exit the terminal.

5. The questions are tailored to the system that runs the program. A good approach would be to create a Powershell ISE session on the same machine that runs this program, then press Ctrl+R to be able to run scripts and even debug quickly. You might need to set the Execution Policy to Bypass to be able to run scripts.

6. In case you struggle with a question, especially the first ones, there are some hints to guide you. 
If you are experiencing technical difficulties as a result that I tried to not spend too much time on creating this game then don''t waste your time and let me know.

Hope you enjoy!
'

$sort_hashtable = '$hashtable = @{
    "g7S" = "G"
    "t7H" = "e"
    "m5M" = "l"
    "v3F" = "o"
    "e1U" = "T"
    "i6Q" = "u"
    "q4J" = "s"
    "97Z" = "g"
    "w5E" = "P"
    "j3P" = "o"
    "_4a" = "u"
    "d2V" = "o"
    "s6I" = "r"
    "w8D" = "e"
    "l9N" = "l"
    "k2O" = "Y"
    "*6c" = "g"
    "p1K" = "h"
    "h0R" = "r"
    "f4T" = "o"
    "c8W" = "L"
    "!5d" = "e"
    "b9X" = "a"
    "a3Y" = "n"
    "n8L" = "e"
    "u0G" = "w"
    "z1A" = "M"
    "xwB" = "a"
    "xtC" = "k"
    "@1b" = "a"
}'

$iis_logs = 'IP_Address Remote_Logname Remote_User Date Request Status_Code Response_Size Referrer User_Agent
127.0.0.1 - - [10/Oct/2023:13:55:36 +0000] "GET /index.html HTTP/1.1" 200 532 "http://example.com/start.html" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
127.0.0.1 - - [10/Oct/2023:13:55:37 +0000] "POST /form_submit.php HTTP/1.1" 404 182 "http://example.com/form.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:38 +0000] "GET /missing-page.html HTTP/1.1" 404 123 "http://example.com/missing.html" "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.78 Mobile Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:39 +0000] "GET /products/list HTTP/1.1" 200 975 "http://example.com/products.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15"
127.0.0.1 - - [10/Oct/2023:13:55:40 +0000] "PUT /api/user/12345 HTTP/1.1" 201 702 "http://example.com/api/documentation" "curl/7.64.1"
127.0.0.1 - - [10/Oct/2023:13:55:41 +0000] "DELETE /api/post/67890 HTTP/1.1" 403 415 "http://example.com/api/documentation" "PostmanRuntime/7.26.8"
127.0.0.1 - - [10/Oct/2023:13:55:42 +0000] "GET /news/latest-news.html HTTP/1.1" 303 1578 "http://example.com/news.html" "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"
127.0.0.1 - - [10/Oct/2023:13:55:43 +0000] "GET /images/logo.png HTTP/1.1" 304 0 "http://example.com/index.html" "Mozilla/5.0 (iPhone; CPU iPhone OS 13_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.2 Mobile/15E148 Safari/604.1"
127.0.0.1 - - [10/Oct/2023:13:55:44 +0000] "POST /contact/form HTTP/1.1" 302 0 "http://example.com/contact.html" "Mozilla/5.0 (iPad; CPU OS 14_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"
127.0.0.1 - - [10/Oct/2023:13:55:45 +0000] "GET /services.html HTTP/1.1" 401 745 "http://example.com/login.html" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:46 +0000] "GET /dashboard HTTP/1.1" 302 0 "http://example.com/home.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:47 +0000] "GET /css/style.css HTTP/1.1" 304 1024 "http://example.com/index.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:48 +0000] "GET /js/app.js HTTP/1.1" 206 587 "http://example.com/index.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.80 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:49 +0000] "GET /about-us HTTP/1.1" 404 234 "http://example.com/about.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:81.0) Gecko/20100101 Firefox/81.0"
127.0.0.1 - - [10/Oct/2023:13:55:50 +0000] "GET /favicon.ico HTTP/1.1" 302 1430 "http://example.com" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:51 +0000] "GET /profile/settings HTTP/1.1" 403 512 "http://example.com/profile.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:52 +0000] "POST /api/login HTTP/1.1" 204 760 "http://example.com/api/documentation" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:55:53 +0000] "GET /search?q=powershell HTTP/1.1" 303 1250 "http://example.com/search.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15"
127.0.0.1 - - [10/Oct/2023:13:55:54 +0000] "GET /api/data?filter=recent HTTP/1.1" 500 642 "http://example.com/api/documentation" "PostmanRuntime/7.26.10"
127.0.0.1 - - [10/Oct/2023:13:55:55 +0000] "GET /blog/2023/powershell-tips HTTP/1.1" 200 1875 "http://example.com/blog.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:56 +0000] "POST /webhook/receive HTTP/1.1" 202 340 "http://example.com/webhooks.html" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:55:57 +0000] "GET /events HTTP/1.1" 418 1283 "http://example.com/events.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:58 +0000] "GET /privacy-policy HTTP/1.1" 301 0 "http://example.com/privacy.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.193 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:59 +0000] "GET /terms-and-conditions HTTP/1.1" 200 1548 "http://example.com/terms.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:00 +0000] "GET /sitemap.xml HTTP/1.1" 201 958 "http://example.com/robots.txt" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
127.0.0.1 - - [10/Oct/2023:13:56:01 +0000] "POST /api/items/new HTTP/1.1" 302 200 "http://example.com/api/guide" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:56:02 +0000] "GET /api/items/12345 HTTP/1.1" 404 98 "http://example.com/api/items" "PostmanRuntime/7.26.5"
127.0.0.1 - - [10/Oct/2023:13:56:03 +0000] "PUT /api/items/12345/update HTTP/1.1" 204 0 "http://example.com/api/items" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:56:04 +0000] "DELETE /api/items/12345 HTTP/1.1" 403 178 "http://example.com/api/items" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:56:05 +0000] "GET /archive/2023/ HTTP/1.1" 304 3420 "http://example.com/archive.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:06 +0000] "GET /help/faq HTTP/1.1" 303 2160 "http://example.com/help.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:07 +0000] "GET /assets/img/header.jpg HTTP/1.1" 304 0 "http://example.com/index.html" "Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.2 Mobile/15E148 Safari/604.1"
127.0.0.1 - - [10/Oct/2023:13:56:08 +0000] "GET /video/tutorials/intro.mp4 HTTP/1.1" 206 524288 "http://example.com/videos.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:09 +0000] "GET /articles/powershell-advantages HTTP/1.1" 200 1032 "http://example.com/articles.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:10 +0000] "GET /download/powershell-script.ps1 HTTP/1.1" 304 480 "http://example.com/downloads.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:49 +0000] "GET /about-us HTTP/1.1" 404 234 "http://example.com/about.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:81.0) Gecko/20100101 Firefox/81.0"
127.0.0.1 - - [10/Oct/2023:13:55:50 +0000] "GET /favicon.ico HTTP/1.1" 200 1430 "http://example.com" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:51 +0000] "GET /profile/settings HTTP/1.1" 403 512 "http://example.com/profile.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:52 +0000] "POST /api/login HTTP/1.1" 304 760 "http://example.com/api/documentation" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:55:53 +0000] "GET /search?q=powershell HTTP/1.1" 200 1250 "http://example.com/search.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15"
127.0.0.1 - - [10/Oct/2023:13:55:54 +0000] "GET /api/data?filter=recent HTTP/1.1" 500 642 "http://example.com/api/documentation" "PostmanRuntime/7.26.10"
127.0.0.1 - - [10/Oct/2023:13:55:55 +0000] "GET /blog/2023/powershell-tips HTTP/1.1" 303 200 "http://example.com/blog.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:56 +0000] "POST /webhook/receive HTTP/1.1" 202 340 "http://example.com/webhooks.html" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:55:57 +0000] "GET /events HTTP/1.1" 418 1283 "http://example.com/events.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:58 +0000] "GET /privacy-policy HTTP/1.1" 301 0 "http://example.com/privacy.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.193 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:55:59 +0000] "GET /terms-and-conditions HTTP/1.1" 303 200 "http://example.com/terms.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:00 +0000] "GET /sitemap.xml HTTP/1.1" 404 958 "http://example.com/robots.txt" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
127.0.0.1 - - [10/Oct/2023:13:56:01 +0000] "POST /api/items/new HTTP/1.1" 302 174 "http://example.com/api/guide" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:56:02 +0000] "GET /api/items/12345 HTTP/1.1" 404 98 "http://example.com/api/items" "PostmanRuntime/7.26.5"
127.0.0.1 - - [10/Oct/2023:13:56:03 +0000] "PUT /api/items/12345/update HTTP/1.1" 204 0 "http://example.com/api/items" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:56:04 +0000] "DELETE /api/items/12345 HTTP/1.1" 500 178 "http://example.com/api/items" "curl/7.68.0"
127.0.0.1 - - [10/Oct/2023:13:56:05 +0000] "GET /archive/2023/ HTTP/1.1" 303 3420 "http://example.com/archive.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:06 +0000] "GET /help/faq HTTP/1.1" 403 2160 "http://example.com/help.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:07 +0000] "GET /assets/img/header.jpg HTTP/1.1" 304 200 "http://example.com/index.html" "Mozilla/5.0 (iPhone; CPU iPhone OS 13_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.2 Mobile/15E148 Safari/604.1"
127.0.0.1 - - [10/Oct/2023:13:56:08 +0000] "GET /video/tutorials/intro.mp4 HTTP/1.1" 403 524288 "http://example.com/videos.html" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:09 +0000] "GET /articles/powershell-advantages HTTP/1.1" 200 1032 "http://example.com/articles.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
127.0.0.1 - - [10/Oct/2023:13:56:10 +0000] "GET /download/powershell-script.ps1 HTTP/1.1" 303 480 "http://example.com/downloads.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36"
'
$reg_key = "HKCU:\Powershell0toH"
$reg_keys = @{
    "k1XeR2L" = "o3n4roo6o8ooX9oXZoY2oYoWoVoUToSoRoQoPoNoMoLoKoJoIoHoGoF1L3M5K7N" 
    "Y2uT4oP" = "bC5DoFoHoJoLoNoP8ooqoToVoXoZoo1o3o5o7o9XbXdXfXhXjXlXnXpXrXtXvXxXzX1" 
    "p3Lk9QW" = "oX2CoEo0oIoKoMoOoQoS6UoWoYo1o3o5o7oo9XobXdXfXhXjXlXnXp0rXotXvXxXzX2o" 
    "ZxP5To2" = "XCoEoGoIoKoMoOoQoS6UooWoYo1o3o5o7o9XbX0XofXhX00lXnXpXrXtoXvXxXzX2o4R" 
    "N6yU8Ik" = "oX2o4o6o8XaXcXeXgXiXk00XoXqXsXuXwXyX1X3X5X7X9YoZbYdYfYhYjYlYnYoYqYr" 
    "W3R5T7Y" = "oX2o4o6o8XaXcXeXgXiXkXmXooXqXsXuXwXyX1X3X5X7X9YoZbYdYfYhYjYlYnYoYqYs" 
    "o8P0L4K" = "X2X4Xot096X8YaYcYeoooooooooooY103Yo5Y7Y9ZaZcZeZoooomZoZqooZsZuZw" 
    "Q1F3H5J" = "oXoZoYoWoVoUoToSoRoQoPoNoMoLoKoJoIoHoGoFooDoBo9o7o5o3o1XZXYXXWVUTSR" 
    "L9K8J7H" = "GFEoCoAo8o6o4o2o0XZXVXUXSoXRXPXoooIXGXEXCoXAX9Xo7X5X3Xo1ZWYWUWTSWRV" 
    "M1N2B3V" = "oXoZoYoWooVoUoToSoRoQoPoNoMoLoKoJoIoHoGoFoDoBo9o7o5o3o1XZXYXXWVUTSo" 
    "C4X5C6V" = "BNAoMoQoSoUooWoYo1o3o5o7o9XbXdXfXhXjXlXnXpXrXotXvXxXozX1X3X5X7X9YaYcYe" 
    "Z7X8C9V" = "oXoZoYoWoVoUoToSoRoQoPoNoMoLoKoJ00oHoGoFoDooBo9o7o5o3o1XZXYXXWVUTSR" 
    "B5N4M3L" = "KJIH0oEoCoAo8o6o4o2o0oXZXVXUXSXRXPXNXLXKXIXGXEXCXAX9X7X5X3X1ZWYWUWT" 
    "Q2W3E4R" = "TYXoVoToRoPoNoLoJoHoGoFoDoBoAo8o6o4o2o0X0XVXUXSXRXPXNXLXKXIXGXEXC" 
    "T5Y6U7I" = "oXZXYWoVoUoToSoRoQoPoNoMoLoKoJoIoHoGoFoDooBoAo9X7X5X3X1ZoWYWUWTSWRVQ" 
    "O9P0A4S" = "oXoZoYoWoVoUoToSoRo0oPoNoMoLoKoJoIoHooGoFoDoBo9o7o5o3o1XZoXoXWVUTSR" 
    "D7F8G9H" = "oJIoHoGoFoDoBoAo8o6oo4o2o0XZXVXUXSXRXPXNXLXKXIXGXoEXCXAX9X7X5X3X1ZWX" 
    "J1K2L3Z" = "oXoZoYoWoVoUoToSoRoQoPoNoMoLoKoJoIoHoGoFoDoBo9oo7o5o3o1XZXYXXWVUTSR" 
    "X3C4V5B" = "oNoMoLoKoJoIoHoGo00DoBoAo8o6oo4o2o0XZXVXUoXSXRXPXNXLXKXI0GXEXCXooAX9X7" 
    }

### Questions

$questions = @(
    [Question]::new(0, 'code', 'What is the version of the command "get-member"?', { $(get-command "get-member").Version.ToString() }, ""),
    [Question]::new(1, 'default', 'What is ''MemberType'' of the ''CommandType'' member in the output of the command ''Get-Command Invoke-Expression''?', $null, "Property"),
    [Question]::new(2, 'default', 'What is the cmdlet behind the alias of the command "ls"', $null, 'get-childitem'),
    [Question]::new(3, 'code', 'How many aliases does Get-ChildItem has?', {$(Get-Alias -Definition Get-ChildItem).count}, ''),
    [Question]::new(4, 'code', 'What is the ModuleName of the command "get-member"', {get-command get-member | Select-Object -ExpandProperty ModuleName}, ''),
    [Question]::new(5, 'code', 'How many available commands in your machine has "Microsoft.PowerShell.Utility" as ther ModuleName?', { $(Get-command | Where-Object{$_.ModuleName -eq "Microsoft.PowerShell.Utility"}).Count }, ""),
    [Question]::new(6, 'default', 'What is the type of the output to the command "Get-Help cat" ', $null , 'PSCustomObject'), #{ $(get-help cat ).gettype().name }
    [Question]::new(7, 'code', 'What is the 77th char of the output to the command "Get-Help cat -full" ', { $(get-help cat -full | out-string)[77] }, ''),
    [Question]::new(8, 'code', 'What is the SHA1 has of "C:\Windows\notepad.exe"? ', { Get-FileHash  "C:\windows\notepad.exe" -Algorithm SHA1 | select-object -ExpandProperty Hash }, ''),
    [Question]::new(9, 'code', 'What is the character length of the Issuer''s distinguished name who Issued the certificate for "C:\Windows\notepad.exe"? ', { $(Get-AuthenticodeSignature C:\windows\notepad.exe).SignerCertificate.Issuer.trim().Length }, '', "Did you look within the SignerCertificate?"),
    [Question]::new(10, 'code', 'What is the path name (commandline) of the service with the display name of Windows Update?', { Get-WmiObject win32_service | Where-Object{$_.name -eq "wuauserv"} | Select-Object -ExpandProperty PathName }, '', "WMI is the real deal"),
    [Question]::new(11, 'code', 'What is the creation date of the process lsass.exe? Format: YYYYMMDDHHmmSS.sss ', { $date = Get-WmiObject win32_process | Where-Object {$_.name -eq "lsass.exe"} | Select-Object -ExpandProperty CreationDate | out-string; $dotPosition = $date.IndexOf('.'); return $date.Substring(0,$dotPosition+ 4)}, '', "WMI is the real deal. Here is an example for an answer '20240131102618.284'"),
    [Question]::new(12, 'default', "Copy and paste this hashtable to your own terminal, find the hidden message:`n$sort_hashtable", $null , 'MakePowershellYourGoToLanguage'), # ($hashtable.GetEnumerator() | Sort-Object Name -Descending).Value -join ''
[Question]::new(13, 'default', 'My name is Omri, and I love vowels. If you''d remove all other characters from this very question, you will get your answer!', $null, 'aeiOiaIoeoeIoueoeaoeaaeoieueioouieouae', "Either Regex or '-replace' would do the trick!"), #-replace '[^aeiouAEIOU]', ''
[Question]::new(14, 'code', 'What is the alphabetically first property in your registry''s Run key (Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run)?', { $($(Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run).Property | Sort-Object)[0] }, '')
[Question]::new(15, 'setup', 'Check out the IIS log file in C:\Users\Public\iis.log. Go over the logs and find the most common Status Code (use Foreach-Object and regex)', { if (-not (Test-Path "C:\Users\Public\iis.log")) {Out-File -FilePath "C:\Users\Public\iis.log" -Encoding utf8 -Force -InputObject $iis_logs} }, '303') 
<#
$codes = @() # It is super not efficient to use @() for adding elements to an array since arrays have fixed sizes, it's better to use dynamic objects. But it's just simple for this use case. Read more here - https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.4#array-addition
$niis_logs | %{ #after splitting by lines and removing first line
$_ -match '".*?"\s{1,2}(\d+)\s' | Out-Null
$codes += $Matches[1]
}
$($code | Group-Object | Sort-Object -Descending Count).Name[0]
#>
[Question]::new(16, 'setup', 'Look at the registry key ''HKEY_CURRENT_USER\Powershell0toH''. What is the property with the most ''o''s?', { if( -not (Test-Path ($reg_key))) {new-item  $reg_key; foreach ($key in $reg_keys.Keys){  New-ItemProperty -Path $reg_key -Name $key -Value $reg_keys[$key] -PropertyType String}} }, 'O9P0A4S')
)

function Cleanup
{
    # Question15
    Remove-Item "C:\Users\Public\iis.log" -Force

    # Question16
    Remove-Item -Path $reg_key -Recurse -Force


}

function Start-TutorialGame {
    $currentIndex = 0
    $answersStatus = @{}

    Write-Host $intro_text -foregroundColor Cyan

      do {
        $currentQuestion = $questions[$currentIndex]
        
        try {
            if ($currentQuestion.type -eq 'setup')
            {
                & $currentQuestion.preliminary
            }
        }
        catch {
            Write-Host "Error executing setup for question $($currentQuestion.id), continuing to the next question" -ForegroundColor Red
            Write-Host $_.Exception.Message
            continue
        }

        Write-Host "Question #$($currentQuestion.id):`n$($currentQuestion.prompt)" -foregroundColor Cyan
        $userInput = Read-Host "Your answer (type 'skip' to skip/'hint' for a hint/'cleanup' to remove setup for all questions)"

        if ($userInput -eq 'PowershellGod') {
            $password = Read-Host -AsSecureString "What is the password" 
            $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
            $InsecureString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            if ($InsecureString -eq "shlomo")
            {
                $num = Read-Host "How many questions do you want to reveal? (ID of last question + 1)"
                if ($num -eq "all")
                {$num = $questions.Count}
                for ($i =0;$i -lt $num; $i++) {
                    $q = $questions[$i]
                    if ($q.type -eq 'code') {
                        # Execute the preliminary scriptblock to get the answer
                        try {
                            $preliminaryOutput = & $q.preliminary
                            $q.answer = $preliminaryOutput.ToString().Trim()
                        } catch {
                            Write-Host "Error executing code for question $($q.id)" -ForegroundColor Red
                            continue
                        }
                }
                    Write-Host "Question $($q.id): $($q.prompt)`nAnswer   $($q.id): $($q.answer)" -ForegroundColor Green
            }
            # break # Exit the loop after revealing all answers
            }
            elseif ($InsecureString -eq "skipto")
            {
                [int] $currentindex = Read-Host "What is the question number you want to skip to?"
            }
 
        }
        elseif ($userInput -eq 'cleanup') {
            Write-Host "Clean up on aisle 5, removing setup for all questions." -ForegroundColor Yellow
            Cleanup
        }
        elseif ($userInput -eq 'skip') {
            Write-Host "Question skipped." -ForegroundColor Yellow
            $answersStatus[$currentQuestion.id] = 'Skipped'
            $currentIndex++
        } elseif ($userInput -eq "hint")
        {
            # Write-Host "Are you sure you want a hint? [yes/no]" -ForegroundColor Yellow
            Write-Host "The hint is:`n'$($currentQuestion.hint)'" -ForegroundColor Yellow
        }
        elseif ($currentQuestion.CheckAnswer($userInput)) {
            $answersStatus[$currentQuestion.id] = 'Correct'
            $currentIndex++
            Write-Host "Correct! Next is question number $currentIndex!" -ForegroundColor Green
        } else {
            if ($currentQuestion.answer -match "^ERROR \|")
            {
                Write-Host -ForegroundColor Orange $currentQuestion.answer
                $answersStatus[$currentQuestion.id] = 'Error'
            }
            else 
            {
            Write-Host "Incorrect. Please try again or type 'skip' to skip or 'hint' for a hint." -ForegroundColor Red
            $answersStatus[$currentQuestion.id] = 'Incorrect'
            }
        }
    } while ($currentIndex -lt $questions.Length)

    Write-Host "Tutorial completed. Review your answers:" -ForegroundColor Green
    $answersStatus.GetEnumerator() | ForEach-Object { Write-Host "Question $($_.Key): $($_.Value)" }

    Write-host "Done.. Cleaning up..."
    Cleanup
}


# Start the game
Start-TutorialGame
