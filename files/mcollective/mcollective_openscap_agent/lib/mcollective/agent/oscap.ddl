metadata  :name        => 'oscap',
          :description => 'Perform OpenSCAP scans. Defaults to the SCAP Security Guide (https://fedorahosted.org/scap-security-guide)',
          :author      => 'Onyx Point',
          :license     => 'ASL 2.0',
          :version     => '0.0.1',
          :url         => 'https://github.com/onyxpoint/mcollective-openscap-agent',
          :timeout     => 300

requires :mcollective => '2.3.1'

action 'profiles', :description => 'List available profiles' do
  display :always

  input :content_path,
    :prompt       => 'Content Path',
    :description  => 'The full path to the OpenSCAP content',
    :type         => :string,
    :validation   => '^\/',
    :default      => '/usr/share/xml/scap/ssg/content',
    :optional     => true,
    :maxlength    => 230

  input :xccdf,
    :prompt       => 'XCCDF Source',
    :description  => 'The XCCDF File to use for the scan. A sensible default will be chosen based on the target system.',
    :type         => :string,
    :validation   => '^.*',
    :optional     => true,
    :maxlength    => 1024

  output :profiles,
    :description  => 'Available OpenSCAP Profiles',
    :display_as   => 'OpenSCAP Profiles',
    :default      => 'No Profiles Found'
end

action 'oval_checks', :description => 'List available OVAL Checks' do
  display :always

  input :content_path,
    :prompt       => 'Content Path',
    :description  => 'The full path to the OpenSCAP content',
    :type         => :string,
    :validation   => '^\/',
    :default      => '/usr/share/xml/scap/ssg/content',
    :optional     => true,
    :maxlength    => 230

  input :xccdf,
    :prompt       => 'XCCDF Source',
    :description  => 'The XCCDF File to use for the scan. A sensible default will be chosen based on the target system.',
    :type         => :string,
    :validation   => '^.*',
    :optional     => true,
    :maxlength    => 1024

  output :oval_checks,
    :description  => 'Available OVAL Checks',
    :display_as   => 'OVAL Checks',
    :default      => 'No Checks Found'
end

action 'scan', :description => 'Run an OpenSCAP scan. Full scans will need to set a large timeout!' do
  display :always

  # Required Parameters
  input :profile,
    :prompt       => 'Profile Name',
    :description  => 'A specific Profile to run.',
    :type         => :string,
    :validation   => '.*',
    :optional     => false,
    :maxlength    => 1024

  input :scan_id,
    :prompt       => 'Scan ID',
    :description  => 'A specific scan ID to run or "ALL".',
    :type         => :string,
    :validation   => '.*',
    :optional     => false,
    :maxlength    => 2048

  # Optional Parameters
  input :content_path,
    :prompt       => 'Content Path',
    :description  => 'The full path to the OpenSCAP content',
    :type         => :string,
    :validation   => '^\/',
    :default      => '/usr/share/xml/scap/ssg',
    :optional     => true,
    :maxlength    => 230

  input :cpe,
    :prompt       => 'CPE Source',
    :description  => 'The CPE File to use for the scan. A sensible default will be chosen based on the target system.',
    :type         => :string,
    :validation   => '^.*',
    :optional     => true,
    :maxlength    => 1024

  input :xccdf,
    :prompt       => 'XCCDF Source',
    :description  => 'The XCCDF File to use for the scan. A sensible default will be chosen based on the target system.',
    :type         => :string,
    :validation   => '^.*',
    :optional     => true,
    :maxlength    => 1024

  input :full_report,
    :prompt       => 'Full Report',
    :description  => 'If set, return a full report of the system scan',
    :type         => :boolean,
    :optional     => true,
    :default      => false

  input :save_results,
    :prompt       => 'Save Results?',
    :description  => 'If set, save the results to a directory on the executing system for future analysis.',
    :type         => :boolean,
    :optional     => true,
    :default      => false

  input :save_location,
    :prompt       => 'Save Location',
    :description  => 'If "save_results" is true, use this location for saving the results.',
    :type         => :string,
    :validation   => '^\/',
    :optional     => true,
    :default      => '/var/cache/ssg/scans',
    :maxlength    => 2048

  output :score,
    :description  => 'OpenSCAP Scan Score',
    :display_as   => 'Score',
    :default      => '0'

  output :scan_results,
    :description  => 'OpenSCAP Scan Results',
    :display_as   => 'Scan Results',
    :default      => ''

  summarize do
    aggregate summary(:score)
  end
end
# vim: syntax=ruby ts=2 sw=2:
