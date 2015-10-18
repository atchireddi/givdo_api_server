module FacebookGraph
  
  def get_graph
    oauth = Koala::Facebook::OAuth.new Facebook::APP_ID, Facebook::SECRET
    app_access_token = oauth.get_app_access_token
    Koala::Facebook::API.new app_access_token
  end
  
  def cache_organization(organization, graph)
    ograph = graph.get_object(organization.facebook_id)
    organization['name'] = ograph['name']
    organization['city'] = ograph['location']['city']
    organization['state'] = ograph['location']['state']
    organization['zip'] = ograph['location']['zip']
    organization['street'] = ograph['location']['street']
    organization['picture'] = graph.get_picture(organization.facebook_id)
    organization['mission'] = ograph['mission']
    organization['cached'] = true
    organization.save
  end
  
  def cache_organizations
    graph = get_graph
    for organization in Organization.all
      if !organization.cached?
        puts "caching organization with FB ID " + organization['facebook_id'] 
        cache_organization(organization, graph)  
        puts "organization " + organization['name'] + " was cached successfully!"
      else
        puts "organization " + organization.name + " is already cached"
      end
    end    
  end
  
end