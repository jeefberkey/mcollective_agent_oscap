class MCollective::Application::Oscap < MCollective::Application
  description 'Run OpenSCAP Actions'

  USAGES = {
    'profiles' => %{mco oscap profiles [--content-path <content path>] [--xccdf <xccdf filename>]},
    'oval_checks' => %{mco oscap oval_checks [--content-path <content path>] [--xccdf <xccdf filename>]},
    'scan' => %{mco oscap scan -p <profile> -i <ALL|some:valid:scan:id> [--content-path <content path>] [-xccdf <xccdf filename>] [ -f --full-report ] [--save_results] [--save_location <path>]}
  }

  usage <<-END_OF_USAGE
mco oscap [OPTIONS] [FILTERS] <ACTION> [ARGS]

  #{USAGES.values.sort.join("\n  ")}
END_OF_USAGE

  option :profile,
         :description => 'The profile to use.',
         :arguments   => [ '-p','--profile PROFILE' ],
         :type        => String

  option :scan_id,
         :description => 'The specific scan ID to target.',
         :arguments   => [ '-i','--scan_id ID' ],
         :type        => String

  option :content_path,
         :description => 'The absolute path to the SCAP content',
         :arguments   => [ '--content-path PATH' ],
         :type        => String,
         :validate    => Proc.new{|val| val =~ /^\/.+/ ? true : 'The Content Path must be absolute'}

  option :xccdf,
         :description => 'The full name of the XCCDF file to use',
         :arguments   => [ '-x','--xccdf XCCDF_FILE' ],
         :type        => String,
         :validate    => Proc.new{|val| val !~ /-xccdf.xml$/ ? true : 'The Data Stream should end with -ds.xml'}

  option :full_report,
         :arguments   => [ '-f','--full-report' ],
         :description => 'If set, display the full report of system findings',
         :type        => :bool

  option :save_results,
         :description => 'Whether to save the results on the system',
         :arguments   => [ '-s','--save_results' ],
         :type        => :bool

  option :save_location,
         :description => 'The location to which to save results on the system',
         :arguments   => [ '-t','--save_location PATH' ],
         :type        => String,
         :validate    => Proc.new{|val| val =~ /^\/.+/ ? true : 'The Save Location Path must be absolute'}

  def post_option_parser(configuration)
    valid_actions = USAGES.keys

    if ARGV.size < 1
      raise %{\nPlease specify one of the following actions:\n    * #{valid_actions.join("\n    * ")}}
    end

    action = ARGV.shift

    unless valid_actions.include?(action)
      raise 'Action has to be one of ' + valid_actions.join(', ')
    end

    configuration[:command] = action
    configuration[:options] = options
  end

  def validate_configuration(configuration)
    required_options = {
      'scan' => ['profile','scan_id']
    }

    required_options.each_key do |command|
      if configuration[:command] == command
        required_options[command].each do |opt|
          if configuration[opt.to_sym].nil?
            raise %{\nYou must supply '#{opt}'\n\nUSAGE:\n\n#{application_usage.join("\n")}}
          end
        end
      end
    end
  end

  def main
    rpcutil = rpcclient('oscap')
    printrpc rpcutil.send(configuration[:command],configuration)

    printrpcstats :summarize => true
  end
end
