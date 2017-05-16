# mcollective_agent_oscap version 0.0.1

#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
1. [Configuration](#configuration)

## Overview

Perform OpenSCAP scans. Defaults to the SCAP Security Guide (https://fedorahosted.org/scap-security-guide)

The mcollective_agent_oscap module is based on the source from https://github.com/onyxpoint/mcollective-openscap-agent.

Available Actions:

  * **oval_checks** - List available OVAL Checks
  * **profiles** - List available profiles
  * **remove** - Removes a file
  * **scan** - Run an OpenSCAP scan. Full scans will need to set a large timeout!
  * **status** - Basic information about a file
  * **touch** - Creates an empty file or touch it's timestamp

## Usage

You can include this module into your infrastructure as any other module, but as it's designed to work with the [choria mcollective](http://forge.puppet.com/choria/mcollective) module you can configure it via Hiera:

```yaml
mcollective::plugin_classes:
  - mcollective_agent_oscap
```

## Configuration

Server and Client configuration can be added via Hiera and managed through tiers in your site Hiera, they will be merged with any included in this module

```yaml
mcollective_agent_oscap::config:
   example: value
```

This will be added to both the `client.cfg` and `server.cfg`, you can likewise configure server and client specific settings using `mcollective_agent_oscap::client_config` and `mcollective_agent_oscap::server_config`.

These settings will be added to the `/etc/puppetlabs/mcollective/plugin.d/` directory in individual files.

For a full list of possible configuration settings see the module [source repository documentation](https://github.com/onyxpoint/mcollective-openscap-agent).

## Data Reference

  * `mcollective_agent_oscap::gem_dependencies` - Deep Merged Hash of gem name and version this module depends on
  * `mcollective_agent_oscap::manage_gem_dependencies` - disable managing of gem dependencies
  * `mcollective_agent_oscap::package_dependencies` - Deep Merged Hash of package name and version this module depends on
  * `mcollective_agent_oscap::manage_package_dependencies` - disable managing of packages dependencies
  * `mcollective_agent_oscap::class_dependencies` - Array of classes to include when installing this module
  * `mcollective_agent_oscap::package_dependencies` - disable managing of class dependencies
  * `mcollective_agent_oscap::config` - Deep Merged Hash of common config items for this module
  * `mcollective_agent_oscap::server_config` - Deep Merged Hash of config items specific to managed nodes
  * `mcollective_agent_oscap::client_config` - Deep Merged Hash of config items specific to client nodes
  * `mcollective_agent_oscap::policy_default` - `allow` or `deny`
  * `mcollective_agent_oscap::policies` - List of `actionpolicy` policies to deploy with an agent
  * `mcollective_agent_oscap::client` - installs client files when true - defaults to `$mcollective::client`
  * `mcollective_agent_oscap::server` - installs server files when true - defaults to `$mcollective::server`
  * `mcollective_agent_oscap::ensure` - `present` or `absent`
