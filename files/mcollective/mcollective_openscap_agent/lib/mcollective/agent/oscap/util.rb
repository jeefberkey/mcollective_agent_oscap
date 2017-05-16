module MCollective::Agent::Oscap::Util
  require 'facter'
  require 'nokogiri'

  class MCollective::Agent::Oscap::Error < StandardError; end

  def ddl
    @ddl = MCollective::DDL.new('oscap') unless @ddl
    return @ddl
  end

  def content_path(request)
    return @content_path if @content_path

    path = request.data[:content_path]
    path = ddl.action_interface('profiles')[:input][:content_path][:default] unless path

    unless File.directory?(path)
      raise MCollective::Agent::Oscap::Error,"Content Path '#{path}' could not be found"
    end

    @content_path = path
    return @content_path
  end

  def xccdf(request)
    return @xccdf if @xccdf

    file = request.data[:xccdf]
    file = ddl.action_interface(request[:command])[:input][:xccdf][:data_default] unless file
    base_path = content_path(request)

    # If we were passed a file, don't bother with trying to determine one
    if file
      unless File.exist?(File.join(base_path,file))
        raise MCollective::Agent::Oscap::Error,"XCCDF file '#{file}' could not be found"
      end
    else 
      operating_system = Facter.fact('operatingsystem')
      operating_system_maj_release = Facter.fact('operatingsystemmajrelease')
    
      if !operating_system or !operating_system_maj_release
        raise MCollective::Agent::Oscap::Error,'Could not determine the host OS or OS Release'
      else
        operating_system = operating_system.value.strip
        operating_system_maj_release = operating_system_maj_release.value.strip
      end
    
      # Map this to something that should match a distribution file
      distribution_file_name = operating_system.downcase
    
      # Default to the SSG method of doing things
      if ['redhat','centos'].include?(distribution_file_name)
        distribution_file_name = "rhel#{operating_system_maj_release}"
      end
    
      file = Dir.glob(File.join(base_path,"*#{distribution_file_name}-xccdf.xml")).first
  
      # All guesses failed.
      if file.nil? || file.empty?
        raise MCollective::Agent::Oscap::Error,"Could not find a valid XCCDF file at '#{file}' for #{operating_system} #{operating_system_maj_release}"
      end

      @xccdf = file
      return @xccdf
    end

    file
  end

  def cpe(request)
    return @cpe if @cpe

    file = request.data[:cpe]
    file = ddl.action_interface(request[:command])[:input][:cpe][:data_default] unless file
    base_path = content_path(request)

    # If we were passed a file, don't bother with trying to determine one
    if file
      unless File.exist?(File.join(base_path,file))
        raise MCollective::Agent::Oscap::Error,"CPE file '#{file}' could not be found"
      end
    else 
      # Just mangle the XCCDF request base
      file = xccdf(request).gsub('xccdf','cpd-dictionary')

      unless File.exist?(file)
        # We didn't find the first guess, try again.
        file = Dir.glob(File.join(base_path,'*cpe-dictionary.xml')).first

        # All guesses failed.
        if file.nil? || file.empty?
          raise MCollective::Agent::Oscap::Error,"Could not find a valid CPE file at '#{file}'"
        end
      end

      @cpe = file
      return @cpe
    end
  end
end
