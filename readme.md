# Ruby Site Mapper

This is a basic Ruby web crawler which hits one URL and returns a sitemap including static assets, in an HTML file. It does not do everything that a great crawler would do, but it does the basics pretty well. Because of this, I've listed the problems below.

# Run it

Run `ruby run.rb` to run it with the default start page, which is currently `https://gocardless.com`, just because. It also limits to 15 threads, max. This can be changed in `crawler.rb`. With these settings it should take about a minute to create a map of the GoCardless website, depending on your machine and your connection.

# Test it

You need [rspec](http://rspec.info/) for this, so install rspec using `gem install rspec` and then type `rspec` in the root. You should get no problems.

# What's good about it?

* It normalises URIs (to some degree - see below) so that `http://example.com/whatever/` and `http://example.com/whatever` are the same
* It doesn't re-scrape URIs when they've already been found
* It uses multi-threading and mutexes for extra speed and safety in that speed
* It uses Regular Expressions to find links and resources. Why?
    * We don't have to loop through and reject links because they don't fit the original domain, or because they are javascript/mailtos
    * Regular Expressions are fun
* It outputs results to an HTML file for your browsing pleasure

# What's wrong with it?

## Query strings

The Crawler does not group together two pages with different querystrings, and sometimes this can be confusing because they are actually the same.

For example, the following two URIs:

* `http://example.com/about-us.php?source=marketing-campaign-sept`
* `http://example.com/about-us.php?source=marketing-campaign-oct`

Anybody who looks at this domain would probably assume these are the same page/document, but there's a querystring on it which probably, when the page is it, is used for some analytics software. However, consider these two URIs:

* `http://example.com/article.php?id=24123`
* `http://example.com/article.php?id=15642`

These two pages/documents are definitely different, because they show two different articles. They should definitely be treated as different pages.

In summary, some normalisation solution needs to be figured out which turns the first two URIs into the same page, and the two others should be kept separate.

This problem can be solved by digging deeper into the content of the page. A good place to start would be to look for some kind of a permalink, or 'one version of the truth' URI which points the page, which might be defined in the meta data in the `<head>` tag of the page's source. Alternatively, we could go based on the assumption that no two pages will have the exact same `<title>` and use that, or for a very heavy-handed solution we could compare the content of the page to see if it's the same, or different.

## Hash fragments

This same problems as aboce happens for hash fragments. These days, it is very common practice for single-page web applications use URIs like http://example.com/page/#sub-page. Arguably, these pages can be very different depending on the hash fragment.

Before doing the solutions outlined above, we would need to have some way of executing JavaScript on the page we're scraping and then seeing what the result is, since hash fragments are often reacted to by some client-side JS code to load a different page.

So, it's a pretty tough problem and would require a headless browser like [PhantomJS](http://phantomjs.org/).

## Redirect Loops

* If the crawler comes across a redirect loop, openuri actually will detect it and blow up. The crawler simply reacts to this by going "not my problem!" and ignoring it - this should probably be handled differently.

## The results are hard to view

They are all output in a big ol' HTML file but it's kinda hard to browse it. I'd like to make it so you can click on a link that is available on a page and show more about that page. Maybe using in-page hash fragment links.

## It's probably a bit buggy

I threw it together pretty quickly in short bursts of 30mins-1hr over 3 days, goodness knows what dragons be lurking in there.

# Dependencies

* Ruby 2.0.0
* OpenURI

## If there's trouble with openuri ssl

You probably are using RVM, and RVM doesn't get the proper certificate for SSL. See this:

http://stackoverflow.com/questions/10728436/opensslsslsslerror-ssl-connect-returned-1-errno-0-state-sslv3-read-server-c