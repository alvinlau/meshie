require 'airborne'

describe 'topics' do
  it 'should create and publish topics' do
    get 'localhost:9000/api/topics/new'
    expect(topic_id = json_body[:uuid]).not_to be nil

    topic_name = "test_topic#{SecureRandom.urlsafe_base64}"
    post 'localhost:9000/api/topics/publish', {name: topic_name, uuid: topic_id.to_s}
    puts "publish result: #{json_body}"
    expect(json_body[:success]).not_to be(nil), 'cannot publish topic'
    expect(json_body[:name]).to eq(topic_name), 'published topic name does not match'
  end

  it 'should create edit and delete items' do

  end

end
