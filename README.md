## Fixer API proxy service

Build a microservice for fetching and caching data from an external API (www.fixer.io).

## Currency development report job

Build a small application that runs every evening, after the markets close and creates a report on currency development.
 
## How it works:

* fixer-proxy proxies requests to fixer.io
* fixer-reporting creates report on currecy development
* usage: `cd fixer-reporting && ruby app.rb usd rub etc`
* it outputs result csv file path to stdout

## Proxy service is connected as a submodule 

from here: https://github.com/dmitry-matveyev/fixer-proxy/

