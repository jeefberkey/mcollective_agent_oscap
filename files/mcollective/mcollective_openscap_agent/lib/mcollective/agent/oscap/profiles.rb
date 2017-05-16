module MCollective::Agent::Oscap::Profiles
  def get_profiles(xccdf_file)
    xmldoc = Nokogiri::XML(File.open(xccdf_file))
    profiles = xmldoc.xpath('//xmlns:Profile')
    # Just return the Profile IDs (human readable)
    reply[:profiles] = profiles.map{|x| x = x[:id]}
  end
end
