require 'cora'
require 'siri_objects'
require 'httparty'
require 'json'
require 'pp'


class SiriProxy::Plugin::Sirifacebook < SiriProxy::Plugin
  attr_accessor :access_token
  attr_accessor :username
  
  def initialize(config)  
    self.access_token = config["access_token"] 
    self.username = config["username"]
  end



#"Create facebook friend list"
#You: "Create facebook friend list lalalal
#Siri: You want to crat a facebook friendlist called lalala
#If you confirm siri will say: Sending to facebook, and after making the friendlist, siri will say Your friendlist has been made.
#
#Finished--
listen_for /create facebook friend list (.+)/i do |friendlist|
  if confirm "You want to create a facebook friendlist called " + friendlist + "?"
        say "Sending to Facebook..."
        Thread.new {
            begin
                page = HTTParty.post(
                                     "https://graph.facebook.com/#{self.username}/friendlists",
                                     :query => {
				     :name => (friendlist),
                                     :access_token => (access_token)
                                     }
                                     )
                say "Your friendlist has been made."
                rescue Exception
                pp $!
                say "Sorry, I encountered an error: #{$!}"
                ensure
                request_completed
            end
        }
        else
        say "Ok I won't send it."
        request_completed
    end
end





#"What's my latest wall post"
#siri shows you your latest wall post
#For Example
#You: What's my latest wall post?
#Siri: Your latest wall post is: blablabla
#Finished--
listen_for /what's my latest wall post/i do
	notificationspage = HTTParty.get("https://graph.facebook.com/#{self.username}/feed?fields=name,message&access_token=#{self.access_token}&limit=1").body rescue ni
	notifications = JSON.parse(notificationspage) rescue nil

	notifications['data'].each do |data|
	 say "Your latest wall post is: data['message']"
	end


	request_completed
end


#"Check facebook requests"
#Siri checs your requests, nothing more to say...
#For Example:
#You: Check facebook requests
#Siri: 'You have no new friend requests' or 'You have new friend requests'
#Finished--
listen_for /check facebook requests/i do
	requestspage = HTTParty.get("https://graph.facebook.com/#{self.username}/friendrequests&access_token=#{self.access_token}").body rescue ni
	requests = JSON.parse(requestspage) rescue nil

	answer = "You have no new friend requests."

	requests['data'].each do |data|
	 unread = "#{data['unread']}"
	 if unread = "true"
	   answer = "You have new friend requests."	
	  end
	end

	say answer

	request_completed
end




#"Check facebook messages"
#DOESN'T WORK!
#I'M WORKING ON THAT!
#Do not try it since I made an update, maybe your siri proxy freezes!
#listen_for /check facebook messages/i do
#     	  page = HTTParty.get("https://graph.facebook.com/me/inbox&access_token=#{self.access_token}").body rescue nil
 #         inbox = JSON.parse(page) rescue nil
#
#	inbox['data'].each do |data|
#
#	messages = "#{data['name']}"
#
 #       object = SiriAddViews.new
  #      object.make_root(last_ref_id)
   #     answer = SiriAnswer.new("My facebook Messages:", [
    #                        SiriAnswerLine.new(messages)
     #                       ])
      #  object.views << SiriAnswerSnippet.new([answer])
       # send_object object
	#end
#
#
#	request_completed
#end





#"Make a facebook note"
#Siri makes a facebook note for you
#For example:
#You: make a facebook note blablabla
#Siri: What's the subject of your note?
#You: lalala
#Siri: Here is your note:
#then a SiriAddViews appears (The same frame like WoflramAlpha)
#With your subject and your text
#Siri: Ready to send it?
#You: Yes
#Siri: Posting to facebok...
#If you say no, siri will say Ok, I won't send it
#
#Finished--
listen_for /make a facebook note (.+)/i do |notetext|
   subject = ask "What's the subject of your note?"

    say "Here is your note:"
    
        # Preview of the note
        object = SiriAddViews.new
        object.make_root(last_ref_id)
        answer = SiriAnswer.new("Facebook note", [
                            SiriAnswerLine.new('logo','http://cl.ly/CXNm/Screen%20Shot%202011-12-11%20at%2011.26.52%20AM.png'), # facebook logo
                            SiriAnswerLine.new(subject),
			    SiriAnswerLine.new(notetext)
                            ])
        object.views << SiriAnswerSnippet.new([answer])
        send_object object

          
            
    if confirm "Ready to send it?"
        say "Sending to Facebook..."
        Thread.new {
            begin
                page = HTTParty.post(
                                     "https://graph.facebook.com/#{self.username}/notes",
                                     :query => {
                                     :subject => (subject),
				     :message => (notetext),
                                     :access_token => (access_token)
                                     }
                                     )
                say "Your note has been sent."
                rescue Exception
                pp $!
                say "Sorry, I encountered an error: #{$!}"
                ensure
                request_completed
            end
        }
        else
        say "Ok I won't send it."
        request_completed
    end
