module MCollective::Agent::Oscap::Scan
  def perform_scan(xccdf,cpe,options)
    require 'tempfile'
    require 'nokogiri'

    results_file = Tempfile.new('oscap_results')

    begin
      base_dir = xccdf_hack(xccdf)

      xccdf = File.basename(xccdf)
      cpe = File.basename(cpe)

      status = run("oscap xccdf eval --profile #{options[:profile]} --cpe #{cpe} --check-engine-results --results #{results_file.path} #{xccdf}",:cwd => base_dir)

      if status != 1
        scan_results = {}

        xmldoc = Nokogiri::XML(File.open(results_file))

        score = xmldoc.at_xpath('//xmlns:score').text
        if score.to_f == 0.0
          reply[:scan_results] = 'No Useful Scan Results Produced'
        else
          reply[:score] = score
        end

        if reply[:score] && options[:full_report]
          scan_results = {}
          xmldoc.xpath('//xmlns:rule-result').each do |result|
            result_value = result.children.select{|x| x.name == 'result'}.first.child.to_s
            # Ignore anything not actually used.
            next if ['notselected','notapplicable'].include?(result_value)

            scan_results[result[:idref]] = {
              :severity => result[:severity],
              :result   => result.children.select{|x| x.name == 'result'}.first.child.to_s
            }
          end

          reply[:scan_results] = scan_results
        end
      else
        reply[:scan_results] = 'There was an error during the OpenSCAP scan'
      end
    ensure
      results_file.close
      results_file.unlink
      if base_dir && base_dir =~ /mco\.oscap\.tmp/
        require 'fileutils'
        FileUtils.rm_rf(base_dir)
      end
    end
  end

  def perform_targeted_scan(xccdf,options)
    require 'tempfile'

    oval_id = options[:scan_id]
    unless oval_id.include?(':')
      oval_id,oval_src = get_oval_ref_id(xccdf,oval_id)
    end

    if oval_id.nil?
      reply[:scan_results] = "Invalid OVAL ID #{options[:scan_id]} passed"
    else
      results_file = Tempfile.new('oscap_results')

      begin
        base_dir = xccdf_hack(xccdf)

        scan_results = []
        MCollective::Log.error("oscap oval eval --id #{oval_id} #{oval_src}")
        run("oscap oval eval --id #{oval_id} #{oval_src}",
                             :stdout => scan_results,
                             :chomp => true,
                             :cwd => base_dir
                            )

        reply[:scan_results] = scan_results[0].to_s =~ /true$/ ? 'Pass' : 'Fail'
      ensure
        results_file.close
        results_file.unlink
        if base_dir && base_dir =~ /mco\.oscap\.tmp/
          require 'fileutils'
          FileUtils.rm_rf(base_dir)
        end
      end
    end
  end

  private

  # Translate from a human-readable OVAL name to the actual OVAL ID
  def get_oval_ref_id(xccdf,oval_name)
    require 'nokogiri'
    oval_id = nil

    xmldoc = Nokogiri::XML(File.open(xccdf))

    rule = xmldoc.at_xpath("//xmlns:Rule[@id='#{oval_name}']")
    check = rule.at_xpath('xmlns:check') if rule
    content_ref = check.at_xpath('xmlns:check-content-ref') if check
    oval_id = content_ref[:name] if content_ref
    oval_src = content_ref[:href] if content_ref

    unless File.readable?(File.join(File.dirname(xccdf),oval_src))
      MCollective::Log.error("Could not find #{oval_src}")
      oval_id = oval_src = nil
    end

    return [oval_id,oval_src]
  end

  # Flip the RHEL defs so that we can use them on CentOS
  # Return the new base directory
  def xccdf_hack(xccdf_file)
    base_dir = File.dirname(xccdf_file)

    operating_system = Facter.fact('operatingsystem')
    
    if operating_system && operating_system.value.strip == 'CentOS'
      require 'facter'

      tmpdir = Dir.mktmpdir('mco.oscap.tmp')

      # Force CentOS scan compatibility.
      Dir.glob("#{base_dir}/*.xml").each do |to_munge|
        content = File.read(to_munge)
        content.gsub!(/Red Hat Enterprise Linux/,'CentOS')
        content.gsub!(/cpe:\/o:redhat:enterprise_linux/,'cpe:/o:centos:centos')

        File.open(%{#{tmpdir}/#{File.basename(to_munge)}},'w') do |fh|
          fh.write(content)
        end
      end

      base_dir = tmpdir
    end

    return base_dir
  end
end
