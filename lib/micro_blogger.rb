require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client
  
  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end
  
  def tweet(message)
    if message.length > 140
      puts "Message length is greater than 140; too long!"
    else
      @client.update(message)
    end
  end

  def dm(target, message)
    screen_names = @client.followers.map {|follower| @client.user(follower).screen_name}
    unless screen_names.include?(target)
      puts "Message target is not a follower! Cannot send."
      return
    end
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    tweet(message)
  end

  def followers_list
    return @client.followers.map {|follower| @client.user(follower).screen_name}
  end
  
  def spam_my_followers(message)
    self.followers_list.each{|follower| dm(follower, message)}
  end

  def everyones_last_tweet
    friends = @client.friends.sort_by {|friend| @client.user(friend).screen_name.downcase}
    friends.each do |friend|
      puts "----", "@#{@client.user(friend).screen_name} said this at #{@client.user(friend).status.created_at.strftime('%-m-%-d-%Y %l:%M %p')}", "---- \n"
      puts "\n#{@client.user(friend).status.text}", "\n"
    end
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    return bitly.shorten(original_url).short_url
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q' then puts "Goodbye!"
      when 't' then tweet(parts[1..-1].join(" "))
      when 'dm' then dm(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_followers(parts[1..-1].join(" "))
      when 'elt' then everyones_last_tweet
      when 'turl' then tweet(parts[1..-2].join(' ') + " #{shorten(parts[-1])}")
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end

end

blogger = MicroBlogger.new
blogger.run