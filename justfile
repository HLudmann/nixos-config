_default:
  @{{just_executable()}} --list

# Build NixOS config of current system (use config with NAME=`hostname`)
rebuild *ARGS:
  nixos-rebuild --flake . build {{ ARGS }}

# Switch to NixOS config of current system  (use config with NAME=`hostname`)
reswitch *ARGS:
  echo NOTE: will need sudo to activate
  nixos-rebuild --flake . switch {{ ARGS }}

# Build the given NixOS config NAME
dobuild NAME *ARGS:
  nixos-rebuild --flake .#{{ NAME }} build {{ ARGS }}

# Switch system to the given NixOS config NAME
doswitch NAME *ARGS:
  echo NOTE: will need sudo to activate
  nixos-rebuild --flake .#{{ NAME }} switch {{ ARGS }}