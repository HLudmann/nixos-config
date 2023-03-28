{ ... }:

{
  # https://jackson.dev/post/nix-reasonable-defaults/
  nix.settings = {
    connect-timeout = 5;
    log-lines = 25;
    min-free = 128000000;
    max-free = 1000000000;

    experimental-features = nix-command flakes;
    fallback = true;
    warn-dirty = false;
    auto-optimise-store = true;

    keep-outputs = true;
  };
}
