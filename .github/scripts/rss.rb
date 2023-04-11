require 'rss'
require 'octokit'

# Scrape blog posts from the website
url = "https://confusedbit.dev/index.xml"

# Generate the updated blog posts list (top 5)
posts_list = ["\n### Latest posts\n\n[//]: # \"Everything after this will be obliterated\"\n\n"]
URI.open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  feed.items.first(5).each do |item|
    posts_list << "* [#{item.title}](#{item.link}) (#{item.date.strftime("%Y/%m/%d")})"
  end
end

# Update the README.md file
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
repo = ENV['GITHUB_REPOSITORY']
readme = client.readme(repo)
readme_content = Base64.decode64(readme[:content]).force_encoding('UTF-8')

# Replace the existing blog posts section
posts_regex = /### Latest posts\n\n[\s\S]*?(?=<\/td>)/m
updated_content = readme_content.sub(posts_regex, "#{posts_list.join("\n")}\n")

client.update_contents(repo, 'README.md', 'Update latest blog posts', readme[:sha], updated_content)
