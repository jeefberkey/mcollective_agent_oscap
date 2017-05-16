module MCollective::Agent::Oscap::OvalChecks
  def get_oval_checks(oval_file)
    xmldoc = Nokogiri::XML(File.open(oval_file))
    oval_checks = xmldoc.xpath('//xmlns:Rule')
    # Return some human readable names with OVAL IDs
    reply[:oval_checks] = []
    oval_checks.each do |check|
      id = check[:id]
      content_ref = check.at_xpath('xmlns:check')

      if content_ref
        content_ref = content_ref.at_xpath('xmlns:check-content-ref')
      else
        MCollective::Log.debug(%{Could not find Rule/check for #{id}})
      end

      if content_ref
        reply[:oval_checks] << %{#{id} => #{content_ref[:name]}}
      else
        MCollective::Log.debug(%{Could not find Rule/check/check-content-ref for #{id}})
      end
    end
  end
end
