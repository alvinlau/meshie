require 'uuid'

module Meshie
  class API < Grape::API
    format :json

    helpers do
      def topics
        Padrino.config.mongo[:topics]
      end
    end

    # get 'status' do
    #   cookies[:status_count] ||= 0
    #   cookies[:status_count] = cookies[:status_count].to_i + 1
    #   { status_count: cookies[:status_count] }
    # end

    get 'mongo' do
      topics.find.to_a
    end

    resource :topics do
      desc 'make a new draft'
      get :new do
        uuid = UUID.new.generate.to_s
        result = topics.insert_one({uuid: uuid, links: [], notes: [], widgets: []})
        # TODO: create token for user visage
        (result.n > 0) ? {uuid: uuid} : {error: 'could not insert'}
      end

      desc 'publish a draft'
      params do
        requires :name, type: String
        requires :uuid, type: String
      end
      post :publish do
        # check the topic name availability
        results = topics.find({name: params[:name]})
        return {error: 'topic name already exists'} if results.to_a.size > 0

        # just set the name of the topic to indicate it is published
        topics.update_one({uuid: params[:uuid]}, {'$set' => {name: params[:name]}} )
        {succes: 'published topic', name: params[:name]}
      end

      desc 'show a topic'
      route_param :name do
        get do
          topics.find({name: params[:name]}).first
        end
      end

      desc 'request token for a topic'
      params { requires :visage_id , type: Integer, desc: 'requester id' }
      route_param :id do
        get :token do
          # generate token for topic id => visage id
        end
      end
    end

    resource :items do
      desc 'add link to a topic'
      params do
        requires :topic_id, type: String, desc: 'draft id or topic name'
        requires :url, type: String, desc: 'the url'
      end
      route_param :name do
        post :link do
          # TODO: fetch the url and get some meta data
          uuid = UUID.new.generate.to_s
          link_obj = {uuid: uuid, url: params[:url]}
          result = topics.update_one({name: params[:name]}, {'$push' => {links: link_obj}})
          (result.modified_count > 0) ? {uuid: uuid} : {error: 'could not insert'}
        end
      end


      desc 'edit link'
      params do
        requires :item_name, type: String
      end
      put ':uuid' do

      end
    end
  end
end
