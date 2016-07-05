require "net/http"
require 'json'
require "uri"

# Get the AWS EC2 instance ID from http://instance-data/
begin
  uri = URI.parse("http://169.254.169.254")
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = 4
  http.read_timeout = 4
  request = Net::HTTP::Get.new("/latest/meta-data/instance-id")
  response = http.request(request)

  instance_id = response.body
  # puts "ec2tagfacts: Instance ID is #{instance_id}"

rescue
  puts "ec2tagfacts: this is not an AWS EC2 instance or unable to contact the AWS instance-data web server."
end

if !instance_id.is_a? String then
  puts "ec2tagfacts: Something bad happened since there was no error but this isn't a string."
else
  # Get the AWS EC2 instance region from http://instance-data/ and then shorten the region
  # for example we convert us-west-2b into us-west-2 in order to get the tags
  #r = Net::HTTP.get('instance-data', '/latest/meta-data/placement/availability-zone')
  request2 = Net::HTTP::Get.new("/latest/meta-data/placement/availability-zone")
  response2 = http.request(request2)
  r = response2.body

  region = /.*-.*-[0-9]/.match(r)
  # puts "ec2tagfacts: Region is #{region}"

  # Get the aws ec2 instance tags as a JSON string
  begin
    jsonString = `aws ec2 describe-tags --filters "Name=resource-id,Values=#{instance_id}" --region #{region}`
    hash = JSON.parse(jsonString)

    if hash.is_a? Hash then
      if hash.has_key?("Tags") then
        hash['Tags'].each do |child|
          fact = "ec2_tag_#{child['Key']}"
          fact.downcase!
          fact.gsub(/\s+/, "_")

          puts "ec2tagfacts: fact #{fact} = #{child['Value']}"

          Facter.add("#{fact}") do
            setcode do
              child['Value']
            end
          end
        end
      else
        puts "ec2tagfacts: No tags found"
      end
    end
  rescue # Ignore if awscli had any issues
    puts "ec2tagfacts: awscli has problems, cant do anything"
  end
end
