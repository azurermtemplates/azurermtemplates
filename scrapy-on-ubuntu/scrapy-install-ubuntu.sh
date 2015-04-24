# Install updates
sudo apt-get -y update

#Install Scrapy
sudo apt-get install -y python-setuptools
easy_install pip
pip install scrapy
cat > myspider.py <<EOF

from scrapy import Spider, Item, Field

class Post(Item):
    title = Field()

class BlogSpider(Spider):
    name, start_urls = 'blogspider', ['http://blog.scrapinghub.com']

    def parse(self, response):
        return [Post(title=e.extract()) for e in response.css("h2 a::text")]

EOF
scrapy runspider myspider.py