end

#"Share link on facebook"
#Siri shares a link you want on facebook
#You: Share link on facebook www.revolution-apps.com
#Siri: Here is your preview:
#then a SiriAddViews appears (The same frame like WoflramAlpha)
#With the link you have chosen
#Siri: Ready to send it?
#You: Yes
#Siri: Posting to facebok...
#If you say no, siri will say Ok, I won't send it
#
#Finished--
listen_for /share link on facebook (.+)/i do |link|
    say "Do you want to share that link on facebook: " + link + "?"

          
            
    if confirm "Ready to send it?"
        say "Posting to Facebook..."
        Thread.new {
            begin
                page = HTTParty.post(
                                     "https://graph.facebook.com/#{self.username}/feed",
                                     :query => {
                                     :link => (link),
                                     :access_token => (access_token)
                                     }
                                     )
                say "Your link has been shared."
                rescue Exception
                pp $!
                say "Sorry, I encountered an error: #{$!}"
                ensure
                request_completed
            end
        }
        else
        say "Ok I won't send it."
        request_completed
    end
end

#"My facebook friends"
#Siri will show you your facebook friends
#You: my facebook friends
#Siri will send you a list of your friends using a SiriAddViews (The same frame like WoflramAlpha)
#Finished--
listen_for /my facebook friends/i do     
     	  page = HTTParty.get("https://graph.facebook.com/#{self.username}/friends&access_token=#{self.access_token}").body rescue nil
          friends = JSON.parse(page) rescue nil

	friends['data'].each do |data|	

        object = SiriAddViews.new
        object.make_root(last_ref_id)
        answer = SiriAnswer.new("My facebook friends:", [
                            SiriAnswerLine.new("Name: #{data['name']}"),
			    SiriAnswerLine.new("ID: #{data['id']}"),
                            ])
        object.views << SiriAnswerSnippet.new([answer])
        send_object object
	end


	request_completed
end


#"My facebook likes"
#Siri will show you your facebook likes
#You: my facebook likes
#Siri will send you a list of your likes using a SiriAddViews (The same frame like WoflramAlpha) 
#Finished--
listen_for /my facebook likes/i do
	page = HTTParty.get("https://graph.facebook.com/#{self.username}/likes&access_token=#{self.access_token}").body rescue nil
	likes = JSON.parse(page) rescue nil
	
	likes['data'].each do |data|

        object = SiriAddViews.new
        object.make_root(last_ref_id)
        answer = SiriAnswer.new("My facebook likes:", [
                            SiriAnswerLine.new("Name: #{data['name']}"),
			    SiriAnswerLine.new("Category: #{data['category']}"),
			    SiriAnswerLine.new("ID: #{data['id']}"),
			    SiriAnswerLine.new("Created: #{data['created_time']}"),
                            ])
        object.views << SiriAnswerSnippet.new([answer])
        send_object object
	end

	request_completed
end


#"Check facebook notifications"
#Siri checks your facebook notifications
#You: Check facebook notifications
#Siri: Checking facebook notifications...
#Siri: 'You have no new notification' or 'You have 1 new notification and what notification it is' or 'You have ... new notifications and what notifications'
#
#Credits: Ross Waycaster (made this command)
#Finished--
  listen_for /check facebook notifications/i do
    
          page = HTTParty.get("https://api.facebook.com/method/notifications.getList?access_token=#{self.access_token}&format=json").body rescue nil
          notifications = JSON.parse(page) rescue nil
          count = 0
          
          say "Checking Facebook notifications..."
            
          unless notifications.nil?
            notifications['notifications'].each do
              count = count + 1
            end
          end
            
            if count == 1
              say "You have #{count} new notification."
              notifications['notifications'].each do |item|
                say item['title_text']
              end
            end
            if count > 1
              say "You have #{count} new notifications."
              notifications['notifications'].each do |item|
                say item['title_text']
              end
            end
            
            if count == 0
              say "You have no new notifications."
            end
  
          request_completed #always complete your request! Otherwise the phone will "spin" at the user!
    end
 

    
