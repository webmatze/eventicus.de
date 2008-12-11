ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  map.connect 'sitemap.xml', :controller => 'event', :action => 'sitemap' 


  map.connect 'events/import',
              :controller => 'event',
              :action => 'import',
              :menu => 'events'

  # Install the default route as the lowest priority.
  map.connect 'events/search/:search',
              :controller => 'event',
              :action => 'list',
              :menu => 'events',
              :type => 'upcoming',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world'
              
  map.events 'events/:place/:type/:category/:range/:page',
              :controller => 'event',
              :action => 'list',
			        :menu => 'events',
              :type => 'upcoming',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world',
              :requirements => {
                :page => /\d+/
              }
              
  map.connect 'rss/search/:search',
              :controller => 'feed',
              :action => 'events',
              :type => 'upcoming',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world'
  
  map.rss_events 'rss/events/:place/:type/:category/:range/:page',
              :controller => 'feed',
              :action => 'events',
              :type => 'upcoming',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world',
              :requirements => {
                :page => /\d+/
              }
              
  map.ical_events 'ical/events/:place/:type/:category/:range/:page',
              :controller => 'ical',
              :action => 'events',
              :type => 'upcoming',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world',
              :requirements => {
                :page => /\d+/
              }

  map.connect 'ical/search/:search',
              :controller => 'ical',
              :action => 'events',
              :type => 'upcoming',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world'

  map.reviews 'reviews/:place/:type/:category/:range/:page',
              :controller => 'event',
              :action => 'list',
			        :menu => 'reviews',
              :type => 'popular',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world',
              :requirements => {
                :page => /\d+/
              }
  map.photos 'photos/:place/:type/:category/:range/:page',
              :controller => 'event',
              :action => 'list',
              :menu => 'photos',
              :type => 'popular',
              :category => 'all',
              :range => 'all',
              :page => 1,
              :place => 'world',
              :requirements => {
                :page => /\d+/
              }
              
  map.blogposts 'blogposts/:page',
              :controller => 'blog',
              :action => 'list',
              :menu => 'blog',
              :page => 1,
              :requirements => {
                :page => /\d+/
              }
            
  map.rss_blog 'rss/blogposts/:page',
            :controller => 'feed',
            :action => 'blog',
            :page => 1,
            :requirements => {
              :page => /\d+/
            }
									
  map.event 'event/:id/:action',
      :controller => 'event',
      :action => 'show',
      :menu => 'events',
      :requirements => {
      :id => /\d+/
      }

  map.blog 'blog/:id/:action',
      :controller => 'blog',
      :action => 'show',
      :menu => 'blog',
      :requirements => {
      :id => /\d+/
      }

  map.user 'user/:id/:action',
			  :controller => 'account',
			  :action => 'show'
			
  map.connect 'event/:action',
      :controller => 'event',
      :action => 'new',
      :menu => 'events'
      
  map.connect 'blogadmin/:action',
      :controller => 'blog',
      :action => 'list',
      :menu => 'blog'

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
