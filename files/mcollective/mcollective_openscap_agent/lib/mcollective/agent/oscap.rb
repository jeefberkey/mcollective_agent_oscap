module MCollective
  module Agent
    class Oscap<RPC::Agent
      require 'mcollective/agent/oscap/util'
      include MCollective::Agent::Oscap::Util

      require 'mcollective/agent/oscap/profiles'
      include MCollective::Agent::Oscap::Profiles

      action 'profiles' do
        get_profiles(xccdf(request))
      end

      require 'mcollective/agent/oscap/oval_checks'
      include MCollective::Agent::Oscap::OvalChecks

      action 'oval_checks' do
        get_oval_checks(xccdf(request))
      end

      require 'mcollective/agent/oscap/scan'
      include MCollective::Agent::Oscap::Scan

      action 'scan' do
        if request.data[:scan_id] == 'ALL'
          perform_scan(xccdf(request), cpe(request), request.data)
        else
          perform_targeted_scan(xccdf(request), request.data)
        end
      end
    end
  end
end
