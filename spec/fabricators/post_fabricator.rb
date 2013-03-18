Fabricator(:post) do
  user
  topic {|attrs| Fabricate(:topic, user: attrs[:user] ) }
  raw "Hello world"
end

Fabricator(:post_with_youtube, from: :post) do
  cooked '<a href="http://www.youtube.com/watch?v=9bZkp7q19f0" class="onebox" target="_blank">http://www.youtube.com/watch?v=9bZkp7q19f0</a>'
end

Fabricator(:old_post, from: :post) do
  topic {|attrs| Fabricate(:topic, user: attrs[:user], created_at: (DateTime.now - 100) ) }
  created_at (DateTime.now - 100)
end

Fabricator(:moderator_post, from: :post) do
  user
  topic {|attrs| Fabricate(:topic, user: attrs[:user] ) }
  post_type Post::MODERATOR_ACTION
  raw "Hello world"
end


Fabricator(:post_with_images, from: :post) do
  raw "
<img src='/path/to/img.jpg' height='50' width='50'>
![Alt text](/second_image.jpg)
  "
end

Fabricator(:post_with_image_url, from: :post) do
  cooked "
<img src=\"http://www.forumwarz.com/images/header/logo.png\">
  "
end


Fabricator(:basic_reply, from: :post) do
  user(:coding_horror)
  reply_to_post_number 1
  topic
  raw 'this reply has no quotes'
end

Fabricator(:reply, from: :post) do
  user(:coding_horror)
  topic
  raw '
    [quote="Evil Trout, post:1"]hello[/quote]
    Hmmm!
  '
end

Fabricator(:post_with_external_links, from: :post) do
  user
  topic
  raw "
Here's a link to twitter: http://twitter.com
And a link to google: http://google.com
And a markdown link: [forumwarz](http://forumwarz.com)
And a markdown link with a period after it [codinghorror](http://www.codinghorror.com/blog).
  "
end
