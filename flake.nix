{
	description = "Package for FinanceJ";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
	};

	outputs = { self, nixpkgs, ... }: let
		system = "x86_64-linux";
		buildMavenPackage = import ./buildmaven.nix {lib=pkgs.lib;stdenv=pkgs.stdenv;maven=pkgs.maven;};
		pkgs = import nixpkgs { inherit system; };
	in {
		packages."${system}" = {
			site = buildMavenPackage {
				pname = "financej-website";
				version = "0-SNAPSHOT";
				src = self;
				buildInputs = with pkgs; [ maven jdk8 ];
				postBuild = ''
					mvn site -o -nsu "-Dmaven.repo.local=$mvnDeps/.m2"
				'';
				installPhase = ''
					mkdir -p $out
					mv ./target/site $out/www
					mkdir -p $out/bin
					echo "${pkgs.firefox}/bin/firefox $out/www/index.html" > $out/bin/financej-website
					chmod u+x $out/bin/financej-website
				'';

				mvnJdk = pkgs.jdk8;
				mvnHash = "sha256-mrC/vszYlFWw+8BbuDbPsp/btnko/f3Opiv9GehwipM=";

				buildOffline = true;
			};
			
			default = buildMavenPackage {
				pname = "financej";
				version = "0-SNAPSHOT";
				src = self;
				buildInputs = with pkgs; [ maven jdk8 makeWrapper ];
				postBuild = ''
					mvn package -o -nsu "-Dmaven.repo.local=$mvnDeps/.m2"
				'';
				installPhase = ''
					mkdir $out/bin -p
					mv ./target/financej-team06-1.0-SNAPSHOT.jar $out/bin/financej.jar

					makeWrapper ${pkgs.jdk8}/bin/java $out/bin/financej --add-flags "-jar $out/bin/financej.jar"
				'';
				mvnHash = "sha256-mrC/vszYlFWw+8BbuDbPsp/btnko/f3Opiv9GehwipM=";
				mvnJdk = pkgs.jdk8;
			};
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
