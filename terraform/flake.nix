{
  description =
    "A Nix-flake-based development environment for Terraform";


  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            aws-azure-login # Terraform uses this to allow access to state files
            awscli2 # Terraform uses this to allow access to state files
            terraform # Deployment automation
            tflint # terraform linter
            terragrunt # terraform wrapper

            google-cloud-sdk # Required for accesing Vault
            vault-bin # Vault CLI for secret management
          ];
        };
      });
    };
}
