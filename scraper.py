from lxml import html
from lxml.cssselect import CSSSelector
import requests
import os
import math

dirname = "profiles"

if not os.path.exists(dirname):
    os.makedirs(dirname)
counter = 0

payload = {'search_school': '0',
    'search_year': '0',
    'search_age': '0',
    'search_ethnicity': '0',
    'search_state': '0',
    'search_areaofstudy': '0',
    'psr': '0', } # page number
page = requests.get("http://mdapplicants.com/search.php", params=payload)
tree = html.fromstring(page.text)
# 'Your search generated 14512 results.' <- this # is an estimate sometimes, use while loop
text = tree.cssselect('div#content>p')[0].text
numResults = int(text[22:text.index('results')-1])
print('total results ', numResults)
# 50
table = tree.cssselect('table.results>tbody tr')
numResultsPerPage = len(table)
# 0 indexing for psr (page numbers)
numPages = int(math.ceil(float(numResults/float(numResultsPerPage))))

# for pageNumber in range(0, numPages):

pageNumber = 0
while True:

    payload['psr'] = pageNumber
    page = requests.get("http://mdapplicants.com/search.php", params=payload)
    tree = html.fromstring(page.text)

    # results
    print('page number ', pageNumber)
    pageNumber = pageNumber + 1
    table = tree.cssselect('table.results>tbody tr')

    # exit while loop, no more results
    if len(table) == 0:
        break

    for row in table:
        # print(etree.tostring(element, pretty_print=True))
        profileUrl = row[0][0].get('href')
        # "profile.php?id=22709&"
        profileId = profileUrl[profileUrl.index("=")+1:profileUrl.index("&")]
        profilePage = requests.get("http://mdapplicants.com/profile.php", params={'id': profileId})

        htmlFile = open(dirname + "/" + str(counter) + ".html", "w")
        htmlFile.write(profilePage.text.encode('utf-8'))
        htmlFile.close()

        print('counter ', counter)
        counter = counter + 1