#"Facebook status"
#Siri shares a status you want on facebook
#You: Facebook status lalalalal
#Siri: Here is your preview:
#then a SiriAddViews appears (The same frame like WoflramAlpha)
#With your status
#Siri: Ready to send it?
#You: Yes
#Siri: Posting to facebok...
#If you say no, siri will say Ok, I won't send it
#
#Credits: Shabbir (made this command)
#Finished--
listen_for /facebook status (.+)/i do |facebookText|
    say "Here is your status:"
    
        # Preview of the Status update
        object = SiriAddViews.new
        object.make_root(last_ref_id)
        answer = SiriAnswer.new("Facebook Status", [
                            SiriAnswerLine.new('logo','http://cl.ly/CXNm/Screen%20Shot%202011-12-11%20at%2011.26.52%20AM.png'), # facebook logo
                            SiriAnswerLine.new(facebookText)
                            ])
        object.views << SiriAnswerSnippet.new([answer])
        send_object object

          
            
    if confirm "Ready to send it?"
        say "Posting to Facebook..."
        Thread.new {
            begin
                page = HTTParty.post(
                                     "https://graph.facebook.com/#{self.username}/feed",
                                     :query => {
                                     :message => (facebookText),
                                     :access_token => (access_token)
                                     }
                                     )
                say "Your status has been updated."
                rescue Exception
                pp $!
                say "Sorry, I encountered an error: #{$!}"
                ensure
                request_completed
            end
        }
        else
        say "Ok I won't send it."
        request_completed
    end
end 



#"My facebook profile"
#Siri will give you, some informations about you
#You: My facebook profile
#Siri: I found that for you:
#then a SiriAddViews appears (The same frame like WoflramAlpha)
#with your pofilepicture, your name, your gender, your birthday, your facebook link, your facebook ID
#Finished--
listen_for /my facebook profile/i do
     userjson = HTTParty.get("https://graph.facebook.com/#{self.username}?fields=link,id,name,picture,gender&access_token=#{self.access_token}").body rescue nil #profile informations
  
user = JSON.parse(userjson) rescue nil
name = "#{user['name']}"
id = "#{user['id']}"
link = "#{user['link']}"
gender = "#{user['gender']}"
profilepicture = "#{user['picture']}"
 
say "I found that for you:", spoken: "Name: #{user['name']}, Gender: #{user['gender']}, Link: #{user['link']}"

        object = SiriAddViews.new
        object.make_root(last_ref_id)
        answer = SiriAnswer.new("My facebook profile:", [
                            SiriAnswerLine.new('your profilpicture', profilepicture), #profile picture
                            SiriAnswerLine.new('Name: ' + name),
                            SiriAnswerLine.new('Gender: ' + gender),
                            SiriAnswerLine.new('Link: ' + link),
                            SiriAnswerLine.new('ID: ' + id)
                            ])
        object.views << SiriAnswerSnippet.new([answer])
        send_object object

          request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

#"What's my access token"
#Siri says your facebook access token
#You: What's my access token
#Siri: Your Facebook access token is: 'and your acces token'
#Finished--
listen_for /what's my access token/i do
  say "Your Facebook access token is: #{self.access_token}"
end


#"About facebook for siri"
#Nothing more to say :)
#
#Finished--
listen_for /about Siri facebook/i do

say "I found that for you:", spoken: "Name: SiriFacebook, Version: 0.0.1 (First release), Developer: TheKleini666 (Revolution-Apps.com), Homepage: http://revolution-apps.com, Support: support@revolution-apps.com and TheKleini666@revolution-apps.com"

        object = SiriAddViews.new
        object.make_root(last_ref_id)
        answer = SiriAnswer.new("About SiriFacebook:", [
                            SiriAnswerLine.new('Name: SiriFacebook'),
                            SiriAnswerLine.new('Version: 0.0.1.1'),
                            SiriAnswerLine.new('Developer: TheKleini666 (Revolution-Apps.com)'),
                            SiriAnswerLine.new('Homepage: http://revolution-apps.com'),
                            SiriAnswerLine.new('Support:'),
                            SiriAnswerLine.new('support@revolution-apps.com'),
                            SiriAnswerLine.new('TheKleini666@revolution-apps.com')
                            ])
        object.views << SiriAnswerSnippet.new([answer])
        send_object object

	request_completed
end
end
 
