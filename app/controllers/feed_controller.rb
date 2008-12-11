class FeedController < ApplicationController

	def events
		@events = eventlist(params, 10, 1)
		headers["Content-Type"] = "application/rss+xml"
	end
	
	def blog
		@blogposts = Blog.find(:all, :order => "created_at ASC")
		headers["Content-Type"] = "application/rss+xml"
	end

	private

		def metrolist(params)
			Metro.find(:all, :order => 'name ASC');
		end
	
end
