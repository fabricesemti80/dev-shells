{
  description =
    "A Nix-flake-based development environment for Ansible";


  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; config.permittedInsecurePackages = [
                "python3.12-kerberos-1.3.1"
              ]; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            ansible  # IT automation
            ansible-lint # Linter for Ansible #! install this directly until solution found to get latest
            glibcLocales  # Ansible  needs this [source: https://github.com/NixOS/nixpkgs/issues/223151]
            python3
            python312Packages.flake8
            python312Packages.kerberos # KERBEROS authentication for Ansible to communicate with domain-joined Windows hosts
            python312Packages.pip
            python312Packages.pywinrm # Allow Ansible to manage Windows-hosts
            python312Packages.requests
            sshpass # For those rare cases when SSH is used with password

            google-cloud-sdk # Required for accesing Vault
            vault-bin # Vault CLI for secret management
          ];
        };
      });
    };
}
