{
	description = "Package for FinanceJ";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	};

	outputs = { self, nixpkgs, ... }: let
		system = "x86_64-linux";
		pkgs = import nixpkgs { inherit system; };
	in {
		packages."${system}".default = pkgs.maven.buildMavenPackage {
			pname = "financej";
			version = "0-SNAPSHOT";
			src = self;
			buildInputs = with pkgs; [ maven jdk8 makeWrapper ];
			buildPhase = ''
				bat flake.nix
				# mvn assembly:single
			'';
			installPhase = ''
				mkdir $out/bin -p
				mv ./target/financej-team06-1.0-SNAPSHOT.jar $out/bin/financej.jar

				makeWrapper ${pkgs.jdk8}/bin/java $out/bin/financej --add-flags "-jar $out/bin/financej.jar"
			'';
			mvnHash = "sha256-JaGAgToroCN7akuDjjWUaPeE+AxB6tcv4KPxruf12uo=";
		};
		devShells."${system}".default = pkgs.mkShell {
			packages = with pkgs; [
				maven
				jdk8
				zsh
			];
			shellHook = ''
				set SHELL zsh
				exec nvim
			'';
		};
	};
}
