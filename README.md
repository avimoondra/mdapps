# mdapps
scraper for http://mdapplicants.com/

## scraper.py
Web scraper for http://mdapplicants.com/. To run, create a virtual environment and run "pip install lxml cssselect requests" in that environment. Then run "python scraper.py"

Python 2.7.6

## parser.rb

Parses the html documents downloaded by scraper.py (see generated 'profiles' folder). Install nokogiri gem by running "gem install nokogiri". Then run "ruby parser.rb"

ruby 1.9.3p484
